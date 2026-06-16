local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

local TP_Settings = {
    Active = true
}

-- Стабильный HUD через Drawing API в обход ошибок nil
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
UI_Elements.Title = createTextLine("== SEAT METHOD CLICK TP ==", 0, Color3.fromRGB(138, 43, 226))
UI_Elements.Status = createTextLine("Метод: Обход через Seat-Glitches", 25, Color3.fromRGB(0, 255, 0))
UI_Elements.Instruction = createTextLine("Управление: [Ctrl + Клик Мыши] по карте", 50, Color3.fromRGB(240, 240, 240))
UI_Elements.UnloadText = createTextLine("Нажми [X] для выгрузки чита", 75, Color3.fromRGB(255, 0, 50))

-- Основная функция ТП через создание сидения
local function SeatTeleport(targetPos)
    local Character = LocalPlayer.Character
    local HRP = Character and Character:FindFirstChild("HumanoidRootPart")
    local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")
    
    if not HRP or not Humanoid or Humanoid.Health <= 0 then return end
    
    -- Создаем временное невидимое сидение
    local TempSeat = Instance.new("Seat")
    TempSeat.Size = Vector3.new(1, 1, 1)
    TempSeat.Transparency = 1
    TempSeat.CanCollide = false
    TempSeat.Anchored = true
    -- Спавним его прямо под персонажем
    TempSeat.CFrame = HRP.CFrame
    TempSeat.Parent = workspace
    
    -- Принудительно сажаем персонажа (сервер одобряет это действие)
    TempSeat:Sit(Humanoid)
    
    -- Микро-пауза, чтобы сервер зафиксировал посадку
    task.wait(0.05)
    
    if TP_Settings.Active and TempSeat.Parent then
        -- Перемещаем само СИДЕНИЕ в точку назначения (приподняв над землей)
        local finalPos = targetPos + Vector3.new(0, 3, 0)
        TempSeat.CFrame = CFrame.new(finalPos)
        
        -- Даем серверу долю секунды обновить позицию сидения вместе с нами
        task.wait(0.05)
        
        -- Заставляем персонажа прыгнуть, чтобы встать со стула
        Humanoid.Jump = true
        
        -- Уничтожаем временное сидение, стирая следы
        task.wait(0.02)
        TempSeat:Destroy()
    else
        TempSeat:Destroy()
    end
end

-- Обработка клавиш
local InputConnection
InputConnection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    -- Ctrl + ЛКМ
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) or UserInputService:IsKeyDown(Enum.KeyCode.RightControl) then
            if Mouse.Hit then
                task.spawn(SeatTeleport, Mouse.Hit.Position)
            end
        end
    end
    
    -- Выгрузка чита (Клавиша X)
    if input.KeyCode == Enum.KeyCode.X then
        TP_Settings.Active = false
        if InputConnection then InputConnection:Disconnect() end
        
        for _, element in pairs(UI_Elements) do
            if element then element:Destroy() end
        end
        print("[Чит полностью выгружен]")
    end
end)
