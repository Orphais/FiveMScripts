# Surgery Esthetic - FiveM Plastic Surgery System

A comprehensive plastic surgery system for FiveM RP servers using QB-Core, allowing authorized medical staff to perform permanent appearance changes on players.

## Features

- **Persistent PED Changes**: Surgery results persist after reconnection
- **Job-Based Authorization**: Only ambulance/doctor (grade 2+) can perform surgeries
- **Location-Based System**: Surgery available at specific hospital locations
- **Payment System**: Patient pays $5000, medic receives $500 commission
- **Audit Logging**: Complete database tracking of all surgeries
- **Modern UI**: Clean ox_lib context menus
- **Extensive PED Library**: 100+ male, female, and special models

## Requirements

- qb-core
- ox_lib
- oxmysql

## Installation

1. Place the `surgeryEsthetic` folder in your `resources/[Custom]` directory
2. Add `ensure surgeryEsthetic` to your `server.cfg`
3. Restart your server

The database table will be created automatically on first start.

## Configuration

Edit `config.lua` to customize:

- Authorized jobs and minimum grade
- Surgery price and commission
- Hospital locations
- Payment type (cash/bank)
- UI messages

## Usage

### For Medical Staff

1. Go to a hospital surgery location (Pillbox Hill or Sandy Shores)
2. Stand in the green marker
3. Press **E** to open the surgery menu
4. Select a nearby patient (automatic selection)
5. Choose a PED category (Male/Female/Special)
6. Select a specific model
7. Confirm the surgery

### Surgery Locations

- **Pillbox Hill Medical Center**: (298.22, -584.42, 43.26)
- **Sandy Shores Medical**: (357.43, -1415.68, 32.51)

## Admin Commands

- `/surgeryhistory [citizenid]` - View surgery history (admin only)
  - Without citizenid: Shows last 10 surgeries globally
  - With citizenid: Shows last 10 surgeries for that citizen

## Technical Details

### Persistence

The system uses QB-Core metadata to store the selected PED model:
- Saved on successful surgery
- Automatically applied on player spawn
- Persists across server restarts

### Database Schema

```sql
CREATE TABLE surgery_records (
    id INT AUTO_INCREMENT PRIMARY KEY,
    medic_citizenid VARCHAR(50),
    patient_citizenid VARCHAR(50),
    model VARCHAR(100),
    cost INT,
    date DATETIME
)
```

### Weapon Handling

The system automatically:
- Saves all player weapons before surgery
- Applies the new PED model
- Restores all weapons with their ammo

## File Structure

```
surgeryEsthetic/
├── fxmanifest.lua
├── config.lua
├── shared/
│   └── pedModels.lua
├── client/
│   ├── utils.lua
│   └── client.lua
└── server/
    ├── callbacks.lua
    └── server.lua
```

## Troubleshooting

### Surgery doesn't work
- Verify you have the correct job (ambulance/doctor)
- Check your grade is 2 or higher
- Ensure you're standing in the green marker
- Confirm patient has enough cash ($5000)

### PED doesn't persist
- Check server console for errors
- Verify oxmysql is running
- Check player metadata in database

### Menu doesn't open
- Verify ox_lib is running
- Check client console for errors
- Confirm job authorization in config

## Support

For issues or questions, check the server console for detailed error messages.
