GamePhysics = {}

love.physics.setMeter(16)
GamePhysics.collisionObjects =  {}
GamePhysics.gravity = 0.31
GamePhysics.limits = { velocity = 20 }

return GamePhysics