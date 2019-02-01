
-- Resources
local model_wing = "models/gibs/gunship_gibs_wing.mdl"

-- Variables
local placeholder

local anim = {
	Name = "WingFlap",
	States = {
		Start = {
			Enter = function( self, anim, data )
				MM_Animation_ChangeState( anim, data, "Grow" )
			end,
		},
		Grow = {
			StateTime = 0.1,
			Enter = function( self, anim, data )
				-- Create and store wing models
				data.Wings = {}
				for wing = 1, 2 do
					local wing = ClientsideModel( model_wing )
					table.insert( data.Wings, wing )
				end
			end,
			Think = function( self, anim, data )
				for k, wing in pairs( data.Wings ) do
					wing:SetPos( anim:GetAttachPoint( anim, data, k ) )
					wing:SetAngles( anim:GetAttachAngle( anim, data, k ) )

					-- Grow to scale
					MM_RenderScale( wing, LerpVector( self.StateTime / data.StateTime, Vector( 0, 0, 0 ), Vector( 1, 1, 1 ) ) )
				end

				-- Next state
				if ( data.StateTime >= self.StateTime ) then
					MM_Animation_ChangeState( anim, data, "Flap" )
				end
			end,
			Exit = function( self, anim, data )
			end,
		},
		Flap = {
			StateTime = 0.2,
			Enter = function( self, anim, data )
				
			end,
			Think = function( self, anim, data )
				for k, wing in pairs( data.Wings ) do
					wing:SetPos( anim:GetAttachPoint( anim, data, k ) )
					local ang = anim:GetAttachAngle( anim, data, k )
					ang:RotateAroundAxis( data.Entity:GetRight(), ( 1 - ( self.StateTime / data.StateTime ) ) * 2 )
					wing:SetAngles( ang )
				end

				if ( data.StateTime >= self.StateTime ) then
					MM_Animation_ChangeState( anim, data, "Shrink" )
				end
			end,
			Exit = function( self, anim, data )
				
			end,
		},
		Shrink = {
			StateTime = 0.01,
			Enter = function( self, anim, data )
				
			end,
			Think = function( self, anim, data )
				for k, wing in pairs( data.Wings ) do
					wing:SetPos( anim:GetAttachPoint( anim, data, k ) )
					wing:SetAngles( anim:GetAttachAngle( anim, data, k ) )

					-- Grow to scale
					MM_RenderScale( wing, LerpVector( 1 - ( self.StateTime / data.StateTime ), Vector( 0, 0, 0 ), Vector( 1, 1, 1 ) ) )
				end

				if ( data.StateTime >= self.StateTime ) then
					MM_Animation_ChangeState( anim, data, "Flap" ) -- Fake, trigger end
				end
			end,
			Exit = function( self, anim, data )
				MM_StopAnimation( data.Entity, anim.Name )
			end,
		},
	},
	GetAttachPoint = function( self, anim, data, index )
		local pos = data.Entity:GetPos()
		if ( data.Entity:IsPlayer() ) then
			pos = data.Entity:GetBonePosition( 8 )
			pos = pos + data.Entity:GetUp() * 10
			pos = pos + data.Entity:GetForward() * -30
		end
		pos = pos + data.Entity:GetRight() * ( ( index == 1 ) and 1 or -1 ) * 30
		return pos
	end,
	GetAttachAngle = function( self, anim, data, index )
		local ang = data.Entity:GetAngles()
			ang:RotateAroundAxis( data.Entity:GetForward(), -30 )
			ang:RotateAroundAxis( data.Entity:GetUp(), -90 + 40 * ( ( index == 1 ) and 1 or -1 ) )
		return ang
	end,
	Remove = function( self, anim, data )
		-- Remove models
		for k, wing in pairs( data.Wings ) do
			wing:Remove()
		end
	end,
}
MM_AddAnimation( anim )
