function DrawAvatar()
AvatarShouldDraw = 1
end
hook.Add("Initialize", "Avatardeestim", DrawAvatar)

function HUD()
	local User = LocalPlayer()
	if !User:Alive() then return end
	if(User:GetActiveWeapon() == NULL or User:GetActiveWeapon() == "Camara") then return end
	
	-- Textures - relative to the folder "materials"
	-- local HUD_Texture = surface.GetTextureID("boxwar_hud/stats_hud")
	local HUD_Texture = Material("boxwar_hud/stats_hud.png", "nocull")
	
	-- local HUD_Texture_TOP = surface.GetTextureID("boxwar_hud/stats_hud_top")
	local HUD_Texture_TOP = Material("boxwar_hud/stats_hud_top.png", "nocull")
	
	local HUD_Texture_Icon = Material("boxwar_hud/stats_hud_icon.png", "nocull")
	-- local HUD_Texture_Icon = surface.GetTextureID("boxwar_hud/stats_hud_icon")

	-- local HUD_Texture_Ammo = surface.GetTextureID("boxwar_hud/ammo_hud_top")
	local HUD_Texture_Ammo = Material("boxwar_hud/ammo_hud_top.png", "nocull")

	-- local HUD_Texture_Hora = surface.GetTextureID("boxwar_hud/hud_clock")
	
	local StatsHUDwidth 	= 200
	local StatsHUDheight 	= 100
	local StatsHUDposH	= ScrH() - 120
	local StatsHUDposW	= 20
	
	local clockHUDwidth 	= 80
	local clockHUDheight 	= 80
	local clockHUDposH	= ScrH() - 63
	local clockHUDposW	= 80
	
	local AmmoHUDwidth 	= 200
	local AmmoHUDheight 	= 100
	local AmmoHUDposH	= ScrH() - 120
	local AmmoHUDposW	= ScrW() - 220
	
	local CurrentHP = math.Round(User:Health())
	local CurrentArmor = math.Round(User:Armor())
	//local TheTime = os.date("%I:%M:%S %p")
	
	-- Draw the hud
	surface.SetDrawColor( 255, 255, 255, 255 )
	-- surface.SetTexture( HUD_Texture )
	surface.SetMaterial( HUD_Texture )
	surface.DrawTexturedRect( StatsHUDposW, StatsHUDposH, StatsHUDwidth, StatsHUDheight )
	
	draw.RoundedBox(0, StatsHUDposW + 75, StatsHUDposH + 32, math.Clamp(CurrentHP, 0, 100), 15, Color(255, 0, 0, 255))
	draw.RoundedBox(0, StatsHUDposW + 75, StatsHUDposH + 52, math.Clamp(CurrentArmor, 0, 100), 15, Color(0, 110, 255, 225))
	
	surface.SetDrawColor( 255, 255, 255, 255 )
	-- surface.SetTexture( HUD_Texture_TOP )
	surface.SetMaterial( HUD_Texture_TOP )
	surface.DrawTexturedRect( StatsHUDposW, StatsHUDposH, StatsHUDwidth, StatsHUDheight )
	surface.DrawTexturedRect( StatsHUDposW, StatsHUDposH, StatsHUDwidth, StatsHUDheight )
	
	surface.SetDrawColor( 255, 255, 255, 255 )
	-- surface.SetTexture( HUD_Texture_Icon )
	surface.SetMaterial( HUD_Texture_Icon )
	surface.DrawTexturedRect( StatsHUDposW, StatsHUDposH, StatsHUDwidth, StatsHUDheight )
	
	//surface.SetDrawColor( 255, 255, 255, 255 )
	//surface.SetTexture( HUD_Texture_Hora )
	//surface.DrawTexturedRect( clockHUDposW, clockHUDposH, clockHUDwidth, clockHUDheight )
	
	-- Create fonts
	fontData = {
		font = "arial",
		size = 16,
		weight = 400,
		antialias = true,
		additive = true
	}
	
	surface.CreateFont( "adrys_HUD_Font", fontData)
	fontData.size = 11
	surface.CreateFont( "adrys_HUD_Font2", fontData )
	
	-- Draw the font on the scren
	draw.SimpleText(CurrentHP.."%" , "adrys_HUD_Font", StatsHUDposW + 124, StatsHUDposH + 39, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	draw.SimpleText(CurrentArmor.."%" , "adrys_HUD_Font", StatsHUDposW + 124, StatsHUDposH + 59, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	
	-- Draw the time
	//draw.SimpleText(TheTime, "adrys_HUD_Font2", StatsHUDposW + 100, StatsHUDposH + 99, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	
	if AvatarShouldDraw == 1 then
		local Avatar = vgui.Create("AvatarImage")
		Avatar:SetPos(StatsHUDposW + 8, ScrH() - 93)
		Avatar:SetSize(43, 43)
		Avatar:SetPlayer( LocalPlayer(), 43)	
		AvatarShouldDraw = 0
	end
end
hook.Add( "HUDPaint", "HUD", HUD )

-- Hide the HL2 hud
function hidehud(name)
    for k, v in pairs{"CHudHealth", "CHudBattery", "CHudSecondaryAmmo"} do
        if name == v then return false end
    end
end
hook.Add("HUDShouldDraw", "hidehud", hidehud)

local BlurX = CreateMaterial( "DamageEffect_X", "g_blurx", {
	[ "$basetexture" ] = "_rt_FullFrameFB",
	[ "$ignorez" ] = "1",
	[ "$additive"] = "1",
	[ "$size" ] = "1"
} )
local BlurY = CreateMaterial( "DamageEffect_Y", "g_blury", {
	[ "$basetexture" ] = "_rt_FullFrameFB",
	[ "$ignorez" ] = "1",
	[ "$additive"] = "1",
	[ "$size" ] = "1"
} )

--The file path is relative to the folder "materials"
--Pain = surface.GetTextureID( "boxwar_hud/screenpain" )
Pain = Material("boxwar_hud/screenpain.png", "nocull")

BlurX:SetTexture( "$basetexture", render.GetScreenEffectTexture() )
BlurY:SetTexture( "$basetexture", render.GetScreenEffectTexture() )

local function DrawBBlur( strength )

	render.UpdateScreenEffectTexture()

	BlurX:SetFloat( "$size", strength )
	BlurY:SetFloat( "$size", strength )
	
	render.SetMaterial( BlurX )
	render.DrawScreenQuad()
	render.SetMaterial( BlurY )
	render.DrawScreenQuad()
	
end

local ScreenThrob_NextThrob = 0
local ScreenThrob_Delay = 1.3
local ScreenThrob_Enable = true

CreateClientConVar( "efectodesangre", 1, false, false )
local function DoDamageEffect()
	if GetConVarNumber( "efectodesangre" ) == 1 and LocalPlayer():Alive() then
		local minStrength,maxStrength = 0,3
		
		local hp = math.Clamp( LocalPlayer():Health(), 0, 40 )
		
		if hp ~= 40 then
			local scale = 1 - ( hp / 40 )
			
			if ScreenThrob_NextThrob <= CurTime() then
				ScreenThrob_NextThrob = CurTime() + ScreenThrob_Delay
			end
			local throb = ScreenThrob_NextThrob - CurTime()
			local calcthrob = throb / 1.3
			
			local str = scale * ( 1 + calcthrob )
			str = math.Clamp( str, minStrength, maxStrength )
			DrawBBlur( str )
		end
	end
end
hook.Add( "RenderScreenspaceEffects", "RenderDamageEffect", DoDamageEffect )

local function DoDamageHUD()
	if LocalPlayer():Alive() then
		local hp = math.Clamp( LocalPlayer():Health(), 0, 40 )
		if hp ~= 40 then
			local mat_alpha = 1 - ( hp / 40 )
			
			surface.SetDrawColor( 255, 255, 255, mat_alpha * 255 )
			--surface.SetTexture( Pain )
			surface.SetMaterial( Pain )
			surface.DrawTexturedRect( 0, 0, ScrW(), ScrH() )
		end
	end
end
hook.Add( "HUDPaint", "RenderDamageEffect", DoDamageHUD )
