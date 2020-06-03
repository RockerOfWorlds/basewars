TOOL.Category = "BaseWars"
TOOL.Name = "#tool.capacity.name"

local function tool_gun( tr, tool_type, tool )

	local ply = tool:GetOwner()
	local trace = ply:GetEyeTrace().Entity

	if not IsValid( trace ) or trace:IsPlayer() then return end

	if string.StartWith( trace:GetClass(), "bw_" ) or trace:GetClass() == "prop_physics" then

		if CLIENT then

			net.Start( "BaseWarsToolGun" )

				net.WriteEntity( trace )
				net.WriteString( "Capacity" )
				net.WriteString( tool_type )

			net.SendToServer()

		end

	end

	return true

end

function TOOL:LeftClick( tr )

	if not IsFirstTimePredicted() then return end

	tool_gun( tr, "Heavy", self )

	return true

end

function TOOL:RightClick( tr )

	if not IsFirstTimePredicted() then return end

	tool_gun( tr, "Capacity", self )

	return true

end

if CLIENT then

	TOOL.Information = {

		{ name = "left" },
		{ name = "right" },

	}

	language.Add( "tool.capacity.name", "Capacity" )
	language.Add( "tool.capacity.desc", "Allows you to use/add heavy capacity/capacity on printers." )
	language.Add( "tool.capacity.left", "Use/Add Heavy Capacity printers." )
	language.Add( "tool.capacity.right", "Use/Add Capacity printers." )

end