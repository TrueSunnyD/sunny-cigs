if Config.Debug then
    print("^2========================================^7")
    print("^2[SUNNY-CIGS] Server script loaded!^7")
    print("^2[SUNNY-CIGS] Using inventory:", Config.Inventory)
    print("^2========================================^7")
end

local QBCore = nil
if Config.Inventory == 'qb-inventory' or Config.Inventory == 'ps-inventory' then
    QBCore = exports['qb-core']:GetCoreObject()
end

-- Inventory wrapper functions for server
local function GetItemSlot(src, slot)
    if Config.Inventory == 'ox_inventory' then
        return exports.ox_inventory:GetSlot(src, slot)
    elseif Config.Inventory == 'qb-inventory' or Config.Inventory == 'ps-inventory' then
        local Player = QBCore.Functions.GetPlayer(src)
        if not Player then return nil end
        return Player.Functions.GetItemBySlot(slot)
    end
end

local function AddItem(src, itemName, amount)
    if Config.Inventory == 'ox_inventory' then
        return exports.ox_inventory:AddItem(src, itemName, amount)
    elseif Config.Inventory == 'qb-inventory' or Config.Inventory == 'ps-inventory' then
        local Player = QBCore.Functions.GetPlayer(src)
        if not Player then return false end
        Player.Functions.AddItem(itemName, amount)
        TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[itemName], "add")
        return true
    end
end

local function RemoveItem(src, itemName, amount, metadata, slot)
    if Config.Inventory == 'ox_inventory' then
        return exports.ox_inventory:RemoveItem(src, itemName, amount, metadata, slot)
    elseif Config.Inventory == 'qb-inventory' or Config.Inventory == 'ps-inventory' then
        local Player = QBCore.Functions.GetPlayer(src)
        if not Player then return false end
        Player.Functions.RemoveItem(itemName, amount, slot)
        TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[itemName], "remove")
        return true
    end
end

local function SetMetadata(src, slot, metadata)
    if Config.Inventory == 'ox_inventory' then
        return exports.ox_inventory:SetMetadata(src, slot, metadata)
    elseif Config.Inventory == 'qb-inventory' or Config.Inventory == 'ps-inventory' then
        local Player = QBCore.Functions.GetPlayer(src)
        if not Player then return false end
        local item = Player.Functions.GetItemBySlot(slot)
        if item then
            item.info = metadata
            Player.Functions.SetInventory(Player.PlayerData.items)
            return true
        end
        return false
    end
end

-- Use cigarette pack
RegisterNetEvent('sunny-cigs:cigarettes:server:UsePack', function(packName, slot, metadata)
    local src = source
    
    if Config.Debug then
        print("^2[SUNNY-CIGS]^7 Server UsePack received from player:", src)
        print("^2[SUNNY-CIGS]^7 Pack name:", packName, "Slot:", slot)
    end
    
    local item = GetItemSlot(src, slot)
    if not item then
        if Config.Debug then
            print("^1[SUNNY-CIGS]^7 Item not found in slot", slot)
        end
        return
    end
    
    if item.name ~= packName then
        if Config.Debug then
            print("^1[SUNNY-CIGS]^7 Item name mismatch. Expected:", packName, "Got:", item.name)
        end
        return
    end
    
    -- Get current uses from metadata or info
    local itemData = Config.Inventory == 'ox_inventory' and item.metadata or item.info
    local currentUses = (itemData and itemData.uses) or Config.DefaultPackUses
    local newUses = currentUses - 1
    
    if Config.Debug then
        print("^2[SUNNY-CIGS]^7 Current uses:", currentUses, "→ New uses:", newUses)
    end
    
    local success = AddItem(src, 'cigarette', 1)
    if not success then
        if Config.Debug then
            print("^1[SUNNY-CIGS]^7 Failed to add cigarette to inventory")
        end
        TriggerClientEvent('ox_lib:notify', src, {
            title = 'Cigarettes',
            description = 'Your inventory is full',
            type = 'error'
        })
        return
    end
    
    if Config.Debug then
        print("^2[SUNNY-CIGS]^7 Cigarette added successfully")
    end
    
    if newUses <= 0 then
        RemoveItem(src, packName, 1, itemData, slot)
        if Config.Debug then
            print("^2[SUNNY-CIGS]^7 Pack removed (empty)")
        end
        TriggerClientEvent('ox_lib:notify', src, {
            title = 'Cigarette Pack',
            description = 'The pack is now empty',
            type = 'inform'
        })
    else
        local metadataSuccess = SetMetadata(src, slot, { uses = newUses })
        if Config.Debug then
            print("^2[SUNNY-CIGS]^7 Metadata updated:", metadataSuccess and "SUCCESS" or "FAILED")
        end
        TriggerClientEvent('ox_lib:notify', src, {
            title = 'Cigarette Pack',
            description = newUses .. ' cigarettes remaining',
            type = 'inform'
        })
    end
    
    TriggerClientEvent('ox_lib:notify', src, {
        title = 'Cigarettes',
        description = 'You got a cigarette from the pack',
        type = 'success'
    })
end)

-- Use cigarette (remove from inventory)
RegisterNetEvent('sunny-cigs:cigarettes:server:UseCigarette', function(slot)
    local src = source
    
    if Config.Debug then
        print("^2[SUNNY-CIGS]^7 Server UseCigarette received from player:", src, "Slot:", slot)
    end
    
    local item = GetItemSlot(src, slot)
    if not item or item.name ~= 'cigarette' then
        if Config.Debug then
            print("^1[SUNNY-CIGS]^7 Cigarette not found or wrong item")
        end
        return
    end
    
    local metadata = Config.Inventory == 'ox_inventory' and item.metadata or item.info
    local success = RemoveItem(src, 'cigarette', 1, metadata, slot)
    if Config.Debug then
        print("^2[SUNNY-CIGS]^7 Cigarette removal:", success and "SUCCESS" or "FAILED")
    end
end)
