
-- Resources
local model_rope_end = "models/props_junk/harpoon002a.mdl"
local material_rope = "cable/rope"
local particle_pierce = "watersplash"

-- Variables
local radius = 15
local radius_subtract = 0.1
local max = 30
local rise = 1
local totalsegs = 65
local half = totalsegs / 2
local segs = half + math.sin( CurTime() * 5 ) * half

-- Chain rendering
local chains = {}
hook.Add( "PostPlayerDraw", "MM_PostPlayerDraw_Animation_ChainWrap", function( ply )
	if ( !IsValid( ply ) ) then return end
	if ( !ply:Alive() ) then return end

	local width = 4
	local colour = Color( 255, 255, 255, 255 )

	for k, chain in pairs( chains ) do
		for _, rope in pairs( chain.Ropes ) do
			render.StartBeam( #rope )
				local lastpos
				for seg, pos in pairs( rope ) do
					if ( type( seg ) == "number" ) then
						local length = lastpos and ( pos:Distance( lastpos ) ) or 0
						render.AddBeam( pos, width, length, colour )
						lastpos = pos
					end
				end
			render.EndBeam()
		end
	end

	-- local maxoffset = 2
	-- for offset = 1, maxoffset do
		-- local radius = 15
		-- local segs = half + math.sin( CurTime() * 5 ) * half

		-- local z = ply:GetPos().z
		-- render.StartBeam( segs )
			-- for seg = 1, segs do
				-- local z = z + seg * rise
				-- radius = radius - radius_subtract
				-- local points = MM_GetCirclePoints( ply:GetPos().x, ply:GetPos().y, radius, max, 0 )
				-- local offset = offset * max / maxoffset
				-- local pos = points[( ( seg + offset ) % max ) + 1]
				-- render.AddBeam( Vector( pos.x, pos.y, z ), width, seg * 5, colour )
			-- end
		-- render.EndBeam()
	-- end
end )

local anim = {
	Name = "ChainWrap",
	States = {
		Start = {
			Enter = function( self, anim, data )
				MM_Animation_ChangeState( anim, data, "PierceWorld" )
			end,
		},
		PierceWorld = {
			StateTime = 0.1,
			Enter = function( self, anim, data )
				-- Store the chains
				table.insert( chains, { Data = data } )
				data.Chain = #chains
				chains[data.Chain].Ropes = {}

				-- Functionality
				local function pierce( pos )
					local effectdata = EffectData()
						effectdata:SetOrigin( pos )
					util.Effect( particle_pierce, effectdata )

					table.insert( chains[data.Chain].Ropes, { pos, pos } )
					-- Find closest point to begin on circle
					local points = MM_GetCirclePoints( data.Entity:GetPos().x, data.Entity:GetPos().y, radius, max, 0 )
					local target = pos
					local mindist = 100000
					local startpoint = 0
					for k, point in pairs( points ) do
						local pointpos = Vector( point.x, point.y, pos.z )
						local dist = pos:Distance( pointpos )
						if ( dist < mindist ) then
							target = pointpos
							mindist = dist
							startpoint = k
						end
					end
					chains[data.Chain].Ropes[#chains[data.Chain].Ropes].Target = Vector( target.x, target.y, data.Entity:GetPos().z + 5 + math.random( 1, 20 ) )
					chains[data.Chain].Ropes[#chains[data.Chain].Ropes].TimeMult = math.random( 0.5, 1 )
					chains[data.Chain].Ropes[#chains[data.Chain].Ropes].StartPoint = startpoint
				end

				-- Some random pierce points
				local range = 130
				pierce( data.Entity:GetPos() + Vector( math.random( -range, range ), math.random( -range, range ), 0 ) )
				pierce( data.Entity:GetPos() + Vector( math.random( -range, range ), math.random( -range, range ), 0 ) )
				pierce( data.Entity:GetPos() + Vector( math.random( -range, range ), math.random( -range, range ), 0 ) )
			end,
			Think = function( self, anim, data )
				-- Onto object nearest sphericlocation
				for k, rope in pairs( chains[data.Chain].Ropes ) do
					rope[#rope] = LerpVector( math.min( 1, ( data.StateTime / ( self.StateTime * rope.TimeMult ) ) ), rope[1], rope.Target )
				end

				-- Next state
				if ( data.StateTime >= self.StateTime ) then
					MM_Animation_ChangeState( anim, data, "WrapObject" )
				end
			end,
			Exit = function( self, anim, data )
			end,
		},
		WrapObject = {
			StateTime = 0.7,
			Enter = function( self, anim, data )
				
			end,
			Think = function( self, anim, data )
				-- Move each rope end point upward on squished sphere
				-- While decreasing radius to have a tightening effect
				local radius = radius / ( ( data.StateTime / self.StateTime ) + 1 )
				for k, rope in pairs( chains[data.Chain].Ropes ) do
					local points = MM_GetCirclePoints( data.Entity:GetPos().x, data.Entity:GetPos().y, radius, max, 0 )
					local pos = points[( rope.StartPoint % max ) + 1]
					local z = rope[#rope].z + 0.5
					table.insert( rope, Vector( pos.x, pos.y, z ) )
					rope.StartPoint = rope.StartPoint + 1
				end

				if ( data.StateTime >= self.StateTime ) then
					MM_Animation_ChangeState( anim, data, "AnchorShoot" )
				end
			end,
			Exit = function( self, anim, data )
				
			end,
		},
		AnchorShoot = {
			Enter = function( self, anim, data )
				-- Fire off top of object and gravity fall into ground to anchor
			end,
			Think = function( self, anim, data )
				-- Particles on ground impact
			end,
			Exit = function( self, anim, data )
				
			end,
		},
	},
	Remove = function( self, anim, data )
		print( "call remove" )
		PrintTable( data )
		table.remove( chains, data.Chain )
	end,
}
MM_AddAnimation( anim )
