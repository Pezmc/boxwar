---
-- This script and all included files
-- Copyright 2013 Pez Cuckow & Oliver Brown.
-- All rights reserved.
---
-- Main server side script, sends files to client and includes others
---

-- Code for the client
AddCSLuaFile("sh_init.lua")
AddCSLuaFile("cl_init.lua")

AddCSLuaFile("players/class_box.lua")
AddCSLuaFile("cl_hud.lua")
AddCSLuaFile("sh_player.lua")

-- 'Global' variables
DEBUG_MODE = false

-- Run the shared file
include("sh_init.lua")

-- Load server only files
include("maze/maze.lua") -- generate mazes
include("rounds.lua") -- handle game rounds
include("spawns.lua") -- spawn point for users
include("lib/json.lua") -- parse json
include("lib/toolkit.lua") -- add lua functions

-- Download hud resources (to be moved into the folders below)
AddResourcesByDirectory("materials/boxwar_hud")
AddResourcesByDirectory("effects/boxwar_hud")

-- Download custom resources
AddResourcesByDirectory("materials/boxwar")
AddResourcesByDirectory("materials/models/boxwar")
AddResourcesByDirectory("models/boxwar")


-- Con var's
CreateConVar("bw_roundtime_minutes", 10, FCVAR_NOTIFY, "The length of a round in minutes")
CreateConVar("bw_max_frags", 10, FCVAR_NOTIFY, "The frag limit before a player wins a round")
CreateConVar("bw_minimum_players", 2, FCVAR_NOTIFY, "Minimum amount of players required")
CreateConVar("bw_debug_mode", 0, FCVAR_NOTIFY, "Output debug information true/false")

-- Called when the gamemode is initialized.
function Initialize()
	MsgN("BoxWar gamemode initializing...")
	
	-- Force check client scripts to prevent modding
	RunConsoleCommand("sv_allowcslua", "0")
	
	-- Delay reading of cvars until config has loaded
	GAMEMODE.cvars_loaded = false
	
	-- Make random more random?!?
	math.randomseed(os.time())
	
	-- Set up the current round
	GAMEMODE.RoundState = ROUND_WAIT
	
	-- Wait for players before we start a game
	WaitForPlayers()
end
hook.Add("Initialize", "BoxWar_Initialize", Initialize)

-- Server cfg has not always run yet by initialize
function GM:InitCvars()
	print("Loading convar settings...")
   
	-- Debug?
	if(GetConVar("bw_debug_mode"):GetInt() >= 1) then
		print("=== Debug Enabled ===")
		DEBUG_MODE = true
	end
	
	-- Don't kick if in debug mode
	if(DEBUG_MODE) then RunConsoleCommand("sv_kickerrornum", "0") end
	
	-- Don't run this again
	GAMEMODE.cvars_loaded = true
end

-- Called when a player leaves.
function PlayerDisconnected(pl)
	pl:RemoveProp() -- just delete their prop
end
hook.Add("PlayerDisconnected", "BoxWar_PlayerDisconnected", PlayerDisconnected)

-- If someone dies, delete their prop!
function PlayerDied( player, weapon, killer )
	player:BoxwarKill() -- run the kill effect
end
hook.Add( "PlayerDeath", "BoxWar_PlayerDeath", PlayerDied )

-- Prevent gmod handling player death
function GM:DoPlayerDeath( ply, attacker, dmginfo )
 	-- DO nothing
end

-- On the first player spawn
function GM:PlayerInitialSpawn(pl)
	-- First player to spawn
	if not GAMEMODE.cvars_loaded then
	  GAMEMODE:InitCvars()
	end

	-- Base gamemode
	self.BaseClass:PlayerInitialSpawn(pl)
end

-- Every time a player spawns
function GM:PlayerSpawn( pl )
	player_manager.SetPlayerClass( pl, "player_crate" )
	
	pl:PrintMessage( HUD_PRINTTALK, "BoxWar is currently under development, please excuse any bugs." )
	
	-- Base gamemode
	self.BaseClass:PlayerSpawn(pl)
end

-- Called just before a player spawns to get their spawn point
function GM:PlayerSelectSpawn( pl )
    spawns = GetSpawnEnts()
    
    return spawns[math.random( #spawns )]
end

-- This is called when somebody tries to pick up and object
function GM:AllowPlayerPickup(ply, ent)
	return false
end

function GM:InitPostEntity()
	 print( "All Entities have initialized\n" )
end

-- Version announce also used in Initialize
function ShowVersion(ply)
   local text = Format("This is BoxWar version %s\n", GAMEMODE.Version)
   if IsValid(ply) then
      ply:PrintMessage(HUD_PRINTNOTIFY, text)
   else
      Msg(text)
   end
end
concommand.Add("bw_version", ShowVersion)

-- Announce used to tell the players the current version
function AnnounceVersion()
   local text = Format("You are playing %s, version %s.\n", GAMEMODE.Name, GAMEMODE.Version)

   -- announce to players
   for k, ply in pairs(player.GetAll()) do
      if IsValid(ply) then
         ply:PrintMessage(HUD_PRINTTALK, text)
      end
   end
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
end
hook.Add("Think", "BoxWar_Think", Think)
