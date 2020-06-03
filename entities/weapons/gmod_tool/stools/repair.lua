TOOL.Category = "BaseWars"
TOOL.Name = "#tool.repair.name"

local function tool_gun( tr, tool_type, tool )

	local ply = tool:GetOwner()
	local trace = ply:GetEyeTrace().Entity

	if not IsValid( trace ) or trace:IsPlayer() then return end

	if string.StartWith( trace:GetClass(), "bw_" ) or trace:GetClass() == "prop_physics" then

		if CLIENT then

			net.Start( "BaseWarsToolGun" )

				net.WriteEntity( trace )
				net.WriteString( "Repair" )
				net.WriteString( tool_type )

			net.SendToServer()

		end

	end

	return true

end

function TOOL:LeftClick( tr )

	if not IsFirstTimePredicted() then return end

	tool_gun( tr, "Repair", self )

	return true

end

if CLIENT then

	TOOL.Information = {

		{ name = "left" },

	}

	language.Add( "tool.repair.name", "Repair" )
	language.Add( "tool.repair.desc", "Allows you repair entities/props with a toolgun." )
	language.Add( "tool.repair.left", "Repair entities/props" )

end