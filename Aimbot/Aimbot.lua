--==[ SERVICES ]==--
local Workspace = cloneref(game:GetService("Workspace"))
local RunService = cloneref(game:GetService("RunService"))
local Players = cloneref(game:GetService("Players"))
local TweenService = cloneref(game:GetService("TweenService"))
local UserInputService = cloneref(game:GetService("UserInputService"))

--==[ VARIABLES ]==--
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local typing, running = false
local sens
local connections = {}

local Circle = Drawing.new("Circle")
setrenderproperty(Circle, "Visible", false)

local function getClosestPlayer(aimbotSettings)
    local closestPlayer, closestDistance = nil, math.huge
    for _, plr in ipairs(Players:GetPlayers()) do
        local character = plr.Character 
        if not character then continue end
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        local lockPart = character:FindFirstChild(aimbotSettings.HumanoidSettings.LockPart)

        if plr ~= LocalPlayer and character and lockPart and humanoid then
            local vector, os = Camera:WorldToViewportPoint(lockPart.Position)
            vector = Vector2.new(vector.X, vector.Y)
            local distance = (UserInputService:GetMouseLocation() - vector).Magnitude
            
            if distance < closestDistance and os and distance <= aimbotSettings.CircleSettings.Radius then
                closestPlayer, closestDistance = plr, distance
            end
        end
    end

    if not aimbotSettings.MainSettings.Locked then 
        aimbotSettings.MainSettings.Locked = closestPlayer
    end
end

local function endLock(aimbotSettings)
    aimbotSettings.MainSettings.Locked = nil

    setrenderproperty(Circle, "Color", aimbotSettings.CircleSettings.Color)
    UserInputService.MouseDeltaSensitivity = sens
end

connections.TypingStartedConnection = UserInputService.TextBoxFocused:Connect(function()
	typing = true
end)

connections.TypingEndedConnection = UserInputService.TextBoxFocusReleased:Connect(function()
    typing = false
end)

local Aimbot = {
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
        LockedColor = Color3.fromRGB(255, 100, 100)
    },
}

function Aimbot.Load(self)
    sens = UserInputService.MouseDeltaSensitivity

    connections.RenderStepped = RunService.RenderStepped:Connect(function()
        if self.MainSettings.Enabled and self.CircleSettings.Enabled then
            setrenderproperty(Circle, "Visible", true)
            setrenderproperty(Circle, "Radius", self.CircleSettings.Radius)
            setrenderproperty(Circle, "Thickness", 1)
            setrenderproperty(Circle, "Color", self.Locked and self.CircleSettings.LockedColor or self.CircleSettings.Color)
            setrenderproperty(Circle, "Position", UserInputService:GetMouseLocation())
        else
            setrenderproperty(Circle, "Visible", false)
        end

        if self.MainSettings.Enabled and running then
            getClosestPlayer(self)

            if self.MainSettings.Locked then
                local v3LockedPosition = self.MainSettings.Locked.Character:FindFirstChild(self.HumanoidSettings.LockPart).Position
                local lockedPosition = Camera.WorldToViewportPoint(Camera, v3LockedPosition)

                if self.MainSettings.LockMode == "CFrame" then
                    Camera.CFrame = CFrame.new(Camera.CFrame.Position, v3LockedPosition)
                elseif self.MainSettings.LockMode == "Mouse" then
                    mousemoverel(lockedPosition.X - UserInputService:GetMouseLocation().X, lockedPosition.Y - UserInputService:GetMouseLocation().Y)
                else
                    assert(nil, "Wrong Lock Mode!")
                end
                setrenderproperty(Circle, "Color", self.CircleSettings.LockedColor)
            end
        end
    end)

    connections.InputBeganConnection = UserInputService.InputBegan:Connect(function(input)
        if typing then return end

        if input.UserInputType == self.MainSettings.TriggerKey or input.KeyCode == self.MainSettings.TriggerKey then
            if self.MainSettings.Toggle then
                running = not running

                if not running then 
                    endLock(self)
                end
            else
                running = true
            end
        end
    end)

    connections.InputEndedConnection = UserInputService.InputEnded:Connect(function(input)
        if typing or self.MainSettings.Toggle then return end
        if input.UserInputType == self.MainSettings.TriggerKey or input.KeyCode == self.MainSettings.TriggerKey then
            running = false
            endLock(self)
        end
    end)
end

function Aimbot.Unload(self)
    for i, connection in pairs(connections) do
        if connection and connection.Connected then
            connection:Disconnect()
        end
    end

    setrenderproperty(Circle, "Visible", false)
end

return Aimbot