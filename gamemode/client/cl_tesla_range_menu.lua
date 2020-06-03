local main_color = Color( 45, 45, 45, 200 )
local text_color = Color( 255, 255, 255 )
local hover_text_color = Color( 255, 255, 255 )
local button_color = Color( 45, 45, 45, 175 )
local hover_button_color = Color( 85, 85, 85 )

surface.CreateFont( "range_labels", {

	font = "Roboto",
	size = 18

} )

function TeslaRangeMenu( ply )

	if IsValid( tesla_range_menu ) then return end

	local ent = ply:GetEyeTrace().Entity

	if not IsValid( ent ) or not ent.IsAbleToSetRange then return end

	local tesla_range = ent:GetRadius()

	local tesla_range_menu = vgui.Create( "DFrame" )
	tesla_range_menu:SetSize( 500, 220 )
	tesla_range_menu:SetTitle( "" )
	tesla_range_menu:SetDraggable( false )
	tesla_range_menu:Center()
	tesla_range_menu:MakePopup()
	tesla_range_menu:ShowCloseButton( false )

	tesla_range_menu.Paint = function( s, w, h )

		draw.RoundedBox( 5, 2, 2, w, h, main_color )

	end

	local tesla_range_label = vgui.Create( "DLabel", tesla_range_menu )
	tesla_range_label:SetPos( 130, 50 )
	tesla_range_label:SetFont( "range_labels" )
	tesla_range_label:SetText( "Max Range - 300" )
	tesla_range_label:SetTextColor( text_color )
	tesla_range_label:SizeToContents()
	tesla_range_label:CenterHorizontal()

	local tesla_range_label_2

	if tesla_range >= 1 then

		tesla_range_label_2 = vgui.Create( "DLabel", tesla_range_menu )
		tesla_range_label_2:SetPos( 270, 25 )
		tesla_range_label_2:SetFont( "range_labels" )
		tesla_range_label_2:SetText( "Current Range - " .. tesla_range )
		tesla_range_label_2:SetTextColor( text_color )
		tesla_range_label_2:SizeToContents()
		tesla_range_label_2:CenterHorizontal()

	end

	local tesla_range_slider = vgui.Create( "DNumSlider", tesla_range_menu )
	tesla_range_slider:SetPos( 0, 50 )
	tesla_range_slider:SetSize( 350, 100 )
	tesla_range_slider:SetMinMax( 1, 300 )
	tesla_range_slider:SetDecimals( 0 )
	tesla_range_slider:SetValue( tesla_range )
	tesla_range_slider.TextArea:SetPos( 400 )
	tesla_range_slider.TextArea:Dock( NODOCK )

	function tesla_range_slider:OnValueChanged( value )

		tesla_range = math.Round( value )

		if tesla_range >= 1 then
			
			tesla_range_label_2:SetText( "Current Range - " .. tostring( tesla_range ) )

		end

	end

	telsa_range_done = vgui.Create( "DButton", tesla_range_menu )
	telsa_range_done:SetText( "Done" )
	telsa_range_done:SetTextColor( text_color )
	telsa_range_done:SetPos( 250, 150 )
	telsa_range_done:SetSize( 150, 25 )
	telsa_range_done:CenterHorizontal()

	telsa_range_done.Paint = function( s, w, h )

		if not telsa_range_done.Hovered then

			telsa_range_done:SetTextColor( text_color )
			draw.RoundedBox( 10, 0, 0, w, h, button_color )

		else

			telsa_range_done:SetTextColor( hover_text_color )
			draw.RoundedBox( 10, 0, 0, w, h, hover_button_color )

		end

	end

	telsa_range_done.DoClick = function()

		net.Start( "SetRange" )

			net.WriteEntity( ent )
			net.WriteString( tostring( tesla_range ) )

		net.SendToServer()

		tesla_range_menu:Remove()

	end


end

concommand.Add( "range_open_menu", TeslaRangeMenu )