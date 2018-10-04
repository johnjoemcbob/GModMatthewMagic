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
local MM_RUNE_SHAPE_APPROX	= 0.1
local MM_RUNE_ACCEPTANCE	= 90

-- <<<<<<<<<<<<<<<<
-- Variables
-- <<<<<<<<<<<<<<<<
local MM_Rune_Points = {}
local MM_Rune_Drawing = false

-- <<<<<<<<<<<<<<<<
-- Net
-- <<<<<<<<<<<<<<<<
-- net.Receive( "MM_Send_Map_Size", function()
	-- local w = net.ReadInt( MM_Net_Map_Bits_Size )
	-- local h = net.ReadInt( MM_Net_Map_Bits_Size )
	-- MM_Map_Width = w
	-- MM_Map_Height = h
-- end )

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
	MM_Rune_Normalize()
	MM_Rune_Match()
	-- MM_Rune_Points = {}
	MM_Rune_Drawing = false
end

-- Remove extra in-between points on approximately straight line
function MM_Rune_Simplify()
	local lastdir = Vector( 0, 0 )
	local lastpoint = nil
	local todelete = {}
	for k, newpoint in pairs( MM_Rune_Points ) do
		if ( !lastpoint ) then
			lastpoint = newpoint
		else
			local newdir = ( newpoint - lastpoint ):GetNormalized()
			-- print( newdir )
			-- print( lastdir )
			-- print( newdir:Distance( lastdir ) )
			if ( k == 2 or ( newdir:Distance( lastdir ) <= MM_RUNE_LINE_APPROX and k != #MM_Rune_Points ) ) then
				-- print( k )
				table.insert( todelete, k )
			else
				-- table.remove( todelete, #todelete )
			end
			lastdir = newdir
			lastpoint = newpoint
		end
	end

	for k, point in pairs( todelete ) do
		MM_Rune_Points[point] = nil
	end
end

function MM_Rune_Normalize()
	-- With middle as center
	-- So to normalise height, divide all by max y?
	-- local width = 0
	-- local height = 0
		-- for k, a in pairs( MM_Rune_Points ) do
			-- for _, b in pairs( MM_Rune_Points ) do
				-- local newwidth = math.abs( a.x - b.x )
				-- width = math.max( width, newwidth )
				-- local newheight = math.abs( a.y - b.y )
				-- height = math.max( height, newheight )
			-- end
		-- end
		-- print( width .. " " .. height )
	-- for k, point in pairs( MM_Rune_Points ) do
		-- print( point )
		-- point.x = point.x / width
		-- point.y = point.y / height
		-- print( point )
	-- end
	local lastpoint = nil
	local dirs = {}
	for k, point in pairs( MM_Rune_Points ) do
		if ( lastpoint ) then
			table.insert( dirs, ( lastpoint - point ):GetNormalized() )
			print( dirs[#dirs] )
		end
		lastpoint = point
	end
	MM_Rune_Points = dirs
end

function MM_Rune_Match()
	-- Compare against all loaded runes
	local matches = {}
	for k, rune in pairs( MM_Runes ) do
		local match = 0
			-- Score with number of matches against total required
			for _, point in pairs( rune.Shape ) do
				for n, newpoint in pairs( MM_Rune_Points ) do
					print( point:Distance( newpoint ) )
					if ( point:Distance( newpoint ) <= MM_RUNE_SHAPE_APPROX ) then
						match = match + 100
						break
					end
				end
				-- TODO: Take into account offset from pure
			end
			match = match / #rune.Shape
		matches[k] = match
	end

	-- Choose closest if over acceptance threshold
	local max = 0
	local ind = -1
	for k, match in pairs( matches ) do
		print( "Tried: " .. k .. " (with " .. max .. " score)" )
		if ( match >= MM_RUNE_ACCEPTANCE and max > match ) then
			max = match
			ind = k
		end
	end
	if ( ind != -1 ) then
		print( "Recognised rune shape: " .. ind .. " (with " .. max .. " score)" )
	end
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
