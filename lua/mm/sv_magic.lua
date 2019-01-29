-- Matthew Cormack
-- 22/04/18

-- <<<<<<<<<<<<<<<<
-- Variables
-- <<<<<<<<<<<<<<<<
local MM_Map_Table = {}
local MM_Map_Min, MM_Map_Max

local MM_Net_ExpectedResponses = {}

-- <<<<<<<<<<<<<<<<
-- Net
-- <<<<<<<<<<<<<<<<
-- From SERVER
util.AddNetworkString( "MM_Send_Map_Size" )
function MM_Send_Map_Size()
	print( "Sending Map Size: " .. #MM_Map_Table .. " " .. #MM_Map_Table[0] )
	net.Start( "MM_Send_Map_Size" )
		net.WriteInt( #MM_Map_Table   , MM_Net_Map_Bits_Size )
		net.WriteInt( #MM_Map_Table[0], MM_Net_Map_Bits_Size )
	net.Broadcast()
end
-- From SERVER
util.AddNetworkString( "MM_Send_Map_Min" )
function MM_Net_Send_Map_Min()
	print( "Sending Map Min " .. tostring( MM_Map_Min ) )
	net.Start( "MM_Send_Map_Min" )
		net.WriteVector( MM_Map_Min )
		net.WriteVector( MM_Map_Max )
	net.Broadcast()
end
-- From SERVER
util.AddNetworkString( "MM_Send_Map_Initial" )
function MM_Net_Send_Map_Initial()
	print( "Sending Map Initial" )
	net.Start( "MM_Send_Map_Initial" )
		net.WriteInt( #MM_Map_Table   , MM_Net_Map_Bits_Size )
		net.WriteInt( #MM_Map_Table[0], MM_Net_Map_Bits_Size )
	net.Broadcast()
end
-- From SERVER
util.AddNetworkString( "MM_Send_Map" )
function MM_Net_Send_Map( offset )
	print( "Sending Map with offset: " .. offset )
	local data = MM_Map_Table
	if ( offset != 0 ) then
		data = table.shallowcopypart( MM_Map_Table, offset, offset + 6 )
	end
	net.Start( "MM_Send_Map" )
		net.WriteInt( offset, MM_Net_Map_Bits_Cell )
		net.WriteTable( data )
	net.Broadcast()
end
-- From SERVER
util.AddNetworkString( "MM_Send_Map_Cell" )
function MM_Net_Send_Map_Cell( x, y )
	-- print( "Sending Map Cell " .. x .. " " .. y )

	net.Start( "MM_Send_Map_Cell" )
		net.WriteInt( x, MM_Net_Map_Bits_Cell )
		net.WriteInt( y, MM_Net_Map_Bits_Cell )
		local bool = MM_Map_Table[x][y] != 0
		net.WriteBool( bool ) -- Convert to boolean
	net.Broadcast()
end
-- From SERVER
util.AddNetworkString( "MM_Invoke" )
function MM_Net_Invoke( ply, comp )
	net.Start( "MM_Invoke" )
		net.WriteString( comp )
	net.Send( ply )
end
-- From CLIENT
util.AddNetworkString( "MM_Receive_Map_Request" )
net.Receive( "MM_Receive_Map_Request", function( len, ply )
	local widthreceived = net.ReadInt( MM_Net_Map_Bits_Cell )
	print( "Received Map Data Request.. " .. widthreceived )
	MM_Net_Send_Map( widthreceived )
end )
-- From CLIENT
util.AddNetworkString( "MM_Receive_Spell_Craft" )
net.Receive( "MM_Receive_Spell_Craft", function( len, ply )
	local components = net.ReadTable()

	local name = ply:Nick() .. "_" .. CurTime()
	print( "Creating spell! " .. name )

	local spell = table.shallowcopy( MM_Components[string.upper( components[1] )] )
	spell.Name = name
	table.remove( components, 1 )
	PrintTable( components )
	for k, comp in pairs( components ) do
		spell.SubComponents[comp.Name].Value = comp.Value
	end

	MM_AddComponent( spell )
	MM_InvokeComponent( ply, name )
	-- TODO: Need to send to clients again?
end )

-- <<<<<<<<<<<<<<<<
-- Functions
-- <<<<<<<<<<<<<<<<
function MM_SetModifier( ply, key, val )
	if ( !ply.MM_Modifiers ) then
		ply.MM_Modifiers = {}
	end

	ply.MM_Modifiers[key] = val
end

function MM_GetModifier( ply, key )
	if ( type( ply.MM_Modifiers[key] ) == "function" ) then
		return ply.MM_Modifiers[key]()
	end
	return ply.MM_Modifiers[key]
end

function MM_Parse( ply, text )
	local wops = string.Split( string.upper( text ), " " )
	-- PrintTable( runes )

	-- Check for invalid runes
	for k, wop in pairs( wops ) do
		if ( !MM_WOPs[wop] ) then
			print( wop .. " word of power not found! Spell Invalid!" )
			return
		end
	end

	-- Invoke each rune
	for k, wop in pairs( wops ) do
		MM_WOPs[wop]:Invoke( ply )
	end
end

function MM_Map_Initialise()
	-- Get the minimum and maximum of the map using the nav mesh
	local min = nil
	local max = nil
	for area = 1, navmesh.GetNavAreaCount() - 1 do
		local navarea = navmesh.GetNavAreaByID( area )
		for corner = 0, 3 do
			local pos = navarea:GetCorner( corner )
				if ( !pos ) then break end

			-- Initial minimum
			if ( min == nil ) then
				min = Vector( pos )
			end
			-- Initial maximum
			if ( max == nil ) then
				max = Vector( pos )
			end
			-- Minimum
			min.x = math.min( min.x, pos.x )
			min.y = math.min( min.y, pos.y )
			min.z = math.min( min.z, pos.z )
			-- Maximum
			max.x = math.max( max.x, pos.x )
			max.y = math.max( max.y, pos.y )
			max.z = math.max( max.z, pos.z )
		end
	end
	if ( !min or !max ) then return end

	-- Clamp to horizontal 2d plan
	min.z = 0
	max.z = 0

	-- Debug output
		print( "0-0" )
		print( min )
		print( max )
		print( "0-0" )

	-- Generate the map texture
	local texture = {}
		-- Texture size from map units divided by units per pixel
		local width = math.abs( min.x - max.x )
		local height = math.abs( min.y - max.y )
			width = width / MM_Map_Detail
			height = height / MM_Map_Detail
		for x = 0, width do
			texture[x] = {}
			for y = 0, height do
				texture[x][y] = 1
			end
		end
	MM_Map_Table = texture

	-- Store
	MM_Map_Min = min
	MM_Map_Max = max

	-- Send to any connected players
	MM_Send_Map_Size()
	MM_Net_Send_Map_Min()
	MM_Net_Send_Map_Initial()
	-- MM_Net_Send_Map( 0 )
end

-- <<<<<<<<<<<<<<<<
-- Hooks
-- <<<<<<<<<<<<<<<<

-- Initialise player variables
local init = false
hook.Add( "PlayerInitialSpawn", "MM_PlayerInitialSpawn", function( ply )
	if ( !init ) then
		MM_Map_Initialise()
		init = true
	end

	ply:SetNWInt( "MM_Reach", MM_Reach_Default )
	ply:SetNWInt( "MM_Magic", MM_Magic_Default )
end )

-- Parse text when talking
hook.Add( "PlayerSay", "MM_PlayerSay", function( ply, text, team )
	MM_Parse( ply, text )
end )

-- Get player inputs
hook.Add( "SetupMove", "MM_SetupMove", function( ply, mv, cmd )
	if ( bit.band( cmd:GetButtons(), IN_ATTACK2 ) == IN_ATTACK2 ) then
		-- MM_AddVoid(
		local cell = MM_Map_WorldToLocal( ply:GetPos(), MM_Map_Min, MM_Map_Table )
		local w = math.ceil( ply:GetNWInt( "MM_Reach" ) / MM_Map_Detail )
		-- print( w )
		for offx = -w, w do
			for offy = -w, w do
				local x = cell.x + offx
				local y = cell.y + offy
				if ( x > 0 and x < #MM_Map_Table and y > 0 and y < #MM_Map_Table[0] ) then
					-- print( MM_Map_Table[x][y] )
					if ( MM_Map_Table[x][y] == 1 ) then
						local pos = MM_Map_LocalToWorld( Vector( x, y, 0 ), MM_Map_Min )
							pos.z = ply:GetPos().z
						local dist = ply:GetPos():Distance( pos )
-- debugoverlay.Cross( pos, 5, 10, Color( 255, 255, 255, 255 ), true )
						if ( dist <= ply:GetNWInt( "MM_Reach" ) ) then
							-- print( x .. " " .. y )
							-- print( "come yes" )
							MM_Map_Table[x][y] = 0
							MM_Net_Send_Map_Cell( x, y )
						end
					end
				end
			end
		end
	end
end )

-- Recommend bind to MWHEELUP
concommand.Add( "+mm_reach_up", function( ply, cmd, args )
	local new = ply:GetNWInt( "MM_Reach" ) + FrameTime() * MM_Reach_ChangeSpeed
		new = math.Clamp( new, MM_Reach_Min, MM_Reach_Max )
	ply:SetNWInt( "MM_Reach", new )
end )

-- Recommend bind to MWHEELDOWN
concommand.Add( "+mm_reach_down", function( ply, cmd, args )
	local new = ply:GetNWInt( "MM_Reach" ) - FrameTime() * MM_Reach_ChangeSpeed
		new = math.Clamp( new, MM_Reach_Min, MM_Reach_Max )
	ply:SetNWInt( "MM_Reach", new )
end )
