
-- TODO: Could be extended to be able to check any player's eye trace

print( "hi" )
hook.Add( "PlayerShouldTakeDamage", "MM_PlayerShouldTakeDamage_LastAttacker", function( ply, attacker )
	ply.LastAttacker = attacker
	print( "Took damage: " .. tostring( ply.LastAttacker ) )
end )

local comp = {
	Name = "TARGET_LAST_ATTACKER",
	Type = "TARGET",
	ReturnType = "Entity",
	Cost = 10,
	Invoke = function( self, ply )
		return ply.LastAttacker
	end,
}
MM_AddComponent( comp )
