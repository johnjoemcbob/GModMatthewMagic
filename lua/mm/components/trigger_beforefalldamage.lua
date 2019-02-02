
local height	= 0.3
local speed		= -500

local comp = {
	Name = "TRIGGER_BEFORE_FALLDAMAGE",
	Type = "TRIGGER",
	ReturnType = "None",
	Cost = 10,
	Invoke = function( self, ply, args )
		local hookid = "MM_Think_" .. tostring( self ) .. "_" .. tostring( ply ) .. "_" .. tostring( CurTime() )
		local activated = false
		hook.Add( "Think", hookid, function()
			if ( !ply:IsOnGround() and ply:GetVelocity().z < speed ) then
				if ( !activated ) then
					local tr = util.TraceLine( {
						start = ply:GetPos(),
						endpos = ply:GetPos() - Vector( 0, 0, 1 ) * math.abs( height * speed ),
						collisiongroup = COLLISION_GROUP_WORLD
					} )
					if ( tr.HitWorld ) then
						print( ply:GetVelocity() )
						timer.Simple( 0.01, function() args[1]() end )
						-- hook.Remove( "Think", hookid )
						activated = true
					end
				end
			elseif ( ply:IsOnGround() ) then
				activated = false
			end
		end )
	end,
}
MM_AddComponent( comp )
