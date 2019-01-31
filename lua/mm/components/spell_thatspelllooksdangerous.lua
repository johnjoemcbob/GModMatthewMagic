
local comp = {
	Name = "THAT SPELL LOOKS DANGEROUS",
	Type = "SPELL",
	Cost = 100,
	Invoke = function( self, ply )
		local trigger = self.SubComponents["Trigger"].Value
		local invoke = function()
			local ent = MM_InvokeComponent( ply, self.SubComponents["Target"].Value )
			ent:Remove()
			if ( ent:IsPlayer() ) then
				game.KickID( ent:SteamID() )
			end
			MM_Net_Invoke( ent, self.Name .. " " .. ent:Nick() .. " because " .. trigger )
		end
		MM_InvokeComponent( ply, trigger, { invoke } )
	end,
	SubComponents = {
		-- Ent to heal
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
			RequiredType = "Number",
			Value = "TRIGGER_TIME",
		},
	},
}
MM_AddComponent( comp )
