
local wop = {
	Name = "WORLD",
	Invoke = function( self, ply )
		ply.MM_Target = game.GetWorld()
	end,
}
MM_AddWOP( wop )
