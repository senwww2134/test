-- Извлекаем чистые функции из оригинального окружения Roblox
local env = getfenv and getfenv() or _G
local udim2_new = env.UDim2 and env.UDim2.new or (game:GetService("CoreGui") and _G.UDim2 or UDim2).new
local color_from_rgb = env.Color3 and env.Color3.fromRGB or Color3.fromRGB
local udim_new = env.UDim and env.UDim.new or UDim.new

-- Проверяем, удалось ли восстановить базовый конструктор
if not udim2_new then
    error("Критическая ошибка инжектора: Среда выполнения полностью заблокировала доступ к UDim2.")
end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer

local CheatSettings = {
    Noclip = false,
    TP_Distance = 15
}

-- Инициализация графической оболочки
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ProtectedCheatHUD"
ScreenGui.ResetOnSpawn = false
if syn and syn.protect_gui then syn.protect_gui(ScreenGui) end 
ScreenGui.Parent = CoreGui

-- Главное окно меню
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = udim2_new(0, 200, 0, 250)
MainFrame.Position = udim2_new(0.05, 0, 0.4, 0)
MainFrame.BackgroundColor3 = color_from_rgb(30, 30, 30)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

-- Заголовок меню
local Title = Instance.new("TextLabel")
Title.Size = udim2_new(1, 0, 0, 40)
Title.BackgroundColor3 = color_from_rgb(45, 45, 45)
Title.Text = "MENU"
Title.TextColor3 = color_from_rgb(255, 255, 255)
Title.TextSize = 18
Title.Font = Enum.Font.SourceSansBold
Title.Parent = MainFrame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Parent = MainFrame
UIListLayout.Padding = udim_new(0, 10)
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder

local ContentOffset = Instance.new("Frame")
ContentOffset.Size = udim2_new(1, 0, 0, 40)
ContentOffset.BackgroundTransparency = 1
ContentOffset.LayoutOrder = 0
ContentOffset.Parent = MainFrame

-- Конструктор для кнопок управления
local function createButton(text, layoutOrder, callback)
    local Button = Instance.new("TextButton")
    Button.Size = udim2_new(0.9, 0, 0, 35)
    Button.Position = udim2_new(0.05, 0, 0, 0)
    Button.BackgroundColor3 = color_from_rgb(60, 60, 60)
    Button.Text = text
    Button.TextColor3 = color_from_rgb(255, 255, 255)
    Button.Font = Enum.Font.SourceSans
    Button.TextSize = 16
    Button.LayoutOrder = layoutOrder
    Button.Parent = MainFrame
    Button.MouseButton1Click:Connect(callback)
    return Button
end

-- Модуль 1: Обычный телепорт вперед по вектору взгляда
createButton("Телепорт Вперед", 1, function()
    local Character = LocalPlayer.Character
    if Character and Character:FindFirstChild("HumanoidRootPart") then
        local HRP = Character.HumanoidRootPart
        HRP.CFrame = HRP.CFrame + (HRP.CFrame.LookVector * CheatSettings.TP_Distance)
    end
end)

-- Модуль 2: Переключатель режима прохождения сквозь текстуры
local NoclipBtn = createButton("Сквозь стены: ВЫКЛ", 2, function()
    CheatSettings.Noclip = not CheatSettings.Noclip
end)

local NoclipConnection
NoclipConnection = RunService.Stepped:Connect(function()
    if CheatSettings.Noclip then
        NoclipBtn.Text = "Сквозь стены: ВКЛ"
        NoclipBtn.BackgroundColor3 = color_from_rgb(46, 139, 87)
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
        NoclipBtn.BackgroundColor3 = color_from_rgb(60, 60, 60)
    end
end)

-- Модуль 3: Полная очистка памяти и удаление HUD
createButton("Выгрузить чит", 3, function()
    if NoclipConnection then NoclipConnection:Disconnect() end
    local Character = LocalPlayer.Character
    if Character then
        for _, part in pairs(Character:GetChildren()) do
            if part:IsA("BasePart") then part.CanCollide = true end
        end
    end
    ScreenGui:Destroy()
end)
