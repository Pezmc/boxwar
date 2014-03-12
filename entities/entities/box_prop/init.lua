-- Need both cl and shared on the client
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

-- Load shared
include("shared.lua")

-- Called when the entity loads
function ENT:Initialize()

	-- Set up entity defaults
	self:SetModel("models/boxwar/bwcrate1.mdl")
	
	-- Physics and bounding
	self:SetSolid(SOLID_BBOX)
	self:PhysicsInit( SOLID_VPHYSICS )      -- Make us work with physics,
	self:SetSolid( SOLID_VPHYSICS )         -- Toolbox
	
	-- Collisions
	self:SetCollisionGroup( COLLISION_GROUP_PLAYER ) -- Collision group for player
	
	-- Health
	self.health = 100 -- Default health
	self.max_health = 100
	
	-- Bounding box
	self:CalculateMinMax()
end 

-- Called when box takes damage.
function ENT:OnTakeDamage(dmg)

	-- Damage info
	local pl 		= self:GetOwner()
	local attacker 	= dmg:GetAttacker()
	local inflictor = dmg:GetInflictor()

	-- Check player and attacker are valid.
	if pl && pl:IsValid() && pl:Alive() && pl:IsPlayer() && attacker:IsPlayer() && dmg:GetDamage() > 0 then
	
		-- You can't shoot your own box
		if( pl == attacker ) then
			return
		end
			
		-- Output the shot
		printDebug(attacker:Name() .. " shot " .. pl:Name())

		-- Set player health.
		self.health = self.health - dmg:GetDamage()
		pl:SetHealth(self.health)
		
		--[[ Not implemented until new models have damaged versions
		-- Damage the box
		if(self.health < self.max_health * 0.25) then
			self:SetModel("models/props_junk/wood_crate001a_damagedmax.mdl")
		elseif(self.health < self.max_health * 0.5) then
			self:SetModel("models/props_junk/wood_crate001a_damaged.mdl")
		end
		]]

		-- Human blood
		DecalName = "Blood" --"Impact.Wood" --Impact.Wood, Blood
		EffectName = "BloodImpact" --"BloodImpact"
				
		-- Perform a trace from the player, using their current velocity
		local Trace = {}
		Trace.start = dmg:GetDamagePosition()
		Trace.endpos = Trace.start + dmg:GetDamageForce( ) * 5
		Trace.filter = pl
		local tr = util.TraceLine( Trace )
				
		-- If we hit something
		if ( tr.Hit && tr.HitPos:Distance( pl:GetPos() ) < 100 ) then
		
			-- Spawn some blood
			util.Decal( DecalName, tr.HitPos + tr.HitNormal, tr.HitPos - tr.HitNormal )
			util.Decal( DecalName, tr.HitPos - tr.HitNormal, tr.HitPos + tr.HitNormal )

			-- Spawn a spike of blood
			local Effect = EffectData()
			Effect:SetOrigin( tr.HitPos )
			util.Effect( EffectName, Effect )
			
			local Effect = EffectData()
			Effect:SetOrigin( dmg:GetDamagePosition() )
			util.Effect( EffectName, Effect )
		end

		-- Check if the player should be dead.
		if self.health <= 0 then

			-- Kill the player and remove their prop.
			pl:Kill()
			
			-- Find out what player should take credit for the kill.
			if inflictor && inflictor == attacker && inflictor:IsPlayer() then

				inflictor = inflictor:GetActiveWeapon()

				if !inflictor || inflictor == NULL then

					inflictor = attacker

				end

			end
			
			-- Print to chat & to the murderer
			PrintMessage( HUD_PRINTTALK, attacker:Name() .. " found and killed " .. pl:Name() .. ".")
			if(attacker:IsPlayer()) then attacker:PrintMessage( HUD_PRINTCENTER, " You killed " .. pl:Name() .. "." ) end

			-- Add points to the attacker's score.
			attacker:AddFrags(1)
			
			-- Bonus health to player and their box
			attacker:SetHealth(math.Clamp(attacker:Health() + 25, 1, 100)) 
			if(attacker.prop ~= nil and attacker.prop:IsValid()) then
				attacker.prop.health = math.Clamp(attacker.prop.health + 25, 1, 100)
			end

		end

	end
	
	

end 

function ENT:CalculateBoxAnger() 
	local pl = self:GetOwner()
	
	if pl:IsValid() then
	
		-- Make box red when player "angry"
		local playerAngry = false
		if(pl.angerLevel > 50) then
			playerAngry = true
			local color = math.floor(((pl.angerLevel-50) + 1) / 2);
			if(color > 128) then color = 128; end --don't let the player get too red
			
			pl.prop:SetColor(Color(255,255-color,255-color,255));
		else
			-- Make sure they reset to the true color
			if(playerAngry) then
				pl.prop:SetColor(Color(255,255,255,255));
				playerAngry = false
			end
		end
		
		-- Decrease the player anger level
		if(pl.angerLevel > 0) then
			pl.angerLevel = pl.angerLevel - 10
		end
	end
end

function ENT:Think()

	-- Use the shared server and client method to calculate the current position
	self:CalculateBoxPosition()

	-- Calculate how red the box is
	self:CalculateBoxAnger()
	
end
