DEFINE_BASECLASS( "player_default" )

local CLASS = {}

CLASS.DisplayName			= "Box"
CLASS.WalkSpeed 			= 230
CLASS.CrouchedWalkSpeed 	= 0.2
CLASS.RunSpeed				= 400
CLASS.DuckSpeed				= 0.2
CLASS.DrawTeamRing			= false

function CLASS:Loadout( pl )

	pl:GiveAmmo( 20, "Buckshot" )
	pl:GiveAmmo( 400, "SMG1" )
	pl:GiveAmmo( 50, "pistol" )
	
	pl:Give( "weapon_pistol" )
	pl:Give( "weapon_shotgun" )
	pl:Give( "weapon_smg1" )
	pl:Give( "item_ar2_grenade" )
	
end

player_manager.RegisterClass( "Box", CLASS, "player_default" )