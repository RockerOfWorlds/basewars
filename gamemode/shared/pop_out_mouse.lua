if SERVER then

	util.AddNetworkString( "PopOutMouse" )

	hook.Add( "PlayerButtonDown", "pop_out_mouse", function( ply, key )

		if ( key == KEY_F2 and ply:GetNWBool( "IsMousePoppedOut" ) ~= true and ply:GetNWBool( "IsMousePoppedOut" ) ~= false ) then

			ply:SetNWBool( "IsMousePoppedOut", false )

		end

		if ( key == KEY_F2 and not ply:GetNWBool( "IsMousePoppedOut" ) ) then

			ply:SetNWBool( "IsMousePoppedOut", true )

		elseif ( key == KEY_F2 and ply:GetNWBool( "IsMousePoppedOut" ) ) then

			ply:SetNWBool( "IsMousePoppedOut", false )

		end

		if ( key == KEY_F2 ) then

			net.Start( "PopOutMouse" )

				net.WriteBool( ply:GetNWInt( "IsMousePoppedOut" ) )

			net.Send( ply )

		end


	end )

end

if CLIENT then

	net.Receive( "PopOutMouse", function( len, ply ) 

		local ShouldPopOutMouse = net.ReadBool()

		gui.EnableScreenClicker( ShouldPopOutMouse )

	end )

end