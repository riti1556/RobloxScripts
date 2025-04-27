-- Максимально упрощенный и прямой Auto Parry для Blade Ball
-- by zxwhgdsushgs
-- GitHub: riti1556

-- Сервисы Roblox
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")

-- Получаем объекты игрока
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

-- Настройки скрипта
local PARRY_DISTANCE = 25 -- Увеличенная дистанция для надёжности
local PARRY_COOLDOWN = 0.3 -- Меньшая задержка
local lastParryTime = 0
local parryCount = 0
local scriptActive = true

-- Создаем GUI для отображения статуса
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "BladeBallAutoParryGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = player.PlayerGui

-- Создаем рамку статуса
local StatusFrame = Instance.new("Frame")
StatusFrame.Name = "StatusFrame"
StatusFrame.Size = UDim2.new(0, 200, 0, 100)
StatusFrame.Position = UDim2.new(0, 10, 0, 10)
StatusFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
StatusFrame.BackgroundTransparency = 0.5
StatusFrame.BorderSizePixel = 2
StatusFrame.BorderColor3 = Color3.fromRGB(0, 255, 0)
StatusFrame.Parent = ScreenGui

-- Заголовок
local TitleLabel = Instance.new("TextLabel")
TitleLabel.Name = "TitleLabel"
TitleLabel.Size = UDim2.new(1, 0, 0, 25)
TitleLabel.BackgroundTransparency = 0.7
TitleLabel.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.Font = Enum.Font.SourceSansBold
TitleLabel.TextSize = 14
TitleLabel.Text = "AutoParry v3 by riti1556"
TitleLabel.Parent = StatusFrame

-- Статус скрипта
local StatusLabel = Instance.new("TextLabel")
StatusLabel.Name = "StatusLabel"
StatusLabel.Size = UDim2.new(1, 0, 0, 25)
StatusLabel.Position = UDim2.new(0, 0, 0, 25)
StatusLabel.BackgroundTransparency = 1
StatusLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
StatusLabel.Font = Enum.Font.SourceSans
StatusLabel.TextSize = 14
StatusLabel.Text = "АКТИВЕН"
StatusLabel.Parent = StatusFrame

-- Информация о парированиях
local CountLabel = Instance.new("TextLabel")
CountLabel.Name = "CountLabel"
CountLabel.Size = UDim2.new(1, 0, 0, 25)
CountLabel.Position = UDim2.new(0, 0, 0, 50)
CountLabel.BackgroundTransparency = 1
CountLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
CountLabel.Font = Enum.Font.SourceSans
CountLabel.TextSize = 14
CountLabel.Text = "Парирований: 0"
CountLabel.Parent = StatusFrame

-- Кнопка включения/выключения
local ToggleButton = Instance.new("TextButton")
ToggleButton.Name = "ToggleButton"
ToggleButton.Size = UDim2.new(1, 0, 0, 25)
ToggleButton.Position = UDim2.new(0, 0, 0, 75)
ToggleButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
ToggleButton.BorderSizePixel = 1
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.Font = Enum.Font.SourceSans
ToggleButton.TextSize = 14
ToggleButton.Text = "Выключить"
ToggleButton.Parent = StatusFrame

-- Обработчик нажатия кнопки вкл/выкл
ToggleButton.MouseButton1Click:Connect(function()
    scriptActive = not scriptActive
    
    if scriptActive then
        StatusLabel.Text = "АКТИВЕН"
        StatusLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
        StatusFrame.BorderColor3 = Color3.fromRGB(0, 255, 0)
        ToggleButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
        ToggleButton.Text = "Выключить"
    else
        StatusLabel.Text = "НЕАКТИВЕН"
        StatusLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
        StatusFrame.BorderColor3 = Color3.fromRGB(255, 0, 0)
        ToggleButton.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
        ToggleButton.Text = "Включить"
    end
end)

-- Делаем рамку перетаскиваемой
local isDragging = false
local dragStart = nil
local startPos = nil

TitleLabel.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        isDragging = true
        dragStart = input.Position
        startPos = StatusFrame.Position
    end
end)

TitleLabel.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        isDragging = false
    end
end)

TitleLabel.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement and isDragging then
        local delta = input.Position - dragStart
        StatusFrame.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end
end)

-- Функция нажатия на F (парирование)
local function PressParry()
    if not scriptActive then return end
    
    local currentTime = tick()
    if currentTime - lastParryTime < PARRY_COOLDOWN then return end
    
    -- Используем множество методов, чтобы гарантировать работу
    -- Метод 1: Virtual Input Manager (клавиша F)
    pcall(function()
        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.F, false, game)
        wait()
        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.F, false, game)
    end)
    
    -- Метод 2: Поиск Remote Events
    pcall(function()
        for _, v in pairs(game:GetService("ReplicatedStorage"):GetDescendants()) do
            if v:IsA("RemoteEvent") and (v.Name:lower():find("parry") or v.Name:lower() == "parry") then
                v:FireServer()
                break
            end
        end
    end)
    
    -- Метод 3: Поиск GUI кнопок
    pcall(function()
        for _, gui in pairs(player.PlayerGui:GetDescendants()) do
            if (gui:IsA("TextButton") or gui:IsA("ImageButton")) and 
               (gui.Name:lower():find("parry") or (gui.Text and gui.Text:lower():find("parry"))) then
                for _, connection in pairs(getconnections(gui.MouseButton1Click)) do
                    connection:Fire()
                end
                break
            end
        end
    end)
    
    -- Обновляем счетчик и время
    lastParryTime = currentTime
    parryCount = parryCount + 1
    CountLabel.Text = "Парирований: " .. parryCount
end

-- Функция поиска мяча
local function FindBall()
    local closestBall = nil
    local closestDistance = PARRY_DISTANCE
    
    -- Ищем мяч по имени
    for _, obj in pairs(workspace:GetChildren()) do
        if obj:IsA("BasePart") and (obj.Name == "Ball" or obj.Name:lower():find("ball")) then
            local distance = (obj.Position - humanoidRootPart.Position).Magnitude
            if distance < closestDistance then
                closestBall = obj
                closestDistance = distance
            end
        end
    end
    
    -- Если мяч не найден по имени, ищем по свойствам
    if not closestBall then
        for _, obj in pairs(workspace:GetDescendants()) do
            if obj:IsA("BasePart") and obj:GetAttribute("IsBall") then
                local distance = (obj.Position - humanoidRootPart.Position).Magnitude
                if distance < closestDistance then
                    closestBall = obj
                    closestDistance = distance
                end
            end
        end
    end
    
    return closestBall, closestDistance
end

-- Основной цикл
RunService.Heartbeat:Connect(function()
    if not scriptActive then return end
    
    -- Обновляем ссылки на персонажа
    character = player.Character
    if not character then return end
    
    humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then return end
    
    -- Ищем мяч
    local ball, distance = FindBall()
    
    -- Если мяч найден и близко - выполняем парирование
    if ball and distance <= PARRY_DISTANCE then
        PressParry()
    end
end)

-- Обработчик входа в игру или смены персонажа
player.CharacterAdded:Connect(function(newCharacter)
    character = newCharacter
    humanoidRootPart = newCharacter:WaitForChild("HumanoidRootPart")
end)

-- Переключение по клавише P
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.P then
        scriptActive = not scriptActive
        
        if scriptActive then
            StatusLabel.Text = "АКТИВЕН"
            StatusLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
            StatusFrame.BorderColor3 = Color3.fromRGB(0, 255, 0)
            ToggleButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
            ToggleButton.Text = "Выключить"
        else
            StatusLabel.Text = "НЕАКТИВЕН"
            StatusLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
            StatusFrame.BorderColor3 = Color3.fromRGB(255, 0, 0)
            ToggleButton.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
            ToggleButton.Text = "Включить"
        end
    end
end)

print("Blade Ball AutoParry v3 успешно загружен!")
print("Нажмите клавишу P для включения/выключения")
