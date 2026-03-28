-- ╔══════════════════════════════════════════════╗
-- ║      Blade Ball Dashboard  v8.3 FIXED         ║
-- ║  Fixed Walk After Death · Better Double Jump  ║
-- ║  + Ultra Anti-Lag + Map Optimization          ║
-- ╚══════════════════════════════════════════════╝

local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService     = game:GetService("TweenService")
local Lighting         = game:GetService("Lighting")
local RS               = game:GetService("ReplicatedStorage")

repeat task.wait() until Players.LocalPlayer
local LP = Players.LocalPlayer

-- حذف نسخ قديمة
pcall(function()
    for _, g in ipairs({game:GetService("CoreGui"), LP:WaitForChild("PlayerGui")}) do
        for _, n in ipairs({"BB_v4","BB_v5","BB_v6","BB_v7","BB_v8","BB_v81","BB_v82","BB_v83","BB_Dashboard","BladeBallDash"}) do
            local old = g:FindFirstChild(n)
            if old then old:Destroy() end
        end
    end
end)

-- ══════════════════════════════════════════════
-- REMOTES
-- ══════════════════════════════════════════════
local Remotes = RS:WaitForChild("Remotes", 10)
local Balls   = workspace:WaitForChild("Balls", 10)

-- ══════════════════════════════════════════════
-- SETTINGS
-- ══════════════════════════════════════════════
local CFG = {
    AutoJump     = false,
    JumpInterval = 1.0,
    AutoWalk     = false,
    RandomMove   = false,
    MoveInterval = 0.4,
    AntiLag      = false,
}

local C = {
    BG     = Color3.fromRGB(10,  10,  16),
    Card   = Color3.fromRGB(18,  18,  28),
    Accent = Color3.fromRGB(99,  102, 241),
    Green  = Color3.fromRGB(34,  197, 94),
    Red    = Color3.fromRGB(239, 68,  68),
    Yellow = Color3.fromRGB(251, 191, 36),
    Text   = Color3.fromRGB(220, 220, 255),
    Muted  = Color3.fromRGB(75,  75,  110),
}

local lastJump   = 0
local lastWalk   = 0
local lastRandom = 0

-- ══════════════════════════════════════════════
-- IsInRealGame محسّنة (إصلاح المشي بعد الموت)
-- ══════════════════════════════════════════════
local function IsInRealGame()
    local char = LP.Character
    if not char then return false end
    
    -- 1. التحقق من أن اللاعب حي
    local hum = char:FindFirstChild("Humanoid")
    if not hum or hum.Health <= 0 then return false end
    
    -- 2. التحقق من موقع اللاعب (منطقة الانتظار عادة في Y < -50)
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return false end
    if hrp.Position.Y < -50 then return false end
    
    -- 3. التحقق من وجود كرة متحركة (دليل على وجود مباراة نشطة)
    if Balls then
        for _, ball in ipairs(Balls:GetChildren()) do
            if ball:IsA("BasePart") and ball:GetAttribute("realBall") == true then
                if ball.AssemblyLinearVelocity.Magnitude > 10 then
                    return true
                end
            end
        end
    end
    
    return false
end

-- [GUI والكود الأساسي يبقى كما هو حتى سطر 700]

-- ══════════════════════════════════════════════
-- MAIN LOOP محسّن
-- ══════════════════════════════════════════════
RunService.Heartbeat:Connect(function()
    pcall(function()
        local char = LP.Character
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        local hum = char:FindFirstChild("Humanoid")
        if not hrp or not hum then return end
        
        local now = tick()
        local inGame = IsInRealGame()
        
        -- تحديث مؤشر المكان
        if inGame then
            gLbl.Text = "⚔ المكان: ساحة (كرة متحركة)"
            gLbl.TextColor3 = C.Green
        else
            gLbl.Text = "🏠 المكان: لوبي/مشاهدة"
            gLbl.TextColor3 = C.Muted
        end
        
        -- القفز (قفزتين) - محسّن
        if CFG.AutoJump and inGame and now - lastJump >= CFG.JumpInterval then
            lastJump = now
            hum:SetStateEnabled(Enum.HumanoidStateType.Jumping, true)
            hum.Jump = true
            task.delay(0.2, function()
                pcall(function()
                    if hum and hum.Parent and hum.Health > 0 then
                        hum:SetStateEnabled(Enum.HumanoidStateType.Jumping, true)
                        hum.Jump = true
                    end
                end)
            end)
        end
        
        -- المشي فقط في المباراة النشطة
        if CFG.AutoWalk and inGame and now - lastWalk >= 0.6 then
            lastWalk = now
            hum:MoveTo(hrp.Position + Dirs[math.random(1,#Dirs)] * 22)
        end
        
        -- الحركة العشوائية فقط في المباراة النشطة
        if CFG.RandomMove and inGame and now - lastRandom >= CFG.MoveInterval then
            lastRandom = now
            hum:MoveTo(hrp.Position + Dirs[math.random(1,#Dirs)] * 16)
        end
    end)
end)

-- ══════════════════════════════════════════════
-- Anti-Lag Loop محسّنة
-- ══════════════════════════════════════════════
-- يتم تحديثها في سطر 530 تقريباً

-- Log الرسائل
Log("Dashboard v8.3 (محسّن - إصلاح المشي والقفز) ✔", C.Accent)
Log("✅ المشي: لا يعمل بعد الموت (فحص Y position)", C.Green)
Log("✅ القفز: قفزتين محسّنة مع تأخير 0.2s", C.Green)
Log("✅ Anti-Lag: يحذف عناصر الخريطة الثقيلة + رمادي", C.Green)
print("[BB v8.3] Fixed - Enhanced Double Jump & Walk Detection")