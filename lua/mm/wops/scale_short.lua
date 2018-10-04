
local wop = {
	Name = "SHORT",
	Invoke = function( self, ply )
		MM_SetModifier( ply, "scale", 1 / 2 )
	end,
}
MM_AddWOP( wop )
