-- Run on client and server

include("sh_player.lua")
include("player_class/class_box.lua")

GM.Name = "BoxWar"
GM.Author = "Need4Beans"
GM.Email = "email@pezcuckow.com"
GM.Website = "www.need4beans.com"
-- Date of last change
GM.Version = "2013-08-11"

GM.GameLength 			= 30	
GM.MaximumDeathLength	= 1
GM.MinimumDeathLength 	= 1
GM.RealisticFallDamage	= true
GM.EnableFreezeCam		= true
GM.SelectColor			= true
GM.ShowTeamName 		= false
GM.NoPlayerTeamDamage 	= false
GM.FragLimit			= 20
GM.NoAutomaticSpawning		= true
GM.NoNonPlayerPlayerDamage	= true
GM.NoPlayerPlayerDamage 	= true


function GM:CreateTeams()

	team.SetUp( 1, "Deathmatchers", Color( 70, 230, 70 ), true )
	team.SetSpawnPoint( 1, "info_player_start" )
	team.SetClass( 1, { "player_box" } )

end

--[[ Called when the game starts
function GM:Initialize()
	self.BaseClass.Initialize( self )
end

-- We are not using sandbox so this doesn't exist
function DoPropSpawnedEffect( e )
end]]