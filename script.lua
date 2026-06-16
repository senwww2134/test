-- Инициализация сервисов
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer

-- Настройки чита
local CheatSettings = {
    Noclip = false,
    TP_Distance = 15
}

-- Создание интерфейса (HUD)
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SimpleCheatHUD"
ScreenGui.ResetOnSpawn = false
-- Защита интерфейса от обнаружения обычными методами
if syn and syn.protect_gui then syn.protect_gui(ScreenGui) end 
ScreenGui.Parent = CoreGui

-- Главное окно
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 200, 0, 250) -- Ошибка исправлена здесь
MainFrame.Position = UDim2.new(0.05, 0, 0.4, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true -- Можно двигать мышкой
MainFrame.Parent = ScreenGui

-- Заголовок
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
Title.Text = "MENU"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 18
Title.Font = Enum.Font.SourceSansBold
Title.Parent = MainFrame

-- Список для удобного расположения кнопок
local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Parent = MainFrame
UIListLayout.Padding = UDim.new(0, 10)
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder

-- Сдвигаем список ниже заголовка
local ContentOffset = Instance.new("Frame")
ContentOffset.Size = UDim2.new(1, 0, 0, 40)
ContentOffset.BackgroundTransparency = 1
ContentOffset.LayoutOrder = 0
ContentOffset.Parent = MainFrame

-- Функция создания кнопок/переключателей
local function createButton(text, layoutOrder, callback)
    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(0.9, 0, 0, 35)
    Button.Position = UDim2.new(0.05, 0, 0, 0)
    Button.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    Button.Text = text
    Button.TextColor3 = Color3.fromRGB(255, 255, 255)
    Button.Font = Enum.Font.SourceSans
    Button.TextSize = 16
    Button.LayoutOrder = layoutOrder
    Button.Parent = MainFrame
    
    Button.MouseButton1Click:Connect(callback)
    return Button
end

-- 1. Кнопка обычного телепорта вперед
createButton("Телепорт Вперед", 1, function()
    local Character = LocalPlayer.Character
    if Character and Character:FindFirstChild("HumanoidRootPart") then
        local HRP = Character.HumanoidRootPart
        -- Перемещаем персонажа вперед по направлению взгляда камеры
        HRP.CFrame = HRP.CFrame + (HRP.CFrame.LookVector * CheatSettings.TP_Distance)
    end
end)

-- 2. Переключатель хождения сквозь стены (Noclip)
local NoclipBtn = createButton("Сквозь стены: ВЫКЛ", 2, function()
    CheatSettings.Noclip = not CheatSettings.Noclip
end)

-- Логика работы Noclip (каждый кадр отключаем коллизию)
local NoclipConnection
NoclipConnection = RunService.Stepped:Connect(function()
    if CheatSettings.Noclip then
        NoclipBtn.Text = "Сквозь стены: ВКЛ"
        NoclipBtn.BackgroundColor3 = Color3.fromRGB(46, 139, 87) -- Зеленый
        
        local Character = LocalPlayer.Character
        if Character then
            for _, part in pairs(Character:GetChildren()) do
                if part:IsA("BasePart") and part.CanCollide == true then
                    part.CanCollide = false
                end
            end
        end
    else
        NoclipBtn.Text = "Сквозь стены: ВЫКЛ"
        NoclipBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60) -- Серый
    end
end)

-- 3. Кнопка полной выгрузки (Unload)
createButton("Выгрузить чит", 3, function()
    -- Отключаем постоянные циклы проверки
    if NoclipConnection then
        NoclipConnection:Disconnect()
    end
    
    -- Включаем коллизию персонажу обратно, если она была отключена
    local Character = LocalPlayer.Character
    if Character then
        for _, part in pairs(Character:GetChildren()) do
            if part:IsA("BasePart") then
                part.CanCollide = true
            end
        end
    end
    
    -- Полностью удаляем интерфейс из игры
    ScreenGui:Destroy()
end)
