local httpService = game:GetService("HttpService")

local requestHandler = {
    EmptyMatchModel = "$EMPTY"
}
local sha1 = require(script.Parent.sha1)

---@class mongodbResult
local resultHandler = {}
resultHandler.__index = resultHandler

local function getError(self)
    if self.err then return self.err end
    if self.error then
        return table.concat(self.error," ",self.message or "")
    end
end

function resultHandler:hasError()
    local err = getError(self)
    if not err then
        return false
    end
    return err
end

function resultHandler:isNull()
    local err = getError(self)
    if err then
        error(err)
    end
    return self.type == "null"
end

function resultHandler:isArray()
    local err = getError(self)
    if err then
        error(err)
    end
    return self.type == "array"
end

function resultHandler:getResult()
    local err = getError(self)
    if err then
        error(err)
    end
    if self.type == "null" then return nil end
    return self.result
end

function resultHandler:forEach(func)
    local err = getError(self)
    if err then
        error(err)
    end
    if self.type ~= "array" then
        error(("data type must be array, but got %s. maybe data is not exist?")
            :format(tostring(self.type)))
    end
    for i,v in pairs(self.result) do
        func(v,i)
    end
end

function resultHandler:iterator()
    local err = getError(self)
    if err then
        error(err)
    end
    if self.type ~= "array" then
        error(("data type must be array, but got %s. maybe data is not exist?")
            :format(tostring(self.type)))
    end
    if self.type == "null" then return nil end
    return pairs(self.result)
end

local function request(db,collectionName,body)
    local strBody = httpService:JSONEncode(body)
    local url = table.concat{db.url,"/collection/",httpService:UrlEncode(collectionName)}

    if db.debug then
        warn(("MONGODB: send request\nurl: %s\nbody: %s"):format(url,strBody))
    end

    local data = httpService:JSONDecode(httpService:PostAsync(
        url,strBody,Enum.HttpContentType.TextPlain,false,{
            secret=sha1(strBody..db.secret);
        }
    ))
    return data
end

---@param db mongodb
---@return mongodbResult
function requestHandler.request(db,collectionName,body)
    local passed,result = pcall(request,db,collectionName,body)
    if not passed then
        result = {err = result}
    end
    return setmetatable(result,resultHandler)
end

return requestHandler
