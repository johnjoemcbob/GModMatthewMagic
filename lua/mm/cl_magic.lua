-- Matthew Cormack
-- 22/04/18

-- <<<<<<<<<<<<<<<<
-- Externals
-- <<<<<<<<<<<<<<<<
local MM_Material_Reach = Material( "circle_reach.png", "smooth" )

-- <<<<<<<<<<<<<<<<
-- Variables
-- <<<<<<<<<<<<<<<<
local MM_Map_Table = {}
local MM_Map_RenderTarget = nil

local HOOK_ID = "MATTHEW_TEST"

-- <<<<<<<<<<<<<<<<
-- Projected Textures
-- <<<<<<<<<<<<<<<<
local MM_ProjectedTexture_Reach = ProjectedTexture()
	MM_ProjectedTexture_Reach:SetTexture( MM_Material_Reach:GetTexture( "$basetexture" ) )
	MM_ProjectedTexture_Reach:SetFOV( 90 )
	MM_ProjectedTexture_Reach:SetBrightness( 100 )
	MM_ProjectedTexture_Reach:SetEnableShadows( false )
MM_ProjectedTexture_Reach:Update()

local MM_ProjectedTexture_Map = ProjectedTexture()
	MM_ProjectedTexture_Map:SetFOV( 90 )
	MM_ProjectedTexture_Map:SetBrightness( 100 )
	MM_ProjectedTexture_Map:SetFarZ( 100000 )
	MM_ProjectedTexture_Map:SetEnableShadows( false )
MM_ProjectedTexture_Map:Update()

-- <<<<<<<<<<<<<<<<
-- Net
-- <<<<<<<<<<<<<<<<
net.Receive( "MM_Send_Map_Size", function()
	local w = net.ReadInt( MM_Net_Map_Bits_Size )
	local h = net.ReadInt( MM_Net_Map_Bits_Size )
	MM_Map_Width = w
	MM_Map_Height = h
	print( "Received Map Size: " .. w .. " " .. h )

	MM_Net_CheckForAllReceived()
end )
net.Receive( "MM_Send_Map_Min", function()
	local min = net.ReadVector()
	local max = net.ReadVector()
	MM_Map_Min = min
	MM_Map_Max = max
	print( "Received Map Min: " .. tostring( MM_Map_Min ) )
	print( "Received Map Max: " .. tostring( MM_Map_Max ) )
end )
net.Receive( "MM_Send_Map", function()
	local offset = net.ReadInt( MM_Net_Map_Bits_Cell )
	local tab = net.ReadTable()

	-- Reset data if first indices are received again
	if ( offset == 0 ) then
		MM_Map_Table = {}
	end

	-- Store indices with offset
	local index = 0
	for k, v in pairs( tab ) do
		MM_Map_Table[k] = v
		-- print( "Store map data at: " .. k )
		index = index + 1
	end
	print( "Received Map Data: " .. offset .. " " .. #tab )

	MM_Net_CheckForAllReceived()
end )
net.Receive( "MM_Send_Map_Initial", function()
	local w = net.ReadInt( MM_Net_Map_Bits_Size )
	local h = net.ReadInt( MM_Net_Map_Bits_Size )
	MM_Map_Width = w
	MM_Map_Height = h
	print( "Received Map Initial: " .. w .. " " .. h )

	MM_Map_Table = {}
	for x = 0, w do
		MM_Map_Table[x] = {}
		for y = 0, h do
			MM_Map_Table[x][y] = 1
		end
	end
end )
net.Receive( "MM_Send_Map_Cell", function()
	local x = net.ReadInt( MM_Net_Map_Bits_Cell )
	local y = net.ReadInt( MM_Net_Map_Bits_Cell )
	local val = net.ReadBool()
	MM_Map_Table[x][y] = ( val and 1 ) or 0 -- Bool back to number

	-- Flag for render
	if ( !istable( MM_Map_ShouldRender ) ) then
		MM_Map_ShouldRender = {}
	end
	table.insert( MM_Map_ShouldRender, { x, y } ) -- Flag to render next PostDrawOpaqueRenderables

	-- Spawn particles if drawing from that position
	if ( !val ) then
		local pos = MM_Map_LocalToWorld( Vector( x, y, 0 ), MM_Map_Min )
		-- print( pos )
			pos.z = LocalPlayer():GetPos().z
-- debugoverlay.Cross( pos, 5, 10, Color( 255, 255, 255, 255 ), true )
		local effectdata = EffectData()
			effectdata:SetOrigin( pos )
		util.Effect( "mm_draw", effectdata )

		-- Play sound effect
		-- local nearmiss = {
			-- "03",
			-- "04",
			-- "05",
			-- "06",
			-- "07",
			-- "08",
			-- "09",
			-- "10",
			-- "11",
			-- "12",
			-- "13",
			-- "14",
		-- }
		-- sound.Play( "weapons/fx/nearmiss/bulletltor" .. nearmiss[math.random( 1, #nearmiss )] .. ".wav", pos )
		sound.Play( "npc/barnacle/barnacle_gulp" .. math.random( 1, 2 ) .. ".wav", pos )
		-- sound.Play( "weapons/physcannon/physcannon_charge.wav", pos )
	end

	-- print( "Single cell data received! " .. x .. " " .. y .. " Rendering..." )
end )
function MM_Net_CheckForAllReceived()
	-- print( MM_Map_Width )
	-- print( #MM_Map_Table )
	if ( MM_Map_Width != nil and MM_Map_Table != nil ) then
		if ( MM_Map_Width - 1 <= #MM_Map_Table ) then
			print( "All data received! Rendering..." )
			MM_Map_ShouldRender = true -- Flag to render next PostDrawOpaqueRenderables
		else
			print( "Not all data received! Requesting from " .. #MM_Map_Table )
			net.Start( "MM_Receive_Map_Request" )
				net.WriteInt( #MM_Map_Table, MM_Net_Map_Bits_Cell )
			net.SendToServer()
		end
	end
end
net.Receive( "MM_Invoke", function()
	local comp = net.ReadString()
	print( "Received Invoke: " .. comp )

	hook.Run( "HUDItemPickedUp", comp )
end )

-- <<<<<<<<<<<<<<<<
-- Functions
-- <<<<<<<<<<<<<<<<
function MM_Map_Render()
	local w, h = #MM_Map_Table * MM_Map_FakeDetail, #MM_Map_Table[0] * MM_Map_FakeDetail

	-- Render the map to a render texture using 2D surface.DrawRect
	MM_Map_RenderTarget = GetRenderTarget( "MM_Map_RenderTarget", w, h, true )
	render.PushRenderTarget( MM_Map_RenderTarget )
		render.Clear( 0, 0, 0, 0, true )

		render.SetViewPort( 0, 0, w, h )
			cam.Start2D()
				for x = 0, #MM_Map_Table do
					for y = 0, #MM_Map_Table[0] do
						-- if ( math.random( 1, 2 ) == 1 ) then
						if ( MM_Map_Table[x][y] != 0 ) then
							surface.SetDrawColor( 50, 50, 50, 255 )
							surface.DrawRect( w - x * MM_Map_FakeDetail, y * MM_Map_FakeDetail, 1 * MM_Map_FakeDetail, 1 * MM_Map_FakeDetail )
						end
					end
				end
			cam.End2D()
		render.SetViewPort( 0, 0, ScrW(), ScrH() )
	render.PopRenderTarget()
end

function MM_Map_Render_Cell( x, y )
	local w, h = #MM_Map_Table * MM_Map_FakeDetail, #MM_Map_Table[0] * MM_Map_FakeDetail

	-- Render the map to a render texture using 2D surface.DrawRect
	MM_Map_RenderTarget = GetRenderTarget( "MM_Map_RenderTarget", w, h, true )
	render.PushRenderTarget( MM_Map_RenderTarget )
		render.SetViewPort( 0, 0, w, h )
			cam.Start2D()
				if ( MM_Map_Table[x][y] == 0 ) then
					surface.SetDrawColor( 0, 0, 0, 255 )
					-- surface.DrawRect( w - x - 1, y - 1, 2, 2 )
					-- draw.Circle( #MM_Map_Table - x, y, 0.5 * MM_Map_FakeDetail, 128, 0 )
					surface.DrawRect( #MM_Map_Table - x, y, 1 * MM_Map_FakeDetail, 1 * MM_Map_FakeDetail )
				end
			cam.End2D()
		render.SetViewPort( 0, 0, ScrW(), ScrH() )
	render.PopRenderTarget()
end

-- <<<<<<<<<<<<<<<<
-- Hooks
-- <<<<<<<<<<<<<<<<
hook.Add( "PreDrawHUD", "MM_Map_PreDrawHUD", function()
	if ( MM_Map_ShouldRender ) then
		if ( istable( MM_Map_ShouldRender ) ) then
			for k, v in pairs( MM_Map_ShouldRender ) do
				MM_Map_Render_Cell( v[1], v[2] )
			end
			MM_Map_ShouldRender = {}
		else
			MM_Map_Render()
		end
		MM_Map_ShouldRender = false
	end
end )

hook.Add( "HUDPaint", "HUDPaint_Map", function()
	-- Update the Reach projected texture
	local speed = 20
	local speed_rot = 10
	local txtr = MM_ProjectedTexture_Reach
		local target = LocalPlayer():GetPos() + Vector( 0, 0, 100 )
		txtr:SetPos( LerpVector( FrameTime() * speed, txtr:GetPos(), target ) )
		txtr:SetAngles( Angle( 90, CurTime() * speed_rot, 0 ) )

		local size = LocalPlayer():GetNWInt( "MM_Reach" )
		MM_ProjectedTexture_Reach:SetOrthographic( true, size, size, size, size )
	txtr:Update()

	-- Update the Map projected texture with the render texture
	if ( MM_Map_Table != {} and MM_Map_RenderTarget ) then
		local dist = MM_Map_Max - MM_Map_Min
		-- local w, h = #MM_Map_Table, #MM_Map_Table[0]
		local w, h = dist.x / 2, dist.y / 2
		local realw = w-- * MM_Map_Detail
		local realh = h-- * MM_Map_Detail
		local txtr = MM_ProjectedTexture_Map
			txtr:SetOrthographic( true,
				realw,
				realh,
				realw,
				realh
			)
			local offset = 0
			-- txtr:SetPos( Vector( MM_Map_Min.x / 200 * MM_Map_Detail, -MM_Map_Min.y / 200 * MM_Map_Detail, 1000 ) ) -- height correct (invert width in MM_Map_Render)
			-- txtr:SetPos( LocalPlayer():GetPos() + Vector( 0, 0, 1000 ) )
			local mid = MM_Map_Min + dist / 2
			txtr:SetPos( mid + Vector( 0, 0, 1000 ) )
			txtr:SetAngles( Angle( 90, -90, 0 ) )
			txtr:SetTexture( MM_Map_RenderTarget )
		txtr:Update()
	end
end )

-- NOTE: Original credits for this system go to Rick Dark (https://garrysmods.org/download/3952/weatheraddonzip)
hook.Add( "RenderScreenspaceEffects", "MM_RenderScreenspaceEffects", function()
	-- Create post process effect based on the calculated closeness to light sources
	local postprocess_colourmodify = {
		["$pp_colour_addr"] = 0,
		["$pp_colour_addg"] = 0,
		["$pp_colour_addb"] = 0,
		["$pp_colour_mulr"] = 0,
		["$pp_colour_mulg"] = 0,
		["$pp_colour_mulb"] = 0,
		["$pp_colour_brightness"] = -0.5,
		["$pp_colour_contrast"] = 1,
		["$pp_colour_colour"] = 1
	}
	//DrawColorModify( postprocess_colourmodify ) -- uncomment for daynight
end )

function draw.Circle( x, y, radius, seg, rotate )
	local cir = PRK_GetCirclePoints( x, y, radius, seg, rotate )
	surface.DrawPoly( cir )
end

-- From: http://wiki.garrysmod.com/page/surface/DrawPoly
function PRK_GetCirclePoints( x, y, radius, seg, rotate )
	local cir = {}
		-- table.insert( cir, { x = x, y = y, u = 0.5, v = 0.5 } )
		for i = 0, seg do
			local a = math.rad( ( ( i / seg ) * -360 ) + rotate )
			table.insert( cir, { x = x + math.sin( a ) * radius, y = y + math.cos( a ) * radius, u = math.sin( a ) / 2 + 0.5, v = math.cos( a ) / 2 + 0.5 } )
		end

		-- local a = math.rad( 0 ) -- This is need for non absolute segment counts
		-- table.insert( cir, { x = x + math.sin( a ) * radius, y = y + math.cos( a ) * radius, u = math.sin( a ) / 2 + 0.5, v = math.cos( a ) / 2 + 0.5 } )
	return cir
end

-- The following were shader/post processing tests for ways to visualise the void zones

--print( render.SupportsPixelShaders_2_0() )
--print( render.GetFullScreenDepthTexture() )
--local HOOK_ID = "MATTHEW_TEST"
--hook.Remove( "PreRender", HOOK_ID )
--hook.Add( "PreRender", HOOK_ID, function()
--end )
--hook.Remove( "PostDrawOpaqueRenderables", HOOK_ID )
--hook.Add( "PostDrawOpaqueRenderables", HOOK_ID, function()
--	-- cam.Start3D()
--		-- render.SetStencilEnable( true )
--			-- render.SuppressEngineLighting(true)
--			-- cam.IgnoreZ( true )
--
--				-- render.SetStencilWriteMask( 1 )
--				-- render.SetStencilTestMask( 1 )
--				-- render.SetStencilReferenceValue( 1 )
--
--				-- render.SetStencilCompareFunction( STENCIL_ALWAYS )
--				-- render.SetStencilPassOperation( STENCIL_DECRSAT )
--				-- render.SetStencilFailOperation( STENCIL_DECRSAT )
--				-- render.SetStencilZFailOperation( STENCIL_KEEP )
--
--				
--					-- for k, v in pairs( ents.FindByClass( "prop_physics" ) ) do
--
--						-- if ( !IsValid( v ) ) then continue end
--
--						-- RenderEnt = v
--
--						-- v:DrawModel()
--
--					-- end
--
--					-- RenderEnt = NULL
--
--				-- render.SetStencilCompareFunction( STENCIL_EQUAL )
--				-- render.SetStencilPassOperation( STENCIL_KEEP )
--				render.SetStencilFailOperation( STENCIL_KEEP )
--				render.SetStencilZFailOperation( STENCIL_KEEP )
--
--					-- cam.Start2D()
--						-- surface.SetDrawColor( Color( 0, 255, 0, 255 ) )
--						-- surface.DrawRect( 0, 0, ScrW(), ScrH() )
--					-- cam.End2D()
--
--			-- cam.IgnoreZ( false )
--			-- render.SuppressEngineLighting(false)
--		-- render.SetStencilEnable( false )
--	-- cam.End3D()
--end )
--hook.Remove( "HUDPaint", HOOK_ID )
--local ourMat = Material( "pp/downsample" ) -- Calling Material() every frame is quite expensive
--PrintTable( ourMat:GetKeyValues() )
--hook.Add( "HUDPaint", HOOK_ID, function()
--	render.UpdateFullScreenDepthTexture()
--	ourMat:SetTexture( "$fbtexture", render.GetFullScreenDepthTexture() )
--
--	-- pp/sharpen
--	-- ourMat:SetFloat( "$contrast", 0.5 )
--	-- ourMat:SetFloat( "$distance", 0.005 )
--
--	-- downsample
--	ourMat:SetFloat( "$multiply", 3 )
--	ourMat:SetFloat( "$scale", 1.1 )
--	surface.SetDrawColor( 255, 255, 255, 255 )
--	surface.SetMaterial( ourMat	) -- If you use Material, cache it!
--	surface.DrawTexturedRect( 0, 0, ScrW(), ScrH() )
--end )
