local function FactionInviteMenu( ply )

	local faction = net.ReadString()
	local inviter = net.ReadEntity()
	if IsValid( faction_invite_menu ) then return end
	local new_color_scheme_main = Color( 26, 26, 29 )
	local text_color = Color( 95, 102, 114 )
	local text_hover_color = Color( 209, 209, 209 )
	local button_color = Color( 209, 209, 209 )
	local hover_color = Color( 89, 89, 89 )

	local faction_invite_menu = vgui.Create( "DFrame" )
	faction_invite_menu:SetSize( 650, 350 )
	faction_invite_menu:SetTitle( "Faction Invite" )
	faction_invite_menu:Center()
	faction_invite_menu:MakePopup()
	faction_invite_menu:ShowCloseButton( false )
	faction_invite_menu:SetDraggable( true )
	faction_invite_menu.Paint = function( s, w, h )

		draw.RoundedBox( 10, 0, 0, w, h, new_color_scheme_main )
		draw.RoundedBox( 10, 2, 2, w - 4, h - 4, new_color_scheme_main )

	end

	local faction_invite_label = vgui.Create( "DLabel", faction_invite_menu )
	faction_invite_label:SetPos( 80, 89 )
	faction_invite_label:SetText( "You have recieved an invite to join a faction named " .. faction .. " would you like to join this faction?" )
	faction_invite_label:SetTextColor( text_color )
	faction_invite_label:SizeToContents()

	if inviter:Nick() == nil then faction_invite_menu:Close() end

	local faction_inviter = vgui.Create( "DLabel", faction_invite_menu )
	faction_inviter:SetPos( 80, 100 )
	faction_inviter:SetText( "The one who invited you is " .. inviter:Nick() .. "." )
	faction_inviter:SetTextColor( text_color )
	faction_inviter:SizeToContents()

	local faction_invite_yes = vgui.Create( "DButton", faction_invite_menu )
	faction_invite_yes:SetText( "Accept Faction Invite" )
	faction_invite_yes:SetTextColor( text_color )
	faction_invite_yes:SetPos( 125, 200 )
	faction_invite_yes:SetSize( 150, 50 )
	faction_invite_yes.Paint = function( s, w, h )

		if not faction_invite_yes.Hovered then

			faction_invite_yes:SetTextColor(text_color)
			draw.RoundedBox( 10, 0, 0, w, h, button_color )

		else

			faction_invite_yes:SetTextColor( text_hover_color )
			draw.RoundedBox( 10, 0, 0, w, h, hover_color )

		end

	end

	faction_invite_yes.DoClick = function()


		net.Start( "InvitePlayerJoinFaction" )

			net.WriteString( faction )

		net.SendToServer()

		faction_invite_menu:Remove()

	end

	local faction_invite_no = vgui.Create( "DButton", faction_invite_menu )
	faction_invite_no:SetText( "Deny Faction Invite" )
	faction_invite_no:SetTextColor( text_color )
	faction_invite_no:SetPos( 350, 200 )
	faction_invite_no:SetSize( 150, 50 )
	faction_invite_no.Paint = function( s, w, h )

		if not faction_invite_no.Hovered then

			faction_invite_no:SetTextColor(text_color)
			draw.RoundedBox( 10, 0, 0, w, h, button_color )

		else

			faction_invite_no:SetTextColor( text_hover_color )
			draw.RoundedBox( 10, 0, 0, w, h, hover_color )

		end

	end

	faction_invite_no.DoClick = function()

		faction_invite_menu:Remove()

	end

end

net.Receive( "InvitePlayer", FactionInviteMenu )