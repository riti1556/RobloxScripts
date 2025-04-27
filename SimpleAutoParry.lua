-- Упрощенная версия BladeballAutoParry
-- by zxwhgdsushgs
-- GitHub: riti1556

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")

-- Настройки
local ParryDistance = 20
local IsParrying = false
local ScriptEnabled = true
local ParryCount = 0

-- Создаем простой интерфейс
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AutoParryGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 150, 0, 80)
MainFrame.Position = UDim2.new(0, 10, 0, 10)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.BorderColor3 = Color3.fromRGB(0, 255, 0)
MainFrame.BorderSizePixel = 2
MainFrame.Parent = ScreenGui

local StatusText = Instance.new("TextLabel")
StatusText.Size = UDim2.new(1, 0, 0, 25)
StatusText.Position = UDim2.new(0, 0, 0, 0)
StatusText.BackgroundTransparency = 0.7
StatusText.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
StatusText.TextColor3 = Color3.fromRGB(0, 255, 0)
StatusText.Font = Enum.Font.SourceSansBold
StatusText.TextSize = 14
StatusText.Text = "AUTO PARRY: ВКЛ"
StatusText.Parent = MainFrame

local CountText = Instance.new("TextLabel")
CountText.Size = UDim2.new(1, 0, 0, 25)
CountText.Position = UDim2.new(0, 0, 0, 25)
CountText.BackgroundTransparency = 1
CountText.TextColor3 = Color3.fromRGB(255, 255, 255)
CountText.Font = Enum.Font.SourceSans
CountText.TextSize = 14
CountText.Text = "Парирований: 0"
CountText.Parent = MainFrame

local ToggleButton = Instance.new("TextButton")
ToggleButton.Size = UDim2.new(1, 0, 0, 30)
ToggleButton.Position = UDim2.new(0, 0, 0, 50)
ToggleButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.Font = Enum.Font.SourceSans
ToggleButton.TextSize = 14
ToggleButton.Text = "ВЫКЛЮЧИТЬ"
ToggleButton.Parent = MainFrame

-- Функция переключения
local function ToggleScript()
    ScriptEnabled = not ScriptEnabled
    if ScriptEnabled then
        StatusText.Text = "AUTO PARRY: ВКЛ"
        StatusText.TextColor3 = Color3.fromRGB(0, 255, 0)
        MainFrame.BorderColor3 = Color3.fromRGB(0, 255, 0)
        ToggleButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
        ToggleButton.Text = "ВЫКЛЮЧИТЬ"
    else
        StatusText.Text = "AUTO PARRY: ВЫКЛ"
        StatusText.TextColor3 = Color3.fromRGB(255, 0, 0)
        MainFrame.BorderColor3 = Color3.fromRGB(255, 0, 0)
        ToggleButton.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
        ToggleButton.Text = "ВКЛЮЧИТЬ"
    end
end

ToggleButton.MouseButton1Click:Connect(ToggleScript)

-- Переключение по клавише "P"
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.P then
        ToggleScript()
    end
end)

-- Упрощенная функция парирования
local function Parry()
    if not ScriptEnabled or IsParrying then return end
    
    IsParrying = true
    
    -- Ищем удаленное событие парирования
    local parryEvent = ReplicatedStorage:FindFirstChild("Parry")
    local success = false
    
    if parryEvent and parryEvent:IsA("RemoteEvent") then
        -- Метод 1: использовать прямой удаленный ивент
        parryEvent:FireServer()
        success = true
    else
        -- Метод 2: найти любое событие с "parry" в имени
        for _, event in pairs(ReplicatedStorage:GetDescendants()) do
            if event:IsA("RemoteEvent") and string.match(event.Name:lower(), "parry") then
                event:FireServer()
                success = true
                break
            end
        end
        
        -- Метод 3: симулировать нажатие клавиши E
        if not success then
            game:GetService("VirtualInputManager"):SendKeyEvent(true, Enum.KeyCode.E, false, game)
            wait(0.1)
            game:GetService("VirtualInputManager"):SendKeyEvent(false, Enum.KeyCode.E, false, game)
            success = true
        end
    end
    
    if success then
        ParryCount = ParryCount + 1
        CountText.Text = "Парирований: " .. ParryCount
    end
    
    wait(0.5) -- Защита от спама
    IsParrying = false
end

-- Проверка игры
local function IsBladeBall()
    return game.PlaceId == 13772394625 or game.PlaceId == 13816678286
end

-- Главный цикл
RunService.Heartbeat:Connect(function()
    if not ScriptEnabled then return end
    
    -- Обновляем ссылки на персонажа
    Character = LocalPlayer.Character
    if not Character then return end
    
    HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart")
    if not HumanoidRootPart then return end
    
    -- Ищем все мячи на сцене
    local nearestBall = nil
    local nearestDistance = ParryDistance
    
    for _, obj in pairs(workspace:GetChildren()) do
        if (obj.Name == "Ball" or string.match(obj.Name:lower(), "ball")) and obj:IsA("BasePart") then
            local distance = (obj.Position - HumanoidRootPart.Position).Magnitude
            if distance < nearestDistance then
                nearestBall = obj
                nearestDistance = distance
            end
        end
    end
    
    -- Если нашли мяч и он подходит для парирования, делаем парирование
    if nearestBall then
        local dist = (nearestBall.Position - HumanoidRootPart.Position).Magnitude
        if dist <= ParryDistance then
            Parry()
        end
    end
end)

-- Сообщение о запуске
print("Упрощенный Auto Parry скрипт запущен!")
print("Нажмите P для включения/выключения")
