local required_time_hold = 0.3
local distance_max = 92


local dist_check = distance_max*distance_max
local function check(ply, ent, printer)
	if not IsValid(ent) then return end
	if not ent.PresetMaxHealth then return end
	if printer and not ent.IsPrinter then return end
	if IsValid(ent:CPPIGetOwner()) and ply ~= ent:CPPIGetOwner() then return end
	if ent:CPPIGetOwner() == disconnected then return end
	if ply:GetPos():DistToSqr(ent:GetPos()) > dist_check then return end
	if IsValid(ply:GetActiveWeapon()) and ply:GetActiveWeapon():GetClass() == "weapon_physgun" and ply:KeyDown( IN_ATTACK ) then return end
	if SERVER and not ent.CurrentValue then return end

	return true
end

if SERVER then

util.AddNetworkString("UpgradePrinter")
util.AddNetworkString("MaxUpgradePrinter")
util.AddNetworkString("SellPrinter")
util.AddNetworkString( "SetRange" )

net.Receive("UpgradePrinter", function(_, ply)
	local ent = net.ReadEntity()
	if not check(ply, ent, true) then return end

	ent:Upgrade(ply)
end)

net.Receive("MaxUpgradePrinter", function(_, ply)
	local ent = net.ReadEntity()
	if not check(ply, ent, true) then return end

	for i = 1, (ent.MaxLevel or 1024) do
		local r = ent:Upgrade(ply, true)
		if r == false then break end
	end
end)

net.Receive("SellPrinter", function(_, ply)
	local ent = net.ReadEntity()
	if not check(ply, ent, false) then return end
	if ply:InRaid() then return end

	BaseWars.UTIL.PayOut(ent, ply)
	ent:Remove()
end)

net.Receive( "SetRange", function( len, ply )

	local ent = net.ReadEntity()
	local range = net.ReadString()
	if ent:CPPIGetOwner() ~= ply then return end
	if ply:InRaid() then return end
	if not IsValid( ply ) then return end
	if tonumber( range ) > 300 then return end

	ent:SetRadius( range )

end)

else

local PrinterPanel
local function OpenPrinterPanel(printer, sellonly, able_to_set_range)
	if not IsValid(printer) then return end
	if IsValid(PrinterPanel) then PrinterPanel:Close() end

	PrinterPanel = vgui.Create("DFrame")
	local h = 200 -- (sellonly and 30 or 90) + 34
	PrinterPanel:SetSize(200, h)
	PrinterPanel:SetPos(ScrW()/2 - 75, ScrH()/2 - h)
	PrinterPanel:SetTitle("Interaction Menu")
	PrinterPanel:ShowCloseButton(false)
	PrinterPanel:MakePopup()
	PrinterPanel.Paint = function()
		draw.RoundedBox( 0, 0, 0, 400, 25, Color(65, 65, 65, 255))
		draw.RoundedBox( 0, 0, 0, 400, h, Color(40,40,40, 150))
	end

	function PrinterPanel:Think()
		if not LocalPlayer():KeyDown(IN_USE) then
			self:Close()
		end
	end

	if not sellonly then
		local Upg = vgui.Create("DButton", PrinterPanel)
		Upg:SetText("Upgrade")
		Upg:Dock(TOP)
		Upg:SetSize(100, 40)
		Upg.DoClick = function()
			net.Start("UpgradePrinter")
				net.WriteEntity(printer)
			net.SendToServer()
		end

		local MaxUpg = vgui.Create("DButton", PrinterPanel)
		MaxUpg:SetText("Max Upgrade")
		MaxUpg:Dock(TOP)
		MaxUpg:DockMargin( 0, 20, 0, 0 )
		MaxUpg:SetSize(100, 40)
		MaxUpg.DoClick = function()
			net.Start("MaxUpgradePrinter")
				net.WriteEntity(printer)
			net.SendToServer()

			if IsValid(PrinterPanel) then PrinterPanel:Close() end
		end
	end

	if not able_to_set_range then

		local TeslaRange = vgui.Create( "DButton", PrinterPanel )
		TeslaRange:SetText( "Set Range" )
		TeslaRange:Dock( TOP )
		TeslaRange:DockMargin( 0, 20, 0, 0 )
		TeslaRange:SetSize( 100, 40 )
		TeslaRange.DoClick = function()

			LocalPlayer():ConCommand( "range_open_menu" )

		end

		if not sellonly then

			h = 250
			PrinterPanel:SetSize( 200, h )

		end

	end

	local Sell = vgui.Create("DButton", PrinterPanel)
	Sell:SetText("Sell")
	Sell:Dock(TOP)
	Sell:DockMargin( 0, 20, 0, 0 )
	Sell:SetSize(100, 40)
	Sell.DoClick = function()
		net.Start("SellPrinter")
			net.WriteEntity(printer)
		net.SendToServer()

		if IsValid(PrinterPanel) then PrinterPanel:Close() end
	end
end

local start, in_menu = 0, false
local target, need_repress = nil, false
hook.Add("Think", "printermenu", function()
	local ply = LocalPlayer()
	local ct = CurTime()

	if not ply:Alive() then
		return
	end

	local e = ply:KeyDown(IN_USE)
	if not e then
		start = ct
		target = nil
		in_menu = false
		need_repress = false
	elseif not need_repress and not in_menu then
		local ent = ply:GetEyeTrace().Entity
		target = target or ent

		if ent ~= target or not check(ply, target, false) then
			start = ct
			target = nil
			in_menu = false
			need_repress = true

			return
		end

		if ct - start > required_time_hold then
			OpenPrinterPanel(target, not target.IsPrinter, not target.IsAbleToSetRange)
			in_menu = true
		end
	end
end)

end