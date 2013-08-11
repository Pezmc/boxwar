--- This file is only run on the server

AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")
include("player.lua")

function GM:PlayerConnect( name, ip )
	print("Player" .. name .. " has joined the game.")
end

function GM:PlayerInitialSpawn( player )
	ply:PrintMessage(HUD_PRINTCENTER,"Welcome to the server!")
	print("Player: " .. ply:Nick() .. " has spawned.")
end

function GM:PlayerSetModel( player )
	ply:SetModel("models/player/group01/male_07.mdl")
end

function GM:PlayerAuthed( ply, steamID, uniqueID )
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
end

timer.Create( "FragLimitThink", 1, 0, function() GAMEMODE:FragLimitThink() end )