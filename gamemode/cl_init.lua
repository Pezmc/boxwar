-- This file is only run on the client
include("sh_init.lua")

-- Called immediately after starting the gamemode.
function Initialize()
	hull_z = 80
end
hook.Add("Initialize", "PH_Initialize", Initialize)

-- Resets the player hull.
function ResetHull(um)

	if LocalPlayer() && LocalPlayer():IsValid() then

		LocalPlayer():ResetHull()
		hull_z = 80

	end

end
usermessage.Hook("ResetHull", ResetHull)

-- Disable crouching on client side
hook.Add("PlayerBindPress", "AntiCrouch", function(ply, bind)
      if (string.find(bind, "+duck")) then return true end
end )

-- Sets the player hull and the health status.
function UserSetHull(um)
	
	hull_xy 	= um:ReadLong()
	hull_z 		= um:ReadLong()
	SetHull(hull_xy, hull_z)
	
end
usermessage.Hook("SetHull", UserSetHull)

function SetHull(hull_xy, hull_z)

	if IsValid(LocalPlayer()) then
		LocalPlayer():SetHull(Vector(hull_xy * -1, hull_xy * -1, 0), Vector(hull_xy, hull_xy, hull_z))
		LocalPlayer():SetHullDuck(Vector(hull_xy * -1, hull_xy * -1, 0), Vector(hull_xy, hull_xy, hull_z))
		print("Set hull")
	else
		print("Player not valid yet, can't set hull, using a timer")
		timer.Create("setHullAgain", 1, 1, function() 
			SetHull(hull_xy, hull_z)
		end)
	end

end

function GM:PlayerSpawn() 
	local oldhands = ply:GetHands()
	if ( IsValid( oldhands ) ) then oldhands:Remove() end

	local hands = ents.Create( "gmod_hands" )
	if ( IsValid( hands ) ) then
	    ply:SetHands( hands )
	    hands:SetOwner( ply )
	
	    -- Which hands should we use?
	    local cl_playermodel = ply:GetInfo( "cl_playermodel" )
	    local info = player_manager.TranslatePlayerHands( cl_playermodel )
	    if ( info ) then
	      hands:SetModel( info.model )
	      hands:SetSkin( info.skin )
	      hands:SetBodyGroups( info.body )
	    end
	
	    -- Attach them to the viewmodel
	    local vm = ply:GetViewModel( 0 )
	    hands:AttachToViewmodel( vm )
	
	    vm:DeleteOnRemove( hands )
	    ply:DeleteOnRemove( hands )
	
	    hands:Spawn()
    end
end

function GM:PostDrawViewModel( vm, ply, weapon )
   if weapon.UseHands or (not weapon:IsScripted()) then
      local hands = LocalPlayer():GetHands()
      if IsValid(hands) and not ply:KeyDown(IN_ATTACK2) then
      	hands:DrawModel()
      end
   end
end

-- Decides where the player view should be.
function GM:CalcView(pl, origin, angles, fov)
	local view = {} 

 	view.origin = origin 
 	view.angles	= angles 
 	view.fov = fov 
 	
 	-- Give the active weapon a go at changing the viewmodel position 
	if (pl:KeyDown(IN_ATTACK2)) then
		pl:DrawViewModel(false)
		view.origin = origin + Vector(0, 0, 80 - 60) + (angles:Forward() * -80)
	else
		pl:DrawViewModel(true)
	 	local wep = pl:GetActiveWeapon() 
	 	if wep && wep != NULL then 
	 		local func = wep.GetViewModelPosition 
	 		if func then 
	 			view.vm_origin, view.vm_angles = func(wep, origin*1, angles*1)
	 		end

	 		local func = wep.CalcView 
	 		if func then 
	 			view.origin, view.angles, view.fov = func(wep, pl, origin*1, angles*1, fov)
	 		end 
	 	end
	 	
	 	--[[if(pl:Alive()) then
	 		view.origin = view.origin - Vector(0, 0, 40)
	 	end]]
	end
 	
 	return view 
end