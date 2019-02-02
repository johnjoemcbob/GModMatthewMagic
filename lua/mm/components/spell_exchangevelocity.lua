
local comp = {
	Name = "EXCHANGE VELOCITY",
	Type = "SPELL",
	Cost = 100,
	Invoke = function( self, ply )
		local trigger = self.SubComponents["Trigger"].Value
		local invoke = function()
			local enta = MM_InvokeComponent( ply, self.SubComponents["TargetA"].Value )
			local entb = MM_InvokeComponent( ply, self.SubComponents["TargetB"].Value )
			local velocity = enta:GetVelocity()
			enta:SetVelocity( -enta:GetVelocity() + entb:GetVelocity() )
			entb:SetVelocity( -entb:GetVelocity() + velocity )
			MM_Net_Invoke( enta, self.Name .. " " .. tostring( ply:EntIndex() ) .. " because " .. trigger )
			MM_Net_Invoke( entb, self.Name .. " " .. tostring( ply:EntIndex() ) .. " because " .. trigger )
		end
		MM_InvokeComponent( ply, trigger, { invoke } )
	end,
	SubComponents = {
		-- Ent 1
		["TargetA"] =
		{
			Type = "TARGET",
			RequiredType = "Entity",
			Value = "TARGET_SELF",
		},
		-- Ent 2
		["TargetB"] =
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
			Value = "TRIGGER_TIME",
		},
	},
}
MM_AddComponent( comp )
