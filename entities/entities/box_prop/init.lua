-- Need both cl and shared on the client
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

-- Load shared
include("shared.lua")

-- Called when the entity loads
function ENT:Initialize()

	self:SetModel("models/props_junk/wood_crate001a.mdl")
	self:PhysicsInit( SOLID_VPHYSICS )      -- Make us work with physics,
	--self:SetMoveType( MOVETYPE_VPHYSICS )   -- after all, gmod is a physics
	self:SetSolid( SOLID_VPHYSICS )         -- Toolbox
	self.health = 100
	
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

		print(attacker:Name() .. " shot " .. pl:Name())

		-- Set player health.
		self.health = self.health - dmg:GetDamage()
		pl:SetHealth(self.health)
		
		-- Damage the box
		if(self.health < self.max_health * 0.25) then
			self:SetModel("models/props_junk/wood_crate001a_damagedmax.mdl")
		elseif(self.health < self.max_health * 0.5) then
			self:SetModel("models/props_junk/wood_crate001a_damaged.mdl")
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
	--self:CalculateBoxAnger()
	
end