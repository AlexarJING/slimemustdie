local touch={}
touch.type="touch"
touch.body = love.physics.newBody(game.world, 0, 0)
touch.shape = love.physics.newCircleShape( 0, 0, 3)
touch.fixture = love.physics.newFixture(touch.body, touch.shape)
touch.fixture:setSensor(true)
touch.fixture:setUserData({obj=touch})
touch.ox=0
touch.oy=0
touch.trace={}

function touch:traceUpdate()
	for i,v in ipairs(self.trace) do
		v[1]=v[1]-1/10
		if v[1]<0 then
			v[5]=true
		end
	end
	for i=#self.trace,1,-1 do
		if self.trace[i][5] then
			table.remove(self.trace, i)
		end 
	end
end

function touch:update()
	self:traceUpdate()
	if not love.mouse.isDown("l") then 
		--如果没有按下则回归初始位置
		self.body:setPosition(0,0)
		self.isActive=false
		return
	else
		self.isActive=true
	end 
	if self.fixture2 then
		self.fixture2:destroy()
		self.fixture2=nil
	end
	self.cx, self.cy = love.mouse.getPosition()
	table.insert(self.trace, {1,self.cx,self.cy,self.isActive})
	self.body:setPosition(self.cx,self.cy)
	if math.getDistance(self.ox,self.oy,self.cx,self.cy)>6 then
		self.shape2 = love.physics.newChainShape(false, 0, 0, self.body:getLocalPoint(self.ox,self.oy))
		self.fixture2 = love.physics.newFixture(self.body, self.shape2)
		touch.fixture2:setSensor(true)
		touch.fixture2:setUserData({obj=touch})
	end
	self.ox,self.oy=self.cx,self.cy
end

function touch:draw()
	love.graphics.circle("line", self.body:getX(), self.body:getY(), 3)

	for i=2,#self.trace do
		if self.trace[i-1][4] then
			love.graphics.line(self.trace[i-1][2],self.trace[i-1][3],self.trace[i][2],self.trace[i][3])
		end
	end
end


return touch