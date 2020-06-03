TOOL.Category = "BaseWars"
TOOL.Name = "#tool.upgrade.name"

local function tool_gun( tr, tool_type, tool )

	local ply = tool:GetOwner()
	local trace = ply:GetEyeTrace().Entity

	if not IsValid( trace ) or trace:IsPlayer() then return end

	if string.StartWith( trace:GetClass(), "bw_" ) or trace:GetClass() == "prop_physics" then

		if CLIENT then

			net.Start( "BaseWarsToolGun" )

				net.WriteEntity( trace )
				net.WriteString( "Upgrade" )
				net.WriteString( tool_type )

			net.SendToServer()

		end

	end

	return true

end

function TOOL:LeftClick( tr )

	if not IsFirstTimePredicted() then return end

	tool_gun( tr, "Max", self )

	return true

end

function TOOL:RightClick( tr )

	if not IsFirstTimePredicted() then return end

	tool_gun( tr, "Upgrade", self )

	return true

end

if CLIENT then

	TOOL.Information = {

		{ name = "left" },
		{ name = "right" },

	}

	language.Add( "tool.upgrade.name", "Upgrade" )
	language.Add( "tool.upgrade.desc", "Allows you to upgrade any upgradeable BaseWars Entities by using a toolgun." )
	language.Add( "tool.upgrade.left", "Max Upgrade any upgradable BaseWars Entities." )
	language.Add( "tool.upgrade.right", "Upgrade any upgradable BaseWars Entities once." )

end