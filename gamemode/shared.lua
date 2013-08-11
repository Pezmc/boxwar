-- Run on client and server

GM.Name = "BoxWar"
GM.Author = "Need4Beans"
GM.Email = "email@pezcuckow.com"
GM.Website = "www.need4beans.com"

GM.GameLength 			= 30	
GM.MaximumDeathLength	= 1
GM.MinimumDeathLength 	= 1
GM.RealisticFallDamage	= true
GM.EnableFreezeCam		= true
GM.SelectColor			= true
GM.ShowTeamName 		= false
GM.NoPlayerTeamDamage 	= false
GM.FragLimit			= 20

include("player_class/class_box.lua")

function GM:CreateTeams()

	team.SetUp( 1, "Deathmatchers", Color( 70, 230, 70 ), true )
	team.SetSpawnPoint( 1, "info_player_start" )
	team.SetClass( 1, { "Box" } )

end

-- Called when the game starts
function GM:Initialize()
	self.BaseClass.Initialize( self )
end

-- We are not using sandbox so this doesn't exist
function DoPropSpawnedEffect( e )
end