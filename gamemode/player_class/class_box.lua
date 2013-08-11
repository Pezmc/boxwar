DEFINE_BASECLASS( "player_default" )

local CLASS = {}

CLASS.DisplayName			= "Box"
CLASS.WalkSpeed 			= 230
CLASS.CrouchedWalkSpeed 	= 0.2
CLASS.RunSpeed				= 400
CLASS.DuckSpeed				= 0.2
CLASS.DrawTeamRing			= false

function CLASS:Loadout( pl )

	self.Player:GiveAmmo( 20, "Buckshot" )
	self.Player:GiveAmmo( 400, "SMG1" )
	self.Player:GiveAmmo( 50, "pistol" )
	
	self.Player:Give( "weapon_pistol" )
	self.Player:Give( "weapon_shotgun" )
	self.Player:Give( "weapon_smg1" )
	self.Player:Give( "item_ar2_grenade" )
	
end

-- Called on spawn
function CLASS:OnSpawn(pl)

	-- Make sure player model doesn't show up to anyone else.
	pl:SetColor(255, 255, 255, 0)

	// Create a new ph_prop entity, set its collision type, and spawn it.
	pl.prop = ents.Create("box_prop")
	pl.prop:SetSolid(SOLID_BSP)
	pl.prop:SetOwner(pl)
	pl.prop:Spawn()

	// Set initial max health.
	pl.prop.max_health = 100
end

player_manager.RegisterClass( "player_box", CLASS, "player_default" )