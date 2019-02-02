
local mag = 150

local comp = {
	Name = "TARGET_FORWARD",
	Type = "POSITION",
	ReturnType = "Position",
	Cost = 10,
	Invoke = function( self, ply )
		return ply:GetPos() + ply:GetForward() * mag
	end,
}
MM_AddComponent( comp )

local comp = {
	Name = "TARGET_BACKWARD",
	Type = "POSITION",
	ReturnType = "Position",
	Cost = 10,
	Invoke = function( self, ply )
		return ply:GetPos() + -ply:GetForward() * mag
	end,
}
MM_AddComponent( comp )

local comp = {
	Name = "TARGET_RIGHT",
	Type = "POSITION",
	ReturnType = "Position",
	Cost = 10,
	Invoke = function( self, ply )
		return ply:GetPos() + ply:GetRight() * mag
	end,
}
MM_AddComponent( comp )

local comp = {
	Name = "TARGET_LEFT",
	Type = "POSITION",
	ReturnType = "Position",
	Cost = 10,
	Invoke = function( self, ply )
		return ply:GetPos() + -ply:GetRight() * mag
	end,
}
MM_AddComponent( comp )

local comp = {
	Name = "TARGET_UP",
	Type = "POSITION",
	ReturnType = "Position",
	Cost = 10,
	Invoke = function( self, ply )
		return ply:GetPos() + ply:GetUp() * mag
	end,
}
MM_AddComponent( comp )

local comp = {
	Name = "TARGET_DOWN",
	Type = "POSITION",
	ReturnType = "Position",
	Cost = 10,
	Invoke = function( self, ply )
		return ply:GetPos() + -ply:GetUp() * mag
	end,
}
MM_AddComponent( comp )
