--[[
    Universal Script Loader
    by zxwhgdsushgs
    GitHub: riti1556
    
    Универсальный загрузчик скриптов через loadstring
    Позволяет загружать скрипты прямо с GitHub
]]

-- URL адреса скриптов (измените на ваши после загрузки на GitHub)
local scripts = {
    ["BladeballAutoParry"] = "https://raw.githubusercontent.com/riti1556/RobloxScripts/main/BladeballAutoParry.lua",
    ["AutoJump"] = "https://raw.githubusercontent.com/riti1556/RobloxScripts/main/AutoJump.lua",
    ["WalkSpeed"] = "https://raw.githubusercontent.com/riti1556/RobloxScripts/main/WalkSpeed.lua",
    ["ESP"] = "https://raw.githubusercontent.com/riti1556/RobloxScripts/main/ESP.lua"
}

-- Сервисы Roblox
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")

-- Создание простого интерфейса для выбора скриптов
local function CreateGui()
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "ScriptLoader"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
    
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, 300, 0, 350)
    MainFrame.Position = UDim2.new(0.5, -150, 0.5, -175)
    MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    MainFrame.BorderSizePixel = 0
    MainFrame.Active = true
    MainFrame.Draggable = true
    MainFrame.Parent = ScreenGui
    
    -- Заголовок
    local TitleBar = Instance.new("Frame")
    TitleBar.Name = "TitleBar"
    TitleBar.Size = UDim2.new(1, 0, 0, 40)
    TitleBar.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    TitleBar.BorderSizePixel = 0
    TitleBar.Parent = MainFrame
    
    local Title = Instance.new("TextLabel")
    Title.Name = "Title"
    Title.Size = UDim2.new(1, -40, 1, 0)
    Title.Position = UDim2.new(0, 10, 0, 0)
    Title.BackgroundTransparency = 1
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextSize = 18
    Title.Font = Enum.Font.SourceSansBold
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Text = "Roblox Script Loader"
    Title.Parent = TitleBar
    
    -- Кнопка закрытия
    local CloseButton = Instance.new("TextButton")
    CloseButton.Name = "CloseButton"
    CloseButton.Size = UDim2.new(0, 40, 0, 40)
    CloseButton.Position = UDim2.new(1, -40, 0, 0)
    CloseButton.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
    CloseButton.BorderSizePixel = 0
    CloseButton.Text = "X"
    CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    CloseButton.TextSize = 18
    CloseButton.Font = Enum.Font.SourceSansBold
    CloseButton.Parent = TitleBar
    
    CloseButton.MouseButton1Click:Connect(function()
        ScreenGui:Destroy()
    end)
    
    -- Контейнер для кнопок скриптов
    local ScrollFrame = Instance.new("ScrollingFrame")
    ScrollFrame.Name = "ScriptsList"
    ScrollFrame.Size = UDim2.new(1, -20, 1, -100)
    ScrollFrame.Position = UDim2.new(0, 10, 0, 50)
    ScrollFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    ScrollFrame.BorderSizePixel = 0
    ScrollFrame.ScrollBarThickness = 8
    ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, (#scripts * 60) + 10)
    ScrollFrame.Parent = MainFrame
    
    -- Создаем кнопки для каждого скрипта
    local yOffset = 10
    for name, _ in pairs(scripts) do
        local Button = Instance.new("TextButton")
        Button.Name = name .. "Button"
        Button.Size = UDim2.new(1, -20, 0, 50)
        Button.Position = UDim2.new(0, 10, 0, yOffset)
        Button.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        Button.BorderSizePixel = 0
        Button.Text = name
        Button.TextColor3 = Color3.fromRGB(255, 255, 255)
        Button.TextSize = 16
        Button.Font = Enum.Font.SourceSans
        Button.Parent = ScrollFrame
        
        -- Обработчик нажатия
        Button.MouseButton1Click:Connect(function()
            LoadScript(name)
        end)
        
        yOffset = yOffset + 60
    end
    
    -- Добавляем статус
    local StatusLabel = Instance.new("TextLabel")
    StatusLabel.Name = "StatusLabel"
    StatusLabel.Size = UDim2.new(1, -20, 0, 40)
    StatusLabel.Position = UDim2.new(0, 10, 1, -50)
    StatusLabel.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    StatusLabel.BorderSizePixel = 0
    StatusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    StatusLabel.TextSize = 14
    StatusLabel.Font = Enum.Font.SourceSans
    StatusLabel.Text = "Готов к загрузке скриптов"
    StatusLabel.Parent = MainFrame
    
    return ScreenGui, StatusLabel
end

-- Функция для загрузки скрипта
local function LoadScript(scriptName)
    local gui = Players.LocalPlayer.PlayerGui:FindFirstChild("ScriptLoader")
    local statusLabel = gui and gui.MainFrame:FindFirstChild("StatusLabel")
    
    if statusLabel then
        statusLabel.Text = "Загрузка скрипта: " .. scriptName .. "..."
    end
    
    local url = scripts[scriptName]
    if not url then
        if statusLabel then
            statusLabel.Text = "Ошибка: Скрипт не найден!"
        end
        return
    end
    
    -- Пытаемся загрузить скрипт
    local success, response = pcall(function()
        return game:HttpGet(url)
    end)
    
    if not success then
        if statusLabel then
            statusLabel.Text = "Ошибка загрузки: Проверьте соединение!"
        end
        return
    end
    
    -- Выполняем скрипт
    local scriptFunc, loadError = loadstring(response)
    if not scriptFunc then
        if statusLabel then
            statusLabel.Text = "Ошибка компиляции: " .. tostring(loadError)
        end
        return
    end
    
    local executeSuccess, executeError = pcall(scriptFunc)
    if not executeSuccess then
        if statusLabel then
            statusLabel.Text = "Ошибка выполнения: " .. tostring(executeError)
        end
        return
    end
    
    if statusLabel then
        statusLabel.Text = "Скрипт " .. scriptName .. " успешно загружен!"
    end
end

-- Создаем графический интерфейс
local gui, statusLabel = CreateGui()

print("Script Loader загружен! Выберите скрипт для запуска.")
