
local comp = {
	Name = "TRIGGER_TIME",
	Type = "TRIGGER",
	ReturnType = "Number",
	Cost = function( self, ply, args )
		return args[1] * 10
	end,
	Invoke = function( self, ply, args )
		print( "Try invoke TRIGGER_TIME " .. tostring( args[2] ) .. " " .. tostring( args[1] ) )
		timer.Simple( args[2], args[1] )
	end,
}
MM_AddComponent( comp )
