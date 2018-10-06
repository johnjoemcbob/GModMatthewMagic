
local rune = {
	Name = "Ramp",
	Shape = {
		{ "E", 0.5, 1 },
		{ "N", 0.5, 1 },
		{ "E", 0.5, 1 },
	},
	Invoke = function( self, ply )
		ply:SetVelocity( ply:EyeAngles():Forward() * 1000 + Vector( 0, 0, 1 ) * 400 )
	end,
}
MM_AddRune( rune )
