
-- TODO: Could be extended to be able to check any player's eye trace

local comp = {
	Name = "TARGET_ENT_TRACE",
	Type = "TARGET",
	ReturnType = "Entity",
	Cost = 10,
	Invoke = function( self, ply )
		return ply:GetEyeTrace().Entity
	end,
}
MM_AddComponent( comp )
