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
local TeleportEnabled = false

-- Хранилище для системных подключений (чтобы можно было их отключать)
local Connections = {}

-- =========================================================================
-- 2. СОЗДАНИЕ ГРАФИЧЕСКОГО ИНТЕРФЕЙСА (HUD)
-- =========================================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SolaraProHUD"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = game:GetService("CoreGui") -- Защита от удаления при смерти

-- Главная панель меню (Увеличили высоту до 360, чтобы влезла кнопка Destroy)
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 300, 0, 360)
MainFrame.Position = UDim2.new(0.5, -150, 0.5, -180)
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
Title.Text = "MY CUSTOM CHEAT v1.2"
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
-- КНОПКИ ФУНКЦИЙ
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

local TeleportButton = Instance.new("TextButton")
TeleportButton.Size = UDim2.new(0, 260, 0, 40)
TeleportButton.Position = UDim2.new(0, 20, 0, 170)
TeleportButton.Text = "Teleport Click (Ctrl + ЛКМ): ВЫКЛ"
TeleportButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
TeleportButton.TextColor3 = Color3.fromRGB(255, 255, 255)
TeleportButton.Font = Enum.Font.SourceSansBold
TeleportButton.TextSize = 14
TeleportButton.Parent = MainFrame

local TeleportCorner = Instance.new("UICorner")
TeleportCorner.CornerRadius = UDim.new(0, 6)
TeleportCorner.Parent = TeleportButton

-- =========================================================================
-- КНОПКА ВЫГРУЗКИ СКРИПТА (Новая)
-- =========================================================================
local DestroyButton = Instance.new("TextButton")
DestroyButton.Size = UDim2.new(0, 260, 0, 40)
DestroyButton.Position = UDim2.new(0, 20, 0, 240) -- Разместили ниже остальных кнопок
DestroyButton.Text = "DESTROY SCRIPT (UNLOAD)"
DestroyButton.BackgroundColor3 = Color3.fromRGB(180, 40, 40) -- Красный цвет
DestroyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
DestroyButton.Font = Enum.Font.SourceSansBold
DestroyButton.TextSize = 15
DestroyButton.Parent = MainFrame

local DestroyCorner = Instance.new("UICorner")
DestroyCorner.CornerRadius = UDim.new(0, 6)
DestroyCorner.Parent = DestroyButton

-- =========================================================================
-- 3. ЛОГИКА ФУНКЦИЙ (ВКЛЮЧЕНИЕ И СБРОС КАК БЫЛО)
-- =========================================================================

local function ToggleSpeed()
    SpeedHackEnabled = not SpeedHackEnabled
    if SpeedHackEnabled then
        SpeedButton.Text = "Undetected Speed: ВКЛ"
        SpeedButton.BackgroundColor3 = Color3.fromRGB(0, 170, 100)
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
        SpeedButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        if Connections.SpeedLoop then
            Connections.SpeedLoop:Disconnect()
            Connections.SpeedLoop = nil
        end
    end
end

local function ToggleJump()
    InfiniteJumpEnabled = not InfiniteJumpEnabled
    if InfiniteJumpEnabled then
        JumpButton.Text = "Infinite Jump: ВКЛ"
        JumpButton.BackgroundColor3 = Color3.fromRGB(0, 170, 100)
        Connections.JumpLoop = UIS.JumpRequest:Connect(function()
            local char = LocalPlayer.Character
            if char and char:FindFirstChild("Humanoid") then
                char.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end)
    else
        JumpButton.Text = "Infinite Jump: ВЫКЛ"
        JumpButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        if Connections.JumpLoop then
            Connections.JumpLoop:Disconnect()
            Connections.JumpLoop = nil
        end
    end
end

local function ToggleTeleport()
    TeleportEnabled = not TeleportEnabled
    if TeleportEnabled then
        TeleportButton.Text = "Teleport Click (Ctrl + ЛКМ): ВКЛ"
        TeleportButton.BackgroundColor3 = Color3.fromRGB(0, 170, 100)
        
        local mouse = LocalPlayer:GetMouse()
        Connections.TPClick = mouse.Button1Down:Connect(function()
            if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then
                local char = LocalPlayer.Character
                if char and char:FindFirstChild("HumanoidRootPart") and mouse.Target then
                    local targetPos = mouse.Hit.p + Vector3.new(0, 3, 0)
                    for _, part in pairs(char:GetChildren()) do
                        if part:IsA("BasePart") then
                            part.CanCollide = false
                        end
                    end
                    char.HumanoidRootPart.CFrame = CFrame.new(targetPos)
                    task.wait(0.1)
                    for _, part in pairs(char:GetChildren()) do
                        if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                            part.CanCollide = true
                        end
                    end
                end
            end
        end)
    else
        TeleportButton.Text = "Teleport Click (Ctrl + ЛКМ): ВЫКЛ"
        TeleportButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        if Connections.TPClick then
            Connections.TPClick:Disconnect()
            Connections.TPClick = nil
        end
    end
end

-- ФУНКЦИЯ ПОЛНОЙ ВЫГРУЗКИ ЧИТА
local function UnloadScript()
    -- 1. Принудительно выключаем все активные функции, чтобы сбросить настройки персонажа
    if SpeedHackEnabled then ToggleSpeed() end
    if InfiniteJumpEnabled then ToggleJump() end
    if TeleportEnabled then ToggleTeleport() end
    
    -- 2. Отключаем все системные прослушиватели событий (клавиша Insert и перетаскивание)
    for name, connection in pairs(Connections) do
        if connection then
            connection:Disconnect()
        end
    end
    table.clear(Connections)
    
    -- 3. Полностью удаляем графическое меню из игры
    ScreenGui:Destroy()
    print("Чит успешно выгружен и удален из памяти игры!")
end

-- Активация кнопок
SpeedButton.MouseButton1Click:Connect(ToggleSpeed)
JumpButton.MouseButton1Click:Connect(ToggleJump)
TeleportButton.MouseButton1Click:Connect(ToggleTeleport)
DestroyButton.MouseButton1Click:Connect(UnloadScript)

-- =========================================================================
-- 4. СИСТЕМНЫЕ ФУНКЦИИ HUD (СКРЫТИЕ И ПЕРЕТАСКИВАНИЕ)
-- =========================================================================

-- Сохраняем подключение для скрытия меню на Insert, чтобы потом его тоже удалить
