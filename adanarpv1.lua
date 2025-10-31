-- LocalScript (StarterPlayerScripts içine koy)
local player = game.Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

-- ScreenGui oluştur
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "UltraMegaPinkLoading"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

-- Ana çerçeve
local frame = Instance.new("Frame")
frame.Size = UDim2.new(1, 0, 1, 0)
frame.Position = UDim2.new(0, 0, 0, 0)
frame.BackgroundColor3 = Color3.fromRGB(255, 182, 193)
frame.BorderSizePixel = 0
frame.Parent = screenGui

-- Ana gradient glow
local gradient = Instance.new("UIGradient")
gradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 182, 193)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 105, 180)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 182, 193))
}
gradient.Rotation = 45
gradient.Parent = frame

-- Yükleme bar arka
local barBackground = Instance.new("Frame")
barBackground.Size = UDim2.new(0.6, 0, 0.05, 0)
barBackground.Position = UDim2.new(0.2, 0, 0.85, 0)
barBackground.BackgroundColor3 = Color3.fromRGB(255, 105, 180)
barBackground.BorderSizePixel = 0
barBackground.Parent = frame
barBackground.ClipsDescendants = true

-- Bar glow
local barGlow = Instance.new("UIGradient")
barGlow.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 20, 147)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 182, 193))
}
barGlow.Rotation = 0
barGlow.Parent = barBackground

-- Bar dolan kısmı
local bar = Instance.new("Frame")
bar.Size = UDim2.new(0, 0, 1, 0)
bar.Position = UDim2.new(0, 0, 0, 0)
bar.BackgroundColor3 = Color3.fromRGB(255, 20, 147)
bar.BorderSizePixel = 0
bar.Parent = barBackground

-- Loading yazısı
local loadingText = Instance.new("TextLabel")
loadingText.Size = UDim2.new(0.3, 0, 0.1, 0)
loadingText.Position = UDim2.new(0.35, 0, 0.75, 0)
loadingText.BackgroundTransparency = 1
loadingText.Text = "Loading..."
loadingText.TextColor3 = Color3.fromRGB(255, 255, 255)
loadingText.Font = Enum.Font.FredokaOne
loadingText.TextScaled = true
loadingText.Parent = frame

-- Parçacık efekti (yıldızlar)
local particleContainer = Instance.new("Folder")
particleContainer.Name = "Particles"
particleContainer.Parent = frame

local function spawnStar()
    local star = Instance.new("Frame")
    star.Size = UDim2.new(0, math.random(4, 10), 0, math.random(4, 10))
    star.Position = UDim2.new(math.random(), 0, math.random(), 0)
    star.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    star.BackgroundTransparency = 0
    star.BorderSizePixel = 0
    star.AnchorPoint = Vector2.new(0.5, 0.5)
    star.Rotation = math.random(0, 360)
    star.Parent = particleContainer

    -- Tween yıldız için
    local starTween = TweenService:Create(star, TweenInfo.new(1 + math.random(), Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Position = UDim2.new(math.random(), 0, math.random(), 0),
        Size = UDim2.new(0, 0, 0, 0),
        BackgroundTransparency = 1,
        Rotation = star.Rotation + 360
    })
    starTween:Play()
    starTween.Completed:Connect(function()
        star:Destroy()
    end)
end

-- Sürekli yıldız spawn
local spawnConnection
spawnConnection = RunService.RenderStepped:Connect(function()
    if math.random() < 0.05 then
        spawnStar()
    end
end)

-- Bar tween
local tweenInfo = TweenInfo.new(4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local tweenGoal = {Size = UDim2.new(1, 0, 1, 0)}
local barTween = TweenService:Create(bar, tweenInfo, tweenGoal)
barTween:Play()

-- Glow animasyonu
spawn(function()
    while barTween.PlaybackState ~= Enum.PlaybackState.Completed do
        barGlow.Rotation = (barGlow.Rotation + 5) % 360
        wait(0.03)
    end
end)

-- Loading text pulse
spawn(function()
    while barTween.PlaybackState ~= Enum.PlaybackState.Completed do
        for i = 0, 1, 0.05 do
            loadingText.TextTransparency = i
            wait(0.03)
        end
        for i = 1, 0, -0.05 do
            loadingText.TextTransparency = i
            wait(0.03)
        end
    end
end)

-- Tween tamamlandığında fade-out ve temizleme
barTween.Completed:Connect(function()
local ok, Rayfield = pcall(function() return loadstring(game:HttpGet('https://sirius.menu/rayfield'))() end)
if not ok or not Rayfield then warn("Rayfield yüklenemedi") return end

local Window = Rayfield:CreateWindow({
    Name = "AdanaCityUltra | Adana hub",
    LoadingTitle = "💎 Uwu...",
    LoadingSubtitle = "👑 by MR.Script (safe) 👑",
    Theme = "Default",
    ConfigurationSaving = { Enabled = true, FolderName = "AdanaCityUltra", FileName = "config" },
    KeySystem = false
})

-- ===== Services =====
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local localPlayer = Players.LocalPlayer
local character = localPlayer.Character or localPlayer.CharacterAdded:Wait()

local function refreshCharacter()
    character = localPlayer.Character or localPlayer.CharacterAdded:Wait()
end
localPlayer.CharacterAdded:Connect(function() wait(0.1); refreshCharacter() end)

-- ===== Toast Sistem =====
local toastGui
local toastY = 10
local function showToast(title,text,duration,color)
    toastGui = toastGui or Instance.new("ScreenGui",localPlayer:WaitForChild("PlayerGui"))
    toastGui.Name="UltraMegaFXToasts"
    duration = duration or 3
    color = color or Color3.fromRGB(30,30,30)
    local frame = Instance.new("Frame",toastGui)
    frame.Size=UDim2.new(0,320,0,60)
    frame.Position=UDim2.new(1,320,0,toastY)
    frame.BackgroundColor3=color
    frame.BackgroundTransparency=0.08
    frame.AnchorPoint=Vector2.new(1,0)
    frame.ZIndex = 5
    local titleLbl = Instance.new("TextLabel",frame)
    titleLbl.Size=UDim2.new(1,-10,0,24)
    titleLbl.Position=UDim2.new(0,5,0,4)
    titleLbl.BackgroundTransparency=1
    titleLbl.Text=title
    titleLbl.TextXAlignment=Enum.TextXAlignment.Left
    titleLbl.Font=Enum.Font.SourceSansBold
    titleLbl.TextSize=18
    titleLbl.TextColor3=Color3.new(1,1,1)
    local textLbl = Instance.new("TextLabel",frame)
    textLbl.Size=UDim2.new(1,-10,0,28)
    textLbl.Position=UDim2.new(0,5,0,28)
    textLbl.BackgroundTransparency=1
    textLbl.Text=text
    textLbl.TextXAlignment=Enum.TextXAlignment.Left
    textLbl.Font=Enum.Font.SourceSans
    textLbl.TextSize=14
    textLbl.TextColor3=Color3.new(0.9,0.9,0.9)
    TweenService:Create(frame,TweenInfo.new(0.35,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{Position=UDim2.new(1,-10,0,toastY)}):Play()
    toastY = toastY + 70
    delay(duration,function()
        TweenService:Create(frame,TweenInfo.new(0.25),{Position=UDim2.new(1,320,0,toastY)}):Play()
        wait(0.26)
        if frame and frame.Parent then frame:Destroy() end
        toastY = math.max(10,toastY-70)
    end)
end
local function notify(title,text,dur) showToast(title,text,dur or 3) end

-- ===== Particle FX =====
local function spawnFX(color,duration,size,height)
    local center = (character and character.PrimaryPart and character.PrimaryPart.Position) or Vector3.new(0,5,0)
    for i=1,20 do
        local p = Instance.new("Part")
        p.Size=Vector3.new(size,size,size)
        p.Position=center+Vector3.new(math.random(-4,4),math.random(0,height),math.random(-4,4))
        p.Anchored=false
        p.CanCollide=false
        p.Material=Enum.Material.Neon
        p.BrickColor=BrickColor.new(color)
        p.Parent=workspace
        Debris:AddItem(p,duration)
    end
end

-- ===== Invisible + Dance FX =====
local danceEmoteId = 180435571
local danceTrack = nil
local invisible = false

local function playDance()
    if not character then return end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end
    local animator = humanoid:FindFirstChildOfClass("Animator") or Instance.new("Animator", humanoid)
    if danceTrack then danceTrack:Stop() end
    local animation = Instance.new("Animation")
    animation.AnimationId = "rbxassetid://132241001987036"..danceEmoteId
    danceTrack = animator:LoadAnimation(animation)
    danceTrack:Play()
end

local function setInvisible(state)
    invisible = state
    if character then
        for _,p in pairs(character:GetDescendants()) do
            if p:IsA("BasePart") then
                p.Transparency = state and 1 or 0
                p.CanCollide = not state
            end
        end
    end
    if state then
        playDance()
        spawnFX("Bright violet",0.5,0.3,6)
        notify("Player","Invisible + Dance aktif! 🎉",4)
        local sound = Instance.new("Sound",workspace)
        sound.SoundId="rbxassetid://9118829615"
        sound.Volume=1
        sound:Play()
        Debris:AddItem(sound,3)
    else
        if danceTrack then danceTrack:Stop() end
        spawnFX("Bright red",0.5,0.3,4)
        notify("Player","Invisible kapandı, dans durdu.",3)
        local sound = Instance.new("Sound",workspace)
        sound.SoundId="rbxassetid://9118831234"
        sound.Volume=1
        sound:Play()
        Debris:AddItem(sound,3)
    end
end

-- ===== Player Tab =====
local PlayerTab = Window:CreateTab("Player",nil)

PlayerTab:CreateToggle({
    Name="Invisible + Dance FX",
    CurrentValue=false,
    Flag="ps_invisDance",
    Callback=setInvisible
})

-- Fly Toggle
local flying = false
local flySpeed = 50
PlayerTab:CreateToggle({
    Name="Fly",
    CurrentValue=false,
    Flag="ps_fly",
    Callback=function(state)
        flying = state
        if state then notify("Fly","Fly aktif! 🎈",3) else notify("Fly","Fly kapalı",2) end
    end
})

RunService.RenderStepped:Connect(function(dt)
    if flying and character and character.PrimaryPart then
        local direction = Vector3.new()
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then direction = direction + character.PrimaryPart.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then direction = direction - character.PrimaryPart.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then direction = direction - character.PrimaryPart.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then direction = direction + character.PrimaryPart.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then direction = direction + Vector3.new(0,1,0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then direction = direction - Vector3.new(0,1,0) end
        if direction.Magnitude>0 then
            character:SetPrimaryPartCFrame(character.PrimaryPart.CFrame + direction.Unit * flySpeed * dt)
        end
    end
end)

-- Noclip
local noclip = false
PlayerTab:CreateToggle({
    Name="Local Noclip",
    CurrentValue=false,
    Flag="ps_noclip",
    Callback=function(state)
        noclip = state
        if character then
            for _,p in pairs(character:GetDescendants()) do
                if p:IsA("BasePart") then p.CanCollide = not state end
            end
        end
        notify("Player","Noclip: "..tostring(state),2)
    end
})

-- Double Jump
local doubleJump = false
local canDoubleJump = true
local humanoid = character:FindFirstChildOfClass("Humanoid")
if humanoid then
    humanoid.StateChanged:Connect(function(old,new)
        if new == Enum.HumanoidStateType.Landed then
            canDoubleJump = true
        end
    end)
end
PlayerTab:CreateToggle({
    Name="Double Jump",
    CurrentValue=false,
    Flag="ps_djump",
    Callback=function(state)
        doubleJump = state
        notify("Player","Double Jump: "..tostring(state),2)
    end
})
UserInputService.JumpRequest:Connect(function()
    if doubleJump and canDoubleJump and character and character:FindFirstChildOfClass("Humanoid") then
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if humanoid:GetState() ~= Enum.HumanoidStateType.Seated then
            humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            canDoubleJump = false
            spawnFX("Bright yellow",0.4,0.3,3)
        end
    end
end)

-- ===== Teleport Tab =====
local TeleportTab = Window:CreateTab("Teleport",nil)
local teleports = {
    ["Spawn"]=Vector3.new(5906,26.25,-1846),
    ["NALBURİYE"]=Vector3.new(6484,26,-1692),
    ["MALİKANE"]=Vector3.new(5093,40,-1219),
    ["Ev (Verilen)"]=Vector3.new(5114.3,40,-1150),
    ["BUGLU EV"]=Vector3.new(5077,40,-1165),
    ["TOKİLER"]=Vector3.new(4575,26,-1151)
}
local function safeTeleportTo(pos)
    if character and character.PrimaryPart then
        character:SetPrimaryPartCFrame(CFrame.new(pos))
        spawnFX("Bright cyan",0.3,0.3,5)
        notify("Teleport","Gitildi!",2)
    end
end
for name,pos in pairs(teleports) do
    TeleportTab:CreateButton({Name=name, Callback=function() safeTeleportTo(pos) end})
end

-- ===== Final =====
notify("AdanaCityUltra","",5)
print("AdanaCityUltra Mega FX Hub loaded.")


    spawnConnection:Disconnect()

    local fadeTween = TweenService:Create(frame, TweenInfo.new(1.5, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {BackgroundTransparency = 1})
    fadeTween:Play()
    fadeTween.Completed:Connect(function()
        screenGui:Destroy()
    end)
end)
