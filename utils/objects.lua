-- Object with default properties used throughout game.
function getDefaultObject(existingObj)
    local obj = {
        x = 0,
        y = 0,
        vx = 0,
        vy = 0,
        ax = 0,
        ay = 0,
        dx = 0,
        dy = 0,
        width = 1,
        halfWidth = 1,
        height = 1,
        halfHeight = 1,
        radius = 1,
        center = { x = 0, y = 0 },
    }

    if existingObj then
        for key, value in pairs(obj) do
            existingObj[key] = value
        end

        return existingObj
    else
        return obj
    end
end