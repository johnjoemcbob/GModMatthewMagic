
local rune = {
	Name = "Spiral",
	Shape = {
		{ "E", 0.2, 0.6 },
		{ "N", 0.2, 0.6 },
		{ "W", 0.2, 0.6 },
		{ "S", 0.5, 1 },
		{ "E", 0.5, 1 },
		{ "N", 0.5, 1 },
	},
	Invoke = function( self, ply )
		ply:Ignite( 10, 30 )
	end,
}
MM_AddRune( rune )
