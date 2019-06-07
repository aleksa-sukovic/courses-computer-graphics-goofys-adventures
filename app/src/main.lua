--- Import libraries

    --- Advanced Tield Loader  ---
    local ALT = require('plugins/advance-tiled-loader')

    --- Bump  ---
    local bump = require 'plugins/bump/bump'

    --- Anim8 ---
    local anim8 = require 'plugins/anim8/anim8'

--- Global Variables

    -- World
    local tileWidth  = 16
    local tileHeight = 16
    local world      = bump.newWorld(16)
    local gravity    = 1000
    local blocks     = {}

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
        --- load map
        ALT.Loader.path = path
        map = ALT.Loader.load(mapName)

        --- initialize tiles
        findSolidTiles(map)

        map.drawObjects = false
    end

    --- Load every tile that should be solid
    function findSolidTiles(map)
        layer = map.layers['solid']

        for tileX = 0, map.width do
            for tileY = 0, map.height do
                local tile = layer(tileX, tileY)

                if tile then
                    local block = { 
                        l = (tileX) * 16,
                        t = (tileY) * 16,
                        w = tileWidth / 4,
                        h = tileHeight / 4
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
        width  = 32
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

        world:add(player, x, y - height - 4, player.w, player.h)
    end

    function movePlayer(dt)
        --- Update player position and animation
        if love.keyboard.isDown('left') then
            player.l, player.t = world:move(player, player.l - playerSpeed * dt, player.t)
            playAnimation      = playerWalkleft
            player.direction   = 'left'
        elseif love.keyboard.isDown('right') then
            player.l, player.t = world:move(player, player.l + playerSpeed * dt, player.t)
            playAnimation      = playerWalkRight
            player.direction   = 'right'
        else
            if player.direction == 'left' then
                playAnimation = playerIdleLeft 
            else 
                playAnimation = playerIdleRight
            end
        end
        playAnimation:update(dt)
        
        --- apply gravity to player
        player.velocity = player.velocity + gravity * dt / 2
        player.l, player.t = world:move(player, player.l, player.t + (player.velocity * dt))
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
    movePlayer(dt)
end

function love.draw()
    map:draw()
    drawPlayer()
end
