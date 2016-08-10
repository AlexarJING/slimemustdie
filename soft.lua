--rewrite from the lib softball by Alexar JING 
--softbody lib by Shorefire/Steven
--tesselate function by Amadiro/Jonathan Ringstad
local function copy(from)
	local to = {};

	for i,v in pairs(from) do
		to[i] = v;
	end

	return to;
end

function math.getDistance(x1,y1,x2,y2)
	return ((x1-x2)^2+(y1-y2)^2)^0.5
end

function math.polygonTrans(x,y,rot,size,v)
	local tab={}
	for i=1,#v/2 do
		tab[2*i-1],tab[2*i]=math.axisRot(v[2*i-1],v[2*i],rot)
		tab[2*i-1]=tab[2*i-1]*size+x
		tab[2*i]=tab[2*i]*size+y
	end
	return tab
end

function math.axisRot(x,y,rot)
	return math.cos(rot)*x-math.sin(rot)*y,math.cos(rot)*y+math.sin(rot)*x
end

local softbody = setmetatable({}, {
	__call = function(self, world, x, y, r, s, t)
		local new = copy(self);
		new:init(world, x, y, r, s, t);

		return setmetatable(new, getmetatable(self));
	end,
	__index = function(self, i)
		return self.nodes[i] or false;
	end,
	__tostring = function(self)
		return "softbody";
	end
});

function softbody:newBall(arg)
	local r=arg.r
	local x=arg.x
	local y=arg.y
	self.centerBody = love.physics.newBody(self.world, x, y, "dynamic");
	self.centerShape = love.physics.newCircleShape(10);
	self.centerfixture = love.physics.newFixture(self.centerBody, self.centerShape,30);
	--self.centerfixture:setMask(1);
	self.centerfixture:setUserData({obj=self,node=0})
	--create 'nodes' (outer bodies) & connect to center body
	self.nodeShape = love.physics.newCircleShape(1);
	self.nodes = {};
	self.r=r
	local nodes = r;

	for node = 1, nodes do
		local angle = (2*math.pi)/nodes*node;
		
		local posx = x+r*math.cos(angle);
		local posy = y+r*math.sin(angle);

		local b = love.physics.newBody(self.world, posx, posy, "dynamic");
		b:setAngularDamping(50);
		
		local f = love.physics.newFixture(b, self.nodeShape,10);
		f:setFriction(30);
		f:setRestitution(0);
		f:setUserData({obj=self,node=node})
		
		local j = love.physics.newDistanceJoint(self.centerBody, b, posx, posy, posx, posy, false);
		j:setDampingRatio(0.1);
		j:setFrequency(12*(20/r));

		table.insert(self.nodes, {body = b, fixture = f, joint = j});
	end


	--connect nodes to eachother
	for i = 1, #self.nodes do
		if i < #self.nodes then
			local j = love.physics.newDistanceJoint(self.nodes[i].body, self.nodes[i+1].body, self.nodes[i].body:getX(), self.nodes[i].body:getY(),
			self.nodes[i+1].body:getX(), self.nodes[i+1].body:getY(), false);
			self.nodes[i].joint2 = j;
		else
			local j = love.physics.newDistanceJoint(self.nodes[i].body, self.nodes[1].body, self.nodes[i].body:getX(), self.nodes[i].body:getY(),
			self.nodes[1].body:getX(), self.nodes[1].body:getY(), false);
			self.nodes[i].joint3 = j;
		end
	end

	

end


function softbody:newPolygon(arg)
	local x=arg.x
	local y=arg.y
	local vert=arg.vert
	self.centerBody = love.physics.newBody(self.world, x, y, "dynamic");
	self.centerShape  = love.physics.newPolygonShape(unpack(math.polygonTrans(0,0,0,0.7,vert)))
	self.centerfixture = love.physics.newFixture(self.centerBody, self.centerShape);
	self.nodeShape = love.physics.newCircleShape(8);
	self.centerfixture:setUserData({obj=self,node=0})
	self.nodes = {};
	local dis=16
	local node=0
	for i=1,#vert,2 do
		local ox,oy,nx,ny
		if i<#vert-2 then
			ox=vert[i]
			oy=vert[i+1]
			nx=vert[i+2]
			ny=vert[i+3]
		else
			ox=vert[i]
			oy=vert[i+1]
			nx=vert[1]
			ny=vert[2]			
		end
		local dis=math.getDistance(ox,oy,nx,ny)
		local count=math.floor(dis/12)
		if count==0 then count=1 end
		for ii=1,count+1 do
			node=node+1
			local posx=ox+(nx-ox)*((ii-1)/count)+x
			local posy=oy+(ny-oy)*((ii-1)/count)+y
			local b = love.physics.newBody(self.world, posx, posy, "dynamic");
			b:setAngularDamping(50);
			
			local f = love.physics.newFixture(b, self.nodeShape);
			f:setFriction(30);
			f:setRestitution(0);
			f:setUserData({obj=self,node=node})
			
			local j = love.physics.newDistanceJoint(self.centerBody, b, posx, posy, posx, posy, false);
			j:setDampingRatio(0.1);
			j:setFrequency(1.2);

			table.insert(self.nodes, {body = b, fixture = f, joint = j});
		end
	end

	for i = 1, #self.nodes do
		if i < #self.nodes then
			local j = love.physics.newDistanceJoint(self.nodes[i].body, self.nodes[i+1].body, self.nodes[i].body:getX(), self.nodes[i].body:getY(),
			self.nodes[i+1].body:getX(), self.nodes[i+1].body:getY(), false);
			self.nodes[i].joint2 = j;
		else
			local j = love.physics.newDistanceJoint(self.nodes[i].body, self.nodes[1].body, self.nodes[i].body:getX(), self.nodes[i].body:getY(),
			self.nodes[1].body:getX(), self.nodes[1].body:getY(), false);
			self.nodes[i].joint3 = j;
		end
	end
end


function softbody:newRect(arg)
	local x=arg.x
	local y=arg.y
	local w=arg.w
	local h=arg.h
	local vert={-w/2,-h/2,w/2,-h/2,w/2,h/2,-w/2,h/2}
	self.centerBody = love.physics.newBody(self.world, x, y, "dynamic");
	self.centerShape  = love.physics.newPolygonShape(unpack(math.polygonTrans(0,0,0,0.7,vert)))
	self.centerfixture = love.physics.newFixture(self.centerBody, self.centerShape);
	self.centerfixture:setUserData({obj=self,node=0})
	self.nodeShape = love.physics.newCircleShape(8);
	
	self.nodes = {};
	--local dis=16
	local node=0
	for i=1,#vert,2 do
		local ox,oy,nx,ny
		if i<#vert-2 then
			ox=vert[i]
			oy=vert[i+1]
			nx=vert[i+2]
			ny=vert[i+3]
		else
			ox=vert[i]
			oy=vert[i+1]
			nx=vert[1]
			ny=vert[2]			
		end
		local dis=math.getDistance(ox,oy,nx,ny)
		local count=math.floor(dis/12)
		for ii=1,count+1 do
			local posx=ox+(nx-ox)*((ii-1)/count)+x
			local posy=oy+(ny-oy)*((ii-1)/count)+y
			local b = love.physics.newBody(self.world, posx, posy, "dynamic");
			b:setAngularDamping(50);
			
			local f = love.physics.newFixture(b, self.nodeShape);
			f:setFriction(30);
			f:setRestitution(0);
			node=node+1
			f:setUserData({obj=self,node=node})
			
			local j = love.physics.newDistanceJoint(self.centerBody, b, posx, posy, posx, posy, false);
			j:setDampingRatio(0.1);
			j:setFrequency(4);

			table.insert(self.nodes, {body = b, fixture = f, joint = j});
		end
	end

	for i = 1, #self.nodes do
		if i < #self.nodes then
			local j = love.physics.newDistanceJoint(self.nodes[i].body, self.nodes[i+1].body, self.nodes[i].body:getX(), self.nodes[i].body:getY(),
			self.nodes[i+1].body:getX(), self.nodes[i+1].body:getY(), false);
			self.nodes[i].joint2 = j;
		else
			local j = love.physics.newDistanceJoint(self.nodes[i].body, self.nodes[1].body, self.nodes[i].body:getX(), self.nodes[i].body:getY(),
			self.nodes[1].body:getX(), self.nodes[1].body:getY(), false);
			self.nodes[i].joint3 = j;
		end
	end
end

function softbody:custom(arg)


end


function softbody:init(world, type ,arg, s, t, reinit) -- arg={x,y,r}
	self.world = world;
	self.form=type
	self.type="soft"
	if type=="ball" then
		self:newBall(arg)
	elseif type=="polygon" then
		self:newPolygon(arg)
	elseif type=="rect" then
		self:newRect(arg)
	elseif type=="custom" then
		self:custom(arg)
	end
	--create center body

	if not reinit then
		--set tesselation and smoothing
		self.smooth = s or 2;

		local tess = t or 4;
		self.tess = {};
		for i=1,tess do
			self.tess[i] = {};
		end
	end

	self.dead = false;
end

function softbody:update()
	--update tesselation (for drawing)
	if self.dead==true then return end
	self:selfDestroy()
	local pos = {};
	for i = 1, #self.nodes, self.smooth do
		v = self.nodes[i];

		table.insert(pos, v.body:getX());
		table.insert(pos, v.body:getY());
	end

	tessellate(pos, self.tess[1]);
	for i=1,#self.tess - 1 do
		tessellate(self.tess[i], self.tess[i+1]);
	end
end

function softbody:destroy()
	if self.dead then
		return;
	end

	for i = #self.nodes, 1, -1 do
		self.nodes[i].body:destroy();
		self.nodes[i] = nil;
	end

	self.centerBody:destroy();
	self.dead = true;
end

function softbody:setFrequency(f)
	for i,v in pairs(self.nodes) do
		v.joint:setFrequency(f);
	end
end

function softbody:setDamping(d)
	for i,v in pairs(self.nodes) do
		v.joint:setDampingRatio(d);
	end
end

function softbody:setFriction(f)
	for i,v in ipairs(self.nodes) do
		v.fixture:setFriction(0);
	end
end

function softbody:getPoints()
	return self.tess[#self.tess];
end

function softbody:draw(type, debug)
	if self.dead then
		return;
	end
	if not debug then
		love.graphics.setLineStyle("smooth");
		love.graphics.setLineWidth(self.nodeShape:getRadius()*2);

		if type == "line" then
			love.graphics.polygon("line", self.tess[#self.tess]);
		else
			love.graphics.polygon("outline", self.tess[#self.tess]);
			--love.graphics.polygon("line", self.tess[#self.tess]);
		end

		love.graphics.setLineWidth(1);


	else 
		for i,v in ipairs(self.nodes) do
			love.graphics.circle("line", v.body:getX(), v.body:getY(), self.nodeShape:getRadius());
		end
		if self.form=="ball" then
			love.graphics.circle("line", self.centerBody:getX(), self.centerBody:getY(), self.centerShape:getRadius())
		else
			love.graphics.polygon("line", self.centerBody:getWorldPoints(self.centerShape:getPoints()))
		end

		if self.slideResults then 
    		love.graphics.line(self.nodes[self.slideResults[1]].body:getX(),
							    		self.nodes[self.slideResults[1]].body:getY(),
							    		self.nodes[self.slideResults[2]].body:getX(),
							    		self.nodes[self.slideResults[2]].body:getY())
   		end  

	end
end

--tessellate function by Amadiro/Jonathan Ringstad
function tessellate(vertices, new_vertices)
   MIX_FACTOR = .5
   new_vertices[#vertices*2] = 0
   for i=1,#vertices,2 do
      local newindex = 2*i
      -- indexing brackets:
      -- [1, *2*, 3, 4], [5, *6*, 7, 8]
      -- bracket center: 2*i
      -- bracket start: 2*1 - 1
      new_vertices[newindex - 1] = vertices[i];
      new_vertices[newindex] = vertices[i+1]
      if not (i+1 == #vertices) then
	 -- x coordinate
	 new_vertices[newindex + 1] = (vertices[i] + vertices[i+2])/2
	 -- y coordinate
	 new_vertices[newindex + 2] = (vertices[i+1] + vertices[i+3])/2
      else
	 -- x coordinate
	 new_vertices[newindex + 1] = (vertices[i] + vertices[1])/2
	 -- y coordinate
	 new_vertices[newindex + 2] = (vertices[i+1] + vertices[2])/2
      end
   end

   for i = 1,#new_vertices,4 do
      if i == 1 then
   	 -- x coordinate
   	 new_vertices[1] = MIX_FACTOR*(new_vertices[#new_vertices - 1] + new_vertices[3])/2 + (1 - MIX_FACTOR)*new_vertices[1]
   	 -- y coordinate
   	 new_vertices[2] = MIX_FACTOR*(new_vertices[#new_vertices - 0] + new_vertices[4])/2 + (1 - MIX_FACTOR)*new_vertices[2]
      else
   	 -- x coordinate
   	 new_vertices[i] = MIX_FACTOR*(new_vertices[i - 2] + new_vertices[i + 2])/2 + (1 - MIX_FACTOR)*new_vertices[i]
   	 -- y coordinate
   	 new_vertices[i + 1] = MIX_FACTOR*(new_vertices[i - 1] + new_vertices[i + 3])/2 + (1 - MIX_FACTOR)*new_vertices[i + 1]
      end
   end
end

function softbody:coll(node)
	if not self.slideStart then 
		self.slideOver=false
	end

	if node==0 then 
		self.slideOver=true 
	else
		if self.slideOver then
			self.slideEnd=node
		else
			self.slideStart=node
		end
	end
	
	if self.slideStart and self.slideEnd then
		local dist=math.getLoopDist(self.slideStart,self.slideEnd,#self.nodes)
		if dist>#self.nodes/5 then
			self.slideResults={self.slideStart,self.slideEnd}
		end
		self.slideStart=nil
		self.slideEnd=nil
		self.slideOver=false
	end
end

function softbody:selfDestroy()
	if not self.antiCount then return end
	self.antiCount=self.antiCount-1/60
	if self.antiCount<0 then
		self:destroy()
	end
end

function softbody:divise()
	if not self.slideResults then return end
	local nodeA=self.slideResults[1]
	local nodeB=self.slideResults[2]
	if nodeA>nodeB then --a,b从小到大
		local tmp=nodeB
		nodeB=nodeA
		nodeA=tmp
	end

	local vertA={}
	local step=math.floor((nodeB-nodeA)/4)
	for i=nodeA,nodeB,step do
		table.insert(vertA, self.nodes[i].body:getX())
		table.insert(vertA, self.nodes[i].body:getY())
	end
	local shape = love.physics.newPolygonShape(unpack(vertA))
	local xA,yA = shape:computeMass(1)
	--math.polygonTrans(x,y,rot,size,v)
	vertA=math.polygonTrans(-xA,-yA,0,1,vertA)
	
-------------------------------------------------

	local vertB={}

	local step=math.floor((#self.nodes-nodeB+nodeA)/4)
	for i=nodeB,#self.nodes,step do
		table.insert(vertB, self.nodes[i].body:getX())
		table.insert(vertB, self.nodes[i].body:getY())
	end
	for i=1,nodeA,step do
		table.insert(vertB, self.nodes[i].body:getX())
		table.insert(vertB, self.nodes[i].body:getY())
	end

	local shape = love.physics.newPolygonShape(unpack(vertB))
	local xB,yB = shape:computeMass(1)

	vertB=math.polygonTrans(-xB,-yB,0,1,vertB)

	self.slideResults=nil
	return xA,yA,vertA,xB,yB,vertB
end

return softbody;