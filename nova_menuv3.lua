-- ================================================================
--   NOVA MENU  v4  |  Ultimate Edition
--   loadstring(game:HttpGet('https://raw.githubusercontent.com/kawaiifirecat/nova-menu/main/nova_menu.lua'))()
-- ================================================================
local Players=game:GetService("Players"); local TweenService=game:GetService("TweenService")
local UIS=game:GetService("UserInputService"); local RS=game:GetService("RunService")
local Lighting=game:GetService("Lighting"); local LP=Players.LocalPlayer; local Cam=workspace.CurrentCamera
if game.CoreGui:FindFirstChild("NOVA_MENU") then game.CoreGui.NOVA_MENU:Destroy() end

-- ================================================================  PALETTE
local C={BG=Color3.fromRGB(7,7,16),BG2=Color3.fromRGB(13,13,26),BG3=Color3.fromRGB(21,19,42),
ACCENT=Color3.fromRGB(110,50,245),ACCENT2=Color3.fromRGB(168,74,255),PINK=Color3.fromRGB(215,68,195),
TEXT=Color3.fromRGB(228,222,245),SUB=Color3.fromRGB(112,102,148),GREEN=Color3.fromRGB(62,212,122),
RED=Color3.fromRGB(212,62,74),YELLOW=Color3.fromRGB(250,192,48),ORANGE=Color3.fromRGB(250,138,48),
CYAN=Color3.fromRGB(48,212,220),BLUE=Color3.fromRGB(60,140,255)}
local FB=Enum.Font.GothamBold; local FS=Enum.Font.GothamSemibold; local FR=Enum.Font.Gotham; local FC=Enum.Font.Code
local TIF=TweenInfo.new(0.15,Enum.EasingStyle.Quad,Enum.EasingDirection.Out)
local TIS=TweenInfo.new(0.28,Enum.EasingStyle.Quart,Enum.EasingDirection.Out)
local W,H=340,495

-- ================================================================  PARAMS (sliders)
local P={
    walkSpeed ={v=160, min=16,  max=600,  lbl="Vitesse de marche"},
    jumpPower ={v=150, min=50,  max=600,  lbl="Puissance de saut"},
    flySpeed  ={v=60,  min=10,  max=400,  lbl="Vitesse de vol"},
    healRate  ={v=0.4, min=0.05,max=5,    lbl="Intervalle heal (s)"},
    hitboxSz  ={v=8,   min=1,   max=60,   lbl="Taille hitbox"},
    headSz    ={v=2,   min=0.3, max=15,   lbl="Taille de tête"},
    fogDist   ={v=500, min=50,  max=5000, lbl="Distance brouillard"},
    timeHour  ={v=12,  min=0,   max=24,   lbl="Heure (0-24)"},
    gravity   ={v=196, min=0,   max=980,  lbl="Gravité"},
    fov       ={v=70,  min=30,  max=120,  lbl="Champ de vision"},
    camZoom   ={v=20,  min=5,   max=80,   lbl="Zoom caméra"},
    sprintSpd ={v=80,  min=20,  max=300,  lbl="Vitesse sprint"},
    trailLen  ={v=1,   min=0.1, max=5,    lbl="Durée traînée (s)"},
}

-- ================================================================  OPTS (bool toggles in settings)
local O={
    speedProg=false, speedFire=false, speedSpark=false, speedTrail=false,
    flyFire=false, flySpark=false,
    godFF=false,
    espHealth=false, espDist=false, espBoxes=false,
    noShadow=false,
    hitboxInvis=false,
}

-- ================================================================  STATE
local S={noclip=false,infjump=false,fly=false,autoheal=false,god=false,esp=false,
antiaafk=false,crosshair=false,fullbright=false,hitbox=false,sprint=false,
swimair=false,antirag=false,thirdp=false,fpsshow=false,gravloop=false,timeloop=false}

-- ================================================================  KEYBIND SYSTEM
local KB={}
local function regKB(id,fn) KB[id]=KB[id] or {kc=nil,fn=nil,labels={}}; KB[id].fn=fn end
local function kbTxt(kc) if not kc then return "—" end return tostring(kc):match("KeyCode%.(.+)") or "?" end
local function setKB(id,kc)
    if not KB[id] then return end; KB[id].kc=kc
    for _,w in ipairs(KB[id].labels) do pcall(function() w.Text=kbTxt(kc) end) end
end
local function addKBLbl(id,w) KB[id]=KB[id] or {kc=nil,fn=nil,labels={}}; table.insert(KB[id].labels,w); w.Text=kbTxt(KB[id].kc) end

-- ================================================================  HELPERS
local function tw(o,p,i) TweenService:Create(o,i or TIF,p):Play() end
local function corner(p,r) local c=Instance.new("UICorner",p); c.CornerRadius=UDim.new(0,r or 10); return c end
local function stroke(p,col,th) local s=Instance.new("UIStroke",p); s.Color=col; s.Thickness=th or 1.5; s.ApplyStrokeMode=Enum.ApplyStrokeMode.Border; return s end
local function lbl(p,t,sz,f,col,xa)
    local l=Instance.new("TextLabel",p); l.BackgroundTransparency=1; l.Text=t; l.TextSize=sz or 12
    l.Font=f or FR; l.TextColor3=col or C.TEXT; l.TextXAlignment=xa or Enum.TextXAlignment.Left
    l.Size=UDim2.new(1,0,1,0); return l
end
local function mkdrag(frame,handle)
    local drag,ds,sp=false
    handle.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then drag=true;ds=i.Position;sp=frame.Position end end)
    handle.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then drag=false end end)
    UIS.InputChanged:Connect(function(i)
        if drag and i.UserInputType==Enum.UserInputType.MouseMovement then
            local d=i.Position-ds; frame.Position=UDim2.new(sp.X.Scale,sp.X.Offset+d.X,sp.Y.Scale,sp.Y.Offset+d.Y)
        end
    end)
end
local function applyFX(key,col)
    if not LP.Character then return end
    if key=="fire" then
        for _,v in pairs(LP.Character:GetChildren()) do
            if v:IsA("BasePart") and not v:FindFirstChild("NV_F") then
                local f=Instance.new("Fire",v); f.Name="NV_F"; f.Size=2; f.Heat=6; f.Color=col or Color3.fromRGB(255,100,0); f.SecondaryColor=Color3.fromRGB(255,200,0)
            end
        end
    elseif key=="spark" then
        local hrp=LP.Character:FindFirstChild("HumanoidRootPart")
        if hrp and not hrp:FindFirstChild("NV_SP") then
            local sp=Instance.new("Sparkles",hrp); sp.Name="NV_SP"; sp.SparkleColor=col or C.ACCENT2
        end
    elseif key=="trail" then
        local hrp=LP.Character:FindFirstChild("HumanoidRootPart")
        if hrp and not hrp:FindFirstChild("NV_TR") then
            local a0=Instance.new("Attachment",hrp); a0.Name="NV_TRA"
            local a1=Instance.new("Attachment",hrp); a1.Name="NV_TRB"; a1.Position=Vector3.new(0,-2.5,0)
            local tr=Instance.new("Trail",hrp); tr.Name="NV_TR"; tr.Attachment0=a0; tr.Attachment1=a1
            tr.Lifetime=P.trailLen.v; tr.Color=ColorSequence.new(col or C.ACCENT2,C.PINK)
            tr.LightEmission=0.8; tr.Transparency=NumberSequence.new(0,1)
        end
    end
end
local function removeFX(key)
    if not LP.Character then return end
    for _,v in pairs(LP.Character:GetDescendants()) do
        if (key=="fire" and v.Name=="NV_F") or (key=="spark" and v.Name=="NV_SP")
        or (key=="trail" and (v.Name=="NV_TR" or v.Name=="NV_TRA" or v.Name=="NV_TRB")) then
            pcall(function() v:Destroy() end)
        end
    end
end

-- ================================================================  GUI ROOT
local Gui=Instance.new("ScreenGui"); Gui.Name="NOVA_MENU"; Gui.ResetOnSpawn=false
Gui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling; Gui.IgnoreGuiInset=true; Gui.Parent=game.CoreGui

-- ================================================================  NOTIFICATIONS
local NH=Instance.new("Frame",Gui); NH.Size=UDim2.new(0,258,1,0); NH.Position=UDim2.new(1,-268,0,0)
NH.BackgroundTransparency=1; NH.BorderSizePixel=0
local NL=Instance.new("UIListLayout",NH); NL.VerticalAlignment=Enum.VerticalAlignment.Bottom; NL.Padding=UDim.new(0,5)
Instance.new("UIPadding",NH).PaddingBottom=UDim.new(0,78)
local function notify(title,msg,ntype)
    local col=({on=C.GREEN,off=C.RED,warn=C.YELLOW})[ntype] or C.ACCENT
    local n=Instance.new("Frame",NH); n.Size=UDim2.new(1,0,0,52); n.BackgroundColor3=C.BG2
    n.BorderSizePixel=0; n.BackgroundTransparency=1; corner(n,8); stroke(n,col,1.5)
    local bar=Instance.new("Frame",n); bar.Size=UDim2.new(0,3,1,-12); bar.Position=UDim2.new(0,7,0,6)
    bar.BackgroundColor3=col; bar.BorderSizePixel=0; corner(bar,2)
    local t=lbl(n,title,11,FB,col); t.Size=UDim2.new(1,-22,0,14); t.Position=UDim2.new(0,16,0,7)
    local m=lbl(n,msg,10,FR,C.SUB); m.Size=UDim2.new(1,-22,0,22); m.Position=UDim2.new(0,16,0,23); m.TextWrapped=true
    tw(n,{BackgroundTransparency=0})
    task.delay(3,function() tw(n,{BackgroundTransparency=1}); task.wait(0.2); n:Destroy() end)
end

-- ================================================================  KEYBIND PICKER
local PickActive=false; local picConn=nil
local POverlay=Instance.new("Frame",Gui); POverlay.Size=UDim2.new(1,0,1,0)
POverlay.BackgroundColor3=Color3.new(0,0,0); POverlay.BackgroundTransparency=0.5
POverlay.BorderSizePixel=0; POverlay.Visible=false; POverlay.ZIndex=200
local PBox=Instance.new("Frame",POverlay); PBox.Size=UDim2.new(0,272,0,108)
PBox.Position=UDim2.new(0.5,-136,0.5,-54); PBox.BackgroundColor3=C.BG2; PBox.BorderSizePixel=0; PBox.ZIndex=201
corner(PBox,12); stroke(PBox,C.ACCENT2,1.5)
local PT=lbl(PBox,"ASSIGNER UNE TOUCHE",13,FB,C.ACCENT2); PT.Position=UDim2.new(0,0,0,12); PT.Size=UDim2.new(1,0,0,18); PT.TextXAlignment=Enum.TextXAlignment.Center; PT.ZIndex=202
local PS=lbl(PBox,"Appuie sur n'importe quelle touche",10,FR,C.SUB); PS.Position=UDim2.new(0,0,0,33); PS.Size=UDim2.new(1,0,0,16); PS.TextXAlignment=Enum.TextXAlignment.Center; PS.ZIndex=202
local PC=lbl(PBox,"ESC = supprimer le raccourci",9,FR,C.SUB); PC.Position=UDim2.new(0,0,0,52); PC.Size=UDim2.new(1,0,0,14); PC.TextXAlignment=Enum.TextXAlignment.Center; PC.ZIndex=202
local PCan=Instance.new("TextButton",PBox); PCan.Size=UDim2.new(0.5,-16,0,24); PCan.Position=UDim2.new(0.25,8,0,76)
PCan.BackgroundColor3=C.BG3; PCan.Text="ANNULER"; PCan.TextSize=10; PCan.Font=FB; PCan.TextColor3=C.SUB
PCan.BorderSizePixel=0; corner(PCan,6); PCan.ZIndex=202
local function openPicker(id,cb)
    if PickActive then return end; PickActive=true
    PC.Text="Actuel : "..(KB[id] and kbTxt(KB[id].kc) or "—")
    POverlay.Visible=true
    picConn=UIS.InputBegan:Connect(function(inp,gpe)
        if gpe then return end; picConn:Disconnect(); picConn=nil; POverlay.Visible=false; PickActive=false
        if inp.KeyCode==Enum.KeyCode.Escape then setKB(id,nil); if cb then cb(nil) end; notify("TOUCHE","Raccourci supprimé","warn")
        else setKB(id,inp.KeyCode); if cb then cb(inp.KeyCode) end; notify("TOUCHE","["..kbTxt(inp.KeyCode).."] assigné","on") end
    end)
end
PCan.MouseButton1Click:Connect(function() if picConn then picConn:Disconnect();picConn=nil end; POverlay.Visible=false; PickActive=false end)

-- ================================================================  HUD — ACTIVE FEATURES
local HUD=Instance.new("Frame",Gui); HUD.Name="HUD"; HUD.Size=UDim2.new(0,180,0,28)
HUD.Position=UDim2.new(0,10,1,-46); HUD.BackgroundColor3=C.BG2; HUD.BorderSizePixel=0
HUD.AutomaticSize=Enum.AutomaticSize.Y; corner(HUD,8); stroke(HUD,C.ACCENT,1)
local HTop=Instance.new("Frame",HUD); HTop.Size=UDim2.new(1,0,0,22); HTop.BackgroundColor3=C.BG3; HTop.BorderSizePixel=0; corner(HTop,8)
do local f=Instance.new("Frame",HTop); f.Size=UDim2.new(1,0,0.5,0); f.Position=UDim2.new(0,0,0.5,0); f.BackgroundColor3=C.BG3; f.BorderSizePixel=0 end
local HTL=lbl(HTop,"◆  ACTIF",9,FB,C.ACCENT); HTL.Position=UDim2.new(0,8,0,0)
local HList=Instance.new("Frame",HUD); HList.Size=UDim2.new(1,-12,0,0); HList.Position=UDim2.new(0,6,0,26)
HList.BackgroundTransparency=1; HList.BorderSizePixel=0; HList.AutomaticSize=Enum.AutomaticSize.Y
local HLL=Instance.new("UIListLayout",HList); HLL.Padding=UDim.new(0,2); HLL.SortOrder=Enum.SortOrder.LayoutOrder
Instance.new("UIPadding",HList).PaddingBottom=UDim.new(0,6)
local HE={}
local function hudOn(k,name,col) if HE[k] then return end; local r=Instance.new("Frame",HList); r.Size=UDim2.new(1,0,0,15); r.BackgroundTransparency=1; r.BorderSizePixel=0; local d=Instance.new("Frame",r); d.Size=UDim2.new(0,6,0,6); d.Position=UDim2.new(0,0,0.5,-3); d.BackgroundColor3=col; d.BorderSizePixel=0; corner(d,3); local l=lbl(r,name,10,FS,C.TEXT); l.Position=UDim2.new(0,10,0,0); l.Size=UDim2.new(1,-10,1,0); HE[k]=r end
local function hudOff(k) if HE[k] then HE[k]:Destroy(); HE[k]=nil end end
mkdrag(HUD,HTop)

-- ================================================================  SIDEBAR TAB
local STab=Instance.new("TextButton",Gui); STab.Size=UDim2.new(0,32,0,108); STab.Position=UDim2.new(1,-32,0.5,-54)
STab.BackgroundColor3=C.BG2; STab.Text=""; STab.BorderSizePixel=0; STab.ZIndex=10; corner(STab,8); stroke(STab,C.ACCENT,1.5)
local SLbl=Instance.new("TextLabel",STab); SLbl.Size=UDim2.new(1,0,1,-18); SLbl.Position=UDim2.new(0,0,0,4)
SLbl.BackgroundTransparency=1; SLbl.Text="N\nO\nV\nA"; SLbl.TextSize=10; SLbl.Font=FB; SLbl.TextColor3=C.ACCENT2; SLbl.TextXAlignment=Enum.TextXAlignment.Center
local SArr=Instance.new("TextLabel",STab); SArr.Size=UDim2.new(1,0,0,16); SArr.Position=UDim2.new(0,0,1,-18)
SArr.BackgroundTransparency=1; SArr.Text="‹"; SArr.TextSize=16; SArr.Font=FB; SArr.TextColor3=C.SUB; SArr.TextXAlignment=Enum.TextXAlignment.Center
STab.MouseEnter:Connect(function() tw(STab,{BackgroundColor3=C.BG3}) end)
STab.MouseLeave:Connect(function() tw(STab,{BackgroundColor3=C.BG2}) end)

-- ================================================================  MAIN PANEL
local Main=Instance.new("Frame",Gui); Main.Name="Main"; Main.Size=UDim2.new(0,W,0,H)
Main.BackgroundColor3=C.BG; Main.BorderSizePixel=0; Main.ClipsDescendants=true; corner(Main,12); stroke(Main,C.ACCENT,1.5)
local mG=Instance.new("UIGradient",Main); mG.Color=ColorSequence.new({ColorSequenceKeypoint.new(0,C.BG),ColorSequenceKeypoint.new(1,Color3.fromRGB(9,6,22))}); mG.Rotation=138
local PHIDE=UDim2.new(1,10,0.5,-(H/2)); local PSHOW=UDim2.new(1,-(W+38),0.5,-(H/2)); Main.Position=PHIDE
local mOpen=false
local function toggleMenu()
    mOpen=not mOpen
    if mOpen then tw(Main,{Position=PSHOW},TIS); SArr.Text="›"; tw(SArr,{TextColor3=C.ACCENT})
    else tw(Main,{Position=PHIDE},TIS); SArr.Text="‹"; tw(SArr,{TextColor3=C.SUB}) end
end
STab.MouseButton1Click:Connect(toggleMenu)

-- ================================================================  TOPBAR
local TBar=Instance.new("Frame",Main); TBar.Size=UDim2.new(1,0,0,40); TBar.BackgroundColor3=C.BG2; TBar.BorderSizePixel=0; corner(TBar,12)
do local f=Instance.new("Frame",TBar); f.Size=UDim2.new(1,0,0.5,0); f.Position=UDim2.new(0,0,0.5,0); f.BackgroundColor3=C.BG2; f.BorderSizePixel=0 end
local AL=Instance.new("Frame",Main); AL.Size=UDim2.new(1,-32,0,1); AL.Position=UDim2.new(0,16,0,40); AL.BackgroundColor3=C.ACCENT; AL.BorderSizePixel=0
local alG=Instance.new("UIGradient",AL); alG.Color=ColorSequence.new({ColorSequenceKeypoint.new(0,C.BG),ColorSequenceKeypoint.new(0.3,C.ACCENT),ColorSequenceKeypoint.new(0.7,C.ACCENT2),ColorSequenceKeypoint.new(1,C.BG)})
local TL=lbl(TBar,"✦  NOVA  MENU",14,FB,C.TEXT); TL.Size=UDim2.new(1,-72,1,0); TL.Position=UDim2.new(0,12,0,0)
local tG=Instance.new("UIGradient",TL); tG.Color=ColorSequence.new({ColorSequenceKeypoint.new(0,C.ACCENT2),ColorSequenceKeypoint.new(0.5,C.TEXT),ColorSequenceKeypoint.new(1,C.PINK)})
local VB=Instance.new("TextLabel",TBar); VB.Size=UDim2.new(0,24,0,12); VB.Position=UDim2.new(0,124,0.5,-6); VB.BackgroundColor3=C.ACCENT; VB.Text="v4"; VB.TextSize=8; VB.Font=FB; VB.TextColor3=C.TEXT; VB.BorderSizePixel=0; corner(VB,3)
local function mkTBtn(x,t,bg) local b=Instance.new("TextButton",TBar); b.Size=UDim2.new(0,24,0,24); b.Position=UDim2.new(1,x,0.5,-12); b.BackgroundColor3=bg; b.Text=t; b.TextColor3=C.TEXT; b.TextSize=10; b.Font=FB; b.BorderSizePixel=0; corner(b,5); return b end
local MinB=mkTBtn(-58,"—",C.BG3); local CloseB=mkTBtn(-30,"✕",Color3.fromRGB(168,30,50))
CloseB.MouseButton1Click:Connect(function() tw(Main,{Position=PHIDE},TIS); mOpen=false; SArr.Text="‹"; tw(SArr,{TextColor3=C.SUB}) end)
local mini=false; MinB.MouseButton1Click:Connect(function() mini=not mini; tw(Main,{Size=mini and UDim2.new(0,W,0,40) or UDim2.new(0,W,0,H)}); MinB.Text=mini and "□" or "—" end)
mkdrag(Main,TBar)
-- sync PSHOW when dragged
do local drag2,ds2,sp2=false
TBar.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then drag2=true;ds2=i.Position;sp2=Main.Position end end)
TBar.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then drag2=false end end)
UIS.InputChanged:Connect(function(i) if drag2 and i.UserInputType==Enum.UserInputType.MouseMovement then PSHOW=Main.Position end end) end

-- ================================================================  PLAYER INFO
local PIB=Instance.new("Frame",Main); PIB.Size=UDim2.new(1,-18,0,28); PIB.Position=UDim2.new(0,9,0,48); PIB.BackgroundColor3=C.BG2; PIB.BorderSizePixel=0; corner(PIB,6)
local piN=lbl(PIB,"◆  "..LP.Name,11,FS,C.TEXT); piN.Position=UDim2.new(0,10,0,0); piN.Size=UDim2.new(0.58,0,1,0)
local piS=lbl(PIB,"● ONLINE",10,FB,C.GREEN); piS.Position=UDim2.new(0.58,0,0,0); piS.Size=UDim2.new(0.42,-8,1,0); piS.TextXAlignment=Enum.TextXAlignment.Right

-- ================================================================  TAB BAR
local TabBar=Instance.new("Frame",Main); TabBar.Size=UDim2.new(1,-18,0,26); TabBar.Position=UDim2.new(0,9,0,84)
TabBar.BackgroundColor3=C.BG2; TabBar.BorderSizePixel=0; corner(TabBar,6)
local TBL=Instance.new("UIListLayout",TabBar); TBL.FillDirection=Enum.FillDirection.Horizontal; TBL.Padding=UDim.new(0,2); TBL.SortOrder=Enum.SortOrder.LayoutOrder
local TBP=Instance.new("UIPadding",TabBar); TBP.PaddingLeft=UDim.new(0,3); TBP.PaddingRight=UDim.new(0,3); TBP.PaddingTop=UDim.new(0,3); TBP.PaddingBottom=UDim.new(0,3)
local CA=Instance.new("Frame",Main); CA.Size=UDim2.new(1,-18,1,-120); CA.Position=UDim2.new(0,9,0,118); CA.BackgroundTransparency=1; CA.ClipsDescendants=true

-- ================================================================  SETTINGS PANEL
local SPvis=false
local SP=Instance.new("Frame",Main); SP.Name="SP"; SP.Size=UDim2.new(1,-18,1,-120); SP.Position=UDim2.new(1,20,0,118); SP.BackgroundColor3=C.BG; SP.BorderSizePixel=0; SP.ZIndex=20
local SPTop=Instance.new("Frame",SP); SPTop.Size=UDim2.new(1,0,0,36); SPTop.BackgroundColor3=C.BG2; SPTop.BorderSizePixel=0; SPTop.ZIndex=21
local SPColBar=Instance.new("Frame",SPTop); SPColBar.Size=UDim2.new(0,3,1,-8); SPColBar.Position=UDim2.new(0,36,0,4); SPColBar.BackgroundColor3=C.ACCENT; SPColBar.BorderSizePixel=0; corner(SPColBar,2); SPColBar.ZIndex=22
local SPTitle=lbl(SPTop,"PARAMÈTRES",12,FB,C.ACCENT2); SPTitle.Position=UDim2.new(0,46,0,0); SPTitle.Size=UDim2.new(1,-56,1,0); SPTitle.ZIndex=22
local SPBack=Instance.new("TextButton",SPTop); SPBack.Size=UDim2.new(0,28,0,26); SPBack.Position=UDim2.new(0,4,0.5,-13); SPBack.BackgroundColor3=C.BG3; SPBack.Text="‹"; SPBack.TextSize=16; SPBack.Font=FB; SPBack.TextColor3=C.TEXT; SPBack.BorderSizePixel=0; corner(SPBack,6); SPBack.ZIndex=22
-- accent line under SPTop
local SPAl=Instance.new("Frame",SP); SPAl.Size=UDim2.new(1,-24,0,1); SPAl.Position=UDim2.new(0,12,0,36); SPAl.BackgroundColor3=C.ACCENT; SPAl.BorderSizePixel=0; SPAl.ZIndex=21
local spAlG=Instance.new("UIGradient",SPAl); spAlG.Color=ColorSequence.new({ColorSequenceKeypoint.new(0,C.BG),ColorSequenceKeypoint.new(0.4,C.ACCENT),ColorSequenceKeypoint.new(0.6,C.ACCENT2),ColorSequenceKeypoint.new(1,C.BG)})
local SPScr=Instance.new("ScrollingFrame",SP); SPScr.Size=UDim2.new(1,0,1,-42); SPScr.Position=UDim2.new(0,0,0,42); SPScr.BackgroundTransparency=1; SPScr.BorderSizePixel=0; SPScr.ScrollBarThickness=3; SPScr.ScrollBarImageColor3=C.ACCENT; SPScr.CanvasSize=UDim2.new(0,0,0,0); SPScr.AutomaticCanvasSize=Enum.AutomaticSize.Y; SPScr.ZIndex=21
local SPSL=Instance.new("UIListLayout",SPScr); SPSL.Padding=UDim.new(0,5); SPSL.SortOrder=Enum.SortOrder.LayoutOrder
local SPSP=Instance.new("UIPadding",SPScr); SPSP.PaddingLeft=UDim.new(0,5); SPSP.PaddingRight=UDim.new(0,5); SPSP.PaddingBottom=UDim.new(0,10)

local function hideSettings()
    if not SPvis then return end; SPvis=false; tw(SP,{Position=UDim2.new(1,20,0,118)},TIS)
end
SPBack.MouseButton1Click:Connect(hideSettings)

-- build a slider inside SPScr
local function spSlider(paramId,col,order)
    local p=P[paramId]; if not p then return end
    local F=Instance.new("Frame",SPScr); F.Size=UDim2.new(1,0,0,62); F.BackgroundColor3=C.BG2; F.BorderSizePixel=0; F.LayoutOrder=order; corner(F,8); stroke(F,C.BG3,1.5); F.ZIndex=22
    local tl=lbl(F,p.lbl,10,FS,C.TEXT); tl.Position=UDim2.new(0,10,0,6); tl.Size=UDim2.new(0.65,0,0,15); tl.ZIndex=23
    local vl=lbl(F,tostring(math.floor(p.v)),12,FB,col); vl.Position=UDim2.new(0.65,0,0,5); vl.Size=UDim2.new(0.35,-10,0,17); vl.TextXAlignment=Enum.TextXAlignment.Right; vl.ZIndex=23
    local ml=lbl(F,tostring(p.min),8,FR,C.SUB); ml.Position=UDim2.new(0,10,0,50); ml.Size=UDim2.new(0.3,0,0,11); ml.ZIndex=23
    local xl=lbl(F,tostring(p.max),8,FR,C.SUB); xl.Position=UDim2.new(0.7,-10,0,50); xl.Size=UDim2.new(0.3,10,0,11); xl.TextXAlignment=Enum.TextXAlignment.Right; xl.ZIndex=23
    local Tr=Instance.new("Frame",F); Tr.Size=UDim2.new(1,-20,0,8); Tr.Position=UDim2.new(0,10,0,34); Tr.BackgroundColor3=C.BG3; Tr.BorderSizePixel=0; corner(Tr,4); Tr.ZIndex=23
    local r0=math.clamp((p.v-p.min)/(p.max-p.min),0,1)
    local Fi=Instance.new("Frame",Tr); Fi.Size=UDim2.new(r0,0,1,0); Fi.BackgroundColor3=col; Fi.BorderSizePixel=0; corner(Fi,4); Fi.ZIndex=24
    local Kn=Instance.new("Frame",Tr); Kn.Size=UDim2.new(0,14,0,14); Kn.BackgroundColor3=C.TEXT; Kn.Position=UDim2.new(r0,-7,0.5,-7); Kn.BorderSizePixel=0; corner(Kn,7); Kn.ZIndex=25
    local sd=false
    local function upd(inp) local ap=Tr.AbsolutePosition; local as=Tr.AbsoluteSize; local r=math.clamp((inp.Position.X-ap.X)/as.X,0,1); p.v=p.min+(p.max-p.min)*r; Fi.Size=UDim2.new(r,0,1,0); Kn.Position=UDim2.new(r,-7,0.5,-7); vl.Text=tostring(math.floor(p.v*10)/10) end
    Tr.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then sd=true;upd(i) end end)
    Tr.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then sd=false end end)
    UIS.InputChanged:Connect(function(i) if sd and i.UserInputType==Enum.UserInputType.MouseMovement then upd(i) end end)
end

-- build a bool toggle inside SPScr
local function spBool(optKey,label,desc,col,onChange,order)
    local F=Instance.new("Frame",SPScr); F.Size=UDim2.new(1,0,0,40); F.BackgroundColor3=C.BG2; F.BorderSizePixel=0; F.LayoutOrder=order; corner(F,8); stroke(F,C.BG3,1.5); F.ZIndex=22
    local tl=lbl(F,label,11,FS,C.TEXT); tl.Position=UDim2.new(0,10,0,desc and 4 or 0); tl.Size=UDim2.new(1,-52,0,16); tl.ZIndex=23
    if desc then local dl=lbl(F,desc,9,FR,C.SUB); dl.Position=UDim2.new(0,10,0,22); dl.Size=UDim2.new(1,-52,0,14); dl.ZIndex=23 end
    local Tr=Instance.new("Frame",F); Tr.Size=UDim2.new(0,32,0,17); Tr.Position=UDim2.new(1,-40,0.5,-8.5); Tr.BackgroundColor3=C.BG3; Tr.BorderSizePixel=0; corner(Tr,9); Tr.ZIndex=23
    local Th=Instance.new("Frame",Tr); local on0=O[optKey]; Th.Size=UDim2.new(0,13,0,13); Th.Position=on0 and UDim2.new(1,-15,0.5,-6.5) or UDim2.new(0,2,0.5,-6.5); Th.BackgroundColor3=on0 and C.TEXT or C.SUB; Th.BorderSizePixel=0; corner(Th,7); Th.ZIndex=24
    if on0 then Tr.BackgroundColor3=col end
    local TB=Instance.new("TextButton",F); TB.Size=UDim2.new(1,0,1,0); TB.BackgroundTransparency=1; TB.Text=""; TB.BorderSizePixel=0; TB.ZIndex=25
    TB.MouseButton1Click:Connect(function()
        O[optKey]=not O[optKey]; local v=O[optKey]
        tw(Tr,{BackgroundColor3=v and col or C.BG3}); tw(Th,{Position=v and UDim2.new(1,-15,0.5,-6.5) or UDim2.new(0,2,0.5,-6.5),BackgroundColor3=v and C.TEXT or C.SUB})
        if onChange then pcall(onChange,v) end
    end)
end

-- section header inside SPScr
local function spSection(title,order)
    local F=Instance.new("Frame",SPScr); F.Size=UDim2.new(1,0,0,20); F.BackgroundTransparency=1; F.LayoutOrder=order; F.ZIndex=22
    local L=lbl(F,"  "..string.upper(title),9,FB,C.ACCENT); L.ZIndex=23
    local Ln=Instance.new("Frame",F); Ln.Size=UDim2.new(1,-6,0,1); Ln.Position=UDim2.new(0,3,1,-1); Ln.BackgroundColor3=C.BG3; Ln.BorderSizePixel=0; Ln.ZIndex=22
end

local function openSettings(cfg)
    -- clear SPScr
    for _,c in pairs(SPScr:GetChildren()) do if not c:IsA("UIListLayout") and not c:IsA("UIPadding") then c:Destroy() end end
    SPTitle.Text=string.upper(cfg.name); SPTitle.TextColor3=cfg.col; SPColBar.BackgroundColor3=cfg.col
    SPAl.BackgroundColor3=cfg.col
    local ord=0; local function O2() ord=ord+1; return ord end
    -- KB row
    spSection("Raccourci clavier",O2())
    local KR=Instance.new("Frame",SPScr); KR.Size=UDim2.new(1,0,0,44); KR.BackgroundColor3=C.BG2; KR.BorderSizePixel=0; KR.LayoutOrder=O2(); corner(KR,8); stroke(KR,C.BG3,1.5); KR.ZIndex=22
    local kbSub=lbl(KR,"Cliquer pour assigner — ESC pour supprimer",9,FR,C.SUB); kbSub.Position=UDim2.new(0,10,0,4); kbSub.Size=UDim2.new(1,-20,0,13); kbSub.ZIndex=23
    local kbB=Instance.new("TextButton",KR); kbB.Size=UDim2.new(1,-20,0,22); kbB.Position=UDim2.new(0,10,0,18); kbB.BackgroundColor3=C.BG3; kbB.BorderSizePixel=0; corner(kbB,6); kbB.ZIndex=23; kbB.TextSize=12; kbB.Font=FB; kbB.TextColor3=C.TEXT
    addKBLbl(cfg.id,kbB)
    kbB.MouseEnter:Connect(function() tw(kbB,{BackgroundColor3=cfg.col}) end)
    kbB.MouseLeave:Connect(function() tw(kbB,{BackgroundColor3=C.BG3}) end)
    kbB.MouseButton1Click:Connect(function() openPicker(cfg.id,function() end) end)
    -- sliders
    if cfg.sliders and #cfg.sliders>0 then
        spSection("Valeurs",O2())
        for _,s in ipairs(cfg.sliders) do spSlider(s,cfg.col,O2()) end
    end
    -- options
    if cfg.options and #cfg.options>0 then
        spSection("Modes & Effets",O2())
        for _,opt in ipairs(cfg.options) do spBool(opt.key,opt.lbl,opt.desc,cfg.col,opt.onChange,O2()) end
    end
    SPvis=true; tw(SP,{Position=UDim2.new(0,9,0,118)},TIS)
end

-- ================================================================  TAB FACTORY
local Tabs={}
local function newTab(name)
    local Btn=Instance.new("TextButton",TabBar); Btn.Size=UDim2.new(0.25,-2,1,0); Btn.BackgroundColor3=C.BG3; Btn.Text=name; Btn.TextSize=9; Btn.Font=FS; Btn.TextColor3=C.SUB; Btn.BorderSizePixel=0; corner(Btn,4)
    local Scr=Instance.new("ScrollingFrame",CA); Scr.Size=UDim2.new(1,0,1,0); Scr.BackgroundTransparency=1; Scr.BorderSizePixel=0; Scr.ScrollBarThickness=3; Scr.ScrollBarImageColor3=C.ACCENT; Scr.CanvasSize=UDim2.new(0,0,0,0); Scr.AutomaticCanvasSize=Enum.AutomaticSize.Y; Scr.Visible=false
    local SL=Instance.new("UIListLayout",Scr); SL.Padding=UDim.new(0,4); SL.SortOrder=Enum.SortOrder.LayoutOrder
    local tab={btn=Btn,scr=Scr}; Tabs[name]=tab
    Btn.MouseButton1Click:Connect(function()
        hideSettings()
        for _,t in pairs(Tabs) do t.scr.Visible=false; tw(t.btn,{BackgroundColor3=C.BG3,TextColor3=C.SUB}) end
        Scr.Visible=true; tw(Btn,{BackgroundColor3=C.ACCENT,TextColor3=C.TEXT})
    end)
    return tab
end

-- ================================================================  WIDGET FACTORIES
local function section(tab,title,order)
    local F=Instance.new("Frame",tab.scr); F.Size=UDim2.new(1,0,0,20); F.BackgroundTransparency=1; F.LayoutOrder=order
    local L=lbl(F,"  "..string.upper(title),9,FB,C.ACCENT)
    local Ln=Instance.new("Frame",F); Ln.Size=UDim2.new(1,-6,0,1); Ln.Position=UDim2.new(0,3,1,-1); Ln.BackgroundColor3=C.BG3; Ln.BorderSizePixel=0
end

local function mkToggle(tab,cfg,onOn,onOff,order)
    local on=false; regKB(cfg.id,function() end)
    local Row=Instance.new("TextButton",tab.scr); Row.Size=UDim2.new(1,0,0,42); Row.BackgroundColor3=C.BG2; Row.Text=""; Row.BorderSizePixel=0; Row.LayoutOrder=order; corner(Row,8); local BS=stroke(Row,C.BG3,1.5)
    local Lb=lbl(Row,cfg.name,12,FS,C.TEXT); Lb.Position=UDim2.new(0,10,0,0); Lb.Size=UDim2.new(1,-110,1,0)
    local KBF=Instance.new("Frame",Row); KBF.Size=UDim2.new(0,28,0,16); KBF.Position=UDim2.new(1,-102,0.5,-8); KBF.BackgroundColor3=C.BG3; KBF.BorderSizePixel=0; corner(KBF,3)
    local KBL=lbl(KBF,"—",8,FB,C.SUB); KBL.TextXAlignment=Enum.TextXAlignment.Center; addKBLbl(cfg.id,KBL)
    local Tr=Instance.new("Frame",Row); Tr.Size=UDim2.new(0,30,0,16); Tr.Position=UDim2.new(1,-66,0.5,-8); Tr.BackgroundColor3=C.BG3; Tr.BorderSizePixel=0; corner(Tr,8)
    local Th=Instance.new("Frame",Tr); Th.Size=UDim2.new(0,12,0,12); Th.Position=UDim2.new(0,2,0.5,-6); Th.BackgroundColor3=C.SUB; Th.BorderSizePixel=0; corner(Th,6)
    local GB=Instance.new("TextButton",Row); GB.Size=UDim2.new(0,28,0,28); GB.Position=UDim2.new(1,-34,0.5,-14); GB.BackgroundColor3=C.BG3; GB.Text="⚙"; GB.TextSize=12; GB.Font=FB; GB.TextColor3=C.SUB; GB.BorderSizePixel=0; corner(GB,6); GB.ZIndex=5
    GB.MouseEnter:Connect(function() tw(GB,{BackgroundColor3=cfg.col,TextColor3=C.TEXT}) end)
    GB.MouseLeave:Connect(function() tw(GB,{BackgroundColor3=C.BG3,TextColor3=C.SUB}) end)
    GB.MouseButton1Click:Connect(function() openSettings(cfg) end)
    Row.MouseEnter:Connect(function() if not on then tw(Row,{BackgroundColor3=C.BG3}) end end)
    Row.MouseLeave:Connect(function() if not on then tw(Row,{BackgroundColor3=C.BG2}) end end)
    local function act()
        on=true; tw(Row,{BackgroundColor3=Color3.fromRGB(14,8,28)}); tw(BS,{Color=cfg.col}); tw(Lb,{TextColor3=cfg.col}); tw(Tr,{BackgroundColor3=cfg.col}); tw(Th,{Position=UDim2.new(1,-14,0.5,-6),BackgroundColor3=C.TEXT})
        pcall(onOn); hudOn(cfg.id,cfg.name,cfg.col); notify("ACTIVÉ",cfg.name,"on")
    end
    local function deact()
        on=false; tw(Row,{BackgroundColor3=C.BG2}); tw(BS,{Color=C.BG3}); tw(Lb,{TextColor3=C.TEXT}); tw(Tr,{BackgroundColor3=C.BG3}); tw(Th,{Position=UDim2.new(0,2,0.5,-6),BackgroundColor3=C.SUB})
        if onOff then pcall(onOff) end; hudOff(cfg.id); notify("DÉSACTIVÉ",cfg.name,"off")
    end
    Row.MouseButton1Click:Connect(function() if on then deact() else act() end end)
    KB[cfg.id].fn=function() if on then deact() else act() end end
end

local function mkButton(tab,cfg,action,order)
    regKB(cfg.id,action)
    local Row=Instance.new("TextButton",tab.scr); Row.Size=UDim2.new(1,0,0,40); Row.BackgroundColor3=C.BG2; Row.Text=""; Row.BorderSizePixel=0; Row.LayoutOrder=order; corner(Row,8); stroke(Row,C.BG3,1.5)
    local Lb=lbl(Row,cfg.name,12,FS,C.TEXT); Lb.Position=UDim2.new(0,10,0,0); Lb.Size=UDim2.new(1,-110,1,0)
    local KBF=Instance.new("Frame",Row); KBF.Size=UDim2.new(0,28,0,16); KBF.Position=UDim2.new(1,-102,0.5,-8); KBF.BackgroundColor3=C.BG3; KBF.BorderSizePixel=0; corner(KBF,3)
    local KBL=lbl(KBF,"—",8,FB,C.SUB); KBL.TextXAlignment=Enum.TextXAlignment.Center; addKBLbl(cfg.id,KBL)
    local Ar=lbl(Row,"›",18,FB,C.SUB); Ar.Size=UDim2.new(0,16,1,0); Ar.Position=UDim2.new(1,-68,0,0); Ar.TextXAlignment=Enum.TextXAlignment.Center
    local GB=Instance.new("TextButton",Row); GB.Size=UDim2.new(0,28,0,28); GB.Position=UDim2.new(1,-34,0.5,-14); GB.BackgroundColor3=C.BG3; GB.Text="⚙"; GB.TextSize=12; GB.Font=FB; GB.TextColor3=C.SUB; GB.BorderSizePixel=0; corner(GB,6); GB.ZIndex=5
    GB.MouseEnter:Connect(function() tw(GB,{BackgroundColor3=cfg.col,TextColor3=C.TEXT}) end)
    GB.MouseLeave:Connect(function() tw(GB,{BackgroundColor3=C.BG3,TextColor3=C.SUB}) end)
    GB.MouseButton1Click:Connect(function() openSettings(cfg) end)
    Row.MouseEnter:Connect(function() tw(Row,{BackgroundColor3=C.BG3}); tw(Lb,{TextColor3=cfg.col}); tw(Ar,{TextColor3=cfg.col}) end)
    Row.MouseLeave:Connect(function() tw(Row,{BackgroundColor3=C.BG2}); tw(Lb,{TextColor3=C.TEXT}); tw(Ar,{TextColor3=C.SUB}) end)
    Row.MouseButton1Click:Connect(function() tw(Row,{BackgroundColor3=cfg.col}); task.wait(0.09); tw(Row,{BackgroundColor3=C.BG2}); pcall(action) end)
end

-- ================================================================  TABS
local tP=newTab("PLAYER"); local tV=newTab("VISUAL"); local tW=newTab("WORLD"); local tS=newTab("SERVER")
tP.btn.BackgroundColor3=C.ACCENT; tP.btn.TextColor3=C.TEXT; tP.scr.Visible=true

-- ================================================================  TAB: PLAYER
section(tP,"Mouvement",1)

local flyBV,flyBG,flyHB
mkToggle(tP,{id="speed",name="Speed Hack",col=C.ACCENT,sliders={"walkSpeed"},options={
    {key="speedProg",lbl="Accélération progressive",desc="Augmente graduellement",onChange=function() end},
    {key="speedFire",lbl="Effet feu",onChange=function(v) if v then applyFX("fire",C.ORANGE) else removeFX("fire") end end},
    {key="speedSpark",lbl="Étincelles",onChange=function(v) if v then applyFX("spark",C.ACCENT2) else removeFX("spark") end end},
    {key="speedTrail",lbl="Traînée lumineuse",onChange=function(v) if v then applyFX("trail",C.ACCENT2) else removeFX("trail") end end},
}},function()
    S.noclip=false
    if O.speedProg then
        task.spawn(function()
            while S.speed and LP.Character do
                local h=LP.Character:FindFirstChildOfClass("Humanoid"); if not h then task.wait(0.1); continue end
                if h.WalkSpeed<P.walkSpeed.v then h.WalkSpeed=math.min(h.WalkSpeed+3,P.walkSpeed.v) end
                task.wait(0.02)
            end
        end)
    else if LP.Character then LP.Character.Humanoid.WalkSpeed=P.walkSpeed.v end end
    S.speed=true
end,function()
    S.speed=false; if LP.Character then LP.Character.Humanoid.WalkSpeed=16 end
    removeFX("fire"); removeFX("spark"); removeFX("trail")
end,2)

mkToggle(tP,{id="jump",name="Jump Power",col=C.ACCENT2,sliders={"jumpPower"}},function()
    if LP.Character then LP.Character.Humanoid.JumpPower=P.jumpPower.v end
end,function()
    if LP.Character then LP.Character.Humanoid.JumpPower=50 end
end,3)

mkToggle(tP,{id="infjump",name="Infinite Jump",col=C.PINK},function()
    S.infjump=true
    UIS.JumpRequest:Connect(function()
        if S.infjump and LP.Character then LP.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping) end
    end)
end,function() S.infjump=false end,4)

mkToggle(tP,{id="noclip",name="No Clip",col=Color3.fromRGB(138,82,255)},function()
    S.noclip=true
end,function()
    S.noclip=false
    if LP.Character then for _,v in pairs(LP.Character:GetDescendants()) do if v:IsA("BasePart") then v.CanCollide=true end end end
end,5)

mkToggle(tP,{id="sprint",name="Sprint  [SHIFT]",col=C.CYAN,sliders={"sprintSpd"}},function()
    S.sprint=true
end,function()
    S.sprint=false; if LP.Character then LP.Character.Humanoid.WalkSpeed=16 end
end,6)

mkToggle(tP,{id="swimair",name="Swim in Air",col=Color3.fromRGB(80,180,255)},function()
    S.swimair=true
end,function()
    S.swimair=false
    if LP.Character then LP.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Freefall) end
end,7)

section(tP,"Vol",8)
mkToggle(tP,{id="fly",name="Fly Mode",col=C.CYAN,sliders={"flySpeed"},options={
    {key="flyFire",lbl="Effet feu (réacteur)",onChange=function(v) if v then applyFX("fire",C.ORANGE) else removeFX("fire") end end},
    {key="flySpark",lbl="Étincelles",onChange=function(v) if v then applyFX("spark",C.CYAN) else removeFX("spark") end end},
}},function()
    S.fly=true; local char=LP.Character; if not char then return end
    local hrp=char:FindFirstChild("HumanoidRootPart"); if not hrp then return end
    char.Humanoid.PlatformStand=true
    flyBV=Instance.new("BodyVelocity",hrp); flyBV.MaxForce=Vector3.new(1e9,1e9,1e9); flyBV.Velocity=Vector3.zero
    flyBG=Instance.new("BodyGyro",hrp); flyBG.MaxTorque=Vector3.new(1e9,1e9,1e9); flyBG.P=5e4; flyBG.CFrame=hrp.CFrame
    flyHB=RS.Heartbeat:Connect(function()
        if not S.fly then return end; local d=Vector3.zero; local cf=Cam.CFrame
        if UIS:IsKeyDown(Enum.KeyCode.W) then d=d+cf.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.S) then d=d-cf.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.A) then d=d-cf.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.D) then d=d+cf.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.Space) then d=d+Vector3.new(0,1,0) end
        if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then d=d-Vector3.new(0,1,0) end
        if d.Magnitude>0 then d=d.Unit end; flyBV.Velocity=d*P.flySpeed.v; flyBG.CFrame=cf
    end)
end,function()
    S.fly=false; if flyHB then flyHB:Disconnect();flyHB=nil end
    if flyBV then flyBV:Destroy();flyBV=nil end; if flyBG then flyBG:Destroy();flyBG=nil end
    if LP.Character then LP.Character.Humanoid.PlatformStand=false end
    removeFX("fire"); removeFX("spark")
end,9)

section(tP,"Combat",10)
mkToggle(tP,{id="god",name="God Mode",col=C.YELLOW,options={
    {key="godFF",lbl="Force Field visible",onChange=function(v)
        if LP.Character then
            if v then Instance.new("ForceField",LP.Character).Visible=true
            else local ff=LP.Character:FindFirstChildOfClass("ForceField"); if ff then ff:Destroy() end end
        end
    end},
}},function()
    S.god=true; if LP.Character then LP.Character.Humanoid.MaxHealth=math.huge; LP.Character.Humanoid.Health=math.huge end
end,function()
    S.god=false; if LP.Character then LP.Character.Humanoid.MaxHealth=100; LP.Character.Humanoid.Health=100 end
    if LP.Character then local ff=LP.Character:FindFirstChildOfClass("ForceField"); if ff then ff:Destroy() end end
end,11)

mkToggle(tP,{id="autoheal",name="Auto-Heal",col=C.GREEN,sliders={"healRate"}},function()
    S.autoheal=true
    task.spawn(function()
        while S.autoheal do
            if LP.Character then local h=LP.Character:FindFirstChildOfClass("Humanoid"); if h then h.Health=h.MaxHealth end end
            task.wait(P.healRate.v)
        end
    end)
end,function() S.autoheal=false end,12)

mkToggle(tP,{id="antirag",name="Anti-Ragdoll",col=C.ORANGE},function()
    S.antirag=true
end,function()
    S.antirag=false
end,13)

mkToggle(tP,{id="hitbox",name="Hitbox Expander",col=C.RED,sliders={"hitboxSz"},options={
    {key="hitboxInvis",lbl="Hitbox invisible",desc="Transparence = 1"},
}},function() S.hitbox=true end,function() S.hitbox=false end,14)

section(tP,"Téléport",15)
mkButton(tP,{id="tpspawn",name="TP au Spawn",col=C.PINK},function()
    if LP.Character then LP.Character.HumanoidRootPart.CFrame=CFrame.new(0,10,0); notify("TÉLÉPORTÉ","Spawn (0,10,0)","on") end
end,16)
mkButton(tP,{id="tpcursor",name="TP au Curseur",col=C.PINK},function()
    local m=LP:GetMouse(); if m.Target then LP.Character.HumanoidRootPart.CFrame=CFrame.new(m.Hit.Position+Vector3.new(0,3,0)); notify("TÉLÉPORTÉ","Curseur","on") end
end,17)
mkButton(tP,{id="tphead",name="TP sur un joueur",col=C.PINK},function()
    for _,pl in pairs(Players:GetPlayers()) do
        if pl~=LP and pl.Character then
            LP.Character.HumanoidRootPart.CFrame=pl.Character.HumanoidRootPart.CFrame*CFrame.new(3,0,0)
            notify("TÉLÉPORTÉ","Sur "..pl.Name,"on"); break
        end
    end
end,18)
mkButton(tP,{id="headsize",name="Changer taille tête",col=C.ACCENT2},function()
    if LP.Character then
        local h=LP.Character:FindFirstChild("Head"); if h then h.Size=Vector3.new(P.headSz.v,P.headSz.v,P.headSz.v) end
        notify("TÊTE","Taille "..math.floor(P.headSz.v),"on")
    end
end,19)

-- ================================================================  TAB: VISUAL
section(tV,"Rendu",1)
mkToggle(tV,{id="fullbright",name="Fullbright",col=C.YELLOW},function()
    S.fullbright=true; Lighting.Brightness=10; Lighting.ClockTime=14; Lighting.FogEnd=1e6; Lighting.GlobalShadows=false; Lighting.Ambient=Color3.new(1,1,1); Lighting.OutdoorAmbient=Color3.new(1,1,1)
end,function()
    S.fullbright=false; Lighting.Brightness=1; Lighting.GlobalShadows=true; Lighting.Ambient=Color3.fromRGB(127,127,127); Lighting.OutdoorAmbient=Color3.fromRGB(127,127,127)
end,2)

mkToggle(tV,{id="crosshair",name="Crosshair",col=C.PINK,options={
    {key="crossDot",lbl="Style point (au lieu de croix)"},
}},function() S.crosshair=true end,function() S.crosshair=false end,3)

local CHA=Instance.new("Frame",Gui); CHA.Size=UDim2.new(0,18,0,2); CHA.Position=UDim2.new(0.5,-9,0.5,-1); CHA.BackgroundColor3=C.ACCENT2; CHA.BorderSizePixel=0; CHA.Visible=false
local CVA=Instance.new("Frame",Gui); CVA.Size=UDim2.new(0,2,0,18); CVA.Position=UDim2.new(0.5,-1,0.5,-9); CVA.BackgroundColor3=C.ACCENT2; CVA.BorderSizePixel=0; CVA.Visible=false
local CDot=Instance.new("Frame",Gui); CDot.Size=UDim2.new(0,6,0,6); CDot.Position=UDim2.new(0.5,-3,0.5,-3); CDot.BackgroundColor3=C.ACCENT2; CDot.BorderSizePixel=0; corner(CDot,3); CDot.Visible=false
RS.RenderStepped:Connect(function()
    if S.crosshair then
        if O.crossDot then CHA.Visible=false; CVA.Visible=false; CDot.Visible=true
        else CHA.Visible=true; CVA.Visible=true; CDot.Visible=false end
    else CHA.Visible=false; CVA.Visible=false; CDot.Visible=false end
end)

mkToggle(tV,{id="fpsshow",name="FPS Counter",col=C.CYAN},function() S.fpsshow=true end,function() S.fpsshow=false end,4)

-- FPS display
local FPSFrame=Instance.new("Frame",Gui); FPSFrame.Size=UDim2.new(0,90,0,22); FPSFrame.Position=UDim2.new(0,10,0,10); FPSFrame.BackgroundColor3=C.BG2; FPSFrame.BorderSizePixel=0; FPSFrame.Visible=false; corner(FPSFrame,6); stroke(FPSFrame,C.BG3,1)
local FPSL=lbl(FPSFrame,"FPS: —",11,FB,C.CYAN); FPSL.Position=UDim2.new(0,8,0,0)
local fpsT,fpsF=tick(),0
RS.RenderStepped:Connect(function() fpsF=fpsF+1; if tick()-fpsT>=1 then FPSFrame.Visible=S.fpsshow; FPSL.Text="FPS: "..fpsF; fpsF=0; fpsT=tick() end end)

mkToggle(tV,{id="fov",name="FOV Personnalisé",col=C.BLUE,sliders={"fov"}},function()
    S.fovon=true; Cam.FieldOfView=P.fov.v
end,function()
    S.fovon=false; Cam.FieldOfView=70
end,5)

mkToggle(tV,{id="thirdp",name="Troisième personne",col=C.ACCENT2,sliders={"camZoom"}},function()
    S.thirdp=true; LP.CameraMode=Enum.CameraMode.Classic; LP.CameraMaxZoomDistance=P.camZoom.v; LP.CameraMinZoomDistance=P.camZoom.v
end,function()
    S.thirdp=false; LP.CameraMaxZoomDistance=400; LP.CameraMinZoomDistance=0.5
end,6)

section(tV,"ESP",7)
local espC={}
mkToggle(tV,{id="esp",name="Player ESP",col=C.ACCENT2,options={
    {key="espHealth",lbl="Barre de vie",onChange=function() end},
    {key="espDist",lbl="Afficher distance",onChange=function() end},
    {key="espBoxes",lbl="Boîtes (highlight)",onChange=function() end},
}},function()
    S.esp=true
    local function mkESP(p)
        if p==LP then return end
        local function make()
            if not p.Character then return end; local hrp=p.Character:FindFirstChild("HumanoidRootPart"); if not hrp then return end
            if hrp:FindFirstChild("NV_ESP") then return end
            local bb=Instance.new("BillboardGui",hrp); bb.Name="NV_ESP"; bb.Size=UDim2.new(0,90,0,O.espHealth and 36 or 22); bb.StudsOffset=Vector3.new(0,4,0); bb.AlwaysOnTop=true
            local nl=lbl(bb,p.Name,12,FB,C.ACCENT2); nl.TextXAlignment=Enum.TextXAlignment.Center; nl.TextStrokeTransparency=0.3
            if O.espHealth then
                local hbg=Instance.new("Frame",bb); hbg.Size=UDim2.new(1,0,0,6); hbg.Position=UDim2.new(0,0,1,-6); hbg.BackgroundColor3=C.RED; hbg.BorderSizePixel=0
                local hfg=Instance.new("Frame",hbg); hfg.BackgroundColor3=C.GREEN; hfg.BorderSizePixel=0; hfg.Size=UDim2.new(1,0,1,0)
                RS.Heartbeat:Connect(function() if p.Character then local h=p.Character:FindFirstChildOfClass("Humanoid"); if h then hfg.Size=UDim2.new(h.Health/math.max(h.MaxHealth,1),0,1,0) end end end)
            end
            if O.espBoxes then
                local sel=Instance.new("SelectionBox",hrp); sel.Name="NV_ESPBOX"; sel.Adornee=hrp; sel.Color3=C.ACCENT2; sel.LineThickness=0.05; sel.SurfaceTransparency=0.8; sel.SurfaceColor3=C.ACCENT2
            end
        end
        make(); espC[p]=p.CharacterAdded:Connect(function() task.wait(0.5); make() end)
    end
    for _,p in pairs(Players:GetPlayers()) do mkESP(p) end
    espC.__add=Players.PlayerAdded:Connect(mkESP)
end,function()
    S.esp=false
    for k,v in pairs(espC) do if typeof(v)=="RBXScriptConnection" then v:Disconnect() end; espC[k]=nil end
    for _,p in pairs(Players:GetPlayers()) do
        if p.Character then local hrp=p.Character:FindFirstChild("HumanoidRootPart"); if hrp then for _,v in pairs(hrp:GetChildren()) do if v.Name=="NV_ESP" or v.Name=="NV_ESPBOX" then v:Destroy() end end end end
    end
end,8)

-- ================================================================  TAB: WORLD
section(tW,"Éclairage",1)
mkToggle(tW,{id="timeloop",name="Heure Dynamique",col=C.YELLOW,sliders={"timeHour"}},function()
    S.timeloop=true
    task.spawn(function()
        while S.timeloop do Lighting.ClockTime=P.timeHour.v; task.wait(0.1) end
    end)
end,function() S.timeloop=false end,2)
mkButton(tW,{id="wnoon",name="Midi",col=C.YELLOW},function() Lighting.TimeOfDay="12:00:00"; notify("MONDE","Midi","on") end,3)
mkButton(tW,{id="wmid",name="Minuit",col=C.ACCENT},function() Lighting.TimeOfDay="00:00:00"; notify("MONDE","Minuit","on") end,4)
mkButton(tW,{id="wfog",name="Supprimer brouillard",col=C.ACCENT2},function() Lighting.FogEnd=1e6; Lighting.FogStart=1e6; notify("MONDE","Brouillard supprimé","on") end,5)
mkToggle(tW,{id="nofog",name="Contrôle brouillard",col=C.BLUE,sliders={"fogDist"},options={{key="noShadow",lbl="Supprimer ombres",onChange=function(v) Lighting.GlobalShadows=not v end}}},function()
    S.fogon=true
    task.spawn(function()
        while S.fogon do Lighting.FogEnd=P.fogDist.v; Lighting.FogStart=P.fogDist.v*0.5; task.wait(0.1) end
    end)
end,function() S.fogon=false end,6)

section(tW,"Gravité",7)
mkToggle(tW,{id="gravloop",name="Gravité Personnalisée",col=C.PINK,sliders={"gravity"}},function()
    S.gravloop=true
    task.spawn(function()
        while S.gravloop do workspace.Gravity=P.gravity.v; task.wait(0.1) end
    end)
end,function() S.gravloop=false; workspace.Gravity=196 end,8)
mkButton(tW,{id="gmoon",name="Gravité Lune  (20%)",col=Color3.fromRGB(200,190,255)},function() workspace.Gravity=38; notify("GRAVITÉ","Lune — 38","on") end,9)
mkButton(tW,{id="gnorm",name="Gravité Normale",col=C.GREEN},function() workspace.Gravity=196; notify("GRAVITÉ","Normale — 196","on") end,10)
mkButton(tW,{id="gzero",name="Zéro Gravité",col=C.CYAN},function() workspace.Gravity=0; notify("GRAVITÉ","0 G","on") end,11)
mkButton(tW,{id="gheavy",name="Super Lourde  (×5)",col=C.ORANGE},function() workspace.Gravity=980; notify("GRAVITÉ","980","on") end,12)

section(tW,"Utilitaires",13)
mkToggle(tW,{id="antiaafk",name="Anti-AFK",col=C.GREEN},function()
    S.antiaafk=true
    pcall(function() local VU=game:GetService("VirtualUser"); LP.Idled:Connect(function() if S.antiaafk then VU:Button2Down(Vector2.zero,CFrame.new()) end end) end)
    task.spawn(function() while S.antiaafk do LP:Move(Vector3.zero); task.wait(55) end end)
end,function() S.antiaafk=false end,14)

-- ================================================================  TAB: SERVER
section(tS,"Actions",1)
mkButton(tS,{id="copyname",name="Copier pseudo",col=C.ACCENT},function() pcall(setclipboard,LP.Name); notify("COPIÉ",LP.Name,"on") end,2)
mkButton(tS,{id="reloadchar",name="Recharger personnage",col=C.ACCENT2},function() LP:LoadCharacter(); notify("PERSO","Rechargé","on") end,3)
mkButton(tS,{id="rejoin",name="Rejoin le serveur",col=C.YELLOW},function() game:GetService("TeleportService"):Teleport(game.PlaceId,LP) end,4)
mkButton(tS,{id="servhop",name="Server Hop",col=C.ORANGE},function()
    local servers={}; local ok,res=pcall(function()
        return game:GetService("HttpService"):JSONDecode(game:GetService("HttpService"):GetAsync("https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Asc&limit=100"))
    end)
    if ok and res and res.data then
        for _,s in pairs(res.data) do if s.id~=game.JobId then table.insert(servers,s.id) end end
        if #servers>0 then game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId,servers[math.random(1,#servers)],LP) end
    else notify("ERREUR","HttpService non disponible","off") end
end,5)
mkButton(tS,{id="printplrs",name="Afficher tous les joueurs",col=C.CYAN},function()
    local msg=""
    for _,p in pairs(Players:GetPlayers()) do msg=msg..p.Name.." | " end
    notify("JOUEURS",msg,"on"); print("[NOVA] "..msg)
end,6)

section(tS,"Exécuteur Lua",7)
local ExBg=Instance.new("Frame",tS.scr); ExBg.Size=UDim2.new(1,0,0,110); ExBg.BackgroundColor3=C.BG2; ExBg.BorderSizePixel=0; ExBg.LayoutOrder=8; corner(ExBg,8); stroke(ExBg,C.BG3,1.5)
local ExBox=Instance.new("TextBox",ExBg); ExBox.Size=UDim2.new(1,-10,0,82); ExBox.Position=UDim2.new(0,5,0,4); ExBox.BackgroundColor3=C.BG; ExBox.BorderSizePixel=0; ExBox.PlaceholderText="-- Lua ici..."; ExBox.Text=""; ExBox.TextColor3=C.TEXT; ExBox.PlaceholderColor3=C.SUB; ExBox.TextSize=10; ExBox.Font=FC; ExBox.TextXAlignment=Enum.TextXAlignment.Left; ExBox.TextYAlignment=Enum.TextYAlignment.Top; ExBox.MultiLine=true; ExBox.ClearTextOnFocus=false; corner(ExBox,6)
local ExBtn=Instance.new("TextButton",ExBg); ExBtn.Size=UDim2.new(1,-10,0,20); ExBtn.Position=UDim2.new(0,5,0,88); ExBtn.BackgroundColor3=C.ACCENT; ExBtn.Text="EXÉCUTER"; ExBtn.TextSize=11; ExBtn.Font=FB; ExBtn.TextColor3=C.TEXT; ExBtn.BorderSizePixel=0; corner(ExBtn,5)
ExBtn.MouseButton1Click:Connect(function()
    local fn,err=loadstring(ExBox.Text)
    if fn then local ok,re=pcall(fn); if ok then notify("EXEC","OK","on") else notify("EXEC ERREUR",tostring(re),"off") end
    else notify("COMPILE ERR",tostring(err),"off") end
end)

-- ================================================================  RUNTIME LOOPS
RS.Stepped:Connect(function()
    if S.noclip and LP.Character then for _,v in pairs(LP.Character:GetDescendants()) do if v:IsA("BasePart") then v.CanCollide=false end end end
    if S.antirag and LP.Character then local h=LP.Character:FindFirstChildOfClass("Humanoid"); if h then h:SetStateEnabled(Enum.HumanoidStateType.Ragdoll,false); h:SetStateEnabled(Enum.HumanoidStateType.FallingDown,false) end end
    if S.hitbox then
        for _,p in pairs(Players:GetPlayers()) do
            if p~=LP and p.Character then local hrp=p.Character:FindFirstChild("HumanoidRootPart"); if hrp then hrp.Size=Vector3.new(P.hitboxSz.v,P.hitboxSz.v,P.hitboxSz.v); if O.hitboxInvis then hrp.Transparency=1 end end end
        end
    end
    if S.swimair and LP.Character then LP.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Swimming) end
    if S.sprint and LP.Character then local h=LP.Character:FindFirstChildOfClass("Humanoid"); if h then if UIS:IsKeyDown(Enum.KeyCode.LeftShift) then h.WalkSpeed=P.sprintSpd.v else h.WalkSpeed=16 end end end
    if S.fovon then Cam.FieldOfView=P.fov.v end
end)

-- ================================================================  KEYBIND HANDLER
UIS.InputBegan:Connect(function(inp,gpe)
    if gpe then return end; if PickActive then return end
    if inp.KeyCode==Enum.KeyCode.Insert then toggleMenu() end
    for id,entry in pairs(KB) do if entry.kc and entry.kc==inp.KeyCode and entry.fn then pcall(entry.fn) end end
end)

-- ================================================================  BOOT
notify("NOVA MENU v4","INSERT = toggle  |  ⚙ = paramètres & touche","on")
print("✦ NOVA MENU v4 | INSERT toggle | kawaiifirecat/nova-menu")
