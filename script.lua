local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

local TP_Settings = {
    Active = true,
    FreezeTime = 0.35 -- Время заморозки в секундах (подбирается под античит)
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
UI_Elements.Title = createTextLine("== FREEZE NETWORK CLICK TP ==", 0, Color3.fromRGB(0, 255, 255))
UI_Elements.Status = createTextLine("Метод: Заморозка сетевых пакетов", 25, Color3.fromRGB(255, 215, 0))
UI_Elements.Instruction = createTextLine("Управление: [Ctrl + Клик Мыши] по карте", 50, Color3.fromRGB(240, 240, 240))
UI_Elements.UnloadText = createTextLine("Нажми [X] для выгрузки чита", 75, Color3.fromRGB(255, 0, 50))

-- Функция телепортации через сетевой лаг
local function FreezeTeleport(targetPos)
    local Character = LocalPlayer.Character
    local HRP = Character and Character:FindFirstChild("HumanoidRootPart")
    local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")
    
    if not HRP or not Humanoid or Humanoid.Health <= 0 then return end
    
    local networkSettings = settings():FindFirstChild("NetworkSettings") or settings().Network
    
    -- Шаг 1: Искусственно врубаем дикий пинг (замораживаем пакеты для сервера)
    if networkSettings then
        networkSettings.IncomingReplicationLag = 9999
    end
    
    -- Шаг 2: Меняем состояние гуманоида, чтобы сервер временно потерял физический контроль
    Humanoid:ChangeState(Enum.HumanoidStateType.Physics)
    
    -- Шаг 3: Мгновенно переносим персонажа на клиенте в точку клика
    local finalPos = targetPos + Vector3.new(0, 3, 0)
    HRP.CFrame = CFrame.new(finalPos)
    
    -- Шаг 4: Даем клиенту микро-паузу, чтобы прогрузить текстуры в новой точке
    task.wait(TP_Settings.FreezeTime)
    
    -- Шаг 5: Восстанавливаем сеть и отправляем серверу факт того, что мы уже тут
    if networkSettings then
        networkSettings.IncomingReplicationLag = 0
    end
    
    -- Возвращаем нормальное состояние персонажу
    Humanoid:ChangeState(Enum.HumanoidStateType.Running)
end

-- Обработка кликов (Ctrl + ЛКМ)
local InputConnection
InputConnection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) or UserInputService:IsKeyDown(Enum.KeyCode.RightControl) then
            if Mouse.Hit then
                task.spawn(FreezeTeleport, Mouse.Hit.Position)
            end
        end
    end
    
    -- Полная выгрузка чита (Клавиша X)
    if input.KeyCode == Enum.KeyCode.X then
        TP_Settings.Active = false
        if InputConnection then InputConnection:Disconnect() end
        
        -- Возвращаем сеть в норму на всякий случай
        local networkSettings = settings():FindFirstChild("NetworkSettings") or settings().Network
        if networkSettings then networkSettings.IncomingReplicationLag = 0 end
        
        for _, element in pairs(UI_Elements) do
            if element then element:Destroy() end
        end
        print("[Чит полностью выгружен]")
    end
end)
