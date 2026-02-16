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
local LocalPlayer = Players.LocalPlayer
local CollectionService = game:GetService("CollectionService")

local CurrentMap = ReplicatedStorage:FindFirstChild("CurrentMap")

-- Variáveis de Controle
local running = true
local speedBoostEnabled = false
local noclipEnabled = false
_G.antiSeerEnabled = false

local targetLockerCFrame = nil

local highlightEnabled = false

local reachEnabled = false
local reachSize = 15
local clearAllHighlights = false

local espBeast = false
local espSurvivors = false
local espEveryone = false

local tracersEnabled = false
local tracersBeast = false
local tracersSurvivors = false
local tracersEveryone = false

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

local EnabledNotifications = true

local Saturation = 0.15

local function applyHighlight(target, name, color, fillTransparency)
  
    local h = target:FindFirstChild(name)
    
    if not h then
        h = Instance.new("Highlight")
        h.Name = name
        h.Parent = target
    end
    
    h.FillColor = color
    h.FillTransparency = highlightTransparency or 0.5
    h.OutlineColor = color
    
    return h
end

-- Função para limpar os ESPs
local function clearAllHighlights(name)
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("Highlight") and v.Name == name then
            v:Destroy()
        end
    end
end


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
        
        if not myRoot:FindFirstChild("TracerAtt0") then
            local newAtt = Instance.new("Attachment", myRoot)
            newAtt.Name = "TracerAtt0"
            beam.Attachment0 = newAtt
        end
    end
end

local iconFileName = "nightfall_icon.png"
local iconURL = "https://i.postimg.cc/8cmm8P9M/1771013761110.png" -- Link direto da imagem do gatinho

local function getIcon()
    -- Se o arquivo não existe, o script baixa ele agora
    if not isfile(iconFileName) then
        local success, result = pcall(function()
            return game:HttpGet(iconURL)
        end)
        if success then
            writefile(iconFileName, result)
        end
    end

    -- Agora tenta carregar o arquivo local
    local asset = ""
    pcall(function()
        asset = getcustomasset(iconFileName)
    end)
    
    -- Se falhar (alguns executores mobile não tem getcustomasset), usa o link direto
    return (asset ~= "" and asset) or iconURL
end

local iconAsset = getIcon()

--Janela
local Window = WindUI:CreateWindow({
    Title = "Night-fall",
    Author = "v1.0",
    Folder = "FTF_Wind_Settings",
    Icon = iconAsset, 
    Theme = "Midnight",
    Transparent = true,
    HideSearchBar = false,
    User = {
      Enabled = true,
      Callback = function(selected)
        
        if selected then
           HomeTab:Select()
        end 
      end
    },

    OpenButton = { 
      Enabled = true,
      Title = "Night-fall hub",
      Draggable = true,
      StrokeThickness = 0
    },
  
  KeySystem = {
    Note = "Night Fall Hub Key System",

    API = {
        {
            Type = "platoboost",
            ServiceId = 20343,
            Secret = "8ddbd5df-283f-42ae-a20d-2d0049855e00",
        }
    }
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
    Title = "Beast Tracer", 
    Callback = function(state) tracersBeast = state end 
})

VisualTab:Toggle({ 
    Title = "Survivors Tracer", 
    Callback = function(state) tracersSurvivors = state end 
})

VisualTab:Toggle({ 
    Title = "Everyone Tracer", 
    Callback = function(state) tracersEveryone = state end 
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

HomeTab:Section({ Title = "View" })

local spectating = false

local function getPlayerNames()
    local names = {}
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            table.insert(names, player.Name)
        end
    end
    table.sort(names)
    return names
end

local selectedPlayerName = ""
local PlayerDropdown = HomeTab:Dropdown({
    Title = "Select Player",
    Values = getPlayerNames(),
    Callback = function(selected)
        selectedPlayerName = selected
    end
})

HomeTab:Button({
    Title = "Teleport to Player",
    Callback = function()
        if selectedPlayerName ~= "" then
            local target = Players:FindFirstChild(selectedPlayerName)
            if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
                LocalPlayer.Character:PivotTo(target.Character.HumanoidRootPart.CFrame + Vector3.new(0, 3, 0))
                WindUI:Notify({ Title = "Teleport", Content = "Voce foi ate " .. selectedPlayerName, Duration = 2 })
            end
        else
            WindUI:Notify({ Title = "Erro", Content = "Selecione um player no menu acima!", Duration = 3 })
        end
    end
})

HomeTab:Toggle({
    Title = "Spectate Player",
    Callback = function(state)
        spectating = state
        local camera = workspace.CurrentCamera
        
        if state then
            task.spawn(function()
                while spectating do
                    local target = Players:FindFirstChild(selectedPlayerName)
                    if target and target.Character and target.Character:FindFirstChild("Humanoid") then
                        camera.CameraSubject = target.Character.Humanoid
                    else
                        camera.CameraSubject = LocalPlayer.Character:FindFirstChild("Humanoid")
                    end
                    task.wait(0.1)
                end
                camera.CameraSubject = LocalPlayer.Character:FindFirstChild("Humanoid")
            end)
        else
            camera.CameraSubject = LocalPlayer.Character:FindFirstChild("Humanoid")
        end
    end
})

local function refreshDropdown()
    PlayerDropdown:Refresh(getPlayerNames())
end

Players.PlayerAdded:Connect(function() task.wait(1) refreshDropdown() end)
Players.PlayerRemoving:Connect(function() refreshDropdown() end)


--Auto
AutoTab:Section({ 
  Title = "Auto" 
})
AutoTab:Toggle({ 
  Title = "Anti pc error", 
  Callback = function(state) autoHackerEnabled = state end })

AutoTab:Toggle({
  Title = "Anti-Seer",
  Callback = function(state)
    _G.antiSeerEnabled = state end })

AutoTab:Section({ 
  Title = "Fast" })

AutoTab:Toggle({ 
  Title = "Auto save players",
  Callback = function(state) autoHelpEnabled = state end }) 

local function triggerHelp()
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    for _, obj in pairs(CurrentMap.Value:GetDescendants()) do
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

local auraMode = "Legit"

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
    Title = "Hitbox",
    Callback = function(state) 
        hitboxEnabled = state 
        if not state then
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
    Locked = true,
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
      
      if selectedValue then
        
      WindUI:Notify({ 
            Title = "System", 
            Content = "Tema " .. selectedValue .. " ativado!", 
            Duration = 2
        })
      end
  end
})

ConfigsTab:Toggle({
  Title = "Notifications",
  Callback = function(state)
    EnabledNotifications = state 
  end 
})

ConfigsTab:Section({
  Title = "Graphics"
})

ConfigsTab:Slider({
  Title = "Saturation",
  Step = 0.1, Value = { Min = -5, Max = 5, Default = 0.5 },
    Callback = function(v) Saturation = v
      
      local colorCorrection = Lighting:FindFirstChildOfClass("ColorCorrectionEffect")
    
if not colorCorrection then
    colorCorrection = Instance.new("ColorCorrectionEffect")
    colorCorrection.Parent = Lighting
end

colorCorrection.Saturation = Saturation
end
})

ConfigsTab:Slider ({
  Title = "Contrast",
  Step = 0.1,
  Value = { Min = -5, Max = 5, Default = 0.2},
  Callback = function(v) Contrast = v
    
    local colorCorrection = Lighting:FindFirstChildOfClass("ColorCorrectionEffect")
  if not colorCorrection then
    colorCorrection = Instance.new("ColorCorrectionEffect")
    colorCorrection.Parent = Lighting
  end

colorCorrection.Contrast = Contrast

end
})

--- ==========================================
--- 2. LÓGICA TÉCNICA (HOOKS MELHORADOS)
--- =======================================

local function applySelfLocker()
    local char = LocalPlayer.Character
    if char then
        -- Adiciona a tag mágica diretamente em você
        if not CollectionService:HasTag(char, "LOCKER") then
            CollectionService:AddTag(char, "LOCKER")
        end
        
        -- Remove a tag "MUST_CRAWL" se existir, para o Seer achar 
        -- que você está em um armário em pé mesmo.
        if CollectionService:HasTag(char, "MUST_CRAWL") then
            CollectionService:RemoveTag(char, "MUST_CRAWL")
        end
    end
end

-- Mantém a tag mesmo se você morrer e renascer
LocalPlayer.CharacterAdded:Connect(function()
    task.wait(1)
    if _G.antiSeerEnabled then
        applySelfLocker()
    end
end)

-- Loop simples para garantir que a tag não suma
task.spawn(function()
    while true do
        if _G.antiSeerEnabled then
            applySelfLocker()
        end
        task.wait(2)
    end
end)


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
                        if EnabledNotifications then
                        WindUI:Notify({
                            Title = "Fera Detectada: " ..p.Name,
                            Content = "Poder: " .. tostring(powerName),
                            Duration = 4
                        })
                        end
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
--ESP
task.spawn(function()
    while running do
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character then
                local stats = p:FindFirstChild("TempPlayerStatsModule")
                if stats and stats:FindFirstChild("IsBeast") then
                    local isBeast = stats.IsBeast.Value
                    local color = isBeast and Color3.fromRGB(255, 0, 0) or Color3.fromRGB(0, 255, 0)
                    local r = p.Character:FindFirstChild("HumanoidRootPart")

                    local showHighlight = espEveryone or (espBeast and isBeast) or (espSurvivors and not isBeast)
                    if showHighlight then
                        applyHighlight(p.Character, "PlayerESP", color)
                    else
                        local h = p.Character:FindFirstChild("PlayerESP")
                        if h then h:Destroy() end
                    end

                    -- Controle do Tracer (Linha)
                    local showTracer = tracersEveryone or (tracersBeast and isBeast) or (tracersSurvivors and not isBeast)
                    if showTracer then
                        applyTracer(p.Character, color)
                    else
                        if r and r:FindFirstChild("NightfallTracer") then
                            r.NightfallTracer.Enabled = false
                        end
                    end
                end
            end
        end

        if (tableHighlightEnabled or podHighlightEnabled) and CurrentMap and CurrentMap.Value then
            for _, obj in pairs(CurrentMap.Value:GetChildren()) do
                
                if tableHighlightEnabled and obj.Name == "ComputerTable" then
                    local screen = obj:FindFirstChild("Screen", true)
                    
                    if screen and screen:IsA("BasePart") then
                        
                        
                        local isFinished = (screen.Color == Color3.fromRGB(40, 127, 71))
                        
                        local targetColor = isFinished and Color3.fromRGB(4, 106, 179) or Color3.fromRGB(0, 150, 255)
                        
                        -- Aplica/Atualiza o Highlight
                        local h = applyHighlight(obj, "TableESP", targetColor, highlightTransparency)
                        
                        if h then
                            h.FillColor = targetColor
                            h.OutlineColor = targetColor
                            h.FillTransparency = isFinished and 0.8 or (highlightTransparency or 0.5)
                            h.OutlineTransparency = isFinished and 0.6 or 0
                        end
                    end
                
                -- Cápsulas (Freeze Pods)
                elseif podHighlightEnabled and obj.Name == "FreezePod" then
                    applyHighlight(obj, "PodESP", Color3.fromRGB(255, 200, 0), highlightTransparency)
                    local h = obj:FindFirstChild("PodESP")
                    if h then
                        h.FillTransparency = highlightTransparency or 0.5
                        h.OutlineTransparency = 0
                    end
                end
            end
        else
            if not tableHighlightEnabled then clearAllHighlights("TableESP") end
            if not podHighlightEnabled then clearAllHighlights("PodESP") end
        end

        task.wait(1.5)
    end
end)


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
                    
                    if not isBeast then
                        local hrp = p.Character:FindFirstChild("HumanoidRootPart")
                        if hrp then
                            hrp.Size = Vector3.new(hitboxSize, hitboxSize, hitboxSize)
                            hrp.Transparency = 1
                            hrp.Shape = Enum.PartType.Block 
                            hrp.CanCollide = false
                        end
                    end
                end
            end
        end
        task.wait(5)
    end
end)

WindUI:Notify({ Title = "Night-fall Hub", Content = "Hub Carregado com Sucesso!", Duration = 4 })
