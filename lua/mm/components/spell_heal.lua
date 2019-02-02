
local comp = {
	Name = "HEAL",
	Type = "SPELL",
	Cost = 100,
	Invoke = function( self, ply )
		print( "Try invoke HEAL" )
		local trigger = self.SubComponents["Trigger"].Value
		local invoke = function()
			local ent = MM_InvokeComponent( ply, self.SubComponents["Patient"].Value )
			ent:AddBuff( 4 )
			MM_Net_Invoke( ent, self.Name .. " " .. tostring( ent:EntIndex() ) .. " because " .. trigger )
		end
		MM_InvokeComponent( ply, trigger, { invoke } )
	end,
	SubComponents = {
		-- Ent to heal
		["Patient"] =
		{
			Type = "TARGET",
			RequiredType = "Entity",
			Value = "TARGET_SELF",
		},
		-- Trigger
		["Trigger"] =
		{
			Type = "TRIGGER",
			RequiredType = "None",
			Value = "TRIGGER_HURT",
			-- Value = "TRIGGER_TIME",
		},
	},
}
MM_AddComponent( comp )
