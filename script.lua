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
UI_Elements.Title = createTextLine("== SEAT-GLITCH CLICK TP ==", 0, Color3.fromRGB(255, 105, 180))
UI_Elements.Status = createTextLine("Обход античета: АКТИВИРОВАН", 25, Color3.fromRGB(0, 255, 255))
UI_Elements.Instruction = createTextLine("Управление: [Ctrl + Клик Мыши]", 50, Color3.fromRGB(240, 240, 240))
UI_Elements.UnloadText = createTextLine("Нажми [X] для выгрузки чита", 75, Color3.fromRGB(255, 0, 50))

-- Функция ТП со встроенным сбросом проверок античета
local function GlitchTeleport(targetPos)
    local Character = LocalPlayer.Character
    local HRP = Character and Character:FindFirstChild("HumanoidRootPart")
    local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")
    
    if not HRP or not Humanoid or Humanoid.Health <= 0 then return end
    
    -- 1. Создаем невидимый фантомный стул под ногами для баггинга сети
    local FakeSeat = Instance.new("Seat")
    FakeSeat.Size = Vector3.new(0.5, 0.5, 0.5)
    FakeSeat.Transparency = 1
    FakeSeat.CanCollide = false
    FakeSeat.Anchored = true
    FakeSeat.CFrame = HRP.CFrame
    FakeSeat.Parent = workspace
    
    -- 2. Сажаем персонажа, ломая серверную проверку расстояния
    FakeSeat:Sit(Humanoid)
    task.wait(0.03) -- Микро-пауза для фиксации бага сервером
    
    if TP_Settings.Active then
        -- 3. Мгновенно перемещаем персонажа в точку клика (чуть выше земли)
        local finalPos = targetPos + Vector3.new(0, 3, 0)
        HRP.CFrame = CFrame.new(finalPos)
        
        -- 4. Сбрасываем состояние сидения, заставляя персонажа встать в новой точке
        task.wait(0.02)
        Humanoid.Jump = true
    end
    
    -- Удаляем стул из игры
    FakeSeat:Destroy()
end

-- Обработка кликов
local InputConnection
InputConnection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    -- Проверка Ctrl + ЛКМ
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) or UserInputService:IsKeyDown(Enum.KeyCode.RightControl) then
            if Mouse.Hit then
                task.spawn(GlitchTeleport, Mouse.Hit.Position)
            end
        end
    end
    
    -- Выгрузка чита
    if input.KeyCode == Enum.KeyCode.X then
        TP_Settings.Active = false
        if InputConnection then InputConnection:Disconnect() end
        
        for _, element in pairs(UI_Elements) do
            if element then element:Destroy() end
        end
        print("[Чит выгружен]")
    end
end)
