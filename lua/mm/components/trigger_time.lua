
local comp = {
	Name = "TRIGGER_TIME",
	Type = "TRIGGER",
	ReturnType = "None",
	Cost = function( self, ply, args )
		return args[1] * 10
	end,
	Invoke = function( self, ply, args )
		-- timer.Simple( args[2], args[1] )
		args[1]()
		-- timer.Create( ply:Nick() .. "_" .. CurTime(), 1, 0, function() args[1]() end )
	end,
}
MM_AddComponent( comp )
