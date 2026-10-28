-- Built-in FrameXML, loaded once by GameUI before the bundled feature modules.
-- The server supplies the values; decimal strings retain all 256 magnitude bits.
-- Guard against accidental duplicate execution in the same Lua state.
if NativeUI_BridgeLoaded then return end
NativeUI_BridgeLoaded = true
-- Diagnostic bridge version; reloads are owned by the GameUI lifecycle.
NativeUI_BridgeVersion = "2"

-- Register with the stock Interface Options so the feature is discoverable.
if InterfaceOptions_AddCategory then
    local features = CreateFrame("Frame", "NativeUIFeaturesPanel", UIParent)
    features.name = "特色"
    features:Hide()

    local title = features:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", 16, -16)
    title:SetText("特色")

    local fishing = CreateFrame("CheckButton", "NativeUIAutoFishing", features, "InterfaceOptionsCheckButtonTemplate")
    fishing:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -16)
    _G[fishing:GetName() .. "Text"]:SetText("钓鱼上钩自动收杆")
    fishing.tooltipText = "上钩后自动收杆；开启自动拾取可自动收取鱼获。下钩仍需手动。"
    fishing:SetScript("OnClick", function(self)
        SetCVar("autoFishing", self:GetChecked() and "1" or "0")
    end)

    local description = features:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    description:SetPoint("TOPLEFT", fishing, "BOTTOMLEFT", 4, -8)
    description:SetText("配合“控制”中的“自动拾取”使用；下钩仍需手动。")

    local antiIdle = CreateFrame("CheckButton", "NativeUIAntiIdle", features, "InterfaceOptionsCheckButtonTemplate")
    antiIdle:SetPoint("TOPLEFT", description, "BOTTOMLEFT", -4, -12)
    _G[antiIdle:GetName() .. "Text"]:SetText("挂机不掉线")
    antiIdle.tooltipText = "在游戏内定期发送心跳，避免长时间不操作被服务器断开。"
    antiIdle:SetScript("OnClick", function(self)
        SetCVar("antiIdle", self:GetChecked() and "1" or "0")
    end)

    local function addVideoToggle(name, label, tip, cvar, y)
        local parent = VideoOptionsFrame or UIParent
        local check = CreateFrame("CheckButton", name, parent, "InterfaceOptionsCheckButtonTemplate")
        check:SetPoint("BOTTOMLEFT", parent, "BOTTOMLEFT", 32, y)
        check:SetFrameStrata("DIALOG")
        local text = _G[check:GetName() .. "Text"]
        if text then text:SetText(label) end
        check.tooltipText = tip
        check:SetScript("OnClick", function(self)
            SetCVar(cvar, self:GetChecked() and "1" or "0")
        end)
        local function sync()
            check:SetChecked(GetCVar(cvar) == "1")
        end
        if parent.HookScript then parent:HookScript("OnShow", sync) end
        sync()
    end
    addVideoToggle("NativeUILootBeam", "掉落光柱", "地面掉落物品显示品质颜色光柱。", "lootBeam", 46)

    features.refresh = function()
        fishing:SetChecked(GetCVar("autoFishing") == "1")
        antiIdle:SetChecked(GetCVar("antiIdle") == "1")
    end
    features.default = function()
        SetCVar("autoFishing", GetCVarDefault("autoFishing"))
        SetCVar("antiIdle", GetCVarDefault("antiIdle"))
        features.refresh()
    end
    features:SetScript("OnShow", features.refresh)
    InterfaceOptions_AddCategory(features)
end

local function value(unit, key) return NativeUnitValue(unit, key) end
local updating = false
local bars = {
    {"PlayerFrameHealthBar", "player", "HEALTH"}, {"PlayerFrameManaBar", "player", "POWER"},
    {"TargetFrameHealthBar", "target", "HEALTH"}, {"TargetFrameManaBar", "target", "POWER"},
    {"PetFrameHealthBar", "pet", "HEALTH"}, {"PetFrameManaBar", "pet", "POWER"},
    {"FocusFrameHealthBar", "focus", "HEALTH"}, {"FocusFrameManaBar", "focus", "POWER"},
    {"TargetFrameToTHealthBar", "targettarget", "HEALTH"},
}
for i = 1, 4 do
    bars[#bars + 1] = {"PartyMemberFrame" .. i .. "HealthBar", "party" .. i, "HEALTH"}
    bars[#bars + 1] = {"PartyMemberFrame" .. i .. "ManaBar", "party" .. i, "POWER"}
end
-- 256-bit amount formatting that matches NativeUIFormat.h in the client:
-- 万 (10^4), 亿 (10^8), 兆 (10^12), 京 (10^16); one truncated decimal.
-- Use the same truncation as the C++ combat text formatter.
local amountUnits = {
    {24, "秭"}, {20, "垓"}, {16, "京"}, {12, "兆"}, {8, "亿"}, {4, "万"},
}

local function formatAmount(value)
    if value == nil then return "0" end
    local digits = string.gsub(tostring(value), "[,%s]", "")
    local sign = string.sub(digits, 1, 1) == "-" and "-" or ""
    if sign ~= "" then digits = string.sub(digits, 2) end
    if string.find(digits, "[^%d]") then return sign .. digits end
    digits = string.gsub(digits, "^0+", "")
    if digits == "" then return "0" end

    if string.len(digits) > 28 then
        return sign .. string.sub(digits, 1, 1) .. "." .. string.sub(digits, 2, 2) .. "e+" .. (string.len(digits) - 1)
    end

    for _, unit in ipairs(amountUnits) do
        local exponent = unit[1]
        if string.len(digits) > exponent then
            local split = string.len(digits) - exponent
            local integerPart = string.sub(digits, 1, split)
            local fractionPart = string.sub(digits, split + 1, split + 1)
            if fractionPart ~= "0" then
                return sign .. integerPart .. "." .. fractionPart .. unit[2]
            end
            return sign .. integerPart .. unit[2]
        end
    end

    return sign .. digits
end

local function barPrefix(name)
    if string.sub(name, 1, 11) == "TargetFrame" then return "TargetFrameTextureFrame" end
    if string.sub(name, 1, 11) == "PlayerFrame" then return "PlayerFrameTextureFrame" end
    return nil
end

-- Hide the stock FontStrings that still carry 32-bit values (the player frame
-- keeps "100%" on a second object) so only one label stays visible.
local function hideStockBarText(bar, name, keep, keepRight)
    local prefix = barPrefix(name)
    local rest = prefix and string.sub(name, 12) or nil

    for _, suffix in ipairs({"Text", "TextLeft", "TextRight"}) do
        local object = _G[name .. suffix]
        if object and object ~= keep and object ~= keepRight then object:Hide() end
        if prefix then
            local alternate = _G[prefix .. rest .. suffix]
            if alternate and alternate ~= keep and alternate ~= keepRight then alternate:Hide() end
        end
    end
    if bar.TextString and bar.TextString ~= keep and bar.TextString ~= keepRight then
        bar.TextString:Hide()
    end
end

-- Older Wow64 builds add an unnamed mask -> fill pair below each official bar.
-- Their two unnamed FontStrings cannot be found through the stock global names.
-- Match that exact hierarchy; leave named addon frames and other regions alone.
local legacyOverlayBars = {
    PlayerFrameHealthBar = true, PlayerFrameManaBar = true,
    TargetFrameHealthBar = true, TargetFrameManaBar = true,
}
local function isAnonymousUnitBar(frame)
    if frame:GetName() or not frame.GetObjectType or frame:GetObjectType() ~= "StatusBar" then
        return false
    end
    local minimum, maximum = frame:GetMinMaxValues()
    return minimum == 0 and maximum == 1
end
local function hideLegacyNativeOverlay(bar, name)
    if not legacyOverlayBars[name] or not bar.GetChildren then return end
    for _, mask in ipairs({bar:GetChildren()}) do
        if isAnonymousUnitBar(mask) then
            for _, fill in ipairs({mask:GetChildren()}) do
                if isAnonymousUnitBar(fill) then
                    local labels = 0
                    for _, region in ipairs({fill:GetRegions()}) do
                        if not region:GetName() and region:GetObjectType() == "FontString" then
                            labels = labels + 1
                        end
                    end
                    if labels == 2 then
                        -- Native C++ may Show() the old fill on the next snapshot.
                        -- Parent opacity keeps both its text and opaque mask invisible.
                        mask:SetAlpha(0)
                    end
                end
            end
        end
    end
end

local function createBarLabel(bar, name)
    local template = bar.TextString or _G[bar:GetName() .. "Text"]
    local font, size, flags
    if template then font, size, flags = template:GetFont() end
    if not font and GameFontNormal then font, size, flags = GameFontNormal:GetFont() end
    local text = bar:CreateFontString(name, "OVERLAY")
    text:SetFont(font or "Fonts\\FRIZQT__.TTF", math.min(size or 10, 11), flags or "OUTLINE")
    text:SetTextColor(1, 1, 1)
    text:SetJustifyV("MIDDLE")
    return text
end

local function healthLabels(bar, name)
    local left, right = bar.nativeHealthLeft, bar.nativeHealthRight
    if not left then
        -- Dedicated names prevent stock/native writers from moving or hiding our labels.
        left = createBarLabel(bar, name .. "NativeHealthLeft")
        right = createBarLabel(bar, name .. "NativeHealthRight")
        left:SetPoint("LEFT", bar, "LEFT", 2, 0)
        left:SetJustifyH("LEFT")
        right:SetPoint("RIGHT", bar, "RIGHT", -2, 0)
        right:SetJustifyH("RIGHT")
        bar.nativeHealthLeft, bar.nativeHealthRight = left, right
    end
    local width, height = bar:GetWidth(), bar:GetHeight()
    if bar.nativeHealthWidth ~= width or bar.nativeHealthHeight ~= height then
        left:SetWidth(math.max(1, width * 0.40 - 3))
        right:SetWidth(math.max(1, width * 0.60 - 3))
        left:SetHeight(height)
        right:SetHeight(height)
        bar.nativeHealthWidth, bar.nativeHealthHeight = width, height
    end
    return left, right
end

local function powerLabel(bar, name)
    local text = bar.nativePowerText
    if not text then
        text = createBarLabel(bar, name .. "NativePowerText")
        text:SetPoint("CENTER", bar, "CENTER", 0, 0)
        text:SetJustifyH("CENTER")
        bar.nativePowerText = text
    end
    local width, height = bar:GetWidth(), bar:GetHeight()
    if bar.nativePowerWidth ~= width or bar.nativePowerHeight ~= height then
        text:SetWidth(math.max(1, width - 4))
        text:SetHeight(height)
        bar.nativePowerWidth, bar.nativePowerHeight = width, height
    end
    return text
end

local function setLabelText(label, text)
    if label and label:GetText() ~= text then label:SetText(text) end
end

-- Cache formatting only. Stock updates can still change the bar's range/fill
-- or reveal their own text, so those repairs must run even for unchanged health.
local function setAmountText(label, current, maximum)
    if label.nativeCurrent ~= current or label.nativeMaximum ~= maximum then
        label.nativeCurrent, label.nativeMaximum = current, maximum
        label.nativeAmount = formatAmount(current)
        if maximum then label.nativeAmount = label.nativeAmount .. " / " .. formatAmount(maximum) end
    end
    setLabelText(label, label.nativeAmount)
end

local function targetHealth()
    if not Dream_GetCreGuidLow or not DreamCustomTargetHealthData then return end
    local data, pending
    if Dream_GetCustomTargetHealth then
        data, pending = Dream_GetCustomTargetHealth()
    else
        data = DreamCustomTargetHealthData[Dream_GetCreGuidLow()]
    end
    if not data or (tonumber(data.MaxMultipleHp) or 1) <= 1 then return nil, nil, pending end
    -- The addon retains exact totals even when 900京 * 20 exceeds int64.
    return string.match(data.TotalHealthText or "", "^(%d+)/(%d+)$")
end

local function updateBar(bar, unit, resource)
    if not bar then return end
    local name = bar:GetName()
    if not name then return end
    hideLegacyNativeOverlay(bar, name)
    local current, maximum = value(unit, "CUR_" .. resource), value(unit, "MAX_" .. resource)
    if unit == "target" and resource == "HEALTH" and not value(unit, "INT256") then
        local totalCurrent, totalMaximum, pending = targetHealth()
        if totalCurrent and totalMaximum then
            current, maximum = totalCurrent, totalMaximum
        elseif pending then
            -- An int32 compatibility projection can be small (e.g. 42) even
            -- when actual health is 900京. Never infer readiness from its size.
            current, maximum = nil, nil
        end
    end
    if unit == "target" and not UnitExists(unit) then current, maximum = nil, nil end
    if not current or not maximum then
        -- A GUID-checked native bridge returns no values while the new target is pending.
        if unit == "target" then
            setLabelText(bar.nativeHealthLeft, "")
            setLabelText(bar.nativeHealthRight, "")
            setLabelText(bar.nativePowerText, "")
            hideStockBarText(bar, name)
        end
        return
    end
    -- Floating point is used only for the geometric fraction, never for displayed text.
    local maxNumber = tonumber(maximum) or 0
    local fraction = maxNumber > 0 and math.min(1, math.max(0, tonumber(current) / maxNumber)) or 0
    local low, high = bar:GetMinMaxValues()
    if low ~= 0 or high ~= 1 then bar:SetMinMaxValues(0, 1) end
    if bar:GetValue() ~= fraction then bar:SetValue(fraction) end

    -- One dedicated label layer owns the text; stock and old native layers are suppressed.
    if resource == "HEALTH" then
        local left, right = healthLabels(bar, name)
        -- Show the nearest integer percent; 99.999997% must not appear as 99%.
        -- A living unit with less than half a percent left still displays 1%.
        local percent = math.floor(fraction * 100 + 0.5)
        if fraction > 0 then percent = math.max(1, percent) end
        setLabelText(left, tostring(percent) .. "%")
        setAmountText(right, current)
        hideStockBarText(bar, name, left, right)
        left:Show()
        right:Show()
    else
        local text = powerLabel(bar, name)
        setAmountText(text, current, maximum)
        text:Show()
        hideStockBarText(bar, name, text)
    end
end
local function refreshBars()
    if updating then return end
    updating = true
    for _, spec in ipairs(bars) do updateBar(_G[spec[1]], spec[2], spec[3]) end
    updating = false
end
local barSpecs = {}
for _, spec in ipairs(bars) do barSpecs[spec[1]] = spec end
local function refreshOneBar(bar)
    if updating or not bar or not bar.GetName then return end
    local spec = barSpecs[bar:GetName()]
    if not spec then return end
    updating = true
    updateBar(bar, spec[2], spec[3])
    updating = false
end
if TextStatusBar_UpdateTextString then hooksecurefunc("TextStatusBar_UpdateTextString", refreshOneBar) end
if UnitFrameHealthBar_Update then hooksecurefunc("UnitFrameHealthBar_Update", refreshOneBar) end
if UnitFrameManaBar_Update then hooksecurefunc("UnitFrameManaBar_Update", refreshOneBar) end
local function refreshTarget()
    refreshOneBar(TargetFrameHealthBar)
    refreshOneBar(TargetFrameManaBar)
    refreshOneBar(TargetFrameToTHealthBar)
end
NativeUI_RefreshTargetHealth = refreshTarget
if TargetFrame_Update then hooksecurefunc("TargetFrame_Update", refreshTarget) end

local function setStat(frame, unit, key)
    if not frame then return end
    local text = value(unit or "player", key)
    if not text then return end
    local name = frame:GetName()
    local label = frame.Value or (name and _G[name .. "StatText"])
    if label then label:SetText(formatAmount(text)) end
    frame.nativeUnit, frame.nativeKey = unit or "player", key
    local title = name and _G[name .. "Label"]
    frame.tooltip = (title and title:GetText() or "") .. " " .. text
    frame.tooltip2 = nil
end
local statNames = {"STRENGTH", "AGILITY", "STAMINA", "INTELLECT", "SPIRIT"}
if PaperDollFrame_SetStat then
    hooksecurefunc("PaperDollFrame_SetStat", function(frame, index)
        if statNames[index] then setStat(frame, "player", statNames[index]) end
    end)
end
local statHooks = {
    PaperDollFrame_SetArmor = "ARMOR", PaperDollFrame_SetAttackPower = "ATTACK_POWER",
    PaperDollFrame_SetRangedAttackPower = "RANGED_ATTACK_POWER", PaperDollFrame_SetDamage = "MAINHAND_DAMAGE",
    PaperDollFrame_SetRangedDamage = "RANGED_DAMAGE", PaperDollFrame_SetSpellBonusDamage = "SPELL_POWER",
    PaperDollFrame_SetSpellBonusHealing = "HEALING_POWER", PaperDollFrame_SetSpellPenetration = "ATTR_47",
    PaperDollFrame_SetSpellHaste = "RATING_19", PaperDollFrame_SetDefense = "DEFENSE",
    PaperDollFrame_SetDodge = "DODGE_CHANCE", PaperDollFrame_SetParry = "PARRY_CHANCE",
    PaperDollFrame_SetBlock = "BLOCK_CHANCE", PaperDollFrame_SetResilience = "RESILIENCE",
    PaperDollFrame_SetMeleeCritChance = "MELEE_CRIT", PaperDollFrame_SetRangedCritChance = "RANGED_CRIT",
    PaperDollFrame_SetSpellCritChance = "SPELL_CRIT", PaperDollFrame_SetManaRegen = "MANA_REGEN",
    PaperDollFrame_SetExpertise = "EXPERTISE",
}
for name, key in pairs(statHooks) do
    if _G[name] then
        local field = key
        hooksecurefunc(name, function(frame, unit) setStat(frame, unit, field) end)
    end
end

-- GetMoney remains a numeric compatibility API. The player money labels use
-- decimal slices so even balances above Lua's exact integer range stay exact.
local function refreshMoney(frame)
    if type(frame) == "string" then frame = _G[frame] end
    if not frame or frame.moneyType ~= "PLAYER" then return end
    local exact = value("player", "MONEY")
    if not exact or string.find(exact, "[^%d]") then return end
    -- The wide balance is enabled only by the Wow64 native API.
    if not NativeMoneyString then return end
    local digits = "0000" .. exact
    local gold = string.gsub(string.sub(digits, 1, -5), "^0+", "")
    if gold == "" then gold = "0" end
    local name = frame:GetName()
    if not name then return end
    for _, coin in ipairs({
        {"Gold", gold},
        {"Silver", tostring(tonumber(string.sub(digits, -4, -3)))},
        {"Copper", tostring(tonumber(string.sub(digits, -2)))},
    }) do
        local text = _G[name .. coin[1] .. "ButtonText"]
        if text then text:SetText(coin[2]) end
    end
end
if MoneyFrame_Update then hooksecurefunc("MoneyFrame_Update", refreshMoney) end
if PaperDollFrame_SetRating then
    hooksecurefunc("PaperDollFrame_SetRating", function(frame, index)
        setStat(frame, "player", "RATING_" .. index)
    end)
end

local function nativeTooltip(frame)
    local text = frame.nativeKey and value(frame.nativeUnit or "player", frame.nativeKey)
    if not text then return end
    local label = _G[frame:GetName() .. "Label"]
    GameTooltip:SetOwner(frame, "ANCHOR_RIGHT")
    GameTooltip:ClearLines()
    GameTooltip:AddLine(label and label:GetText() or "", 1, 1, 1)
    GameTooltip:AddLine(text, 1, 1, 1, true)
    if frame.nativeKey == "MAINHAND_DAMAGE" then
        local offhand = value(frame.nativeUnit or "player", "OFFHAND_DAMAGE")
        if offhand then GameTooltip:AddLine((INVTYPE_WEAPONOFFHAND or "") .. ": " .. offhand, 1, 1, 1, true) end
    end
    GameTooltip:Show()
end
for _, name in ipairs({"PaperDollStatTooltip", "CharacterDamageFrame_OnEnter", "CharacterRangedDamageFrame_OnEnter",
    "CharacterSpellBonusDamage_OnEnter", "CharacterSpellCritChance_OnEnter"}) do
    if _G[name] then hooksecurefunc(name, nativeTooltip) end
end

local elapsed, lastRevision = 0, -1
local driver = CreateFrame("Frame")
driver:RegisterEvent("PLAYER_ENTERING_WORLD")
driver:RegisterEvent("PLAYER_MONEY")
driver:RegisterEvent("PLAYER_TARGET_CHANGED")
driver:SetScript("OnEvent", function(_, event)
    if event == "PLAYER_ENTERING_WORLD" then lastRevision = -1; refreshBars() end
    if event == "PLAYER_TARGET_CHANGED" then refreshTarget() end
end)
driver:SetScript("OnUpdate", function(_, dt)
    elapsed = elapsed + dt
    if elapsed < 0.1 then return end
    elapsed = 0
    refreshBars()
    local revision = NativeUIRevision()
    if revision ~= lastRevision then
        lastRevision = revision
        if PaperDollFrame and PaperDollFrame:IsShown() and PaperDollFrame_UpdateStats then
            PaperDollFrame_UpdateStats()
        end
    end
end)
