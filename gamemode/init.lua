---
-- This script and all included files
-- Copyright 2013 Pez Cuckow & Oliver Brown.
-- All rights reserved.
---
-- Main server side script, sends files to client and includes others
---

-- Code for the client
AddCSLuaFile("sh_init.lua")
AddCSLuaFile("players/class_box.lua")
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("sh_player.lua")

-- 'Global' variables
DEBUG_MODE = true

-- Run the shared file
include("sh_init.lua")

-- Load server only files
include("maze/maze.lua") -- generate mazes
include("lib/json.lua") -- parse json
include("lib/toolkit.lua") -- add lua functions

-- Called when the gamemode is initialized.
function Initialize()
	game.ConsoleCommand("mp_flashlight 1\n")
	
	-- See Maze.Lua
	timer.Simple(1,CreateMazes)
end
hook.Add("Initialize", "BoxWar_Initialize", Initialize)

-- Called when a player leaves.
function PlayerDisconnected(pl)
	pl:RemoveProp() -- just delete their prop
end
hook.Add("PlayerDisconnected", "BoxWar_PlayerDisconnected", PlayerDisconnected)

-- If someone dies, delete their prop!
function PlayerDied( player, weapon, killer )
	pl:BoxWarkill() -- run the kill effect
end
hook.Add( "PlayerDeath", "BoxWar_PlayerDeath", PlayerDied )

-- On the first player spawn
function GM:PlayerInitialSpawn(pl)
	-- Base gamemode
	self.BaseClass:PlayerInitialSpawn(pl)
end

-- Every time a player spawns
function GM:PlayerSpawn( pl )
	player_manager.SetPlayerClass( pl, "player_crate" )
	
	pl:PrintMessage( HUD_PRINTTALK, "BoxWar is currently under development, please excuse any bugs." )
	
	-- Base gamemode
	self.BaseClass:PlayerSpawn(pl)
		
	SetBox(pl)
end

-- THIS DOESN'T WORK YET
function GM:OnRoundStart() 	
	for _,p in ipairs(player.GetAll()) do p:PrintMessage( HUD_PRINTCENTER, "A new round has started!" ) end
end


-- Called just before a player spawns to get their spawn point
function GM:PlayerSelectSpawn( pl )
    spawns = GetSpawnEnts()
    
    return spawns[math.random( #spawns )]
end

-- Called when an entity takes damage.
--[[function EntityTakeDamage( target, dmginfo )

	

end
hook.Add("EntityTakeDamage", "PropHunt_EntityTakeDamage", EntityTakeDamage)]]

--[[function GM:EntityRemoved( ent )
	print("Box dead?")
end]]

-- This is called when somebody tries to pick up and object
function GM:AllowPlayerPickup(ply, ent)

	return false

end

--[[
function GM:FragLimitThink()

	if ( GAMEMODE.IsEndOfGame ) then return end

	for k, ply in pairs( player.GetAll() ) do
	
		if ( !IsValid( ply ) ) then continue end
		if ( ply:Team() == TEAM_SPECTATOR ) then continue end
		if ( ply:Team() == TEAM_UNASSIGNED ) then continue end

		if ( ply:Frags() >= GAMEMODE.FragLimit ) then
			GAMEMODE:EndOfGame( true )
		end
		
	end
end]]

function GM:InitPostEntity()
	 print( "All Entities have initialized\n" )
end

-- Called every server tick.
function Think()
	for _, pl in pairs(player.GetAll()) do
		if ( pl:KeyDown(IN_ATTACK) ) then
			pl.angerLevel = pl.angerLevel + 1
		end

		if ( pl:KeyDown(IN_ATTACK2) ) then
			--pl:GetActiveWeapon():SetNextSecondaryFire(CurTime()+1000) -- disable secondary fire?
		end		
		
	end


	--Calculate the location of every Prop's prop entity.
	--[[for _, pl in pairs(player.GetAll()) do

		-- Check for a valid player/prop, and if they aren't freezing their prop.
		if pl && pl:IsValid() && pl:Alive() && pl.prop && pl.prop:IsValid()  && !(pl:KeyDown(IN_ATTACK2) && pl:GetVelocity():Length() == 0) then

			pl.prop:SetPos(pl:GetPos() - Vector(0, 0, pl.prop:OBBMins().z))
			pl.prop:SetAngles(pl:GetAngles())

		end

	end]]

end
hook.Add("Think", "BoxWar_Think", Think)