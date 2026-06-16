local plrv = game:GetService("Players").LocalPlayer
local mouse = plrv:GetMouse()
mouse.Button1Down:Connect(function()
    if game:GetService("UserInputService"):IsKeyDown(Enum.KeyCode.LeftControl) then
        if mouse.Target then
            plrv.Character:MoveTo(mouse.Hit.p)
        end
    end
end)
