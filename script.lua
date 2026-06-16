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
UI_Elements.Title = createTextLine("== MAP SEAT CLICK TP ==", 0, Color3.fromRGB(255, 165, 0))
UI_Elements.Status = createTextLine("Использует готовые стулья карты", 25, Color3.fromRGB(0, 255, 255))
UI_Elements.Instruction = createTextLine("Инструкция: Сядьте на любой стул -> Нажмите Ctrl + Клик", 50, Color3.fromRGB(240, 240, 240))
UI_Elements.UnloadText = createTextLine("Нажми [X] для выгрузки чита", 75, Color3.fromRGB(255, 0, 50))

-- Функция поиска ближайшего сидения на карте
local function findNearestSeat()
    local Character = LocalPlayer.Character
    local HRP = Character and Character:FindFirstChild("HumanoidRootPart")
    if not HRP then return nil end
    
    local nearestSeat = nil
    local shortestDistance = math.huge
    
    -- Сканируем всю карту на наличие стандартных сидений
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("Seat") or obj:IsA("VehicleSeat") then
            local distance = (obj.Position - HRP.Position).Magnitude
            if distance < shortestDistance then
                shortestDistance = distance
                nearestSeat = obj
            end
        end
    end
    return nearestSeat
end

-- Функция телепортации
local function MapSeatTeleport(targetPos)
    local Character = LocalPlayer.Character
    local HRP = Character and Character:FindFirstChild("HumanoidRootPart")
    local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")
    
    if not HRP or not Humanoid or Humanoid.Health <= 0 then return end
    
    -- Проверяем: сидит ли игрок уже. Если нет — ищем ближайший стул в радиусе 10 метров и сажаем
    if Humanoid.SeatPart == nil then
        local targetSeat = findNearestSeat()
        if targetSeat and (targetSeat.Position - HRP.Position).Magnitude < 10 then
            targetSeat:Sit(Humanoid)
            task.wait(0.1) -- Ждем посадки
        else
            print("[Внимание] Для обхода античета сначала сядьте на любой стул/машину на карте!")
            return
        end
    end
    
    -- Если мы успешно сидим на легитимном стуле карты:
    if Humanoid.SeatPart and TP_Settings.Active then
        -- Мгновенно переносим персонажа в точку клика мыши
        local finalPos = targetPos + Vector3.new(0, 3, 0)
        HRP.CFrame = CFrame.new(finalPos)
        
        -- Сбрасываем сидение (заставляем персонажа встать/выпрыгнуть в новой точке)
        task.wait(0.02)
        Humanoid.Jump = true
    end
end

-- Обработка кликов (Ctrl + ЛКМ)
local InputConnection
InputConnection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) or UserInputService:IsKeyDown(Enum.KeyCode.RightControl) then
            if Mouse.Hit then
                task.spawn(MapSeatTeleport, Mouse.Hit.Position)
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
