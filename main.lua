print(love.graphics.getRendererInfo())
require("util")
class=require("middleclass")
softbody=require("soft")
slime_root=require("slime")
slime_ball=require("ball")
slime_rect=require("rect")
slime_polygon=require("polygon")
require "gameSetting"
touch=require("touch")
local antiCount=2
function love.load() 
	game.slimes={}
	table.insert(game.slimes,slime_ball:new("test",400,100,50))
	--table.insert(game.slimes,slime_rect:new("test",400,100,60))  
end


function love.draw()
    touch:draw()
    for i,v in ipairs(game.slimes) do
    	v:draw()
    end
    love.graphics.line(400,0,800,600,800,0)
    love.graphics.line(0,300,800,600,0,600)

end

local function slideTest()


end

function love.update(dt) 
    touch:update()
    --antiCount=antiCount-dt
    if antiCount<0 then
    	antiCount=2
    	local slime=slime_ball:new("test",100,500,60)
    	table.insert(game.slimes,slime)
    	slime.body.centerBody:applyForce(500000,-1000000)
    end
    
    for i=#game.slimes,1,-1 do
    	if game.slimes[i].dead then
    		table.remove(game.slimes, i)
    	end
    end
    for i,v in ipairs(game.slimes) do
    	if v.body.slideResults then
    		local xA,yA,vertA,xB,yB,vertB=v.body:divise()
	    	v.body:destroy()
	    	local slime=slime_polygon:new("test",xA,yA,vertA)
	    	slime.body.antiCount=1
	    	table.insert(game.slimes,slime)
	    	local slime=slime_polygon:new("test",xB,yB,vertB)
	    	slime.body.antiCount=1
	    	table.insert(game.slimes,slime)
    	end
    	v:update()
    end
    game.world:update(dt)
end 

function love.keypressed(key,isrepeat) --Callback function triggered when a key is pressed.
	
end

function love.mousepressed(x, y, button) 
    
end


function love.keyreleased(key)
    
end

function love.textinput(text)
    
end

function love.mousereleased(x, y, button)
    
end

--[[
function love.quit() --Callback function triggered when the game is closed.
end 
function love.resize(w,h) --Called when the window is resized.
end 
function love.textinput(text) --Called when text has been entered by the user.
end 
function love.threaderror(thread, err ) --Callback function triggered when a Thread encounters an error.
end 
function love.visible() --Callback function triggered when window is shown or hidden.
end 
function love.mousefocus(f)--Callback function triggered when window receives or loses mouse focus.
end
function love.mousepressed(x,y,button) --Callback function triggered when a mouse button is pressed.
end 
function love.mousereleased(x,y,button)--Callback function triggered when a mouse button is released.
end 
function love.errhand(err) --The error handler, used to display error messages.
end 
function love.focus(f) --Callback function triggered when window receives or loses focus.
end 
function love.keypressed(key,isrepeat) --Callback function triggered when a key is pressed.
end
function love.keyreleased(key) --Callback function triggered when a key is released.
end 
function love.run() --The main function, containing the main loop. A sensible default is used when left out.
end
]]