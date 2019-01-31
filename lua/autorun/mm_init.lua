-- Matthew Cormack
-- 22/04/18

MsgN("Initiating matthew magic ...")

if SERVER then
	-- AddCSLuaFile("autorun/mm_init.lua") -- Auto sent to client if autorun

	AddCSLuaFile("mm/cl_magic.lua")
	AddCSLuaFile("mm/cl_craft.lua")
	AddCSLuaFile("mm/cl_rune.lua")
	AddCSLuaFile("mm/cl_buff.lua")
	AddCSLuaFile("mm/sh_buff.lua")
	AddCSLuaFile("mm/shared.lua")

	include("mm/sv_magic.lua")
	include("mm/sv_rune.lua")
	include("mm/sv_buff.lua")
	include("mm/sh_buff.lua")
	include("mm/shared.lua")

	resource.AddFile( "materials/circle_reach.png" )
else
	include("mm/cl_magic.lua")
	include("mm/cl_craft.lua")
	include("mm/cl_rune.lua")
	include("mm/cl_buff.lua")
	include("mm/sh_buff.lua")
	include("mm/shared.lua")
end

MsgN("Done Initializing!")
