--[[
    Рабочий скрипт для автопарирования и закручивания мяча
]]

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
local parryDistance = 30 -- Расстояние для парирования
local parryButtonPressed = false
local scriptEnabled = true
local parryCount = 0

-- Функция для закручивания мяча
function spinBall(ball)
    -- Закручиваем мяч, добавляем вращение
    local bodyGyro = ball:FindFirstChild("BodyGyro") or Instance.new("BodyGyro")
    bodyGyro.MaxTorque = Vector3.new(10000, 10000, 10000)  -- Максимальные значения для вращения
    bodyGyro.CFrame = CFrame.Angles(math.rad(90), 0, 0) -- Угол наклона мяча
    bodyGyro.Parent = ball
end

-- Функция для парирования
function parryBall()
    if not scriptEnabled or parryButtonPressed then return end

    parryButtonPressed = true

    -- Пример с виртуальным нажатием кнопки для парирования
    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.F, false, game)
    wait(0.1)
    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.F, false, game)

    -- Обновление статистики
    parryCount = parryCount + 1
    print("Парировано: " .. parryCount)

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
                -- Закручиваем мяч
                spinBall(nearestBall)  
                break
            end
        end
    end

    -- Если мяч найден и достаточно близко, выполняем парирование
    if nearestBall then
        parryBall()
    end
end)

print("Автопарирование и закручивание мяча успешно настроены!")
