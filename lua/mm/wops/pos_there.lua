
local wop = {
	Name = "THERE",
	Invoke = function( self, ply )
		MM_SetModifier( ply, "pos",
			function()
				return ply:GetEyeTrace().HitPos
			end
		)
	end,
}
MM_AddWOP( wop )
