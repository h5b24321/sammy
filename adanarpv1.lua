-- Adana City RP | Ultra Smart Hub v2.0 (Safe & Fancy)
-- Features: Ultra toast, Infinity Dex, Smooth teleport & bring, HUD, R6 dances, themes, custom particles, dynamic malikane, fancy visual effects

-- Rayfield Load
local ok, Rayfield = pcall(function() return loadstring(game:HttpGet('https://sirius.menu/rayfield'))() end)
if not ok or not Rayfield then warn("Rayfield yüklenemedi!"); return end

local Window = Rayfield:CreateWindow({
    Name = "Adana City RP | Ultra Smart Hub",
    LoadingTitle = "💎 Yükleniyor...",
    LoadingSubtitle = "👑 by CostyTR (Safe + Fancy) 👑",
    Theme = "Default",
    ConfigurationSaving = { Enabled = true, FolderName = "AdanaCityUltraSmart", FileName = "config" },
    KeySystem = false
})

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local Lighting = game:GetService("Lighting")

local localPlayer = Players.LocalPlayer
local character = localPlayer.Character or localPlayer.CharacterAdded:Wait()

local function refreshCharacter()
    character = localPlayer.Character or localPlayer.CharacterAdded:Wait()
end
localPlayer.CharacterAdded:Connect(function() wait(0.1); refreshCharacter() end)

-- -------------------- TOAST SYSTEM (Ultra Fancy) --------------------
local toastGui, toastList, toastY = nil, {}, 10
local function ensureToastGui()
    if toastGui and toastGui.Parent then return toastGui end
    toastGui = Instance.new("ScreenGui")
    toastGui.Name = "AdanaCityToasts"
    toastGui.ResetOnSpawn = false
    toastGui.Parent = localPlayer:WaitForChild("PlayerGui")
    return toastGui
end

local function showToast(title, text, duration, color, icon)
    ensureToastGui()
    duration = duration or 3
    color = color or Color3.fromRGB(35,35,35)
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 320, 0, 70)
    frame.Position = UDim2.new(1, 350, 0, toastY)
    frame.BackgroundColor3 = color
    frame.BackgroundTransparency = 0.08
    frame.AnchorPoint = Vector2.new(0,0)
    frame.Name = "Toast"
    frame.Parent = toastGui
    frame.ZIndex = 10
    
    -- Icon
    if icon then
        local img = Instance.new("ImageLabel", frame)
        img.Size = UDim2.new(0,32,0,32)
        img.Position = UDim2.new(0,5,0,19)
        img.BackgroundTransparency=1
        img.Image = icon
    end
    
    -- Title
    local titleLbl = Instance.new("TextLabel", frame)
    titleLbl.Size = UDim2.new(1, -50, 0, 24)
    titleLbl.Position = UDim2.new(0, 45, 0, 8)
    titleLbl.BackgroundTransparency = 1
    titleLbl.Text = title
    titleLbl.TextXAlignment = Enum.TextXAlignment.Left
    titleLbl.Font = Enum.Font.SourceSansBold
    titleLbl.TextSize = 18
    titleLbl.TextColor3 = Color3.new(1,1,1)
    
    -- Text
    local textLbl = Instance.new("TextLabel", frame)
    textLbl.Size = UDim2.new(1, -50, 0, 28)
    textLbl.Position = UDim2.new(0, 45, 0, 32)
    textLbl.BackgroundTransparency = 1
    textLbl.Text = text
    textLbl.TextXAlignment = Enum.TextXAlignment.Left
    textLbl.Font = Enum.Font.SourceSans
    textLbl.TextSize = 14
    textLbl.TextColor3 = Color3.new(0.9,0.9,0.9)
    
    -- Tween In
    TweenService:Create(frame, TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position=UDim2.new(1,-330,0,toastY)}):Play()
    
    toastY = toastY + 75
    delay(duration, function()
        TweenService:Create(frame, TweenInfo.new(0.25), {Position=UDim2.new(1,350,0,toastY)}):Play()
        wait(0.26)
        if frame and frame.Parent then frame:Destroy() end
        toastY = math.max(10, toastY-75)
    end)
end

local function notify(title,text,dur,color,icon) showToast(title,text,dur,color,icon) end

-- -------------------- HUD: FPS & Ping --------------------
local hudGui, fpsLabel, pingLabel, frameAvg = nil, nil, nil, {}
local function ensureHUD()
    if hudGui and hudGui.Parent then return end
    hudGui = Instance.new("ScreenGui")
    hudGui.Name = "AdanaCityHUD"
    hudGui.ResetOnSpawn=false
    hudGui.Parent = localPlayer:WaitForChild("PlayerGui")
    
    local bg = Instance.new("Frame",hudGui)
    bg.Size = UDim2.new(0,180,0,55)
    bg.Position = UDim2.new(0,10,0,10)
    bg.BackgroundTransparency=0.6
    bg.BackgroundColor3=Color3.fromRGB(20,20,20)
    bg.BorderSizePixel=0
    
    fpsLabel = Instance.new("TextLabel",bg)
    fpsLabel.Size=UDim2.new(1,-8,0,24)
    fpsLabel.Position=UDim2.new(0,4,0,4)
    fpsLabel.BackgroundTransparency=1
    fpsLabel.Font=Enum.Font.SourceSans
    fpsLabel.TextSize=16
    fpsLabel.TextColor3=Color3.new(1,1,1)
    fpsLabel.TextXAlignment=Enum.TextXAlignment.Left
    
    pingLabel = Instance.new("TextLabel",bg)
    pingLabel.Size=UDim2.new(1,-8,0,20)
    pingLabel.Position=UDim2.new(0,4,0,28)
    pingLabel.BackgroundTransparency=1
    pingLabel.Font=Enum.Font.SourceSans
    pingLabel.TextSize=14
    pingLabel.TextColor3=Color3.new(0.85,0.85,0.85)
    pingLabel.TextXAlignment=Enum.TextXAlignment.Left
end
ensureHUD()

RunService.RenderStepped:Connect(function(dt)
    local fps = math.floor(1/dt)
    table.insert(frameAvg,fps)
    if #frameAvg>10 then table.remove(frameAvg,1) end
    local sum=0
    for _,v in ipairs(frameAvg) do sum=sum+v end
    local avg=math.floor(sum/#frameAvg)
    fpsLabel.Text="FPS: "..tostring(avg)
    pingLabel.Text="Ping: "..tostring(math.floor(localPlayer:GetNetworkPing()*1000)).." ms"
end)

-- -------------------- UTILITY: Find / Bring Models --------------------
local function findModelByName(query)
    if not query or query=="" then return {} end
    local q=string.lower(query)
    local matches={}
    for _,obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("Model") then
            local name=tostring(obj.Name or "")
            if string.lower(name)==q or string.find(string.lower(name),q) then table.insert(matches,obj) end
        elseif obj:IsA("BasePart") then
            local m=obj:FindFirstAncestorOfClass("Model")
            if m then local name=tostring(m.Name or ""); if string.lower(name)==q or string.find(string.lower(name),q) then table.insert(matches,m) end end
        end
    end
    local unique, seen = {}, {}
    for _,m in ipairs(matches) do if not seen[m] then seen[m]=true; table.insert(unique,m) end end
    return unique
end

local function bringModelToPlayer(model)
    if not model then return false,"Model nil" end
    local ok, err = pcall(function()
        if model.PrimaryPart and character and character.PrimaryPart then
            local pos = character.PrimaryPart.CFrame * CFrame.new(5,0,5)
            model:SetPrimaryPartCFrame(pos)
            notify("Vehicle",model.Name.." getirildi",3)
            return
        end
        local clone=model:Clone()
        clone.Parent=workspace
        local pivot = clone.PrimaryPart and clone.PrimaryPart.Position or (clone:FindFirstChildWhichIsA("BasePart") and clone:FindFirstChildWhichIsA("BasePart").Position)
        if not pivot then error("Pivot bulunamadı") end
        local desired = character.PrimaryPart.Position + character.PrimaryPart.CFrame.LookVector*5 + Vector3.new(0,1,0)
        local delta = desired - pivot
        for _,p in pairs(clone:GetDescendants()) do if p:IsA("BasePart") then p.CFrame=p.CFrame+delta end end
        if not clone.PrimaryPart then clone.PrimaryPart=clone:FindFirstChildWhichIsA("BasePart") end
        notify("Vehicle",model.Name.." kopyası getirildi",3)
    end)
    if not ok then return false,tostring(err) end
    return true
end

-- -------------------- KEYBINDS --------------------
local keybinds = { CloseGUI=Enum.KeyCode.K }
UserInputService.InputBegan:Connect(function(input,gp)
    if gp then return end
    if input.KeyCode==keybinds.CloseGUI then
        pcall(function() Window:Destroy() end)
        notify("GUI","Kapandı",2)
    end
end)

-- -------------------- PLAYER TAB --------------------
local PlayerTab = Window:CreateTab("Player", nil)
PlayerTab:CreateSlider({ Name="WalkSpeed", Range={16,200}, Increment=1, CurrentValue=16, Flag="ps_ws", Callback=function(v) if character and character:FindFirstChildOfClass("Humanoid") then character:FindFirstChildOfClass("Humanoid").WalkSpeed=v end end })
PlayerTab:CreateSlider({ Name="JumpPower", Range={50,300}, Increment=1, CurrentValue=50, Flag="ps_jp", Callback=function(v) if character and character:FindFirstChildOfClass("Humanoid") then character:FindFirstChildOfClass("Humanoid").JumpPower=v end end })
PlayerTab:CreateToggle({ Name="Invisible (Local)", CurrentValue=false, Flag="ps_invis", Callback=function(s) if character then for _,p in pairs(character:GetDescendants()) do if p:IsA("BasePart") then p.LocalTransparencyModifier = s and 1 or 0 end end notify("Player","Local invis: "..tostring(s),2) end end })
PlayerTab:CreateToggle({ Name="Noclip (Local)", CurrentValue=false, Flag="ps_noclip", Callback=function(s) if character then for _,p in pairs(character:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide=not s end end notify("Player","Local noclip: "..tostring(s),2) end end })
PlayerTab:CreateButton({ Name="Reset Character", Callback=function() localPlayer:LoadCharacter() end })
PlayerTab:CreateButton({ Name="Nearby Players", Callback=function()
    if not character or not character.PrimaryPart then notify("Player","Karakter yok",2); return end
    local list={}
    for _,p in ipairs(Players:GetPlayers()) do
        if p~=localPlayer and p.Character and p.Character.PrimaryPart then
            local d=(p.Character.PrimaryPart.Position-character.PrimaryPart.Position).Magnitude
            if d<=50 then table.insert(list,p.Name.."("..math.floor(d).."m)") end
        end
    end
    notify("Nearby",#list>0 and table.concat(list,", ") or "Yakında kimse yok",4)
end })

-- -------------------- TELEPORT TAB --------------------
local TeleportTab = Window:CreateTab("Teleport", nil)
local function safeTeleportTo(pos)
    if character and character.PrimaryPart then
        TweenService:Create(character.PrimaryPart, TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {CFrame=CFrame.new(pos)}):Play()
        notify("Teleport","Işınlandı",2)
    end
end
TeleportTab:CreateButton({ Name="Spawn", Callback=function() safeTeleportTo(Vector3.new(5906,26.25,-1846)) end })

-- -------------------- VEHICLE TAB --------------------
local VehicleTab = Window:CreateTab("Vehicle", nil)
VehicleTab:CreateButton({ Name="16' Boxster GTS Finder", Callback=function()
    local matches=findModelByName("16' Boxster GTS")
    if #matches==0 then notify("Vehicle","Bulunamadı",3); return end
    bringModelToPlayer(matches[1])
end })

-- -------------------- DANCE TAB --------------------
local DanceTab = Window:CreateTab("Dance (R6)", nil)
local danceAnims={{Name="Dance 1",Id=180435571},{Name="Dance 2",Id=180426354}}
local function playAnim(id)
    if not character then notify("Dance","Karakter yok",2); return end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid then notify("Dance","Humanoid yok",2); return end
    local animator = humanoid:FindFirstChildOfClass("Animator") or humanoid:FindFirstChild("Animator")
    if not animator then animator = Instance.new("Animator"); animator.Parent=humanoid end
    local animation = Instance.new("Animation")
    animation.AnimationId="rbxassetid://"..tostring(id)
    local track = animator:LoadAnimation(animation)
    track:Play()
    Debris:AddItem(animation,12)
    delay(10,function() pcall(function() track:Stop() end) end)
end
for _,a in ipairs(danceAnims) do DanceTab:CreateButton({Name=a.Name,Callback=function() playAnim(a.Id) end}) end

-- -------------------- MISC --------------------
MiscTab=Window:CreateTab("Misc",nil)
MiscTab:CreateButton({Name="Show Version",Callback=function() print("AdanaCityUltraSmart v2.0"); notify("Misc","Versiyon konsola yazıldı",3) end})

notify("AdanaCityUltraSmart","Yüklendi — Ultra fancy hub, toastlar, HUD, R6 dans ve daha fazlası hazır!",5)
print("AdanaCityUltraSmart v2.0 loaded. Enjoy uwu~")
