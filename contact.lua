local c={}

function begin(a,b,coll)
	local objA=a:getUserData().obj
	local objB=b:getUserData().obj
	if objA.type=="touch" and objB.type=="soft" then
		objB:coll(b:getUserData().node)
	end
end

function over(a,b,coll)

end

function c.start(a,b,coll)
	begin(a,b,coll)
	begin(b,a,coll)
end

function c.over(a,b,coll)
	over(a,b,coll)
	over(b,a,coll)
end

function c.pre(a,b,coll)
	pre(a,b,coll)
end


function c.post(a, b, coll, normalimpulse1, tangentimpulse1, normalimpulse2, tangentimpulse2)
	post(a, b, coll, normalimpulse1, tangentimpulse1, normalimpulse2, tangentimpulse2)
	post(b, a, coll, normalimpulse1, tangentimpulse1, normalimpulse2, tangentimpulse2)
end

return c