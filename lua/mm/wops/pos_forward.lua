
local wop = {
	Name = "FORWARD",
	Invoke = function( self, ply )
		MM_SetModifier( ply, "pos",
			function()
				local multiplier = 100
					local scale = MM_GetModifier( ply, "scale" )
					if ( scale ) then
						multiplier = multiplier * scale
					end
				return ply:GetPos() + ply:EyeAngles():Forward() * multiplier
			end
		)
	end,
}
MM_AddWOP( wop )
