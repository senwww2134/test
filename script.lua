local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

local TP_Settings = {
    Active = true
}

-- Стабильный HUD через Drawing API
local function createTextLine(text, yOffset, color)
    if not Drawing then return nil end
    local textObject = Drawing.new("Text")
    textObject.Text = text
    textObject.Size = 18
    textObject.Position = Vector2.new(40, 160 + yOffset)
    textObject.Color = color or Color3.fromRGB(255, 255, 255)
    textObject.Outline = true
    textObject.Visible = true
    return textObject
end

local UI_Elements = {}
UI_Elements.Title = createTextLine("== HARD BYPASS CLICK TP ==", 0, Color3.fromRGB(0, 255, 255))
UI_Elements.Status = createTextLine("Метод: Физический импульс (Velocity)", 25, Color3.fromRGB(255, 255, 0))
UI_Elements.Instruction = createTextLine("Управление: [Ctrl + Клик Мыши] по карте", 50, Color3.fromRGB(240, 240, 240))
UI_Elements.UnloadText = createTextLine("Нажми [X] для выгрузки чита", 75, Color3.fromRGB(255, 0, 50))

-- Основная функция физического телепорта
local function VelocityTeleport(targetPos)
    local Character = LocalPlayer.Character
    local HRP = Character and Character:FindFirstChild("HumanoidRootPart")
    local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")
    
    if not HRP or not Humanoid or Humanoid.Health <= 0 then return end
    
    -- Корректируем точку назначения, чтобы не влететь в текстуры земли
    local startPos = HRP.Position
    local finalPos = targetPos + Vector3.new(0, 3, 0)
    
    -- Шаг 1: Обман системы проверок штатных состояний
    -- Смена состояния на 'FallingDown' имитирует падение или спотыкание
    Humanoid:ChangeState(Enum.HumanoidStateType.FallingDown)
    
    -- Шаг 2: Прикладываем физическую скорость (Импульс)
    -- Мы рассчитываем точный вектор направления и мгновенно «выстреливаем» персонажем в точку
    local direction = (finalPos - startPos)
    HRP.Velocity = direction * 15 -- Сервер регистрирует физическое ускорение (как от взрыва)
    
    -- Шаг 3: Микро-сдвиг CFrame вдогонку импульсу
    task.wait(0.02)
    if TP_Settings.Active then
        HRP.CFrame = CFrame.new(finalPos, finalPos + HRP.CFrame.LookVector)
    end
    
    -- Шаг 4: Гасим остаточную инерцию, чтобы персонаж не улетел дальше нужного
    HRP.Velocity = Vector3.new(0, 0, 0)
    Humanoid:ChangeState(Enum.HumanoidStateType.Running)
end

-- Обработка событий мыши и клавиатуры
local InputConnection
InputConnection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    -- Фиксация комбинации Ctrl + ЛКМ
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) or UserInputService:IsKeyDown(Enum.KeyCode.RightControl) then
            if Mouse.Hit then
                task.spawn(VelocityTeleport, Mouse.Hit.Position)
            end
        end
    end
    
    -- Выгрузка чита (Клавиша X)
    if input.KeyCode == Enum.KeyCode.X then
        TP_Settings.Active = false
        if InputConnection then InputConnection:Disconnect() end
        
        -- Стираем HUD с экрана
        for _, element in pairs(UI_Elements) do
            if element then element:Destroy() end
        end
        print("[Чит полностью выгружен]")
    end
end)
