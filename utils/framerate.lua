Framerate = {}

-- Used only for locking love.updates to a target framerate.
-- Helps keep down collision computing, given the # of tiles on screen.

Framerate.timer = 0
Framerate.target = 60
Framerate.rate = 1 / Framerate.target
Framerate.next = false

function Framerate:track(dt)
    if self.next then
        self.next = false
        self.timer = 0
    end
    
    self.timer = self.timer + dt

    if self.timer > self.rate then
        self.next = true
    end
end

function Framerate:reset()
    self.timer = 0
end

function Framerate:nextFrame()
    return self.next
end

return Framerate