-- Code for the client
AddCSLuaFile("sh_init.lua")
AddCSLuaFile("player_class/class_box.lua")
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("sh_player.lua")

-- Run the shared file
include("sh_init.lua")

-- Load server only files
include("maze.lua")
include("lib/json.lua")
include("toolkit.lua")

-- Currently in debug?
debugMode = true

-- Count how many boxes there are
totalMazeBoxes = 0
currentMazeBoxes = 0

-- Called when the gamemode is initialized.
function Initialize()
	game.ConsoleCommand("mp_flashlight 1\n")
	
	-- See Maze.Lua
	timer.Simple(1,CreateMazes)
	
end
hook.Add("Initialize", "BoxWar_Initialize", Initialize)

-- Called when a player leaves.
function PlayerDisconnected(pl)
	pl:RemoveProp()
end
hook.Add("PlayerDisconnected", "BoxWar_PlayerDisconnected", PlayerDisconnected)

-- If someone dies, delete their prop!
function PlayerDied( player, weapon, killer )
	-- Kill the player and remove their prop.
	player:SetModel("models/player/leet.mdl")
	player:SetColor(Color(255,255,255,255))
	player:CreateRagdoll()
	
	if not player:Alive() and ValidEntity( player:GetRagdollEntity() ) then
	  local ent = player:GetRagdollEntity()
	  local head = ent:GetPhysicsObjectNum( 10 )
	  head:ApplyForceCenter( Vector(0,0,-100) )
	end
		
	if (player.prop ~= nil)	then	
		-- Smash the box
		player.prop:PrecacheGibs()
		player.prop:GibBreakClient(Vector(0,0,100))
	end
		  
    -- Delete the prop
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

function GM:CanStartRound( iNum )
     --if team.NumPlayers( TEAM_RED ) > 0 and team.NumPlayers( TEAM_BLUE ) > 0 then
          return true
     --else
     --     return false
     --end
end

-- THIS DOESN'T WORK YET
function GM:OnRoundStart() 

	
	for _,p in ipairs(player.GetAll()) do p:PrintMessage( HUD_PRINTCENTER, "A new round has started!" ) end
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
    
    return spawns[spawnNumber]
end

	
--[[function GM:KeyPress( pl, key )	
	 if ( key == IN_ATTACK ) then
	 	Player:KeyDownLast( number key )
		pl.angerLevel = pl.angerLevel + 1
		print(pl.angerLevel)
	 end
end]]

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
		pl:SetColor(Color(255, 255, 255, 1))
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
		
		pl.angerLevel = 0;
	
		-- Set initial player max health.
		pl.prop.max_health = 100
		pl.prop.health = 100
		
		-- Set player info
		pl:SetJumpPower( 250 )
		pl:SetRunSpeed(250) --default 500
		pl:SetWalkSpeed(125) --default 250
		pl:DrawWorldModel(false);
		pl:SetHealth(100)
		
		pl:SetViewOffset( 	Vector( 0, 0, 22 ) ) -- I think this must base it on the prop so we must round up
		pl:SetViewOffsetDucked( Vector( 0, 0, 36+22 ) )
		
		-- Calculate new player hull slightly smaller than prop
		local hull_xy_max 	= math.floor(math.Max(pl.prop:OBBMaxs().x, pl.prop:OBBMaxs().y) * 0.8)
		local hull_xy_min 	= hull_xy_max * -1
		local hull_z 		= math.floor(pl.prop:OBBMaxs().z * 0.8)
		
		-- Set player hull.
		pl:SetHull(Vector(hull_xy_min, hull_xy_min, 0), Vector(hull_xy_max, hull_xy_max, hull_z))
		pl:SetHullDuck(Vector(hull_xy_min, hull_xy_min, 0), Vector(hull_xy_max, hull_xy_max, hull_z))
	
		-- Set the player hull client side
		umsg.Start("SetHull", pl)
			umsg.Long(hull_xy_max)
			umsg.Long(hull_z)
		umsg.End()
	end
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