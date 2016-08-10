game={}
game.type="game"
contact=require("contact")
love.window.setTitle("slimes must die")
love.graphics.setBackgroundColor(10, 10, 50)
game.world = love.physics.newWorld(0, 9.8*100, false)
love.physics.setMeter(20)
--game.world:setCallbacks(contact.start,contact.over)
local body = love.physics.newBody(game.world, 0, 0)
local shape = love.physics.newChainShape(true, 0, 0, 800, 0, 800, 600, 0, 600)
local fixture = love.physics.newFixture(body, shape)
fixture:setUserData({obj=game})

local body = love.physics.newBody(game.world, 0, 0)
local shape = love.physics.newChainShape(false, 400,0,800,600,800,0)
local fixture = love.physics.newFixture(body, shape)

local body = love.physics.newBody(game.world, 0, 0)
local shape = love.physics.newChainShape(false, 0,300,800,600,0,600)
local fixture = love.physics.newFixture(body, shape)
