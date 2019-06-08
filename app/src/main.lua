--- Import libraries

    --- Advanced Tield Loader  ---
    local ALT = require('plugins/advance-tiled-loader')

    --- Bump  ---
    local bump = require 'plugins/bump/bump'

    --- Anim8 ---
    local anim8 = require 'plugins/anim8/anim8'

--- Global Variables

    -- World
    local TILE_WIDTH       = 16
    local TILE_HEIGHT      = 16
    local GRAVITY          = 1.5
    local MAX_ACCELERATION = 10
    local WORLD            = bump.newWorld(8)

    --- Player
    local PLAYER_SPRITE      = love.graphics.newImage('assets/gripe/gripe.run_right.png')
    local PLAYER_DIMENSION   = 32
    local PLAYER_SPEED       = 100
    local PLAYER_JUMP_AMOUNT = 4

    --- Animations

        --- Player
        local a8 = anim8.newGrid(32, 32, PLAYER_SPRITE:getWidth(), PLAYER_SPRITE:getHeight())

            --- Walk Right
            playerWalkRight = anim8.newAnimation(a8('1-8', 1), 0.1)

            -- Walk Left
            playerWalkLeft  = anim8.newAnimation(a8('1-8', 1), 0.1)
            playerWalkLeft:flipH()

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
        map.drawObjects = false

        --- initialize tiles
        initializeTiles(map)

        --- spawn every object
        spawnObjects(map)
    end

    --- Load every tile that should be solid
    function initializeTiles(map)
        layer = map.layers['solid']

        for x, y, tile in layer:iterate() do
            local block = { 
                l = x * 16,
                t = y * 16,
                w = TILE_WIDTH / 4,
                h = TILE_HEIGHT / 4
            }

            WORLD:add(block, block.l, block.t, block.w, block.h)
        end
    end

    --- Spawns every object found in 'characters' layer
    function spawnObjects(map)
        for i, obj in pairs( map('characters').objects ) do
            if obj.type == 'player' then spawnPlayer(obj.x, obj.y) end
        end
    end

--- Player Functions

    --- Initializes main character with given coordinates
    function spawnPlayer(x, y)
        player = {
            name         = 'Goofy',
            startL       = x,
            startT       = y - PLAYER_DIMENSION,
            l            = x,
            t            = y - PLAYER_DIMENSION,
            w            = PLAYER_DIMENSION,
            h            = PLAYER_DIMENSION,
            velocity     = 0,
            acceleration = 0,
            direction    = 'right'
        }

        WORLD:add(player, player.l, player.t, player.w, player.h)
    end

    --- Updates main character position
    function updatePlayer(dt)

        --- Update player position and animation
        if love.keyboard.isDown('left') or love.keyboard.isDown('a') then
            playAnimation = movePlayer('left', dt)
        elseif love.keyboard.isDown('right') or love.keyboard.isDown('d') then
            playAnimation = movePlayer('right', dt)
        else
            playAnimation = idlePlayer()
        end

        playAnimation:update(dt)
        
        --- apply gravity and acceleration to player if its in air
        if playerOnGround() then
           player.acceleration = 0
           player.velocity     = 0 
        else
            player.velocity     = player.velocity + dt * GRAVITY
            player.acceleration = player.acceleration + player.velocity
        end

        player.l, player.t, collisions, len = WORLD:move(player, player.l, player.t + player.acceleration)

        --- if player is in air and collision occured, make player drop
        if not playerOnGround() and len > 0 then
            player.acceleration = 0
            player.velocity     = 0
        else
            --- handle other collisions
        end

        --- die if player falls of map
        if (player.t > map.height * TILE_HEIGHT) then Die() end
    end

    function movePlayer(direction, dt)
        --- get direction
        local dir =  -1
        if direction == 'right' then dir = 1 end

        --- move player
        player.l, player.t = WORLD:move(player, player.l + PLAYER_SPEED * dt * dir, player.t)
        player.direction   = direction

        --- return animation
        if player.direction == 'right' then return playerWalkRight else return playerWalkLeft end
    end

    --- Returns player 'idle' position animation
    function idlePlayer()
        if player.direction == 'left' then
            return playerIdleLeft
        else
            return playerIdleRight
        end
    end

    --- Determines if player is currently on ground
    function playerOnGround()
        goalY = player.t + player.acceleration

        actualX, actualY = WORLD:check(player, player.l, goalY)

        if actualY == goalY then return false else return true end
    end

function love.keypressed(k)
    if k == 'w' or k == 'up' then
        player.velocity = 0
        player.acceleration = -PLAYER_JUMP_AMOUNT
    end
end

function Die()
    player.l = player.startL
    player.t = player.startT

    WORLD:update(player, player.l, player.t)
end

function drawPlayer()
    playAnimation:draw(PLAYER_SPRITE, player.l, player.t)
end

function love.load()
    loadTileMap('assets/maps/level_1/', 'level_1_map.tmx')
end

function love.update(dt)
    updatePlayer(dt)
end

function love.draw()
    map:draw()
    drawPlayer()
end
