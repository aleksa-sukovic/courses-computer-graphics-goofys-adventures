
local Quad = love.graphics.newQuad

local ALT = require('plugins/advance-tiled-loader')
ALT.Loader.path = "assets/maps/level_1/"

function makeCharacter()
    character = {}
    character.player = {}
    character.player['left'] = love.graphics.newImage('assets/gripe/gripe.run_left.png')
    character.player['right'] = love.graphics.newImage('assets/gripe/gripe.run_right.png')

    character.x = 50
    character.y = 50

    return character
end

function makeCharacterSprites()
    quads = {}
    quads['left'] = {}
    quads['right'] = {}

    for i = 1, 8 do
        quads['left'][i] = Quad((i - 1) * 32, 0, 32, 32, 256, 32)
        quads['right'][i] = Quad((i - 1) * 32, 0, 32, 32, 256, 32)
    end

    return quads
end

function setup()
    values = {}

    values['direction'] = 'right'
    values['iteration'] = 1
    values['max_iteration'] = 8
    values['idle'] = true
    values['timer'] = 0.1

    return values
end

function love.load()
    love.graphics.setBackgroundColor(255, 153, 0)
    map = ALT.Loader.load("level_1_map.tmx")

    character = makeCharacter()
    quads     = makeCharacterSprites()
    values    = setup()
end

function love.update(dt)
    if values.idle == true then
        return
    end

    values.timer = values.timer + dt
    if values.timer <= 0.2 then
        return
    end

    values.timer = 0.1
    values.iteration = values.iteration + 1

    if love.keyboard.isDown('right') then
        character.x = character.x + 5
    end

    if love.keyboard.isDown('left') then
        character.x = character.x - 5
    end

    if values.iteration > values.max_iteration then
        values.iteration = 1
    end
end

function love.keypressed(key)
    if quads[key] then
        values.direction = key
        values.idle = false
    end
end

function love.keyreleased(key)
    if quads[key] and values.direction == key then
        values.idle = true
        values.iteration = 1
        values.direction = 'right'
    end
end

function love.draw()
    map:draw()
    love.graphics.draw(character.player[values.direction], quads[values.direction][values.iteration], character.x, character.y)
end
