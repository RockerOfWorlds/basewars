surface.CreateFont( "Trebuchet_new", {

    font = "Trebuchet MS",
    size = 20

} )

local button_color = Color( 70, 70, 70 )
local button_hover_color = Color( 75, 75, 75 )

local function bwmenu( open_tab, open_tab2 )

    if IsValid( bwmenu_frame ) then bwmenu_frame:Close() return end

    local tabs = { { ["tab"] = "factions", ["name"] = "Factions", ["icon"] = "icon16/group.png" }, { ["tab"] = "raids", ["name"] = "Raids", ["icon"] = "icon16/error.png" }, { ["tab"] = "rules", ["name"] = "Rules", ["icon"] = "icon16/page_white.png", ["link"] = BaseWars.Config.RulesURL }, { ["tab"] = "guide", ["name"] = "Guide", ["icon"] = "icon16/note.png", ["link"] = "https://forums.notfound.tech/index.php?threads/english-basewars-guide.136/" } } -- { ["tab"] = "prestige", ["name"] = "Prestige", ["icon"] = "icon16/clock.png" }, { ["tab"] = "staff", ["name"] = "Staff", ["icon"] = "icon16/shield.png", ["link"] = "https://notfound.tech/staff" }, { ["tab"] = "leaderboard", ["name"] = "Leaderboard", ["icon"] = "icon16/award_star_gold_1.png", ["link"] = "https://notfound.tech/leaderboard" }, { ["tab"] = "settings", ["name"] = "Settings", ["icon"] = "icon16/cog.png" } }
    local buttons = { ["Factions"] = { { ["button"] = "create_faction", ["name"] = "Create Faction" }, { ["button"] = "join_faction", ["name"] = "Join Faction" }, { ["button"] = "leave_faction", ["name"] = "Leave Faction" }, { ["button"] = "invite_faction", ["name"] = "Invite To Faction" }, { ["button"] = "kick_faction", ["name"] = "Kick From Faction" } }, ["Raids"] = { { ["button"] = "start_raid", ["name"] = "Start Raid" }, { ["button"] = "concede_raid", ["name"] = "Concede Raid" } } }

    local me = LocalPlayer()

    local bwmenu_frame = vgui.Create( "DFrame" )
    bwmenu_frame:SetSize( 960, 540 )
    bwmenu_frame:SetTitle( "" )
    bwmenu_frame:SetDraggable( false )
    bwmenu_frame:MakePopup()

    function bwmenu_frame:OnKeyCodeReleased( key )

        if key == KEY_F3 then

            bwmenu_frame:Close()

        end

    end

    function bwmenu_frame:Paint( w, h )

        for i = 1, 5 do

            Derma_DrawBackgroundBlur( self, SysTime() )

        end

        draw.RoundedBox( 0, 0, 0, w, h, Color( 45, 45, 45, 225 ) )

    end

    local bwmenu_tabs = vgui.Create( "DPropertySheet", bwmenu_frame )
    bwmenu_tabs:Dock( FILL )
    bwmenu_tabs:SetPadding( 0 )

    -- function bwmenu_tabs:Paint( w, h )

    --     draw.RoundedBox( 0, 0, 0, w, h, Color( 85, 85, 85, 225 ) )

    -- end

    for i = 1, #tabs do

        local tab = tabs[i]["tab"]
        local tab_name = tabs[i]["name"]
        local tab_icon = tabs[i]["icon"]

        local tab_tab = vgui.Create( "DPanel" )

        function tab_tab:Paint( w, h )

            draw.RoundedBox( 0, 0, 0, w, h, Color( 40, 40, 40, 255 ) )

        end

        if tab == "factions" or tab == "raids" then

            local tab_list = vgui.Create( "DListView", tab_tab )
            tab_list:Dock( FILL )
            tab_list:DockMargin( 5, 5, 5, 40 )
            tab_list:SetMultiSelect( false )
            tab_list:AddColumn( "Name" )
            tab_list:AddColumn( "Faction" )

            tab_list.lines = {}

            function tab_list:OnRowSelected( id, panel )

                selected_line = panel:GetColumnText( 1 )
                faction_line = panel:GetColumnText( 2 )

            end

            function tab_list:Think()

                for k, v in pairs( player.GetHumans() ) do

                    local faction = v:GetFaction()

                    if v == LocalPlayer() then continue end

                    if faction == "" then

                        faction = "<NONE>"

                    end

                    if not self.lines[v] then

                        local line = self:AddLine( v:Nick(), faction )
                        self.lines[v] = line

                    end

                end

                for k, v in pairs( self.lines ) do

                    if not IsValid( v ) then

                        v:Remove()

                        continue

                    end

                    if not v.SetColumnText then

                        v:Remove()

                        continue

                    end

                    if not IsValid( k ) then

                        local id = v:GetID()

                        self:RemoveLine( id )
                        self.lines[k] = nil

                        continue

                    end

                    local faction = k:GetFaction()

                    if faction == "" then

                        faction = "<NONE>"

                    end

                    v:SetColumnText( 1, k:Nick() )
                    v:SetColumnText( 2, faction )

                end

            end

            local function GetPlayer( t )

                for k, v in next, player.GetAll() do

                    if v:Nick() == t then

                        return v

                    end

                end

                return false

            end

            if tab == "factions" then

                local b = 1

                for a = 1, #buttons["Factions"] do

                    local button = buttons["Factions"][a]["button"]
                    local button_name = buttons["Factions"][a]["name"]

                    local w = 5.376

                    if a >= 2 then

                        w = w + ( 190 * b )

                        b = b + 1

                    end

                    local button_button = vgui.Create( "DButton", tab_tab )
                    button_button:SetSize( 180, 34 )
                    button_button:SetPos( w, 448.74 )
                    button_button:SetText( button_name )
                    button_button:SetTextColor( color_white )

                    if button_name == "Create Faction" then

                        button_button.DoClick = function()

                            local button_name_frame = vgui.Create( "DFrame" )
                            button_name_frame:SetSize( 550, 250 )
                            button_name_frame:Center()
                            button_name_frame:SetTitle( "" )
                            button_name_frame:MakePopup()

                            local button_name_color_cube_color = Color( 45, 45, 45, 150 )

                            button_name_frame.Paint = function( self, w, h )

                                draw.RoundedBox( 0, 0, 0, w, h, Color( 45, 45, 45, 150 ) )

                                draw.RoundedBox( 0, 100, 200, 200, 40, button_name_color_cube_color )

                            end

                            local button_name_label = vgui.Create( "DLabel", button_name_frame )
                            button_name_label:SetFont( "Trebuchet18" )
                            button_name_label:SetText( "Enter the information below and maybe choose a color to create your faction!" )
                            button_name_label:SetBright( true )
                            button_name_label:SizeToContents()
                            button_name_label:SetPos( 0, 25 )
                            button_name_label:CenterHorizontal()
                            button_name_label:SizeToContents()

                            local button_name_rgb_picker = vgui.Create( "DRGBPicker", button_name_frame )
                            button_name_rgb_picker:SetPos( 500, 50 )
                            button_name_rgb_picker:SetSize( 40, 200 )

                            local button_name_color_cube = vgui.Create( "DColorCube", button_name_frame )
                            button_name_color_cube:SetPos( 380, 50 )
                            button_name_color_cube:SetSize( 100, 100 )

                            function button_name_rgb_picker:OnChange( col )

                                local h = ColorToHSV( col )
                                local _, s, v = ColorToHSV( button_name_color_cube:GetRGB() )

                                col = HSVToColor( h, s, v )
                                button_name_color_cube:SetColor( col )

                                button_name_color_cube_color = col

                            end

                            function button_name_color_cube:OnUserChanged( col )

                                button_name_color_cube_color = col

                            end

                            local button_name_faction = vgui.Create( "DTextEntry", button_name_frame )
                            button_name_faction:SetPos( 50, 50 )
                            button_name_faction:SetSize( 310, 20 )
                            button_name_faction:SetPlaceholderText( "Enter the name of your faction here!" )

                            local button_name_text = vgui.Create( "DTextEntry", button_name_frame )
                            button_name_text:SetPos( 50, 75 )
                            button_name_text:SetSize( 310, 20 )
                            button_name_text:SetPlaceholderText( "Enter the password of your faction here!" )

                            local button_name_confirm = vgui.Create( "DButton", button_name_frame )
                            button_name_confirm:SetPos( 50, 100 )
                            button_name_confirm:SetSize( 150, 40 )
                            button_name_confirm:SetText( "Create Faction!" )
                            button_name_confirm:SetTextColor( color_white )


                            button_name_confirm.DoClick = function()

                                local name, pw = string.Trim( button_name_faction:GetValue() ), string.Trim( button_name_text:GetValue() )

                                if #pw < 5 or #name < 5 then Derma_Message( "You're password & faction name must contain at least 5 characters!", "FACTION NOTICE", "OK" ) return end

                                me:CreateFaction( name, ( #pw >= 5 and pw ), button_name_color_cube:GetRGB() )

                                button_name_frame:Close()

                            end

                            function button_name_confirm:Think()

                                if not IsValid( bwmenu_frame ) then

                                    button_name_frame:Close()

                                end

                            end

                            function button_name_confirm:Paint( w, h )

                                local hover_color

                                if self.Hovered then hover_color = button_hover_color else hover_color = button_color end

                                draw.RoundedBox( 10, 0, 0, w, h, hover_color )

                            end

                            local button_name_cancel = vgui.Create( "DButton", button_name_frame )
                            button_name_cancel:SetPos( 210, 100 )
                            button_name_cancel:SetSize( 150, 40 )
                            button_name_cancel:SetText( "Cancel!" )
                            button_name_cancel:SetTextColor( color_white )

                            button_name_cancel.DoClick = function()

                                button_name_frame:Close()

                            end

                            function button_name_cancel:Paint( w, h )

                                local hover_color

                                if self.Hovered then hover_color = button_hover_color else hover_color = button_color end

                                draw.RoundedBox( 10, 0, 0, w, h, hover_color )

                            end

                        end

                    elseif button_name == "Join Faction" then

                        button_button.DoClick = function()

                            if faction_line == nil then faction_line = "" return end

                            if not me:InFaction() then

                                local button_name_frame = vgui.Create( "DFrame" )
                                button_name_frame:SetSize( 400, 150 )
                                button_name_frame:Center()
                                button_name_frame:SetTitle( "" )
                                button_name_frame:MakePopup()

                                button_name_frame.Paint = function( self, w, h )

                                    draw.RoundedBox( 0, 0, 0, w, h, Color( 45, 45, 45, 150 ) )

                                end

                                function button_name_frame:Think()

                                    if not IsValid( bwmenu_frame ) then

                                        button_name_frame:Close()

                                    end

                                end

                                button_name_label = vgui.Create( "DLabel", button_name_frame )
                                button_name_label:SetFont( "Trebuchet18" )
                                button_name_label:SetText( "Enter the password to join the faction!" )
                                button_name_label:SetBright( true )
                                button_name_label:SizeToContents()
                                button_name_label:SetPos( 0, 25 )
                                button_name_label:CenterHorizontal()

                                button_name_faction = vgui.Create( "DTextEntry", button_name_frame )
                                button_name_faction:SetPos( 50, 50 )
                                button_name_faction:SetSize( 310, 20 )
                                button_name_faction:SetPlaceholderText( "Enter the faction name or select the faction from the menu!" )

                                button_name_text = vgui.Create( "DTextEntry", button_name_frame )
                                button_name_text:SetPos( 50, 75 )
                                button_name_text:SetSize( 310, 20 )
                                button_name_text:SetPlaceholderText( "Enter the password to join the faction here!" )

                                if faction_line ~= "<NONE>" then

                                    button_name_faction:SetValue( faction_line )

                                end

                                button_name_confirm = vgui.Create( "DButton", button_name_frame )
                                button_name_confirm:SetPos( 50, 100 )
                                button_name_confirm:SetSize( 150, 40 )
                                button_name_confirm:SetText( "Join faction!" )
                                button_name_confirm:SetTextColor( color_white )

                                button_name_confirm.DoClick = function()

                                    if me:InRaid() then return end

                                    local name, pw = string.Trim( button_name_faction:GetValue() ), string.Trim( button_name_text:GetValue() )

                                    me:JoinFaction( name, ( #pw > 0 and pw ), true )

                                    button_name_frame:Close()

                                end

                                function button_name_confirm:Paint( w, h )

                                    local hover_color

                                    if self.Hovered then hover_color = button_hover_color else hover_color = button_color end

                                    draw.RoundedBox( 10, 0, 0, w, h, hover_color )

                                end

                                button_name_cancel = vgui.Create( "DButton", button_name_frame )
                                button_name_cancel:SetPos( 210, 100 )
                                button_name_cancel:SetSize( 150, 40 )
                                button_name_cancel:SetText( "Cancel!" )
                                button_name_cancel:SetTextColor( color_white )

                                button_name_cancel.DoClick = function()

                                    button_name_frame:Close()

                                end

                                function button_name_cancel:Paint( w, h )

                                    local hover_color

                                    if self.Hovered then hover_color = button_hover_color else hover_color = button_color end

                                    draw.RoundedBox( 10, 0, 0, w, h, hover_color )

                                end

                            elseif me:InFaction() then

                                Derma_Message( "You're already in a faction!", "Faction Notice", "OK" )

                            end

                        end

                    elseif button_name == "Leave Faction" then

                        button_button.DoClick = function()

                            if not me:InFaction() then

                                Derma_Message( "You're not in a faction!", "Faction Notice", "OK" )

                            elseif me:InFaction() then

                                local button_name_frame = vgui.Create( "DFrame" )
                                button_name_frame:SetSize( 400, 150 )
                                button_name_frame:Center()
                                button_name_frame:SetTitle( "" )
                                button_name_frame:MakePopup()

                                button_name_frame.Paint = function( self, w, h )

                                    draw.RoundedBox( 0, 0, 0, w, h, Color( 45, 45, 45, 150 ) )

                                end

                                function button_name_frame:Think()

                                    if not IsValid( bwmenu_frame ) then

                                        button_name_frame:Close()

                                    end

                                end

                                local button_name_label = vgui.Create( "DLabel", button_name_frame )
                                button_name_label:SetFont( "Trebuchet18" )
                                button_name_label:SetText( "Are you sure you want to leave or disband this faction?" )
                                button_name_label:SetBright( true )
                                button_name_label:SizeToContents()
                                button_name_label:Center()

                                local button_name_confirm = vgui.Create( "DButton", button_name_frame )
                                button_name_confirm:SetPos( 50, 100 )
                                button_name_confirm:SetSize( 150, 40 )
                                button_name_confirm:SetText( "Yes, leave!" )
                                button_name_confirm:SetTextColor( color_white )

                                button_name_confirm.DoClick = function()

                                    me:LeaveFaction( true )

                                    button_name_frame:Close()

                                end

                                function button_name_confirm:Paint( w, h )

                                    local hover_color

                                    if self.Hovered then hover_color = button_hover_color else hover_color = button_color end

                                    draw.RoundedBox( 10, 0, 0, w, h, hover_color )

                                end

                                local button_name_cancel = vgui.Create( "DButton", button_name_frame )
                                button_name_cancel:SetPos( 210, 100 )
                                button_name_cancel:SetSize( 150, 40 )
                                button_name_cancel:SetText( "No, cancel!" )
                                button_name_cancel:SetTextColor( color_white )

                                button_name_cancel.DoClick = function()

                                    button_name_frame:Close()

                                end

                                function button_name_cancel:Paint( w, h )

                                    local hover_color

                                    if self.Hovered then hover_color = button_hover_color else hover_color = button_color end

                                    draw.RoundedBox( 10, 0, 0, w, h, hover_color )

                                end

                            end

                        end

                    elseif button_name == "Invite To Faction" then

                        button_button.DoClick = function()

                            if me:InFaction( me:GetFaction(), true ) then

                                net.Start( "InvitePlayerToFaction" )

                                    net.WriteString( selected_line )

                                net.SendToServer()

                            end

                        end

                    elseif button_name == "Kick From Faction" then

                        button_button.DoClick = function()

                            if me:InFaction( me:GetFaction(), true ) then

                                net.Start( "CheckPlayerBeforeKick" )

                                    net.WriteString( selected_line )

                                net.SendToServer()

                            end

                        end

                    end

                    function button_button:Paint( w, h )

                        local hover_color

                        if self.Hovered then hover_color = button_hover_color else hover_color = button_color end

                        draw.RoundedBox( 10, 0, 0, w, h, hover_color )

                    end

                end

            elseif tab == "raids" then

                local b = 1

                for a = 1, #buttons["Raids"] do

                    local button = buttons["Raids"][a]["button"]
                    local button_name = buttons["Raids"][a]["name"]

                    local w = 284.16

                    if a >= 2 then

                        w = w + ( 190 * b )

                        b = b + 1

                    end

                    local button_button = vgui.Create( "DButton", tab_tab )
                    button_button:SetSize( 180, 34 )
                    button_button:SetPos( w, 448.74 )
                    button_button:SetText( button_name )
                    button_button:SetTextColor( color_white )

                    if button_name == "Start Raid" then

                        button_button.DoClick = function()

                            me:StartRaid( GetPlayer( selected_line ) )

                        end

                    elseif button_name == "Concede Raid" then

                        button_button.DoClick = function()

                            me:ConceedRaid()

                        end

                    end

                    function button_button:Paint( w, h )

                        local hover_color

                        if self.Hovered then hover_color = button_hover_color else hover_color = button_color end

                        draw.RoundedBox( 10, 0, 0, w, h, hover_color )

                    end

                end

            end

        elseif tab == "rules" or tab == "guide" then

            local tab_html = vgui.Create( "DHTML", tab_tab )
            tab_html:Dock( FILL )
            tab_html:OpenURL( tabs[i]["link"] )

		end

        bwmenu_tabs:AddSheet( tab_name, tab_tab, tab_icon )

    end

    for k, v in ipairs( bwmenu_tabs.Items ) do

        if not v.Tab then continue end

        v.Tab.Paint = function( self, w, h )

            draw.RoundedBox( 0, 0, 0, w, h, Color( 85, 85, 85, 225 ) )

        end

    end

    local function inQuad( fraction, beginning, change )

        return change * ( fraction ^ 2 ) + beginning

    end

    local bwmenu_anim = Derma_Anim( "EaseInQuad", bwmenu_frame, function( pnl, anim, delta, data )

        pnl:SetPos( 0, inQuad( delta, -ScrH() / 2, ScrH() / 2 * 2 - ScrH() * 0.25 ) )
        pnl:CenterHorizontal()

    end )

    if open_tab == nil then

        bwmenu_anim:Start( 0.25 )

    end

    bwmenu_frame.Think = function( self )

        if bwmenu_anim:Active() then

            bwmenu_anim:Run()

        end

    end

    if open_tab ~= nil then

        bwmenu_frame:Center()
        bwmenu_tabs:SetActiveTab( bwmenu_tabs:GetItems()[open_tab].Tab )

    end

end

hook.Add( "PlayerButtonUp", "bwmenu_toggle", function( ply, button )

    if button == KEY_F3 and IsFirstTimePredicted() then

        bwmenu()

    end

end )