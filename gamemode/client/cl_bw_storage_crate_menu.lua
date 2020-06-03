local function bw_storage_crate_menu()

    if IsValid( storage_frame ) then return end

    local ent = net.ReadEntity()
    local items_bits = net.ReadUInt( 32 )
    local items_stored_net = net.ReadData( items_bits )

    local items_stored = util.JSONToTable( util.Decompress( items_stored_net ) )

    local storage_frame = vgui.Create( "DFrame" )
    storage_frame:SetSize( 700, 425 )
    storage_frame:Center()
    storage_frame:SetTitle( "Storage Crate - Left Click To Equip/Consume the Item | Right Click to Take Out the Item" )
    storage_frame:MakePopup()

    hook.Add( "Think", "storage_frame", function() if not LocalPlayer():Alive() then if IsValid( storage_frame ) then storage_frame:Close() end end end )

    function storage_frame:OnClose()

        net.Start( "bw_storage_crate_allow" )

            net.WriteEntity( ent )

        net.SendToServer()

        hook.Remove( "storage_frame" )

    end

    function storage_frame:Paint( w, h )

        draw.RoundedBox( 0, 0, 0, w, h, Color( 45, 45, 45, 225 ) )

    end

    local storage_scroll = vgui.Create( "DScrollPanel", storage_frame )
    storage_scroll:Dock( FILL )

    local storage_list = vgui.Create( "DIconLayout", storage_scroll )
    storage_list:Dock( FILL )
    storage_list:SetSpaceY( 40 )
    storage_list:SetSpaceX( 10 )

    for i = 1, #items_stored do

        local storage_panel = storage_list:Add( "DPanel" )
        storage_panel:SetSize( 100, 100 )

        function storage_panel:Paint( w, h )

            draw.RoundedBox( 10, 0, 0, w, h, Color( 75, 75, 75, 150 ) )

        end

        local storage_label = vgui.Create( "DLabel", storage_panel )
        storage_label:SetText( items_stored[i]["name"] .. " x" .. items_stored[i]["amount"] )
        storage_label:SizeToContents()
        storage_label:SetPos( 0, 4 )
        storage_label:CenterHorizontal()
        storage_label:SetTextColor( color_white )

        local storage_item = vgui.Create( "SpawnIcon", storage_panel )
        storage_item:SetModel( items_stored[i]["model"] )
        storage_item:SetTooltip( items_stored[i]["name"] )
        storage_item:SetSize( 64, 64 )
        storage_item:SetPos( 0, 25 )
        storage_item:CenterHorizontal()

        storage_item.DoClick = function()

            if items_stored[i]["type"] == "weapon" then

                if LocalPlayer():HasWeapon( items_stored[i]["class"] ) then

                    Derma_Message( "You currently have this weapon equipped! ( " .. items_stored[i]["name"] .. " )", "Storage Notice", "OK" )

                    return

                end

            end

            local item_compression = util.Compress( util.TableToJSON( items_stored[i] ) )

            net.Start( "bw_storage_crate_menu" )

                net.WriteEntity( ent )
                net.WriteBool( true )
                net.WriteUInt( #item_compression, 32 )
                net.WriteData( item_compression, #item_compression )

            net.SendToServer()

            storage_frame:Close()

        end

        storage_item.DoRightClick = function()

            local item_compression = util.Compress( util.TableToJSON( items_stored[i] ) )

            net.Start( "bw_storage_crate_menu" )

                net.WriteEntity( ent )
                net.WriteBool( false )
                net.WriteUInt( #item_compression, 32 )
                net.WriteData( item_compression, #item_compression )

            net.SendToServer()

            storage_frame:Close()

        end

        -- storage_item.DoClick = function()

        --     local item_equip

        --     if items_stored[i]["type"] == "weapon" then

        --         item_equip = "Equip"

        --     elseif items_stored[i]["type"] == "drug" then

        --         item_equip = "Consume"

        --     end

        --     local storage_menu = DermaMenu()
        --     storage_menu:AddOption( item_equip, function()

        --         if items_stored[i]["type"] == "weapon" then

        --             if LocalPlayer():HasWeapon( items_stored[i]["class"] ) then

        --                 Derma_Message( "You currently have this weapon equipped! ( " .. items_stored[i]["name"] .. " )", "Storage Notice", "OK" )

        --                 return

        --             end

        --         end

        --         local item_compression = util.Compress( util.TableToJSON( items_stored[i] ) )

        --         net.Start( "bw_storage_crate_menu" )

        --             net.WriteEntity( ent )
        --             net.WriteBool( true )
        --             net.WriteUInt( #item_compression, 32 )
        --             net.WriteData( item_compression, #item_compression )

        --         net.SendToServer()

        --         storage_frame:Close()

        --     end )
        --     storage_menu:AddOption( "Take Out", function()

        --         local item_compression = util.Compress( util.TableToJSON( items_stored[i] ) )

        --         net.Start( "bw_storage_crate_menu" )

        --             net.WriteEntity( ent )
        --             net.WriteBool( false )
        --             net.WriteUInt( #item_compression, 32 )
        --             net.WriteData( item_compression, #item_compression )

        --         net.SendToServer()

        --         storage_frame:Close()

        --     end )
        --     storage_menu:Open()

        -- end

    end

end

net.Receive( "bw_storage_crate_menu", bw_storage_crate_menu )