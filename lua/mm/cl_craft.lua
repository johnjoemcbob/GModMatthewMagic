-- Matthew Cormack
-- 29/01/19

local frame, backdrop, craft_panel, comp_list

-- <<<<<<<<<<<<<<<<
-- Variables
-- <<<<<<<<<<<<<<<<
local dropid = "MM_Craft_DropID"
local textcolour = Color( 0, 0, 0, 255 )
local backtextcolour = Color( 150, 20, 10, 255 )
local backcolour = Color( 181, 181, 181, 255 )
local iw, ih = 64, 64
local titlebar = 22
local iconborder = 24
local border = 8

-- <<<<<<<<<<<<<<<<
-- Net
-- <<<<<<<<<<<<<<<<
net.Receive( "MM_Invoke", function()
	local comp = net.ReadString()
	print( "Received Invoke: " .. comp )

	hook.Run( "HUDItemPickedUp", comp )
end )
function MM_Net_SendCraftSpell( spell )
	net.Start( "MM_Receive_Spell_Craft" )
		for k, v in pairs( spell ) do
			if ( type( v ) == "function" ) then
				spell[k] = nil
			end
		end
		net.WriteTable( spell )
	net.SendToServer()
end

-- <<<<<<<<<<<<<<<<
-- Functions
-- <<<<<<<<<<<<<<<<
local components = {}
function MM_Craft_Component_Add( icon, type, name )
	local comp = comp_list:Add( "DPanel" )
	comp:SetSize( iw, ih )
	comp.Name = name
	comp.Type = type
	comp.Paint = function( self, w, h )
		-- Icon
		surface.SetDrawColor( 255, 255, 255, 255 )
		surface.SetMaterial( icon )
		surface.DrawTexturedRect( iconborder / 2, iconborder / 2, w - iconborder, h - iconborder )

		-- Name
		draw.SimpleText( type, "TargetID", 0, 0, textcolour, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP )
		draw.SimpleText( name, "TargetID", w, h, textcolour, TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM )
	end
	comp:Droppable( dropid )
	table.insert( components, comp )
	return comp
end

local slots = {}
function MM_Craft_Slot_Add( type, name, x, y )
	local w, h = iw + border * 2, ih + border * 2
	local slot = vgui.Create( "DPanel", craft_panel )
	slot:SetSize( w, h )
	slot:SetPos( x, y )
	slot.Name = name
	slot.Type = type
	slot.Component = nil
	slot.Slots = {}
	slot.PaintOver = function( self, w, h )
		if ( slot.Component == nil ) then
			-- Name
			draw.SimpleText( type, "TargetID", border, border, backtextcolour, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP )
			draw.SimpleText( name, "TargetID", w - border, h - border, backtextcolour, TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM )
		end

		-- Border
		surface.SetDrawColor( backtextcolour )
		surface.DrawRect( 0, 0, border, h )
		surface.DrawRect( w - border, 0, border, h )
		surface.DrawRect( 0, 0, w, border )
		surface.DrawRect( 0, h - border, w, border )
	end
	slot:Receiver( dropid, function( receiver, droppedpanels, isDropped, menuIndex, mouseX, mouseY )
		if ( isDropped ) then
			for k, panel in pairs( droppedpanels ) do
				MM_Craft_Drop_Slot( panel, slot )
			end
		end
	end, {} )
	table.insert( slots, slot )
	return slot
end

function MM_Craft_Slot_Leave( comp )
	if ( string.upper( comp.Type ) == "SPELL" ) then
		for k, slot in pairs( comp.Slot.Slots ) do
			if ( slot.Component ) then
				MM_Craft_Drop_Inv( slot.Component, comp_list )
			end
			slot:Remove()
			table.RemoveByValue( slots, slot )
		end
		comp.Slot.Slots = {}
	end

	comp.Slot.Component = nil
	comp.Slot = nil
end

function MM_Craft_Drop_Slot( dropped, into )
	if ( string.upper( into.Type ) == string.upper( dropped.Type ) ) then
		into:Add( dropped )
		into.Component = dropped
		print( into )
		dropped.Slot = into
		dropped:SetPos( border, border )

		if ( string.upper( dropped.Type ) == "SPELL" ) then
			MM_Craft_Drop_Slot_Spell( dropped, into )
		end
	end
end

function MM_Craft_Drop_Slot_Spell( dropped, into )
	-- Look up and create spell subcomponents
	local x = into:GetPos()
	for k, comp in pairs( MM_Components[string.upper( dropped.Name )].SubComponents ) do
		x = x + iw + border
		local slot = MM_Craft_Slot_Add( k, comp.Type, x, border )
		table.insert( into.Slots, slot )
		slot.SlotParent = into
	end
end

function MM_Craft_Drop_Inv( dropped, into )
	into:Add( dropped )

	if ( dropped.Slot != nil ) then
		MM_Craft_Slot_Leave( dropped )
	end
end

function MM_Craft_UI_Open()
	-- TODO Subslots depend on parent slots,
	-- IF parent slot changes then slots are removed/readded
	-- Make sure to remove component from slots before removing and readd to inv!

	slots = {}
	components = {}

	-- UI
	local w = ScrW() / 3
	local h = ScrH() / 1.5
	frame = vgui.Create( "DFrame" )
	frame:SetTitle( "Spell Crafting" )
	frame:SetSize( w, h )
	frame:Center()
	frame:SetDraggable( true )
	frame:MakePopup()

	w = w - border * 2
	h = h - titlebar - border * 2

	-- Background
	backdrop = vgui.Create( "DPanel", frame )
	backdrop:SetSize( w, h )
	backdrop:Center()
	local x, y = backdrop:GetPos()
	backdrop:SetPos( x, y + titlebar / 2 )

	w = w - border * 2
	h = h - border * 2

	-- Top crafting area
	craft_panel = vgui.Create( "DPanel", backdrop )
	craft_panel:SetSize( w, h / 2 )
	craft_panel:DockMargin( border, border, border, border )
	craft_panel:SetBackgroundColor( backcolour )
	-- craft_panel:Receiver( dropid, function( receiver, droppedpanels, isDropped, menuIndex, mouseX, mouseY )
		-- if ( isDropped ) then
			-- for k, panel in pairs( droppedpanels ) do
				-- craft_panel:Add( panel )
				-- local w, h = panel:GetSize()
				-- panel:SetPos( mouseX - w / 2, mouseY - h / 2 )
			-- end
		-- end
	-- end, {} )

	local bw, bh = 192, 32
	local button_spell = vgui.Create( "DButton", backdrop )
	button_spell:SetText( "Omg! Make spell!!" )
	button_spell:SetSize( bw, bh )
	button_spell:SetPos( w - bw, border / 2 + titlebar / 2 + h / 2 )
	button_spell.DoClick = function()
		print( "but1" )
		print( slots[1] )
		print( slots[1].Component )
		if ( slots[1].Component == nil ) then return end
		print( "but2" )

		frame:Close()

		-- local spell = table.shallowcopy( MM_Components[string.upper( slots[1].Component.Name )] )
		local data = {}
		table.insert( data, slots[1].Component.Name )
		for k, slot in pairs( slots ) do
			if ( slot != slots[1] and slot.Component ) then
				table.insert( data, { Name = slot.Type, Value = slot.Component.Name } )
			end
		end
		PrintTable( data )
		MM_Net_SendCraftSpell( data )
	end

	-- Bottom component list area
	comp_list = vgui.Create( "DTileLayout", backdrop )
	comp_list:SetSize( w, h / 2 )
	comp_list:SetBorder( border )
	comp_list:SetMinHeight( ih + border * 2 )
	comp_list:DockMargin( border, 0, border, border )
	comp_list:Dock( BOTTOM )
	comp_list:SetSpaceY( 5 )
	comp_list:SetSpaceX( 5 )
	comp_list:SetBackgroundColor( backcolour )
	comp_list:Receiver( dropid, function( receiver, droppedpanels, isDropped, menuIndex, mouseX, mouseY )
		if ( isDropped ) then
			for k, panel in pairs( droppedpanels ) do
				MM_Craft_Drop_Inv( panel, comp_list )
			end
			comp_list:Dock( BOTTOM )
			craft_panel:Dock( FILL )
		end
	end, {} )
	craft_panel:Dock( FILL )

	-- Base spell slot always
	MM_Craft_Slot_Add( "SPELL", "Main", border, border )

	-- Test with some components
	-- MM_Craft_Component_Add( Material( "icon16/wand.png" ), "Spell", "Force" )
	-- MM_Craft_Component_Add( Material( "icon16/clock.png" ), "Trigger", "Time" )
	-- MM_Craft_Component_Add( Material( "icon16/clock.png" ), "Trigger", "Hurt" )
	-- MM_Craft_Component_Add( Material( "icon16/status_online.png" ), "Target", "Self" )
	-- MM_Craft_Component_Add( Material( "icon16/arrow_up.png" ), "Direction", "Forward" )
	-- MM_Craft_Component_Add( Material( "icon16/arrow_up.png" ), "Direction", "Backward" )
	-- MM_Craft_Component_Add( Material( "icon16/status_online.png" ), "Target", "Self" )
	-- MM_Craft_Component_Add( Material( "icon16/status_online.png" ), "Target", "Self" )
	-- MM_Craft_Component_Add( Material( "icon16/status_online.png" ), "Target", "Self" )
	local type_icons = {
		["SPELL"] = Material( "icon16/wand.png" ),
		["TRIGGER"] = Material( "icon16/clock.png" ),
		["TARGET"] = Material( "icon16/status_online.png" ),
	}
	for k, comp in pairs( MM_Components ) do
		MM_Craft_Component_Add( type_icons[comp.Type], comp.Type, comp.Name )
	end
end
concommand.Add( "mm_craft", MM_Craft_UI_Open )
