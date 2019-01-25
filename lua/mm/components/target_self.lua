
local comp = {
	Name = "TARGET_SELF",
	Type = "TARGET",
	ReturnType = "Entity",
	Cost = 10,
	Invoke = function( self, ply )
		print( "Try invoke TARGET_SELF " .. tostring( ply ) )
		return ply
	end,
}
MM_AddComponent( comp )
