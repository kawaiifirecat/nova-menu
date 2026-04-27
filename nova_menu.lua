-- ====================================================
--   NOVA MENU  |  Dark Violet Edition
--   loadstring(game:HttpGet('RAW_URL'))()
-- ====================================================

local Players         = game:GetService("Players")
local TweenService    = game:GetService("TweenService")
local UserInputService= game:GetService("UserInputService")
local RunService      = game:GetService("RunService")

local LP   = Players.LocalPlayer
local Mouse = LP:GetMouse()

-- Cleanup si déjà chargé
if game.CoreGui:FindFirstChild("NOVA_MENU") then
    game.CoreGui.NOVA_MENU:Destroy()
end

-- ====================================================
--   PALETTE
-- ====================================================
local C = {
    BG      = Color3.fromRGB(8,   8,  18),
    BG2     = Color3.fromRGB(14,  14, 28),
    BG3     = Color3.fromRGB(22,  20, 42),
    ACCENT  = Color3.fromRGB(120,  55, 255),
    ACCENT2 = Color3.fromRGB(180,  80, 255),
    PINK    = Color3.fromRGB(220,  75, 200),
    TEXT    = Color3.fromRGB(230, 225, 245),
    SUB     = Color3.fromRGB(120, 110, 155),
    GREEN   = Color3.fromRGB( 70, 220, 130),
    RED     = Color3.fromRGB(220,  70,  80),
    YELLOW  = Color3.fromRGB(255, 200,  55),
}

local FB = Enum.Font.GothamBold
local FS = Enum.Font.GothamSemibold
local FR = Enum.Font.Gotham

local function tw(obj, props, info)
    TweenService:Create(obj, info or TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props):Play()
end
local function corner(p, r)  local c=Instance.new("UICorner",p); c.CornerRadius=UDim.new(0,r or 10); return c end
local function uistroke(p,col,th) local s=Instance.new("UIStroke",p); s.Color=col; s.Thickness=th or 1.5; s.ApplyStrokeMode=Enum.ApplyStrokeMode.Border; return s end

-- ====================================================
--   GUI ROOT
-- ====================================================
local Gui = Instance.new("ScreenGui")
Gui.Name = "NOVA_MENU"
Gui.ResetOnSpawn = false
Gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
Gui.Parent = game.CoreGui

-- ====================================================
--   SYSTÈME DE NOTIFICATIONS
-- ====================================================
local NHolder = Instance.new("Frame", Gui)
NHolder.Size = UDim2.new(0, 265, 1, 0)
NHolder.Position = UDim2.new(1, -275, 0, 0)
NHolder.BackgroundTransparency = 1
NHolder.BorderSizePixel = 0
local NLayout = Instance.new("UIListLayout", NHolder)
NLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
NLayout.Padding = UDim.new(0, 6)
local NPad = Instance.new("UIPadding", NHolder)
NPad.PaddingBottom = UDim.new(0, 14)

local function notify(title, msg, ntype)
    local col = ntype == "success" and C.GREEN or ntype == "error" and C.RED or C.ACCENT
    local n = Instance.new("Frame", NHolder)
    n.Size = UDim2.new(1, 0, 0, 58)
    n.BackgroundColor3 = C.BG2
    n.BorderSizePixel = 0
    n.BackgroundTransparency = 1
    corner(n, 9)
    uistroke(n, col, 1.5)

    local bar = Instance.new("Frame", n)
    bar.Size = UDim2.new(0, 3, 1, -14); bar.Position = UDim2.new(0, 8, 0, 7)
    bar.BackgroundColor3 = col; bar.BorderSizePixel = 0; corner(bar, 2)

    local t = Instance.new("TextLabel", n)
    t.Size = UDim2.new(1,-26,0,16); t.Position = UDim2.new(0,18,0,8)
    t.BackgroundTransparency=1; t.Text=title; t.TextSize=12; t.Font=FB
    t.TextColor3=col; t.TextXAlignment=Enum.TextXAlignment.Left

    local m = Instance.new("TextLabel", n)
    m.Size = UDim2.new(1,-26,0,24); m.Position = UDim2.new(0,18,0,26)
    m.BackgroundTransparency=1; m.Text=msg; m.TextSize=11; m.Font=FR
    m.TextColor3=C.SUB; m.TextXAlignment=Enum.TextXAlignment.Left; m.TextWrapped=true

    tw(n, {BackgroundTransparency = 0})
    task.delay(3.2, function()
        tw(n, {BackgroundTransparency = 1})
        task.wait(0.22); n:Destroy()
    end)
end

-- ====================================================
--   CADRE PRINCIPAL
-- ====================================================
local Main = Instance.new("Frame", Gui)
Main.Name = "Main"
Main.Size = UDim2.new(0, 345, 0, 468)
Main.Position = UDim2.new(0.5, -172, 1.5, 0)
Main.BackgroundColor3 = C.BG
Main.BorderSizePixel = 0
corner(Main, 14)
uistroke(Main, C.ACCENT, 1.5)

local grad = Instance.new("UIGradient", Main)
grad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, C.BG),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(10, 6, 26)),
})
grad.Rotation = 135

-- ====================================================
--   TOP BAR
-- ====================================================
local TopBar = Instance.new("Frame", Main)
TopBar.Size = UDim2.new(1, 0, 0, 44)
TopBar.BackgroundColor3 = C.BG2
TopBar.BorderSizePixel = 0
corner(TopBar, 14)

-- fix coins bas topbar
local TBFix = Instance.new("Frame", TopBar)
TBFix.Size = UDim2.new(1, 0, 0.5, 0); TBFix.Position = UDim2.new(0,0,0.5,0)
TBFix.BackgroundColor3 = C.BG2; TBFix.BorderSizePixel = 0

-- ligne accent dégradée
local AccLine = Instance.new("Frame", Main)
AccLine.Size = UDim2.new(1,-40,0,1); AccLine.Position = UDim2.new(0,20,0,44)
AccLine.BackgroundColor3 = C.ACCENT; AccLine.BorderSizePixel = 0
local alGrad = Instance.new("UIGradient", AccLine)
alGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, C.BG),
    ColorSequenceKeypoint.new(0.25, C.ACCENT),
    ColorSequenceKeypoint.new(0.75, C.ACCENT2),
    ColorSequenceKeypoint.new(1, C.BG),
})

-- Titre avec gradient
local TitleLbl = Instance.new("TextLabel", TopBar)
TitleLbl.Size = UDim2.new(1,-82,1,0); TitleLbl.Position = UDim2.new(0,14,0,0)
TitleLbl.BackgroundTransparency=1; TitleLbl.Text="✦  NOVA  MENU"
TitleLbl.TextSize=15; TitleLbl.Font=FB; TitleLbl.TextColor3=C.TEXT
TitleLbl.TextXAlignment=Enum.TextXAlignment.Left
local tGrad = Instance.new("UIGradient", TitleLbl)
tGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0,  C.ACCENT2),
    ColorSequenceKeypoint.new(0.5,C.TEXT),
    ColorSequenceKeypoint.new(1,  C.PINK),
})

-- Badge version
local VerBadge = Instance.new("TextLabel", TopBar)
VerBadge.Size = UDim2.new(0,28,0,14); VerBadge.Position = UDim2.new(0,128,0.5,-7)
VerBadge.BackgroundColor3 = C.ACCENT; VerBadge.Text="v1"
VerBadge.TextSize=9; VerBadge.Font=FB; VerBadge.TextColor3=C.TEXT
VerBadge.BorderSizePixel=0; corner(VerBadge,4)

-- Bouton minimiser
local MinBtn = Instance.new("TextButton", TopBar)
MinBtn.Size = UDim2.new(0,28,0,28); MinBtn.Position = UDim2.new(1,-66,0.5,-14)
MinBtn.BackgroundColor3 = C.BG3; MinBtn.Text="—"
MinBtn.TextColor3=C.SUB; MinBtn.TextSize=12; MinBtn.Font=FB
MinBtn.BorderSizePixel=0; corner(MinBtn,6)

-- Bouton fermer
local CloseBtn = Instance.new("TextButton", TopBar)
CloseBtn.Size = UDim2.new(0,28,0,28); CloseBtn.Position = UDim2.new(1,-34,0.5,-14)
CloseBtn.BackgroundColor3 = Color3.fromRGB(175,35,55); CloseBtn.Text="✕"
CloseBtn.TextColor3=C.TEXT; CloseBtn.TextSize=12; CloseBtn.Font=FB
CloseBtn.BorderSizePixel=0; corner(CloseBtn,6)

CloseBtn.MouseButton1Click:Connect(function()
    tw(Main, {Position=UDim2.new(0.5,-172,1.5,0)}, TweenInfo.new(0.3,Enum.EasingStyle.Back,Enum.EasingDirection.In))
    task.wait(0.35); Gui:Destroy()
end)

local minimized = false
MinBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    tw(Main, {Size = minimized and UDim2.new(0,345,0,44) or UDim2.new(0,345,0,468)})
    MinBtn.Text = minimized and "□" or "—"
end)

-- ====================================================
--   INFOS JOUEUR
-- ====================================================
local PIFrame = Instance.new("Frame", Main)
PIFrame.Size=UDim2.new(1,-20,0,36); PIFrame.Position=UDim2.new(0,10,0,52)
PIFrame.BackgroundColor3=C.BG2; PIFrame.BorderSizePixel=0; corner(PIFrame,8)

local PIName = Instance.new("TextLabel", PIFrame)
PIName.Size=UDim2.new(0.62,0,1,0); PIName.Position=UDim2.new(0,12,0,0)
PIName.BackgroundTransparency=1; PIName.Text="👤  "..LP.Name
PIName.TextSize=12; PIName.Font=FS; PIName.TextColor3=C.TEXT
PIName.TextXAlignment=Enum.TextXAlignment.Left

local PIStatus = Instance.new("TextLabel", PIFrame)
PIStatus.Size=UDim2.new(0.38,-8,1,0); PIStatus.Position=UDim2.new(0.62,0,0,0)
PIStatus.BackgroundTransparency=1; PIStatus.Text="● ACTIF"
PIStatus.TextSize=11; PIStatus.Font=FB; PIStatus.TextColor3=C.GREEN
PIStatus.TextXAlignment=Enum.TextXAlignment.Right

-- ====================================================
--   BARRE D'ONGLETS
-- ====================================================
local TabBar = Instance.new("Frame", Main)
TabBar.Size=UDim2.new(1,-20,0,32); TabBar.Position=UDim2.new(0,10,0,96)
TabBar.BackgroundColor3=C.BG2; TabBar.BorderSizePixel=0; corner(TabBar,8)
local TabLayout = Instance.new("UIListLayout", TabBar)
TabLayout.FillDirection=Enum.FillDirection.Horizontal
TabLayout.Padding=UDim.new(0,3); TabLayout.SortOrder=Enum.SortOrder.LayoutOrder
local TabPad = Instance.new("UIPadding", TabBar)
TabPad.PaddingLeft=UDim.new(0,4); TabPad.PaddingRight=UDim.new(0,4)
TabPad.PaddingTop=UDim.new(0,4);  TabPad.PaddingBottom=UDim.new(0,4)

-- Zone de scroll
local Scroll = Instance.new("ScrollingFrame", Main)
Scroll.Size=UDim2.new(1,-20,1,-148); Scroll.Position=UDim2.new(0,10,0,136)
Scroll.BackgroundTransparency=1; Scroll.BorderSizePixel=0
Scroll.ScrollBarThickness=3; Scroll.ScrollBarImageColor3=C.ACCENT
Scroll.CanvasSize=UDim2.new(0,0,0,0); Scroll.AutomaticCanvasSize=Enum.AutomaticSize.Y
local ScrollLayout = Instance.new("UIListLayout", Scroll)
ScrollLayout.Padding=UDim.new(0,5); ScrollLayout.SortOrder=Enum.SortOrder.LayoutOrder

-- ====================================================
--   FACTORY ONGLETS
-- ====================================================
local tabs = {}

local function newTab(name, emoji)
    local Btn = Instance.new("TextButton", TabBar)
    Btn.Size=UDim2.new(0,78,1,0)
    Btn.BackgroundColor3=C.BG3; Btn.Text=emoji.." "..name
    Btn.TextSize=11; Btn.Font=FS; Btn.TextColor3=C.SUB
    Btn.BorderSizePixel=0; corner(Btn,6)

    local Container = Instance.new("Frame", Scroll)
    Container.Size=UDim2.new(1,0,1,0); Container.BackgroundTransparency=1; Container.Visible=false
    local CL = Instance.new("UIListLayout", Container)
    CL.Padding=UDim.new(0,5); CL.SortOrder=Enum.SortOrder.LayoutOrder

    local tab = {btn=Btn, cont=Container}
    tabs[name] = tab

    Btn.MouseButton1Click:Connect(function()
        for _, t in pairs(tabs) do
            t.cont.Visible=false
            tw(t.btn, {BackgroundColor3=C.BG3, TextColor3=C.SUB})
        end
        Container.Visible=true
        tw(Btn, {BackgroundColor3=C.ACCENT, TextColor3=C.TEXT})
    end)
    return tab
end

-- ====================================================
--   FACTORY SECTION HEADER
-- ====================================================
local function newSection(tab, title, order)
    local F = Instance.new("Frame", tab.cont)
    F.Size=UDim2.new(1,0,0,24); F.BackgroundTransparency=1; F.LayoutOrder=order or 0

    local L = Instance.new("TextLabel", F)
    L.Size=UDim2.new(1,0,1,0); L.BackgroundTransparency=1
    L.Text="  "..string.upper(title); L.TextSize=10; L.Font=FB
    L.TextColor3=C.ACCENT; L.TextXAlignment=Enum.TextXAlignment.Left

    local Line = Instance.new("Frame", F)
    Line.Size=UDim2.new(1,-8,0,1); Line.Position=UDim2.new(0,4,1,-1)
    Line.BackgroundColor3=C.BG3; Line.BorderSizePixel=0
end

-- ====================================================
--   FACTORY TOGGLE
-- ====================================================
local function newToggle(tab, name, emoji, col, onOn, onOff, order)
    local on = false

    local Btn = Instance.new("TextButton", tab.cont)
    Btn.Size=UDim2.new(1,0,0,46); Btn.BackgroundColor3=C.BG2
    Btn.Text=""; Btn.BorderSizePixel=0; Btn.LayoutOrder=order or 0; corner(Btn,9)
    local BStroke = uistroke(Btn, C.BG3, 1.5)

    local Ico = Instance.new("TextLabel", Btn)
    Ico.Size=UDim2.new(0,34,1,0); Ico.Position=UDim2.new(0,7,0,0)
    Ico.BackgroundTransparency=1; Ico.Text=emoji; Ico.TextSize=19; Ico.Font=FR; Ico.TextColor3=col

    local Lbl = Instance.new("TextLabel", Btn)
    Lbl.Size=UDim2.new(1,-110,1,0); Lbl.Position=UDim2.new(0,44,0,0)
    Lbl.BackgroundTransparency=1; Lbl.Text=name
    Lbl.TextSize=13; Lbl.Font=FS; Lbl.TextColor3=C.TEXT
    Lbl.TextXAlignment=Enum.TextXAlignment.Left

    local Track = Instance.new("Frame", Btn)
    Track.Size=UDim2.new(0,34,0,18); Track.Position=UDim2.new(1,-44,0.5,-9)
    Track.BackgroundColor3=C.BG3; Track.BorderSizePixel=0; corner(Track,9)

    local Thumb = Instance.new("Frame", Track)
    Thumb.Size=UDim2.new(0,12,0,12); Thumb.Position=UDim2.new(0,3,0.5,-6)
    Thumb.BackgroundColor3=C.SUB; Thumb.BorderSizePixel=0; corner(Thumb,6)

    local SLbl = Instance.new("TextLabel", Btn)
    SLbl.Size=UDim2.new(0,28,0,14); SLbl.Position=UDim2.new(1,-80,0.5,-7)
    SLbl.BackgroundTransparency=1; SLbl.Text="OFF"; SLbl.TextSize=10; SLbl.Font=FB
    SLbl.TextColor3=C.SUB; SLbl.TextXAlignment=Enum.TextXAlignment.Center

    Btn.MouseEnter:Connect(function() if not on then tw(Btn,{BackgroundColor3=C.BG3}) end end)
    Btn.MouseLeave:Connect(function() if not on then tw(Btn,{BackgroundColor3=C.BG2}) end end)

    Btn.MouseButton1Click:Connect(function()
        on = not on
        if on then
            tw(Btn,   {BackgroundColor3=Color3.fromRGB(18,12,36)})
            tw(BStroke,{Color=col})
            tw(Track,  {BackgroundColor3=col})
            tw(Thumb,  {Position=UDim2.new(1,-15,0.5,-6), BackgroundColor3=C.TEXT})
            SLbl.Text="ON"; SLbl.TextColor3=col
            pcall(onOn)
            notify("✦ Activé", name, "success")
        else
            tw(Btn,   {BackgroundColor3=C.BG2})
            tw(BStroke,{Color=C.BG3})
            tw(Track,  {BackgroundColor3=C.BG3})
            tw(Thumb,  {Position=UDim2.new(0,3,0.5,-6), BackgroundColor3=C.SUB})
            SLbl.Text="OFF"; SLbl.TextColor3=C.SUB
            if onOff then pcall(onOff) end
            notify("✦ Désactivé", name, "error")
        end
    end)
    return Btn
end

-- ====================================================
--   FACTORY BOUTON ACTION
-- ====================================================
local function newButton(tab, name, emoji, col, action, order)
    local Btn = Instance.new("TextButton", tab.cont)
    Btn.Size=UDim2.new(1,0,0,46); Btn.BackgroundColor3=C.BG2
    Btn.Text=""; Btn.BorderSizePixel=0; Btn.LayoutOrder=order or 0; corner(Btn,9)
    uistroke(Btn, C.BG3, 1.5)

    local Ico = Instance.new("TextLabel", Btn)
    Ico.Size=UDim2.new(0,34,1,0); Ico.Position=UDim2.new(0,7,0,0)
    Ico.BackgroundTransparency=1; Ico.Text=emoji; Ico.TextSize=19; Ico.Font=FR; Ico.TextColor3=col

    local Lbl = Instance.new("TextLabel", Btn)
    Lbl.Size=UDim2.new(1,-60,1,0); Lbl.Position=UDim2.new(0,44,0,0)
    Lbl.BackgroundTransparency=1; Lbl.Text=name
    Lbl.TextSize=13; Lbl.Font=FS; Lbl.TextColor3=C.TEXT
    Lbl.TextXAlignment=Enum.TextXAlignment.Left

    local Arrow = Instance.new("TextLabel", Btn)
    Arrow.Size=UDim2.new(0,22,1,0); Arrow.Position=UDim2.new(1,-28,0,0)
    Arrow.BackgroundTransparency=1; Arrow.Text="›"; Arrow.TextSize=22
    Arrow.Font=FB; Arrow.TextColor3=C.SUB

    Btn.MouseEnter:Connect(function()
        tw(Btn,  {BackgroundColor3=C.BG3})
        tw(Lbl,  {TextColor3=col})
        tw(Arrow,{TextColor3=col})
    end)
    Btn.MouseLeave:Connect(function()
        tw(Btn,  {BackgroundColor3=C.BG2})
        tw(Lbl,  {TextColor3=C.TEXT})
        tw(Arrow,{TextColor3=C.SUB})
    end)
    Btn.MouseButton1Click:Connect(function()
        tw(Btn, {BackgroundColor3=col})
        task.wait(0.1)
        tw(Btn, {BackgroundColor3=C.BG2})
        pcall(action)
    end)
    return Btn
end

-- ====================================================
--   CREATION DES ONGLETS
-- ====================================================
local tabPlayer = newTab("Player",  "⚡")
local tabWorld  = newTab("World",   "🌍")
local tabMisc   = newTab("Misc",    "⚙️")

-- activer Player par défaut
tabPlayer.btn.BackgroundColor3 = C.ACCENT
tabPlayer.btn.TextColor3       = C.TEXT
tabPlayer.cont.Visible         = true

-- ====================================================
--   ÉTAT GLOBAL
-- ====================================================
local S = { noclip=false, infjump=false, autoheal=false }

-- ====================================================
--   TAB PLAYER
-- ====================================================
newSection(tabPlayer, "Mouvement", 1)

newToggle(tabPlayer,"Speed Hack  ×10","🚀",C.ACCENT, function()
    LP.Character.Humanoid.WalkSpeed = 160
end, function()
    LP.Character.Humanoid.WalkSpeed = 16
end, 2)

newToggle(tabPlayer,"Jump Power  ×5","⬆️",C.ACCENT2, function()
    LP.Character.Humanoid.JumpPower = 150
end, function()
    LP.Character.Humanoid.JumpPower = 50
end, 3)

newToggle(tabPlayer,"Infinite Jump","🌙",C.PINK, function()
    S.infjump = true
    UserInputService.JumpRequest:Connect(function()
        if S.infjump and LP.Character then
            LP.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end)
end, function()
    S.infjump = false
end, 4)

newToggle(tabPlayer,"No Clip","👻",Color3.fromRGB(140,90,255), function()
    S.noclip = true
end, function()
    S.noclip = false
    if LP.Character then
        for _,v in pairs(LP.Character:GetDescendants()) do
            if v:IsA("BasePart") then v.CanCollide = true end
        end
    end
end, 5)

newSection(tabPlayer, "Combat", 6)

newToggle(tabPlayer,"God Mode","🛡️",C.YELLOW, function()
    LP.Character.Humanoid.MaxHealth = math.huge
    LP.Character.Humanoid.Health = math.huge
end, function()
    LP.Character.Humanoid.MaxHealth = 100
    LP.Character.Humanoid.Health = 100
end, 7)

newToggle(tabPlayer,"Auto-Heal","💊",C.GREEN, function()
    S.autoheal = true
    task.spawn(function()
        while S.autoheal do
            if LP.Character then
                local h = LP.Character:FindFirstChildOfClass("Humanoid")
                if h then h.Health = h.MaxHealth end
            end
            task.wait(0.5)
        end
    end)
end, function()
    S.autoheal = false
end, 8)

newSection(tabPlayer, "Téléport", 9)

newButton(tabPlayer,"Téléport au Spawn","📍",C.PINK, function()
    LP.Character.HumanoidRootPart.CFrame = CFrame.new(0,10,0)
    notify("Téléporté !", "Au spawn (0, 10, 0)", "success")
end, 10)

-- ====================================================
--   TAB WORLD
-- ====================================================
newSection(tabWorld, "Éclairage", 1)

newButton(tabWorld,"Midi ☀️","☀️",C.YELLOW, function()
    game:GetService("Lighting").TimeOfDay = "12:00:00"
    notify("Heure", "Midi activé", "success")
end, 2)

newButton(tabWorld,"Minuit 🌑","🌑",C.ACCENT, function()
    game:GetService("Lighting").TimeOfDay = "00:00:00"
    notify("Heure", "Minuit activé", "success")
end, 3)

newButton(tabWorld,"Suppr. brouillard","🌤️",C.ACCENT2, function()
    local L = game:GetService("Lighting")
    L.FogEnd = 1e6; L.FogStart = 1e6
    notify("Météo", "Brouillard effacé", "success")
end, 4)

newSection(tabWorld, "Gravité", 5)

newButton(tabWorld,"Lune  (20%)","🌕",Color3.fromRGB(200,200,255), function()
    game:GetService("Workspace").Gravity = 38
    notify("Gravité", "Mode Lune !", "success")
end, 6)

newButton(tabWorld,"Normale","🌍",C.GREEN, function()
    game:GetService("Workspace").Gravity = 196
    notify("Gravité", "Restaurée", "success")
end, 7)

newButton(tabWorld,"Zéro G","🪐",C.PINK, function()
    game:GetService("Workspace").Gravity = 0
    notify("Gravité", "Zéro G !", "success")
end, 8)

-- ====================================================
--   TAB MISC
-- ====================================================
newSection(tabMisc, "Utilitaires", 1)

newButton(tabMisc,"Recharger perso","🔄",C.ACCENT, function()
    LP:LoadCharacter()
    notify("Perso", "Rechargé", "success")
end, 2)

newButton(tabMisc,"Copier pseudo","📋",C.ACCENT2, function()
    pcall(setclipboard, LP.Name)
    notify("Copié !", LP.Name, "success")
end, 3)

newSection(tabMisc, "Danger Zone", 4)

newButton(tabMisc,"Rejoindre (rejoin)","🔁",C.YELLOW, function()
    game:GetService("TeleportService"):Teleport(game.PlaceId, LP)
end, 5)

newButton(tabMisc,"Fermer le menu","❌",C.RED, function()
    Gui:Destroy()
end, 6)

-- ====================================================
--   NOCLIP LOOP
-- ====================================================
RunService.Stepped:Connect(function()
    if S.noclip and LP.Character then
        for _,v in pairs(LP.Character:GetDescendants()) do
            if v:IsA("BasePart") then v.CanCollide = false end
        end
    end
end)

-- ====================================================
--   DRAG
-- ====================================================
local dragging, dragStart, startPos

TopBar.InputBegan:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true; dragStart = inp.Position; startPos = Main.Position
    end
end)
TopBar.InputEnded:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
end)
UserInputService.InputChanged:Connect(function(inp)
    if dragging and inp.UserInputType == Enum.UserInputType.MouseMovement then
        local d = inp.Position - dragStart
        Main.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + d.X,
            startPos.Y.Scale, startPos.Y.Offset + d.Y
        )
    end
end)

-- ====================================================
--   KEYBIND : INSERT → toggle visibilité
-- ====================================================
UserInputService.InputBegan:Connect(function(inp, gpe)
    if gpe then return end
    if inp.KeyCode == Enum.KeyCode.Insert then
        Main.Visible = not Main.Visible
    end
end)

-- ====================================================
--   ANIMATION D'OUVERTURE
-- ====================================================
tw(Main,
    {Position = UDim2.new(0.5,-172,0.5,-234)},
    TweenInfo.new(0.45, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
)

notify("NOVA MENU", "Chargé  ✦  INSERT = toggle", "success")
print("✦ NOVA MENU chargé | INSERT pour toggle")
