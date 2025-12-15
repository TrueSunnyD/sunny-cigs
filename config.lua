Config = {}

-- Inventory System Selection
-- Options: 'ox_inventory', 'qb-inventory', 'ps-inventory'
Config.Inventory = 'ox_inventory'

-- Timing settings
Config.PackOpenTime = 3 -- seconds to open cigarette pack
Config.LightCigTime = 2 -- seconds to light cigarette
Config.MinStress = 2 -- minimum stress relief per puff
Config.MaxStress = 5 -- maximum stress relief per puff

-- Puff settings
Config.MaxPuffs = 5 -- number of manual puffs before cigarette is finished
Config.AutoThrowAfterFinish = true -- automatically throw cigarette after all puffs are used

-- Cigarette prop settings
Config.PropModel = `prop_amb_ciggy_01` -- Lit cigarette with ember
Config.PropBone = 28422 -- right hand bone
Config.PropOffset = vector3(0.0, 0.0, 0.0)
Config.PropRotation = vector3(0.0, 0.0, 0.0)

-- Animation settings
Config.PackAnimation = {
    dict = "amb@world_human_clipboard@male@idle_a",
    clip = "idle_c"
}

Config.SmokingAnimation = {
    dict = "amb@world_human_smoking@male@male_a@base",
    clip = "base"
}

-- Throw animation - RIGHT HAND gesture
Config.ThrowAnimation = {
    dict = "gestures@m@standing@casual",
    clip = "gesture_shrug_hard"
}

-- Emote settings
Config.SmokingEmote = "smoke"
Config.SmokingEmoteVehicle = "smoke3"

-- Evidence settings
Config.TobaccoSmellDuration = 300 -- seconds

-- Key bindings
Config.PuffKey = 38 -- E key
Config.ThrowKey = 47 -- G key

-- Default pack uses
Config.DefaultPackUses = 20

-- Debug mode (shows print statements in console)
Config.Debug = true