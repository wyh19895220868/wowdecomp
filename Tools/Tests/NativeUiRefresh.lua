dofile("Tools/Tests/WowUiMock.lua")
-- WoW frame instances use nil for addon state, not API fallback methods.
local function prepare(name)
    local bar = CreateFrame("StatusBar", name)
    local old = getmetatable(bar).__index
    getmetatable(bar).__index = function(t, key)
        if string.sub(key, 1, 6) == "native" or key == "TextString" then return nil end
        return old(t, key)
    end
    local create = bar.CreateFontString
    bar.CreateFontString = function(self, ...)
        local label = create(self, ...)
        local lookup = getmetatable(label).__index
        getmetatable(label).__index = function(t, key)
            if string.sub(key, 1, 6) == "native" then return nil end
            return lookup(t, key)
        end
        return label
    end
end
for _, unit in ipairs({"Player", "Target", "Pet", "Focus"}) do
    prepare(unit .. "FrameHealthBar"); prepare(unit .. "FrameManaBar")
end
prepare("TargetFrameToTHealthBar")
for i = 1, 4 do prepare("PartyMemberFrame" .. i .. "HealthBar"); prepare("PartyMemberFrame" .. i .. "ManaBar") end
dofile(arg[1] or "Interface/NativeUI/NativeUI.lua")
Tick(0.1)
local readValue = NativeUnitValue
local ready = false
function NativeUnitValue(unit, key)
    if unit ~= "target" then return readValue(unit, key) end
    if not ready then return nil end
    metrics.reads = metrics.reads + 1
    if key == "INT256" then return "1" end
    if key == "CUR_HEALTH" or key == "MAX_HEALTH" then return "45" end
end
local stock = TargetFrameHealthBar:CreateFontString("TargetFrameHealthBarText")
stock:SetText("42"); stock:Show()
assert(hooks.TargetFrame_Update, "target frame redraw has no native owner")
hooks.TargetFrame_Update()
assert(not stock:IsShown(), "pending target exposes the compatibility value 42")
assert(TargetFrameHealthBar.nativeHealthRight:GetText() == "", "pending target keeps the previous target's text")
ready = true
hooks.TargetFrame_Update()
assert(TargetFrameHealthBar.nativeHealthRight:GetText() == "45", "authoritative target value 45 not shown")
stock:Show(); stock:SetText("42")
TargetFrameHealthBar:SetMinMaxValues(0, 42); TargetFrameHealthBar:SetValue(42)
hooks.UnitFrameHealthBar_Update(TargetFrameHealthBar)
assert(not stock:IsShown() and TargetFrameHealthBar.nativeHealthRight:GetText() == "45",
    "stock redraw changes target value back to 42")
print("Target 42 -> 45 regression: placeholder hidden, authoritative text survives stock redraw")
metrics.reads, metrics.values = 0, 0
hooks.TextStatusBar_UpdateTextString(TargetFrameHealthBar)
print("one target text update: native reads=" .. metrics.reads .. ", bar writes=" .. metrics.values)
assert(metrics.reads <= 3, "one target update refreshes every unit bar")
metrics.values = 0
for i = 1, 100 do Tick(0.1) end
print("unchanged values across 100 ticks: bar writes=" .. metrics.values)
assert(metrics.values == 0, "unchanged health rewrites every bar on every poll")

-- A target can have its INT256 per-bar snapshot before the multi-bar query.
local targetQueryData, targetQueryPending = nil, true
Dream_GetCreGuidLow = function() return 299 end
DreamCustomTargetHealthData = {}
function Dream_GetCustomTargetHealth()
    return targetQueryData, targetQueryPending
end
function NativeUnitValue(unit, key)
    if unit ~= "target" then return readValue(unit, key) end
    if key == "INT256" then return "1" end
    if key == "CUR_HEALTH" or key == "MAX_HEALTH" then return "42" end
end
stock:SetText("42"); stock:Show()
hooks.TargetFrame_Update()
assert(TargetFrameHealthBar.nativeHealthRight:GetText() == "",
    "INT256 snapshot exposes 42 while the selected target query is pending")
assert(not stock:IsShown(), "pending multi-bar query leaves the stock projection visible")

targetQueryData = { MaxMultipleHp = 5, TotalHealthText = "2500000000/12500000000" }
targetQueryPending = false
hooks.TargetFrame_Update()
assert(TargetFrameHealthBar.nativeHealthRight:GetText() == "25亿/125亿",
    "multi-bar query did not replace the per-bar snapshot with 25亿/125亿")
stock:SetText("42"); stock:Show()
hooks.UnitFrameHealthBar_Update(TargetFrameHealthBar)
assert(not stock:IsShown() and TargetFrameHealthBar.nativeHealthRight:GetText() == "25亿/125亿",
    "stock redraw replaced the complete multi-bar health with 42")
print("Target INT256 42 -> multi-bar 25亿/125亿 readiness regression passed")
print("Native UI refresh regression passed")
