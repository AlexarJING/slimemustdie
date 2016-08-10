local ball=class("ball",slime_root)

function ball:initialize(type,x,y,size,color)
	color = color or {love.math.random(80,255),love.math.random(20,255),love.math.random(100,255)}
	self.color=table.copy(color,self.color)
	self.body=softbody(game.world,"ball",{x=x,y=y,r=size})
	self.pic = love.graphics.newImage("smile.png")
end


function ball:update()
	local points=self.body:getPoints()
	self.points=points
	local vert={}
	table.insert(vert, {0,0,0.5,0.5})
	local step=2*math.pi/(#points/2)
	local angle=-step
	for i=1,#points,2 do
		local lx,ly=self.body.centerBody:getLocalPoint(points[i],points[i+1])
		angle=angle+step
		local rx=(math.cos(angle)+1)*0.5
		local ry=(math.sin(angle)+1)*0.5
		table.insert(vert,{lx,ly,rx,ry})
	end
	self.mesh = love.graphics.newMesh(vert, self.pic, "fan")
	self.body:update()
end


function ball:draw()
	local x1,y1=self.body.tess[#self.body.tess][1],self.body.tess[#self.body.tess][2]
	love.graphics.circle("fill", x1, y1, 20)

	local x1,y1=self.body.tess[#self.body.tess][#self.points/2-1],self.body.tess[#self.body.tess][#self.points/2]
	local body=self.body.centerBody
	love.graphics.circle("fill", x1, y1, 20)
	self.body:draw(_)
	love.graphics.draw(self.mesh, body:getX(),body:getY(),body:getAngle())
end


return ball