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


-- Sets the player hull and the health status.
function SetHull(um)

	hull_xy 	= um:ReadLong()
	hull_z 		= um:ReadLong()
	new_health 	= um:ReadShort()

	--[[if IsValid(LocalPlayer()) then
		LocalPlayer():SetHull(Vector(hull_xy * -1, hull_xy * -1, 0), Vector(hull_xy, hull_xy, hull_z))
		LocalPlayer():SetHullDuck(Vector(hull_xy * -1, hull_xy * -1, 0), Vector(hull_xy, hull_xy, hull_z))
		LocalPlayer():SetHealth(new_health)
	else
		print("Player not valid yet, can't set hull")
	end]]

end
usermessage.Hook("SetHull", SetHull)

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

function GM:PlayerSpawn() 
	if ( weapon.UseHands || !weapon:IsScripted() ) then
    	local hands = LocalPlayer():GetHands()
    	if ( IsValid( hands ) ) then hands:DrawModel() end
    end	
end

-- Decides where the player view should be.
--[[function GM:CalcView(pl, origin, angles, fov)

	-- Create empty array to store view information in.
	local view = {} 

	--[[ If the player is supposed blind, set their view off the map.
	if blind then

		view.origin = Vector(20000, 0, 0)
		view.angles = Angle(0, 0, 0)
		view.fov 	= fov

		return view

	end

	-- Set view variables to given function arguements.
 	view.origin = origin 
 	view.angles	= angles 
 	view.fov 	= fov 
 	
 	-- Change the view
	view.origin = origin + Vector(0, 0, hull_z - 20) --+ (angles:Forward() * -80)
 	
 	return view

end]]