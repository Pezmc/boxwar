--- Code for the client
AddCSLuaFile("sh_init.lua")
AddCSLuaFile("player_class/class_box.lua")
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("sh_player.lua")

--- This file is only run on the server
include("sh_init.lua")
--include("player.lua")--]

--[[function GM:PlayerConnect( name, ip )
	print("Player" .. name .. " has joined the game.")
end
--]]
function GM:PlayerInitialSpawn( player )
	player:PrintMessage(HUD_PRINTCENTER,"Welcome to the server!")
	
	player:SetTeam(0)
	player_manager.SetPlayerClass(player, "player_box")
	
	print("Player: " .. player:Nick() .. " has spawned.")
end

-- Called whenever a has finished auth
function GM:PlayerAuthed( pl )
	local player_model = "models/Gibs/Antlion_gib_small_3.mdl"

	util.PrecacheModel(player_model)
	pl:SetModel(player_model)
	
	-- new entity
	pl.prop = ents.Create("box_prop")
	pl.prop:SetSolid(SOLID_BSP)
	pl.prop:SetOwner(pl)
	pl.prop:Spawn()

	// Set initial max health.
	pl.prop.max_health = 100
	pl.prop.health = 100

	// Calculate new player hull based on prop size.
	local hull_xy_max 	= math.Round(math.Max(pl.prop:OBBMaxs().x, pl.prop:OBBMaxs().y))
	local hull_xy_min 	= hull_xy_max * -1
	local hull_z 		= math.Round(pl.prop:OBBMaxs().z)

	// Set player hull server side.
	pl:SetHull(Vector(hull_xy_min, hull_xy_min, 0), Vector(hull_xy_max, hull_xy_max, hull_z))
	pl:SetHullDuck(Vector(hull_xy_min, hull_xy_min, 0), Vector(hull_xy_max, hull_xy_max, hull_z))
	pl:SetHealth(100)

	// Set the player hull client side so movement predictions work correctly.
	umsg.Start("SetHull", pl)
		umsg.Long(hull_xy_max)
		umsg.Long(hull_z)
		umsg.Short(new_health)
	umsg.End()
end

-- Called whenever a player spawns and must choose a model.
function GM:PlayerSetModel( pl )
end

-- Called when an entity takes damage.
function EntityTakeDamage( target, dmginfo )

	print (target)
	print (dmginfo)
	print("Attacker " .. attacker:Name() .. " shot " .. ent:Name())

	--[[if ent && !ent:IsPlayer() && attacker && attacker:IsPlayer() && attacker:Alive() then

		attacker:SetHealth(attacker:Health() - amount)

		if attacker:Health() <= 0 then

			MsgAll(attacker:Name() .. " felt guilty for hurting so many innocent props and committed suicide\n")
			attacker:Kill()

		end

	end]]

end
hook.Add("EntityTakeDamage", "PropHunt_EntityTakeDamage", EntityTakeDamage)

-- This is called when somebody tries to pick up and object
function GM:AllowPlayerPickup(ply, ent)

	return false

end

--[[function GM:PlayerAuthed( ply, steamID, uniqueID )
	print("Player: " .. ply:Nick() .. " has auth.")
end

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

	-- Calculate the location of every Prop's prop entity.
	for _, pl in pairs(player.GetAll()) do

		-- Check for a valid player/prop, and if they aren't freezing their prop.
		if pl && pl:IsValid() && pl:Alive() && pl.prop && pl.prop:IsValid()  && !(pl:KeyDown(IN_ATTACK2) && pl:GetVelocity():Length() == 0) then

			pl.prop:SetPos(pl:GetPos() - Vector(0, 0, pl.prop:OBBMins().z))
			pl.prop:SetAngles(pl:GetAngles())

		end

	end

end
hook.Add("Think", "PropHunt_Think", Think)