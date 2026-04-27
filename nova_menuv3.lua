-- ================================================================
--   NOVA MENU  v3  |  Ultimate Edition
--   loadstring(game:HttpGet('https://raw.githubusercontent.com/kawaiifirecat/nova-menu/main/nova_menu.lua'))()
-- ================================================================

local Players          = game:GetService("Players")
local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService       = game:GetService("RunService")
local Lighting         = game:GetService("Lighting")

local LP  = Players.LocalPlayer
local Cam = workspace.CurrentCamera

if game.CoreGui:FindFirstChild("NOVA_MENU") then
    game.CoreGui.NOVA_MENU:Destroy()
end

-- ================================================================
--   PALETTE & CONFIG
-- ================================================================
local C = {
    BG      = Color3.fromRGB(7,   7,  16),
    BG2     = Color3.fromRGB(13,  13, 26),
    BG3     = Color3.fromRGB(21,  19, 42),
    ACCENT  = Color3.fromRGB(110,  50, 245),
    ACCENT2 = Color3.fromRGB(168,  74, 255),
    PINK    = Color3.fromRGB(215,  68, 195),
    TEXT    = Color3.fromRGB(228, 222, 245),
    SUB     = Color3.fromRGB(112, 102, 148),
    GREEN   = Color3.fromRGB( 62, 212, 122),
    RED     = Color3.fromRGB(212,  62,  74),
    YELLOW  = Color3.fromRGB(250, 192,  48),
    ORANGE  = Color3.fromRGB(250, 138,  48),
    CYAN    = Color3.fromRGB( 48, 212, 220),
}

local FB = Enum.Font.GothamBold
local FS = Enum.Font.GothamSemibold
local FR = Enum.Font.Gotham
local FC = Enum.Font.Code

local TI_FAST  = TweenInfo.new(0.15, Enum.EasingStyle.Quad,  Enum.EasingDirection.Out)
local TI_SLIDE = TweenInfo.new(0.32, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)

local W, H = 340, 490

-- ================================================================
--   STATE
-- ================================================================
local S = {
    noclip=false, infjump=false, fly=false,
    autoheal=false, god=false, esp=false,
    antiaafk=false, crosshair=false, fullbright=false,
}

-- ================================================================
--   KEYBIND REGISTRY
--   KB[actionId] = { kc = KeyCode|nil, fn = function }
-- ================================================================
local KB = {}

local function registerKeybind(id, fn)
    if not KB[id] then KB[id] = { kc = nil, fn = fn } end
    KB[id].fn = fn
end

local function setKeybind(id, kc)
    if KB[id] then KB[id].kc = kc end
end

-- ================================================================
--   PARAMS REGISTRY
--   PARAMS[id] = { value = v, min = n, max = n, label = s }
-- ================================================================
local PARAMS = {
    walkSpeed  = { value = 160, min = 20,  max = 500, label = "Walk Speed"   },
    jumpPower  = { value = 150, min = 50,  max = 500, label = "Jump Power"   },
    flySpeed   = { value = 50,  min = 10,  max = 300, label = "Fly Speed"    },
    healRate   = { value = 0.4, min = 0.1, max = 5,   label = "Heal Rate (s)"},
}

-- ================================================================
--   HELPERS
-- ================================================================
local function tw(o,p,i) TweenService:Create(o,i or TI_FAST,p):Play() end

local function corner(p,r)
    local c=Instance.new("UICorner",p); c.CornerRadius=UDim.new(0,r or 10); return c
end

local function mkstroke(p,col,th)
    local s=Instance.new("UIStroke",p)
    s.Color=col; s.Thickness=th or 1.5
    s.ApplyStrokeMode=Enum.ApplyStrokeMode.Border
    return s
end

local function mklabel(p,txt,sz,fnt,col,xa)
    local l=Instance.new("TextLabel",p)
    l.BackgroundTransparency=1; l.Text=txt; l.TextSize=sz or 12
    l.Font=fnt or FR; l.TextColor3=col or C.TEXT
    l.TextXAlignment=xa or Enum.TextXAlignment.Left
    l.Size=UDim2.new(1,0,1,0)
    return l
end

local function kbText(kc)
    if not kc then return "—" end
    return tostring(kc):match("KeyCode%.(.+)") or "?"
end

-- ================================================================
--   GUI ROOT
-- ================================================================
local Gui=Instance.new("ScreenGui")
Gui.Name="NOVA_MENU"; Gui.ResetOnSpawn=false
Gui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling
Gui.IgnoreGuiInset=true; Gui.Parent=game.CoreGui

-- ================================================================
--   TOAST NOTIFICATIONS
-- ================================================================
local NH=Instance.new("Frame",Gui)
NH.Size=UDim2.new(0,255,1,0)
NH.Position=UDim2.new(1,-265,0,0)
NH.BackgroundTransparency=1; NH.BorderSizePixel=0
local NL=Instance.new("UIListLayout",NH)
NL.VerticalAlignment=Enum.VerticalAlignment.Bottom; NL.Padding=UDim.new(0,5)
local NP=Instance.new("UIPadding",NH); NP.PaddingBottom=UDim.new(0,75)

local function notify(title,msg,ntype)
    local col=({on=C.GREEN,off=C.RED,warn=C.YELLOW})[ntype] or C.ACCENT
    local n=Instance.new("Frame",NH)
    n.Size=UDim2.new(1,0,0,52); n.BackgroundColor3=C.BG2
    n.BorderSizePixel=0; n.BackgroundTransparency=1
    corner(n,8); mkstroke(n,col,1.5)
    local bar=Instance.new("Frame",n)
    bar.Size=UDim2.new(0,3,1,-12); bar.Position=UDim2.new(0,7,0,6)
    bar.BackgroundColor3=col; bar.BorderSizePixel=0; corner(bar,2)
    local t=mklabel(n,title,11,FB,col)
    t.Size=UDim2.new(1,-22,0,14); t.Position=UDim2.new(0,16,0,6)
    local m=mklabel(n,msg,10,FR,C.SUB)
    m.Size=UDim2.new(1,-22,0,22); m.Position=UDim2.new(0,16,0,22); m.TextWrapped=true
    tw(n,{BackgroundTransparency=0})
    task.delay(3,function() tw(n,{BackgroundTransparency=1}); task.wait(0.2); n:Destroy() end)
end

-- ================================================================
--   KEYBIND PICKER OVERLAY
--   Affiché au-dessus de tout, attend une touche, la stocke
-- ================================================================
local PickerActive = false

local PickerOverlay = Instance.new("Frame", Gui)
PickerOverlay.Size = UDim2.new(1,0,1,0)
PickerOverlay.BackgroundColor3 = Color3.fromRGB(0,0,0)
PickerOverlay.BackgroundTransparency = 0.45
PickerOverlay.BorderSizePixel = 0
PickerOverlay.Visible = false
PickerOverlay.ZIndex = 50

local PickerBox = Instance.new("Frame", PickerOverlay)
PickerBox.Size = UDim2.new(0,260,0,96)
PickerBox.Position = UDim2.new(0.5,-130,0.5,-48)
PickerBox.BackgroundColor3 = C.BG2
PickerBox.BorderSizePixel = 0
PickerBox.ZIndex = 51
corner(PickerBox, 10); mkstroke(PickerBox, C.ACCENT, 1.5)

local PickerTitle = mklabel(PickerBox, "CHOISIR UNE TOUCHE", 12, FB, C.ACCENT2)
PickerTitle.Position = UDim2.new(0,16,0,10)
PickerTitle.Size = UDim2.new(1,-32,0,18)
PickerTitle.TextXAlignment = Enum.TextXAlignment.Center
PickerTitle.ZIndex = 52

local PickerSub = mklabel(PickerBox, "Appuie sur n'importe quelle touche\nESC = supprimer le raccourci", 10, FR, C.SUB)
PickerSub.Position = UDim2.new(0,16,0,32)
PickerSub.Size = UDim2.new(1,-32,0,36)
PickerSub.TextXAlignment = Enum.TextXAlignment.Center
PickerSub.TextWrapped = true
PickerSub.ZIndex = 52

local PickerCurrent = mklabel(PickerBox, "", 9, FR, C.SUB)
PickerCurrent.Position = UDim2.new(0,0,0,70)
PickerCurrent.Size = UDim2.new(1,0,0,18)
PickerCurrent.TextXAlignment = Enum.TextXAlignment.Center
PickerCurrent.ZIndex = 52

-- openPicker(actionId, kbLabel) → attend une touche, met à jour KB et le label UI
local function openPicker(id, kbLabelWidget)
    if PickerActive then return end
    PickerActive = true
    local cur = KB[id] and KB[id].kc
    PickerCurrent.Text = cur and ("Actuel : "..kbText(cur)) or "Pas de touche"
    PickerOverlay.Visible = true

    local conn
    conn = UserInputService.InputBegan:Connect(function(inp, gpe)
        if gpe then return end
        conn:Disconnect()
        PickerOverlay.Visible = false
        PickerActive = false

        if inp.KeyCode == Enum.KeyCode.Escape then
            setKeybind(id, nil)
            if kbLabelWidget then kbLabelWidget.Text = "—" end
            notify("TOUCHE","Raccourci supprimé","warn")
        else
            setKeybind(id, inp.KeyCode)
            if kbLabelWidget then kbLabelWidget.Text = kbText(inp.KeyCode) end
            notify("TOUCHE","["..kbText(inp.KeyCode).."] assigné","on")
        end
    end)
end

-- ================================================================
--   PARAM EDITOR OVERLAY
--   Slider simple pour modifier un PARAM en live
-- ================================================================
local ParamOverlay = Instance.new("Frame", Gui)
ParamOverlay.Size = UDim2.new(1,0,1,0)
ParamOverlay.BackgroundColor3 = Color3.fromRGB(0,0,0)
ParamOverlay.BackgroundTransparency = 0.45
ParamOverlay.BorderSizePixel = 0
ParamOverlay.Visible = false
ParamOverlay.ZIndex = 50

local ParamBox = Instance.new("Frame", ParamOverlay)
ParamBox.Size = UDim2.new(0,280,0,120)
ParamBox.Position = UDim2.new(0.5,-140,0.5,-60)
ParamBox.BackgroundColor3 = C.BG2
ParamBox.BorderSizePixel = 0
ParamBox.ZIndex = 51
corner(ParamBox, 10); mkstroke(ParamBox, C.CYAN, 1.5)

local ParamTitle = mklabel(ParamBox, "PARAMÈTRE", 12, FB, C.CYAN)
ParamTitle.Position = UDim2.new(0,16,0,10)
ParamTitle.Size = UDim2.new(1,-32,0,16)
ParamTitle.TextXAlignment = Enum.TextXAlignment.Center
ParamTitle.ZIndex = 52

local ParamValLbl = mklabel(ParamBox, "0", 14, FB, C.TEXT)
ParamValLbl.Position = UDim2.new(0,0,0,32)
ParamValLbl.Size = UDim2.new(1,0,0,20)
ParamValLbl.TextXAlignment = Enum.TextXAlignment.Center
ParamValLbl.ZIndex = 52

-- Slider track
local SliderTrack = Instance.new("Frame", ParamBox)
SliderTrack.Size = UDim2.new(1,-32,0,8)
SliderTrack.Position = UDim2.new(0,16,0,60)
SliderTrack.BackgroundColor3 = C.BG3
SliderTrack.BorderSizePixel = 0
SliderTrack.ZIndex = 52
corner(SliderTrack, 4)
mkstroke(SliderTrack, C.BG3, 1)

local SliderFill = Instance.new("Frame", SliderTrack)
SliderFill.Size = UDim2.new(0.5,0,1,0)
SliderFill.BackgroundColor3 = C.CYAN
SliderFill.BorderSizePixel = 0
SliderFill.ZIndex = 53
corner(SliderFill, 4)

local SliderKnob = Instance.new("Frame", SliderTrack)
SliderKnob.Size = UDim2.new(0,14,0,14)
SliderKnob.Position = UDim2.new(0.5,-7,0.5,-7)
SliderKnob.BackgroundColor3 = C.TEXT
SliderKnob.BorderSizePixel = 0
SliderKnob.ZIndex = 54
corner(SliderKnob, 7)

local ParamCloseBtn = Instance.new("TextButton", ParamBox)
ParamCloseBtn.Size = UDim2.new(1,-32,0,22)
ParamCloseBtn.Position = UDim2.new(0,16,0,86)
ParamCloseBtn.BackgroundColor3 = C.ACCENT
ParamCloseBtn.Text = "CONFIRMER"
ParamCloseBtn.TextSize = 10
ParamCloseBtn.Font = FB
ParamCloseBtn.TextColor3 = C.TEXT
ParamCloseBtn.BorderSizePixel = 0
ParamCloseBtn.ZIndex = 52
corner(ParamCloseBtn, 5)

local _currentParamId = nil
local _sliderDragging = false

local function updateSliderDisplay(id)
    local p = PARAMS[id]
    if not p then return end
    local ratio = (p.value - p.min) / (p.max - p.min)
    ratio = math.clamp(ratio, 0, 1)
    SliderFill.Size = UDim2.new(ratio, 0, 1, 0)
    SliderKnob.Position = UDim2.new(ratio, -7, 0.5, -7)
    ParamValLbl.Text = tostring(math.floor(p.value * 100) / 100)
end

local function openParamEditor(id, valLblWidget)
    _currentParamId = id
    local p = PARAMS[id]
    if not p then return end
    ParamTitle.Text = string.upper(p.label)
    updateSliderDisplay(id)
    ParamOverlay.Visible = true

    -- Slider drag
    local function sliderInput(input)
        if not _sliderDragging then return end
        local absPos = SliderTrack.AbsolutePosition
        local absSize = SliderTrack.AbsoluteSize
        local ratio = math.clamp((input.Position.X - absPos.X) / absSize.X, 0, 1)
        p.value = p.min + (p.max - p.min) * ratio
        updateSliderDisplay(id)
        if valLblWidget then
            valLblWidget.Text = tostring(math.floor(p.value * 100) / 100)
        end
    end

    SliderTrack.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            _sliderDragging = true; sliderInput(i)
        end
    end)
    SliderTrack.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then _sliderDragging = false end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if _sliderDragging and i.UserInputType == Enum.UserInputType.MouseMovement then
            sliderInput(i)
        end
    end)
end

ParamCloseBtn.MouseButton1Click:Connect(function()
    ParamOverlay.Visible = false
    _currentParamId = nil
    _sliderDragging = false
end)

-- ================================================================
--   HUD — ACTIVE FEATURES
-- ================================================================
local HUD=Instance.new("Frame",Gui)
HUD.Name="HUD"; HUD.Size=UDim2.new(0,175,0,28)
HUD.Position=UDim2.new(0,10,1,-46)
HUD.BackgroundColor3=C.BG2; HUD.BorderSizePixel=0
HUD.AutomaticSize=Enum.AutomaticSize.Y
corner(HUD,8); mkstroke(HUD,C.ACCENT,1)

local HTop=Instance.new("Frame",HUD)
HTop.Size=UDim2.new(1,0,0,22); HTop.BackgroundColor3=C.BG3
HTop.BorderSizePixel=0; corner(HTop,8)
do local f=Instance.new("Frame",HTop); f.Size=UDim2.new(1,0,0.5,0)
   f.Position=UDim2.new(0,0,0.5,0); f.BackgroundColor3=C.BG3; f.BorderSizePixel=0 end
local HTitle=mklabel(HTop,"◆  ACTIVE FEATURES",9,FB,C.ACCENT)
HTitle.Position=UDim2.new(0,8,0,0)

local HList=Instance.new("Frame",HUD)
HList.Size=UDim2.new(1,-12,0,0); HList.Position=UDim2.new(0,6,0,26)
HList.BackgroundTransparency=1; HList.BorderSizePixel=0
HList.AutomaticSize=Enum.AutomaticSize.Y
local HLL=Instance.new("UIListLayout",HList)
HLL.Padding=UDim.new(0,2); HLL.SortOrder=Enum.SortOrder.LayoutOrder
local HP=Instance.new("UIPadding",HList); HP.PaddingBottom=UDim.new(0,6)

local HEntries={}
local function hudOn(key,name,col)
    if HEntries[key] then return end
    local row=Instance.new("Frame",HList)
    row.Size=UDim2.new(1,0,0,15); row.BackgroundTransparency=1; row.BorderSizePixel=0
    local dot=Instance.new("Frame",row)
    dot.Size=UDim2.new(0,6,0,6); dot.Position=UDim2.new(0,0,0.5,-3)
    dot.BackgroundColor3=col; dot.BorderSizePixel=0; corner(dot,3)
    local l=mklabel(row,name,10,FS,C.TEXT)
    l.Position=UDim2.new(0,10,0,0); l.Size=UDim2.new(1,-10,1,0)
    HEntries[key]=row
end
local function hudOff(key)
    if HEntries[key] then HEntries[key]:Destroy(); HEntries[key]=nil end
end

-- HUD drag
do local drag,ds,sp=false
    HTop.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 then
            drag=true; ds=i.Position; sp=HUD.Position end end)
    HTop.InputEnded:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 then drag=false end end)
    UserInputService.InputChanged:Connect(function(i)
        if drag and i.UserInputType==Enum.UserInputType.MouseMovement then
            local d=i.Position-ds
            HUD.Position=UDim2.new(sp.X.Scale,sp.X.Offset+d.X,sp.Y.Scale,sp.Y.Offset+d.Y) end end)
end

-- ================================================================
--   SIDEBAR TAB
-- ================================================================
local SideTab=Instance.new("TextButton",Gui)
SideTab.Size=UDim2.new(0,32,0,108)
SideTab.Position=UDim2.new(1,-32,0.5,-54)
SideTab.BackgroundColor3=C.BG2; SideTab.Text=""
SideTab.BorderSizePixel=0; SideTab.ZIndex=10
corner(SideTab,8); mkstroke(SideTab,C.ACCENT,1.5)

local SideLbl=Instance.new("TextLabel",SideTab)
SideLbl.Size=UDim2.new(1,0,1,-18); SideLbl.Position=UDim2.new(0,0,0,4)
SideLbl.BackgroundTransparency=1; SideLbl.Text="N\nO\nV\nA"
SideLbl.TextSize=10; SideLbl.Font=FB; SideLbl.TextColor3=C.ACCENT2
SideLbl.TextXAlignment=Enum.TextXAlignment.Center

local SideArr=Instance.new("TextLabel",SideTab)
SideArr.Size=UDim2.new(1,0,0,16); SideArr.Position=UDim2.new(0,0,1,-18)
SideArr.BackgroundTransparency=1; SideArr.Text="‹"
SideArr.TextSize=16; SideArr.Font=FB; SideArr.TextColor3=C.SUB
SideArr.TextXAlignment=Enum.TextXAlignment.Center

SideTab.MouseEnter:Connect(function() tw(SideTab,{BackgroundColor3=C.BG3}) end)
SideTab.MouseLeave:Connect(function() tw(SideTab,{BackgroundColor3=C.BG2}) end)

-- ================================================================
--   MAIN PANEL
-- ================================================================
local Main=Instance.new("Frame",Gui)
Main.Name="Main"; Main.Size=UDim2.new(0,W,0,H)
Main.BackgroundColor3=C.BG; Main.BorderSizePixel=0
corner(Main,12); mkstroke(Main,C.ACCENT,1.5)
local mGrad=Instance.new("UIGradient",Main)
mGrad.Color=ColorSequence.new({
    ColorSequenceKeypoint.new(0,C.BG),
    ColorSequenceKeypoint.new(1,Color3.fromRGB(9,6,22)),
}); mGrad.Rotation=138

local POS_HIDE = UDim2.new(1,10,0.5,-(H/2))
local POS_SHOW = UDim2.new(1,-(W+38),0.5,-(H/2))
Main.Position = POS_HIDE

local menuOpen=false
local function toggleMenu()
    menuOpen=not menuOpen
    if menuOpen then
        tw(Main,{Position=POS_SHOW},TI_SLIDE)
        SideArr.Text="›"; tw(SideArr,{TextColor3=C.ACCENT})
    else
        tw(Main,{Position=POS_HIDE},TI_SLIDE)
        SideArr.Text="‹"; tw(SideArr,{TextColor3=C.SUB})
    end
end
SideTab.MouseButton1Click:Connect(toggleMenu)

-- ================================================================
--   TOPBAR
-- ================================================================
local TopBar=Instance.new("Frame",Main)
TopBar.Size=UDim2.new(1,0,0,40); TopBar.BackgroundColor3=C.BG2
TopBar.BorderSizePixel=0; corner(TopBar,12)
do local f=Instance.new("Frame",TopBar); f.Size=UDim2.new(1,0,0.5,0)
   f.Position=UDim2.new(0,0,0.5,0); f.BackgroundColor3=C.BG2; f.BorderSizePixel=0 end

local AccLine=Instance.new("Frame",Main)
AccLine.Size=UDim2.new(1,-32,0,1); AccLine.Position=UDim2.new(0,16,0,40)
AccLine.BackgroundColor3=C.ACCENT; AccLine.BorderSizePixel=0
local alG=Instance.new("UIGradient",AccLine)
alG.Color=ColorSequence.new({
    ColorSequenceKeypoint.new(0,C.BG),
    ColorSequenceKeypoint.new(0.3,C.ACCENT),
    ColorSequenceKeypoint.new(0.7,C.ACCENT2),
    ColorSequenceKeypoint.new(1,C.BG),
})

local TitleLbl=mklabel(TopBar,"✦  NOVA  MENU",14,FB,C.TEXT)
TitleLbl.Size=UDim2.new(1,-72,1,0); TitleLbl.Position=UDim2.new(0,12,0,0)
local tGrd=Instance.new("UIGradient",TitleLbl)
tGrd.Color=ColorSequence.new({
    ColorSequenceKeypoint.new(0,C.ACCENT2),
    ColorSequenceKeypoint.new(0.5,C.TEXT),
    ColorSequenceKeypoint.new(1,C.PINK),
})

local VerBadge=Instance.new("TextLabel",TopBar)
VerBadge.Size=UDim2.new(0,24,0,12); VerBadge.Position=UDim2.new(0,124,0.5,-6)
VerBadge.BackgroundColor3=C.ACCENT; VerBadge.Text="v3"; VerBadge.TextSize=8
VerBadge.Font=FB; VerBadge.TextColor3=C.TEXT; VerBadge.BorderSizePixel=0; corner(VerBadge,3)

local function mkTopBtn(x,txt,bg)
    local b=Instance.new("TextButton",TopBar)
    b.Size=UDim2.new(0,24,0,24); b.Position=UDim2.new(1,x,0.5,-12)
    b.BackgroundColor3=bg; b.Text=txt; b.TextColor3=C.TEXT
    b.TextSize=10; b.Font=FB; b.BorderSizePixel=0; corner(b,5)
    return b
end
local MinBtn   = mkTopBtn(-58,"—",C.BG3)
local CloseBtn = mkTopBtn(-30,"✕",Color3.fromRGB(168,30,50))

CloseBtn.MouseButton1Click:Connect(function()
    tw(Main,{Position=POS_HIDE},TI_SLIDE)
    menuOpen=false; SideArr.Text="‹"; tw(SideArr,{TextColor3=C.SUB})
end)

local mini=false
MinBtn.MouseButton1Click:Connect(function()
    mini=not mini
    tw(Main,{Size=mini and UDim2.new(0,W,0,40) or UDim2.new(0,W,0,H)})
    MinBtn.Text=mini and "□" or "—"
end)

-- ================================================================
--   PLAYER INFO BAR
-- ================================================================
local PIBar=Instance.new("Frame",Main)
PIBar.Size=UDim2.new(1,-18,0,28); PIBar.Position=UDim2.new(0,9,0,48)
PIBar.BackgroundColor3=C.BG2; PIBar.BorderSizePixel=0; corner(PIBar,6)
local piN=mklabel(PIBar,"◆  "..LP.Name,11,FS,C.TEXT)
piN.Position=UDim2.new(0,10,0,0); piN.Size=UDim2.new(0.58,0,1,0)
local piS=mklabel(PIBar,"● ONLINE",10,FB,C.GREEN)
piS.Position=UDim2.new(0.58,0,0,0); piS.Size=UDim2.new(0.42,-8,1,0)
piS.TextXAlignment=Enum.TextXAlignment.Right

-- ================================================================
--   TAB BAR
-- ================================================================
local TabBar=Instance.new("Frame",Main)
TabBar.Size=UDim2.new(1,-18,0,26); TabBar.Position=UDim2.new(0,9,0,84)
TabBar.BackgroundColor3=C.BG2; TabBar.BorderSizePixel=0; corner(TabBar,6)
local TBL=Instance.new("UIListLayout",TabBar)
TBL.FillDirection=Enum.FillDirection.Horizontal
TBL.Padding=UDim.new(0,2); TBL.SortOrder=Enum.SortOrder.LayoutOrder
local TBP=Instance.new("UIPadding",TabBar)
TBP.PaddingLeft=UDim.new(0,3); TBP.PaddingRight=UDim.new(0,3)
TBP.PaddingTop=UDim.new(0,3); TBP.PaddingBottom=UDim.new(0,3)

local ContentArea=Instance.new("Frame",Main)
ContentArea.Size=UDim2.new(1,-18,1,-122); ContentArea.Position=UDim2.new(0,9,0,118)
ContentArea.BackgroundTransparency=1; ContentArea.ClipsDescendants=true

-- ================================================================
--   TAB FACTORY
-- ================================================================
local tabs={}
local function newTab(name)
    local Btn=Instance.new("TextButton",TabBar)
    Btn.Size=UDim2.new(0.25,-2,1,0); Btn.BackgroundColor3=C.BG3
    Btn.Text=name; Btn.TextSize=9; Btn.Font=FS; Btn.TextColor3=C.SUB
    Btn.BorderSizePixel=0; corner(Btn,4)

    local Scroll=Instance.new("ScrollingFrame",ContentArea)
    Scroll.Size=UDim2.new(1,0,1,0); Scroll.BackgroundTransparency=1
    Scroll.BorderSizePixel=0; Scroll.ScrollBarThickness=3
    Scroll.ScrollBarImageColor3=C.ACCENT
    Scroll.CanvasSize=UDim2.new(0,0,0,0)
    Scroll.AutomaticCanvasSize=Enum.AutomaticSize.Y
    Scroll.Visible=false

    local SL=Instance.new("UIListLayout",Scroll)
    SL.Padding=UDim.new(0,4); SL.SortOrder=Enum.SortOrder.LayoutOrder

    local tab={btn=Btn,scroll=Scroll}
    tabs[name]=tab

    Btn.MouseButton1Click:Connect(function()
        for _,t in pairs(tabs) do
            t.scroll.Visible=false
            tw(t.btn,{BackgroundColor3=C.BG3,TextColor3=C.SUB})
        end
        Scroll.Visible=true
        tw(Btn,{BackgroundColor3=C.ACCENT,TextColor3=C.TEXT})
    end)
    return tab
end

-- ================================================================
--   WIDGET FACTORIES
-- ================================================================
local function newSection(tab,title,order)
    local F=Instance.new("Frame",tab.scroll)
    F.Size=UDim2.new(1,0,0,20); F.BackgroundTransparency=1; F.LayoutOrder=order or 0
    local L=mklabel(F,"  "..string.upper(title),9,FB,C.ACCENT)
    local Ln=Instance.new("Frame",F)
    Ln.Size=UDim2.new(1,-6,0,1); Ln.Position=UDim2.new(0,3,1,-1)
    Ln.BackgroundColor3=C.BG3; Ln.BorderSizePixel=0
end

-- ================================================================
--   newToggle v3 :
--     • bouton ⚙️ → ouvre le keybind picker
--     • paramId → si fourni, ajoute un bouton ◈ pour le paramètre
--     • aucun kc par défaut
-- ================================================================
local function newToggle(tab, name, col, hudKey, actionId, paramId, onOn, onOff, order)
    local on = false

    -- Registre l'action sans touche par défaut
    registerKeybind(actionId, function()
        -- sera rempli après
    end)

    local Btn=Instance.new("TextButton",tab.scroll)
    local rowH = paramId and 50 or 40
    Btn.Size=UDim2.new(1,0,0,rowH); Btn.BackgroundColor3=C.BG2
    Btn.Text=""; Btn.BorderSizePixel=0; Btn.LayoutOrder=order or 0; corner(Btn,8)
    local BS=mkstroke(Btn,C.BG3,1.5)

    local Lbl=mklabel(Btn,name,12,FS,C.TEXT)
    Lbl.Position=UDim2.new(0,10,0,paramId and 5 or 0)
    Lbl.Size=UDim2.new(1,-100,0,18)

    -- Badge raccourci
    local KBF=Instance.new("Frame",Btn)
    KBF.Size=UDim2.new(0,28,0,15); KBF.Position=UDim2.new(1,-72,0,paramId and 8 or 12)
    KBF.BackgroundColor3=C.BG3; KBF.BorderSizePixel=0; corner(KBF,3)
    local KBL=mklabel(KBF,"—",8,FB,C.SUB)
    KBL.TextXAlignment=Enum.TextXAlignment.Center

    -- Bouton ⚙️ (keybind)
    local GearBtn=Instance.new("TextButton",Btn)
    GearBtn.Size=UDim2.new(0,18,0,18)
    GearBtn.Position=UDim2.new(1,-20, 0, paramId and 7 or 11)
    GearBtn.BackgroundColor3=C.BG3; GearBtn.Text="⚙"
    GearBtn.TextSize=10; GearBtn.Font=FB; GearBtn.TextColor3=C.SUB
    GearBtn.BorderSizePixel=0; corner(GearBtn,4)
    GearBtn.ZIndex=5
    GearBtn.MouseButton1Click:Connect(function()
        openPicker(actionId, KBL)
    end)

    -- Toggle switch
    local Track=Instance.new("Frame",Btn)
    Track.Size=UDim2.new(0,30,0,15)
    Track.Position=UDim2.new(1,-42, 0, paramId and 8 or 12)
    Track.BackgroundColor3=C.BG3; Track.BorderSizePixel=0; corner(Track,8)
    local Thumb=Instance.new("Frame",Track)
    Thumb.Size=UDim2.new(0,11,0,11); Thumb.Position=UDim2.new(0,2,0.5,-5.5)
    Thumb.BackgroundColor3=C.SUB; Thumb.BorderSizePixel=0; corner(Thumb,6)

    -- Ligne paramètre (optionnelle)
    if paramId then
        local p = PARAMS[paramId]
        local ParamRow = Instance.new("Frame",Btn)
        ParamRow.Size=UDim2.new(1,-16,0,16); ParamRow.Position=UDim2.new(0,8,0,29)
        ParamRow.BackgroundColor3=C.BG3; ParamRow.BorderSizePixel=0; corner(ParamRow,4)

        local PL=mklabel(ParamRow, p.label.." :", 9, FR, C.SUB)
        PL.Position=UDim2.new(0,6,0,0); PL.Size=UDim2.new(0.6,0,1,0)

        local PVL=mklabel(ParamRow, tostring(p.value), 9, FB, C.CYAN)
        PVL.Position=UDim2.new(0.6,0,0,0); PVL.Size=UDim2.new(0.28,0,1,0)
        PVL.TextXAlignment=Enum.TextXAlignment.Right

        local EditBtn=Instance.new("TextButton",ParamRow)
        EditBtn.Size=UDim2.new(0,20,1,0); EditBtn.Position=UDim2.new(1,-22,0,0)
        EditBtn.BackgroundColor3=C.ACCENT; EditBtn.Text="◈"
        EditBtn.TextSize=9; EditBtn.Font=FB; EditBtn.TextColor3=C.TEXT
        EditBtn.BorderSizePixel=0; corner(EditBtn,3); EditBtn.ZIndex=5
        EditBtn.MouseButton1Click:Connect(function()
            openParamEditor(paramId, PVL)
        end)
    end

    -- Hover
    Btn.MouseEnter:Connect(function() if not on then tw(Btn,{BackgroundColor3=C.BG3}) end end)
    Btn.MouseLeave:Connect(function() if not on then tw(Btn,{BackgroundColor3=C.BG2}) end end)

    local function activate()
        on=true
        tw(Btn,{BackgroundColor3=Color3.fromRGB(15,9,30)})
        tw(BS,{Color=col}); tw(Lbl,{TextColor3=col})
        tw(Track,{BackgroundColor3=col})
        tw(Thumb,{Position=UDim2.new(1,-13,0.5,-5.5),BackgroundColor3=C.TEXT})
        pcall(onOn); hudOn(hudKey,name,col)
        notify("ACTIVÉ",name,"on")
    end
    local function deactivate()
        on=false
        tw(Btn,{BackgroundColor3=C.BG2})
        tw(BS,{Color=C.BG3}); tw(Lbl,{TextColor3=C.TEXT})
        tw(Track,{BackgroundColor3=C.BG3})
        tw(Thumb,{Position=UDim2.new(0,2,0.5,-5.5),BackgroundColor3=C.SUB})
        if onOff then pcall(onOff) end; hudOff(hudKey)
        notify("DÉSACTIVÉ",name,"off")
    end

    Btn.MouseButton1Click:Connect(function()
        if on then deactivate() else activate() end
    end)

    -- Mise à jour du fn dans KB
    KB[actionId] = KB[actionId] or { kc = nil }
    KB[actionId].fn = function()
        if on then deactivate() else activate() end
    end
end

-- ================================================================
--   newButton v3 : bouton ⚙️ pour keybind
-- ================================================================
local function newButton(tab, name, col, actionId, action, order)
    if actionId then
        registerKeybind(actionId, action)
    end

    local Btn=Instance.new("TextButton",tab.scroll)
    Btn.Size=UDim2.new(1,0,0,40); Btn.BackgroundColor3=C.BG2
    Btn.Text=""; Btn.BorderSizePixel=0; Btn.LayoutOrder=order or 0; corner(Btn,8)
    mkstroke(Btn,C.BG3,1.5)

    local Lbl=mklabel(Btn,name,12,FS,C.TEXT)
    Lbl.Position=UDim2.new(0,10,0,0); Lbl.Size=UDim2.new(1,-100,1,0)

    -- Badge raccourci
    local KBF=Instance.new("Frame",Btn)
    KBF.Size=UDim2.new(0,28,0,15); KBF.Position=UDim2.new(1,-72,0.5,-7.5)
    KBF.BackgroundColor3=C.BG3; KBF.BorderSizePixel=0; corner(KBF,3)
    local KBL=mklabel(KBF,"—",8,FB,C.SUB)
    KBL.TextXAlignment=Enum.TextXAlignment.Center

    -- Bouton ⚙️
    if actionId then
        local GearBtn=Instance.new("TextButton",Btn)
        GearBtn.Size=UDim2.new(0,18,0,18); GearBtn.Position=UDim2.new(1,-20,0.5,-9)
        GearBtn.BackgroundColor3=C.BG3; GearBtn.Text="⚙"
        GearBtn.TextSize=10; GearBtn.Font=FB; GearBtn.TextColor3=C.SUB
        GearBtn.BorderSizePixel=0; corner(GearBtn,4); GearBtn.ZIndex=5
        GearBtn.MouseButton1Click:Connect(function()
            openPicker(actionId, KBL)
        end)
    end

    local Arr=mklabel(Btn,"›",18,FB,C.SUB)
    Arr.Size=UDim2.new(0,16,1,0); Arr.Position=UDim2.new(1,-95,0,0)
    Arr.TextXAlignment=Enum.TextXAlignment.Center

    Btn.MouseEnter:Connect(function()
        tw(Btn,{BackgroundColor3=C.BG3}); tw(Lbl,{TextColor3=col}); tw(Arr,{TextColor3=col})
    end)
    Btn.MouseLeave:Connect(function()
        tw(Btn,{BackgroundColor3=C.BG2}); tw(Lbl,{TextColor3=C.TEXT}); tw(Arr,{TextColor3=C.SUB})
    end)
    Btn.MouseButton1Click:Connect(function()
        tw(Btn,{BackgroundColor3=col}); task.wait(0.09); tw(Btn,{BackgroundColor3=C.BG2})
        pcall(action)
    end)
end

-- ================================================================
--   newSliderParam : widget slider autonome dans un onglet
-- ================================================================
local function newSliderParam(tab, paramId, order)
    local p = PARAMS[paramId]
    if not p then return end

    local F=Instance.new("Frame",tab.scroll)
    F.Size=UDim2.new(1,0,0,56); F.BackgroundColor3=C.BG2
    F.BorderSizePixel=0; F.LayoutOrder=order or 0; corner(F,8)
    mkstroke(F,C.BG3,1.5)

    local Title=mklabel(F,p.label,11,FS,C.TEXT)
    Title.Position=UDim2.new(0,10,0,6); Title.Size=UDim2.new(0.6,0,0,16)

    local ValLbl=mklabel(F,tostring(p.value),11,FB,C.CYAN)
    ValLbl.Position=UDim2.new(0.6,0,0,6); ValLbl.Size=UDim2.new(0.4,-10,0,16)
    ValLbl.TextXAlignment=Enum.TextXAlignment.Right

    local Track=Instance.new("Frame",F)
    Track.Size=UDim2.new(1,-20,0,8); Track.Position=UDim2.new(0,10,0,30)
    Track.BackgroundColor3=C.BG3; Track.BorderSizePixel=0; corner(Track,4)

    local Fill=Instance.new("Frame",Track)
    local initRatio=(p.value-p.min)/(p.max-p.min)
    Fill.Size=UDim2.new(initRatio,0,1,0)
    Fill.BackgroundColor3=C.ACCENT; Fill.BorderSizePixel=0; corner(Fill,4)

    local Knob=Instance.new("Frame",Track)
    Knob.Size=UDim2.new(0,14,0,14); Knob.BackgroundColor3=C.TEXT
    Knob.Position=UDim2.new(initRatio,-7,0.5,-7)
    Knob.BorderSizePixel=0; corner(Knob,7)

    local dragging=false
    local function update(input)
        local ap=Track.AbsolutePosition; local as=Track.AbsoluteSize
        local ratio=math.clamp((input.Position.X-ap.X)/as.X,0,1)
        p.value=p.min+(p.max-p.min)*ratio
        Fill.Size=UDim2.new(ratio,0,1,0)
        Knob.Position=UDim2.new(ratio,-7,0.5,-7)
        ValLbl.Text=tostring(math.floor(p.value*100)/100)
    end

    Track.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 then dragging=true; update(i) end end)
    Track.InputEnded:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 then dragging=false end end)
    UserInputService.InputChanged:Connect(function(i)
        if dragging and i.UserInputType==Enum.UserInputType.MouseMovement then update(i) end end)
end

-- ================================================================
--   CREATE TABS
-- ================================================================
local tPlayer = newTab("PLAYER")
local tVisual = newTab("VISUAL")
local tWorld  = newTab("WORLD")
local tConfig = newTab("CONFIG")   -- nouvel onglet paramètres

tPlayer.btn.BackgroundColor3=C.ACCENT; tPlayer.btn.TextColor3=C.TEXT
tPlayer.scroll.Visible=true

-- ================================================================
--   TAB: PLAYER
-- ================================================================
newSection(tPlayer,"Mouvement",1)

newToggle(tPlayer,"Speed",C.ACCENT,"Speed","speed","walkSpeed",
function()
    if LP.Character then LP.Character.Humanoid.WalkSpeed=PARAMS.walkSpeed.value end
end,
function()
    if LP.Character then LP.Character.Humanoid.WalkSpeed=16 end
end, 2)

newToggle(tPlayer,"Jump Power",C.ACCENT2,"Jump","jump","jumpPower",
function()
    if LP.Character then LP.Character.Humanoid.JumpPower=PARAMS.jumpPower.value end
end,
function()
    if LP.Character then LP.Character.Humanoid.JumpPower=50 end
end, 3)

newToggle(tPlayer,"Infinite Jump",C.PINK,"InfJump","infjump",nil,function()
    S.infjump=true
    UserInputService.JumpRequest:Connect(function()
        if S.infjump and LP.Character then
            LP.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end)
end,function() S.infjump=false end, 4)

newToggle(tPlayer,"No Clip",Color3.fromRGB(138,82,255),"NoClip","noclip",nil,
function() S.noclip=true end,
function()
    S.noclip=false
    if LP.Character then
        for _,v in pairs(LP.Character:GetDescendants()) do
            if v:IsA("BasePart") then v.CanCollide=true end
        end
    end
end, 5)

newSection(tPlayer,"Vol",6)

local flyBV,flyBG,flyConn
newToggle(tPlayer,"Fly Mode",C.CYAN,"Fly","fly","flySpeed",function()
    S.fly=true
    local char=LP.Character; if not char then return end
    local hrp=char:FindFirstChild("HumanoidRootPart"); if not hrp then return end
    char.Humanoid.PlatformStand=true
    flyBV=Instance.new("BodyVelocity",hrp)
    flyBV.MaxForce=Vector3.new(1e9,1e9,1e9); flyBV.Velocity=Vector3.zero
    flyBG=Instance.new("BodyGyro",hrp)
    flyBG.MaxTorque=Vector3.new(1e9,1e9,1e9); flyBG.P=5e4; flyBG.CFrame=hrp.CFrame
    flyConn=RunService.Heartbeat:Connect(function()
        if not S.fly then return end
        local dir=Vector3.zero; local cf=Cam.CFrame
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir=dir+cf.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir=dir-cf.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir=dir-cf.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir=dir+cf.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir=dir+Vector3.new(0,1,0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then dir=dir-Vector3.new(0,1,0) end
        if dir.Magnitude>0 then dir=dir.Unit end
        flyBV.Velocity=dir*PARAMS.flySpeed.value; flyBG.CFrame=cf
    end)
end,function()
    S.fly=false
    if flyConn then flyConn:Disconnect(); flyConn=nil end
    if flyBV then flyBV:Destroy(); flyBV=nil end
    if flyBG then flyBG:Destroy(); flyBG=nil end
    if LP.Character then LP.Character.Humanoid.PlatformStand=false end
end, 7)

newSection(tPlayer,"Combat",8)

newToggle(tPlayer,"God Mode",C.YELLOW,"God","god",nil,function()
    S.god=true
    LP.Character.Humanoid.MaxHealth=math.huge
    LP.Character.Humanoid.Health=math.huge
end,function()
    S.god=false
    if LP.Character then
        LP.Character.Humanoid.MaxHealth=100
        LP.Character.Humanoid.Health=100
    end
end, 9)

newToggle(tPlayer,"Auto-Heal",C.GREEN,"AutoHeal","autoheal","healRate",function()
    S.autoheal=true
    task.spawn(function()
        while S.autoheal do
            if LP.Character then
                local h=LP.Character:FindFirstChildOfClass("Humanoid")
                if h then h.Health=h.MaxHealth end
            end
            task.wait(PARAMS.healRate.value)
        end
    end)
end,function() S.autoheal=false end, 10)

newSection(tPlayer,"Téléport",11)

newButton(tPlayer,"TP au Spawn",C.PINK,"tp_spawn",function()
    LP.Character.HumanoidRootPart.CFrame=CFrame.new(0,10,0)
    notify("TÉLÉPORTÉ","Spawn (0,10,0)","on")
end, 12)

newButton(tPlayer,"TP au Curseur",C.PINK,"tp_cursor",function()
    local m=LP:GetMouse()
    if m.Target then
        LP.Character.HumanoidRootPart.CFrame=CFrame.new(m.Hit.Position+Vector3.new(0,3,0))
        notify("TÉLÉPORTÉ","Position curseur","on")
    end
end, 13)

-- ================================================================
--   TAB: VISUAL
-- ================================================================
newSection(tVisual,"Rendu",1)

newToggle(tVisual,"Fullbright",C.YELLOW,"Fullbright","fullbright",nil,function()
    S.fullbright=true
    Lighting.Brightness=10; Lighting.ClockTime=14; Lighting.FogEnd=1e6
    Lighting.GlobalShadows=false
    Lighting.Ambient=Color3.new(1,1,1); Lighting.OutdoorAmbient=Color3.new(1,1,1)
end,function()
    S.fullbright=false
    Lighting.Brightness=1; Lighting.GlobalShadows=true
    Lighting.Ambient=Color3.fromRGB(127,127,127)
    Lighting.OutdoorAmbient=Color3.fromRGB(127,127,127)
end, 2)

newToggle(tVisual,"Crosshair",C.PINK,"Crosshair","crosshair",nil,function()
    S.crosshair=true
end,function()
    S.crosshair=false
end, 3)

local CHA=Instance.new("Frame",Gui); CHA.Size=UDim2.new(0,16,0,1.5)
CHA.Position=UDim2.new(0.5,-8,0.5,-0.75); CHA.BackgroundColor3=C.ACCENT2
CHA.BorderSizePixel=0; CHA.Visible=false
local CVA=Instance.new("Frame",Gui); CVA.Size=UDim2.new(0,1.5,0,16)
CVA.Position=UDim2.new(0.5,-0.75,0.5,-8); CVA.BackgroundColor3=C.ACCENT2
CVA.BorderSizePixel=0; CVA.Visible=false
RunService.RenderStepped:Connect(function()
    CHA.Visible=S.crosshair; CVA.Visible=S.crosshair
end)

newSection(tVisual,"ESP",4)

local espConns={}
newToggle(tVisual,"Player ESP",C.ACCENT2,"ESP","esp",nil,function()
    S.esp=true
    local function addESP(p)
        if p==LP then return end
        local function make()
            if not p.Character then return end
            local hrp=p.Character:FindFirstChild("HumanoidRootPart"); if not hrp then return end
            if hrp:FindFirstChild("NOVA_ESP") then return end
            local bb=Instance.new("BillboardGui",hrp); bb.Name="NOVA_ESP"
            bb.Size=UDim2.new(0,80,0,22); bb.StudsOffset=Vector3.new(0,3.5,0); bb.AlwaysOnTop=true
            local l=mklabel(bb,p.Name,12,FB,C.ACCENT2)
            l.TextXAlignment=Enum.TextXAlignment.Center; l.TextStrokeTransparency=0.3
        end
        make()
        espConns[p]=p.CharacterAdded:Connect(function() task.wait(0.5); make() end)
    end
    for _,p in pairs(Players:GetPlayers()) do addESP(p) end
    espConns.__added=Players.PlayerAdded:Connect(addESP)
end,function()
    S.esp=false
    for k,v in pairs(espConns) do
        if typeof(v)=="RBXScriptConnection" then v:Disconnect() end
        espConns[k]=nil
    end
    for _,p in pairs(Players:GetPlayers()) do
        if p.Character then
            local hrp=p.Character:FindFirstChild("HumanoidRootPart")
            if hrp then local b=hrp:FindFirstChild("NOVA_ESP"); if b then b:Destroy() end end
        end
    end
end, 5)

-- ================================================================
--   TAB: WORLD
-- ================================================================
newSection(tWorld,"Éclairage",1)

newButton(tWorld,"Midi",C.YELLOW,"world_noon",function()
    Lighting.TimeOfDay="12:00:00"; notify("MONDE","Midi","on")
end,2)
newButton(tWorld,"Minuit",C.ACCENT,"world_midnight",function()
    Lighting.TimeOfDay="00:00:00"; notify("MONDE","Minuit","on")
end,3)
newButton(tWorld,"Suppr. Brouillard",C.ACCENT2,"world_fog",function()
    Lighting.FogEnd=1e6; Lighting.FogStart=1e6; notify("MONDE","Brouillard supprimé","on")
end,4)

newSection(tWorld,"Gravité",5)

newButton(tWorld,"Lune  (20%)",Color3.fromRGB(195,185,255),"grav_moon",function()
    workspace.Gravity=38; notify("GRAVITÉ","Lune — 38","on")
end,6)
newButton(tWorld,"Normale",C.GREEN,"grav_norm",function()
    workspace.Gravity=196; notify("GRAVITÉ","Normale — 196","on")
end,7)
newButton(tWorld,"Zéro G",C.PINK,"grav_zero",function()
    workspace.Gravity=0; notify("GRAVITÉ","Zéro G","on")
end,8)
newButton(tWorld,"Super Heavy",C.ORANGE,"grav_heavy",function()
    workspace.Gravity=980; notify("GRAVITÉ","Super heavy — 980","on")
end,9)

-- Anti-AFK dans World
newSection(tWorld,"Utilitaires",10)

newToggle(tWorld,"Anti-AFK",C.GREEN,"AntiAFK","antiaafk",nil,function()
    S.antiaafk=true
    pcall(function()
        local VU=game:GetService("VirtualUser")
        LP.Idled:Connect(function()
            if S.antiaafk then VU:Button2Down(Vector2.zero,CFrame.new()) end
        end)
    end)
    task.spawn(function()
        while S.antiaafk do LP:Move(Vector3.zero); task.wait(55) end
    end)
end,function() S.antiaafk=false end, 11)

newButton(tWorld,"Copier pseudo",C.ACCENT,"copy_name",function()
    pcall(setclipboard,LP.Name); notify("COPIÉ",LP.Name,"on")
end,12)
newButton(tWorld,"Recharger perso",C.ACCENT2,"reload_char",function()
    LP:LoadCharacter(); notify("PERSO","Rechargé","on")
end,13)
newButton(tWorld,"Rejoin",C.YELLOW,"rejoin",function()
    game:GetService("TeleportService"):Teleport(game.PlaceId,LP)
end,14)

-- ================================================================
--   TAB: CONFIG — Sliders pour tous les paramètres
-- ================================================================
newSection(tConfig,"Paramètres",1)

newSliderParam(tConfig,"walkSpeed",2)
newSliderParam(tConfig,"jumpPower",3)
newSliderParam(tConfig,"flySpeed",4)
newSliderParam(tConfig,"healRate",5)

newSection(tConfig,"Exécuteur Lua",6)

local ExBg=Instance.new("Frame",tConfig.scroll)
ExBg.Size=UDim2.new(1,0,0,94); ExBg.BackgroundColor3=C.BG2
ExBg.BorderSizePixel=0; ExBg.LayoutOrder=7; corner(ExBg,8); mkstroke(ExBg,C.BG3,1.5)

local ExBox=Instance.new("TextBox",ExBg)
ExBox.Size=UDim2.new(1,-10,0,68); ExBox.Position=UDim2.new(0,5,0,4)
ExBox.BackgroundColor3=C.BG; ExBox.BorderSizePixel=0
ExBox.PlaceholderText="-- Lua ici"; ExBox.Text=""
ExBox.TextColor3=C.TEXT; ExBox.PlaceholderColor3=C.SUB
ExBox.TextSize=10; ExBox.Font=FC
ExBox.TextXAlignment=Enum.TextXAlignment.Left
ExBox.TextYAlignment=Enum.TextYAlignment.Top
ExBox.MultiLine=true; ExBox.ClearTextOnFocus=false; corner(ExBox,5)

local ExBtn=Instance.new("TextButton",ExBg)
ExBtn.Size=UDim2.new(1,-10,0,16); ExBtn.Position=UDim2.new(0,5,0,74)
ExBtn.BackgroundColor3=C.ACCENT; ExBtn.Text="EXÉCUTER"
ExBtn.TextSize=10; ExBtn.Font=FB; ExBtn.TextColor3=C.TEXT
ExBtn.BorderSizePixel=0; corner(ExBtn,4)
ExBtn.MouseButton1Click:Connect(function()
    local fn,err=loadstring(ExBox.Text)
    if fn then
        local ok,runErr=pcall(fn)
        if ok then notify("EXEC","Succès","on")
        else notify("EXEC ERREUR",tostring(runErr),"off") end
    else
        notify("COMPILE ERREUR",tostring(err),"off")
    end
end)

-- ================================================================
--   RUNTIME LOOP
-- ================================================================
RunService.Stepped:Connect(function()
    if S.noclip and LP.Character then
        for _,v in pairs(LP.Character:GetDescendants()) do
            if v:IsA("BasePart") then v.CanCollide=false end
        end
    end
end)

-- ================================================================
--   DRAG MAIN PANEL
-- ================================================================
do
    local drag,ds,sp=false
    TopBar.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 then
            drag=true; ds=i.Position; sp=Main.Position end end)
    TopBar.InputEnded:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 then drag=false end end)
    UserInputService.InputChanged:Connect(function(i)
        if drag and i.UserInputType==Enum.UserInputType.MouseMovement then
            local d=i.Position-ds
            local np=UDim2.new(sp.X.Scale,sp.X.Offset+d.X,sp.Y.Scale,sp.Y.Offset+d.Y)
            Main.Position=np; POS_SHOW=np
        end
    end)
end

-- ================================================================
--   KEYBIND HANDLER GLOBAL
-- ================================================================
UserInputService.InputBegan:Connect(function(inp,gpe)
    if gpe then return end
    if PickerActive then return end  -- laisser le picker gérer
    if inp.KeyCode==Enum.KeyCode.Insert then toggleMenu() end
    -- Parcourir KB et déclencher si la touche correspond
    for id, entry in pairs(KB) do
        if entry.kc and entry.kc == inp.KeyCode and entry.fn then
            pcall(entry.fn)
        end
    end
end)

-- ================================================================
--   BOOT
-- ================================================================
notify("NOVA MENU v3","INSERT = toggle  |  ⚙ = changer touche  |  ◈ = paramètres","on")
print("✦ NOVA MENU v3 loaded — système modulaire + keybinds live + paramètres")