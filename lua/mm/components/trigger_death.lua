
local comp = {
	Name = "TRIGGER_DEATH",
	Type = "TRIGGER",
	ReturnType = "None",
	Cost = 100,
	Invoke = function( self, ply, args )
		local hookid = "MM_PlayerDeath_" .. tostring( self ) .. "_" .. tostring( ply )
		hook.Add( "PlayerDeath", hookid, function( victim, inflictor, attacker )
			if ( victim == ply ) then
				args[1]()
				-- hook.Remove( "EntityTakeDamage", hookid )
			end
		end )
	end,
}
MM_AddComponent( comp )
