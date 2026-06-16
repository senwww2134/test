-- =========================================================================
-- 1. ОСНОВНЫЕ ПЕРЕМЕННЫЕ И НАСТРОЙКИ
-- =========================================================================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer

-- Состояние функций (true = включено, false = выключено)
local SpeedHackEnabled = false
local InfiniteJumpEnabled = false

-- Хранилище для системных подключений (чтобы можно было их отключать)
local Connections = {}

-- =========================================================================
-- 2. СОЗДАНИЕ ГРАФИЧЕСКОГО ИНТЕРФЕЙСА (HUD)
-- =========================================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SolaraProHUD"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = game:GetService("CoreGui") -- Защита от удаления при смерти

-- Главная панель меню
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 300, 0, 250)
MainFrame.Position = UDim2.new(0.5, -150, 0.5, -125)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25) -- Темная тема
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui

-- Скругление углов меню
local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 10)
UICorner.Parent = MainFrame

-- Шапка меню (Верхняя полоса для перетаскивания)
local TopBar = Instance.new("Frame")
TopBar.Name = "TopBar"
TopBar.Size = UDim2.new(1, 0, 0, 40)
TopBar.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
TopBar.BorderSizePixel = 0
TopBar.Parent = MainFrame

local TopBarCorner = Instance.new("UICorner")
TopBarCorner.CornerRadius = UDim.new(0, 10)
TopBarCorner.Parent = TopBar

-- Заголовок меню
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -20, 1, 0)
Title.Position = UDim2.new(0, 10, 0, 0)
Title.Text = "MY CUSTOM CHEAT v1.0"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 18
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.BackgroundTransparency = 1
Title.Parent = TopBar

-- Подсказка внизу меню
local Footer = Instance.new("TextLabel")
Footer.Size = UDim2.new(1, 0, 0, 20)
Footer.Position = UDim2.new(0, 0, 1, -25)
Footer.Text = "[Insert] Скрыть / Показать меню"
Footer.TextColor3 = Color3.fromRGB(150, 150, 150)
Footer.Font = Enum.Font.SourceSans
Footer.TextSize = 14
Footer.BackgroundTransparency = 1
Footer.Parent = MainFrame

-- =========================================================================
-- КНОПКА 1: АНДЕТЕКТ СКОРОСТЬ (С переключателем ВКЛ/ВЫКЛ)
-- =========================================================================
local SpeedButton = Instance.new("TextButton")
SpeedButton.Size = UDim2.new(0, 260, 0, 40)
SpeedButton.Position = UDim2.new(0, 20, 0, 60)
SpeedButton.Text = "Undetected Speed: ВЫКЛ"
SpeedButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
SpeedButton.TextColor3 = Color3.fromRGB(255, 255, 255)
SpeedButton.Font = Enum.Font.SourceSansBold
SpeedButton.TextSize = 16
SpeedButton.Parent = MainFrame

local SpeedCorner = Instance.new("UICorner")
SpeedCorner.CornerRadius = UDim.new(0, 6)
SpeedCorner.Parent = SpeedButton

-- =========================================================================
-- КНОПКА 2: БЕСКОНЕЧНЫЙ ПРЫЖОК (С переключателем ВКЛ/ВЫКЛ)
-- =========================================================================
local JumpButton = Instance.new("TextButton")
JumpButton.Size = UDim2.new(0, 260, 0, 40)
JumpButton.Position = UDim2.new(0, 20, 0, 115)
JumpButton.Text = "Infinite Jump: ВЫКЛ"
JumpButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
JumpButton.TextColor3 = Color3.fromRGB(255, 255, 255)
JumpButton.Font = Enum.Font.SourceSansBold
JumpButton.TextSize = 16
JumpButton.Parent = MainFrame

local JumpCorner = Instance.new("UICorner")
JumpCorner.CornerRadius = UDim.new(0, 6)
JumpCorner.Parent = JumpButton

-- =========================================================================
-- 3. ЛОГИКА ФУНКЦИЙ (ВКЛЮЧЕНИЕ И СБРОС КАК БЫЛО)
-- =========================================================================

-- Логика для скорости (CFrame Bypass)
local function ToggleSpeed()
    SpeedHackEnabled = not SpeedHackEnabled
    
    if SpeedHackEnabled then
        SpeedButton.Text = "Undetected Speed: ВКЛ"
        SpeedButton.BackgroundColor3 = Color3.fromRGB(0, 170, 100) -- Зеленый цвет
        
        -- Запускаем цикл обхода античета
        local speed = 2.5
        Connections.SpeedLoop = RunService.RenderStepped:Connect(function()
            local char = LocalPlayer.Character
            if char and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChild("Humanoid") then
                if char.Humanoid.MoveDirection.Magnitude > 0 then
                    char.HumanoidRootPart.CFrame = char.HumanoidRootPart.CFrame + (char.Humanoid.MoveDirection * speed)
                end
            end
        end)
    else
        SpeedButton.Text = "Undetected Speed: ВЫКЛ"
        SpeedButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50) -- Серый цвет
        
        -- ПОЛНЫЙ СБРОС: Отключаем цикл, скорость возвращается в норму
        if Connections.SpeedLoop then
            Connections.SpeedLoop:Disconnect()
            Connections.SpeedLoop = nil
        end
    end
end

-- Логика для бесконечного прыжка
local function ToggleJump()
    InfiniteJumpEnabled = not InfiniteJumpEnabled
    
    if InfiniteJumpEnabled then
        JumpButton.Text = "Infinite Jump: ВКЛ"
        JumpButton.BackgroundColor3 = Color3.fromRGB(0, 170, 100)
        
        -- Запускаем отслеживание нажатия пробела
        Connections.JumpLoop = UIS.JumpRequest:Connect(function()
            local char = LocalPlayer.Character
            if char and char:FindFirstChild("Humanoid") then
                char.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end)
    else
        JumpButton.Text = "Infinite Jump: ВЫКЛ"
        JumpButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        
        -- ПОЛНЫЙ СБРОС: Игра снова прыгает как обычно
        if Connections.JumpLoop then
            Connections.JumpLoop:Disconnect()
            Connections.JumpLoop = nil
        end
    end
end

-- Активация кнопок при клике
SpeedButton.MouseButton1Click:Connect(ToggleSpeed)
JumpButton.MouseButton1Click:Connect(ToggleJump)

-- =========================================================================
-- 4. СИСТЕМНЫЕ ФУНКЦИИ HUD (СКРЫТИЕ И ПЕРЕТАСКИВАНИЕ)
-- =========================================================================

-- Скрытие меню на клавишу Insert
UIS.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.Insert then
        MainFrame.Visible = not MainFrame.Visible
    end
end)

-- Скрипт плавного перетаскивания меню мышкой (Drag-and-Drop)
local dragging, dragInput, dragStart, startPos
local function update(input)
    local delta = input.Position - dragStart
    MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end

TopBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

TopBar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UIS.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        update(input)
    end
end)
