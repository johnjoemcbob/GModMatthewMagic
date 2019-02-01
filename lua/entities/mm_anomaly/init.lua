AddCSLuaFile( "shared.lua" )
AddCSLuaFile( "cl_init.lua" )

include( "shared.lua" )

function ENT:Initialize()
	-- Visuals
	self:SetModel( "models/effects/combineball.mdl" )
	self:SetColor( Color( 255, 255, 255, 50 ) )

	-- Physics
	self:SetSolid( SOLID_NONE )
	self:SetMoveType( MOVETYPE_NONE )

	self.Entities = {}

	self.Effect = math.random( 1, #MM_Buffs )
	self.MaxTime = 2
	self.TimeSpeed = 20

	-- local sound = CreateSound( self, "sfx/skidding.wav" )
	-- sound:ChangePitch( math.random( 0.8, 1.2 ) )
	-- sound:SetSoundLevel( 90 )
	-- sound:Play()
	self:StartLoopingSound( "sfx/skidding.wav" )
end

function ENT:Think()
	util.ScreenShake( self:GetPos(), 5, 5, 10, self.Range )

	for k, ent in pairs( ents.FindInSphere( self:GetPos(), self.Range ) ) do
		if ( ent:IsPlayer() ) then
			local dist = self:GetPos():Distance( ent:GetPos() )
			-- print( 1 - ( dist / self.Range ) )
			if ( self.Entities[ent:EntIndex()] == nil ) then
				self.Entities[ent:EntIndex()] = self.MaxTime
			end
			self.Entities[ent:EntIndex()] = self.Entities[ent:EntIndex()] - FrameTime() * self.TimeSpeed * ( 1 - ( dist / self.Range ) )
			-- print( self.Entities[ent:EntIndex()] )
			if ( self.Entities[ent:EntIndex()] <= 0 ) then
				ent:AddBuff( self.Effect )
				self.Entities[ent:EntIndex()] = nil
			end
		end
	end
end
