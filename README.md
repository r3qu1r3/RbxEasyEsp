# Roblox ESP Library Documentation

## Table of Contents
- [Overview](#overview)
- [Features](#features)
- [Installation](#installation)
- [Quick Start](#quick-start)
- [API Reference](#api-reference)
- [Configuration](#configuration)
- [Examples](#examples)
- [Performance](#performance)
- [Troubleshooting](#troubleshooting)

## Overview

The Roblox ESP (Extra Sensory Perception) Library is a comprehensive visual overlay system designed for Roblox games. It provides advanced rendering capabilities including player tracking, part highlighting, 3D bounding boxes, health bars, and various visual indicators.

### Key Capabilities
- **Player ESP**: Track players with boxes, tags, health bars, and pointers
- **Part ESP**: Highlight game objects and parts with customizable visual elements
- **3D Rendering**: Advanced 3D bounding boxes and wireframe overlays
- **Performance Optimized**: Efficient rendering with caching and culling systems
- **Highly Customizable**: Extensive configuration options for all visual elements

## Features

### Visual Elements
- **2D Bounding Boxes**: Outline players and objects with customizable colors and thickness
- **3D Wireframe Boxes**: Full 3D bounding box visualization
- **Health Bars**: Real-time health display with color coding
- **Name Tags**: Customizable text labels with distance scaling
- **Off-screen Pointers**: Triangular indicators for targets outside viewport
- **Backtracking**: Visual trail system showing player movement history
- **Drawing Chams**: X-ray style rendering through walls

### Advanced Features
- **Team Detection**: Automatic team-based filtering and coloring
- **Occlusion Detection**: Dynamic visibility checking through raycast
- **Fade Animations**: Smooth fade-out effects for disappearing targets
- **Performance Monitoring**: Built-in FPS and render time statistics
- **Multi-target Support**: Handle multiple players and parts simultaneously

## Installation

1. **Load the Module**:
```lua
local Esp = require(path.to.EspModule)
```

2. **Initialize Player ESP**:
```lua
Esp.PlayerUtils:DefaultLoad()
```

3. **Start Rendering** (if not using DefaultLoad):
```lua
coroutine.wrap(function()
    while true do
        task.wait()
        Esp:Render()
    end
end)()
```

## Quick Start

### Basic Player ESP Setup
```lua
local Esp = require(script.EspLibrary)

-- Load with default settings
Esp.PlayerUtils:DefaultLoad()

-- Customize player settings
Esp.PlayerUtils.Settings.Box.InlineColor = Color3.fromRGB(0, 255, 0)
Esp.PlayerUtils.Settings.Tag.Enabled = true
Esp.PlayerUtils.Settings.Health.Enabled = true
```

### Basic Part ESP Setup
```lua
-- Create a settings group for specific parts
local ChestSettings = Esp.PartUtils:CreateSettingsGroup("Chests")
ChestSettings.Box.InlineColor = Color3.fromRGB(255, 255, 0)
ChestSettings.GetTagData = function(part) return "Treasure Chest" end

-- Apply ESP to a part
local chestPart = workspace.TreasureChest
Esp.PartUtils.CreateObject(chestPart, "Chests")
```

## API Reference

### Core ESP Object

#### Methods

##### `Esp:Draw(Class, Properties)` → Drawing
Creates a new Drawing object with specified properties and registers it for cleanup.

**Parameters:**
- `Class` (string): Drawing class type ("Line", "Square", "Triangle", etc.)
- `Properties` (table): Optional properties to apply to the drawing

**Returns:** Drawing object with added FadeFrame property

##### `Esp:MassDraw(Class, Properties, Quantity)` → table
Creates multiple Drawing objects of the same type.

**Parameters:**
- `Class` (string): Drawing class type
- `Properties` (table): Properties to apply to all drawings
- `Quantity` (number): Number of drawings to create

**Returns:** Array of Drawing objects

##### `Esp:Edit(Object, Properties)`
Applies multiple properties to a Drawing or Instance object.

**Parameters:**
- `Object`: Target object to modify
- `Properties` (table): Key-value pairs of properties to set

##### `Esp:GroupEdit(Drawings, Properties)`
Applies properties to multiple Drawing objects simultaneously.

**Parameters:**
- `Drawings` (table): Array of Drawing objects
- `Properties` (table): Properties to apply to all objects

##### `Esp:Render()` → number
Main rendering function that updates all ESP elements. Returns render time in seconds.

### Player Utils

#### Settings Structure
```lua
Esp.PlayerUtils.Settings = {
    General = {
        DrawTeam = true,           -- Draw team members
        MasterSwitch = true,       -- Enable/disable all player ESP
        CheckHealth = true,        -- Hide dead players
        FadeOut = false,          -- Fade out instead of instant hide
        FadeStep = 100            -- Fade animation speed
    },
    Box = {
        Enabled = true,           -- Show bounding boxes
        Transparency = 1,         -- Box transparency (0-1)
        InlineColor = Color3.fromRGB(255, 255, 255),
        OutlineColor = Color3.fromRGB(0, 0, 0),
        InlineThickness = 1       -- Box border thickness
    },
    Box3D = {
        Enabled = true,           -- Show 3D wireframe boxes
        Color = Color3.fromRGB(32, 42, 68),
        Filled = true,            -- Fill faces or wireframe only
        Transparency = 0          -- 3D box transparency
    },
    Tag = {
        Enabled = true,           -- Show name tags
        Transparency = 1,
        InlineColor = Color3.fromRGB(255, 255, 255),
        Font = 3,                 -- Text font (0-3)
        Scale = 0.2,             -- Size scaling factor
        Outline = true,           -- Text outline
        Min = 10,                -- Minimum text size
        Max = 18                 -- Maximum text size
    },
    Health = {
        Enabled = true,           -- Show health bars
        OutlineColor = Color3.fromRGB(0, 0, 0),
        InlineColor = Color3.fromRGB(0, 255, 0),
        Transparency = 1,
        OutlineThickness = 3,     -- Health bar border
        Scale = 0.02,            -- Width scaling
        Offset = 1,              -- Distance from box
        Min = 1,                 -- Minimum width
        Max = 2                  -- Maximum width
    },
    Pointer = {
        Enabled = true,           -- Show off-screen pointers
        Color = Color3.fromRGB(255, 255, 255),
        Filled = true,
        Transparency = 0.5,
        Radius = 100,            -- Distance from screen center
        Size = Vector2.new(10, 10) -- Pointer size
    },
    Backtrack = {
        Enabled = true,           -- Show movement trail
        PointColor = Color3.fromRGB(255, 255, 255),
        ConnectorColor = Color3.fromRGB(20, 20, 20),
        DeletionDelay = 0.4,     -- How long trails persist
        UpdateDelay = 0.1        -- Trail update frequency
    },
    DrawingChams = {
        Enabled = false,          -- X-ray rendering
        Color = Color3.fromRGB(255, 255, 255),
        OccludedColor = Color3.fromRGB(0, 0, 0),
        Dynamic = true,           -- Change color when occluded
        Transparency = 0.5,
        Filled = false
    }
}
```

#### Methods

##### `Esp.PlayerUtils.CreateObject(Player)` → boolean
Creates ESP tracking for a specific player.

**Parameters:**
- `Player`: Roblox Player object to track

**Returns:** Success boolean

##### `Esp.PlayerUtils:DefaultLoad()`
Automatically loads ESP for all current players and sets up new player detection.

##### `Esp.PlayerUtils:UpdatePlayerCache()`
Updates all player ESP elements. Called automatically by `Esp:Render()`.

##### `Esp.PlayerUtils.GetTeam(Player, Character)` → Team
Gets the team of a player.

##### `Esp.PlayerUtils.GetHealth(Player, Character)` → number, number
Returns current health and max health of a player.

##### `Esp.PlayerUtils.GetTagData(Player, Character)` → string
Generates display text for player tags.

### Part Utils

#### Methods

##### `Esp.PartUtils:CreateSettingsGroup(Name)` → table
Creates a new settings configuration group for parts.

**Parameters:**
- `Name` (string): Unique identifier for the settings group

**Returns:** Settings table that can be customized

##### `Esp.PartUtils.CreateObject(Part, Group)` → table
Creates ESP tracking for a game part.

**Parameters:**
- `Part`: BasePart or Model to track
- `Group` (string): Settings group name (defaults to "Default")

**Returns:** ESP data object with Destruct method

##### `Esp.PartUtils:UpdatePartCache()`
Updates all part ESP elements. Called automatically by `Esp:Render()`.

### Utility Functions

#### `Esp.Utils.Get3DInstanceCorners(Object, Convert2D, Offsets)` → table
Calculates the 8 corner positions of an object's bounding box.

**Parameters:**
- `Object`: BasePart or Model
- `Convert2D` (boolean): Convert to screen coordinates
- `Offsets` (table): Optional CFrame offsets for each corner

**Returns:** Array of 8 corner positions (Vector3 or Vector2)

#### `Esp.Utils.Get2DBoundingBox(Model)` → boolean, number, number, number, number
Calculates 2D screen space bounding box for an object.

**Returns:** InFov, MinX, MaxX, MinY, MaxY

#### `Esp.Utils.IsPositionOccluded(Position, ...)` → RaycastResult
Checks if a position is occluded by geometry using raycasting.

**Parameters:**
- `Position` (Vector3): World position to check
- `...`: Objects to ignore in raycast

**Returns:** RaycastResult if occluded, nil if clear

#### `Esp.Utils.ResolvePointerPoints(Position, Dimensions)` → table
Calculates triangle points for off-screen directional pointers.

**Parameters:**
- `Position` (Vector3): Target world position
- `Dimensions` (table): `{Radius = number, Size = Vector2}`

**Returns:** Table with PointA, PointB, PointC for triangle

## Configuration

### Default Settings Groups

The library uses a settings group system for easy configuration management:

```lua
-- Access default settings
local defaultSettings = Esp.DefaultSettingGroup

-- Create custom settings group for parts
local customGroup = Esp.PartUtils:CreateSettingsGroup("CustomParts")
customGroup.Box.InlineColor = Color3.fromRGB(255, 0, 255)
customGroup.GetTagData = function(part) return "Custom: " .. part.Name end
```

### Validation Functions

Each settings group includes a `Validate` function to determine which objects should have ESP:

```lua
-- Only show ESP for parts named "Chest"
customGroup.Validate = function(object)
    return object.Name == "Chest"
end

-- Show ESP for parts with specific attributes
customGroup.Validate = function(object)
    return object:GetAttribute("ShowESP") == true
end
```

### Color Customization

Colors use Roblox's Color3 system:

```lua
-- RGB values (0-255)
Esp.PlayerUtils.Settings.Box.InlineColor = Color3.fromRGB(255, 128, 0)

-- HSV values (0-1)
Esp.PlayerUtils.Settings.Box.InlineColor = Color3.fromHSV(0.5, 1, 1)

-- Predefined colors
Esp.PlayerUtils.Settings.Box.InlineColor = Color3.new(1, 0, 0) -- Red
```

## Examples

### Advanced Player ESP Configuration

```lua
local Esp = require(script.EspLibrary)

-- Configure advanced player settings
local playerSettings = Esp.PlayerUtils.Settings

-- Team-based coloring
playerSettings.General.DrawTeam = false  -- Don't show teammates

-- Enhanced visual elements
playerSettings.Box.Enabled = true
playerSettings.Box.InlineColor = Color3.fromRGB(0, 255, 255)
playerSettings.Box3D.Enabled = true
playerSettings.Health.Enabled = true
playerSettings.Backtrack.Enabled = true
playerSettings.Pointer.Enabled = true

-- Custom tag information
Esp.PlayerUtils.GetTagData = function(player, character)
    local distance = (character.PrimaryPart.Position - game.Players.LocalPlayer.Character.PrimaryPart.Position).Magnitude
    return string.format("%s\nDistance: %.1fm", player.Name, distance)
end

-- Initialize
Esp.PlayerUtils:DefaultLoad()
```

### Multi-Group Part ESP System

```lua
local Esp = require(script.EspLibrary)

-- Create different ESP groups for different item types
local weaponSettings = Esp.PartUtils:CreateSettingsGroup("Weapons")
weaponSettings.Box.InlineColor = Color3.fromRGB(255, 0, 0)
weaponSettings.GetTagData = function(part) return "🗡️ " .. part.Name end
weaponSettings.Validate = function(part) return part:FindFirstChild("WeaponScript") end

local treasureSettings = Esp.PartUtils:CreateSettingsGroup("Treasure")
treasureSettings.Box.InlineColor = Color3.fromRGB(255, 215, 0)
treasureSettings.Box3D.Enabled = true
treasureSettings.GetTagData = function(part) return "💰 Treasure" end
treasureSettings.Validate = function(part) return part.Name:match("Chest") or part.Name:match("Gold") end

-- Apply ESP to workspace objects
for _, obj in pairs(workspace:GetDescendants()) do
    if obj:IsA("BasePart") then
        if weaponSettings.Validate(obj) then
            Esp.PartUtils.CreateObject(obj, "Weapons")
        elseif treasureSettings.Validate(obj) then
            Esp.PartUtils.CreateObject(obj, "Treasure")
        end
    end
end

-- Start rendering
coroutine.wrap(function()
    while true do
        task.wait()
        Esp:Render()
    end
end)()
```

### Dynamic ESP Toggle System

```lua
local Esp = require(script.EspLibrary)
local UserInputService = game:GetService("UserInputService")

-- Initialize ESP
Esp.PlayerUtils:DefaultLoad()

-- Toggle functions
local function togglePlayerESP()
    Esp.PlayerUtils.Settings.General.MasterSwitch = not Esp.PlayerUtils.Settings.General.MasterSwitch
    print("Player ESP:", Esp.PlayerUtils.Settings.General.MasterSwitch and "ON" or "OFF")
end

local function toggleHealthBars()
    Esp.PlayerUtils.Settings.Health.Enabled = not Esp.PlayerUtils.Settings.Health.Enabled
    print("Health bars:", Esp.PlayerUtils.Settings.Health.Enabled and "ON" or "OFF")
end

-- Keybinds
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.F1 then
        togglePlayerESP()
    elseif input.KeyCode == Enum.KeyCode.F2 then
        toggleHealthBars()
    elseif input.KeyCode == Enum.KeyCode.F3 then
        Esp.DebugStats = not Esp.DebugStats
    end
end)
```

## Performance

### Optimization Features

The ESP library includes several performance optimizations:

1. **Viewport Culling**: Objects outside the camera view are not rendered
2. **Distance Culling**: Optional distance-based hiding for far objects
3. **Health Checking**: Automatic hiding of dead players
4. **Object Caching**: Efficient storage and lookup of ESP data
5. **Batch Operations**: Group property updates for better performance

### Performance Monitoring

Enable debug statistics to monitor performance:

```lua
Esp.DebugStats = true  -- Shows render time, FPS, and object count
```

### Performance Tips

1. **Disable Unused Features**: Turn off features you don't need
   ```lua
   Esp.PlayerUtils.Settings.Backtrack.Enabled = false
   Esp.PlayerUtils.Settings.DrawingChams.Enabled = false
   ```

2. **Limit Update Frequency**: Reduce render frequency for better performance
   ```lua
   coroutine.wrap(function()
       while true do
           task.wait(1/30)  -- 30 FPS instead of max framerate
           Esp:Render()
       end
   end)()
   ```

3. **Use Validation Functions**: Filter objects efficiently
   ```lua
   -- Only track players within certain distance
   Esp.PlayerUtils.Settings.Validate = function(player)
       local character = player.Character
       if not character or not character.PrimaryPart then return false end
       local distance = (character.PrimaryPart.Position - game.Players.LocalPlayer.Character.PrimaryPart.Position).Magnitude
       return distance < 500
   end
   ```

## Troubleshooting

### Common Issues

#### ESP Not Appearing
- Ensure `MasterSwitch` is enabled in settings
- Check that the `Validate` function returns true for target objects
- Verify objects are within camera view
- Confirm `Esp:Render()` is being called in a loop

#### Performance Issues
- Disable unused features (Backtrack, DrawingChams, 3D boxes)
- Reduce render frequency
- Limit the number of tracked objects
- Use validation functions to filter objects

#### Health Bars Not Showing
```lua
-- Ensure health bar settings are properly configured
Esp.PlayerUtils.Settings.Health.Enabled = true
Esp.PlayerUtils.Settings.Health.Scale = 0.02  -- Adjust if too small
```

#### Tags Cut Off or Misaligned
```lua
-- Adjust tag scaling and positioning
Esp.PlayerUtils.Settings.Tag.Scale = 0.3
Esp.PlayerUtils.Settings.Tag.Min = 12
Esp.PlayerUtils.Settings.Tag.Max = 24
```

### Debug Information

The library provides debug output when enabled:

```lua
Esp.DebugStats = true
```

This displays:
- Number of drawing objects created
- Render time in milliseconds  
- Current rendering FPS

### Memory Management

The library automatically cleans up drawing objects when players leave or parts are destroyed. To manually clean up:

```lua
-- Clean up all ESP objects
for _, drawing in pairs(Esp.__Drawings) do
    drawing:Remove()
end
Esp.__Drawings = {}

for _, instance in pairs(Esp.__Instances) do
    instance:Destroy()
end
Esp.__Instances = {}
```

---

*This documentation covers the core functionality of the ESP library. For advanced usage or custom modifications, refer to the source code comments and function implementations.*
