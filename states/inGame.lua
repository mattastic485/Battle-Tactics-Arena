local inGame = {}

--loading libraries
local anim8 = require "lib/anim8"
local Timer = require "lib/timer"
local Object = require "lib/classic"

--loading fonts
local font16 = love.graphics.newFont("alagard.ttf", 16)
local font26 = love.graphics.newFont("alagard.ttf", 26)
local font50 = love.graphics.newFont("alagard.ttf", 50)

--setting tile info
local tile = {} --stores available moving/attacking tiles
tile.size = 48
tile.x = 0 --stores mouse coordinates relative to tile coordinates
tile.y = 0
tile.sprite = {}
for i = 1, 12 do
    table.insert(tile.sprite, love.graphics.newImage("sprites/tiles/marble_wall_"..i..".png"))
end

--setting map info
local map = {
    {9, 6, 5, 1, 6, 4, 3, 8, 4, 6, 12},
    {1, 8, 4, 2, 3, 5, 2, 6, 7, 3, 1},
    {6, 7, 5, 1, 7, 1, 8, 3, 2, 5, 4},
    {5, 2, 4, 6, 8, 2, 7, 4, 8, 7, 2},
    {8, 3, 7, 1, 5, 4, 6, 1, 2, 3, 6},
    {1, 5, 8, 4, 3, 2, 8, 3, 4, 8, 7},
    {7, 3, 2, 1, 5, 6, 4, 5, 2, 6, 4},
    {6, 1, 4, 6, 8, 2, 7, 3, 1, 5, 3},
    {2, 5, 3, 7, 1, 3, 8, 6, 7, 2, 7},
    {3, 4, 2, 5, 8, 6, 7, 3, 4, 8, 1},
    {10, 7, 3, 2, 4, 1, 8, 6, 5, 3, 11}
}
map.size = 11
map.width = map.size * tile.size + tile.size

--setting character attributes: (x, y, hp, pwr, def, dex, spd, rng, alignment)
char = {
    {2, 4, 25, 8, 2, 5, 5, 1, 0},
    {2, 6, 25, 7, 5, 3, 2, 1, 0},
    {2, 8, 25, 8, 4, 2, 2, 1, 0},
    {1, 7, 25, 7, 3, 4, 4, 1, 0},
    {1, 5, 25, 10, 1, 4, 3, 4, 0},
    {1, 3, 25, 7, 1, 2, 3, 5, 0},
    {10, 8, 25, 8, 3, 4, 4, 1, 1},
    {10, 6, 25, 9, 3, 2, 2, 1, 1},
    {10, 4, 25, 8, 3, 2, 3, 1, 1},
    {11, 5, 25, 9, 2, 4, 3, 4, 1},
    {11, 7, 25, 10, 1, 2, 2, 5, 1},
    {11, 9, 25, 7, 1, 2, 3, 5, 1}
}
char.isSelected = false
char.selected = false
char.moving = false
char.attacking = false
char.missed = false
char.dodged = false
char.attacked = false
char.damage = 0
char.healed = false
char.heal = 0
s = 0 --selected char's table position
a = 0 --attacked char's table position

--setting char class
char[1].class = "ninja"
char[2].class = "paladin"
char[3].class = "knight"
char[4].class = "scout"
char[5].class = "marksman"
char[6].class = "white_mage"
char[7].class = "assassin"
char[8].class = "dark_knight"
char[9].class = "battlemage"
char[10].class = "ranger"
char[11].class = "black_mage"
char[12].class = "white_mage"


--loading char sprites
for i = 1, #char do
    if i % 2 == 0 then
        j = "1-2"
    else
        j = "2-1"
    end
    char[i].spriteSheet = love.graphics.newImage("sprites/chars/"..char[i].class..".png")
    char[i].grid = anim8.newGrid(16, 16, char[i].spriteSheet:getWidth(), char[i].spriteSheet:getHeight())
    char[i].anim = anim8.newAnimation(char[i].grid(j, 1), 1)
end

--loading attack animations
local attack = {}
attack.slash = {}
attack.slash.sprite = love.graphics.newImage("sprites/attack/hit1.png")
attack.slash.grid = anim8.newGrid(64, 64, attack.slash.sprite:getWidth(), attack.slash.sprite:getHeight())
attack.slash.anim = anim8.newAnimation(attack.slash.grid("1-5", "1-2"), .07)
attack.dslash = {}
attack.dslash.sprite = love.graphics.newImage("sprites/attack/hit6.png")
attack.dslash.grid = anim8.newGrid(64, 64, attack.dslash.sprite:getWidth(), attack.slash.sprite:getHeight())
attack.dslash.anim = anim8.newAnimation(attack.dslash.grid("1-5", "1-2"), .07)
attack.swing = {}
attack.swing.sprite = love.graphics.newImage("sprites/attack/hit4.png")
attack.swing.grid = anim8.newGrid(64, 64, attack.swing.sprite:getWidth(), attack.slash.sprite:getHeight())
attack.swing.anim = anim8.newAnimation(attack.swing.grid("1-10", 1), .07)
attack.pierce = {}
attack.pierce.sprite = love.graphics.newImage("sprites/attack/hit3.png")
attack.pierce.grid = anim8.newGrid(64, 64, attack.pierce.sprite:getWidth(), attack.slash.sprite:getHeight())
attack.pierce.anim = anim8.newAnimation(attack.pierce.grid("1-5", "1-2"), .07)
attack.fire = {}
attack.fire.sprite = love.graphics.newImage("sprites/attack/fire1.png")
attack.fire.grid = anim8.newGrid(64, 64, attack.fire.sprite:getWidth(), attack.slash.sprite:getHeight())
attack.fire.anim = anim8.newAnimation(attack.fire.grid("1-11", 1), .07)
attack.heal = {}
attack.heal.sprite = love.graphics.newImage("sprites/attack/heal.png")
attack.heal.grid = anim8.newGrid(64, 64, attack.heal.sprite:getWidth(), attack.heal.sprite:getHeight())
attack.heal.anim = anim8.newAnimation(attack.heal.grid("1-4", "1-2"), .07)

attack.anim = attack.slash.anim
attack.sprite = attack.slash.sprite

--game: (turn, p1 AP, p2 AP, p1 remaining char, p2 remaining char)
game = {1, 3, 3, 6, 6}
game.over = false

function inGame.update(dt)

    --auto ending turn
    if game[2] == 0 or game[3] == 0 then
        char.selected = false
        if game[1] % 2 == 0 then
            game[3] = 3
            game[1] = game[1] + 1
        else
            game[2] = 3
            game[1] = game[1] + 1
        end
    end

    --resetting char data
    if not char.selected then
        if s ~= 0 then
            char[s].isSelected = false
        end
        char.moving = false
        char.attacking = false
    end 

    --clearing highlighted tiles
    if not char.moving and not char.attacking then
        for i = 1, #tile do
            table.remove(tile, i)
        end
    end

    --setting AP limit
    if game[2] > 5 then
        game[2] = 5
    end
    if game[3] > 5 then
        game[3] = 5
    end

    --setting win condition
    if game[4] == 0 or game[5] == 0 then
        game.over = true
    end

    --!updating animations
    attack.anim:update(dt)
    for i = 1, #char do --char
        char[i].anim:update(dt)
    end

    --!updating timer
    Timer.update(dt)
end

function inGame.draw()

    --!drawing map
    for i, row in ipairs(map) do
        for j, til in ipairs(row) do
            love.graphics.setColor(1, 1, 1, 1)
            love.graphics.draw(tile.sprite[til], j * tile.size, i * tile.size, nil, 1.5)
            
            --highlighting tiles
            if mouseHover(j * tile.size, i * tile.size, tile.size, tile.size, mx, my) then
                love.graphics.setColor(1, 1, 1, .6)
                love.graphics.rectangle("fill", j * tile.size, i * tile.size, tile.size, tile.size)
                tile.x = j
                tile.y = i
            end
        end
    end

    --!drawing UI 
    --char stat window
    love.graphics.setColor(.2, .2, .3, .4)
    love.graphics.rectangle("fill", (map.width + tile.size), (tile.size/4), (tile.size * 6.75), (tile.size * 4.5), 10, 10)
    love.graphics.setColor(.1, .1, .1, 1)
    love.graphics.rectangle("line", (map.width + tile.size), (tile.size/4), (tile.size * 6.75), (tile.size * 4.5), 10, 10)
    love.graphics.line((map.width + tile.size) + (tile.size * 6.75)/2, (tile.size/4), ((map.width + tile.size) + (tile.size * 6.75)/2), (tile.size * 4.75))
    love.graphics.setFont(font16)
    love.graphics.print("Selected", (map.width + tile.size + tile.size * 2), tile.size/4 + tile.size * .05)
    love.graphics.print("Highlighted", ((map.width + tile.size) + (tile.size * 6.75)/2 + tile.size * .1), (tile.size/4 + tile.size * .05))
    
    --selected char stats
    love.graphics.setFont(font50)
    love.graphics.setColor(.1, .1, .1, 1)
    if char.selected then
        love.graphics.print("HP:"..char[s][3], (map.width + tile.size) + (tile.size/6), tile.size/2)
        love.graphics.print("PWR:"..char[s][4], (map.width + tile.size) + (tile.size/6), tile.size/2 + tile.size * .8)
        love.graphics.print("DEF:"..char[s][5], (map.width + tile.size) + (tile.size/6), tile.size/2 + (tile.size * .8) * 2)
        love.graphics.print("DEX:"..char[s][6], (map.width + tile.size) + (tile.size/6), tile.size/2 + (tile.size * .8) * 3)
        love.graphics.print("SPD:"..char[s][7], (map.width + tile.size) + (tile.size/6), tile.size/2 + (tile.size * .8) * 4)
    end

    --highlighted char stats
    for i = 1, #char do
        if tile.x == char[i][1] and tile.y == char[i][2] and not char[i].isSelected then
            love.graphics.print("HP:"..char[i][3], (map.width + tile.size) + (tile.size * 6.5)/2 + (tile.size/3), tile.size/2)
            love.graphics.print("PWR:"..char[i][4], (map.width + tile.size) + (tile.size * 6.5)/2 + (tile.size/3), tile.size/2 + tile.size * .8)
            love.graphics.print("DEF:"..char[i][5], (map.width + tile.size) + (tile.size * 6.5)/2 + (tile.size/3), tile.size/2 + (tile.size * .8) * 2)
            love.graphics.print("DEX:"..char[i][6], (map.width + tile.size) + (tile.size * 6.5)/2 + (tile.size/3), tile.size/2 + (tile.size * .8) * 3)
            love.graphics.print("SPD:"..char[i][7], (map.width + tile.size) + (tile.size * 6.5)/2 + (tile.size/3), tile.size/2 + (tile.size * .8) * 4)
        end
    end

    --move button
    love.graphics.setColor(.6, .6, .6, 1)
    love.graphics.setFont(font50)
    love.graphics.rectangle("fill", (map.width + tile.size), (map.size/2 * tile.size - tile.size/2), (tile.size * 6.75), (tile.size * 1.9), 10, 10)
    love.graphics.setColor(.1, .1, .1, 1)
    love.graphics.rectangle("line", (map.width + tile.size), (map.size/2 * tile.size - tile.size/2), (tile.size * 6.75), (tile.size * 1.9), 10, 10)
    love.graphics.printf("Move", (map.width + tile.size), (map.size/2 * tile.size - tile.size/2) + (tile.size * .53), (tile.size * 6.75), "center")

    --attack button
    love.graphics.setColor(.6, .6, .6, 1)
    love.graphics.rectangle("fill", (map.width + tile.size), (map.size/2 * tile.size + tile.size * 1.5), (tile.size * 6.75) , (tile.size * 1.9), 10, 10)
    love.graphics.setColor(.1, .1, .1, 1)
    love.graphics.rectangle("line", (map.width + tile.size), (map.size/2 * tile.size + tile.size * 1.5), (tile.size * 6.75), (tile.size * 1.9), 10, 10)
    if s ~= 0 and char[s].class == "white_mage" then
        love.graphics.printf("Attack/Heal", (map.width + tile.size), (map.size/2 * tile.size + tile.size * 1.5) + (tile.size * .53), (tile.size * 6.75), "center")
    else
        love.graphics.printf("Attack", (map.width + tile.size), (map.size/2 * tile.size + tile.size * 1.5) + (tile.size * .53), (tile.size * 6.75), "center")
    end

    --skils button
    love.graphics.setColor(.6, .6, .6, 1)
    love.graphics.rectangle("fill", (map.width + tile.size), (map.size/2 * tile.size + tile.size * 3.5), (tile.size * 6.75), (tile.size * 1.9), 10, 10)
    love.graphics.setColor(.1, .1, .1, 1)
    love.graphics.rectangle("line", (map.width + tile.size), (map.size/2 * tile.size + tile.size * 3.5), (tile.size * 6.75), (tile.size * 1.9), 10, 10)
    love.graphics.printf("Skills", (map.width + tile.size), (map.size/2 * tile.size + tile.size * 3.5) + (tile.size * .53), (tile.size * 6.75), "center")

    --end turn button
    love.graphics.setColor(.6, .6, .6, 1)
    love.graphics.rectangle("fill", (map.width + tile.size), (map.size/2 * tile.size + tile.size * 5.5), (tile.size * 6.75), (tile.size * 1.9), 10, 10)
    love.graphics.setColor(.1, .1, .1, 1)
    love.graphics.rectangle("line", (map.width + tile.size), (map.size/2 * tile.size + tile.size * 5.5), (tile.size * 6.75), (tile.size * 1.9), 10, 10)
    love.graphics.printf("End Turn", (map.width + tile.size), (map.size/2 * tile.size + tile.size * 5.5) + (tile.size * .53), (tile.size * 6.75), "center")
    
    --disabling buttons 
    love.graphics.setColor(.3, .3, .3, .7)
    love.graphics.rectangle("fill", (map.width + tile.size), (map.size/2 * tile.size + tile.size * 3.5), (tile.size * 6.75), (tile.size * 1.9), 10, 10)
    if not char.selected then
        --love.graphics.setColor(.3, .3, .3, .7)
        love.graphics.rectangle("fill", (map.width + tile.size), (map.size/2 * tile.size - tile.size/2), (tile.size * 6.75), (tile.size * 1.9), 10, 10)
        love.graphics.rectangle("fill", (map.width + tile.size), (map.size/2 * tile.size + tile.size * 1.5), (tile.size * 6.75), (tile.size * 1.9), 10, 10)
        --love.graphics.rectangle("fill", (map.width + tile.size), (map.size/2 * tile.size + tile.size * 3.5), (tile.size * 6.75), (tile.size * 1.9), 10, 10)
    end

    --turn indicator 
    love.graphics.setColor(.9, .9, .9, 1)
    love.graphics.setFont(font50)
    if game[1] % 2 == 0 then
        love.graphics.printf("Red's Turn", tile.size/2, 1, map.width, "center")
    else
        love.graphics.printf("Green's Turn", tile.size/2, 1, map.width, "center")
    end

    --AP indicator
    love.graphics.setColor(.9, .9, .9, 1)
    love.graphics.setFont(font26)
    love.graphics.printf("Action Points", tile.size/2, (map.width + tile.size * .01), map.width, "center")
    for i = 4, 8, 1 do --empty
        love.graphics.setColor(.7, .6, .2, .5)
        love.graphics.circle("fill", ((tile.size * i) + (tile.size/2)), (map.width + tile.size/3 + tile.size/2), tile.size/3)
    end
    if game[1] % 2 == 0 then --fill for red team
        for i = 4, game[3] + 3, 1 do
            love.graphics.setColor(.7, .7, .1, 1)
            love.graphics.circle("fill", ((tile.size * i) + (tile.size/2)), (map.width + tile.size/3 + tile.size/2), tile.size/3)
        end
    else --fill for green team
        for i = 4, game[2] + 3, 1 do 
            love.graphics.setColor(.7, .7, .1, 1)
            love.graphics.circle("fill", ((tile.size * i) + (tile.size/2)), (map.width + tile.size/3 + tile.size/2), tile.size/3)
        end
    end
    for i = 4, 8, 1 do --outline
        love.graphics.setColor(.6, .5, 0, 1)
        love.graphics.circle("line", ((tile.size * i) + (tile.size/2)), (map.width + tile.size/3 + tile.size/2), tile.size/3)
    end

    --!setting moving limits
    love.graphics.setColor(.7, 1, .7, .6)
    if char.moving then
        for i = 1, #tile do --clearing tile table
            table.remove(tile, i)
        end
        for i = char[s][7], 1, -1 do
            for j = 1, i, 1 do
                
                --topright
                if (char[s][1] * tile.size) + (tile.size * j) < map.width and (char[s][2] * tile.size) + (tile.size * i) - (tile.size * char[s][7]) > 1 then
                    love.graphics.rectangle("fill", (char[s][1] * tile.size) + (tile.size * j), (char[s][2] * tile.size) + (tile.size * i) - (tile.size * char[s][7]), tile.size, tile.size)
                    table.insert(tile, {char[s][1] + j, char[s][2] + i - char[s][7]})
                end

                --bottomright
                if (char[s][1] * tile.size) + (tile.size * -i) + (tile.size * char[s][7]) < map.width and (char[s][2] * tile.size) + (tile.size * j) < map.width then
                    love.graphics.rectangle("fill", (char[s][1] * tile.size) + (tile.size * -i) + (tile.size * char[s][7]), (char[s][2] * tile.size) + (tile.size * j), tile.size, tile.size)
                    table.insert(tile, {char[s][1] - i + char[s][7], char[s][2] + j})
                end

                --bottomleft
                if (char[s][1] * tile.size) + (tile.size * -j) > 1 and (char[s][2] * tile.size) + (tile.size * -i) + (tile.size * char[s][7]) < map.width then
                    love.graphics.rectangle("fill", (char[s][1] * tile.size) + (tile.size * -j), (char[s][2] * tile.size) + (tile.size * -i) + (tile.size * char[s][7]), tile.size, tile.size)
                    table.insert(tile, {char[s][1] - j, char[s][2] - i + char[s][7]})
                end

                --topleft
                if (char[s][1] * tile.size) + (tile.size * i) - (tile.size * char[s][7]) > 1 and (char[s][2] * tile.size) + (tile.size * -j) > 1 then
                    love.graphics.rectangle("fill", (char[s][1] * tile.size) + (tile.size * i) - (tile.size * char[s][7]), (char[s][2] * tile.size) + (tile.size * -j), tile.size, tile.size)
                    table.insert(tile, {char[s][1] + i - char[s][7], char[s][2] - j})
                end
            end
        end
    end

    --!setting attacking limits
    love.graphics.setColor(1, .7, .7, .6)
    if char.attacking then
        for i = 1, #tile do --clearing tile table
            table.remove(tile, i)
        end
        for i = char[s][8], 1, -1 do
            for j = 1, i, 1 do

                --topright
                if (char[s][1] * tile.size) + (tile.size * j) < map.width and (char[s][2] * tile.size) + (tile.size * i) - (tile.size * char[s][8]) > 1 then
                    love.graphics.rectangle("fill", (char[s][1] * tile.size) + (tile.size * j), (char[s][2] * tile.size) + (tile.size * i) - (tile.size * char[s][8]), tile.size, tile.size)
                    table.insert(tile, {char[s][1] + j, char[s][2] + i - char[s][8]})
                end

                --bottomright
                if (char[s][1] * tile.size) + (tile.size * -i) + (tile.size * char[s][8]) < map.width and (char[s][2] * tile.size) + (tile.size * j) < map.width then
                    love.graphics.rectangle("fill", (char[s][1] * tile.size) + (tile.size * -i) + (tile.size * char[s][8]), (char[s][2] * tile.size) + (tile.size * j), tile.size, tile.size)
                    table.insert(tile, {char[s][1] - i + char[s][8], char[s][2] + j})
                end

                --bottomleft
                if (char[s][1] * tile.size) + (tile.size * -j) > 1 and (char[s][2] * tile.size) + (tile.size * -i) + (tile.size * char[s][8]) < map.width then
                    love.graphics.rectangle("fill", (char[s][1] * tile.size) + (tile.size * -j), (char[s][2] * tile.size) + (tile.size * -i) + (tile.size * char[s][8]), tile.size, tile.size)
                    table.insert(tile, {char[s][1] - j, char[s][2] - i + char[s][8]})
                end

                --topleft
                if (char[s][1] * tile.size) + (tile.size * i) - (tile.size * char[s][8]) > 1 and (char[s][2] * tile.size) + (tile.size * -j) > 1 then
                    love.graphics.rectangle("fill", (char[s][1] * tile.size) + (tile.size * i) - (tile.size * char[s][8]), (char[s][2] * tile.size) + (tile.size * -j), tile.size, tile.size)
                    table.insert(tile, {char[s][1] + i - char[s][8], char[s][2] - j})
                end
            end
        end
    end

    --!drawing chars
    for i = 1, #char do
        if char[i][1] >= 1 and char[i][2] >= 1 then
            if char[i] == char[a] and char.attacked then --red highlight
                love.graphics.setColor(.9, .2, .2, 1)
            elseif char[i] == char[a] and char.healed then --green highlight
                love.graphics.setColor(.3, .9, .3, 1)
            else
                love.graphics.setColor(1, 1, 1, 1) --default color
            end
            char[i].anim:draw(char[i].spriteSheet, char[i][1] * tile.size, char[i][2] * tile.size, nil, 3)
        end
    end

    --dodge indicator
    love.graphics.setFont(font16)
    love.graphics.setColor(1, 1, 1, 1)
    if char.dodged then
        love.graphics.print("Dodged", char[a][1] * tile.size, char[a][2] * tile.size - tile.size/5)
        Timer.after(.6, function() char.dodged = false end)
    end

    --miss indicator
    if char.missed then
        love.graphics.print("Missed", char[a][1] * tile.size, char[a][2] * tile.size - tile.size/5)
        Timer.after(.6, function() char.missed = false end)
    end

    --damage indicator 
    if char.attacked then
        if char[s].class == "black_mage" then
            love.graphics.setColor(.9, .1, .9, 1)
        else
            love.graphics.setColor(1, 1, 1, 1)
        end
        if char[s].class == "black_mage" or char[s].class == "white_mage" then
            attack.anim:draw(attack.sprite, char[a][1] * tile.size, char[a][2] * tile.size - tile.size * .25, nil, .75)
        else
            attack.anim:draw(attack.sprite, char[a][1] * tile.size, char[a][2] * tile.size, nil, .75)
        end
        love.graphics.setColor(.9, .1, .1, 1)
        love.graphics.printf(char.damage, char[a][1] * tile.size, char[a][2] * tile.size - tile.size/5, tile.size, "center")
        Timer.after(.6, function() if char[a][3] <= 0 then char[a][1] = 0 char[a][2] = 0 end char.attacked = false end)
    end

    --heal indicator
    if char.healed then
        love.graphics.setColor(.1, .9, .1, 1)
        attack.anim:draw(attack.sprite, char[a][1] * tile.size, char[a][2] * tile.size, nil, .75)
        love.graphics.printf(char.heal, char[a][1] * tile.size, char[a][2] * tile.size - tile.size/5, tile.size, "center")
        Timer.after(.6, function() char.healed = false end)
    end

    --!gameover
    if game.over then

        --!if team has 0 chars
        local win
        if game[4] == 0 then
            win = "Red"
        end
        if game[5] == 0 then
            win = "Green"
        end

        --message box
        love.graphics.setColor(.2, .3, .3, .8)
        love.graphics.rectangle("fill", winWidth/2 - tile.size * 6, winHeight/8, tile.size * 12, tile.size * 6, 10, 10)
        love.graphics.setColor(.1, .1, .1, 1)
        love.graphics.rectangle("line", winWidth/2 - tile.size * 6, winHeight/8, tile.size * 12, tile.size * 6, 10, 10)
        love.graphics.setFont(font50)
        love.graphics.setColor(.9, .9, .9, 1)
        love.graphics.printf("Team "..win.." is Victorious!", winWidth/2 - tile.size * 6, winHeight/8 + tile.size * 1.25, tile.size * 12, "center")

        --rematch button
        love.graphics.setFont(font26)
        love.graphics.setColor(.6, .6, .6, 1)
        love.graphics.rectangle("fill", winWidth/2 - tile.size * 4.5, winHeight * .4, tile.size * 4, tile.size * 1.5, 10, 10)
        love.graphics.setColor(.1, .1, .1, 1)
        love.graphics.rectangle("line", winWidth/2 - tile.size * 4.5, winHeight * .4, tile.size * 4, tile.size * 1.5, 10, 10)
        love.graphics.printf("Rematch", winWidth/2 - tile.size * 4.5, winHeight * .4 + tile.size/2, tile.size * 4, "center")

        --menu button
        love.graphics.setColor(.6, .6, .6, 1)
        love.graphics.rectangle("fill", winWidth/2 + tile.size * .5, winHeight * .4, tile.size * 4, tile.size * 1.5, 10, 10)
        love.graphics.setColor(.1, .1, .1, 1)
        love.graphics.rectangle("line", winWidth/2 + tile.size * .5, winHeight * .4, tile.size * 4, tile.size * 1.5, 10, 10)
        love.graphics.printf("Menu", winWidth/2 + tile.size * .5, winHeight * .4 + tile.size/2, tile.size * 4, "center")

        --disabeling buttons
        love.graphics.setColor(.3, .3, .3, .7)
        love.graphics.rectangle("fill", winWidth/2 - tile.size * 4.5, winHeight * .4, tile.size * 4, tile.size * 1.5, 10, 10)
        --love.graphics.rectangle("fill", winWidth/2 + tile.size * .5, winHeight * .4, tile.size * 4, tile.size * 1.5, 10, 10)
    end
end

--!mouse controls
function inGame.mousepressed(x, y, button, istouch)

    --!gameover controls
    if game.over then
        if mouseHover(winWidth/2 + tile.size * .5, winHeight * .4, tile.size * 4, tile.size * 1.5, x, y) and button == 1 then
            resetGame()
            states.switch("menu")
            return
        end
    end

    --!right click
    if button == 2 then

        --unselecting move
        if char.moving then
            char.moving = false
            return
        end

        --unselecting attack
        if char.attacking then
            char.attacking = false
            return
        end
    
        --unselecting char
        if char.selected == true then
            char.selected = false
            return
        end
    end
    
    --!left click
    if button == 1 then
        if x < map.width and y < map.width and x > tile.size and y > tile.size then --if click was on map
            for i = 1, #char do 
                if char[i][1] == tile.x and char[i][2] == tile.y then --if tile is occupied
                    if char[i].isSelected then --if click self

                        --!healing self
                        if char.attacking and char[i].class == "white_mage" and enoughAP(1) then 
                            if char[i][3] < 25 then
                                char.healed = true
                                attack.anim = attack.heal.anim
                                attack.sprite = attack.heal.sprite
                                attack.anim:gotoFrame(1)
                                char.heal = char[s][4]
                                a = i
                                char[i][3] = char[i][3] + char[s][4]
                                if char[i][3] > 25 then
                                    char[i][3] = 25
                                end
                                char.attacking = false
                                spendAP(1)
                                return
                            end
                            return

                        --!deselecting char
                        else
                            char[i].isSelected = false
                            char.selected = false
                            return
                        end
                    end

                    --!attacking/healing char
                    if char.attacking then
                        for j = 1, #tile do --range check
                            if tile[j][1] == tile.x and tile[j][2] == tile.y and enoughAP(1) then --AP check 

                                --!heal
                                if char[s][9] == char[i][9] and char[s].class == "white_mage" then
                                    if char[i][3] < 25 then
                                        char.healed = true
                                        attack.anim = attack.heal.anim
                                        attack.sprite = attack.heal.sprite
                                        attack.anim:gotoFrame(1)
                                        char.heal = char[s][4]
                                        a = i
                                        char[i][3] = char[i][3] + char[s][4]
                                        if char[i][3] > 25 then
                                            char[i][3] = 25
                                        end
                                        char.attacking = false
                                        spendAP(1)
                                        return
                                    else
                                        return
                                    end
                                end
                                
                                --!attack
                                if char[s][9] ~= char[i][9] then
                                    if char[s][6] * 8 + 60 > love.math.random(100) then --accuracy check
                                        if char[i][6] * 5 < love.math.random(100) then --evasion check
                                            
                                            --slash
                                            if char[s].class == "ninja" or char[s].class == "knight" then
                                                attack.anim = attack.slash.anim
                                                attack.sprite = attack.slash.sprite
                                            end

                                            --dual slash
                                            if char[s].class == "assassin" then
                                                attack.anim = attack.dslash.anim
                                                attack.sprite = attack.dslash.sprite
                                            end
                                            
                                            --swing
                                            if char[s].class == "paladin" or char[s].class == "dark_knight" or char[s].class == "battlemage" then
                                                attack.anim = attack.swing.anim
                                                attack.sprite = attack.swing.sprite
                                            end

                                            --pierce
                                            if char[s].class == "scout" or char[s].class == "marksman" or char[s].class == "ranger" then
                                                attack.anim = attack.pierce.anim
                                                attack.sprite = attack.pierce.sprite
                                            end

                                            --fire
                                            if char[s].class == "black_mage" or char[s].class == "white_mage" then
                                                attack.anim = attack.fire.anim
                                                attack.sprite = attack.fire.sprite
                                            end

                                            --attacking
                                            attack.anim:gotoFrame(1)
                                            char.attacked = true
                                            a = i
                                            char.damage = char[s][4] - char[i][5] 
                                            char[i][3] = char[i][3] - char.damage
                                            if char[i][3] <= 0 then --kill check
                                                if char[i][9] == 0 then --updating score
                                                    game[4] = game[4] - 1
                                                else
                                                    game[5] = game[5] - 1
                                                end
                                            end
                                        else
                                            char.dodged = true
                                            a = i
                                        end
                                    else
                                        char.missed = true
                                        a = i
                                    end
                                    char.attacking = false
                                    spendAP(1)
                                    return
                                else
                                    return
                                end
                            end
                        end
                    end

                    --!avoiding conflict
                    if char.moving then
                        return
                    end
                    if char.attacking and char[s][9] == char[i][9] then
                        return
                    end

                    --!selecting char
                    if game[1] % 2 == 1 and char[i][9] == 0 then --green's turn
                        if char.selected then
                            char[s].isSelected = false
                        end
                        char[i].isSelected = true
                        char.selected = true
                        char.moving = false
                        char.attacking = false
                        s = i
                        return
                    end
                    if game[1] % 2 == 0 and char[i][9] == 1 then --red's turn
                        if char.selected then
                            char[s].isSelected = false
                        end
                        char[i].isSelected = true
                        char.selected = true
                        char.moving = false
                        char.attacking = false
                        char.damage = 0
                        s = i
                        return
                    end
                end
            end

            --!moving char
            if char.moving then
                for i = 1, #tile do --speed check
                    if tile[i][1] == tile.x and tile[i][2] == tile.y and enoughAP(1) then --AP check
                        char[s][1] = tile.x
                        char[s][2] = tile.y
                        char.moving = false
                        spendAP(1)
                        return
                    end
                end
            end
        end

        --!UI controls
        --move button
        if mouseHover((map.width + tile.size), (map.size/2 * tile.size - tile.size/2), (tile.size * 6.75), (tile.size * 1.9), x, y) then
            char.moving = true
            char.attacking = false
            return
        end
        
        --attack button
        if mouseHover((map.width + tile.size), (map.size/2 * tile.size + tile.size * 1.5), (tile.size * 6.75), (tile.size * 1.9), x, y) then
            char.attacking = true
            char.moving = false
            return
        end

        --end turn button
        if mouseHover((map.width + tile.size), (map.size/2 * tile.size + tile.size * 5.5), (tile.size * 6.75), (tile.size * 1.9), x, y) then
            char.selected = false
            if game[1] % 2 == 0 then
                game[3] = game[3] + 3
                game[1] = game[1] + 1
                return
            else
                game[2] = game[2] + 3
                game[1] = game[1] + 1
                return
            end
        end
    end
end

return inGame