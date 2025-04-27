-- Blade Ball Working AutoParry
-- by zxwhgdsushgs
-- GitHub: riti1556

-- Сервисы
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")

-- Переменные
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local rootPart = character:WaitForChild("HumanoidRootPart")
local parryDistance = 30 -- расстояние для парирования
local parryButtonPressed = false
local scriptEnabled = true
local parryCount = 0

-- Создаем интерфейс
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AutoParryGUI"
ScreenGui.Parent = player.PlayerGui
ScreenGui.ResetOnSpawn = false

-- Основная рамка
local Frame = Instance.new("Frame")
Frame.Name = "MainFrame"
Frame.Size = UDim2.new(0, 200, 0, 100)
Frame.Position = UDim2.new(0, 10, 0, 10)
Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Frame.BorderSizePixel = 2
Frame.BorderColor3 = Color3.fromRGB(0, 255, 0)
Frame.Parent = ScreenGui

-- Заголовок
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 25)
Title.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 16
Title.Text = "Auto Parry v1 [riti1556]"
Title.Parent = Frame

-- Статус
local Status = Instance.new("TextLabel")
Status.Size = UDim2.new(1, 0, 0, 25)
Status.Position = UDim2.new(0, 0, 0, 25)
Status.BackgroundTransparency = 1
Status.TextColor3 = Color3.fromRGB(0, 255, 0)
Status.Font = Enum.Font.SourceSans
Status.TextSize = 14
Status.Text = "АКТИВЕН"
Status.Parent = Frame

-- Счетчик
local Counter = Instance.new("TextLabel")
Counter.Size = UDim2.new(1, 0, 0, 25)
Counter.Position = UDim2.new(0, 0, 0, 50)
Counter.BackgroundTransparency = 1
Counter.TextColor3 = Color3.fromRGB(255, 255, 255)
Counter.Font = Enum.Font.SourceSans
Counter.TextSize = 14
Counter.Text = "Парирований: 0"
Counter.Parent = Frame

-- Кнопка вкл/выкл
local ToggleButton = Instance.new("TextButton")
ToggleButton.Size = UDim2.new(1, 0, 0, 25)
ToggleButton.Position = UDim2.new(0, 0, 0, 75)
ToggleButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.Font = Enum.Font.SourceSans
ToggleButton.TextSize = 14
ToggleButton.Text = "Выключить"
ToggleButton.Parent = Frame

-- Функция переключения
ToggleButton.MouseButton1Click:Connect(function()
    scriptEnabled = not scriptEnabled
    
    if scriptEnabled then
        Status.Text = "АКТИВЕН"
        Status.TextColor3 = Color3.fromRGB(0, 255, 0)
        Frame.BorderColor3 = Color3.fromRGB(0, 255, 0)
        ToggleButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
        ToggleButton.Text = "Выключить"
    else
        Status.Text = "НЕАКТИВЕН"
        Status.TextColor3 = Color3.fromRGB(255, 0, 0)
        Frame.BorderColor3 = Color3.fromRGB(255, 0, 0)
        ToggleButton.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
        ToggleButton.Text = "Включить"
    end
end)

-- Переключение по клавише P
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.P then
        scriptEnabled = not scriptEnabled
        
        if scriptEnabled then
            Status.Text = "АКТИВЕН"
            Status.TextColor3 = Color3.fromRGB(0, 255, 0)
            Frame.BorderColor3 = Color3.fromRGB(0, 255, 0)
            ToggleButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
            ToggleButton.Text = "Выключить"
        else
            Status.Text = "НЕАКТИВЕН"
            Status.TextColor3 = Color3.fromRGB(255, 0, 0)
            Frame.BorderColor3 = Color3.fromRGB(255, 0, 0)
            ToggleButton.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
            ToggleButton.Text = "Включить"
        end
    end
end)

-- Функция парирования
function Parry()
    if not scriptEnabled or parryButtonPressed then 
        return 
    end
    
    parryButtonPressed = true
    
    -- Метод 1: Прямое нажатие F (стандартная кнопка парирования)
    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.F, false, game)
    wait(0.1)
    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.F, false, game)
    
    -- Обновляем счетчик
    parryCount = parryCount + 1
    Counter.Text = "Парирований: " .. parryCount
    
    -- Задержка перед следующим парированием
    wait(0.3)
    parryButtonPressed = false
end

-- Основной цикл
RunService.Heartbeat:Connect(function()
    if not scriptEnabled then return end
    
    -- Обновляем ссылку на персонажа
    character = player.Character
    if not character then return end
    
    rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return end
    
    -- Ищем мяч
    local nearestBall = nil
    local nearestDistance = parryDistance
    
    for _, obj in pairs(workspace:GetChildren()) do
        if obj:IsA("BasePart") and (obj.Name == "Ball" or string.find(obj.Name:lower(), "ball")) then
            local distance = (obj.Position - rootPart.Position).Magnitude
            if distance < nearestDistance then
                nearestBall = obj
                nearestDistance = distance
                break
            end
        end
    end
    
    -- Если мяч найден и достаточно близко, выполняем парирование
    if nearestBall then
        Parry()
    end
end)

print("Auto Parry успешно загружен!")
print("Нажмите P для переключения")
