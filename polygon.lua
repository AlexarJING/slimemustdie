local polygon=class("polygon",slime_root)

function polygon:initialize(type,x,y,vert,color)
	color = color or {love.math.random(80,255),love.math.random(20,255),love.math.random(100,255)}
	self.color=table.copy(color,self.color)
	self.body=softbody(game.world,"polygon",{x=x,y=y,vert=vert})
end

function polygon:move()

end

function polygon:update()
	self.body:update()
end




function polygon:draw()
	self.body:draw(_)
end


return polygon