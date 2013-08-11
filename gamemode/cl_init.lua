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


-- Sets the local blind variable to be used in CalcView.
function SetBlind(um)

	blind = um:ReadBool()

end
usermessage.Hook("SetBlind", SetBlind)


-- Sets the player hull and the health status.
function SetHull(um)

	hull_xy 	= um:ReadLong()
	hull_z 		= um:ReadLong()
	new_health 	= um:ReadShort()
	
	print ( new_health )
	print ( hull_xy )
	print ( hull_z )
	
	print( LocalPlayer() )

	if IsValid(LocalPlayer()) then
		LocalPlayer():SetHull(Vector(hull_xy * -1, hull_xy * -1, 0), Vector(hull_xy, hull_xy, hull_z))
		LocalPlayer():SetHullDuck(Vector(hull_xy * -1, hull_xy * -1, 0), Vector(hull_xy, hull_xy, hull_z))
		LocalPlayer():SetHealth(new_health)
	else
		print("Not valid")
	end

end
usermessage.Hook("SetHull", SetHull)

// Decides where the player view should be.
--[[function GM:CalcView(pl, origin, angles, fov)

	// Create empty array to store view information in.
	local view = {} 

	// If the player is supposed blind, set their view off the map.
	if blind then

		view.origin = Vector(20000, 0, 0)
		view.angles = Angle(0, 0, 0)
		view.fov 	= fov

		return view

	end

	// Set view variables to given function arguements.
 	view.origin = origin 
 	view.angles	= angles 
 	view.fov 	= fov 
 	
 	// If the player is a Prop, we know they won't have a weapon so just set their view to third person.
	if pl:Team() == TEAM_PROPS && pl:Alive() then

		view.origin = origin + Vector(0, 0, hull_z - 60) + (angles:Forward() * -80)

	else

		// Give the active weapon a go at changing the viewmodel position.
	 	local wep = pl:GetActiveWeapon() 

	 	if wep && wep != NULL then 

			// Try ViewModelPosition first.
	 		local func = wep.GetViewModelPosition 

	 		if func then 

	 			view.vm_origin, view.vm_angles = func(wep, origin * 1, angles * 1)

	 		end

			// But let the weapon's CalcView override.
	 		local func = wep.CalcView 

	 		if func then 

				view.origin, view.angles, view.fov = func(wep, pl, origin * 1, angles * 1, fov)

	 		end 

	 	end

	end
 	
 	return view

end]]