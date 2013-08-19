-- Run on client and server
include("players/class_box.lua")
include("sh_player.lua")

-- GM details
GM.Name = "BoxWar"
GM.Author = "Need4Beans"
GM.Email = "email@pezcuckow.com"
GM.Website = "www.need4beans.com"

-- Date of last change
GM.Version = "2013-08-19"

-- Custom enums ---
-- Round status
ROUND_WAIT   = 1
ROUND_PREP   = 2
ROUND_ACTIVE = 3
ROUND_POST   = 4

-- Win states
WIN_PLAYER    = 1
WIN_TIMELIMIT = 2

-- GM options
--[[GM.GameLength 			= 30	
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

GM.Help = "Find and kill the other boxes!"]]

--Called when the game starts
function GM:Initialize()
	self.BaseClass.Initialize( self )
end

