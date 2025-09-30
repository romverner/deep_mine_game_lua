require('logic.physics')
require('classes.entity')

Player = Entity:new()

Player.width = 12
Player.halfWidth = Player.width / 2
Player.height = 12
Player.halfHeight = Player.height / 2
Player.speed = 0.2

Player.lastDirection = 1

-- Moves
Player.jumpHeight = 0.97
Player.jumpTime = 3 -- frames to wait (60FPS lock)
Player.jumpFrame = 0
Player.jumping = false

-- Sensing
Player.sense = {}

-- These are used for collision handling during jumps
Player.sense.ground = { x = Player.x, y = Player.y + Player.height + 1, w = Player.width - 2, h = 1 }
Player.sense.ceiling = { x = Player.x, y = Player.y - 2, w = Player.width - 2, h = 1 }

-- These are used for tile sensing during actions
Player.sense.left = { x = Player.x - 1, y = Player.y + Player.halfHeight, w = 1, h = 3 }
Player.sense.right = { x = Player.x + Player.width, y = Player.y + Player.halfHeight, w = 1, h = 3 }
Player.sense.down = { x = Player.x + Player.halfWidth, y = Player.y + Player.height + 2, w = 2, h = 1 }
Player.sense.up = { x = Player.x + Player.halfWidth, y = Player.y + - 2, w = 2, h = 1 }

-- Animations
Player.spriteSheet = love.graphics.newImage('sprites/nude.png')
Player.grid = anim8.newGrid(16, 16, Player.spriteSheet:getWidth(), Player.spriteSheet:getHeight())
Player.animations = {}
Player.animations.left = anim8.newAnimation(Player.grid('1-6', 2), 0.1)
Player.animations.right = anim8.newAnimation(Player.grid('1-6', 3), 0.1)

-- Status Trackers
Player.airborn = false
Player.mining = false

function Player:updateCoordTrackers()
    self.center.x = self.x + self.halfWidth
    self.center.y = self.y + self.halfHeight
    self.sense.ground.x = self.x + 1
    self.sense.ground.y = self.y + self.height
    self.sense.ceiling.x = self.x + 1
    self.sense.ceiling.y = self.y - 1
    self.sense.left.x = self.x - 2
    self.sense.left.y = self.y + self.halfHeight
    self.sense.right.x = self.x + self.width + 1
    self.sense.right.y = self.y + self.halfHeight
    self.sense.down.x = self.x + self.halfWidth - 1
    self.sense.down.y = self.y + self.height + 2
    self.sense.up.x = self.x + self.halfWidth - 1
    self.sense.up.y = self.y - 6
end

function Player:setBump(world)
    world:add(self, self.x, self.y, self.width, self.height)
end

function Player:setDirection()
    if love.keyboard.isDown('d') then
        self.dx = 1
    elseif love.keyboard.isDown('a') then
        self.dx = -1
    else
        self.dx = 0
    end
end

function Player:jump()
    if self.jumpFrame == 0 and not self.airborn then
        self.dy = - 1
        self.jumping = true
    end
end

function Player:trackJump()
    if self.jumping and self.jumpFrame <= self.jumpTime then
        self.jumpFrame = self.jumpFrame + 1
    elseif self.jumping and self.jumpFrame > self.jumpTime then
        self.jumping = false
        self.jumpFrame = 0
    end
end

function Player:trackMine(world)
    self.mining = false

    if not self.airborn and love.keyboard.isDown('lshift') then
        local tile = nil

        if love.keyboard.isDown('w') then
            tile = TestMap:getTileAtCoords(self.sense.up)
        elseif self.dx == -1 then
            tile = TestMap:getTileAtCoords(self.sense.left)
        elseif self.dx == 1 then
            tile = TestMap:getTileAtCoords(self.sense.right)
        elseif self.dx == 0 and love.keyboard.isDown('s') then
            tile = TestMap:getTileAtCoords(self.sense.down)
        end

        if tile and tile.type == 1 and tile.mineable then
            self.mining = true
            tile.color = COLORS.BLACK
            tile:mine()
        end
    end
end

function Player:move(dt, world)
    if self.dx ~= 0 then
        self.lastDirection = self.dx
    end

    self:setDirection()
    self.vx = self.vx * 0.78 + self.dx * self.speed
    local xPrime = self.x + self.vx

    -- Ceiling Detect to Reset Jump
    local ceilingCols, ceilingLen = world:queryRect(
        self.sense.ceiling.x,
        self.sense.ceiling.y,
        self.sense.ceiling.w,
        self.sense.ceiling.h
    )

    if ceilingLen > 0 then
        self.jumping = false
        self.jumpFrame = 0
        self.dy = 1
    end

    -- Ground Detect
    local groundCols, groundLen = world:queryRect(
        self.sense.ground.x,
        self.sense.ground.y,
        self.sense.ground.w,
        self.sense.ground.h
    )
    
    if groundLen > 0 then
        self.airborn = false

        if not self.jumping then
            self.dy = 0
        end
    elseif ceilingLen > 0 then
        self.airborn = true
        self.jumping = false
        self.jumpFrame = 0
        self.dy = 1
        self.vy = 0
    else
        self.airborn = true

        if not self.jumping then
            self.dy = 1
        else
            self.dy = -1
        end
    end

    self:trackJump()

    if self.dy ~= 0 then
        if self.jumping then
            self.vy = self.vy - self.jumpHeight
        else
            self.vy = self.vy + GamePhysics.gravity
        end
    else
        self.vy = 0
    end

    local yPrime = self.y + self.vy
    local actualX, actualY = world:move(self, xPrime, yPrime)

    self.x = actualX
    self.y = actualY

    -- World Boundary Detect
    if self.x < 0 then
        self.x = 0
    elseif self.x + self.width > worldWidth then
        self.x = worldWidth - self.width
    end

    self:trackMine(world)

    self:updateCoordTrackers()
    world:update(self, self.x, self.y)
end

function Player:udpateAnimations(dt)
    if self.dx == 1 then
        Player.animations.right:update(dt)    
    elseif self.dx == -1 then
        Player.animations.left:update(dt)
    end
end

function Player:draw()
    COLORS.set(COLORS.WHITE, 1)
    love.graphics.rectangle('fill', self.x, self.y, self.width, self.height)
    
    if self.dx == 1 or (self.dx == 0 and self.lastDirection == 1) then
        -- Player.animations.right:draw(Player.spriteSheet, self.x, self.y)
    elseif self.dx == -1 or (self.dx == 0 and self.lastDirection == -1) then
        -- Player.animations.left:draw(Player.spriteSheet, self.x, self.y)
    end

    love.graphics.print(self.airborn and 'yes' or 'no', self.x, self.y - 20)
    love.graphics.print(self.mining and 'yes' or 'no', self.x, self.y - 40)

    if DEBUG then
        COLORS.set(COLORS.RED, 1)
        love.graphics.rectangle('fill', self.sense.ground.x, self.sense.ground.y, self.sense.ground.w, self.sense.ground.h)
        love.graphics.rectangle('fill', self.sense.ceiling.x, self.sense.ceiling.y, self.sense.ceiling.w, self.sense.ceiling.h)
        love.graphics.rectangle('fill', self.sense.left.x, self.sense.left.y, self.sense.left.w, self.sense.left.h)    
        love.graphics.rectangle('fill', self.sense.right.x, self.sense.right.y, self.sense.right.w, self.sense.right.h)    
        love.graphics.rectangle('fill', self.sense.down.x, self.sense.down.y, self.sense.down.w, self.sense.down.h)    
        love.graphics.rectangle('fill', self.sense.up.x, self.sense.up.y, self.sense.up.w, self.sense.up.h)    
    end
end

return Player
