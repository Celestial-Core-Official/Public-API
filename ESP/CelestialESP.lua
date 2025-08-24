--==[ SERVICES ]==--
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local UserInputService = game:getService("UserInputService")

--==[ VARIABLES ]==--
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local ViewportSize = Camera.ViewportSize
local toOrientation = CFrame.identity.ToOrientation
local v2Min, v2Max, v2Lerp = Vector2.zero.Min, Vector2.zero.Max, Vector2.zero.Lerp
local v3Min, v3Max = Vector3.zero.Min, Vector3.zero.Max
local floor, round, sin, cos = math.floor, math.round, math.sin, math.cos
local clear, unpack, find, create = table.clear, table.unpack, table.find, table.create

local HEALTH_BAR_OFFSET = Vector2.new(5, 0)
local HEALTH_TEXT_OFFSET = Vector2.new(3, 0)
local HEALTH_BAR_OUTLINE_OFFSET = Vector2.new(0, 1)
local NAME_OFFSET = Vector2.new(0, 2)
local DISTANCE_OFFSET = Vector2.new(0, 2)
local VERTICES = {
	Vector3.new(-1, -1, -1),
	Vector3.new(-1, 1, -1),
	Vector3.new(-1, 1, 1),
	Vector3.new(-1, -1, 1),
	Vector3.new(1, -1, -1),
	Vector3.new(1, 1, -1),
	Vector3.new(1, 1, 1),
	Vector3.new(1, -1, 1)
}

--==[ FUNCTIONS ]==--
local function getMousePos()
	return UserInputService:GetMouseLocation()
end
local function isBodyPart(name)
	return name == "Head" or name:find("Torso") or name:find("Leg") or name:find("Arm")
end

local function getBoundingBox(parts)
	local min, max
	for i = 1, #parts do
		local part = parts[i]
		local cframe, size = part.CFrame, part.Size

		min = v3Min(min or cframe.Position, (cframe - size*0.5).Position)
		max = v3Max(max or cframe.Position, (cframe + size*0.5).Position)
	end

	local center = (min + max)*0.5
	local front = Vector3.new(center.X, center.Y, max.Z)
	return CFrame.new(center, front), max - min
end

local function worldToScreen(world)
	local screen, inBounds = Camera.WorldToViewportPoint(Camera, world)
	return Vector2.new(screen.X, screen.Y), inBounds, screen.Z
end

local function calculateCorners(cframe, size)
	local corners = create(#VERTICES)
	for i = 1, #VERTICES do
		corners[i] = worldToScreen((cframe + size*0.5*VERTICES[i]).Position)
	end

	local min = v2Min(ViewportSize, unpack(corners))
	local max = v2Max(Vector2.zero, unpack(corners))
	return {
		corners = corners,
		topLeft = Vector2.new(floor(min.X), floor(min.Y)),
		topRight = Vector2.new(floor(max.X), floor(min.Y)),
		bottomLeft = Vector2.new(floor(min.X), floor(max.Y)),
		bottomRight = Vector2.new(floor(max.X), floor(max.Y))
	}
end

local function rotateVector(vector, radians)
	local x, y = vector.X, vector.Y
	local c, s = cos(radians), sin(radians)
	return Vector2.new(x*c - y*s, x*s + y*c)
end

local function parseColor(self, color, isOutline)
	if color == "Team Color" or (self.interface.mainSettings.teamColor and not isOutline) then
		return self.interface.getTeamColor(self.player) or Color3.new(1,1,1)
	end
	return color
end

local function getBones(character)
	local bodyConnections = {
		R15 = {
			{"Head", "UpperTorso"},
			{"UpperTorso", "LowerTorso"},
			{"LowerTorso", "LeftUpperLeg"},
			{"LowerTorso", "RightUpperLeg"},
			{"LeftUpperLeg", "LeftLowerLeg"},
			{"LeftLowerLeg", "LeftFoot"},
			{"RightUpperLeg", "RightLowerLeg"},
			{"RightLowerLeg", "RightFoot"},
			{"UpperTorso", "LeftUpperArm"},
			{"UpperTorso", "RightUpperArm"},
			{"LeftUpperArm", "LeftLowerArm"},
			{"LeftLowerArm", "LeftHand"},
			{"RightUpperArm", "RightLowerArm"},
			{"RightLowerArm", "RightHand"}
		},
		R6 = {
			{"Head", "Torso"},
			{"Torso", "Left Arm"},
			{"Torso", "Right Arm"},
			{"Torso", "Left Leg"},
			{"Torso", "Right Leg"}
		}
	}
	if not character or not character:FindFirstChildOfClass("Humanoid") then
		return
	end

	local rigType = character:FindFirstChildOfClass("Humanoid").RigType == Enum.HumanoidRigType.R15 and "R15" or "R6"
	local bones = {}
	for _, part in ipairs(character:GetChildren()) do
		if part:IsA("BasePart") then
			bones[part.Name] = part
		end
	end

	local connections = {}
	for _, connection in pairs(bodyConnections[rigType]) do
		local fromPart, toPart = connection[1], connection[2]
		if bones[fromPart] and bones[toPart] then
			table.insert(connections, {
				From = bones[fromPart],
				To = bones[toPart]
			})
		end
	end

	return connections
end

local function getBonesScreen(character, connections)
    local bones = {}
	if not connections then return end
    for _, conn in ipairs(connections) do
        local fromPos, fromVisible = worldToScreen(conn.From.Position)
        local toPos, toVisible = worldToScreen(conn.To.Position)
        if fromVisible or toVisible then
            table.insert(bones, {
                From = fromPos,
                To = toPos
            })
        end
    end
    return bones
end

--==[ ESP OBJECT ]==--
local EspObject = {}
EspObject.__index = EspObject

function EspObject.new(player, interface)
	local self = setmetatable({}, EspObject)
	self.player = assert(player, "Missing argument")
	self.interface = assert(interface, "Missing argument")
	self:Construct()
	return self
end

function EspObject:_create(class, properties)
	local drawing = Drawing.new(class)
	for property, value in next, properties do
		pcall(function() drawing[property] = value end)
	end
	self.bin[#self.bin + 1] = drawing
	return drawing
end

function EspObject:Construct()
	self.charCache = {}
	self.childCount = 0
	self.bin = {}
 	self.drawings = {
		box3d = {
			{
				self:_create("Line", { Thickness = 1, Visible = false }),
				self:_create("Line", { Thickness = 1, Visible = false }),
				self:_create("Line", { Thickness = 1, Visible = false })
			},
			{
				self:_create("Line", { Thickness = 1, Visible = false }),
				self:_create("Line", { Thickness = 1, Visible = false }),
				self:_create("Line", { Thickness = 1, Visible = false })
			},
			{
				self:_create("Line", { Thickness = 1, Visible = false }),
				self:_create("Line", { Thickness = 1, Visible = false }),
				self:_create("Line", { Thickness = 1, Visible = false })
			},
			{
				self:_create("Line", { Thickness = 1, Visible = false }),
				self:_create("Line", { Thickness = 1, Visible = false }),
				self:_create("Line", { Thickness = 1, Visible = false })
			}
		},
		visible = {
			tracerOutline = self:_create("Line", { Thickness = 3, Visible = false }),
			tracer = self:_create("Line", { Thickness = 1, Visible = false }),
			boxFill = self:_create("Square", { Filled = true, Visible = false }),
			boxOutline = self:_create("Square", { Thickness = 3, Visible = false }),
			box = self:_create("Square", { Thickness = 1, Visible = false }),
			healthBarOutline = self:_create("Line", { Thickness = 3, Visible = false }),
			healthBar = self:_create("Line", { Thickness = 1, Visible = false }),
			healthText = self:_create("Text", { Center = true, Visible = false }),
			name = self:_create("Text", { Text = self.player.DisplayName, Center = true, Visible = false }),
			distance = self:_create("Text", { Center = true, Visible = false }),
		},
		hidden = {
			arrowOutline = self:_create("Triangle", { Thickness = 3, Visible = false }),
			arrow = self:_create("Triangle", { Filled = true, Visible = false })
		}
	}
    
    self.bones = getBonesScreen(self.player.Character, getBones(self.player.Character))
    self.drawings.skeleton = {}
	if self.bones then
    	for _ = 1, #self.bones do
        	table.insert(self.drawings.skeleton, self:_create("Line", {Thickness=1, Visible=false}))
		end
	end
	self.renderConnection = RunService.Heartbeat:Connect(function(deltaTime)
		self:Update(deltaTime)
		self:Render(deltaTime)
	end)
end

function EspObject:Destruct()
	self.renderConnection:Disconnect()

	for i = 1, #self.bin do
		self.bin[i]:Remove()
	end

	clear(self)
end

function EspObject:Update()
	local interface = self.interface

	self.options = interface.humanoidSettings["humanoid"]
	self.character = interface.getCharacter(self.player)
	self.health, self.maxHealth = interface.getHealth(self.player)
	self.enabled = self.options.enabled and self.character

	local head = self.enabled and self.character:FindFirstChild("Head")
	if not head then
		self.charCache = {}
		self.onScreen = false
		return
	end

	local _, onScreen, depth = worldToScreen(head.Position)
	self.onScreen = onScreen
	self.distance = depth

	if interface.mainSettings.limitDistance and depth > interface.mainSettings.maxDistance then
		self.onScreen = false
	end

	if self.onScreen then
		local cache = self.charCache
		local children = self.character:GetChildren()
		if not cache[1] or self.childCount ~= #children then
			clear(cache)

			for i = 1, #children do
				local part = children[i]
				if part:IsA("BasePart") and isBodyPart(part.Name) then
					cache[#cache + 1] = part
				end
			end

			self.childCount = #children
		end

		self.corners = calculateCorners(getBoundingBox(cache))
	elseif self.options.offScreenArrow then
		local cframe = Camera.CFrame
		local flat = CFrame.fromMatrix(cframe.Position, cframe.RightVector, Vector3.yAxis)
		local objectSpace = CFrame.identity.PointToObjectSpace(flat, head.Position)
		self.direction = Vector2.new(objectSpace.X, objectSpace.Z).Unit
	end
end

function EspObject:Render()
	local onScreen = self.onScreen or false
	local enabled = self.enabled or false
	local visible = self.drawings.visible
	local hidden = self.drawings.hidden
	local box3d = self.drawings.box3d
	local skeleton = self.drawings.skeleton
	local interface = self.interface
	local options = self.options
	local corners = self.corners
	local bones = getBonesScreen(self.player.Character, getBones(self.player.Character))

	visible.box.Visible = enabled and onScreen and options.box
	visible.boxOutline.Visible = visible.box.Visible and options.boxOutline
	if visible.box.Visible then
		local box = visible.box
		box.Position = corners.topLeft
		box.Size = corners.bottomRight - corners.topLeft
		box.Color = parseColor(self, options.boxColor[1])
		box.Transparency = options.boxColor[2]

		local boxOutline = visible.boxOutline
		boxOutline.Position = box.Position
		boxOutline.Size = box.Size
		boxOutline.Color = parseColor(self, options.boxOutlineColor[1], true)
		boxOutline.Transparency = options.boxOutlineColor[2]
	end

	visible.boxFill.Visible = enabled and onScreen and options.boxFill
	if visible.boxFill.Visible then
		local boxFill = visible.boxFill
		boxFill.Position = corners.topLeft
		boxFill.Size = corners.bottomRight - corners.topLeft
		boxFill.Color = parseColor(self, options.boxFillColor[1])
		boxFill.Transparency = options.boxFillColor[2]
	end

	visible.healthBar.Visible = enabled and onScreen and options.healthBar
	visible.healthBarOutline.Visible = visible.healthBar.Visible and options.healthBarOutline
	if visible.healthBar.Visible then
		local barFrom = corners.topLeft - HEALTH_BAR_OFFSET
		local barTo = corners.bottomLeft - HEALTH_BAR_OFFSET

		local healthBar = visible.healthBar
		healthBar.To = barTo
		healthBar.From = v2Lerp(barTo, barFrom, self.health/self.maxHealth)
		healthBar.Color = options.healthyColor:Lerp(options.dyingColor, 1 - self.health/self.maxHealth)

		local healthBarOutline = visible.healthBarOutline
		healthBarOutline.To = barTo + HEALTH_BAR_OUTLINE_OFFSET
		healthBarOutline.From = barFrom - HEALTH_BAR_OUTLINE_OFFSET
		healthBarOutline.Color = parseColor(self, options.healthBarOutlineColor[1], true)
		healthBarOutline.Transparency = options.healthBarOutlineColor[2]
	end

	visible.healthText.Visible = enabled and onScreen and options.healthText
	if visible.healthText.Visible then
		local barFrom = corners.topLeft - HEALTH_BAR_OFFSET
		local barTo = corners.bottomLeft - HEALTH_BAR_OFFSET

		local healthText = visible.healthText
		healthText.Text = round(self.health) .. "hp"
		healthText.Size = interface.mainSettings.textSize
		healthText.Font = interface.mainSettings.textFont
		healthText.Color = parseColor(self, options.healthTextColor[1])
		healthText.Transparency = options.healthTextColor[2]
		healthText.Outline = options.healthTextOutline
		healthText.OutlineColor = parseColor(self, options.healthTextOutlineColor, true)
		healthText.Position = v2Lerp(barTo, barFrom, self.health/self.maxHealth) - healthText.TextBounds*0.5 - HEALTH_TEXT_OFFSET
	end

	visible.name.Visible = enabled and onScreen and options.name
	if visible.name.Visible then
		local name = visible.name
		name.Size = interface.mainSettings.textSize
		name.Font = interface.mainSettings.textFont
		name.Color = parseColor(self, options.nameColor[1])
		name.Transparency = options.nameColor[2]
		name.Outline = options.nameOutline
		name.OutlineColor = parseColor(self, options.nameOutlineColor, true)
		name.Position = (corners.topLeft + corners.topRight)*0.5 - Vector2.yAxis*name.TextBounds.Y - NAME_OFFSET
	end

	visible.distance.Visible = enabled and onScreen and self.distance and options.distance
	if visible.distance.Visible then
		local distance = visible.distance
		distance.Text = round(self.distance) .. " studs"
		distance.Size = interface.mainSettings.textSize
		distance.Font = interface.mainSettings.textFont
		distance.Color = parseColor(self, options.distanceColor[1])
		distance.Transparency = options.distanceColor[2]
		distance.Outline = options.distanceOutline
		distance.OutlineColor = parseColor(self, options.distanceOutlineColor, true)
		distance.Position = (corners.bottomLeft + corners.bottomRight)*0.5 + DISTANCE_OFFSET
	end

	visible.tracer.Visible = enabled and onScreen and options.tracer
	visible.tracerOutline.Visible = visible.tracer.Visible and options.tracerOutline
	if visible.tracer.Visible then
		local tracer = visible.tracer
		tracer.Color = parseColor(self, options.tracerColor[1])
		tracer.Transparency = options.tracerColor[2]
		tracer.To = (corners.bottomLeft + corners.bottomRight)*0.5
		tracer.From =
			options.tracerOrigin == "Middle" and ViewportSize*0.5 or
			options.tracerOrigin == "Top" and ViewportSize*Vector2.new(0.5, 0) or
			options.tracerOrigin == "Bottom" and ViewportSize*Vector2.new(0.5, 1) or
			options.tracerOrigin == "Mouse" and getMousePos()

		local tracerOutline = visible.tracerOutline
		tracerOutline.Color = parseColor(self, options.tracerOutlineColor[1], true)
		tracerOutline.Transparency = options.tracerOutlineColor[2]
		tracerOutline.To = tracer.To
		tracerOutline.From = tracer.From
	end

	hidden.arrow.Visible = enabled and (not onScreen) and options.offScreenArrow
	hidden.arrowOutline.Visible = hidden.arrow.Visible and options.offScreenArrowOutline
	if hidden.arrow.Visible and self.direction then
		local arrow = hidden.arrow
		arrow.PointA = v2Min(v2Max(ViewportSize*0.5 + self.direction*options.offScreenArrowRadius, Vector2.one*25), ViewportSize - Vector2.one*25)
		arrow.PointB = arrow.PointA - rotateVector(self.direction, 0.45)*options.offScreenArrowSize
		arrow.PointC = arrow.PointA - rotateVector(self.direction, -0.45)*options.offScreenArrowSize
		arrow.Color = parseColor(self, options.offScreenArrowColor[1])
		arrow.Transparency = options.offScreenArrowColor[2]

		local arrowOutline = hidden.arrowOutline
		arrowOutline.PointA = arrow.PointA
		arrowOutline.PointB = arrow.PointB
		arrowOutline.PointC = arrow.PointC
		arrowOutline.Color = parseColor(self, options.offScreenArrowOutlineColor[1], true)
		arrowOutline.Transparency = options.offScreenArrowOutlineColor[2]
	end

	local box3dEnabled = enabled and onScreen and options.box3d
	for i = 1, #box3d do
		local face = box3d[i]
		for j = 1, #face do
			local line = face[j]
			line.Visible = box3dEnabled
			line.Color = parseColor(self, options.box3dColor[1])
			line.Transparency = options.box3dColor[2]
		end

		if box3dEnabled then
			local line1 = face[1]
			line1.From = corners.corners[i]
			line1.To = corners.corners[i == 4 and 1 or i+1]

			local line2 = face[2]
			line2.From = corners.corners[i == 4 and 1 or i+1]
			line2.To = corners.corners[i == 4 and 5 or i+5]

			local line3 = face[3]
			line3.From = corners.corners[i == 4 and 5 or i+5]
			line3.To = corners.corners[i == 4 and 8 or i+4]
		end
	end

	local skeletonEnabled = enabled and onScreen and options.skeleton

    for i = 1, #skeleton do
        local line = skeleton[i]
        line.Visible = skeletonEnabled
        line.Color = parseColor(self, self.options.skeletonColor[1])
        line.Transparency = self.options.skeletonColor[2]

        if skeletonEnabled and bones[i] then
            line.From = bones[i].From
            line.To = bones[i].To
        end
    end
end

--==[ SETTINGS ]==--
local EspInterface = {
	_hasLoaded = false,
	_objectCache = {},
	userList = {},
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
			skeleton = false,
			skeletonColor = { Color3.new(0.117, 0.564, 1), 1 },
			skeletonOutline = true, -- not working as of now
			skeletonOutlineColor = { Color3.new(), 1},
		},
	}
}

function EspInterface.getTeamColor(player)
	return player.Team and player.Team.TeamColor and player.Team.TeamColor.Color
end

function EspInterface.getCharacter(player)
	return player.Character
end

function EspInterface.getHealth(player)
	local character = player and EspInterface.getCharacter(player)
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	if humanoid then
		return humanoid.Health, humanoid.MaxHealth
	end
	return 100, 100
end

function EspInterface.Load()
	assert(not EspInterface._hasLoaded, "ESP has already been loaded.")

	local function createObject(player)
		EspInterface._objectCache[player] = {
			EspObject.new(player, EspInterface),
		}
	end

	local function removeObject(player)
		local object = EspInterface._objectCache[player]
		if object then
			for i = 1, #object do
				object[i]:Destruct()
			end
			EspInterface._objectCache[player] = nil
		end
	end

	local userList = EspInterface.userList

	if #userList == 0 then
		local plrs = Players:GetPlayers()
		for i = 2, #plrs do
			createObject(plrs[i])
		end

		EspInterface.playerAdded = Players.PlayerAdded:Connect(createObject)
		EspInterface.playerRemoving = Players.PlayerRemoving:Connect(removeObject)
	else
		local plrs = userList
		for i = 1, #plrs do
			createObject(plrs[i])
		end
	end
	EspInterface._hasLoaded = true
end

function EspInterface.Unload()
	assert(EspInterface._hasLoaded, "ESP has not been loaded yet.")

	for index, object in next, EspInterface._objectCache do
		for i = 1, #object do
			object[i]:Destruct()
		end
		EspInterface._objectCache[index] = nil
	end

	EspInterface.playerAdded:Disconnect()
	EspInterface.playerRemoving:Disconnect()
	EspInterface._hasLoaded = false
end

return EspInterface
