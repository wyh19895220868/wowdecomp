dofile("Tools/Tests/WowUiMock.lua")
TargetFrame = CreateFrame("Frame", "TargetFrame")
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

-- A target can have its compatibility fields before the native snapshot.
-- The plugin query is intentionally stale here: the avatar frame must ignore it.
local targetQueryData, targetQueryPending = nil, true
local targetQueryReads = 0
Dream_GetCreGuidLow = function() return 299 end
DreamCustomTargetHealthData = {}
function Dream_GetCustomTargetHealth()
    targetQueryReads = targetQueryReads + 1
    return targetQueryData, targetQueryPending
end
local nativeTargetCurrent, nativeTargetMaximum, nativeTargetBars
local nativeTargetCurrentBars, nativeTargetTotalCurrent, nativeTargetTotalMaximum
function NativeUnitValue(unit, key)
    if unit ~= "target" then return readValue(unit, key) end
    if key == "INT256" then return "1" end
    if key == "CUR_HEALTH" then return nativeTargetCurrent end
    if key == "MAX_HEALTH" then return nativeTargetMaximum end
    if key == "HEALTH_BARS" then return nativeTargetBars end
    if key == "CURRENT_HEALTH_BARS" then return nativeTargetCurrentBars end
    if key == "TOTAL_HEALTH" then return nativeTargetTotalCurrent end
    if key == "MAX_TOTAL_HEALTH" then return nativeTargetTotalMaximum end
end
stock:SetText("42"); stock:Show()
hooks.TargetFrame_Update()
assert(TargetFrameHealthBar.nativeHealthRight:GetText() == "",
    "compatibility target value is visible before the native snapshot")
assert(not stock:IsShown(), "pending native snapshot leaves the stock projection visible")
assert(targetQueryReads == 0, "native target frame called the multi-bar plugin query")

nativeTargetCurrent, nativeTargetMaximum, nativeTargetBars = "2500000000", "12500000000", "5"
nativeTargetCurrentBars, nativeTargetTotalCurrent, nativeTargetTotalMaximum = "3", "32500000000", "62500000000"
targetQueryData = { MaxMultipleHp = 5, TotalHealthText = "999/999" }
targetQueryPending = false
hooks.TargetFrame_Update()
assert(TargetFrameHealthBar.nativeHealthRight:GetText() == "25亿",
    "target frame did not show the single bar value 25亿")
assert(NativeUITargetMultiBar and NativeUITargetMultiBar:IsShown(), "native multi-bar panel is hidden")
assert(NativeUITargetMultiBar.countText:GetText() == "|cFF00FFFF3X|r", "native bar count is not 3X")
assert(NativeUITargetMultiBar.total:GetText() == "325亿 / 625亿", "native total text is wrong")
targetQueryData = nil
targetQueryPending = true
hooks.TargetFrame_Update()
assert(TargetFrameHealthBar.nativeHealthRight:GetText() == "25亿",
    "native target frame incorrectly waited for the multi-bar plugin query")
stock:SetText("42"); stock:Show()
hooks.UnitFrameHealthBar_Update(TargetFrameHealthBar)
assert(not stock:IsShown() and TargetFrameHealthBar.nativeHealthRight:GetText() == "25亿",
    "stock redraw replaced the native single bar health with 42")
print("Target compatibility 42 -> native single bar 25亿 regression passed")
nativeTargetCurrent, nativeTargetMaximum, nativeTargetBars = "45000000000", "90000000000", "1"
hooks.TargetFrame_Update()
assert(TargetFrameHealthBar.nativeHealthRight:GetText() == "450亿",
    "single-bar native target unexpectedly displays a health denominator")
assert(not NativeUITargetMultiBar:IsShown(), "single-bar target keeps the multi-bar panel visible")
assert(targetQueryReads == 0, "single-bar target refresh called the multi-bar plugin query")
print("Single-bar native target formatting regression passed")
print("Native UI refresh regression passed")
