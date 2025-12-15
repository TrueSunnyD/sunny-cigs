# Sunny Cigs - Installation Guide

A realistic cigarette smoking system for FiveM with stress relief, puff mechanics, and multi-inventory support.

## Features
- ✅ Cigarette pack system with metadata tracking (20 uses per pack)
- ✅ Manual puff system (press E to take puffs)
- ✅ Configurable number of puffs per cigarette
- ✅ Realistic smoking animations with smoke effects
- ✅ Stress relief system integration
- ✅ Throw away mechanic (press G)
- ✅ Auto-throw after finishing cigarette
- ✅ Dynamic UI showing remaining puffs
- ✅ Requires lighter to use cigarettes
- ✅ Evidence system integration (tobacco smell)
- ✅ **Multi-inventory support** (ox_inventory, qb-inventory, ps-inventory)

---

## Requirements

- **ox_lib** - For progress bars and notifications
- **One of the following inventory systems:**
  - ox_inventory (recommended)
  - qb-inventory
  - ps-inventory
- **A stress/HUD system** that supports `hud:server:RelieveStress` event

---

## Installation Steps

### 1. Download and Extract
Extract the `sunny-cigs` folder to your server's `resources` directory.

### 2. Configure Inventory System

Open `config.lua` and set your inventory system:
```lua
-- Options: 'ox_inventory', 'qb-inventory', 'ps-inventory'
Config.Inventory = 'ox_inventory'
```

### 3. Add Items to Your Inventory System

Choose the section below based on your inventory system:

---

## Inventory System Configuration

### Option 1: ox_inventory (Default)

**Set in config.lua:**
```lua
Config.Inventory = 'ox_inventory'
```

**Add items to `ox_inventory/data/items.lua`:**
```lua
['redwoodcigs'] = {
    label = 'Redwood Cigarettes',
    consume = 0, -- IMPORTANT: Must be 0 for metadata tracking
    weight = 50,
    stack = false, -- IMPORTANT: Must be false for metadata
    close = true,
    description = 'A pack of Redwood Cigarettes (20 cigarettes)',
    client = {
        event = 'sunny-cigs:cigarettes:client:UseCigPack'
    },
},

['cardiaquecigs'] = {
    label = 'Cardiaque Cigarettes',
    consume = 0,
    weight = 50,
    stack = false,
    close = true,
    description = 'A pack of Cardiaque Cigarettes (20 cigarettes)',
    client = {
        event = 'sunny-cigs:cigarettes:client:UseCigPack'
    },
},

['yukoncigs'] = {
    label = 'Yukon Cigarettes',
    consume = 0,
    weight = 50,
    stack = false,
    close = true,
    description = 'A pack of Yukon Cigarettes (20 cigarettes)',
    client = {
        event = 'sunny-cigs:cigarettes:client:UseCigPack'
    },
},

['cigarette'] = {
    label = 'Cigarette',
    consume = 0, -- IMPORTANT: Must be 0 so we handle removal manually
    weight = 10,
    stack = true,
    close = true,
    description = 'A single use cancer stick',
    client = {
        event = 'sunny-cigs:cigarettes:client:UseCigarette'
    },
},

['lighter'] = { --MAY ALREADY BE IN ITEMS.LUA MAKE SURE ITS NOT IN THERE TWICE
    label = 'Lighter',
    weight = 50,
    stack = true,
    close = true,
    description = 'A lighter for cigarettes'
},
```

---

### Option 2: qb-inventory

**Set in config.lua:**
```lua
Config.Inventory = 'qb-inventory'
```

**Add items to `qb-core/shared/items.lua`:**
```lua
['redwoodcigs'] = {
    name = 'redwoodcigs',
    label = 'Redwood Cigarettes',
    weight = 50,
    type = 'item',
    image = 'redwoodcigs.png',
    unique = true, -- IMPORTANT: Must be true for metadata
    useable = true,
    shouldClose = true,
    combinable = nil,
    description = 'A pack of Redwood Cigarettes (20 cigarettes)'
},

['cardiaquecigs'] = {
    name = 'cardiaquecigs',
    label = 'Cardiaque Cigarettes',
    weight = 50,
    type = 'item',
    image = 'cardiaquecigs.png',
    unique = true,
    useable = true,
    shouldClose = true,
    combinable = nil,
    description = 'A pack of Cardiaque Cigarettes (20 cigarettes)'
},

['yukoncigs'] = {
    name = 'yukoncigs',
    label = 'Yukon Cigarettes',
    weight = 50,
    type = 'item',
    image = 'yukoncigs.png',
    unique = true,
    useable = true,
    shouldClose = true,
    combinable = nil,
    description = 'A pack of Yukon Cigarettes (20 cigarettes)'
},

['cigarette'] = {
    name = 'cigarette',
    label = 'Cigarette',
    weight = 10,
    type = 'item',
    image = 'cigarette.png',
    unique = false,
    useable = true,
    shouldClose = true,
    combinable = nil,
    description = 'A single use cancer stick'
},

['lighter'] = {
    name = 'lighter',
    label = 'Lighter',
    weight = 50,
    type = 'item',
    image = 'lighter.png',
    unique = false,
    useable = false,
    shouldClose = true,
    combinable = nil,
    description = 'A lighter for cigarettes'
},
```

**Register useable items in `qb-core/server/player.lua` or create `qb-core/server/items.lua`:**
```lua
QBCore.Functions.CreateUseableItem('redwoodcigs', function(source, item)
    TriggerClientEvent('sunny-cigs:cigarettes:client:UseCigPack', source, item)
end)

QBCore.Functions.CreateUseableItem('cardiaquecigs', function(source, item)
    TriggerClientEvent('sunny-cigs:cigarettes:client:UseCigPack', source, item)
end)

QBCore.Functions.CreateUseableItem('yukoncigs', function(source, item)
    TriggerClientEvent('sunny-cigs:cigarettes:client:UseCigPack', source, item)
end)

QBCore.Functions.CreateUseableItem('cigarette', function(source, item)
    TriggerClientEvent('sunny-cigs:cigarettes:client:UseCigarette', source, item)
end)
```

---

### Option 3: ps-inventory

**Set in config.lua:**
```lua
Config.Inventory = 'ps-inventory'
```

**Items configuration:** Same as qb-inventory - add items to `qb-core/shared/items.lua` and register useable items (follow qb-inventory instructions above).

**Note:** ps-inventory uses the same structure as qb-inventory.

---

## 4. Add to server.cfg

Add this line to your `server.cfg`:
```cfg
ensure sunny-cigs
```

**Important:** Make sure it loads AFTER your dependencies:
```cfg
ensure ox_lib
ensure ox_inventory  # or qb-inventory / ps-inventory
ensure qb-core       # if using qb-inventory or ps-inventory
ensure sunny-cigs
```

---

## 5. Restart Your Server

**Full server restart recommended**, or at minimum:
```
restart ox_inventory  # or qb-inventory / ps-inventory
restart qb-core       # if using QB
ensure sunny-cigs
```

---

## Configuration

All configuration is in `config.lua`:

### Inventory System Selection
```lua
-- Options: 'ox_inventory', 'qb-inventory', 'ps-inventory'
Config.Inventory = 'ox_inventory'
```

### Timing Settings
```lua
Config.PackOpenTime = 3 -- seconds to open cigarette pack
Config.LightCigTime = 2 -- seconds to light cigarette
```

### Stress Relief
```lua
Config.MinStress = 2 -- minimum stress relief per puff
Config.MaxStress = 5 -- maximum stress relief per puff
```

### Puff Settings
```lua
Config.MaxPuffs = 5 -- number of puffs before cigarette finishes
Config.AutoThrowAfterFinish = true -- auto throw after all puffs
```

### Key Bindings
```lua
Config.PuffKey = 38 -- E key (puff cigarette)
Config.ThrowKey = 47 -- G key (throw away)
```

### Cigarette Prop Options
```lua
-- Choose your cigarette prop:
Config.PropModel = `prop_amb_ciggy_01` -- Lit cigarette (recommended)
-- Config.PropModel = `prop_cs_ciggy_01` -- Unlit cigarette
-- Config.PropModel = `prop_cigarette_01` -- Cigarette butt
-- Config.PropModel = `ng_proc_cigarette01a` -- Alternative lit cigarette
```

### Prop Position (fine-tune if needed)
```lua
Config.PropBone = 28422 -- right hand bone
Config.PropOffset = vector3(0.0, 0.0, 0.0)
Config.PropRotation = vector3(0.0, 0.0, 0.0)

-- Alternative positions:
-- Between fingers:
-- Config.PropOffset = vector3(0.03, 0.01, 0.0)
-- Config.PropRotation = vector3(-90.0, 0.0, 0.0)

-- Left hand:
-- Config.PropBone = 60309
-- Config.PropOffset = vector3(0.02, 0.0, -0.02)
-- Config.PropRotation = vector3(0.0, 0.0, -20.0)
```

### Throw Animation Options
```lua
-- Current (right hand gesture):
Config.ThrowAnimation = {
    dict = "gestures@m@standing@casual",
    clip = "gesture_shrug_hard"
}

-- Alternative options (uncomment to use):
-- Config.ThrowAnimation = {
--     dict = "anim@mp_player_intupperwave",
--     clip = "idle_a" -- Right hand wave
-- }

-- Config.ThrowAnimation = {
--     dict = "friends@frl@ig_1",
--     clip = "wave_c" -- Right hand wave/dismiss
-- }
```

### Debug Mode
```lua
Config.Debug = true -- Set to false to disable console logs
```

---

## Usage

### For Players

1. **Get cigarettes from pack:**
   - Use a cigarette pack (redwoodcigs, cardiaquecigs, or yukoncigs)
   - Takes 3 seconds to open
   - Gives you 1 cigarette
   - Pack tracks uses (20 cigarettes per pack)

2. **Light and smoke:**
   - Use the cigarette item
   - You need a lighter in your inventory
   - Takes 2 seconds to light
   - Character enters smoking idle animation

3. **Take puffs:**
   - Press **E** to take a puff
   - Each puff relieves stress (2-5 points)
   - Smoke effect comes from mouth
   - UI shows remaining puffs (e.g., "4/5 left")

4. **Throw away:**
   - Press **G** to throw away the cigarette
   - Or finish all 5 puffs and it auto-throws (configurable)

### Admin Commands

- `/throwcig` - Manually throw away cigarette (for testing)

### Give Items (Examples)

**ox_inventory:**
```
/ox give @me redwoodcigs 1
/ox give @me lighter 1
```

**qb-inventory / ps-inventory:**
```
/giveitem [player_id] redwoodcigs 1
/giveitem [player_id] lighter 1
```

**Alternative:**
```
/give [player_id] redwoodcigs 1
/give [player_id] cardiaquecigs 1
/give [player_id] yukoncigs 1
/give [player_id] cigarette 5
/give [player_id] lighter 1
```

---

## Troubleshooting

### Cigarettes not being consumed

**ox_inventory:**
- Make sure `consume = 0` in items.lua for both packs and cigarettes
- Restart ox_inventory after making changes

**qb-inventory / ps-inventory:**
- Make sure useable items are registered in server files
- Check that items have `useable = true`
- Restart qb-core after making changes

### Pack metadata not tracking

**ox_inventory:**
- Make sure `stack = false` for cigarette packs in items.lua
- Delete old packs from inventory and spawn fresh ones

**qb-inventory / ps-inventory:**
- Make sure `unique = true` for cigarette packs in items.lua
- Clear inventory and spawn new packs

### Wrong inventory system loading

Check console when resource starts:
```
[SUNNY-CIGS] Client script loaded!
[SUNNY-CIGS] Using inventory: ox_inventory
```

If wrong inventory shows, double-check `Config.Inventory` in config.lua

### G key not throwing

- Check if another script is blocking G key
- Try changing `Config.ThrowKey` to 73 (X key) in config.lua
- Use `/throwcig` command as alternative
- Check F8 console for "G KEY PRESSED" debug message

### No smoke effect

- Particle effect uses native GTA particles
- Should work on all clients without additional downloads
- If missing, may be client-side issue

### Animation not playing

- Animations are native GTA animations
- If throw animation fails, it will throw without animation
- Try different throw animations in config.lua

### Lighter not being detected

**ox_inventory:**
- Item check uses `exports.ox_inventory:Search('count', 'lighter')`

**qb-inventory / ps-inventory:**
- Item check iterates through player inventory
- Make sure lighter item exists in shared/items.lua

### Debug Mode

Enable debug mode to see detailed console logs:
```lua
Config.Debug = true
```

Check F8 console for colored debug messages showing:
- When items are used
- When puffs are taken
- When cigarette is thrown
- Inventory system being used
- Any errors or issues

**Console output should show:**
```
[SUNNY-CIGS] Client script loaded!
[SUNNY-CIGS] Using inventory: ox_inventory
[SUNNY-CIGS] UseCigarette triggered
[SUNNY-CIGS] E KEY PRESSED - Calling PuffCigarette
[SUNNY-CIGS] Puff #1/5 taken, stress relief: 4
```

---

## Integration with Other Scripts

### Stress System

The script triggers this event for stress relief:
```lua
TriggerServerEvent('hud:server:RelieveStress', amount)
```

**If your HUD uses a different event**, modify in `client/cigarettes.lua`:
- Line ~233: `TriggerServerEvent('hud:server:RelieveStress', stressRelief)`

**Common alternatives:**
```lua
-- QB-Core stress
TriggerServerEvent('hud:server:RelieveStress', stressRelief)

-- Custom stress event
TriggerServerEvent('yourscript:server:RemoveStress', stressRelief)

-- Client-side stress
TriggerEvent('yourscript:client:RemoveStress', stressRelief)
```

### Evidence System

The script triggers tobacco smell evidence:
```lua
TriggerEvent("evidence:client:SetStatus", "tobaccosmell", 300)
```

**If you don't use evidence system:**
- You can safely ignore/remove these lines
- Or modify for your evidence system

**Example modifications:**
```lua
-- PS Dispatch
exports['ps-dispatch']:SuspiciousActivity()

-- CD Dispatch
TriggerServerEvent('cd_dispatch:AddNotification', {/*...*/})

-- Remove if not needed
-- TriggerEvent("evidence:client:SetStatus", "tobaccosmell", 300)
```

---

## Adding Custom Cigarette Brands

### 1. Add item to your inventory system

**ox_inventory (`ox_inventory/data/items.lua`):**
```lua
['marlborocigs'] = {
    label = 'Marlboro Cigarettes',
    consume = 0,
    weight = 50,
    stack = false,
    close = true,
    description = 'A pack of Marlboro Cigarettes (20 cigarettes)',
    client = {
        event = 'sunny-cigs:cigarettes:client:UseCigPack'
    },
},
```

**qb-inventory (`qb-core/shared/items.lua`):**
```lua
['marlborocigs'] = {
    name = 'marlborocigs',
    label = 'Marlboro Cigarettes',
    weight = 50,
    type = 'item',
    image = 'marlborocigs.png',
    unique = true,
    useable = true,
    shouldClose = true,
    combinable = nil,
    description = 'A pack of Marlboro Cigarettes (20 cigarettes)'
},
```

### 2. Register useable item (qb-inventory/ps-inventory only)
```lua
QBCore.Functions.CreateUseableItem('marlborocigs', function(source, item)
    TriggerClientEvent('sunny-cigs:cigarettes:client:UseCigPack', source, item)
end)
```

### 3. Add item image

Place your image in the inventory images folder:
- **ox_inventory:** `ox_inventory/web/images/marlborocigs.png`
- **qb-inventory:** `qb-inventory/html/images/marlborocigs.png`
- **ps-inventory:** `ps-inventory/html/images/marlborocigs.png`

**That's it!** The script automatically handles all cigarette pack items.

---

## Performance

- **Resmon:** ~0.00ms idle, ~0.01-0.02ms while smoking
- **Props:** Automatically cleaned up after 5 seconds when thrown
- **Threads:** Only active while smoking, terminated when finished
- **Network:** Minimal - only syncs item removal/addition

---

## Known Limitations

1. **Cigarette prop position** may need fine-tuning for different character models
2. **Animations** are male-only (uses male smoking animations)
3. **Particle effects** may vary slightly between clients
4. **Inventory metadata** requires packs to be non-stackable

---

## FAQ

**Q: Can I change the number of cigarettes per pack?**  
A: Yes, change `Config.DefaultPackUses = 20` in config.lua

**Q: Can I disable the auto-throw feature?**  
A: Yes, set `Config.AutoThrowAfterFinish = false` in config.lua

**Q: Can I change the stress relief amount?**  
A: Yes, adjust `Config.MinStress` and `Config.MaxStress` in config.lua

**Q: Can I use this with ESX?**  
A: Not currently, but it can be adapted for ESX with some modifications

**Q: Do I need cigarette images?**  
A: Images are optional but recommended for better UX. Script works without them.

**Q: Can players smoke without a lighter?**  
A: No, the script requires a lighter item in inventory to use cigarettes

**Q: Does this work with custom HUD/stress systems?**  
A: Yes, just modify the stress relief event in client.lua (see Integration section)

**Q: Can I have different puff amounts for different cigarette types?**  
A: Currently no, but this can be added with custom modifications



## Support

For issues or questions:
1. ✅ Check this INSTALL.md first
2. ✅ Enable `Config.Debug = true` and check F8 console
3. ✅ Make sure all dependencies are up to date
4. ✅ Ensure items are configured correctly for your inventory system
5. ✅ Verify `Config.Inventory` matches your actual inventory
6. ✅ Contact TrueSunnyD in discord if all else fails https://discord.gg/q3Y6ZhTueJ

**Common fixes:**
- Restart your inventory system after adding items
- Clear old cigarette packs and spawn fresh ones
- Check server console for errors on resource start
- Verify all dependencies are running

---

## Changelog

### Version 1.0.0
- Initial release
- Multi-inventory support (ox_inventory, qb-inventory, ps-inventory)
- Manual puff system with configurable amounts
- Dynamic UI with puff counter
- Realistic animations and smoke effects
- Cigarette pack metadata tracking
- Auto-throw feature
- Stress relief integration
- Evidence system integration
- Debug mode for troubleshooting

---

**Enjoy your realistic smoking experience! 🚬**
