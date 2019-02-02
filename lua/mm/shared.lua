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

-- TODO: Fix the loading of these files on clients!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

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
	AddCSLuaFile( "mm/runes/" .. file )
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
	AddCSLuaFile( "mm/wops/" .. file )
	include( "mm/wops/" .. file )
end

-- <<<<<<<<<<<<<<<<
-- Load animations
-- <<<<<<<<<<<<<<<<
MM_Animations = {}

function MM_AddAnimation( tab )
	MM_Animations[tab.Name] = tab
end

-- TODO don't duplicate this... make better...
local files, directories = file.Find( "lua/mm/anims/*", "GAME" )
for k, file in pairs( files ) do
	print( "mm/anims/" .. file )
	AddCSLuaFile( "mm/anims/" .. file )
	include( "mm/anims/" .. file )
end
if ( SERVER ) then
	local files = files
	util.AddNetworkString( "MM_Files_Anims" )
	function MM_Net_SendAnimFiles( ply, files )
		net.Start( "MM_Files_Anims" )
			net.WriteTable( files )
		net.Send( ply )
		print( "Send file list to client" )
	end
	hook.Add( "PlayerInitialSpawn", "MM_PlayerInitialSpawn_Animations", function( ply )
		MM_Net_SendAnimFiles( ply, files )
	end )
end
if ( CLIENT ) then
	net.Receive( "MM_Files_Anims", function()
		local files = net.ReadTable()
		print( "Receive file list from server" )
		PrintTable( files )
		for k, file in pairs( files ) do
			print( "Late mm/anims/" .. file )
			AddCSLuaFile( "mm/anims/" .. file )
			include( "mm/anims/" .. file )
		end
	end )
end

if ( SERVER ) then
	util.AddNetworkString( "MM_Animation_Apply" )
	util.AddNetworkString( "MM_Animation_Stop" )
end
local anims = {}
function MM_ApplyAnimation( ent, name )
	if ( SERVER ) then
		net.Start( "MM_Animation_Apply" )
			net.WriteEntity( ent )
			net.WriteString( name )
		net.Broadcast()
	end
	if ( CLIENT ) then
		table.insert( anims, {
			Animation = MM_Animations[name],
			Data = { Entity = ent }
		} )
		-- Start
		MM_Animation_ChangeState( anims[#anims].Animation, anims[#anims].Data, "Start" )
	end
end
function MM_StopAnimation( ent, name )
	if ( SERVER ) then
		net.Start( "MM_Animation_Stop" )
			net.WriteEntity( ent )
			net.WriteString( name )
		net.Broadcast()
	end
	if ( CLIENT ) then
		local removeanim = nil
			for k, anim in pairs( anims ) do
				if ( anim.Animation == MM_Animations[name] and anim.Data.Entity == ent ) then
					anim.Animation:Remove( anim.Animation, anim.Data )
					removeanim = k
					break
				end
			end
		if ( removeanim ) then
			table.remove( anims, removeanim )
		end
	end
end
if ( CLIENT ) then
	net.Receive( "MM_Animation_Apply", function()
		local ent = net.ReadEntity()
		local name = net.ReadString()

		MM_ApplyAnimation( ent, name )
	end )
	net.Receive( "MM_Animation_Stop", function()
		local ent = net.ReadEntity()
		local name = net.ReadString()

		MM_StopAnimation( ent, name )
	end )

	function MM_Animation_ChangeState( anim, data, state )
		print( anim.Name .. " entered state " .. state )
		if ( data.State and anim.States[data.State].Exit ) then
			anim.States[data.State]:Exit( anim, data )
		end
		data.State = state
		data.StateTime = 0
		if ( anim.States[data.State].Enter ) then
			anim.States[data.State]:Enter( anim, data )
		end
	end
	function MM_Animation_Remove( anim, data )
		for k, v in pairs( anims ) do
			if ( anims.Data == data ) then
				print( "Remove anim success" )
				table.remove( anims, k )
				return
			end
		end
	end
	hook.Add( "Think", "MM_Think_Animation", function()
		for k, anim in pairs( anims ) do
			anim.Data.StateTime = anim.Data.StateTime + FrameTime()
			if ( anim.Animation.States[anim.Data.State].Think ) then
				anim.Animation.States[anim.Data.State]:Think( anim.Animation, anim.Data )
			end
		end
	end )
end

-- <<<<<<<<<<<<<<<<
-- Load components
-- <<<<<<<<<<<<<<<<
MM_Components = {}

function MM_AddComponent( tab )
	print( "Add component.. " .. tostring( tab.Name ) )
	MM_Components[string.upper( tab.Name )] = tab
end

function MM_InvokeComponent( ply, comp, args )
	-- Separate any extra arguments from the component name
	if ( type(comp) == "table" ) then
		table.insert( args, comp[2] )
		comp = comp[1]
	end

	return MM_Components[string.upper( comp )]:Invoke( ply, args )
end

-- TODO: Cache on server and send list to each client? idk...
print( "MM - Load components" )
local files, directories = file.Find( "lua/mm/components/*", "GAME" )
for k, file in pairs( files ) do
	print( "mm/components/" .. file )
	AddCSLuaFile( "mm/components/" .. file )
	include( "mm/components/" .. file )
end
if ( SERVER ) then
	local files = files
	util.AddNetworkString( "MM_Files" )
	function MM_Net_SendFiles( ply, files )
		net.Start( "MM_Files" )
			net.WriteTable( files )
		net.Send( ply )
		print( "Send file list to client" )
	end
	hook.Add( "PlayerInitialSpawn", "MM_PlayerInitialSpawn_Components", function( ply )
		MM_Net_SendFiles( ply, files )
	end )
end
if ( CLIENT ) then
	net.Receive( "MM_Files", function()
		local files = net.ReadTable()
		print( "Receive file list from server" )
		PrintTable( files )
		for k, file in pairs( files ) do
			print( "Late mm/components/" .. file )
			AddCSLuaFile( "mm/components/" .. file )
			include( "mm/components/" .. file )
		end
	end )
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
