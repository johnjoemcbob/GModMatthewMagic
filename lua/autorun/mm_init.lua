-- Matthew Cormack
-- 22/04/18

MsgN("Initiating matthew magic ...")

if SERVER then
	AddCSLuaFile("autorun/mm_init.lua")

	AddCSLuaFile("mm/cl_magic.lua")
	AddCSLuaFile("mm/cl_rune.lua")
	AddCSLuaFile("mm/shared.lua")

	include("mm/sv_magic.lua")
	include("mm/sv_rune.lua")
	include("mm/shared.lua")
else
	include("mm/cl_magic.lua")
	include("mm/cl_rune.lua")
	include("mm/shared.lua")
end

MsgN("Done Initializing!")
