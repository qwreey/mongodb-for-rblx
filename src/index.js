import { fastify } from "fastify"
import mongodb from "mongodb"
import sha1 from "js-sha1"
import settings from "../settings.json" assert { type: "json" }

const mongoClient = await new mongodb.MongoClient(settings.mongodbURL).connect()
const db = mongoClient.db(settings.dbName)
const server = fastify({ logger: true })
const collections = {}
const secretSha = sha1(settings.secret)

server.post('/collection/*', {
    schema: {
        params: {
            '*': {
                type: "string"
            }
        }
    }
}, async (request, reply) => {
    let body = request.body
    if (request.headers.secret !== sha1(body+secretSha)) {
        reply.send({"err":"CHECKSUM FAILED (auth failed)"})
        return
    }

    const collectionName = request.params['*']
    /** @type {mongodb.Collection} */
    let collection = collections[collectionName]
    if (!collection) {
        collection = db.collection(collectionName)
        collections[collectionName] = collection
    }

    let data = JSON.parse(body)

    if (data.model == "$EMPTY") data.model = {}

    switch (data.action) {
        case "find":
            try {
                let result = await collection.findOne(data.model,data.options)
                if (!result) reply.send({type: "null"})
                else reply.send({result: result})
            } catch (err) {
                server.log.info(`MONGODB: ${err}`)
                reply.send({err: err|"Unknown error"})
            }
            return
        case "delete":
            try {
                let result = await tokens.deleteOne(data.model)
                if (!result) reply.send({type: "null"})
                else reply.send({result: result})
            } catch (err) {
                server.log.info(`MONGODB: ${err}`)
                reply.send({err: err|"Unknown error"})
            }
            return
        case "findAll":
            try {
                let result = await collection.find(data.model,data.options).toArray()
                reply.send({result: result})
            } catch (err) {
                server.log.info(`MONGODB: ${err}`)
                reply.send({type: "array",err: err|"Unknown error"})
            }
            return
        case "update":
            try {
                let result = await collection.updateOne(data.model,data.update)
                reply.send({result: result})
            } catch (err) {
                server.log.info(`MONGODB: ${err}`)
                reply.send({err: err|"Unknown error"})
            }
            return
        case "insert":
            try {
                let result = await collection.insertOne(data.insert)
                reply.send({result: result})
            } catch (err) {
                server.log.info(`MONGODB: ${err}`)
                reply.send({err: err|"Unknown error"})
            }
            return
        default:
            reply.send({err: "Unknown action"})
            return
    }
})

server.listen({
    port: settings.port,
}, function (err) {
    if (err) throw err
    server.log.info(`server listening on ${server.server.address().port}`)
})
