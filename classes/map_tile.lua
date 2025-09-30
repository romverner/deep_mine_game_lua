GamePhysics = require('logic.physics')
require('utils.objects')

MapTile = {}

function MapTile:new(x, y, size, type)
    obj = getDefaultObject()
    obj.type = type or 1
    obj.health = 60
    obj.x = x
    obj.y = y
    obj.vx = 0
    obj.vy = 0
    obj.width = size
    obj.height = size
    obj.halfWidth = size / 2
    obj.halfHeight = size / 2
    obj.center.x = obj.x + size / 2
    obj.center.y = obj.y + size / 2
    obj.color = nil
    obj.image = love.graphics.newImage('sprites/dirt.png')

    obj.static = true
    obj.removed = false
    obj.mineable = obj.type == 1 and true or false

    setmetatable(obj, self)
    self.__index = self
    return obj
end

function MapTile:draw()
    if self.health > 0 then
        if self.color then
            COLORS.set(self.color, 1)
        elseif self.type == 1 then
            COLORS.set(COLORS.WHITE, 1)
        else
            COLORS.set(COLORS.PURPLE, 1)
        end

        if self.type == 1 then
            love.graphics.draw(self.image, self.x, self.y)
        else
            COLORS.set(COLORS.BLACK, 1)
            love.graphics.rectangle('fill', self.x, self.y, self.width, self.height)
        end
    end
end

function MapTile:mine()
    self.health = self.health - 1
end

return MapTile