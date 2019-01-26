
-- TODO: Different subcomponents per player per combo, so this should be passed in OR the table shallow copied?

local comp = {
	Name = "TELEPORT",
	Type = "SPELL",
	Cost = 100,
	Invoke = function( self, ply )
		print( "Try invoke TELEPORT" )
		local trigger = self.SubComponents["Trigger"].Value
		local invoke = function()
			local ent = MM_InvokeComponent( ply, self.SubComponents["Teleportee"].Value )
			local pos = MM_InvokeComponent( ply, self.SubComponents["Target"].Value )
			ent:SetPos( pos )
			MM_Net_Invoke( ent, self.Name .. " " .. ent:Nick() .. " because " .. trigger[1] )
		end
		MM_InvokeComponent( ply, trigger, { invoke } )
	end,
	SubComponents = {
		-- Ent to move
		["Teleportee"] =
		{
			Type = "TARGET",
			RequiredType = "Entity",
			Value = "TARGET_SELF",
		},
		-- Pos to go to
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
			-- Value = "TRIGGER_HURT",
			Value = { "TRIGGER_TIME", 0 },
		},
	},
}
MM_AddComponent( comp )
