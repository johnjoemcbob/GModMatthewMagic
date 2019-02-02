
-- Resources
local particle_disappear = "watersplash"

-- Variables
local placeholder

local anim = {
	Name = "Disappear",
	States = {
		Start = {
			Enter = function( self, anim, data )
				MM_Animation_ChangeState( anim, data, "Play" )
			end,
		},
		Play = {
			StateTime = 0.1,
			Enter = function( self, anim, data )
				for bone = 1, data.Entity:GetBoneCount() do
					local pos = data.Entity:GetBonePosition( bone )
					if ( pos != nil ) then
						for i = 1, 4 do
							local effectdata = EffectData()
								effectdata:SetOrigin( pos * ( 1 + i / 100 ) )
							util.Effect( particle_disappear, effectdata )
						end
					end
				end
				MM_Animation_Remove( anim, data, "" )
			end,
			Think = function( self, anim, data )
			end,
			Exit = function( self, anim, data )
			end,
		},
	},
	Remove = function( self, anim, data )
		
	end,
}
MM_AddAnimation( anim )
