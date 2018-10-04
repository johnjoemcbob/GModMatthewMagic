
local wop = {
	Name = "LONG",
	Invoke = function( self, ply )
		MM_SetModifier( ply, "scale", 10 )
	end,
}
MM_AddWOP( wop )
