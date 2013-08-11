-- Need both cl and shared on the client
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

-- Load shared
include("shared.lua")

-- Called when the entity loads
function ENT:Initialize()

	self:SetModel("models/props_junk/wood_crate001a.mdl")
	self.health = 100

end 


-- Called when the takes damage.
function ENT:OnTakeDamage(dmg)

	-- Damage info
	local pl 		= self:GetOwner()
	local attacker 	= dmg:GetAttacker()
	local inflictor = dmg:GetInflictor()

	-- Check player and attacker are valid.
	if pl && pl:IsValid() && pl:Alive() && pl:IsPlayer() && attacker:IsPlayer() && dmg:GetDamage() > 0 then

		-- Set player health.
		self.health = self.health - dmg:GetDamage()
		pl:SetHealth(self.health)

		-- Check if the player should be dead.
		if self.health <= 0 then

			-- Kill the player and remove their prop.
			pl:KillSilent()
			pl:RemoveProp()

			-- Find out what player should take credit for the kill.
			if inflictor && inflictor == attacker && inflictor:IsPlayer() then

				inflictor = inflictor:GetActiveWeapon()

				if !inflictor || inflictor == NULL then

					inflictor = attacker

				end

			end

			print(attacker:Name() .. " found and killed " .. pl:Name() .. "\n") 

			-- Add points to the attacker's score and up their health.
			attacker:AddFrags(1)
			attacker:SetHealth(math.Clamp(attacker:Health() + 10, 1, 100))

		end

	end

end 