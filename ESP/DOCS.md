
# Celestial ESP

Public ESP library, based on **Sense** by Sirius but lightweight and more stable.

## How to use

```lua
local ESP = loadstring(game:HttpGet("https://raw.githubusercontent.com/Celestial-Core-Official/Public-API/refs/heads/main/ESP/CelestialESP.lua"))()

ESP.humanoidSettings.humanoid.enabled = true

ESP:Load()

--ESP:Unload() 
```


## Settings

```lua
ESP = {
	mainSettings = {
		textSize = 13,
		textFont = 2,
		limitDistance = false,
		maxDistance = 100,
		teamColor = false 
	},
	humanoidSettings = {
		humanoid = {
			enabled = false, 
			box = false,
			boxColor = { Color3.new(0.117, 0.564, 1), 1 },
			boxOutline = false,
			boxOutlineColor = { Color3.new(), 1 },
			boxFill = false,
			boxFillColor = { Color3.new(0.117, 0.564, 1), 0.5 },
			healthBar = false,
			healthyColor = Color3.new(0,1,0),
			dyingColor = Color3.new(1,0,0),
			healthBarOutline = true,
			healthBarOutlineColor = { Color3.new(), 0.5 },
			healthText = false,
			healthTextColor = { Color3.new(1,1,1), 1 },
			healthTextOutline = true,
			healthTextOutlineColor = Color3.new(),
			box3d = false,
			box3dColor = { Color3.new(0.117, 0.564, 1), 1 },
			name = false,
			nameColor = { Color3.new(0.117, 0.564, 1), 1 },
			nameOutline = true,
			nameOutlineColor = Color3.new(),
			distance = false,
			distanceColor = { Color3.new(0.117, 0.564, 1), 1 },
			distanceOutline = true,
			distanceOutlineColor = Color3.new(),
			tracer = false, 
			tracerOrigin = "Mouse",
			tracerColor = { Color3.new(0.117, 0.564, 1), 1 },
			tracerOutline = true,
			tracerOutlineColor = { Color3.new(), 1 },
			offScreenArrow = false,
			offScreenArrowColor = { Color3.new(1,1,1), 1 },
			offScreenArrowSize = 15,
			offScreenArrowRadius = 150,
			offScreenArrowOutline = true,
			offScreenArrowOutlineColor = { Color3.new(), 1 },
			skeleton = false
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


## Authors

- [@Dzolat](https://www.github.com/Dzolat)

