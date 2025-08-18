
# Celestial ESP

Public Aimbot library.

## How to use

```lua
local ESP = loadstring(game:HttpGet("https://raw.githubusercontent.com/Celestial-Core-Official/Public-API/refs/heads/main/ESP/CelestialESP.lua"))()

ESP.humanoidSettings.humanoid.enabled = true

ESP:Load()

--ESP:Unload() 
```
### Example
```lua
local ESP = loadstring(game:HttpGet("https://raw.githubusercontent.com/Celestial-Core-Official/Public-API/refs/heads/main/ESP/CelestialESP.lua"))()

ESP.humanoidSettings.humanoid.enabled = true
ESP.humanoidSettings.humanoid.box3d = true
ESP.humanoidSettings.humanoid.tracer = true
ESP.humanoidSettings.humanoid.tracerOrigin = "Middle"
ESP.humanoidSettings.humanoid.skeleton = true

ESP:Load()
```

## Settings

```lua
ESP = {
	espUsers = {} -- If u put player instances here, it will show only them
	mainSettings = {
		textSize = 13, -- Global text size for all text
		textFont = 2,
		limitDistance = false, -- If enabled ESP will only show for users that are {maxDistance} away
		maxDistance = 100,
		teamColor = false -- If enabled all future color checks wont be used and everything will be colored via the players team color
	},
	humanoidSettings = {
		humanoid = {
			enabled = false, -- Is ESP enabled
			box = false, -- Is a 2D box enabled
			boxColor = { Color3.new(0.117, 0.564, 1), 1 },
			boxOutline = false, 
			boxOutlineColor = { Color3.new(), 1 },
			boxFill = false, 
			boxFillColor = { Color3.new(0.117, 0.564, 1), 0.5 },
			healthBar = false, -- Is a health bar enabled
			healthyColor = Color3.new(0,1,0),
			dyingColor = Color3.new(1,0,0),
			healthBarOutline = true,
			healthBarOutlineColor = { Color3.new(), 0.5 },
			healthText = false,
			healthTextColor = { Color3.new(1,1,1), 1 },
			healthTextOutline = true,
			healthTextOutlineColor = Color3.new(),
			box3d = false, -- Is a 3D box enabled
			box3dColor = { Color3.new(0.117, 0.564, 1), 1 },
			name = false, -- Is a name shown
			nameColor = { Color3.new(0.117, 0.564, 1), 1 },
			nameOutline = true,
			nameOutlineColor = Color3.new(),
			distance = false, -- Is the distance shown
			distanceColor = { Color3.new(0.117, 0.564, 1), 1 },
			distanceOutline = true,
			distanceOutlineColor = Color3.new(),
			tracer = false, -- Is a tracer shown
			tracerOrigin = "Mouse", -- Bottom/Middle/Top (screen position) | Mouse (follows mouse)
			tracerColor = { Color3.new(0.117, 0.564, 1), 1 },
			tracerOutline = true,
			tracerOutlineColor = { Color3.new(), 1 },
			offScreenArrow = false, -- Are off screen arrows shown
			offScreenArrowColor = { Color3.new(1,1,1), 1 },
			offScreenArrowSize = 15,
			offScreenArrowRadius = 150,
			offScreenArrowOutline = true,
			offScreenArrowOutlineColor = { Color3.new(), 1 },
			skeleton = false -- Is a skeleton shown
			skeletonColor = { Color3.new(0.117, 0.564, 1), 1 },
			skeletonOutline = true
			skeletonOutlineColor = { Color3.new(), 1}
		},
	}
}
```

## Features

**2D Box** – Draws flat boxes around players.

**3D Box** – Creates a 3D wireframe around the character’s hitbox.

**Tracers** – Lines from your screen (mouse, bottom, top, or center) pointing to players.

**Off-Screen Arrows** – Arrows at your screen showing where players are located.

**Health Bar** – Vertical bar showing player health with colors scaling from green to red.

**Health Text** – Displays health above the player.

**Specific users only** - You can set which users to ESP only.

## Authors

- [@Dzolat](https://www.github.com/Dzolat)

