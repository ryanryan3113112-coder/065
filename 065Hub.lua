--[[
    Developed by: 065
    Project: Multi-Hack Hub (ESP + FLY)
    Version: 4.2
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer

-- 防止重複注入
if CoreGui:FindFirstChild("Hub065") then
    CoreGui:FindFirstChild("Hub065"):Destroy()
end

-- 狀態變數
local ESP_ENABLED = false
local FLY_ENABLED = false
local flySpeed = 50

-- --- 1. GUI 主介面構建 ---
local Hub065 = Instance.new("ScreenGui")
Hub065.Name = "Hub065"
Hub065.Parent = CoreGui
Hub065.ResetOnSpawn = false

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Parent = Hub065
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.BorderSizePixel = 0
MainFrame.Position = UDim2.new(0.3, 0, 0.3, 0)
MainFrame.Size = UDim2.new(0, 180, 0, 200) -- 調整大小以容納更多按鈕
MainFrame.Active = true
MainFrame.Draggable = true -- 讓整個視窗可拖動

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 10)
UICorner.Parent = MainFrame

-- 標題: 065製作
local Title = Instance.new("TextLabel")
Title.Name = "Title"
Title.Parent = MainFrame
Title.BackgroundTransparency = 1
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Font = Enum.Font.GothamBold
Title.Text = "065 官方外掛""
Title.TextColor3 = Color3.fromRGB(255, 215, 0)
Title.TextSize = 18

local SubTitle = Instance.new("TextLabel")
SubTitle.Parent = MainFrame
SubTitle.BackgroundTransparency = 1
SubTitle.Position = UDim2.new(0, 0, 0, 30)
SubTitle.Size = UDim2.new(1, 0, 0, 20)
SubTitle.Font = Enum.Font.SourceSansItalic
SubTitle.Text = "by 065與PW共同製作"
SubTitle.TextColor3 = Color3.fromRGB(200, 200, 200)
SubTitle.TextSize = 14

-- --- 2. 功能按鈕工廠 ---
local function CreateButton(name, text, pos, color)
    local btn = Instance.new("TextButton")
    btn.Name = name
    btn.Parent = MainFrame
    btn.BackgroundColor3 = color
    btn.Position = pos
    btn.Size = UDim2.new(0.8, 0, 0, 35)
    btn.AnchorPoint = Vector2.new(0.5, 0)
    btn.Position = UDim2.new(0.5, 0, pos.Y.Scale, pos.Y.Offset)
    btn.Font = Enum.Font.GothamBold
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 14
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = btn
    
    return btn
end

local ESPBtn = CreateButton("ESPBtn", "ESP: 關閉", UDim2.new(0.5, 0, 0, 60), Color3.fromRGB(170, 0, 0))
local FlyBtn = CreateButton("FlyBtn", "FLY: 關閉", UDim2.new(0.5, 0, 0, 105), Color3.fromRGB(170, 0, 0))
local CloseBtn = CreateButton("CloseBtn", "關閉選單", UDim2.new(0.5, 0, 0, 150), Color3.fromRGB(50, 50, 50))

-- --- 3. ESP 邏輯 ---
local function SetupHighlight(char)
    if not char:FindFirstChild("ESPHighlight") then
        local highlight = Instance.new("Highlight")
        highlight.Name = "ESPHighlight"
        highlight.Parent = char
        highlight.FillColor = Color3.fromRGB(255, 0, 0)
        highlight.Enabled = ESP_ENABLED
    end
end

ESPBtn.MouseButton1Click:Connect(function()
    ESP_ENABLED = not ESP_ENABLED
    ESPBtn.Text = ESP_ENABLED and "ESP: 開啟" or "ESP: 關閉"
    ESPBtn.BackgroundColor3 = ESP_ENABLED and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(170, 0, 0)
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then SetupHighlight(p.Character) end
        if p.Character and p.Character:FindFirstChild("ESPHighlight") then
            p.Character.ESPHighlight.Enabled = ESP_ENABLED
        end
    end
end)

-- --- 4. FLY 邏輯 ---
local bGyro = Instance.new("BodyGyro")
local bVelo = Instance.new("BodyVelocity")
bGyro.P = 9e4
bVelo.MaxForce = Vector3.new(9e4, 9e4, 9e4)

FlyBtn.MouseButton1Click:Connect(function()
    FLY_ENABLED = not FLY_ENABLED
    FlyBtn.Text = FLY_ENABLED and "FLY: 開啟" or "FLY: 關閉"
    FlyBtn.BackgroundColor3 = FLY_ENABLED and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(170, 0, 0)
    
    local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not root then return end
    
    if FLY_ENABLED then
        bGyro.Parent = root
        bVelo.Parent = root
        LocalPlayer.Character.Humanoid.PlatformStand = true
    else
        bGyro.Parent = nil
        bVelo.Parent = nil
        LocalPlayer.Character.Humanoid.PlatformStand = false
    end
end)

RunService.RenderStepped:Connect(function()
    if FLY_ENABLED and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local root = LocalPlayer.Character.HumanoidRootPart
        local cam = workspace.CurrentCamera
        bGyro.CFrame = cam.CFrame
        local moveDir = LocalPlayer.Character.Humanoid.MoveDirection
        if moveDir.Magnitude > 0 then
            bVelo.Velocity = cam.CFrame.LookVector * flySpeed * (moveDir.Z < 0 and 1 or -1) + (cam.CFrame.RightVector * flySpeed * moveDir.X)
        else
            bVelo.Velocity = Vector3.new(0, 0.1, 0)
        end
    end
end)

-- --- 5. 關閉按鈕 ---
CloseBtn.MouseButton1Click:Connect(function()
    Hub065:Destroy() -- 直接銷毀介面
end)

-- 初始化玩家監聽
Players.PlayerAdded:Connect(function(p)
    p.CharacterAdded:Connect(SetupHighlight)
end)


print("065 Hub 已成功加載！")
