COLORS = {
    BLACK = { r = 43/255, g = 15/255, b = 84/255 },
    PURPLE = { r = 171/255, g = 31/255, b = 101/255 },
    RED = { r = 255/255, g = 79/255, b = 105/255 },
    WHITE = { r = 255/255, g = 247/255, b = 248/255 },
    ORANGE = { r = 255/255, g = 129/255, b = 66/255 },
    YELLOW = { r = 255/255, g = 218/255, b = 69/255 },
    BLUE = { r = 51/255, g = 104/255, b = 220/255 },
    TEAL = { r = 73/255, g = 231/255, b = 236/255 },
}

function COLORS.set(color, opacity)
    love.graphics.setColor(color.r, color.g, color.b, opacity or 1)
end

return COLORS