-- Load shared file
include("shared.lua")

-- Draw 
--[[function ENT:Draw()
	-- Hide the box this box is teh localPlayer
	--[[if self:GetOwner() != LocalPlayer() then
		self.Entity:DrawModel()
	end
end]]

local lastYaw = 0;

function ENT:Draw()
	local pl = self:GetOwner()
	
	if pl:IsValid() then
		-- don't draw the hat on the local player if they are in firstperson mode
		if LocalPlayer() == pl and not LocalPlayer():KeyDown(IN_ATTACK2) and not LocalPlayer():ShouldDrawLocalPlayer() then
			return
		end
	
		local m = Matrix()
				
		-- If the player is holding down attack 2 don't rotate
		if(pl:KeyDown(IN_ATTACK2) && pl:GetVelocity():Length() == 0) then
			m:SetAngles(Angle(0, lastYaw, 0)) --only the yaw (rotation in z)
		else
			local angles = pl:GetAngles()
			m:SetAngles(Angle(0, angles.y, 0)) --only the yaw (rotation in z)
			lastYaw = angles.y
		end
		
		-- Set to player pos and add 20 in z
		m:SetTranslation(pl:GetPos())
		m:Translate(Vector(0, 0, -self:OBBMins().z))
		
		self:SetRenderOrigin(m:GetTranslation())
		self:SetRenderAngles(m:GetAngles())
	end
	
	self:DrawModel()
end