-- Защищенная инициализация игровых сервисов
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- Настройки безопасной телепортации
local TP_Settings = {
    Active = true,
    TimeTaken = 0.25 -- Время «полета» до точки клика (чем меньше, тем быстрее, но выше шанс детекта)
}

-- Использование Drawing API для создания интерфейса (HUD) в обход ограничений среды
local function createTextLine(text, yOffset, color)
    if not Drawing then return nil end
    local textObject = Drawing.new("Text")
    textObject.Text = text
    textObject.Size = 18
    textObject.Position = Vector2.new(40, 150 + yOffset)
    textObject.Color = color or Color3.fromRGB(255, 255, 255)
    textObject.Outline = true
    textObject.Visible = true
    return textObject
end

-- Отрисовка элементов HUD прямо на экране поверх игры
local UI_Elements = {}
UI_Elements.Title = createTextLine("== CLICK TELEPORT MENU ==", 0, Color3.fromRGB(255, 215, 0))
UI_Elements.Status = createTextLine("Статус ТП по клику: ВКЛЮЧЕН", 25, Color3.fromRGB(50, 205, 50))
UI_Elements.Instruction = createTextLine("Управление: Нажми [Ctrl + Клик Мыши] для ТП", 50, Color3.fromRGB(200, 200, 200))
UI_Elements.UnloadText = createTextLine("Нажми клавишу [X] для полной выгрузки чита", 75, Color3.fromRGB(220, 20, 60))

-- Основная логика безопасного перемещения по клику мыши
local function TeleportToMouse()
    if not TP_Settings.Active then return end
    
    local Character = LocalPlayer.Character
    local HRP = Character and Character:FindFirstChild("HumanoidRootPart")
    local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")
    
    -- Проверяем, жив ли персонаж и куда указывает курсор мыши
    if HRP and Humanoid and Humanoid.Health > 0 and Mouse.Hit then
        -- Целевая координата (поднимаем на 3 студа вверх, чтобы не застрять в текстурах пола)
        local targetCFrame = CFrame.new(Mouse.Hit.Position + Vector3.new(0, 3, 0))
        
        -- Плавное перемещение (Tweening) для обхода серверного античита
        local tweenInfo = TweenInfo.new(TP_Settings.TimeTaken, Enum.EasingStyle.Linear)
        local tween = TweenService:Create(HRP, tweenInfo, {CFrame = targetCFrame})
        
        -- Переводим гуманоида в режим физики, отключая проверки на падение/бег
        Humanoid:ChangeState(Enum.HumanoidStateType.Physics)
        
        tween:Play()
        tween.Completed:Wait()
        
        -- Возвращаем исходное состояние движения персонажа
        Humanoid:ChangeState(Enum.HumanoidStateType.Running)
    end
end

-- Обработка системных нажатий
local InputConnection
InputConnection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
    -- Если вы печатаете текст в игровом чате, чит игнорирует нажатия
    if gameProcessed then return end
    
    -- Проверка комбинации: Нажат левый или правый Ctrl + Клик левой кнопкой мыши
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) or UserInputService:IsKeyDown(Enum.KeyCode.RightControl) then
            task.spawn(TeleportToMouse)
        end
    end
    
    -- Полная выгрузка скрипта по нажатию на клавишу X
    if input.KeyCode == Enum.KeyCode.X then
        if InputConnection then InputConnection:Disconnect() end
        TP_Settings.Active = false
        
        -- Полностью стираем текстовый HUD с экрана
        for _, element in pairs(UI_Elements) do
            if element then element:Destroy() end
        end
        print("[Чит полностью выгружен из памяти]")
    end
end)

print("[Скрипт готов к работе. Используйте Ctrl + ЛКМ для перемещения]")
