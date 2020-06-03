TOOL.Category = "BaseWars"
TOOL.Name = "#tool.bwarmor.name"
TOOL.Stage = 1
TOOL.AOE = false

TOOL.ClientConVar[ "aoe_range" ] = "200"

local function tool_gun( tr, tool_type, tool )

	local ply = tool:GetOwner()
	local trace = ply:GetEyeTrace().Entity

	if not ( IsValid( trace ) or trace:IsPlayer() ) and not tool.AOE then return end

	if tool.AOE or ( string.StartWith( trace:GetClass(), "bw_" ) or trace:GetClass() == "prop_physics" ) then

		if CLIENT then

			net.Start( "BaseWarsToolGun" )

				net.WriteEntity( trace )

				if not tool.AOE then

					net.WriteString( "Armor" )

				else

					net.WriteString( "ArmorAOE" )

				end

				net.WriteString( tool_type )

				if tool.AOE then

					net.WriteString( tostring( GetConVarNumber( 'bwarmor_aoe_range' ) ) )

				end

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

	tool_gun( tr, "Armor", self )

	return true

end

function TOOL:Reload( tr )

	if not IsFirstTimePredicted() then return end

	self.AOE = !self.AOE

	if not self.AOE then

		self.Stage = 1
		self:SetStage( stage )

	else

		self.Stage = 2
		self:SetStage( stage )

	end

end

function TOOL:Think()

	self:SetStage( self.Stage )

end

function TOOL.BuildCPanel( CPanel )

	local aoe_range = vgui.Create( "DForm" )
	aoe_range:SetName( "AOE Settings" )
	aoe_range:NumSlider( "AOE Range:", "bwarmor_aoe_range", 1, 800 )

	CPanel:AddItem( aoe_range )

end

hook.Add( "PostDrawTranslucentRenderables", "aoe_sphere", function()

	if not IsValid( LocalPlayer():GetActiveWeapon() ) or LocalPlayer():GetActiveWeapon():GetClass() ~= "gmod_tool" then return end
	if LocalPlayer():GetTool() == nil then return end

	if LocalPlayer():GetTool()['Name'] == "#tool.bwarmor.name" and LocalPlayer():GetTool()['AOE'] then

		render.DrawWireframeSphere( LocalPlayer():GetEyeTraceNoCursor().HitPos, GetConVarNumber( 'bwarmor_aoe_range' ), 10, 10, color_white )

	end

end )

if SERVER then

	util.AddNetworkString( "BaseWarsToolGun" )

	net.Receive( "BaseWarsToolGun", function( len, ply )

		local ent = net.ReadEntity()
		local tool = net.ReadString()
		local tool_type = net.ReadString()
		local aoe_range

		if tool == "ArmorAOE" then aoe_range = tonumber( net.ReadString() ) end

		local tools = { ["Armor"] = { ["Heavy"] = { ["tool_cost"] = 8500000, ["tool_amount"] = 1500, ["tool_level"] = 75 }, ["Armor"] = { ["tool_cost"] = 85000, ["tool_amount"] = 500, ["tool_level"] = 0 } }, ["Capacity"] = { ["Heavy"] = { ["tool_cost"] = 12500000, ["tool_amount"] = 3, ["tool_level"] = 75 }, ["Capacity"] = { ["tool_cost"] = 100000, ["tool_amount"] = 2, ["tool_level"] = 0 } }, ["Repair"] = { ["Repair"] = { ["tool_cost"] = 40000, ["tool_level"] = 0 } }, ["Upgrade"] = { ["Max"] = { ["tool_amount"] = 25 }, ["Upgrade"] = { ["tool_amount"] = 1 } } }

		if not ( IsValid( ent ) or ent:IsPlayer() ) and not tool == "ArmorAOE" then return end
		if tool ~= "Upgrade" and tool ~= "ArmorAOE" then if ply:GetMoney() < tools[tool][tool_type]["tool_cost"] or ply:GetLevel() < tools[tool][tool_type]["tool_level"] then return end end
		if tool == "Armor" and ent.Armoured then ply:Notify( "This entity/prop has already been armoured!", BASEWARS_NOTIFICATION_ERROR ) return end
		if tool == "Capacity" and ent.CapUpgraded then ply:Notify( "You've already upgraded the capacity of this printer!", BASEWARS_NOTIFICATION_ERROR ) return end

		if tool == "ArmorAOE" or string.StartWith( ent:GetClass(), "bw_" ) or ( ( tool == "Armor" or tool == "Repair" ) and ent:GetClass() == "prop_physics" ) then

			if tool == "Armor" and not ent.Armoured then

				ply:TakeMoney( tools[tool][tool_type]["tool_cost"] )

				ent.Armoured = true

				ent:SetMaxHealth( ent:GetMaxHealth() + tools[tool][tool_type]["tool_amount"] )
				ent:SetHealth( ent:Health() + tools[tool][tool_type]["tool_amount"] )
				ent:SetColor( Color( 255, 255, 255 ) )

			elseif tool == "ArmorAOE" then

				if aoe_range > 800 then aoe_range = 800 end

				for k, v in next, ents.FindInSphere( ply:GetEyeTraceNoCursor().HitPos, aoe_range ) do

					if ( string.StartWith( v:GetClass(), "bw_" ) or v:GetClass() == "prop_physics" ) and not v.Armoured then

						if ply:GetMoney() < tools["Armor"][tool_type]["tool_cost"] then ply:Notify( "You cannot afford to armor anymore entities/props!" ) return end

						ply:TakeMoney( tools["Armor"][tool_type]["tool_cost"] )

						v.Armoured = true

						v:SetMaxHealth( v:GetMaxHealth() + tools["Armor"][tool_type]["tool_amount"] )
						v:SetHealth( v:Health() + tools["Armor"][tool_type]["tool_amount"] )
						v:SetColor( Color( 255, 255, 255 ) )

					end

				end

				ply:Notify( "You've succesfully armored all of the entities/props with a range of " .. aoe_range .. "!", BASEWARS_NOTIFICATION_MONEY )

			elseif tool == "Capacity" and ent.IsPrinter and not ent.CapUpgraded and not ent.IsVault then

				ply:TakeMoney( tools[tool][tool_type]["tool_cost"] )

				ent.CapUpgraded = true

				ent:SetCapacity( ent:GetCapacity() * tools[tool][tool_type]["tool_amount"] )

			elseif tool == "Repair" and ent:Health() < ent:GetMaxHealth() - 1 then

				ply:TakeMoney( tools[tool][tool_type]["tool_cost"] )

				ent:SetHealth( ent:GetMaxHealth() )
				ent:SetColor( Color( 255, 255, 255 ) )

			elseif tool == "Upgrade" and ent.IsPrinter then

				if BaseWars.Ents:ValidOwner( ent ) ~= ply then return end

				for i = 1, tools[tool][tool_type]["tool_amount"] do

					local r = ent:Upgrade( ply, true )
					if r == false then break end

				end

			end

		end

	end )

end

if CLIENT then

	TOOL.Information = {

		{ name = "left", stage = 1 },
		{ name = "right", stage = 1 },
		{ name = "left_aoe", stage = 2 },
		{ name = "right_aoe", stage = 2 },
		{ name = "reload", stage = 1 },
		{ name = "reload_aoe", stage = 2 }

	}

	language.Add( "tool.bwarmor.name", "BWArmor" )
	language.Add( "tool.bwarmor.desc", "Allows you to heavy armor/armor entities/props with a toolgun." )
	language.Add( "tool.bwarmor.left", "Heavy Armor entities/props." )
	language.Add( "tool.bwarmor.right", "Armor entities/props." )
	language.Add( "tool.bwarmor.left_aoe", "Heavy Armor entities/props in the sphere." )
	language.Add( "tool.bwarmor.right_aoe", "Armor entities/props in the sphere." )
	language.Add( "tool.bwarmor.reload", "Switch Mode to AOE" )
	language.Add( "tool.bwarmor.reload_aoe", "Switch Mode to Normal" )

end