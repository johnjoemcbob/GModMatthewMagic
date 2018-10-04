
local rune = {
	Name = "Test",
	Shape = {
		Vector( 1, 0 ),
		Vector( 0, -1 ),
		Vector( -0.5, 0 ),
	},
	Invoke = function( self, ply )
		ply:Say( "test" )
	end,
}
MM_AddRune( rune )
