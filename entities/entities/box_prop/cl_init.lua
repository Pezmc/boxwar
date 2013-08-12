-- Load shared file
include("shared.lua")

-- Draw 
function ENT:Draw()
	-- Hide the box this box is teh localPlayer
	if self:GetOwner() != LocalPlayer() then
		self.Entity:DrawModel()
	end
end 