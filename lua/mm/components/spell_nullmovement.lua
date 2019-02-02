
local comp = {
	Name = "NULL MOVEMENT",
	Type = "SPELL",
	Cost = 100,
	Invoke = function( self, ply )
		local trigger = self.SubComponents["Trigger"].Value
		local invoke = function()
			local ent = MM_InvokeComponent( ply, self.SubComponents["Target"].Value )
			ent:SetVelocity( -ent:GetVelocity() )-- Vector( 0, 0, 0 ) )
			MM_Net_Invoke( ent, self.Name .. " " .. tostring( ent:EntIndex() ) .. " because " .. trigger )
		end
		MM_InvokeComponent( ply, trigger, { invoke } )
	end,
	SubComponents = {
		-- Ent to null
		["Target"] =
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
