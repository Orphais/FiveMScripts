# Installation & Testing Guide

## Quick Start

### 1. Installation
```bash
# The resource is ready to use
# Just add to your server.cfg:
ensure surgeryEsthetic
```

### 2. Verify Dependencies
Make sure these resources are running:
- ✅ qb-core
- ✅ ox_lib
- ✅ oxmysql

### 3. Restart Server
```bash
restart surgeryEsthetic
```

## Testing Checklist

### Basic Functionality
- [ ] Resource starts without errors
- [ ] Database table `surgery_records` is created
- [ ] Blips appear at hospitals (green medical icons)
- [ ] Green markers visible at surgery locations

### Authorization Tests
```bash
# In-game console commands for testing:
/setjob [yourID] ambulance 2    # Set yourself as medic
/setjob [yourID] ambulance 1    # Test insufficient grade (should fail)
/setjob [yourID] police 4       # Test unauthorized job (should fail)
```

- [ ] Ambulance grade 2+ can open menu
- [ ] Doctor grade 2+ can open menu
- [ ] Lower grades cannot access
- [ ] Other jobs cannot access

### Surgery Flow Test
1. [ ] Set yourself as authorized medic
2. [ ] Go to Pillbox Hill: `/tp 298.22 -584.42 43.26`
3. [ ] Stand in green marker
4. [ ] See "[E] Open Surgery Menu" text
5. [ ] Press E to open menu
6. [ ] Have another player stand nearby (<5m)
7. [ ] Select "Select Patient"
8. [ ] Patient is auto-selected
9. [ ] Patient receives notification
10. [ ] Select "Perform Surgery"
11. [ ] Choose category (Male/Female/Special)
12. [ ] Choose specific model
13. [ ] Confirm surgery
14. [ ] Progress bar shows "Performing surgery..."
15. [ ] Surgery completes
16. [ ] Patient's appearance changes
17. [ ] Patient's weapons are preserved
18. [ ] Patient is charged $5000 cash
19. [ ] Medic receives $500 commission
20. [ ] Both receive success notifications

### Persistence Test
1. [ ] Perform a surgery on a player
2. [ ] Have that player disconnect
3. [ ] Player reconnects
4. [ ] Player spawns with the surgically-changed PED
5. [ ] Weapons are intact

### Database Test
```sql
# Check if records are being saved:
SELECT * FROM surgery_records ORDER BY date DESC LIMIT 5;

# Check player metadata:
SELECT citizenid, JSON_EXTRACT(metadata, '$.surgeryPed') as surgeryPed
FROM players
WHERE JSON_EXTRACT(metadata, '$.surgeryPed') IS NOT NULL;
```

### Admin Commands Test
```bash
/surgeryhistory              # View last 10 surgeries
/surgeryhistory ABC12345     # View surgeries for specific citizen
```

- [ ] Command shows surgery history
- [ ] Data appears in server console
- [ ] Non-admins cannot use command

## Common Test Scenarios

### Test 1: Insufficient Funds
```lua
-- Remove money from patient first
/removemoney cash 10000

-- Try surgery (should fail with "insufficient funds")
```

### Test 2: Distance Check
```lua
-- Stand far from patient (>5m)
-- Try to select patient (should fail with "no player nearby")
```

### Test 3: Multiple Surgeries
```lua
-- Perform surgery on same patient multiple times
-- Each time should overwrite previous PED
-- Check database for multiple records
```

### Test 4: Special Models
```lua
-- Try applying special models (animals, aliens)
-- Verify weapons still work
-- Verify persistence works
```

## Troubleshooting

### Resource won't start
```bash
# Check for syntax errors:
restart surgeryEsthetic

# Look for errors in server console
# Common issues:
# - Missing dependencies
# - Incorrect file permissions
# - MySQL connection issues
```

### Menu doesn't open
```lua
-- F8 console commands:
resmon                    # Check if ox_lib is running
restart ox_lib           # Restart ox_lib if needed
```

### PED doesn't persist
```sql
-- Check if metadata is being saved:
SELECT metadata FROM players WHERE citizenid = 'YOUR_CID';

-- Look for: "surgeryPed": "model_name"
```

### Database errors
```bash
# Verify MySQL connection
restart oxmysql

# Check if table exists
SHOW TABLES LIKE 'surgery_records';

# Check table structure
DESCRIBE surgery_records;
```

## Performance Notes

- Markers update every frame when in zone (0ms wait)
- When out of zone: 1000ms wait (low CPU usage)
- Models are loaded on-demand and unloaded after use
- Database queries are async (non-blocking)

## Support Checklist

If reporting issues, provide:
1. [ ] Server console output (errors)
2. [ ] Client F8 console output
3. [ ] QB-Core version
4. [ ] ox_lib version
5. [ ] oxmysql version
6. [ ] Steps to reproduce
7. [ ] Expected vs actual behavior

## Quick Debug Commands

```bash
# Server console:
resmon                          # Check resource usage
restart surgeryEsthetic        # Restart the resource

# In-game F8 console:
/setjob [id] ambulance 2       # Set test job
/tp 298.22 -584.42 43.26      # TP to Pillbox surgery
/tp 357.43 -1415.68 32.51     # TP to Sandy surgery
```

## Success Criteria

✅ All files created correctly
✅ No syntax errors on start
✅ Database table created
✅ Blips and markers visible
✅ Authorization working
✅ Patient selection working
✅ Surgery completes successfully
✅ Payment processed
✅ PED persists after reconnect
✅ Audit log working
✅ Admin commands working

## Next Steps

1. Test all functionality with the checklist above
2. Adjust config.lua settings as needed
3. Add more PED models if desired (edit shared/pedModels.lua)
4. Customize messages in config.lua
5. Consider adding more surgery locations

## Configuration Examples

### Add a new surgery location:
```lua
-- In config.lua, add to Config.surgeryLocations:
{
    coords = vector3(x, y, z),
    radius = 2.0,
    label = "Your Hospital Surgery",
    blip = {
        sprite = 403,
        color = 2,
        scale = 0.8,
        display = 4
    }
}
```

### Change pricing:
```lua
Config.surgeryPrice = 10000      -- Patient pays more
Config.medicCommission = 2000    -- Medic gets more commission
```

### Change authorized jobs:
```lua
Config.authorizedJobs = {
    ['ambulance'] = true,
    ['doctor'] = true,
    ['ems'] = true,           -- Add more jobs
}
Config.minimumGrade = 3          -- Require higher grade
```
