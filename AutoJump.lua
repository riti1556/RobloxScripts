--[[
    Автоматический прыжок для Roblox
    by zxwhgdsushgs
    GitHub: riti1556
    
    Простой скрипт для автоматического прыжка персонажа, 
    позволяет обходить некоторые препятствия и ловушки
]]

-- Получаем необходимые сервисы
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

-- Настройки скрипта
local AUTO_JUMP_ENABLED = true -- Включен ли автопрыжок по умолчанию
local CHECK_INTERVAL = 0.1 -- Интервал проверки возможности прыжка
local TOGGLE_KEY = Enum.KeyCode.J -- Клавиша для включения/выключения автопрыжка

-- Переменные состояния
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local lastJumpTime = 0
local jumpCooldown = 0.3 -- Задержка между прыжками

-- Функция прыжка
local function Jump()
    if tick() - lastJumpTime < jumpCooldown then
        return -- Предотвращает слишком частые прыжки
    end
    
    -- Проверяем, стоит ли персонаж на земле
    if humanoid and humanoid:GetState() ~= Enum.HumanoidStateType.Jumping and humanoid:GetState() ~= Enum.HumanoidStateType.Freefall then
        humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        lastJumpTime = tick()
        print("Прыжок выполнен")
    end
end

-- Функция проверки препятствий впереди
local function CheckObstacleAhead()
    if not character or not humanoid then return false end
    
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return false end
    
    -- Направление движения персонажа
    local lookVector = rootPart.CFrame.LookVector
    
    -- Запускаем луч перед персонажем для проверки препятствий
    local rayOrigin = rootPart.Position
    local rayDirection = lookVector * 2 -- Проверяем на расстоянии 2 единицы вперед
    
    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
    raycastParams.FilterDescendantsInstances = {character}
    
    local raycastResult = workspace:Raycast(rayOrigin, rayDirection, raycastParams)
    
    if raycastResult then
        -- Проверяем высоту препятствия, если оно не слишком высокое
        local obstacleHeight = raycastResult.Instance.Size.Y
        if obstacleHeight < 4 then -- Прыгаем только через невысокие препятствия
            return true
        end
    end
    
    return false
end

-- Обработчик переключения автопрыжка
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == TOGGLE_KEY then
        AUTO_JUMP_ENABLED = not AUTO_JUMP_ENABLED
        print("Автопрыжок " .. (AUTO_JUMP_ENABLED and "включен" or "выключен"))
    end
end)

-- Основной цикл автопрыжка
RunService.Heartbeat:Connect(function()
    if not AUTO_JUMP_ENABLED then return end
    
    -- Обновляем ссылки на персонажа и хуманоида, если что-то изменилось
    character = player.Character
    if not character then return end
    
    humanoid = character:FindFirstChild("Humanoid")
    if not humanoid then return end
    
    -- Проверяем наличие препятствий впереди и выполняем прыжок
    if humanoid.MoveDirection.Magnitude > 0 and CheckObstacleAhead() then
        Jump()
    end
end)

-- Обработчик смены персонажа
player.CharacterAdded:Connect(function(newCharacter)
    character = newCharacter
    humanoid = newCharacter:WaitForChild("Humanoid")
    print("Персонаж загружен. Автопрыжок " .. (AUTO_JUMP_ENABLED and "включен" or "выключен"))
end)

print("Скрипт автоматического прыжка загружен!")
print("Нажмите клавишу J для включения/выключения")
