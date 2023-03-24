local requestHandler = require(script.Parent.requestHandler) ---@module requestHandler

---@class mongodbCollection
local collection = {}
collection.__index = collection

---@return mongodbCollection
function collection.new(db,collectionName,t)
    t = t or {}
    t.db = db
    t.name = collectionName
    return setmetatable(t,collection)
end

---@param matchModel table table Match model, you can use compare operation too
---@param options table|nil
---@return mongodbResult
---Find datas from collection with match model, you can add more opttions such as sorting with options argment. to find more information, checkout related links
---  
---example : handle error
---db:find({id=1}):hasError():boolean|string
---  
---example : compare operations  
---print(db:find({id={["$lte"]=70}}):getResult())
---  
---Related Links  
---compare operations https://koonsland.tistory.com/174  
---options https://mongodb.github.io/node-mongodb-native/4.0//interfaces/findoptions.html
function collection:find(matchModel,options)
    return requestHandler.request(self.db,self.name,
        {action="find",model=matchModel,options=options}
    )
end

---@param matchModel table Match model, you can use compare operation too
---@param options table|nil
---@return mongodbResult
---Find all datas from collection with match model, you can add more opttions such as sorting with options argment. to find more information, checkout related links
---  
---example : handle error
---db:find({id=1}):hasError():boolean|string
---  
---example : compare operations  
---db:findAll({id={["$lte"]=70}}):forEach(function(item,key) print(item) end)
---  
---Related Links  
---compare operations https://koonsland.tistory.com/174  
---options https://mongodb.github.io/node-mongodb-native/4.0//interfaces/findoptions.html
function collection:findAll(matchModel,options)
    return requestHandler.request(self.db,self.name,
        {action="findAll",model=matchModel,options=options}
    )
end

---@param matchModel table
---@param updateModel table
---@return mongodbResult
---Find all datas from collection with match model and update it, return result is updated data, for find more information about matchModel, checkout collection:find()
function collection:update(matchModel,updateModel)
    return requestHandler.request(self.db,self.name,
        {action="update",model=matchModel,update=updateModel}
    )
end

---@param deleteModel table
---@return mongodbResult
---Delete datas from collection with match model, for find more information about matchModel, checkout collection:find()
function collection:delete(deleteModel)
    return requestHandler.request(self.db,self.name,
        {action="delete",model=deleteModel}
    )
end

---@param insertModel table
---@return mongodbResult
---Create new data into collection
function collection:insert(insertModel)
    return requestHandler.request(self.db,self.name,
        {action="insert",insert=insertModel}
    )
end

function collection:sharedFind(id,matchModel,updateInterval,onUpdate)
    if updateInterval<30 then
        error("updateInterval must be higher then ")
    end

    local requestBody = {
        action="sharedFind";
        model=matchModel;
        id = id;
        updateInterval=updateInterval;
    }

    while true do
        local data = requestHandler.request(self.db,self.name,requestBody)
        coroutine.wrap(onUpdate)(data)
        wait(updateInterval-10)
    end
end

return collection
