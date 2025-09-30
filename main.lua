love.keyboard.keysPressed = {}
love.keyboard.keysReleased = {}

bump = require('libraries.bump.bump')
gamera = require('libraries.gamera.gamera')
Framerate = require('utils.framerate')
GamePhysics = require('logic.physics')
push = require('libraries.push.push')

require('enums.colors')
require('classes.map')

virtualWidth = 320
virtualHeight = 180

windowWidth = 1132
windowHeight = 640

worldWidth = 40 * 16
worldHeight = 200 * 16

function love.load()
    -- makes upscaling look pixel-y instead of blurry
    love.graphics.setDefaultFilter('nearest', 'nearest')
    
    anim8 = require('libraries.anim8.anim8')
    cam = gamera.new(0,0,worldWidth,worldHeight)
    cam:setWindow(0,0, virtualWidth, virtualHeight)
    cam:setScale(1.5)

    world = bump.newWorld(16)
    push:setupScreen(virtualWidth, virtualHeight, windowWidth, windowHeight, {
        fullscreen = false,
        resizable = true
    })

    TestMap = Map:new(40, 150, 16)
    TestMap:generate(world)
    TestMap:setBackgroundColor(COLORS.BLACK)

    Player = require('entities.Player')
    Player:setBump(world)
    FPS = 0
    DEBUG = true
end

function love.update(dt)
    Framerate:track(dt)

    -- Not really FPS restricting here, just contrlling frequency at which
    -- Physics + Movement are calculated to save on resources.
    if Framerate:nextFrame() then
        Player:move(dt, world)
        TestMap:update(dt, world, Player)
        cam:setPosition(Player.x + Player.halfWidth, Player.y + Player.halfHeight)
    end

    FPS = 1 /dt
    Player:udpateAnimations(dt)
end

function love.draw()
    push:apply('start')
    cam:draw(drawToCamera)
    love.graphics.print(FPS, 5, 5)
    love.graphics.print(Player.vy, 5, 25)
    push:apply('end')
end

function love.keypressed(key)
    if key == 'space' and not Player.airborn then
        Player:jump()
    end
end

function love.resize(w, h)
    push:resize(w, h)
end

function drawToCamera()
    TestMap:draw()
    Player:draw()
end