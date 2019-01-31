
local comp = {
	Name = "FORCE",
	Type = "SPELL",
	Cost = 100,
	Invoke = function( self, ply )
		print( "Try invoke FORCE" )
		local trigger = self.SubComponents["Trigger"].Value
		local invoke = function()
			local ent = MM_InvokeComponent( ply, self.SubComponents["Forcee"].Value )
			local pos = MM_InvokeComponent( ply, self.SubComponents["Position"].Value )
			local dir = ( pos - ent:EyePos() ):GetNormalized()
			ent:SetVelocity( dir * 1000 + Vector( 0, 0, 1 ) * 1400 )
			MM_Net_Invoke( ent, self.Name .. " " .. ent:Nick() .. " because " .. trigger )
		end
		MM_InvokeComponent( ply, trigger, { invoke } )
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
		["Position"] =
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
			Value = "TRIGGER_HURT",
			-- Value = { "TRIGGER_TIME", 0 },
		},
	},
}
MM_AddComponent( comp )
