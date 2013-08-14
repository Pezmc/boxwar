-- Code for the client
AddCSLuaFile("sh_init.lua")
AddCSLuaFile("player_class/class_box.lua")
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("sh_player.lua")

-- This file is only run on the server
include("sh_init.lua")
include("maze.lua")

-- Called when the gamemode is initialized.
function Initialize()
	game.ConsoleCommand("mp_flashlight 1\n")
end
hook.Add("Initialize", "BoxWar_Initialize", Initialize)

-- See Maze.Lua
hook.Add("InitPostEntity","SpawnTheProps",timer.Simple(1,SpawnBoxMaze))

-- Called when a player leaves.
function PlayerDisconnected(pl)
	pl:RemoveProp()
end
hook.Add("PlayerDisconnected", "BoxWar_PlayerDisconnected", PlayerDisconnected)

-- If someone dies, delete their prop!
function PlayerDied( player, weapon, killer )
 	player:RemoveProp()
end
hook.Add( "PlayerDeath", "BoxWar_PlayerDeath", PlayerDied )

-- Called whenever a player spawns and has auth
function GM:PlayerAuthed( pl )
	SetBox(pl)
	
	-- Base gamemode
	self.BaseClass:PlayerAuthed(pl)
end

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

--[[ Called whenever a player spawns and must choose a model.
function GM:PlayerSetModel( pl )
	player_manager.SetPlayerClass(pl, "player_box")
end]]

--[[function GM:PlayerConnect( name, ip )
	print("Player" .. name .. " has joined the game.")
end
--]]

-- We use info_player_axis as no map should have these defined
local SpawnTypes = {"info_player_axis"}

function GetSpawnEnts(shuffled, force_all)
   local tbl = {}
   for k, classname in pairs(SpawnTypes) do
      for _, e in pairs(ents.FindByClass(classname)) do
         if IsValid(e) and (not e.BeingRemoved) then
            table.insert(tbl, e)
         end
      end
   end

   if shuffled then
      table.Shuffle(tbl)
   end

   return tbl
end

function GM:PlayerSelectSpawn( pl )
    spawns = GetSpawnEnts()    
    spawnNumber = math.random( #spawns )
    --print("Spawning user at spawn: " .. spawnNumber)
    return spawns[spawnNumber]
end

-- Set a player to be a box
function SetBox ( pl ) 

	-- If the player hasn't been spawned already
	if(!pl.spawned) then	
		pl.spawned = true
	
		-- First set the player model to a small model
		local player_model = "models/Gibs/Antlion_gib_small_3.mdl"
		--local player_model = "models/props_junk/wood_crate001a.mdl"
		
	
		--util.PrecacheModel(player_model)
		pl:SetModel(player_model)
		pl:SetRenderMode(RENDERMODE_TRANSALPHA)
		pl:SetColor(Color(255, 255, 255, 125))
		--pl:SetRenderOrigin(Vector(0, 0, 20))
		--pl:SetLocalPos(Vector(0,0,20))
		
		-- Then spawn a new box around them
		pl.prop = ents.Create("box_prop")
		--pl.prop:SetNotSolid(true)
		pl.prop:SetOwner(pl)
		
		pl.prop:SetPos(pl:GetPos())
		pl.prop:SetAngles(pl:GetAngles())
		pl.prop:SetSolid(SOLID_BBOX)
		pl.prop:SetParent(pl)
		pl.prop:Spawn()
	
		-- Set initial player max health.
		pl.prop.max_health = 100
		pl.prop.health = 100
	
		--[[ Calculate hull based on prop size.
		local hull_xy_max 	= math.Round(math.Max(pl.prop:OBBMaxs().x, pl.prop:OBBMaxs().y))
		local hull_xy_min 	= hull_xy_max * -1
		local hull_z 		= math.Round(pl.prop:OBBMaxs().z)
	
		-- Set player hull server side.
		pl:SetHull(Vector(hull_xy_min, hull_xy_min, 0), Vector(hull_xy_max, hull_xy_max, hull_z))
		pl:SetHullDuck(Vector(hull_xy_min, hull_xy_min, 0), Vector(hull_xy_max, hull_xy_max, hull_z))]]
		pl:SetHealth(100)
	
		-- Set the player hull client side
		umsg.Start("SetHull", pl)
			umsg.Long(hull_xy_max)
			umsg.Long(hull_z)
			umsg.Short(new_health)
		umsg.End()
	end
end


-- Called when an entity takes damage.
function EntityTakeDamage( target, dmginfo )

	local attacker 	= dmginfo:GetAttacker()
	local inflictor = dmginfo:GetInflictor()

	if target && !target:IsPlayer() && target:GetClass() != "box_prop" && attacker && attacker:IsPlayer() && attacker:Alive() then
		
		--[[
				-- If prop is now dead, take damage
		if(target:Health() <= 0)
			attacker:SetHealth(attacker:Health() - math.ceil(target:GetMaxHealth() / 10)) --shoot a non prop take 10% damage 
		end
		]]

		attacker:SetHealth(attacker:Health() - math.ceil(dmginfo:GetDamage() / 10)) --shoot a non prop take 10% damage 

		if attacker:Health() <= 0 then

			PrintMessage( HUD_PRINTTALK, attacker:Name() .. " felt guilty for hurting so many innocent boxes and committed suicide.")
			attacker.prop:GibBreakClient(attacker.prop:GetPos())
			attacker:RemoveProp()
			attacker:Kill()

		end

	end

end
hook.Add("EntityTakeDamage", "PropHunt_EntityTakeDamage", EntityTakeDamage)

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
--[[function Think()

	-- Calculate the location of every Prop's prop entity.
	for _, pl in pairs(player.GetAll()) do

		-- Check for a valid player/prop, and if they aren't freezing their prop.
		if pl && pl:IsValid() && pl:Alive() && pl.prop && pl.prop:IsValid()  && !(pl:KeyDown(IN_ATTACK2) && pl:GetVelocity():Length() == 0) then

			pl.prop:SetPos(pl:GetPos() - Vector(0, 0, pl.prop:OBBMins().z))
			pl.prop:SetAngles(pl:GetAngles())

		end

	end

end
hook.Add("Think", "BoxWar_Think", Think)]]