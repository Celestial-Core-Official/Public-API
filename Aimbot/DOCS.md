
# Celestial ESP

Public Aimbot library.

## How to use

```lua
local Aimbot = loadstring(game:HttpGet("https://raw.githubusercontent.com/Celestial-Core-Official/Public-API/refs/heads/main/Aimbot/Aimbot.lua"))()

Aimbot.MainSettings.Enabled = true
Aimbot.CircleSettings.Enabled = true

Aimbot:Load()

--Aimbot:Unload() 
```
## Settings

```lua
Aimbot = {
    MainSettings = {
        Enabled = false,
        LockMode = "CFrame", -- CFrame, Mouse
        TriggerKey = Enum.UserInputType.MouseButton2,
        Toggle = false
    },
    HumanoidSettings = {
        LockPart = "Head",
    },
    CircleSettings = {
        Enabled = false,
        Radius = 90, 
        Color = Color3.fromRGB(255, 255, 255),
        LockedColor = Color3.fromRGB(255, 50, 50)
    },
}
```

## Authors

- [@Dzolat](https://www.github.com/Dzolat)

