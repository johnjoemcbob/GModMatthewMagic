
local rune = {
	Name = "Test",
	Shape = {
		{ "W", 1 },
		{ "S", 0.5, 1 },
		{ "E", 0.25, 0.75 },
	},
	Invoke = function( self, ply )
		MM_Parse( ply, "self long forward teleport" )
	end,
}
MM_AddRune( rune )
