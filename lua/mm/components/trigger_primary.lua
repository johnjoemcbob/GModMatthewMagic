
local comp = {
	Name = "TRIGGER_PRIMARY",
	Type = "TRIGGER",
	ReturnType = "Number",
	Cost = function( self, ply, args )
		return args[1] * 10
	end,
	Invoke = function( self, ply, args )
		print( "Try invoke TRIGGER_TIME " .. tostring( args[2] ) .. " " .. tostring( args[1] ) )
		local hookid = "MM_SetupMove_" .. tostring( self ) .. "_" .. tostring( ply )
		hook.Add( "SetupMove", hookid, function( target, mv, cmd )
			if ( target == ply and mv:KeyPressed( IN_ATTACK ) ) then
				args[1]()
				-- hook.Remove( "EntityTakeDamage", hookid )
			end
		end )
	end,
}
MM_AddComponent( comp )