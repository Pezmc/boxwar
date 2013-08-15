-- Need both cl and shared on the client
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

-- Load shared
include("shared.lua")

-- Called when the entity loads
function ENT:Initialize()

	self:PhysicsInit( SOLID_VPHYSICS )      -- Make us work with physics,
	self:SetMoveType( MOVETYPE_VPHYSICS )   -- after all, gmod is a physics
	self:SetSolid( SOLID_VPHYSICS )         -- Toolbox
	self:DrawShadow( true )

end 

-- Called when part of the maze takes damage.
function ENT:OnTakeDamage(dmginfo)

	local attacker 	= dmginfo:GetAttacker()
	local inflictor = dmginfo:GetInflictor()

	if attacker && attacker:IsPlayer() && attacker:Alive() then
	
		self:SetHealth(self:Health() - dmginfo:GetDamage())

		-- Check if the box should be dead.
		if self:Health() <= 0 then
			currentMazeBoxes = currentMazeBoxes - 1
			self:PrecacheGibs()
			self:GibBreakClient(self:GetPos())
			self:Remove()
		end

		-- Deal with player damage
		attacker:SetHealth(attacker:Health() - math.ceil(dmginfo:GetDamage() / 10)) --shoot a non prop take 10% damage 

		if attacker:Health() <= 0 then

			PrintMessage( HUD_PRINTTALK, attacker:Name() .. " felt guilty for hurting so many innocent boxes and committed suicide.")
			attacker.prop:GibBreakClient(attacker.prop:GetPos())
			attacker:RemoveProp()
			attacker:Kill()

		end
	end	
end 