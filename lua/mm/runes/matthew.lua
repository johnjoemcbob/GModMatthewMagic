
local rune = {
	Name = "Matthew",
	Shape = {
		{ "N", 0.8, 1 },
		{ "SE", 0.4, 0.8 },
		{ "NE", 0.4, 0.8 },
		{ "S", 0.8, 1 },
	},
	Invoke = function( self, ply )
		ply:Say( "Matthew" )
	end,
}
MM_AddRune( rune )
