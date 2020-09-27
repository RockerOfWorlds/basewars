MODULE.Name = "Prestige"
MODULE.Author = "RockerOfWorlds, Q2F2, Ghosty and Tenrys" -- Q2F2, Ghosty and Tenrys made a lot of what this was based off of.

local tag = "BaseWars.Prestige"
local PLAYER = debug.getregistry().Player

local function isPlayer( ply )

    return ( IsValid( ply ) and ply:IsPlayer() )

end

function MODULE:GetPrestige( ply, type, perk )

    if not IsValid( ply ) then return 0 end

    local current_prestige = string.Explode( "|", ply:GetNWString( tag ) )

    if type == "prestige" then

        return tonumber( current_prestige[1] ) or 0

    elseif type == "points" then

        return tonumber( current_prestige[2] ) or 0

    elseif type == "perk" then

        local i

        for k, v in pairs( BaseWars.Config.Perks ) do

            if k == string.lower(perk) then

                return tonumber( current_prestige[i + 2] ) or 0

            end

            i = i + 1

        end

    end

end
PLAYER.GetPrestige = Curry( MODULE.GetPrestige )

if SERVER then

    util.AddNetworkString( "handle_prestige" )

    function MODULE:InitPrestige( ply )

        -- TODO: Make a better way of saving this data via MySQL.

        BaseWars.MySQL.InitPlayer( ply, "prestige", "0|0|0|0|0|0|0|0|0|0|0|0|0|0|0|0|0|0" )

    end
    PLAYER.InitPrestige = Curry( MODULE.InitPrestige )

    function MODULE:SavePrestige( ply )

        BaseWars.MySQL.SaveVar( ply, "prestige", ply:GetNWString( tag ) )

    end
    PLAYER.SavePrestige = Curry( MODULE.SavePrestige )

    function MODULE:LoadPrestige( ply )

        self:InitPrestige( ply )

        BaseWars.MySQL.LoadVar( ply, "prestige", function( ply, var, val )

            if not IsValid( ply ) then return end

            ply:SetNWString( tag, tostring( val ) )

        end )

    end
    PLAYER.LoadPrestige = Curry( MODULE.LoadPrestige )

    function MODULE:SetPrestige( ply, type, amount, perk )

        local amount = tonumber( amount )

        if not isnumber( amount ) or amount < 0 then amount = 0 end
        if amount ~= amount then amount = 0 end

        local current_prestige = string.Explode( "|", ply:GetNWString( tag ) )

        if type == "prestige" then

            current_prestige[1] = tostring( amount )

        elseif type == "points" then

            current_prestige[2] = tostring( amount )

        elseif type == "perk" then

            local i

            for k, v in pairs( BaseWars.Config.Perks ) do

                if k == string.lower(perk) then

                    current_prestige[i + 2] = tostring( amount )

                end

                i = i + 1

            end

        end

        current_prestige = table.concat( current_prestige, "|" )
        ply:SetNWString( tag, current_prestige )

        self:SavePrestige( ply )

    end
    PLAYER.SetPrestige = Curry( MODULE.SetPrestige )

    function MODULE:GivePrestige( ply, type, amount, perk )

        self:SetPrestige( ply, type, self:GetPrestige( ply, type, perk ) + amount, perk )

    end
    PLAYER.GivePrestige = Curry( MODULE.GivePrestige )

    function MODULE:TakePrestige( ply, type, amount, perk )

        self:SetPrestige( ply, type, self:GetPrestige( ply, type, perk ) - amount, perk )

    end
    PLAYER.TakePrestige = Curry( MODULE.TakePrestige )

    function MODULE:Prestige( ply )

        if ply:GetLevel() >= BaseWars.Config.PrestigeStartingLevel then

            local points_earned = BaseWars.Config.PrestigePointsEarned

            BaseWars.UTIL.RefundAll( ply )
            ply:SetMoney( BaseWars.Config.StartMoney )
            ply:SetLevel( 1 )
            ply:SetXP( 0 )
            self:GivePrestige( ply, "prestige", 1 )
            self:GivePrestige( ply, "points", points_earned )

            for i = 1, 10 do

                local effect_data = EffectData()
                effect_data:SetOrigin( ply:GetPos() )

                util.Effect( "balloon_pop", effect_data )

            end

            for k, v in ipairs( player.GetAll() ) do

                v:SendLua( [[chat.AddText( Color( 255, 255, 255 ), "[", Color( 0, 200, 200 ) "BaseWars", Color( 255, 255, 255 ), "] Congratulations to " .. ply:Nick() .. " who has reached prestige " .. self:GetPrestige( ply, "prestige" ) .. "!")]] )

            end

        else

            return

        end

    end
    PLAYER.Prestige = Curry( MODULE.Prestige )

    function MODULE:UpgradePerk( ply, perk )

        if BaseWars.Config.Perks[perk] == nil or not BaseWars.Config.Perks[perk]["Enabled"] then return end
        if self:GetPrestige( ply, "points" ) < BaseWars.Config.Perks[perk]["Cost"] or self:GetPrestige( ply, "perk", perk ) >= BaseWars.Config.Perks[perk]["Max"] then return end

        self:GivePrestige( ply, "perk", 1, perk )
        self:TakePrestige( ply, "points", BaseWars.Config.Perks[perk]["Cost"] )

    end
    PLAYER.UpgradePerk = Curry( MODULE.UpgradePerk )

    function MODULE:ResetPrestigePerks( ply )

        local prestige_give = 0

        for k, v in pairs( BaseWars.Config.Perks ) do

            if self:GetPrestige( ply, "perk", k ) >= 1 then

                prestige_give = prestige_give + ( BaseWars.Config.Perks[k]["Cost"] * self:GetPrestige( ply, "perk", k ) )

                self:SetPrestige( ply, "perk", 0, k )

            end

        end

        self:GivePrestige( ply, "points", prestige_give )

    end
    PLAYER.ResetPrestigePerks = Curry( MODULE.ResetPrestigePerks )

    net.Receive( "handle_prestige", function( len, pl )

        local type = net.ReadString()

        if type == "prestige" then

            pl:Prestige()

        elseif type == "perk" then

            local perk = net.ReadString()

            pl:UpgradePerk( perk )

        elseif type == "reset_prestige_perks" then

            if pl:GetMoney() < BaseWars.Config.ResetPrestigePerksCost then return end

            pl:TakeMoney( BaseWars.Config.ResetPrestigePerksCost )
            pl:ResetPrestigePerks()

        end

    end )

    local function apply_prestige_perks( ply, transition )

        timer.Simple( 2, function()

            ply:SetHealth( 100 + ( BaseWars.Config.Perks["healthperk"]["Additions"] * ply:GetPrestige( "perk", "healthperk" ) ) )
            ply:SetMaxHealth( 100 + ( BaseWars.Config.Perks["healthperk"]["Additions"] * ply:GetPrestige( "perk", "healthperk" ) ) )
            ply:SetArmor( 100 + ( BaseWars.Config.Perks["armorperk"]["Additions"] * ply:GetPrestige( "perk", "armorperk" ) ) )
            ply:SetWalkSpeed( BaseWars.Config.DefaultWalk + ( BaseWars.Config.Perks["speedperk"]["WalkAdditions"] * ply:GetPrestige( "perk", "speedperk" ) ) )
            ply:SetRunSpeed( BaseWars.Config.DefaultRun + ( BaseWars.Config.Perks["speedperk"]["RunAdditions"] * ply:GetPrestige( "perk", "speedperk" ) ) )

        end )

    end

    hook.Add( "PlayerInitialSpawn", tag .. ".InitialSpawn", apply_prestige_perks )
    hook.Add( "PlayerSpawn", tag .. ".Spawn", apply_prestige_perks )
    hook.Add( "LoadData", tag .. ".Load", Curry( MODULE.LoadPrestige ) )
    hook.Add( "PlayerDisconnected", tag .. ".Save", Curry( MODULE.SavePrestige ) )

end