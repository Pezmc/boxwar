DEFINE_BASECLASS( "player_default" )

local PLAYER = {}

PLAYER.DisplayName			= "Box"
PLAYER.WalkSpeed 			= 230
PLAYER.CrouchedWalkSpeed 	= 0.2
PLAYER.RunSpeed				= 400
PLAYER.DuckSpeed			= 0.2
PLAYER.DrawTeamRing			= false

function PLAYER:Loadout()

	self.Player:RemoveAllAmmo()

	self.Player:GiveAmmo( 20, "Buckshot" )
	self.Player:GiveAmmo( 400, "SMG1" )
	self.Player:GiveAmmo( 50, "pistol" )
	
	self.Player:Give( "weapon_crowbar" )
	self.Player:Give( "weapon_pistol" )
	self.Player:Give( "weapon_shotgun" )
	self.Player:Give( "weapon_smg1" )
	--self.Player:Give( "item_ar2_grenade" )
	
end

function PLAYER:Spawn()
	BaseClass.Spawn( self ) -- This is a must have
	self.Player:DrawWorldModel(false)
end

-- Called on spawn
function PLAYER:OnSpawn()
	-- Make sure player model doesn't show up to anyone else.
	
	BaseClass.OnSpawn( self ) -- This is a must have
end

player_manager.RegisterClass( "player_crate", PLAYER, "player_default" )