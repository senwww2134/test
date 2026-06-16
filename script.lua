-- Сервисы игры
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- Настройки обхода античета
local TP_Settings = {
    Active = true,
    MaxStepDistance = 4.5, -- Длина одного микро-шага в студах (безопасно: от 3 до 5)
    StepDelay = 0.015      -- Задержка между шагами в секундах (микро-пауза для обмана античета)
}

-- Создание стабильного HUD с помощью Drawing API
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
UI_Elements.Title = createTextLine("== BYPASS CLICK TP MENU ==", 0, Color3.fromRGB(255, 140, 0))
UI_Elements.Status = createTextLine("Телепорт (Микро-шаги): РАБОТАЕТ", 25, Color3.fromRGB(0, 255, 127))
UI_Elements.Instruction = createTextLine("Управление: [Ctrl + Клик Мыши] по карте", 50, Color3.fromRGB(220, 220, 220))
UI_Elements.UnloadText = createTextLine("Нажми [X] для выгрузки и удаления меню", 75, Color3.fromRGB(255, 69, 0))

-- Функция продвинутого обхода анти-телепорта
local function BypassTeleport(targetPosition)
    local Character = LocalPlayer.Character
    local HRP = Character and Character:FindFirstChild("HumanoidRootPart")
    local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")
    
    if not HRP or not Humanoid or Humanoid.Health <= 0 then return end
    
    -- Временно переводим персонажа в режим физики, чтобы отключить проверки падения
    Humanoid:ChangeState(Enum.HumanoidStateType.Physics)
    
    -- Конечная точка назначения (приподнимаем, чтобы не застрять в земле)
    local finalPos = targetPosition + Vector3.new(0, 3, 0)
    
    -- Цикл нарезки расстояния на разрешенные сервером отрезки
    while (HRP.Position - finalPos).Magnitude > TP_Settings.MaxStepDistance and TP_Settings.Active do
        -- Вычисляем направление к цели
        local direction = (finalPos - HRP.Position).Unit
        -- Рассчитываем координату следующего безопасного микро-шага
        local nextPosition = HRP.Position + (direction * TP_Settings.MaxStepDistance)
        
        -- Сдвигаем CFrame персонажа на один шаг, сохраняя направление его взгляда
        HRP.CFrame = CFrame.new(nextPosition, nextPosition + HRP.CFrame.LookVector)
        
        -- КРИТИЧЕСКИ ВАЖНО: Обязательная пауза, чтобы сервер успел зафиксировать шаг и не вернул назад
        task.wait(TP_Settings.StepDelay)
    end
    
    -- Финальный микро-телепорт точно в цель (когда расстояние осталось меньше шага)
    if TP_Settings.Active then
        HRP.CFrame = CFrame.new(finalPos, finalPos + HRP.CFrame.LookVector)
    end
    
    -- Возвращаем персонажу обычное состояние бега
    Humanoid:ChangeState(Enum.HumanoidStateType.Running)
end

-- Обработка горячих клавиш и мыши
local InputConnection
InputConnection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    -- Клик мыши при зажатом Ctrl
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) or UserInputService:IsKeyDown(Enum.KeyCode.RightControl) then
            if Mouse.Hit then
                -- Запускаем ТП в отдельном потоке
                task.spawn(BypassTeleport, Mouse.Hit.Position)
            end
        end
    end
    
    -- Выгрузка чита (Клавиша X)
    if input.KeyCode == Enum.KeyCode.X then
        TP_Settings.Active = false
        if InputConnection then InputConnection:Disconnect() end
        
        -- Удаление HUD меню с экрана
        for _, element in pairs(UI_Elements) do
            if element then element:Destroy() end
        end
        print("[Чит полностью выгружен]")
    end
end)
