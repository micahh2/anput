function class(base, init)
	local c = {}    -- a new class instance
	if not init and type(base) == 'function' then
		init = base
		base = nil
	elseif type(base) == 'table' then
		-- our new class is a shallow copy of the base class!
		for i,v in pairs(base) do
			c[i] = v
		end
		c._base = base
	end
	-- the class will be the metatable for all its objects,
	-- and they will look up their methods in it.
	c.__index = c

	-- expose a constructor which can be called by <classname>(<args>)
	local mt = {}
	mt.__call = function(class_tbl, ...)
		local obj = {}
		setmetatable(obj,c)

		-- Call base class' init
		if base and base.init then
			base.init(obj, ...)
		end

		-- Call this class' init
		if c.init then
			c.init(obj,...)
		end

		return obj
	end
	c.init = init
	c.is_a = function(self, klass)
		local m = getmetatable(self)
		while m do 
			if m == klass then return true end
			m = m._base
		end
		return false
	end
	setmetatable(c, mt)

	-- Return true if the caller is an instance of theClass
	--function c:isa(theClass)
	--	local b_isa = false

	--	--local cur_class = c

	--	--while ( nil ~= cur_class ) and ( false == b_isa ) do
	--	--	if cur_class == theClass then
	--	--		b_isa = true
	--	--	else
	--	--		cur_class = base--cur_class:superClass()
	--	--	end
	--	--end

	--	--return b_isa
	--end

	return c
end
