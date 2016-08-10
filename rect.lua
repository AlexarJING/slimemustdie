local rect=class("rect",slime_root)

function rect:initialize(type,x,y,size,color)
	color = color or {love.math.random(80,255),love.math.random(20,255),love.math.random(100,255)}
	self.color=table.copy(color,self.color)
	self.body=softbody(game.world,"rect",{x=x,y=y,w=size*0.8*2,h=size*2})
end

function rect:move()

end

function rect:update()
	self.body:update()
end




function rect:draw()
	self.body:draw(_)
end


return rect