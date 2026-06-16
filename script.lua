local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer

local CheatSettings = {
    Noclip = false,
    TP_Distance = 25, -- Дистанцию можно немного увеличить, так как метод безопаснее
    TweenSpeed = 0.15 -- Время полета (чем меньше, тем быстрее, но выше шанс детекта)
}

print("[Анти-детектив Чит Запущен] 'E' - Безопасный ТП, 'G' - Noclip, 'X' - Выгрузка")

-- 1. Логика Безопасного Телепорта (Tween)
local function SafeTeleport()
    local Character = LocalPlayer.Character
    local HRP = Character and Character:FindFirstChild("HumanoidRootPart")
    local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")
    
    if HRP and Humanoid and Humanoid.Health > 0 then
        -- Рассчитываем конечную точку перед игроком
        local targetCFrame = HRP.CFrame + (HRP.CFrame.LookVector * CheatSettings.TP_Distance)
        
        -- Рассчитываем время в зависимости от расстояния (чтобы скорость была плавной)
        local info = TweenInfo.new(CheatSettings.TweenSpeed, Enum.EasingStyle.Linear)
        local tween = TweenService:Create(HRP, info, {CFrame = targetCFrame})
        
        -- На время полета временно отключаем гравитацию/падение, чтобы античит не сбоил
        local oldState = Humanoid:GetState()
        Humanoid:ChangeState(Enum.HumanoidStateType.Physics)
        
        tween:Play()
        tween.Completed:Wait()
        
        -- Возвращаем нормальное состояние персонажа
        Humanoid:ChangeState(Enum.HumanoidStateType.Running)
    end
end

-- 2. Логика Сквозь Стены (Noclip)
local NoclipConnection
NoclipConnection = RunService.Stepped:Connect(function()
    if CheatSettings.Noclip then
        local Character = LocalPlayer.Character
        if Character then
            for _, part in pairs(Character:GetChildren()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end
    end
end)

-- 3. Обработка нажатий
local InputConnection
InputConnection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    -- Кнопка E — Безопасный ТП
    if input.KeyCode == Enum.KeyCode.E then
        task.spawn(SafeTeleport) -- Запускаем в отдельном потоке, чтобы игра не фризила
    
    -- Кнопка G — Переключатель Noclip
    elseif input.KeyCode == Enum.KeyCode.G then
        CheatSettings.Noclip = not CheatSettings.Noclip
        print("Режим сквозь стены: ", CheatSettings.Noclip)
        
        if not CheatSettings.Noclip then
            local Character = LocalPlayer.Character
            if Character then
                for _, part in pairs(Character:GetChildren()) do
                    if part:IsA("BasePart") then part.CanCollide = true end
                end
            end
        end
        
    -- Кнопка X — Выгрузка
    elseif input.KeyCode == Enum.KeyCode.X then
        print("[Чит Выгружен]")
        if NoclipConnection then NoclipConnection:Disconnect() end
        if InputConnection then InputConnection:Disconnect() end
        
        local Character = LocalPlayer.Character
        if Character then
            for _, part in pairs(Character:GetChildren()) do
                if part:IsA("BasePart") then part.CanCollide = true end
            end
        end
    end
end)
