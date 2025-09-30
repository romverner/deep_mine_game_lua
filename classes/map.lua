require('enums.colors')
require('utils.objects')
require('classes.map_tile')

Map = {}

function Map:new(xSize, ySize, tileSize, obj)
    obj = obj or getDefaultObject()
    obj.size = { x = xSize, y = ySize }
    obj.tileSize = tileSize -- tiles in this game are always square
    obj.tiles = {}
    obj.render = { yMin = 0, yMax = ySize}
    obj.color = {
        background = nil
    }

    setmetatable(obj, self)
    self.__index = self
    return obj
end

function Map:generate(world)
    local tileLayer = {}

    for x=1, self.size.x, 1 do
        for y=1, self.size.y, 1 do
            local noise = love.math.noise(x, y)
            local tileValue = noise < 0.3 and 1 or 0
            local newTile = MapTile:new(
                (x-1) * self.tileSize, 
                (y-1) * self.tileSize, 
                self.tileSize,
                tileValue
            )
            if tileValue == 1 then
                world:add(newTile, newTile.x, newTile.y, newTile.width, newTile.height)
            end
            
            table.insert(tileLayer, newTile)
        end
    end

    table.insert(self.tiles, tileLayer)
end

function Map:getIndexAtCoords(coords)
    local mapX = math.floor(coords.x / self.tileSize)
    local mapY = math.ceil(coords.y / self.tileSize)
    return mapX * self.size.y + mapY
end

function Map:getTileAtCoords(coords)
    local index = self:getIndexAtCoords(coords)
    return self.tiles[1][index]
end

function Map:setBackgroundColor(color)
    self.color.background = color
end

function Map:update(dt, world, player)
    self.render.yMin = math.max(math.ceil(player.y / self.tileSize) - 5, 1)
    self.render.yMax = math.max(math.ceil(player.y / self.tileSize) + 5, 8)

    for x=1,self.size.x,1 do
        for y=self.render.yMin,self.render.yMax,1 do
            local index = (x - 1) * self.size.y + y
            local tile = self.tiles[1][index]

            if tile and tile.type == 1 then
                if tile.health < 0 and not tile.removed then
                    world:remove(tile)
                    tile.removed = true
                    tile.mineable = false
                elseif not tile.static and tile.health > 0 then
                    -- tile.vy = tile.vy * 0.9 + GamePhysics.gravity
                    -- local yPrime = tile.y + tile.vy
                    -- local actualX, actualY = world:move(tile, tile.x, yPrime)
                    -- world:update(tile, tile.x, actualY)
                    -- tile.y = actualY
                end
            end
        end
    end

    -- for i, tile in ipairs(self.tiles[1]) do
    --     if tile.type == 1 then
    --         if tile.health < 0 and not tile.removed then
    --             world:remove(tile)
    --             tile.removed = true
    --             tile.mineable = false
    --         elseif not tile.static and tile.health > 0 then
    --             -- tile.vy = tile.vy * 0.9 + GamePhysics.gravity
    --             -- local yPrime = tile.y + tile.vy
    --             -- local actualX, actualY = world:move(tile, tile.x, yPrime)
    --             -- world:update(tile, tile.x, actualY)
    --             -- tile.y = actualY
    --         end
    --     end
    -- end
end

function Map:draw(layer)
    if self.color.background then
        COLORS.set(self.color.background)
        love.graphics.rectangle(
            'fill',
            0,
            0,
            self.size.x * self.tileSize,
            self.size.y * self.tileSize
        )
    end

    for x=1,self.size.x,1 do
        for y=self.render.yMin,self.render.yMax,1 do
            local index = (x - 1) * self.size.y + y
            local tile = self.tiles[1][index]

            if tile and tile.health > 0 then
                tile:draw()
            end
        end
    end

    -- COLORS.set(COLORS.PURPLE, 0.25)
    -- for a, layer in ipairs(self.tiles) do
    --     for b, tile in ipairs(layer) do
    --         if tile.health > 0 then
    --             tile:draw()
    --         end
    --     end
    -- end
end

return Map