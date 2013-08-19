DEFINE_BASECLASS( "player_default" )

local PLAYER = {}

PLAYER.DisplayName			= "Box"
PLAYER.WalkSpeed 			= 230
PLAYER.CrouchedWalkSpeed 	= 0.2
PLAYER.RunSpeed				= 400
PLAYER.DuckSpeed			= 0.2
PLAYER.DrawTeamRing			= false
PLAYER.AutomaticFrameAdvance = true

-- Called when the class object is created
function PLAYER:Init( )
	self.Player.boxSpawned = false
end

-- Called on spawn to give the player their default loadout
function PLAYER:Loadout()

	self.Player:RemoveAllAmmo()
	
	self.Player:GiveAmmo( 50, "pistol" )
	
	self.Player:Give( "weapon_crowbar" )
	self.Player:Give( "weapon_pistol" )
	
end

-- Called on player spawn
function PLAYER:Spawn()
	BaseClass.Spawn( self ) -- This is a must have
	self.Player:DrawWorldModel(false) -- attempt to hide the players weapon
	
	-- Hide the player model
	self:HidePlayer()
	
	-- Set the players anger
	self.Player.angerLevel = 0;
	
	-- Turn the player into a box
	self:BoxPlayer()
end

-- Hide the player model
function PLAYER:HidePlayer()
	local model = "models/Gibs/Antlion_gib_small_3.mdl"
		
	util.PrecacheModel(model)
	self.Player:SetModel(player_model)
	self.Player:SetRenderMode(RENDERMODE_TRANSALPHA)
	self.Player:SetColor(Color(255, 255, 255, 1))
end

-- Turn the player into a box, after their box 
function PLAYER:BoxPlayer()

	-- Spawn in a box for the player
	self:CreateBox()
	

	-- Set player info
	self.Player:SetJumpPower( 250 )
	self.Player:SetRunSpeed(250) --default 500
	self.Player:SetWalkSpeed(125) --default 250
	self.Player:SetHealth(100)
	
	-- Set player view	
	self.Player:SetViewOffset( 	Vector( 0, 0, 30 ) ) -- I think this must base it on the prop so we must round up
	self.Player:SetViewOffsetDucked( Vector( 0, 0, 36+25 ) )
		
	-- Set the players hull on server and client
	self:SetHull()

end


function PLAYER:SetHull() 
	-- Calculate new player hull slightly smaller than prop
	local hull_xy_max 	= math.floor(math.Max(self.Player.prop:OBBMaxs().x, self.Player.prop:OBBMaxs().y) * 0.8)
	local hull_xy_min 	= hull_xy_max * -1
	local hull_z 		= math.floor(self.Player.prop:OBBMaxs().z * 0.8)
	
	-- Set player hull.
	self.Player:SetHull(Vector(hull_xy_min, hull_xy_min, 0), Vector(hull_xy_max, hull_xy_max, hull_z))
	self.Player:SetHullDuck(Vector(hull_xy_min, hull_xy_min, 0), Vector(hull_xy_max, hull_xy_max, hull_z))

	-- Set the player hull client side
	umsg.Start("SetHull", pl)
		umsg.Long(hull_xy_max)
		umsg.Long(hull_z)
	umsg.End()
end

function PLAYER:CreateBox() 
	
	-- Map to a shorthand
	local pl = self.Player
	
	-- If the box hasn't been spawned already
	if(!pl.boxSpawned) then	
		pl.boxSpawned = true
		
		-- Spawn in our custom entity
		pl.prop = ents.Create("box_prop")
		
		pl.prop:SetOwner(pl)
		pl.prop:SetPos(pl:GetPos())
		pl.prop:SetAngles(pl:GetAngles())
		pl.prop:SetParent(pl)
		pl.prop:Spawn()
	end
end

-- Called when the player changes their weapon to another one causing their viewmodel model to change
function PLAYER:ViewModelChanged( Entity viewmodel, string old, string new )
	self.Player:DrawWorldModel(false) -- attempt to hide the players weapon
end

player_manager.RegisterClass( "player_crate", PLAYER, "player_default" )