
-- TODO: Should be able to set damage threshold or multiplier or something

local comp = {
	Name = "TRIGGER_HURT",
	Type = "TRIGGER",
	ReturnType = "None",
	Cost = 100,
	Invoke = function( self, ply, args )
		local hookid = "MM_EntityTakeDamage_" .. tostring( self ) .. "_" .. tostring( ply )
		hook.Add( "EntityTakeDamage", hookid, function( target, dmginfo )
			if ( target == ply ) then
				args[1]()
				-- hook.Remove( "EntityTakeDamage", hookid )
			end
		end )
	end,
}
MM_AddComponent( comp )
