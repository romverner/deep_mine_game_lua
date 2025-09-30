require('utils.objects')

Entity = {}

function Entity:new(obj)
    obj = obj or getDefaultObject()
    setmetatable(obj, self)
    self.__index = self
    return obj
end

return Entity