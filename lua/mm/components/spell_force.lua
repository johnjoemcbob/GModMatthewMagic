
local comp = {
	Name = "FORCE",
	Type = "SPELL",
	Cost = 100,
	Invoke = function( self, ply )
		print( "Try invoke FORCE" )
		local invoke = function()
			local ent = MM_InvokeComponent( ply, self.SubComponents["Forcee"].Value )
			local pos = MM_InvokeComponent( ply, self.SubComponents["Target"].Value )
			local dir = ( pos - ply:EyePos() ):GetNormalized()
			ply:SetVelocity( dir * 1000 + Vector( 0, 0, 1 ) * 400 )
		end
		MM_InvokeComponent( ply, self.SubComponents["Trigger"].Value, { invoke } )
	end,
	SubComponents = {
		-- Ent to move
		["Forcee"] =
		{
			Type = "TARGET",
			RequiredType = "Entity",
			Value = "TARGET_SELF",
		},
		-- Dir to go to
		["Target"] =
		{
			Type = "TARGET",
			RequiredType = "Position",
			Value = "TARGET_EYE_TRACE",
		},
		-- Trigger
		["Trigger"] =
		{
			Type = "TRIGGER",
			RequiredType = "Number",
			Value = { "TRIGGER_TIME", 0 },
		},
	},
}
MM_AddComponent( comp )
