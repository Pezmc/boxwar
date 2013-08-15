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

			-- Add points to the attacker's score and up their health.
			attacker:AddFrags(1)
			attacker:SetHealth(math.Clamp(attacker:Health() + 25, 1, 100)) -- 10 bonus health

		end

	end
	
	

end 

local lastYaw = 0

function ENT:Think()

	--[[self.R = self.R or 0; -- if R is nil, make it 0
 
	if(self.R < 255) then
			self:SetColor(Color(self.R, 0, 0, 255)); -- actually set the color
			self.R = self.R + 1; -- increment R
	end]]

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
	
		--[[
	
		local m = Matrix()
				
		-- If the player is holding down attack 2 don't rotate
		if(pl:KeyDown(IN_ATTACK2) && pl:GetVelocity():Length() == 0) then
			m:SetAngles(Angle(0, lastYaw, 0)) --only the yaw (rotation in z)
		else
			local angles = pl:GetAngles()
			m:SetAngles(Angle(0, angles.y, 0)) --only the yaw (rotation in z)
			lastYaw = angles.y
		end]]
		
		--print("Info:")
		--print(pl:GetPos())
		--print(self:GetPos())
		--self:SetLocalPos(Vector(0, , ))
		--self:SetPos(pl:GetPos() + Vector(0, 0, -self:OBBMins().z))
		--print(self:GetPos())
		--self:SetAngles(m:GetAngles())
		--self:SetAngles(Angle(0,0,0))
	end
end