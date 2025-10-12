local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local Camera = workspace.CurrentCamera

-- ==================
-- STATE VARIABLES
-- ==================
local teleportActive = false
local cameraNoClip = false
local godModeActive = false
local espActive = true
local infiniteJump = false
local playerTPSel = nil -- seçilen oyuncu için sürekli tp
local playerTPSwitch = false -- sürekli tp aktif mi
local godConns = {}
local espItems = {}

-- DEFAULTS
local defaultWalkSpeed = 16
local defaultJumpPower = 50

-- ==================
-- HELPERS
-- ==================
local function getCharacter() return LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait() end
local function getHumanoid() local c = getCharacter() return c and c:FindFirstChildOfClass("Humanoid") end

-- ==================
-- FULLBRIGHT
-- ==================
pcall(function()
    Lighting.Ambient = Color3.fromRGB(255,255,255)
    Lighting.Brightness = 2
    Lighting.ClockTime = 14
end)

-- ==================
-- GUI
-- ==================
local screenGui = Instance.new("ScreenGui", PlayerGui)
screenGui.Name = "DevMultiToolGUI"
screenGui.ResetOnSpawn = false

local frame = Instance.new("Frame", screenGui)
frame.Size = UDim2.new(0, 320, 0, 400)
frame.Position = UDim2.new(0.02,0,0.08,0)
frame.BackgroundColor3 = Color3.fromRGB(24,22,32)
frame.BorderSizePixel = 0
local uic = Instance.new("UICorner", frame)
uic.CornerRadius = UDim.new(0,12)

-- Title
local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1,-16,0,32)
title.Position = UDim2.new(0,8,0,8)
title.BackgroundTransparency = 1
title.Text = "CoHub"
title.Font = Enum.Font.GothamBold
title.TextSize = 18
title.TextColor3 = Color3.fromRGB(230,230,230)
title.TextXAlignment = Enum.TextXAlignment.Left

-- Label / Button Helpers
local function mkLabel(txt,y)
    local lbl = Instance.new("TextLabel", frame)
    lbl.Size = UDim2.new(0.6,0,0,20)
    lbl.Position = UDim2.new(0,12,0,y)
    lbl.BackgroundTransparency = 1
    lbl.Text = txt
    lbl.Font = Enum.Font.SourceSansSemibold
    lbl.TextSize = 14
    lbl.TextColor3 = Color3.fromRGB(220,220,220)
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    return lbl
end

local function mkButton(txt,x,y,w,h)
    local b = Instance.new("TextButton", frame)
    b.Size = UDim2.new(0,w,0,h)
    b.Position = UDim2.new(0,x,0,y)
    b.BackgroundColor3 = Color3.fromRGB(46,45,60)
    b.BorderSizePixel = 0
    b.Text = txt
    b.Font = Enum.Font.SourceSansBold
    b.TextSize = 13
    b.TextColor3 = Color3.fromRGB(230,230,230)
    local corner = Instance.new("UICorner", b)
    corner.CornerRadius = UDim.new(0,8)
    return b
end

-- ==================
-- TOGGLES
-- ==================
local teleportLabel = mkLabel("Teleport (R + Click): OFF",60)
local teleportBtn = mkButton("Toggle",180,58,120,22)
local cameraLabel = mkLabel("Camera NoClip (J): OFF",86)
local cameraBtn = mkButton("Toggle",180,110,120,22)
local godLabel = mkLabel("Senin beyninin olması gibi sahte God Mode (L): OFF",112)
local godBtn = mkButton("Toggle",180,136,120,22)
local espLabel = mkLabel("ESP (E): ON",138)
local espBtn = mkButton("Toggle",180,162,120,22)
local infLabel = mkLabel("Infinite Jump: OFF",164)
local infBtn = mkButton("Toggle",180,188,120,22)
local playerTPLabel = mkLabel("Player TP: NONE",190)
local playerTPBtn = mkButton("Select Player",180,212,120,22)
local playerTPSwitchBtn = mkButton("Start TP",180,238,120,22)

-- Speed / Jump sliders
local speedLabel = mkLabel("WalkSpeed: 16",240)
local jumpLabel = mkLabel("JumpPower: 50",264)

local function makeSlider(y,minVal,maxVal,init)
    local bar = Instance.new("Frame", frame)
    bar.Size = UDim2.new(0,150,0,10)
    bar.Position = UDim2.new(0,12,0,y)
    bar.BackgroundColor3 = Color3.fromRGB(40,40,50)
    local corner = Instance.new("UICorner", bar); corner.CornerRadius = UDim.new(0,6)
    local fill = Instance.new("Frame", bar)
    fill.Size = UDim2.new((init-minVal)/(maxVal-minVal),0,1,0)
    fill.BackgroundColor3 = Color3.fromRGB(170,78,255)
    local corner2 = Instance.new("UICorner", fill); corner2.CornerRadius = UDim.new(0,6)

    local dragging = false
    bar.InputBegan:Connect(function(input)
        if input.UserInputType==Enum.UserInputType.MouseButton1 then dragging = true end
    end)
    bar.InputEnded:Connect(function(input)
        if input.UserInputType==Enum.UserInputType.MouseButton1 then dragging = false end
    end)
    bar.InputChanged:Connect(function(input)
        if input.UserInputType==Enum.UserInputType.MouseMovement and dragging then
            local rel = math.clamp((input.Position.X - bar.AbsolutePosition.X)/bar.AbsoluteSize.X,0,1)
            fill.Size = UDim2.new(rel,0,1,0)
        end
    end)

    return {
        frame = bar,
        getValue = function()
            local rel = fill.Size.X.Scale
            return minVal + rel*(maxVal-minVal)
        end,
        setValue = function(val)
            local rel = math.clamp((val-minVal)/(maxVal-minVal),0,1)
            fill.Size = UDim2.new(rel,0,1,0)
        end
    }
end

local speedSlider = makeSlider(288,8,120,defaultWalkSpeed)
local jumpSlider = makeSlider(312,20,150,defaultJumpPower)

-- ==================
-- ESP
-- ==================
local espFolder = Instance.new("Folder",workspace)
espFolder.Name = "DevEspFolder_Client"

local function createESP(p)
    if p==LocalPlayer then return end
    if not p.Character then return end
    local hrp = p.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    if espItems[p] then return end

    local box = Instance.new("BoxHandleAdornment")
    box.Size = Vector3.new(3,6,1)
    box.Adornee = hrp
    box.AlwaysOnTop = true
    box.Transparency = 0.5
    box.Parent = espFolder

    local bb = Instance.new("BillboardGui", espFolder)
    bb.Adornee = hrp
    bb.Size = UDim2.new(0,120,0,36)
    bb.AlwaysOnTop = true
    bb.ExtentsOffset = Vector3.new(0,3.5,0)
    local txt = Instance.new("TextLabel", bb)
    txt.Size = UDim2.new(1,0,1,0)
    txt.BackgroundTransparency = 1
    txt.Font = Enum.Font.SourceSansSemibold
    txt.TextSize = 14
    txt.TextColor3 = Color3.fromRGB(255,255,255)
    txt.TextStrokeTransparency = 0.6
    txt.Text = p.Name
    espItems[p] = {box = box, label = txt, gui = bb}
end

local function removeESP(p)
    if espItems[p] then
        pcall(function()
            if espItems[p].box then espItems[p].box:Destroy() end
            if espItems[p].gui then espItems[p].gui:Destroy() end
        end)
        espItems[p] = nil
    end
end

Players.PlayerAdded:Connect(function(p)
    p.CharacterAdded:Connect(function()
        if espActive then createESP(p) end
    end)
end)
Players.PlayerRemoving:Connect(removeESP)

RunService.RenderStepped:Connect(function()
    if espActive then
        for _,p in pairs(Players:GetPlayers()) do
            if p~=LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                if not espItems[p] then createESP(p) end
                local dist = (p.Character.HumanoidRootPart.Position - Camera.CFrame.Position).Magnitude
                if espItems[p] and espItems[p].label then
                    espItems[p].label.Text = p.Name.." ["..math.floor(dist).."m]"
                end
            else removeESP(p) end
        end
    else
        for p,_ in pairs(espItems) do removeESP(p) end
    end
end)

-- ==================
-- BUTTON LOGIC
-- ==================
teleportBtn.MouseButton1Click:Connect(function()
    teleportActive = not teleportActive
    teleportLabel.Text = "Teleport (R + Click): "..(teleportActive and "ON" or "OFF")
end)

cameraBtn.MouseButton1Click:Connect(function()
    cameraNoClip = not cameraNoClip
    cameraLabel.Text = "Camera NoClip (J): "..(cameraNoClip and "ON" or "OFF")
    if cameraNoClip then Camera.CameraSubject = nil else
        local hum = getHumanoid()
        if hum then Camera.CameraSubject = hum end
    end
end)

godBtn.MouseButton1Click:Connect(function()
    godModeActive = not godModeActive
    godLabel.Text = "Dev God Mode (L): "..(godModeActive and "ON" or "OFF")
end)

espBtn.MouseButton1Click:Connect(function()
    espActive = not espActive
    espLabel.Text = "ESP (E): "..(espActive and "ON" or "OFF")
end)

infBtn.MouseButton1Click:Connect(function()
    infiniteJump = not infiniteJump
    infLabel.Text = "Infinite Jump: "..(infiniteJump and "ON" or "OFF")
end)

playerTPBtn.MouseButton1Click:Connect(function()
    -- open simple player chooser
    local chooser = Instance.new("Frame", screenGui)
    chooser.Size = UDim2.new(0,200,0,200)
    chooser.Position = UDim2.new(0,340,0,50)
    chooser.BackgroundColor3 = Color3.fromRGB(20,20,25)
    local corner = Instance.new("UICorner", chooser); corner.CornerRadius = UDim.new(0,10)
    local title2 = Instance.new("TextLabel", chooser)
    title2.Size = UDim2.new(1,-12,0,26)
    title2.Position = UDim2.new(0,6,0,6)
    title2.BackgroundTransparency = 1
    title2.Text = "Select Player"
    title2.Font = Enum.Font.GothamBold
    title2.TextSize = 14
    title2.TextColor3 = Color3.fromRGB(230,230,230)

    local list = Instance.new("ScrollingFrame", chooser)
    list.Size = UDim2.new(1,-12,1,-40)
    list.Position = UDim2.new(0,6,0,36)
    list.BackgroundTransparency = 1
    list.ScrollBarThickness = 6

    local y = 0
    for _,p in ipairs(Players:GetPlayers()) do
        if p~=LocalPlayer then
            local btn = Instance.new("TextButton", list)
            btn.Size = UDim2.new(1,-10,0,28)
            btn.Position = UDim2.new(0,6,0,y)
            btn.BackgroundColor3 = Color3.fromRGB(38,38,48)
            btn.BorderSizePixel = 0
            btn.Text = p.Name
            btn.Font = Enum.Font.SourceSans
            btn.TextSize = 14
            btn.TextColor3 = Color3.fromRGB(230,230,230)
            local ccorner = Instance.new("UICorner", btn); ccorner.CornerRadius = UDim.new(0,6)
            btn.MouseButton1Click:Connect(function()
                playerTPSel = p
                playerTPLabel.Text = "Player TP: "..p.Name
                chooser:Destroy()
            end)
            y = y + 34
        end
    end
    list.CanvasSize = UDim2.new(0,0,0,y)
end)

playerTPSwitchBtn.MouseButton1Click:Connect(function()
    if playerTPSel then
        playerTPSwitch = not playerTPSwitch
        playerTPSwitchBtn.Text = playerTPSwitch and "Stop TP" or "Start TP"
    end
end)

-- ==================
-- SLIDER & MOVEMENT APPLY
-- ==================
local function applyMovement()
    local hum = getHumanoid()
    if hum then
        pcall(function()
            hum.WalkSpeed = math.floor(speedSlider.getValue())
            hum.JumpPower = math.floor(jumpSlider.getValue())
        end)
    end
    speedLabel.Text = "WalkSpeed: "..math.floor(speedSlider.getValue())
    jumpLabel.Text = "JumpPower: "..math.floor(jumpSlider.getValue())
end

-- ==================
-- INPUT BINDS
-- ==================
UserInputService.InputBegan:Connect(function(input,processed)
    if processed then return end
    if input.UserInputType==Enum.UserInputType.Keyboard then
        local kc = input.KeyCode
        if kc==Enum.KeyCode.R then teleportActive = not teleportActive; teleportLabel.Text = "Teleport (R + Click): "..(teleportActive and "ON" or "OFF")
        elseif kc==Enum.KeyCode.J then cameraBtn.MouseButton1Click:Fire()
        elseif kc==Enum.KeyCode.L then godBtn.MouseButton1Click:Fire()
        elseif kc==Enum.KeyCode.E then espBtn.MouseButton1Click:Fire()
        elseif kc==Enum.KeyCode.N then Lighting.ClockTime = (Lighting.ClockTime<12 and 20 or 10)
        elseif kc==Enum.KeyCode.C then screenGui.Enabled = not screenGui.Enabled end
    end
end)

-- ==================
-- TELEPORT
-- ==================
LocalPlayer:GetMouse().Button1Down:Connect(function()
    if teleportActive then
        local target = LocalPlayer:GetMouse().Hit and LocalPlayer:GetMouse().Hit.p
        if target then
            local char = getCharacter()
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if hrp then hrp.CFrame = CFrame.new(target+Vector3.new(0,3,0)) end
        end
    end
end)

-- ==================
-- DEV GOD MODE (local)
-- ==================
RunService.RenderStepped:Connect(function(dt)
    -- god mode
    if godModeActive then
        local hum = getHumanoid()
        if hum then
            if hum.Health<hum.MaxHealth then pcall(function() hum.Health = hum.MaxHealth end) end
            pcall(function() hum.PlatformStand = false end)
        end
    end

    -- camera noclip
    if cameraNoClip then Camera.CameraSubject=nil end

    -- player TP sürekli
    if playerTPSwitch and playerTPSel and playerTPSel.Character and playerTPSel.Character:FindFirstChild("HumanoidRootPart") then
        local hrp = getCharacter():FindFirstChild("HumanoidRootPart")
        hrp.CFrame = playerTPSel.Character.HumanoidRootPart.CFrame + Vector3.new(0,3,0)
    end

    -- apply movement sliders
    applyMovement()
end)

-- ==================
-- INFINITE JUMP
-- ==================
UserInputService.JumpRequest:Connect(function()
    if infiniteJump then
        local hum = getHumanoid()
        if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)

-- ==================
-- INITIAL UPDATE
-- ==================
teleportLabel.Text = "Teleport (R + Click): "..(teleportActive and "ON" or "OFF")
cameraLabel.Text = "Camera NoClip (J): "..(cameraNoClip and "ON" or "OFF")
godLabel.Text = "Dev God Mode (L): "..(godModeActive and "ON" or "OFF")
espLabel.Text = "ESP (E): "..(espActive and "ON" or "OFF")
infLabel.Text = "Infinite Jump: "..(infiniteJump and "ON" or "OFF")
speedLabel.Text = "WalkSpeed: "..math.floor(speedSlider.getValue())
jumpLabel.Text = "JumpPower: "..math.floor(jumpSlider.getValue())
playerTPLabel.Text = "Player TP: NONE" 
-- ==================
-- PLAYER INVENTORY MENU (M)
-- ==================
local inventoryGui = Instance.new("Frame")
inventoryGui.Size = UDim2.new(0, 380, 0, 420)
inventoryGui.Position = UDim2.new(0.5, -190, 0.5, -210)
inventoryGui.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
inventoryGui.Visible = false
inventoryGui.Parent = screenGui
Instance.new("UICorner", inventoryGui).CornerRadius = UDim.new(0, 12)

local invTitle = Instance.new("TextLabel", inventoryGui)
invTitle.Size = UDim2.new(1, 0, 0, 32)
invTitle.BackgroundTransparency = 1
invTitle.Text = "Inventory Viewer"
invTitle.Font = Enum.Font.GothamBold
invTitle.TextSize = 18
invTitle.TextColor3 = Color3.fromRGB(255, 255, 255)

local playersFrame = Instance.new("ScrollingFrame", inventoryGui)
playersFrame.Size = UDim2.new(0.4, -10, 1, -40)
playersFrame.Position = UDim2.new(0, 10, 0, 40)
playersFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
playersFrame.ScrollBarThickness = 6
Instance.new("UICorner", playersFrame).CornerRadius = UDim.new(0, 8)

local itemsFrame = Instance.new("ScrollingFrame", inventoryGui)
itemsFrame.Size = UDim2.new(0.6, -20, 1, -40)
itemsFrame.Position = UDim2.new(0.4, 10, 0, 40)
itemsFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
itemsFrame.ScrollBarThickness = 6
Instance.new("UICorner", itemsFrame).CornerRadius = UDim.new(0, 8)

local selectedPlayer = nil

local function refreshPlayers()
	playersFrame:ClearAllChildren()
	local y = 0
	for _, p in ipairs(Players:GetPlayers()) do
		if p ~= LocalPlayer then
			local btn = Instance.new("TextButton", playersFrame)
			btn.Size = UDim2.new(1, -10, 0, 30)
			btn.Position = UDim2.new(0, 5, 0, y)
			btn.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
			btn.Text = p.Name
			btn.TextColor3 = Color3.fromRGB(230, 230, 230)
			btn.Font = Enum.Font.SourceSansSemibold
			btn.TextSize = 14
			Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
			btn.MouseButton1Click:Connect(function()
				selectedPlayer = p
				invTitle.Text = "Inventory of " .. p.Name
				refreshInventory()
			end)
			y += 34
		end
	end
	playersFrame.CanvasSize = UDim2.new(0, 0, 0, y)
end

function refreshInventory()
	itemsFrame:ClearAllChildren()
	if not selectedPlayer then return end
	local tools = {}
	if selectedPlayer:FindFirstChild("Backpack") then
		for _, tool in ipairs(selectedPlayer.Backpack:GetChildren()) do
			if tool:IsA("Tool") then table.insert(tools, tool) end
		end
	end
	if selectedPlayer.Character then
		for _, tool in ipairs(selectedPlayer.Character:GetChildren()) do
			if tool:IsA("Tool") then table.insert(tools, tool) end
		end
	end

	local y = 0
	for _, tool in ipairs(tools) do
		local itemFrame = Instance.new("Frame", itemsFrame)
		itemFrame.Size = UDim2.new(1, -10, 0, 30)
		itemFrame.Position = UDim2.new(0, 5, 0, y)
		itemFrame.BackgroundColor3 = Color3.fromRGB(55, 55, 75)
		Instance.new("UICorner", itemFrame).CornerRadius = UDim.new(0, 6)

		local lbl = Instance.new("TextLabel", itemFrame)
		lbl.Size = UDim2.new(0.7, 0, 1, 0)
		lbl.BackgroundTransparency = 1
		lbl.Text = tool.Name
		lbl.TextColor3 = Color3.fromRGB(230, 230, 230)
		lbl.Font = Enum.Font.SourceSans
		lbl.TextSize = 14
		lbl.TextXAlignment = Enum.TextXAlignment.Left

		local btn = Instance.new("TextButton", itemFrame)
		btn.Size = UDim2.new(0.3, -5, 1, -4)
		btn.Position = UDim2.new(0.7, 5, 0, 2)
		btn.BackgroundColor3 = Color3.fromRGB(90, 70, 150)
		btn.Text = "Al"
		btn.TextColor3 = Color3.fromRGB(255, 255, 255)
		btn.Font = Enum.Font.SourceSansBold
		btn.TextSize = 13
		Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
		btn.MouseButton1Click:Connect(function()
			local clone = tool:Clone()
			clone.Parent = LocalPlayer.Backpack
		end)
		y += 34
	end
	itemsFrame.CanvasSize = UDim2.new(0, 0, 0, y)
end

UserInputService.InputBegan:Connect(function(input, gp)
	if gp then return end
	if input.KeyCode == Enum.KeyCode.M then
		inventoryGui.Visible = not inventoryGui.Visible
		if inventoryGui.Visible then
			refreshPlayers()
		end
	end
end)  
