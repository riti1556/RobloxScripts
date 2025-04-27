--[[
    Простой ESP для Roblox
    by zxwhgdsushgs
    GitHub: riti1556
    
    Отображает обводку вокруг других игроков с указанием расстояния до них.
    ESP (ExtraSensory Perception) - визуальные подсказки для обнаружения объектов.
]]

-- Сервисы Roblox
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

-- Настройки ESP
local ESP_ENABLED = true -- ESP включен по умолчанию
local MAX_DISTANCE = 1000 -- Максимальное расстояние для отображения игроков
local UPDATE_INTERVAL = 0.2 -- Интервал обновления ESP (секунды)
local TOGGLE_KEY = Enum.KeyCode.RightControl -- Клавиша для включения/выключения ESP

-- Цвета для разных команд
local TEAM_COLORS = {
    Enemy = Color3.fromRGB(255, 0, 0), -- Красный для врагов
    Friendly = Color3.fromRGB(0, 255, 0), -- Зеленый для союзников
    Neutral = Color3.fromRGB(255, 255, 0) -- Желтый для нейтральных
}

-- Переменные
local player = Players.LocalPlayer
local camera = workspace.CurrentCamera
local espObjects = {} -- Таблица для хранения ESP объектов

-- Функция для создания ESP объекта
local function CreateEspObject(targetPlayer)
    -- Основной фрейм
    local espFrame = Drawing.new("Square")
    espFrame.Thickness = 2
    espFrame.Filled = false
    espFrame.Transparency = 1
    
    -- Текст с информацией
    local espText = Drawing.new("Text")
    espText.Size = 16
    espText.Center = true
    espText.Outline = true
    espText.OutlineColor = Color3.fromRGB(0, 0, 0)
    espText.Transparency = 1
    
    -- Добавляем в таблицу
    espObjects[targetPlayer] = {
        Box = espFrame,
        Text = espText,
        LastUpdate = tick()
    }
end

-- Функция для обновления ESP объекта
local function UpdateEspObject(targetPlayer, espInfo)
    if not ESP_ENABLED then
        espInfo.Box.Visible = false
        espInfo.Text.Visible = false
        return
    end
    
    local character = targetPlayer.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then
        espInfo.Box.Visible = false
        espInfo.Text.Visible = false
        return
    end
    
    -- Получаем положение персонажа
    local rootPart = character.HumanoidRootPart
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    
    -- Проверяем расстояние
    local distance = (rootPart.Position - camera.CFrame.Position).Magnitude
    if distance > MAX_DISTANCE then
        espInfo.Box.Visible = false
        espInfo.Text.Visible = false
        return
    end
    
    -- Определяем цвет в зависимости от команды
    local espColor = TEAM_COLORS.Neutral
    if player.TeamColor == targetPlayer.TeamColor then
        espColor = TEAM_COLORS.Friendly
    else
        espColor = TEAM_COLORS.Enemy
    end
    
    -- Обновляем последнее время проверки
    espInfo.LastUpdate = tick()
    
    -- Получаем размеры персонажа для обводки
    local hrpPos, onScreen = camera:WorldToViewportPoint(rootPart.Position)
    if not onScreen then
        espInfo.Box.Visible = false
        espInfo.Text.Visible = false
        return
    end
    
    -- Получаем высоту персонажа
    local headPos = camera:WorldToViewportPoint(character.Head.Position + Vector3.new(0, 0.5, 0))
    local legPos = camera:WorldToViewportPoint(rootPart.Position - Vector3.new(0, 3, 0))
    local height = math.abs(headPos.Y - legPos.Y)
    local width = height * 0.6
    
    -- Обновляем обводку
    espInfo.Box.Visible = true
    espInfo.Box.Size = Vector2.new(width, height)
    espInfo.Box.Position = Vector2.new(hrpPos.X - width/2, hrpPos.Y - height/2)
    espInfo.Box.Color = espColor
    
    -- Обновляем текст
    espInfo.Text.Visible = true
    espInfo.Text.Position = Vector2.new(hrpPos.X, hrpPos.Y - height/2 - 20)
    espInfo.Text.Color = espColor
    
    -- Формируем текст с информацией
    local healthPercent = 0
    if humanoid then 
        healthPercent = math.floor((humanoid.Health / humanoid.MaxHealth) * 100)
    end
    
    espInfo.Text.Text = string.format("%s\nЗдоровье: %d%%\n%0.1f м", 
        targetPlayer.Name, 
        healthPercent, 
        distance)
end

-- Функция очистки ESP объектов
local function ClearEspObjects()
    for player, espInfo in pairs(espObjects) do
        espInfo.Box:Remove()
        espInfo.Text:Remove()
    end
    espObjects = {}
end

-- Обработчик для обновления всех ESP объектов
RunService.RenderStepped:Connect(function()
    -- Проверяем существующие ESP объекты
    for targetPlayer, espInfo in pairs(espObjects) do
        if not Players:FindFirstChild(targetPlayer.Name) then
            -- Если игрок вышел, удаляем ESP объект
            espInfo.Box:Remove()
            espInfo.Text:Remove()
            espObjects[targetPlayer] = nil
        elseif tick() - espInfo.LastUpdate >= UPDATE_INTERVAL then
            -- Обновляем информацию с заданным интервалом
            UpdateEspObject(targetPlayer, espInfo)
        end
    end
    
    -- Проверяем новых игроков
    for _, targetPlayer in pairs(Players:GetPlayers()) do
        if targetPlayer ~= player and not espObjects[targetPlayer] then
            CreateEspObject(targetPlayer)
        end
    end
end)

-- Обработчик для переключения ESP
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == TOGGLE_KEY then
        ESP_ENABLED = not ESP_ENABLED
        print("ESP " .. (ESP_ENABLED and "включен" or "выключен"))
    end
end)

-- Обработчик выхода из игры
game:GetService("CoreGui").ChildRemoved:Connect(function(child)
    if child.Name == "RobloxGui" then
        ClearEspObjects() -- Очистка ресурсов при выходе
    end
end)

print("ESP скрипт загружен!")
print("Нажмите правый Control для включения/выключения ESP")
