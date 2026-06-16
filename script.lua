-- Инициализация базовых сервисов
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

local CheatSettings = {
    Noclip = false,
    TP_Distance = 15
}

-- Вывод уведомления в обычную консоль игры (F9)
print("[Чит Запущен] Нажмите 'E' для Телепорта, 'G' для Сквозь стены, 'X' для Выгрузки")

-- 1. Логика Сквозь Стены (Noclip)
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

-- 2. Обработка нажатий на клавиатуре (Бинды)
local InputConnection
InputConnection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
    -- Если вы пишете в чат, чит не сработает
    if gameProcessed then return end
    
    -- Кнопка E — Телепорт вперед
    if input.KeyCode == Enum.KeyCode.E then
        local Character = LocalPlayer.Character
        if Character and Character:FindFirstChild("HumanoidRootPart") then
            local HRP = Character.HumanoidRootPart
            HRP.CFrame = HRP.CFrame + (HRP.CFrame.LookVector * CheatSettings.TP_Distance)
        end
    
    -- Кнопка G — Переключатель Noclip
    elseif input.KeyCode == Enum.KeyCode.G then
        local Character = LocalPlayer.Character
        CheatSettings.Noclip = not CheatSettings.Noclip
        print("Режим сквозь стены: ", CheatSettings.Noclip)
        
        -- Если выключили, возвращаем коллизию
        if not CheatSettings.Noclip and Character then
            for _, part in pairs(Character:GetChildren()) do
                if part:IsA("BasePart") then part.CanCollide = true end
            end
        end
        
    -- Кнопка X — Полная выгрузка
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
