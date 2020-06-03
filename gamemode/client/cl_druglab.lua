local grayTop       = Color(128, 128, 128, 250)
local grayBottom    = Color(96, 96, 96, 250)
local new_frame_top_color = Color(65, 65, 65, 250)
local new_frame_bottom_color = Color(40, 40, 40, 250)


surface.CreateFont("DrugLab.GUI", {
    font = "Roboto",
    size = 24,
    weight = 800,
})

local function RequestCook( ent, drug )
    net.Start( "BaseWars.DrugLab.Menu" )
        net.WriteEntity( ent )
        net.WriteString( drug )
    net.SendToServer()
end

local function Menu( ent )
    local Frame = vgui.Create( "DFrame" )
    Frame:SetSize( 550, 680 )
    Frame:Center()
    Frame:SetTitle( "Drug Lab" )
    Frame:MakePopup()

    function Frame:Paint(w, h)

        draw.RoundedBoxEx(8, 0, 0, w, 24, new_frame_top_color, true, true, false, false)
        draw.RoundedBox(0, 0, 24, w, h - 24, new_frame_bottom_color)

    end

    local List = vgui.Create( "DPanelList", Frame )
    List:EnableHorizontal(false)
    List:EnableVerticalScrollbar(true)
    List:SetPadding(5)
    List:SetSpacing(5)
    List:Dock(FILL)

    for k, v in pairs( BaseWars.Config.Drugs ) do
        if k == "CookTime" then continue end
        local Panel = vgui.Create( "DPanel", List )
        Panel:SetSize( 100, 75 )

        function Panel:Paint( w, h )

            draw.RoundedBox( 10, 0, 0, w, h, new_frame_top_color)

        end

        local description

        if k == "DoubleJump" then

            description = "Allows you to jump again in the air."

        elseif k == "Steroid" then

            description = "Increases movement speed."

        elseif k == "Regen" then

            description = "You will regenerate HP and armor."

        elseif k == "Adrenaline" then

            description = "Your max health will be increased."

        elseif k == "PainKiller" then

            description = "You will experience less damage."

        elseif k == "Rage" then

            description = "You will deal more damage."

        elseif k == "Shield" then

            description = "You will survive one lethal/killing blow."

        elseif k == "Antidote" then

            description = "Reduces the effect of acid and freezing towers."

        end

        local Label = vgui.Create( "DLabel", Panel )
        Label:SetPos( 80, 5 )
        Label:SetFont( "DrugLab.GUI" )
        Label:SetTextColor( Color( 130, 130, 130 ) )
        Label:SetText( k .. " - Cook Time: " .. string.FormattedTime( BaseWars.Config.Drug.CookTime, "%02i:%02i:%02i" ) )
        Label:SizeToContents()

        local DescriptionLabel = vgui.Create( "DLabel", Panel )
        DescriptionLabel:SetPos( 80, 25 )
        DescriptionLabel:SetFont( "DrugLab.GUI" )
        DescriptionLabel:SetTextColor( Color( 130, 130, 130 ) )
        DescriptionLabel:SetText( description )
        DescriptionLabel:SizeToContents()

        local Item = vgui.Create( "SpawnIcon", Panel )
        Item:SetPos( 6, 6 )
        Item:SetSize( 64, 64 )
        Item:SetModel( "models/props_junk/PopCan01a.mdl" )
        Item:SetTooltip( "Drug: " .. k )

        function Item:DoClick()
            RequestCook( ent, k )

            Frame:Close()
        end

        List:AddItem( Panel )
    end
end

net.Receive( "BaseWars.DrugLab.Menu", function( len )
    Menu( net.ReadEntity() )
end )