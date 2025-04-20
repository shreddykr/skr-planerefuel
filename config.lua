Config = {}

-- Select the fuel system to use: "LegacyFuel", "cdn-fuel", "lc_fuel"
-- To add custom fuel script find your fuel scripts export and add it to the client lua
Config.FuelScript = 'lc_fuel'

-- Refuel zones, define where the refueling spots are
--{coords = vector3(x, x, x), label = 'Vespucci Heli Pads', blip = {sprite = 361, color = 3, name = 'Air Fuel', scale = 0.8}}

Config.RefuelZones = {
    {coords = vector3(-996.18, -2898.32, 14.58), label = 'LSIA Jet Fuel Pumps'},
    {coords = vector3(1751.5, 3289.62, 41.7), label = 'Sandy Airfield'},

    --{coords = vector3(-3245.4, 7439.51, 45.23), label = 'Roxwood Airport'},
}

-- The cost to refuel the aircraft to 100%
Config.RefuelCost = 2500

-- (100 = full tank)
Config.RefuelAmount = 100
