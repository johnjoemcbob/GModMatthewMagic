-- Matthew Cormack
-- 22/04/18

-- <<<<<<<<<<<<<<<<
-- Static Variables
-- <<<<<<<<<<<<<<<<
MM_Magic_Default = 0
MM_Magic_PerUnit = 1

-- How many hammer units per each pixel on the map texture
-- (Warning: More detailed maps will require multiple messages to be sent to clients
--  due to the net library byte limit)
MM_Map_Detail = 100
MM_Map_FakeDetail = 1

MM_Reach_Default = 100
MM_Reach_ChangeSpeed = 5000
MM_Reach_Min = 70
MM_Reach_Max = 1500 -- This should be player specific

MM_Net_Map_Bits_Cell = 32
MM_Net_Map_Bits_Size = 32

-- <<<<<<<<<<<<<<<<
-- Load runes
-- <<<<<<<<<<<<<<<<
MM_Runes = {}

function MM_AddRune( tab )
	MM_Runes[tab.Name] = tab
end

local files, directories = file.Find( "lua/mm/runes/*", "GAME" )
for k, file in pairs( files ) do
	print( "mm/runes/" .. file )
	if ( SERVER ) then
		AddCSLuaFile( "mm/runes/" .. file )
	end
	include( "mm/runes/" .. file )
end

-- <<<<<<<<<<<<<<<<
-- Load words of power
-- <<<<<<<<<<<<<<<<
MM_WOPs = {}

function MM_AddWOP( tab )
	MM_WOPs[tab.Name] = tab
end

local files, directories = file.Find( "lua/mm/wops/*", "GAME" )
for k, file in pairs( files ) do
	print( "mm/wops/" .. file )
	if ( SERVER ) then
		AddCSLuaFile( "mm/wops/" .. file )
	end
	include( "mm/wops/" .. file )
end

-- <<<<<<<<<<<<<<<<
-- Functions
-- <<<<<<<<<<<<<<<<
-- Convert a world position to a map cell
function MM_Map_WorldToLocal( pos, min, tab )
	local cell = Vector()
		local dist = pos - min
		cell = dist / MM_Map_Detail
		-- Round to int
		cell.x = math.Round( cell.x )
		cell.y = math.Round( cell.y )
		-- Clamp to map bounds
		cell.x = math.Clamp( cell.x, 0, #tab - 1 )
		cell.y = math.Clamp( cell.y, 0, #tab[0] - 1 )
	return cell
end
-- Convert a map cell to a world position
function MM_Map_LocalToWorld( cell, min )
	return min + cell * MM_Map_Detail
end

-- <<<<<<<<<<<<<<<<
-- Utils
-- <<<<<<<<<<<<<<<<
-- Make a shallow copy of a table (from http://lua-users.org/wiki/CopyTable)
-- Extended for recursive tables
function table.shallowcopy( orig )
    local orig_type = type( orig )
    local copy
    if ( orig_type == "table" ) then
        copy = {}
        for orig_key, orig_value in pairs( orig ) do
			if ( type( orig_value ) == "table" ) then
				copy[orig_key] = table.shallowcopy( orig_value )
			else
				copy[orig_key] = orig_value
			end
        end
	-- Number, string, boolean, etc
    else
        copy = orig
    end
    return copy
end

-- Make a shallow copy of a table (from http://lua-users.org/wiki/CopyTable)
-- Extended for recursive tables
function table.shallowcopypart( orig, start, finish )
    local orig_type = type( orig )
    local copy
    if ( orig_type == "table" ) then
        copy = {}
        for orig_key, orig_value in pairs( orig ) do
			if ( orig_key > finish ) then break end
			if ( orig_key >= start ) then
				if ( type( orig_value ) == "table" ) then
					copy[orig_key] = table.shallowcopy( orig_value )
				else
					copy[orig_key] = orig_value
				end
			end
        end
	-- Number, string, boolean, etc
    else
        copy = orig
    end
    return copy
end
