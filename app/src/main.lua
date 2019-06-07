--- Import libraries

    --- Advanced Tield Loader  ---
    local ALT = require('plugins/advance-tiled-loader')

    --- Bump  ---
    local bump = require 'plugins/bump/bump'
    local world = bump.newWorld(32)

    --- Anim8 ---
    local anim8 = require 'plugins/anim8/anim8'

--- Global Variables

    -- World
    local tileWidth  = 16
    local tileHeight = 16
    blocks = {} --- holds all the solid tiles

    --- Player
    playerSprite = love.graphics.newImage('assets/gripe/gripe.run_right.png')
    playerSpeed  = 100

    --- Animations

        --- Player
        local a8 = anim8.newGrid(32, 32, playerSprite:getWidth(), playerSprite:getHeight())

            --- Walk Right
            playerWalkRight = anim8.newAnimation(a8('1-8', 1), 0.1)

            -- Walk Left
            playerWalkleft  = anim8.newAnimation(a8('1-8', 1), 0.1)
            playerWalkleft:flipH()

            --- Jump Right
            playerJumpRight = anim8.newAnimation(a8(4, 1), 0.1)

            --- Jump Left
            playerJumpLeft  = anim8.newAnimation(a8(4, 1), 0.1)
            playerJumpLeft:flipH()

            -- Idle Right
            playerIdleRight = anim8.newAnimation(a8(1, 1), 0.1)

            -- Idle Left
            playerIdleLeft  = anim8.newAnimation(a8(1, 1), 0.1)
            playerIdleLeft:flipH()

-- Map Functions

    --- Loads a map from specified file
    function loadTileMap(path, mapName)
        ALT.Loader.path = path
        map = ALT.Loader.load(mapName)

        gravity = 1000

        findSolidTiles(map)

        map.drawObjects = false
    end

    --- Load every tile that should be solid
    function findSolidTiles(map)
        layer = map.layers['solid']

        for tileX = 1, map.width do
            for tileY = 1, map.height do
                local tile = layer(tileX - 1, tileY - 1)

                if tile then
                    local block = { 
                        l = (tileX - 1) * 16,
                        t = (tileY - 1) * 16,
                        w = tileWidth,
                        h = tileHeight
                    }

                    blocks[#blocks + 1] = block
                    world:add(block, block.l, block.t, block.w, block.h)
                end
            end
        end

        for i, obj in pairs( map('characters').objects ) do
            if obj.type == 'player' then spawnPlayer(obj.x, obj.y) end
        end

        map.drawObjects = false

    end

--- Player Functions

    function spawnPlayer(x, y)
        width = 32
        height = 32

        player = {
            name = 'Goofy',
            l = x,
            t = y - height,
            w = width,
            h = height,
            velocity = 0,
            direction = 'right'
        }

        world:add(player, x, y - height, player.w, player.h)
    end

    function playerMovement(dt)
        --- Update player position and animation
        if love.keyboard.isDown('left') then
            player.l = player.l - playerSpeed * dt

            playAnimation = playerWalkleft

            player.direction = 'left'
        elseif love.keyboard.isDown('right') then
            player.l = player.l + playerSpeed * dt

            playAnimation = playerWalkRight

            player.direction = 'right'
        elseif player.direction == 'left' then
            playAnimation = playerIdleLeft
        else
            playAnimation = playerIdleRight
        end

        playAnimation:update(dt)
        if (player.t > map.height * 16) then Die() end
    end


function love.keyreleased(k)
    if k == 'w' then isJumping = false end
end

function love.keypressed(k)
    if k == 'w' then isJumping = true end
end

function Die()
    player.l = 32
    player.t = 32
end

function drawPlayer()
    playAnimation:draw(playerSprite, player.l, player.t)
end

function love.load()
    loadTileMap('assets/maps/level_1/', 'level_1_map.tmx')
end

function love.update(dt)
    playerMovement(dt)
end

function love.draw()
    map:draw()
    drawPlayer()
end
