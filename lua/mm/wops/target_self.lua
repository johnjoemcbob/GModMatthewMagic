
local wop = {
	Name = "SELF",
	Invoke = function( self, ply )
		MM_SetModifier( ply, "target", ply )
	end,
}
MM_AddWOP( wop )
