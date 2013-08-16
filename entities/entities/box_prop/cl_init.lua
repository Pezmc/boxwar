-- Load shared file
include("shared.lua")

-- Draw 
--[[function ENT:Draw()
	-- Hide the box this box is teh localPlayer
	--[[if self:GetOwner() != LocalPlayer() then
		self.Entity:DrawModel()
	end
end]]

function ENT:Draw()
	local pl = self:GetOwner()
	
	if pl:IsValid() then
		-- don't draw the local player if they are in firstperson mode
		if LocalPlayer() == pl and not LocalPlayer():KeyDown(IN_ATTACK2) and not LocalPlayer():ShouldDrawLocalPlayer() then
			return
		end
	end
	
	self:DrawModel()
end