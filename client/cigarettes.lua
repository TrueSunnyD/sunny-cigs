if Config.Debug then
    print("^2========================================^7")
    print("^2[SUNNY-CIGS] Client script loaded!^7")
    print("^2[SUNNY-CIGS] Using inventory:", Config.Inventory)
    print("^2========================================^7")
end

local QBCore = nil
if Config.Inventory == 'qb-inventory' or Config.Inventory == 'ps-inventory' then
    QBCore = exports['qb-core']:GetCoreObject()
end

local isSmoking = false
local cigaretteProp = nil
local currentPuffs = 0

-- Inventory wrapper functions
local function HasItem(itemName)
    if Config.Inventory == 'ox_inventory' then
        return exports.ox_inventory:Search('count', itemName) > 0
    elseif Config.Inventory == 'qb-inventory' or Config.Inventory == 'ps-inventory' then
        local PlayerData = QBCore.Functions.GetPlayerData()
        for _, item in pairs(PlayerData.items) do
            if item.name == itemName then
                return true
            end
        end
        return false
    end
end

local function AttachCigarette()
    if cigaretteProp then return end
    
    local ped = PlayerPedId()
    local propModel = Config.PropModel
    
    RequestModel(propModel)
    while not HasModelLoaded(propModel) do
        Wait(10)
    end
    
    cigaretteProp = CreateObject(propModel, 0.0, 0.0, 0.0, true, true, false)
    AttachEntityToEntity(
        cigaretteProp, 
        ped, 
        GetPedBoneIndex(ped, Config.PropBone), 
        Config.PropOffset.x, Config.PropOffset.y, Config.PropOffset.z,
        Config.PropRotation.x, Config.PropRotation.y, Config.PropRotation.z,
        true, true, false, true, 1, true
    )
    SetModelAsNoLongerNeeded(propModel)
    
    if Config.Debug then
        print("^2[SUNNY-CIGS]^7 Cigarette prop attached, handle:", cigaretteProp)
    end
end

local function RemoveCigarette()
    if cigaretteProp then
        DeleteEntity(cigaretteProp)
        cigaretteProp = nil
    end
    isSmoking = false
    currentPuffs = 0
    exports.ox_lib:hideTextUI()
    
    if Config.Debug then
        print("^2[SUNNY-CIGS]^7 Cigarette removed")
    end
end

local function UpdateTextUI()
    local puffsRemaining = Config.MaxPuffs - currentPuffs
    exports.ox_lib:showTextUI('[E] Puff Cigarette (' .. puffsRemaining .. '/' .. Config.MaxPuffs .. ' left)  •  [G] Throw Away', {
        position = "left-center",
        icon = 'cigarette',
        style = {
            borderRadius = 0,
            backgroundColor = '#141517',
            color = 'white'
        }
    })
end

local function ThrowCigarette()
    if Config.Debug then
        print("^3[SUNNY-CIGS]^7 ========== ThrowCigarette function called ==========")
        print("^3[SUNNY-CIGS]^7 cigaretteProp exists:", cigaretteProp ~= nil)
        print("^3[SUNNY-CIGS]^7 cigaretteProp handle:", cigaretteProp)
        print("^3[SUNNY-CIGS]^7 isSmoking:", isSmoking)
    end
    
    if not cigaretteProp then 
        if Config.Debug then
            print("^1[SUNNY-CIGS]^7 ERROR: ThrowCigarette called but no prop exists!")
        end
        return 
    end
    
    local ped = PlayerPedId()
    exports.ox_lib:hideTextUI()
    
    if Config.Debug then
        print("^2[SUNNY-CIGS]^7 Clearing ped tasks")
    end
    
    ClearPedTasks(ped)
    Wait(100)
    
    local cigToThrow = cigaretteProp
    
    if Config.Debug then
        print("^2[SUNNY-CIGS]^7 Stored cig reference:", cigToThrow)
        print("^2[SUNNY-CIGS]^7 Loading animation:", Config.ThrowAnimation.dict)
    end
    
    RequestAnimDict(Config.ThrowAnimation.dict)
    local timeout = 0
    while not HasAnimDictLoaded(Config.ThrowAnimation.dict) and timeout < 100 do
        Wait(10)
        timeout = timeout + 1
    end
    
    if not HasAnimDictLoaded(Config.ThrowAnimation.dict) then
        if Config.Debug then
            print("^1[SUNNY-CIGS]^7 WARNING: Animation failed to load, throwing without animation")
        end
    else
        if Config.Debug then
            print("^2[SUNNY-CIGS]^7 Animation loaded successfully, playing:", Config.ThrowAnimation.clip)
        end
        TaskPlayAnim(ped, Config.ThrowAnimation.dict, Config.ThrowAnimation.clip, 8.0, -8.0, 800, 48, 0, false, false, false)
    end
    
    if Config.Debug then
        print("^2[SUNNY-CIGS]^7 Waiting 400ms before throw")
    end
    
    SetTimeout(400, function()
        if Config.Debug then
            print("^2[SUNNY-CIGS]^7 Throw timeout triggered")
            print("^2[SUNNY-CIGS]^7 cigToThrow exists:", DoesEntityExist(cigToThrow))
        end
        
        if DoesEntityExist(cigToThrow) then
            if Config.Debug then
                print("^2[SUNNY-CIGS]^7 Detaching and throwing cigarette")
            end
            
            DetachEntity(cigToThrow, true, true)
            
            local pedHeading = GetEntityHeading(ped)
            local forwardX = -math.sin(math.rad(pedHeading))
            local forwardY = math.cos(math.rad(pedHeading))
            
            if Config.Debug then
                print("^2[SUNNY-CIGS]^7 Applying force - X:", forwardX, "Y:", forwardY)
            end
            
            ApplyForceToEntity(
                cigToThrow, 
                1,
                forwardX * 5.0,
                forwardY * 5.0,
                2.5,
                0.0, 0.0, 0.0,
                0, false, true, true, false, true
            )
            
            if Config.Debug then
                print("^2[SUNNY-CIGS]^7 Force applied successfully!")
            end
            
            SetTimeout(5000, function()
                if DoesEntityExist(cigToThrow) then
                    DeleteEntity(cigToThrow)
                    if Config.Debug then
                        print("^2[SUNNY-CIGS]^7 Cigarette prop deleted after 5s")
                    end
                end
            end)
        else
            if Config.Debug then
                print("^1[SUNNY-CIGS]^7 ERROR: Cigarette prop no longer exists!")
            end
        end
    end)
    
    cigaretteProp = nil
    isSmoking = false
    currentPuffs = 0
    
    exports.ox_lib:notify({ 
        title = "Cigarette", 
        description = "You threw away your cigarette", 
        type = "inform" 
    })
    
    if Config.Debug then
        print("^2[SUNNY-CIGS]^7 Smoking state reset")
        print("^3[SUNNY-CIGS]^7 ========== ThrowCigarette function ended ==========")
    end
end

local function CreateSmokeEffect()
    local ped = PlayerPedId()
    
    RequestNamedPtfxAsset("core")
    while not HasNamedPtfxAssetLoaded("core") do
        Wait(10)
    end
    
    UseParticleFxAssetNextCall("core")
    local particle = StartParticleFxLoopedOnPedBone(
        "exp_grd_bzgas_smoke",
        ped,
        0.0, 0.0, 0.0,
        0.0, 0.0, 0.0,
        0x796E,
        0.4,
        false, false, false
    )
    
    SetTimeout(3000, function()
        if particle then
            StopParticleFxLooped(particle, false)
        end
    end)
    
    if Config.Debug then
        print("^2[SUNNY-CIGS]^7 Smoke effect created")
    end
end

local function PuffCigarette()
    if not isSmoking or not cigaretteProp then return end
    
    currentPuffs = currentPuffs + 1
    
    local ped = PlayerPedId()
    local inVehicle = IsPedInAnyVehicle(ped, false)
    
    if inVehicle then
        RequestAnimDict("amb@world_human_smoking@male@male_b@base")
        while not HasAnimDictLoaded("amb@world_human_smoking@male@male_b@base") do
            Wait(10)
        end
        TaskPlayAnim(ped, "amb@world_human_smoking@male@male_b@base", "base", 8.0, -8.0, 3000, 49, 0, false, false, false)
    else
        RequestAnimDict("amb@world_human_aa_smoke@male@idle_a")
        while not HasAnimDictLoaded("amb@world_human_aa_smoke@male@idle_a") do
            Wait(10)
        end
        TaskPlayAnim(ped, "amb@world_human_aa_smoke@male@idle_a", "idle_c", 8.0, -8.0, 3000, 49, 0, false, false, false)
    end
    
    SetTimeout(1500, function()
        if isSmoking then
            CreateSmokeEffect()
        end
    end)
    
    Wait(3000)
    
    if isSmoking then
        if inVehicle then
            RequestAnimDict("amb@world_human_smoking@male@male_b@idle_a")
            while not HasAnimDictLoaded("amb@world_human_smoking@male@male_b@idle_a") do
                Wait(10)
            end
            TaskPlayAnim(ped, "amb@world_human_smoking@male@male_b@idle_a", "idle_a", 8.0, -8.0, -1, 49, 0, false, false, false)
        else
            RequestAnimDict("amb@world_human_smoking@male@male_a@idle_a")
            while not HasAnimDictLoaded("amb@world_human_smoking@male@male_a@idle_a") do
                Wait(10)
            end
            TaskPlayAnim(ped, "amb@world_human_smoking@male@male_a@idle_a", "idle_a", 8.0, -8.0, -1, 49, 0, false, false, false)
        end
    end
    
    local stressRelief = math.random(Config.MinStress, Config.MaxStress)
    TriggerServerEvent('hud:server:RelieveStress', stressRelief)
    
    local puffsRemaining = Config.MaxPuffs - currentPuffs
    
    if Config.Debug then
        print("^2[SUNNY-CIGS]^7 Puff #" .. currentPuffs .. "/" .. Config.MaxPuffs .. " taken, stress relief:", stressRelief)
    end
    
    if puffsRemaining > 0 then
        UpdateTextUI()
        
        exports.ox_lib:notify({ 
            title = "Cigarette", 
            description = puffsRemaining .. " puff" .. (puffsRemaining == 1 and "" or "s") .. " remaining", 
            type = "inform",
            duration = 2000
        })
    end
    
    if currentPuffs >= Config.MaxPuffs then
        if Config.Debug then
            print("^2[SUNNY-CIGS]^7 Maximum puffs reached, finishing cigarette")
        end
        
        TriggerEvent("evidence:client:SetStatus", "tobaccosmell", Config.TobaccoSmellDuration)
        
        if Config.AutoThrowAfterFinish then
            ThrowCigarette()
            exports.ox_lib:notify({ 
                title = "Cigarette", 
                description = "You finished your cigarette and tossed it", 
                type = "success" 
            })
        else
            RemoveCigarette()
            exports.ox_lib:notify({ 
                title = "Cigarette", 
                description = "You finished your cigarette", 
                type = "success" 
            })
        end
    end
end

-- Cigarette Pack Use
RegisterNetEvent('sunny-cigs:cigarettes:client:UseCigPack', function(item)
    if Config.Debug then
        print("^2[SUNNY-CIGS]^7 UseCigPack triggered")
        print("^2[SUNNY-CIGS]^7 Item data:", json.encode(item))
    end
    
    if not item or not item.name then
        exports.ox_lib:notify({ 
            title = "Cigarettes", 
            description = "Invalid item data", 
            type = "error" 
        })
        return
    end

    if not exports.ox_lib:progressBar({
        duration = Config.PackOpenTime * 1000,
        label = "Opening Cigarette Pack...",
        useWhileDead = false,
        canCancel = true,
        disable = { move = false, car = false, combat = true },
        anim = { dict = Config.PackAnimation.dict, clip = Config.PackAnimation.clip }
    }) then
        exports.ox_lib:notify({ 
            title = "Cigarettes", 
            description = "Cancelled", 
            type = "error" 
        })
        return
    end
    
    if Config.Debug then
        print("^2[SUNNY-CIGS]^7 Sending to server:", item.name)
    end
    
    -- Pass item data based on inventory system
    if Config.Inventory == 'ox_inventory' then
        TriggerServerEvent('sunny-cigs:cigarettes:server:UsePack', item.name, item.slot, item.metadata)
    else
        TriggerServerEvent('sunny-cigs:cigarettes:server:UsePack', item.name, item.slot, item.info)
    end
end)

-- Cigarette Use
RegisterNetEvent('sunny-cigs:cigarettes:client:UseCigarette', function(item)
    if Config.Debug then
        print("^2[SUNNY-CIGS]^7 UseCigarette triggered")
        print("^2[SUNNY-CIGS]^7 Item data:", json.encode(item))
    end
    
    if isSmoking then
        exports.ox_lib:notify({ 
            title = "Cigarettes", 
            description = "You're already smoking a cigarette", 
            type = "error" 
        })
        return
    end
    
    if not HasItem('lighter') then
        exports.ox_lib:notify({ 
            title = "Cigarettes", 
            description = "You don't have a lighter", 
            type = "error" 
        })
        return
    end
    
    RemoveCigarette()
    
    if not exports.ox_lib:progressBar({
        duration = Config.LightCigTime * 1000,
        label = "Lighting cigarette...",
        useWhileDead = false,
        canCancel = true,
        disable = { move = false, car = false, combat = true }
    }) then
        exports.ox_lib:notify({ 
            title = "Cigarettes", 
            description = "You stopped lighting the cigarette", 
            type = "error" 
        })
        return
    end
    
    if Config.Debug then
        print("^2[SUNNY-CIGS]^7 Cigarette lit successfully, removing from inventory")
    end
    
    -- Pass slot based on inventory system
    if Config.Inventory == 'ox_inventory' then
        TriggerServerEvent('sunny-cigs:cigarettes:server:UseCigarette', item.slot)
    else
        TriggerServerEvent('sunny-cigs:cigarettes:server:UseCigarette', item.slot or 1)
    end
    
    AttachCigarette()
    isSmoking = true
    currentPuffs = 0
    
    local ped = PlayerPedId()
    if IsPedInAnyVehicle(ped, false) then
        RequestAnimDict("amb@world_human_smoking@male@male_b@idle_a")
        while not HasAnimDictLoaded("amb@world_human_smoking@male@male_b@idle_a") do
            Wait(10)
        end
        TaskPlayAnim(ped, "amb@world_human_smoking@male@male_b@idle_a", "idle_a", 8.0, -8.0, -1, 49, 0, false, false, false)
    else
        RequestAnimDict("amb@world_human_smoking@male@male_a@idle_a")
        while not HasAnimDictLoaded("amb@world_human_smoking@male@male_a@idle_a") do
            Wait(10)
        end
        TaskPlayAnim(ped, "amb@world_human_smoking@male@male_a@idle_a", "idle_a", 8.0, -8.0, -1, 49, 0, false, false, false)
    end
    
    UpdateTextUI()
    
    if Config.Debug then
        print("^2[SUNNY-CIGS]^7 Starting key listener thread")
        print("^2[SUNNY-CIGS]^7 Config.PuffKey:", Config.PuffKey)
        print("^2[SUNNY-CIGS]^7 Config.ThrowKey:", Config.ThrowKey)
    end
    
    CreateThread(function()
        if Config.Debug then
            print("^2[SUNNY-CIGS]^7 Key listener thread started, isSmoking:", isSmoking)
        end
        
        while isSmoking do
            Wait(0)
            
            if IsControlJustPressed(0, Config.PuffKey) then
                if Config.Debug then
                    print("^2[SUNNY-CIGS]^7 E KEY PRESSED - Calling PuffCigarette")
                end
                PuffCigarette()
            end
            
            if IsControlJustPressed(0, Config.ThrowKey) then
                if Config.Debug then
                    print("^3[SUNNY-CIGS]^7 G KEY PRESSED - THROW TRIGGERED")
                end
                
                ClearPedTasks(ped)
                ThrowCigarette()
                TriggerEvent("evidence:client:SetStatus", "tobaccosmell", Config.TobaccoSmellDuration)
                break
            end
        end
        
        if Config.Debug then
            print("^2[SUNNY-CIGS]^7 Key listener thread ended")
        end
    end)
    
    if Config.Debug then
        print("^2[SUNNY-CIGS]^7 Cigarette ready, waiting for manual puffs")
    end
end)

RegisterCommand('throwcig', function()
    if Config.Debug then
        print("^3[SUNNY-CIGS]^7 Manual throw command triggered")
        print("^3[SUNNY-CIGS]^7 isSmoking:", isSmoking)
        print("^3[SUNNY-CIGS]^7 cigaretteProp:", cigaretteProp)
    end
    
    if isSmoking and cigaretteProp then
        ThrowCigarette()
        TriggerEvent("evidence:client:SetStatus", "tobaccosmell", Config.TobaccoSmellDuration)
    else
        print("^1[SUNNY-CIGS]^7 Not smoking or no cigarette prop!")
    end
end, false)
