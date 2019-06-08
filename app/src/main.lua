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

    --- Spikes
    local SPIKES = {}
    local SPIKE_WIDTH = 16
    local SPIKE_HEIGHT = 16

    --- Goal
    local goal = {}

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
    function loadTileMap(path)

        --- load map
        ALT.Loader.path = path
        map = ALT.Loader.load('map.tmx')
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
            if obj.type == 'spike' then spawnSpike(obj.x, obj.y) end
            if obj.type == 'goal' then spawnGoal(obj.x, obj.y) end
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
            playAnimation = playerWalk('left', dt)
        elseif love.keyboard.isDown('right') or love.keyboard.isDown('d') then
            playAnimation = playerWalk('right', dt)
        else
            playAnimation = idlePlayer()
        end

        playAnimation:update(dt)
        
        --- Applies gravity and acceleration to player if its in air
        applyWorldForces(dt);

        --- Move player according to current acceleration
        player.l, player.t, cols, len = WORLD:move(player, player.l, player.t + player.acceleration)

        --- if player is in air and collision occured, make player drop
        if not playerOnGround() and len > 0 then
            player.acceleration = 0
            player.velocity     = 0
        end

        --- Handle collisions
        handlePlayerCollisions(cols, len, 'vertical')

        --- die if player falls of map
        if (player.t > map.height * TILE_HEIGHT) then die() end
    end

    --- Moves player left or right depending on direction passed
        --- direction: Direction in which player wants to move ['left', 'right']
        --- dt: differenct in time between last frame and this one
    function playerWalk(direction, dt)
        --- get direction
        local dir =  -1
        if direction == 'right' then dir = 1 end

        --- move player
        player.l, player.t, cols, len = WORLD:move(player, player.l + PLAYER_SPEED * dt * dir, player.t)
        player.direction   = direction

        handlePlayerCollisions(cols, len, 'horizontal')

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

    --- Applies neccessary forces to player object
        -- Player acceleration and velocity are 0 if player is standing on ground
        -- Player acceleration is increased by velocity in each frame
        -- Player velocity is increased by dt times gravity, where dt is difference in time between last frame and this one
    function applyWorldForces(dt)
        if playerOnGround() then
            player.acceleration = 0
            player.velocity     = 0 
         else
             player.velocity     = player.velocity + dt * GRAVITY
             player.acceleration = player.acceleration + player.velocity
         end
    end

    --- Determines if player is currently on ground
    function playerOnGround()
        goalY = player.t + player.acceleration

        actualX, actualY, cols, len = WORLD:check(player, player.l, goalY)

        if actualY == goalY then return false else return true end
    end

    --- Handles collisions that occured with player
        -- cols: array of collisons that occured
        -- len: number of collisions that occured (len = #cols)
        -- direction: direction in which movement was made ['vertical', 'horizonal'] used for more precise detection
    function handlePlayerCollisions(cols, len, direction)
        for i = 1, len do
            if cols[i].other.type == 'spike' and direction == 'vertical' then die()
            elseif cols[i].other.type == 'goal' then nextLevel() end
        end
    end

    --- Callback function after player has lost one of their lifes
    function die()
        player.l = player.startL
        player.t = player.startT
    
        WORLD:update(player, player.l, player.t)
    end

    --- Draws player object 
    function drawPlayer()
        playAnimation:draw(PLAYER_SPRITE, player.l, player.t)
    end

--- Spikes Functions

    --- Adds spikes to World
    function spawnSpike(x, y)
        local id = #SPIKES + 1
        
        SPIKES[id] = {
            l = x,
            t = y,
            w = SPIKE_WIDTH / 4,
            h = SPIKE_HEIGHT / 4,
            type = 'spike'
        }

        WORLD:add(SPIKES[id], SPIKES[id].l, SPIKES[id].t, SPIKES[id].w, SPIKES[id].h)
    end

--- Goal Functions

    --- Adds goal object to World
    function spawnGoal(x, y)
        goal = {
            l = x,
            t = y,
            w = 16,
            h = 80,
            type = 'goal'
        }

        WORLD:add(goal, goal.l, goal.t, goal.w, goal.h)
    end

--- GUI Functions
    function nextLevel()
        print('Advance to next level.')
        die()
    end

function love.keypressed(k)
    if k == 'w' or k == 'up' then
        player.velocity = 0
        player.acceleration = -PLAYER_JUMP_AMOUNT
    end
end

function love.load()
    loadTileMap('assets/maps/level_1/')
end

function love.update(dt)
    updatePlayer(dt)
end

function love.draw()
    map:draw()
    drawPlayer()
end
