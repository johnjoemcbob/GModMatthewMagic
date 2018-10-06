-- Matthew Cormack
-- 03/10/18

-- <<<<<<<<<<<<<<<<
-- Externals
-- <<<<<<<<<<<<<<<<
-- local MM_Material_Reach = Material( "circle_reach.png", "smooth" )

-- <<<<<<<<<<<<<<<<
-- Constants
-- <<<<<<<<<<<<<<<<
local MM_RUNE_POINT_NEXT	= 24
local MM_RUNE_LINE_APPROX	= 0.5
local MM_RUNE_SHAPE_APPROX	= 0.3
local MM_RUNE_DIR_MIN		= 0.1
local MM_RUNE_ACCEPTANCE	= 60

-- <<<<<<<<<<<<<<<<
-- Variables
-- <<<<<<<<<<<<<<<<
local MM_Rune_Points = {}
local MM_Rune_Compass = {}
local MM_Rune_Drawing = false

-- <<<<<<<<<<<<<<<<
-- Net
-- <<<<<<<<<<<<<<<<
function MM_Net_Rune_Recognised( rune )
	net.Start( "MM_Rune_Recognised" )
		net.WriteString( rune )
	net.SendToServer()
end

-- <<<<<<<<<<<<<<<<
-- Functions
-- <<<<<<<<<<<<<<<<
-- Called on mouse down
function MM_Rune_Start()
	MM_Rune_Points = {}
	MM_Rune_Drawing = true
end

-- Called on mouse up
function MM_Rune_Finish()
	MM_Rune_Simplify()
	local rune = MM_Rune_Match()

	if ( rune ) then
		MM_Net_Rune_Recognised( rune )
	end
	
	MM_Rune_Points = {}
	MM_Rune_Drawing = false
end

-- Convert drawn line data into directional data
function MM_Rune_Simplify()
	MM_Rune_Compass = {}

	-- Convert each point into a 16 point compass direction
	-- Track distance from point to point?
	local lastpoint = newpoint
	for k, newpoint in pairs( MM_Rune_Points ) do
		if ( !lastpoint ) then
			lastpoint = newpoint
		else
			local newdir = ( lastpoint - newpoint ):GetNormalized()
			table.insert( MM_Rune_Compass, {
				Dir = MM_Rune_DirToCompass( newdir ),
				Len = lastpoint:Distance( newpoint ),
			} )
			lastpoint = newpoint
		end
	end

	-- Simplify to 8 point compass directions by prioritising nearest to last
	local last = nil
	for k, compass in pairs( MM_Rune_Compass ) do
		-- Only simplify 16 inbetween details to get to 8 point again
		if ( string.len( compass.Dir ) == 3 ) then
			if ( last ) then
				-- Take the last value
				MM_Rune_Compass[k].Dir = last.Dir
			else
				-- Just remove the first letter
				MM_Rune_Compass[k].Dir = string.Right( compass.Dir, 2 )
			end
		end
		last = MM_Rune_Compass[k]
	end

	-- Remove duplicates
	local toremove = {}
	local last = nil
	for k, compass in pairs( MM_Rune_Compass ) do
		if ( last and last.Dir == compass.Dir ) then
			last.Len = last.Len + compass.Len
			table.insert( toremove, k )
		else
			last = compass
		end
	end
	for k, compass in pairs( toremove ) do
		-- table.remove( MM_Rune_Compass, compass )
		MM_Rune_Compass[compass] = nil
	end

	-- Normalise distances
	local max = 0
		for k, compass in pairs( MM_Rune_Compass ) do
			max = math.max( max, compass.Len )
		end
	for k, compass in pairs( MM_Rune_Compass ) do
		compass.Len = compass.Len / max
	end

	-- Debug
	PrintTable( MM_Rune_Compass )
end

function MM_Rune_Match()
	-- Compare against all loaded runes
	local matches = {}
	for k, rune in pairs( MM_Runes ) do
		local match = 0
			-- Score with number of matches against total required
			local used = {}
			for _, compass in pairs( rune.Shape ) do
				for n, newcompass in pairs( MM_Rune_Compass ) do
					local min = compass[2]
					local max = compass[2]
						-- Optionally min/max range can be supplied
						if ( compass[3] ) then
							max = compass[3]
						end
						-- Add approximation
						min = min - MM_RUNE_SHAPE_APPROX
						max = max + MM_RUNE_SHAPE_APPROX
					local dist = newcompass.Len
					if ( compass[1] == newcompass.Dir and dist >= min and dist <= max ) then
						match = match + 100
						used[n] = true
						break
					end
				end
				-- TODO: Take into account offset from pure
			end
			-- Remove score for each extra direction included
			for n, compass in pairs( MM_Rune_Compass ) do
				if ( !used[n] and compass.Len >= MM_RUNE_DIR_MIN ) then
					match = match - 100
				end
			end
			match = match / #rune.Shape
		matches[k] = match
	end

	-- Choose closest if over acceptance threshold
	local max = 0
	local ind = nil
	for k, match in pairs( matches ) do
		print( "Tried: " .. k .. " (with " .. match .. " score)" )
		if ( match >= MM_RUNE_ACCEPTANCE and max < match ) then
			max = match
			ind = k
		end
	end
	if ( ind != nil ) then
		print( "Recognised rune shape: " .. ind .. " (with " .. max .. " score)" )
	end

	return ind
end

-- Vector direction to 16 point compass direction
-- From: https://gamedev.stackexchange.com/questions/49290/whats-the-best-way-of-transforming-a-2d-vector-into-the-closest-8-way-compass-d
function MM_Rune_DirToCompass( dir )
	-- start direction from the lowest value, in this case it's west with -π
	local dirs = {
		"W",
		"WSW",
		"SW",
		"SSW",
		"S",
		"SSE",
		"SE",
		"ESE",
		"E",
		"ENE",
		"NE",
		"NNE",
		"N",
		"NNW",
		"NW",
		"WNW",
	}

	local increment = (2 * math.pi ) / #dirs
	local angle = math.atan2( dir.y, -dir.x )
	local testangle = -math.pi + increment / 2

	local index = 1
	while ( angle > testangle ) do
		index = index + 1
		if ( index > #dirs ) then
			return dirs[1] -- Roll over
		end
		testangle = testangle + increment
	end

	return dirs[index]
end

-- <<<<<<<<<<<<<<<<
-- Hooks
-- <<<<<<<<<<<<<<<<
-- Inputs for start/stop
hook.Add( "SetupMove", "MM_SetupMove_Rune", function( ply, mv, cmd )
	local mouse = bit.band( cmd:GetButtons(), IN_ATTACK ) == IN_ATTACK
	if ( mouse != MM_Rune_WasMouse ) then
		if ( mouse ) then
			if ( !MM_Rune_Drawing ) then
				MM_Rune_Start()
			end
		else
			if ( MM_Rune_Drawing ) then
				MM_Rune_Finish()
			end
		end
	end
	MM_Rune_WasMouse = mouse
end )

-- Main thinking
hook.Add( "Think", "MM_Think_Rune", function()
	if ( MM_Rune_Drawing ) then
		local lastpoint = Vector( 0, 0 )
			if ( #MM_Rune_Points != 0 ) then
				lastpoint = MM_Rune_Points[#MM_Rune_Points]
			end
		local newpoint = Vector( gui.MouseX(), gui.MouseY() )
		local dist = lastpoint:Distance( newpoint )
		if ( dist >= MM_RUNE_POINT_NEXT ) then
			table.insert( MM_Rune_Points, newpoint )
		end
	end
end )

-- Draw lines
hook.Remove( "HUDPaint", "MM_HUDPaint_Rune" ) -- For hotreload
hook.Add( "HUDPaint", "MM_HUDPaint_Rune", function()
	surface.SetDrawColor( 255, 255, 255, 255 )
	for k, point in pairs( MM_Rune_Points ) do
		surface.DrawRect( point.x, point.y, MM_RUNE_POINT_NEXT, MM_RUNE_POINT_NEXT )
	end
end )
