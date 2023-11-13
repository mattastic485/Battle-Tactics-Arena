Knight = Char:extend()

function Knight:new(x, y, pos, align)
    Knight.super.new(self)
    if pos % 2 == 1 then
        i = "1-2"
    else
        i = "2-1"
    end
    self = {x, y, 25, 10, 4, 3, 3, 1, align} --class specific
    self.class = "knight" --class specific
    self.spriteSheet = love.graphics.newImage("sprites/chars/"..self.class..".png")
    self.grid = anim8.newGrid(16, 16, self.spriteSheet:getWidth(), self.spriteSheet:getHeight())
    self.anim = anim8.newAnimation(self.grid(i, 1), 1)
end

function Knight:update(dt)
    self.anim:update(dt)
end

function Knight:draw()
    if self[1] >= 1 and self[2] >= 1 then
        if self.isAttacked then
            love.graphics.setColor(.9, .2, .2, 1)
        elseif self.isHealed then
            love.graphics.setColor(.3, .9, .3, 1)
        else
            love.graphics.setColor(1, 1, 1, 1)
        end
        self.anim:draw(self.spriteSheet, self[1] * tile.size, self[2] * tile.size, nil, 3)
    end
end

function Knight:mousepressed(x, y, button, istouch)
    
end