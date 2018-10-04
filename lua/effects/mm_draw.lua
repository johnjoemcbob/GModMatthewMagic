
function EFFECT:Init( data )

	if ( GetConVarNumber( "gmod_drawtooleffects" ) == 0 ) then return end

	local vOffset = data:GetOrigin()

	local NumParticles = 16
	local row = NumParticles / 4

	local emitter = ParticleEmitter( vOffset )

	local x, y = 0, 0
	for i = 0, NumParticles do
		-- print( x )
		-- print( y )
		local pos = vOffset + Vector( x, y, 0 ) * MM_Map_Detail / 4
			local tr = util.TraceLine( {
				start = pos + Vector( 0, 0, 100 ),
				endpos = pos - Vector( 0, 0, 1000 ),
				collisiongroup = COLLISION_GROUP_WORLD,
			} )
			pos = tr.HitPos
		local particle = emitter:Add( "effects/spark", pos )
		if ( particle ) then

			local dist = LocalPlayer():GetPos():Distance( pos )
			particle:SetVelocity( ( LocalPlayer():GetPos() - pos ) * math.random( 10, 20 ) / 10 )

			particle:SetLifeTime( 0 )
			particle:SetDieTime( 0.4 )

			particle:SetStartAlpha( 255 )
			particle:SetEndAlpha( 0 )

			particle:SetStartSize( MM_Map_Detail )
			particle:SetEndSize( 0 )

			particle:SetRoll( math.rad( 90 ) )
			-- particle:SetRollDelta( math.Rand( -200, 200 ) )

			-- particle:SetGravity( Vector( 0, 0, 100 ) )

			-- particle:SetNextThink( 1e99 ) -- Makes sure the think hook is used on all particles of the particle emitter
			-- particle:SetThinkFunction( function( pa )
				-- print( "think" )
				-- pa:SetColor( math.random( 0, 255 ), math.random( 0, 255 ), math.random( 0, 255 ) ) -- Randomize it
				-- pa:SetPos( LerpVector( vOffset, LocalPlayer():GetPos(), pa:GetLifeTime() / pa:GetDieTime() ) )
				-- pa:SetNextThink( CurTime() + 1e99 ) -- Makes sure the think hook is actually ran.
			-- end )
		end
		x = x + 1
		if ( x >= row ) then
			x = 0
			y = y + 1
		end
	end

	emitter:Finish()

end

function EFFECT:Think()
	return false
end

function EFFECT:Render()
end
