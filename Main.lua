local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()

-- Serviços
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer
local remoteEvent = ReplicatedStorage:WaitForChild("RemoteEvent")
local IsGameActive = ReplicatedStorage:WaitForChild("IsGameActive")

-- Variáveis de Controle
local running = true
local speedBoostEnabled = false
local noclipEnabled = false
local highlightEnabled = false
local tracersEnabled = false
local reachEnabled = false
local reachSize = 15

local espBeast = false
local espSurvivors = false
local espEveryone = false

local tableHighlightEnabled = false
local podHighlightEnabled = false
local autoHelpEnabled = false
local autoHackerEnabled = false
local antiSeerEnabled = true

local targetWalkSpeed = 60
local highlightTransparency = 0.5 
local originalZoom = LocalPlayer.CameraMaxZoomDistance

local auraEnabled = false
local auraDistance = 20

-- Funções Auxiliares
local function applyTracer(targetChar, color)
    local root = targetChar:FindFirstChild("HumanoidRootPart")
    local myChar = LocalPlayer.Character
    local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
    
    if root and myRoot then
        local beam = root:FindFirstChild("NightfallTracer")
        if not beam then
            local att0 = Instance.new("Attachment")
            att0.Name = "TracerAtt0"
            att0.Parent = myRoot
            
            local att1 = Instance.new("Attachment")
            att1.Name = "TracerAtt1"
            att1.Parent = root
            
            beam = Instance.new("Beam")
            beam.Name = "NightfallTracer"
            beam.Attachment0 = att0
            beam.Attachment1 = att1
            beam.Width0 = 0.05
            beam.Width1 = 0.05
            beam.FaceCamera = true
            beam.Transparency = NumberSequence.new(0.4)
            beam.Parent = root
        end
        beam.Color = ColorSequence.new(color)
        beam.Enabled = true
        
        -- Garante que a âncora no MEU corpo existe
        if not myRoot:FindFirstChild("TracerAtt0") then
            local newAtt = Instance.new("Attachment", myRoot)
            newAtt.Name = "TracerAtt0"
            beam.Attachment0 = newAtt
        end
    end
end

-- Tabela de referência para facilitar a manutenção

--Janela
local Window = WindUI:CreateWindow({
    Title = "Night-fall",
    Author = "v1.2",
    Folder = "FTF_Wind_Settings",
    Icon = "", 
    Theme = "Midnight",
    Transparent = true,
    HideSearchBar = false,
    User = {
      Enabled = true
    }
    
    KeySystem = {
        Key = { "NINAsilva" },
        SaveKey = true
        Note = "Night-fall hub",
        URL = "https://roblox.com/en", -- Link que será copiado no botão
        -- Configuração de APIs automáticas
        API = {
            {   
                Type = "platoboost", 
                ServiceId = 5541, 
                Secret = "1eda3b70-aab4-4394-82e4-4e7f507ae198",
            },
            {   
                Type = "pandadevelopment",
                ServiceId = "windui",
            }
        },
    },

    
    OpenButton = { Enabled = true,
      Title = "Night-fall hub",
      Draggable = true,
      StrokeThickness = 0
    }
})

Window:Tag({
        Title = "gemini",
        Icon = "solar:code-bold",
        Color = Color3.fromHex("#7775F2"),
        Border = false
})

Window:Tag({
        Title = "Jogorbx",
        Icon = "solar:code-bold",
        Color = Color3.fromHex("#10C550"),
        Border = false
})

--Tabs
local HomeTab = Window:Tab({ 
  Title = "Main",
  Icon = "solar:home-2-bold" 
})
local VisualTab = Window:Tab({ 
  Title = "Visuals",
  Icon = "solar:eye-bold"
})
local TeleportTab = Window:Tab({
  Title = "Teleports",
  Icon = "solar:map-point-rotate-bold"
})
local AutoTab = Window:Tab({
  Title = "Auto",
  Icon = "solar:lightbulb-bold"
})
local BeastTab = Window:Tab({
  Title = "Beast",
  Icon = "solar:shield-warning-bold"
})
local ConfigsTab = Window:Tab({
  Title = "Settings",
  Icon = "solar:settings-bold"
})

--Geral
HomeTab:Section({ 
  Title = "Movimentação" })

HomeTab:Slider({ 
  Title = "Walkspeed", 
  Step = 1, Value = { Min = 16, Max = 120, Default = 60 },
  Callback = function(v) targetWalkSpeed = v end })

HomeTab:Toggle({ 
  Title = "toggle walkspeed", 
  Callback = function(state) speedBoostEnabled = state if not state and LocalPlayer.Character:FindFirstChild("Humanoid") then LocalPlayer.Character.Humanoid.WalkSpeed = 16 end end })

HomeTab:Toggle({
  Title = "Noclip",
  Callback = function(state) noclipEnabled = state end })

HomeTab:Section({ 
  Title = "World" })

HomeTab:Button({
    Title = "Remover Neblina",
    Callback = function()
        Lighting.FogEnd = 100000
        for _, effect in pairs(Lighting:GetDescendants()) do
            if effect:IsA("Atmosphere") or effect:IsA("BlurEffect") then effect:Destroy() end
        end
        WindUI:Notify({
          Title = "World", 
          Content = "No fog",
          Duration = 2 })
    end
})

--Visual
VisualTab:Section({ Title = "Highlights" })

VisualTab:Toggle({ 
    Title = "Beast", 
    Callback = function(state) espBeast = state end 
})

VisualTab:Toggle({ 
    Title = "Survivors", 
    Callback = function(state) espSurvivors = state end 
})

VisualTab:Toggle({ 
    Title = "Everyone", 
    Callback = function(state) espEveryone = state end 
})

VisualTab:Space()

VisualTab:Toggle({ 
  Title = "Computers",
  Callback = function(state) tableHighlightEnabled = state if not state then clearAllHighlights("TableESP") end end })

VisualTab:Toggle({
  Title = "Capsules", 
  Callback = function(state) podHighlightEnabled = state if not state then clearAllHighlights("PodESP") end end })

VisualTab:Slider({ 
  Title = "ESP transparency", 
  Step = 0.1, Value = { Min = 0, Max = 1, Default = 0.5 }, Callback = function(v) highlightTransparency = v end })

VisualTab:Section({ 
  Title = "Tracers"})

VisualTab:Toggle({ 
    Title = "Linhas (Tracers)", 
    Value = tracersEnabled,
    Callback = function(state) 
        tracersEnabled = state 
        
        if not state then
            for _, p in pairs(Players:GetPlayers()) do
                if p.Character then
                    local r = p.Character:FindFirstChild("HumanoidRootPart")
                    if r and r:FindFirstChild("NightfallTracer") then
                        r.NightfallTracer.Enabled = false
                    end
                end
            end
        end
    end 
})


--Teletransporte
TeleportTab:Section({ 
  Title = "Places"})

TeleportTab:Dropdown({
    Title = "Teleport to",
    Values = { "Spawn", "Beast Cave", "Map", "Mini-game Cave", "Secret Place" },
    Callback = function(selectedValue)
      
      local tpLocations = {
    ["Spawn"] = function() return workspace:FindFirstChild("LobbySpawnPad") end,
    ["Beast Cave"] = function() return workspace:FindFirstChild("BeastCaveSpawnPad") end,
    ["Mini-game Cave"] = function() return workspace:FindFirstChild("LobbyCaveSpawnPadIn") end,
    ["Map"] = function() 
        -- Busca automática pelo mapa atual carregado
        for _, obj in pairs(workspace:GetChildren()) do
            if obj:IsA("Model") and obj:FindFirstChild("ExitDoor") then
                return obj.ExitDoor
            end
        end
        return nil
    end
}
      
        local targetFunc = tpLocations[selectedValue]
        local target = targetFunc and targetFunc()

        if target and LocalPlayer.Character then
            local targetCFrame = target:IsA("Model") and target:GetPivot() or target.CFrame
            LocalPlayer.Character:PivotTo(targetCFrame + Vector3.new(0, 3, 0))

            WindUI:Notify({
                Title = "Teleport",
                Content = "Teleportado para " .. selectedValue,
                Duration = 2
            })
        else
            WindUI:Notify({
                Title = "Erro",
                Content = "Local não encontrado ou indisponível agora.",
                Duration = 4
            })
        end
    end
})

--Auto
AutoTab:Section({ 
  Title = "Auto" 
})
AutoTab:Toggle({ 
  Title = "Anti pc error", 
  Callback = function(state) autoHackerEnabled = state end })

AutoTab:Toggle({
  Title = "Anti-Seer",
  Callback = function(state) antiSeerEnabled = state end })

AutoTab:Section({ 
  Title = "Fast" })

AutoTab:Toggle({ 
  Title = "Auto save players",
  Callback = function(state) autoHelpEnabled = state end }) 

local function triggerHelp()
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    for _, obj in pairs(workspace:GetDescendants()) do
        if obj.Name == "PodTrigger" and obj:IsA("BasePart") then
            local capturedValue = obj:FindFirstChild("CapturedTorso")
            
            if capturedValue and capturedValue.Value ~= nil then
                local originalCFrame = obj.CFrame
                local originalSize = obj.Size
                
                obj.Size = Vector3.new(60, 60, 60)
                obj.CFrame = hrp.CFrame
                
                task.wait(0.1)
                remoteEvent:FireServer("Input", "Action", true)
                task.wait(0.5)
                
                WindUI:Notify({
                  Title = "Auto Help",
                  Content = "Player Salvo",
                  Duration = 2.5
                })
                
                obj.Size = originalSize
                obj.CFrame = originalCFrame
                
                return true
            end
        end
    end
    return false
end

task.spawn(function()
    while true do
        if autoHelpEnabled and running then
            triggerHelp()
        end
        task.wait(0.5)
    end
end)

AutoTab:Button({
    Title = "Save player",
    Callback = function()
        local result = triggerHelp()
    end
})

--Beast
BeastTab:Section({ Title = "Combat" })

local auraMode = "Legit" -- Padrão

BeastTab:Dropdown({
    Title = "Aura Intensity",
    Values = { "Legit", "Rage" },
    Value = 1,
    Callback = function(v) auraMode = v end
})

BeastTab:Slider({
    Title = "Aura Distance",
    Step = 1, Value = { Min = 5, Max = 25, Default = 15 },
    Callback = function(v) auraDistance = v end
})


BeastTab:Toggle({
    Title = "Enable Kill Aura",
    Callback = function(state) auraEnabled = state end
})

BeastTab:Section({ Title = "Hitbox Expander" })

local hitboxEnabled = false
local hitboxSize = 10

BeastTab:Toggle({
    Title = "Expand Survivors Hitbox",
    Callback = function(state) 
        hitboxEnabled = state 
        if not state then
            -- Resetar hitboxes ao desligar
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                    p.Character.HumanoidRootPart.Size = Vector3.new(2, 2, 1)
                    p.Character.HumanoidRootPart.Transparency = 1
                end
            end
        end
    end 
})

BeastTab:Slider({
    Title = "Hitbox Size",
    Step = 1, Value = { Min = 2, Max = 20, Default = 10 },
    Callback = function(v) hitboxSize = v end
})

BeastTab:Slider({
    Title = "Reach Distance",
    Step = 1, Value = { Min = 2, Max = 40, Default = 15 },
    Callback = function(v) reachSize = v end
})

BeastTab:Toggle({
    Title = "Enable Reach",
    Callback = function(state) reachEnabled = state end
})

BeastTab:Section({ Title = "Player Cam" })

BeastTab:Toggle({
  Title = "Unlimited Zoom-Out",
  Callback = function(state) LocalPlayer.CameraMaxZoomDistance = state and 10000 or originalZoom end })

BeastTab:Button({
  Title = "Unlock third person",
  Callback = function() LocalPlayer.CameraMode = Enum.CameraMode.Classic end })

--Configs
ConfigsTab:Section({
  Title = "Hub Settings"
})
ConfigsTab:Dropdown({ 
    Title = "Theme",
    Values = {
        "Midnight", "Crimson", "Dark", "Emerald", "Indigo", "Light", "Amber", "Plant", "Red", "Rose", "Sky", "Violet","Rainbow"
    },
    Value = 1,
    Callback = function(selectedValue)
      WindUI:SetTheme(selectedValue)
      
      WindUI:Notify({ 
            Title = "System", 
            Content = "Tema " .. selectedValue .. " ativado!", 
            Duration = 2
        })
    end
})

ConfigsTab:Toggle({
  Title = "Notifications",
  Callback = ""
})

ConfigsTab:Button({
    Title = "Close Hub",
    Callback = function()
        running = false
        clearAllHighlights("PlayerESP")
        clearAllHighlights("TableESP")
        clearAllHighlights("PodESP")
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then LocalPlayer.Character.Humanoid.WalkSpeed = 16 end
        Window:Destroy()
    end
})



--- ==========================================
--- 2. LÓGICA TÉCNICA (HOOKS MELHORADOS)
--- =======================================

--Anti pc error
local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
    local args = {...}
    local method = getnamecallmethod()
    
    if method == "FireServer" and not checkcaller() then
        if autoHackerEnabled and args[1] == "SetPlayerMinigameResult" then
            args[2] = true
            return oldNamecall(self, unpack(args))
        end
    end
    
    return oldNamecall(self, ...)
end)

-- Detector de Poder Global
task.spawn(function()
    local lastPower = ""
    local isGameActive = ReplicatedStorage:WaitForChild("IsGameActive")
      
      while running do
        if isGameActive.Value == false then
            if lastPower ~= "" then
                lastPower = "" 
                
            end
        else
            for _, p in pairs(Players:GetPlayers()) do
                local stats = p:FindFirstChild("TempPlayerStatsModule")
                if stats and stats:FindFirstChild("IsBeast") and stats.IsBeast.Value == true then
                    
                    local powerObj = ReplicatedStorage:FindFirstChild("CurrentPower") or stats:FindFirstChild("CurrentPower")
                    local powerName = powerObj and powerObj.Value or p:GetAttribute("Power")
                    
                    if powerName and powerName ~= "" and powerName ~= lastPower then
                        lastPower = powerName
                        WindUI:Notify({
                            Title = "Fera Detectada: " ..p.Name,
                            Content = "Poder: " .. tostring(powerName),
                            Duration = 4
                        })
                    end
                end
            end
        end
        task.wait(2)
      end
end)

--- ==========================================
--- 3. LOOPS (ESP E MOVIMENTAÇÃO)
--- ==========================================

local function applyHighlight(obj, name, color)
    local h = obj:FindFirstChild(name) or Instance.new("Highlight")
    h.Name = name
    h.FillColor = color
    h.OutlineColor = color
    h.FillTransparency = highlightTransparency
    h.Parent = obj
end

--SPEED
RunService.Heartbeat:Connect(function()
    if running and speedBoostEnabled and LocalPlayer.Character then
        local hum = LocalPlayer.Character:FindFirstChild("Humanoid")
        if hum then hum.WalkSpeed = targetWalkSpeed end
    end
end)

--NOCLIP
RunService.Stepped:Connect(function()
    if running and noclipEnabled and LocalPlayer.Character then
        for _, p in pairs(LocalPlayer.Character:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide = false end end
    end
end)

--ESP
task.spawn(function()
    while running do
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character then
                local stats = p:FindFirstChild("TempPlayerStatsModule")
                if stats and stats:FindFirstChild("IsBeast") then
                    local isBeast = stats.IsBeast.Value
                    local shouldShow = false
                    local color = isBeast and Color3.fromRGB(255, 0, 0) or Color3.fromRGB(0, 255, 0)

                    if espEveryone or (espBeast and isBeast) or (espSurvivors and not isBeast) then
                        shouldShow = true
                    end

                    if shouldShow then
                        applyHighlight(p.Character, "PlayerESP", color)
                        if tracersEnabled then applyTracer(p.Character, color) end
                    else
                        if p.Character:FindFirstChild("PlayerESP") then p.Character.PlayerESP:Destroy() end
                    end
                end
            end
        end

        -- Destaque de Objetos
        if tableHighlightEnabled or podHighlightEnabled then
            for _, obj in pairs(workspace:GetDescendants()) do -- Use GetDescendants para garantir
                if tableHighlightEnabled and obj.Name == "ComputerTable" then
                    applyHighlight(obj, "TableESP", Color3.fromRGB(0, 150, 255))
                elseif podHighlightEnabled and obj.Name == "FreezePod" then
                    applyHighlight(obj, "PodESP", Color3.fromRGB(255, 200, 0))
                end
            end
        end
        task.wait(1.5)
    end
end)


--KILL AURA 
task.spawn(function()
    while running do
        if auraEnabled then
            local char = LocalPlayer.Character
            local hammer = char and char:FindFirstChild("Hammer")
            local hEvent = hammer and hammer:FindFirstChild("HammerEvent")
            local myRoot = char and char:FindFirstChild("HumanoidRootPart")
            
            if hEvent and myRoot then
                local maxDist = (auraMode == "Rage") and 22 or auraDistance 
                
                for _, p in pairs(Players:GetPlayers()) do
                    if p ~= LocalPlayer and p.Character then
                        local tChar = p.Character
                        local tRoot = tChar:FindFirstChild("HumanoidRootPart")
                        local stats = p:FindFirstChild("TempPlayerStatsModule")
                        
                        local isBeast = stats and stats:FindFirstChild("IsBeast") and stats.IsBeast.Value
                        local isCaptured = stats and stats:FindFirstChild("IsCaptured") and stats.IsCaptured.Value
                        
                        if not isBeast and not isCaptured and tRoot then
                            local dist = (myRoot.Position - tRoot.Position).Magnitude
                            
                            if dist <= maxDist then
                                hEvent:FireServer("HammerClick", true)
                                
                                local hitPart = tChar:FindFirstChild("Right Arm") or tChar:FindFirstChild("Torso") or tChar:FindFirstChild("HumanoidRootPart")
                                
                                if auraMode == "Rage" then
                                    hEvent:FireServer("HammerHit", hitPart)
                                else
                                    task.wait(0.1)
                                    hEvent:FireServer("HammerHit", hitPart)
                                end
                            end
                        end
                    end
                end
            end
        end
        task.wait(auraMode == "Rage" and 0.1 or 0.3)
    end
end)

--Hitbox Expander
task.spawn(function()
    while running do
        if hitboxEnabled then
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character then
                    local stats = p:FindFirstChild("TempPlayerStatsModule")
                    local isBeast = stats and stats:FindFirstChild("IsBeast") and stats.IsBeast.Value
                    
                    -- Só expande se não for a Fera
                    if not isBeast then
                        local hrp = p.Character:FindFirstChild("HumanoidRootPart")
                        if hrp then
                            hrp.Size = Vector3.new(hitboxSize, hitboxSize, hitboxSize)
                            hrp.Transparency = 0.7 -- Deixa uma "caixa" visível para você saber onde bater
                            hrp.Shape = Enum.PartType.Block -- Opcional: usar formato de cubo cobre mais ângulos
                            hrp.CanCollide = false -- Importante para eles não ficarem travando nas paredes
                        end
                    end
                end
            end
        end
        task.wait(5) -- Não precisa de muito spam
    end
end)



WindUI:Notify({ Title = "Night-fall Hub", Content = "Hub Carregado com Sucesso!", Duration = 4 })
