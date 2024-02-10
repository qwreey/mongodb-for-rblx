import { fastify } from "fastify"
import mongodb from "mongodb"
import sha1 from "js-sha1"
import * as fs from 'fs'

// Settings
const settings = fs.existsSync("../settings.json") ? JSON.parse( fs.readFileSync("../settings.json") ) : {}
function getSetting(key) {
	return settings[key] ?? process.env[key]
}

// Mongodb
const mongoClient = await new mongodb.MongoClient(getSetting("mongodbURL")).connect()
const db = mongoClient.db(getSetting("dbName"))
const server = fastify({ logger: true })
const collections = {}

// Parse tokens
const secrets = []
const tokenPermission = {
	"find": "F",
	"findAll": "FA",
	"delete": "D",
	"update": "U",
	"insert": "I",
}
{
	const rawsecret = getSetting("secret")
	let secretArray
	try { // parse json array
		secretArray = JSON.parse(rawsecret)
	} catch {
		secretArray = [ rawsecret ]
	}

	for (const rawkey of secretArray) {
		const [mode,key] = rawkey.split(":")
		if (!key) { // no permission header
			const secret = Object.fromEntries(Object.entries(tokenPermission).map(permission=>[permission[0],true]))
			secret.key = mode
			secret.hash = sha1(mode)
			secrets.push(secret)
		} else {
			const permissions = mode.split("+")
			const secret = Object.fromEntries(Object.entries(tokenPermission).map(permission=>[permission[0],permissions.includes(permission[1])]))
			secret.key = key
			secret.hash = sha1(key)
			secrets.push(secret)
		}
	}
}
console.log(secrets)
function checkPermission(action,keyhash,secret) {
	if (!action || !keyhash || !secret) return false
	const secretFound = secrets.find(secret=>secret.hash === keyhash)
	if (!secretFound) return false
	return secretFound[action] ?? false
}

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
	let data = JSON.parse(body)
	if (checkPermission(data.action, request.headers.keyhash, request.headers.secret)) {
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
				if (!result) reply.send({type: "null"})
		else reply.send({result: result, type: "array"})
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
	port: getSetting("port"),
	host: getSetting("host")
}, function (err) {
	if (err) throw err
	server.log.info(`server listening on ${server.server.address().port}`)
})
