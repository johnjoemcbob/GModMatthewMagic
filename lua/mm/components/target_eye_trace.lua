
-- TODO: Could be extended to be able to check any player's eye trace

local comp = {
	Name = "TARGET_EYE_TRACE",
	Type = "TARGET",
	ReturnType = "Position",
	Cost = 10,
	Invoke = function( self, ply )
		return ply:GetEyeTrace().HitPos
	end,
}
MM_AddComponent( comp )
