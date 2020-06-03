AddCSLuaFile()

ENT.Base = "bw_base"
ENT.Type = "anim"
ENT.PrintName = "Storage"
ENT.Spawnable = true

ENT.Model = "models/props_wasteland/controlroom_storagecloset001a.mdl"

ENT.PresetMaxHealth = 800
ENT.DrawStructureDisplay = true
ENT.items_stored = {}
ENT.classes_storable = { "bw_drink_drug", "bw_weapon" }
ENT.Opened = false
ENT.PowerCapacity = 0
ENT.IsStorage = true

if CLIENT then return end

if SERVER then

    util.AddNetworkString( "bw_storage_crate_menu" )
    util.AddNetworkString( "bw_storage_crate_allow" )

    -- Each Item should have the name, class, model and type ( Drugs have the effect value ) values.

    net.Receive( "bw_storage_crate_menu", function( len, pl )

        local ent = net.ReadEntity()
        local equip = net.ReadBool()
        local item_bits = net.ReadUInt( 32 )
        local item_compressed = net.ReadData( item_bits )
        local item = util.JSONToTable( util.Decompress( item_compressed ) )

        if ent:GetClass() ~= "bw_storage_crate" then return end

        ent:Items( ent, equip, item, pl )

    end )

    function ENT:Items( ent, equip, item, pl )

        for i = 1, #self.items_stored do

            if item ~= nil and self.items_stored[i] ~= nil and self.items_stored[i]["name"] == item["name"] and self.items_stored[i]["class"] == item["class"] and self.items_stored[i]["model"] == item["model"] and self.items_stored[i]["type"] == item["type"] then

                if item["type"] == "drug" and not item["effect"] == self.items_stored[i]["effect"] then return end

                if equip then

                    if item["type"] == "weapon" then

                        pl:Give( item["class"] )

                    elseif item["type"] == "drug" then

                        pl:ApplyDrug( item["effect"], nil )

                    end

                else

                    if item["type"] == "weapon" then

                        local weapon_ent = ents.Create( "bw_weapon" )
                        weapon_ent.WeaponClass = item["class"]
                        weapon_ent.Model = item["model"]
                        weapon_ent:SetPos( pl:EyePos() + pl:GetAimVector() * 30 )
                        weapon_ent:SetAngles( pl:EyeAngles() )
                        weapon_ent:Spawn()
                        weapon_ent:Activate()
                        weapon_ent:CPPISetOwner( pl )

                    elseif item["type"] == "drug" then

                        local drug_ent = ents.Create( "bw_drink_drug" )
                        drug_ent:SetDrugEffect( item["effect"] )
                        drug_ent.Random = false
                        drug_ent:SetPos( pl:GetPos() + BaseWars.Config.SpawnOffset + Vector( 0, 40, 0 ) )
                        drug_ent:SetAngles( pl:EyeAngles() )
                        drug_ent:Spawn()
                        drug_ent:Activate()
                        drug_ent:CPPISetOwner( pl )

                    end

                end

                if self.items_stored[i]["amount"] > 1 then

                    self.items_stored[i]["amount"] = self.items_stored[i]["amount"] - 1

                else

                    table.RemoveByValue( self.items_stored, self.items_stored[i] )

                end

                if equip then

                    net.Start( "bw_storage_crate_menu" )

                        local items_stored_compression = util.Compress( util.TableToJSON( self.items_stored ) )

                        net.WriteEntity( self )
                        net.WriteUInt( #items_stored_compression, 32 )
                        net.WriteData( items_stored_compression, #items_stored_compression )

                    net.Send( pl )

                end

            end

        end

    end

    function ENT:Init()

        self:SetUseType( SIMPLE_USE )

    end

    function ENT:Use( activator, caller )

        if self.Opened then return end

        if activator:IsPlayer() and ( ( self:CPPIGetOwner():InFaction() and activator:InFaction( self:CPPIGetOwner():GetFaction() ) ) or ( self:CPPIGetOwner() == activator ) or ( self:CPPIGetOwner():InRaid() and activator:InRaid() ) ) then

            net.Start( "bw_storage_crate_menu" )

                local items_stored_compression = util.Compress( util.TableToJSON( self.items_stored ) )

                net.WriteEntity( self )
                net.WriteUInt( #items_stored_compression, 32 )
                net.WriteData( items_stored_compression, #items_stored_compression )

            net.Send( activator )

            self.Opened = true

        else

            return

        end

    end

    function ENT:PhysicsCollide( data, phys )

        local collided = data.HitEntity

        if string.StartWith( collided:GetClass(), "bw_" ) ~= true then return end
        if not IsFirstTimePredicted() then return end

        if collided:CPPIGetOwner():IsPlayer() and ( ( self:CPPIGetOwner():InFaction() and collided:CPPIGetOwner():InFaction( self:CPPIGetOwner():GetFaction() ) ) or ( self:CPPIGetOwner() == collided:CPPIGetOwner() ) ) then

            if collided:GetClass() == "bw_drink_drug" then

                for i = 1, #self.items_stored do

                    if self.items_stored[i]["name"] == collided:GetDrugEffect() then

                        self.items_stored[i]["amount"] = self.items_stored[i]["amount"] + 1

                        collided:Remove()

                        return

                    end

                end

                table.insert( self.items_stored, { ["name"] = collided:GetDrugEffect(), ["class"] = "bw_drink_drug", ["model"] = collided:GetModel(), ["effect"] = collided:GetDrugEffect(), ["type"] = "drug", ["amount"] = collided:GetStack() } )

                collided:Remove()

            elseif collided:GetClass() == "bw_weapon" then

                local weapon_name
                local weapon_language = { ["weapon_crowbar"] = "Crowbar", ["csgo_default_t"] = "T Knife", ["csgo_default_knife"] = "CT Knife", ["cw_g4p_usp40"] = "USP", ["cw_g4p_fiveseven"] = "FiveSeven", ["cw_deagle"] = "Deagle", ["cw_g4p_mp412_rex"] = "MP412", ["cw_g4p_ump45"] = "UMP", ["cw_mp5"] = "MP5", ["cw_g4p_magpul_masada"] = "Magpul", ["cw_g4p_fn_fal"] = "FN FAL", ["cw_g36c"] = "G36", ["cw_ak74"] = "AK74", ["cw_ar15"] = "AR15", ["cw_g4p_xm8"] = "XM8", ["cw_g3a3"] = "G3A3", ["cw_g4p_awm"] = "AWM", ["cw_g4p_m98b"] = "M98b", ["cw_l115"] = "L115", ["cw_scarh"] = "SCAR", ["cw_m249_official"] = "M249", ["cw_m3super90"] = "M3", ["cw_l85a2"] = "L85 (Bullpup)", ["cw_blackops3_38"] = "Bloodhound", ["cw_blackops3_xr2"] = "XR-2", ["cw_blackops3_dlc1_p08"] = "P-06", ["cw_blackops3_mr6"] = "MR6", ["cw_blackops3_spartan"] = "KRM-262", ["cw_h1_dlc2_bos14"] = "BOS14", ["cw_blackops3_dlc3_peacekeeper"] = "Peacekeeper MK2", ["cw_blackops3_dlc2_isr27"] = "ICR-1", ["cw_blackops3_dlc3_mp400"] = "HG 40", ["cw_h1_dlc2_dmr25"] = "D-255", ["cw_g4p_mp412_rex"] = "MP-412 Rex", ["cw_blackops3_dlc4_cp_prec"] = "Argus", ["cw_h1_dlc2_psd9"] = "PK-PSD9", ["cw_h1_dlc1_ak47"] = "AK47", ["cw_g4p_m16a4"] = "M16A4", ["cw_vss"] = "VSS", ["cw_g4p_masada_acr"] = "ACR", ["cw_m14"] = "M14", ["cw_ber_honey_badger"] = "Honeybadger", ["cw_ber_famas_g2"] = "Famas G2", ["cw_ber_msbs"] = "MSBS", ["cw_ber_sig552"] = "Sig552", ["bw_blowtorch"] = "Blowtorch", ["bw_health"] = "Heal Gun" }

                if weapon_language[collided.WeaponClass] ~= nil then

                    weapon_name = weapon_language[collided.WeaponClass]

                end

                if collided.WeaponClass == "bw_weapon_c4" then return end

                for i = 1, #self.items_stored do

                    if self.items_stored[i]["name"] == weapon_name then

                        self.items_stored[i]["amount"] = self.items_stored[i]["amount"] + 1

                        collided:Remove()

                        return

                    end

                end

                table.insert( self.items_stored, { ["name"] = weapon_name, ["class"] = collided.WeaponClass, ["model"] = collided:GetModel(), ["type"] = "weapon", ["amount"] = 1 } )

                collided:Remove()

            end

        end

    end

    net.Receive( "bw_storage_crate_allow", function()

        local ent = net.ReadEntity()

        if ent:GetClass() ~= "bw_storage_crate" then return end

        ent.Opened = false

    end )

end