// Entity information.
ENT.Type = "anim"
ENT.Base = "base_anim"

local min, max

function ENT:CalculateMinMax()
	min = self:OBBMins()
	max = self:OBBMaxs()
end

function ENT:Initialize()
	self:CalculateMinMax()
	self.lastYaw = 0;
end

function ENT:CalculateBoxPosition() 
	local pl = self:GetOwner()
	
	if pl:IsValid() then

		-- Shift the box up by it's min Z position
		local playerPos = self:GetOwner():GetPos()
		self:SetPos(Vector(0,0,-min.z))
		--print("Player then owner:")
		--print(self:GetOwner():GetPos())
		--print(self:GetPos())
		
		
		local playerAngles = self:GetOwner():GetAngles()
		--print(self:GetOwner():GetAngles())
		--print(self:GetOwner():GetLocalAngles())
		--print(self:GetAngles())
		--print(self:GetLocalAngles())
		--self:SetAngles(Angle(-playerAngles.p, -playerAngles.y, -playerAngles.r))
		--print(self:GetAngles())
			
		-- If the player is holding down attack 2 don't rotate
		--[[if(pl:KeyDown(IN_ATTACK2) && pl:GetVelocity():Length() == 0) then
			self:SetLocalAngles(Angle(0, self.lastYaw, 0)) --only the yaw (rotation in z)
		else
			local angles = pl:GetAngles()
			self:SetLocalAngles(Angle(0,angles.y,0))
			self.lastYaw = angles.y
		end]]
	
		--print(self.lastYaw)
	end
	
end

function ENT:Think() 
	--self:CalculateBoxPosition()
end
