
local wop = {
	Name = "TELEPORT",
	Invoke = function( self, ply )
		local target = MM_GetModifier( ply, "target" )
		local pos = MM_GetModifier( ply, "pos" )
		target:SetPos( pos )
	end,
}
MM_AddWOP( wop )
