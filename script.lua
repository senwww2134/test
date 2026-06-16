local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

local TP_Settings = {
    Active = true,
    TargetPos = nil
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
UI_Elements.Title = createTextLine("== SPAWN GLITCH CLICK TP ==", 0, Color3.fromRGB(255, 0, 255))
UI_Elements.Status = createTextLine("Метод: Подмена координат респавна", 25, Color3.fromRGB(0, 255, 0))
UI_Elements.Instruction = createTextLine("Управление: [Ctrl + Клик Мыши] по карте", 50, Color3.fromRGB(240, 240, 240))
UI_Elements.UnloadText = createTextLine("Нажми [X] для выгрузки чита", 75, Color3.fromRGB(255, 0, 50))

-- Поток отслеживания респавна персонажа
local SpawnConnection
SpawnConnection = LocalPlayer.CharacterAdded:Connect(function(newCharacter)
    if TP_Settings.Active and TP_Settings.TargetPos then
        -- Как только сервер создает новое тело, мгновенно перехватываем контроль
        local HRP = newCharacter:WaitForChild("HumanoidRootPart", 5)
        if HRP then
            -- Сдвигаем CFrame спавна в точку нашего клика до того, как античит проснется
            task.wait(0.02)
            HRP.CFrame = CFrame.new(TP_Settings.TargetPos + Vector3.new(0, 4, 0))
            TP_Settings.TargetPos = nil -- Сбрасываем цель после успешного ТП
        end
    end
end)

-- Основная функция триггера ТП
local function TriggerSpawnTP(clickPosition)
    local Character = LocalPlayer.Character
    local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")
    
    if Character and Humanoid and Humanoid.Health > 0 then
        -- Запоминаем точку, куда кликнули
        TP_Settings.TargetPos = clickPosition
        
        -- Мгновенно ломаем связи персонажа (вызываем респавн на сервере)
        Character:BreakJoints()
    end
end

-- Обработка кликов (Ctrl + ЛКМ)
local InputConnection
InputConnection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
    -- Игнорируем, если игрок пишет в чат
    if gameProcessed then return end
    
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) or UserInputService:IsKeyDown(Enum.KeyCode.RightControl) then
            if Mouse.Hit then
                task.spawn(TriggerSpawnTP, Mouse.Hit.Position)
            end
        end
    end
    
    -- Полная выгрузка чита (Клавиша X)
    if input.KeyCode == Enum.KeyCode.X then
        TP_Settings.Active = false
        if InputConnection then InputConnection:Disconnect() end
        if SpawnConnection then SpawnConnection:Disconnect() end
        
        for _, element in pairs(UI_Elements) do
            if element then element:Destroy() end
        end
        print("[Чит полностью выгружен]")
    end
end)
