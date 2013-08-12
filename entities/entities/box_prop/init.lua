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

end 

-- Called when box takes damage.
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
			
			self:PrecacheGibs()
			
			--@todo, spawn a ragdol here?
			-- Smash the prop
			self:GibBreakClient(self:GetPos())
			--self:GibBreakServer(self:GetPos())
		    
		    -- Delete the prop
			pl:RemoveProp()

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

			-- Add points to the attacker's score and up their health.
			attacker:AddFrags(1)
			attacker:SetHealth(math.Clamp(attacker:Health() + 25, 1, 100)) -- 10 bonus health

		end

	end
	
	

end 