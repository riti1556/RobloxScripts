--[[
    Увеличение скорости персонажа для Roblox
    by zxwhgdsushgs
    GitHub: riti1556
    
    Скрипт позволяет изменять скорость ходьбы и прыжка персонажа
    с помощью горячих клавиш
]]

-- Сервисы Roblox
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

-- Настройки скрипта
local DEFAULT_WALK_SPEED = 16 -- Стандартная скорость ходьбы
local DEFAULT_JUMP_POWER = 50 -- Стандартная сила прыжка
local SPEED_INCREMENT = 5 -- Шаг изменения скорости
local JUMP_INCREMENT = 10 -- Шаг изменения силы прыжка

-- Клавиши управления
local SPEED_UP_KEY = Enum.KeyCode.RightBracket -- ']' - Увеличить скорость
local SPEED_DOWN_KEY = Enum.KeyCode.LeftBracket -- '[' - Уменьшить скорость
local JUMP_UP_KEY = Enum.KeyCode.Equals -- '=' - Увеличить силу прыжка
local JUMP_DOWN_KEY = Enum.KeyCode.Minus -- '-' - Уменьшить силу прыжка
local RESET_KEY = Enum.KeyCode.BackSlash -- '\' - Сбросить значения

-- Получаем персонажа игрока
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")

-- Текущие значения
local currentWalkSpeed = DEFAULT_WALK_SPEED
local currentJumpPower = DEFAULT_JUMP_POWER

-- Обновление скорости и силы прыжка
local function UpdateMovementValues()
    if not character or not humanoid then return end
    
    -- Применяем значения
    humanoid.WalkSpeed = currentWalkSpeed
    humanoid.JumpPower = currentJumpPower
    
    -- Выводим информацию
    print(string.format("Скорость ходьбы: %.1f | Сила прыжка: %.1f", currentWalkSpeed, currentJumpPower))
end

-- Обработчик клавиш
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end -- Игнорируем, если ввод обработан игрой
    
    if input.KeyCode == SPEED_UP_KEY then
        -- Увеличиваем скорость
        currentWalkSpeed = currentWalkSpeed + SPEED_INCREMENT
        UpdateMovementValues()
    elseif input.KeyCode == SPEED_DOWN_KEY then
        -- Уменьшаем скорость (но не меньше 1)
        currentWalkSpeed = math.max(1, currentWalkSpeed - SPEED_INCREMENT)
        UpdateMovementValues()
    elseif input.KeyCode == JUMP_UP_KEY then
        -- Увеличиваем силу прыжка
        currentJumpPower = currentJumpPower + JUMP_INCREMENT
        UpdateMovementValues()
    elseif input.KeyCode == JUMP_DOWN_KEY then
        -- Уменьшаем силу прыжка (но не меньше 1)
        currentJumpPower = math.max(1, currentJumpPower - JUMP_INCREMENT)
        UpdateMovementValues()
    elseif input.KeyCode == RESET_KEY then
        -- Сбрасываем значения к стандартным
        currentWalkSpeed = DEFAULT_WALK_SPEED
        currentJumpPower = DEFAULT_JUMP_POWER
        UpdateMovementValues()
    end
end)

-- Проверка и обновление значений каждый кадр
RunService.Heartbeat:Connect(function()
    -- Проверяем наличие персонажа
    character = player.Character
    if not character then return end
    
    humanoid = character:FindFirstChild("Humanoid")
    if not humanoid then return end
    
    -- Если значения были изменены извне, применяем наши
    if humanoid.WalkSpeed ~= currentWalkSpeed or humanoid.JumpPower ~= currentJumpPower then
        UpdateMovementValues()
    end
end)

-- Обработчик смены персонажа
player.CharacterAdded:Connect(function(newCharacter)
    character = newCharacter
    humanoid = newCharacter:WaitForChild("Humanoid")
    
    -- Обновляем значения для нового персонажа
    UpdateMovementValues()
    print("Персонаж загружен. Значения скорости обновлены.")
end)

-- Инициализация
UpdateMovementValues()
print([[
Управление скоростью персонажа:
[+] и [-] - изменение скорости ходьбы
[=] и [-] - изменение силы прыжка
[\] - сброс значений к стандартным
]])
