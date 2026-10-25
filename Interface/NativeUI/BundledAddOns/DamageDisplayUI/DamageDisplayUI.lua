local ADDON_NAME = "DamageDisplayUI"
local LARGE_DAMAGE_PREFIX = "PATTRPANEL"

DamageDisplayUIDB = DamageDisplayUIDB or {}
LargeDamageTextDB = LargeDamageTextDB or {}

local DAMAGE_ANCHOR_X = 0
local DAMAGE_ANCHOR_Y = -40
local LARGE_DAMAGE_ANCHOR_X = 0
local LARGE_DAMAGE_ANCHOR_Y = 20
local DAMAGE_LAYOUT_VERSION = 3
local OLD_DAMAGE_ANCHOR_X = 72
local OLD_DAMAGE_ANCHOR_Y = 72
local OLD_LARGE_DAMAGE_ANCHOR_X = 0
local OLD_LARGE_DAMAGE_ANCHOR_Y = 96
local PREVIOUS_DAMAGE_ANCHOR_X = -190
local PREVIOUS_DAMAGE_ANCHOR_Y = -120
local PREVIOUS_LARGE_DAMAGE_ANCHOR_X = -220
local PREVIOUS_LARGE_DAMAGE_ANCHOR_Y = -170
local OLD_MAX_ACTIVE_TEXTS = 6
local OLD_MAX_QUEUED_TEXTS = 8
local OLD_MERGE_WINDOW = 0.06
local OLD_DELAY_STEP = 0.05
local OLD_DURATION = 0.85
local OLD_DISTANCE = 88
local PREVIOUS_DELAY_STEP = 0.18
local PREVIOUS_DURATION = 1.12

local DEFAULT_DB = {
    enabled = true,
    largeDamageEnabled = true,
    compact = true,
    disableOfficial = true,
    anchorX = DAMAGE_ANCHOR_X,
    anchorY = DAMAGE_ANCHOR_Y,
    largeDamageAnchorX = LARGE_DAMAGE_ANCHOR_X,
    largeDamageAnchorY = LARGE_DAMAGE_ANCHOR_Y,
    fontSize = 30,
    largeDamageFontScale = 1.25,
    maxActiveTexts = 5,
    maxQueuedTexts = 5,
    maxBurstTexts = 5,
    maxLargeDamageTexts = 8,
    mergeWindow = 0.18,
    largeDamageMergeWindow = 0.22,
    normalDamageMergeWindow = 0.18,
    delayStep = 0.22,
    duration = 1.25,
    distance = 72,
    debug = false,
    officialStateVersion = 3,
    layoutVersion = DAMAGE_LAYOUT_VERSION,
}

local LEGACY_LARGE_DAMAGE_DEFAULTS = {
    enabled = true,
    compact = true,
    disableOfficial = true,
    anchorX = LARGE_DAMAGE_ANCHOR_X,
    anchorY = LARGE_DAMAGE_ANCHOR_Y,
    fontScale = 1.25,
    maxTexts = 48,
}

local DAMAGE_SOURCES = {
    MAGICHIT = {
        prefix = "MAGICHIT",
        hitPattern = "^MAGICHIT_HIT:(.*)$",
        hitsPattern = "^MAGICHIT_HITS:(.*)$",
        label = "魔次",
        color = { 1.0, 0.10, 0.10, 1.0 },
        glow = { 1.0, 0.18, 0.18, 0.42 },
    },
    CUT_SYS = {
        prefix = "CUT_SYS",
        hitPattern = "^CT_HIT:(.*)$",
        hitsPattern = "^CT_HITS:(.*)$",
        label = "切割",
        color = { 1.0, 0.50, 0.16, 1.0 },
        glow = { 1.0, 0.78, 0.18, 0.42 },
    },
}

local SCHOOL_COLORS = {
    [1] = { 1.00, 0.86, 0.18 },
    [2] = { 1.00, 0.96, 0.62 },
    [4] = { 1.00, 0.34, 0.18 },
    [8] = { 0.30, 1.00, 0.42 },
    [16] = { 0.40, 0.78, 1.00 },
    [32] = { 0.74, 0.46, 1.00 },
    [64] = { 1.00, 0.46, 0.88 },
}

local SCHOOL_ORDER = { 64, 32, 16, 8, 4, 2, 1 }

local LARGE_DAMAGE_LANES = {
    { -72, 34, -18, 72 },
    { 72, 34, 18, 72 },
    { -38, 58, -12, 78 },
    { 38, 58, 12, 78 },
    { 0, 78, 0, 84 },
    { -108, 52, -20, 74 },
    { 108, 52, 20, 74 },
    { 0, 104, 0, 90 },
}

local OFFICIAL_DAMAGE_CVARS = {
    "floatingCombatTextCombatDamage",
    "floatingCombatTextCombatDamageAllAutos",
    "floatingCombatTextCombatLogPeriodicSpells",
    "floatingCombatTextPetMeleeDamage",
    "floatingCombatTextPetSpellDamage",
    "CombatDamage",
    "CombatDamageAllAutos",
    "CombatLogPeriodicSpells",
    "PetMeleeDamage",
    "PetSpellDamage",
	"CombatHealing",
	"CombatHealingAbsorbSelf",
	"CombatHealingAbsorbTarget",
	"floatingCombatTextCombatHealing",
	"floatingCombatTextCombatHealingAbsorbSelf",
	"floatingCombatTextCombatHealingAbsorbTarget",
}

local OFFICIAL_DAMAGE_CVAR_LOOKUP = {}
for _, cvarName in ipairs(OFFICIAL_DAMAGE_CVARS) do
    OFFICIAL_DAMAGE_CVAR_LOOKUP[cvarName] = true
    OFFICIAL_DAMAGE_CVAR_LOOKUP[string.lower(cvarName)] = true
end

local CHINESE_DAMAGE_UNITS = {
    "",
    "万",
    "亿",
    "兆",
    "京",
    "垓",
    "秭",
    "穰",
    "沟",
    "涧",
}

local State = {
    holder = nil,
    driver = nil,
    largeLayer = nil,
    largeDriver = nil,
    sequence = 0,
    largeSequence = 0,
    activeFrames = {},
    pool = {},
    queue = {},
    pending = {},
    nextDispatchAt = 0,
    chunkBuffers = {},
    largePool = {},
    largeActiveCount = 0,
    lastControlMessageAt = 0,
    lastReadyAck = "未确认",
    lastSourceMessage = "无",
    lastSourceMessageAt = 0,
    sourceMessageCounts = {},
    recentSourcePayloads = {},
    applyingOfficialState = false,
}

_G.LargeDamageTextActive = true

local function IsSameNumber(value, expected)
    return tonumber(value) == expected
end

local function IsSameFloat(value, expected)
    value = tonumber(value)
    return value ~= nil and math.abs(value - expected) < 0.0001
end

local function TrimText(value)
    return (tostring(value or ""):match("^%s*(.-)%s*$")) or ""
end

local function StripMessageColors(message)
    local text = tostring(message or "")
    text = string.gsub(text, "|c%x%x%x%x%x%x%x%x", "")
    text = string.gsub(text, "|r", "")
    return text
end

local function DebugPrint(message)
    if DamageDisplayUIDB and DamageDisplayUIDB.debug and DEFAULT_CHAT_FRAME then
        DEFAULT_CHAT_FRAME:AddMessage("|cffff4444[伤害显示调试]|r " .. tostring(message))
    end
end

local function CopyDefaults()
    if type(DamageDisplayUIDB) ~= "table" then
        DamageDisplayUIDB = {}
    end
	local previousOfficialStateVersion = tonumber(DamageDisplayUIDB.officialStateVersion) or 0
	local previousLayoutVersion = tonumber(DamageDisplayUIDB.layoutVersion) or 0

    for key, value in pairs(DEFAULT_DB) do
        if DamageDisplayUIDB[key] == nil then
            DamageDisplayUIDB[key] = value
        end
    end

    if type(LargeDamageTextDB) ~= "table" then
        LargeDamageTextDB = {}
    end

    for key, value in pairs(LEGACY_LARGE_DAMAGE_DEFAULTS) do
        if LargeDamageTextDB[key] == nil then
            LargeDamageTextDB[key] = value
        end
    end

	-- The 128-bit DMG channel owns outgoing damage text; Blizzard's packet is
	-- limited to 32 bits and would otherwise display INT32_MAX beside it.
	if previousOfficialStateVersion < 3 then
		LargeDamageTextDB.disableOfficial = true
		DamageDisplayUIDB.disableOfficial = true
		DamageDisplayUIDB.officialStateVersion = 3
	end

    if previousLayoutVersion < DAMAGE_LAYOUT_VERSION then
        DamageDisplayUIDB.anchorX = DEFAULT_DB.anchorX
        DamageDisplayUIDB.anchorY = DEFAULT_DB.anchorY
        DamageDisplayUIDB.fontSize = DEFAULT_DB.fontSize
        DamageDisplayUIDB.largeDamageAnchorX = DEFAULT_DB.largeDamageAnchorX
        DamageDisplayUIDB.largeDamageAnchorY = DEFAULT_DB.largeDamageAnchorY
        DamageDisplayUIDB.largeDamageFontScale = DEFAULT_DB.largeDamageFontScale
        DamageDisplayUIDB.layoutVersion = DAMAGE_LAYOUT_VERSION
        LargeDamageTextDB.anchorX = LEGACY_LARGE_DAMAGE_DEFAULTS.anchorX
        LargeDamageTextDB.anchorY = LEGACY_LARGE_DAMAGE_DEFAULTS.anchorY
        LargeDamageTextDB.fontScale = LEGACY_LARGE_DAMAGE_DEFAULTS.fontScale
    end

    if (IsSameNumber(DamageDisplayUIDB.anchorX, OLD_DAMAGE_ANCHOR_X)
            and IsSameNumber(DamageDisplayUIDB.anchorY, OLD_DAMAGE_ANCHOR_Y))
        or (IsSameNumber(DamageDisplayUIDB.anchorX, PREVIOUS_DAMAGE_ANCHOR_X)
            and IsSameNumber(DamageDisplayUIDB.anchorY, PREVIOUS_DAMAGE_ANCHOR_Y)) then
        DamageDisplayUIDB.anchorX = DEFAULT_DB.anchorX
        DamageDisplayUIDB.anchorY = DEFAULT_DB.anchorY
    end

    if (IsSameNumber(LargeDamageTextDB.anchorX, OLD_LARGE_DAMAGE_ANCHOR_X)
            and IsSameNumber(LargeDamageTextDB.anchorY, OLD_LARGE_DAMAGE_ANCHOR_Y))
        or (IsSameNumber(LargeDamageTextDB.anchorX, PREVIOUS_LARGE_DAMAGE_ANCHOR_X)
            and IsSameNumber(LargeDamageTextDB.anchorY, PREVIOUS_LARGE_DAMAGE_ANCHOR_Y)) then
        LargeDamageTextDB.anchorX = LEGACY_LARGE_DAMAGE_DEFAULTS.anchorX
        LargeDamageTextDB.anchorY = LEGACY_LARGE_DAMAGE_DEFAULTS.anchorY
    end

    if IsSameNumber(DamageDisplayUIDB.maxActiveTexts, OLD_MAX_ACTIVE_TEXTS) then
        DamageDisplayUIDB.maxActiveTexts = DEFAULT_DB.maxActiveTexts
    end
    if IsSameNumber(DamageDisplayUIDB.maxQueuedTexts, OLD_MAX_QUEUED_TEXTS) then
        DamageDisplayUIDB.maxQueuedTexts = DEFAULT_DB.maxQueuedTexts
    end
    if IsSameFloat(DamageDisplayUIDB.mergeWindow, OLD_MERGE_WINDOW) then
        DamageDisplayUIDB.mergeWindow = DEFAULT_DB.mergeWindow
    end
    if IsSameFloat(DamageDisplayUIDB.delayStep, OLD_DELAY_STEP)
        or IsSameFloat(DamageDisplayUIDB.delayStep, PREVIOUS_DELAY_STEP) then
        DamageDisplayUIDB.delayStep = DEFAULT_DB.delayStep
    end
    if IsSameFloat(DamageDisplayUIDB.duration, OLD_DURATION)
        or IsSameFloat(DamageDisplayUIDB.duration, PREVIOUS_DURATION) then
        DamageDisplayUIDB.duration = DEFAULT_DB.duration
    end
    if IsSameNumber(DamageDisplayUIDB.distance, OLD_DISTANCE) then
        DamageDisplayUIDB.distance = DEFAULT_DB.distance
    end

    DamageDisplayUIDB.enabled = true
    LargeDamageTextDB.enabled = true
    DamageDisplayUIDB.largeDamageEnabled = LargeDamageTextDB.enabled
    DamageDisplayUIDB.compact = LargeDamageTextDB.compact
    DamageDisplayUIDB.disableOfficial = LargeDamageTextDB.disableOfficial
    DamageDisplayUIDB.largeDamageAnchorX = LargeDamageTextDB.anchorX
    DamageDisplayUIDB.largeDamageAnchorY = LargeDamageTextDB.anchorY
    DamageDisplayUIDB.largeDamageFontScale = LargeDamageTextDB.fontScale
end

local function SplitString(text, separator)
    local result = {}
    if not text or text == "" then
        return result
    end

    local startPos = 1
    while true do
        local foundPos = string.find(text, separator, startPos, true)
        if not foundPos then
            table.insert(result, string.sub(text, startPos))
            break
        end

        table.insert(result, string.sub(text, startPos, foundPos - 1))
        startPos = foundPos + string.len(separator)
    end

    return result
end

local function NormalizeDamageDigits(value)
    if value == nil then
        return nil
    end

    local text = tostring(value)
    text = text:match("^%s*(.-)%s*$") or ""
    text = text:gsub(",", "")

    local first = text:sub(1, 1)
    if first == "-" then
        return nil
    end
    if first == "+" then
        text = text:sub(2)
    end

    if not text:match("^%d+$") then
        return nil
    end

    text = text:gsub("^0+", "")
    if text == "" then
        return nil
    end

    return text
end

local function AddDamageDigits(left, right)
    left = NormalizeDamageDigits(left) or "0"
    right = NormalizeDamageDigits(right) or "0"

    local leftIndex = string.len(left)
    local rightIndex = string.len(right)
    local carry = 0
    local reversed = {}

    while leftIndex > 0 or rightIndex > 0 or carry > 0 do
        local sum = carry

        if leftIndex > 0 then
            sum = sum + string.byte(left, leftIndex) - 48
            leftIndex = leftIndex - 1
        end

        if rightIndex > 0 then
            sum = sum + string.byte(right, rightIndex) - 48
            rightIndex = rightIndex - 1
        end

        table.insert(reversed, string.char(48 + (sum % 10)))
        carry = math.floor(sum / 10)
    end

    local result = {}
    for index = #reversed, 1, -1 do
        table.insert(result, reversed[index])
    end

    return table.concat(result)
end

local function FormatChineseDamageNumber(value)
    local digits = NormalizeDamageDigits(value)
    if not digits then
        return "0"
    end

    local length = string.len(digits)
    local groupIndex = math.floor((length - 1) / 4)
    if groupIndex <= 0 then
        return digits
    end

    if groupIndex + 1 > #CHINESE_DAMAGE_UNITS then
        groupIndex = #CHINESE_DAMAGE_UNITS - 1
    end

    local unit = CHINESE_DAMAGE_UNITS[groupIndex + 1]
    local integerLength = length - (groupIndex * 4)
    local integerPart = string.sub(digits, 1, integerLength)
    local rest = string.sub(digits, integerLength + 1)
    local decimalPlaces = 0

    if string.len(integerPart) == 1 then
        decimalPlaces = 2
    elseif string.len(integerPart) == 2 then
        decimalPlaces = 1
    end

    if decimalPlaces > 0 and rest and rest ~= "" then
        local decimalPart = string.sub(rest .. "0000", 1, decimalPlaces)
        decimalPart = decimalPart:gsub("0+$", "")
        if decimalPart ~= "" then
            return integerPart .. "." .. decimalPart .. unit
        end
    end

    return integerPart .. unit
end

local function FormatWithCommas(value)
    local digits = NormalizeDamageDigits(value)
    if not digits then
        return tostring(value or "")
    end

    local left = #digits % 3
    if left == 0 then
        left = 3
    end

    local parts = { digits:sub(1, left) }
    for index = left + 1, #digits, 3 do
        table.insert(parts, digits:sub(index, index + 2))
    end

    return table.concat(parts, ",")
end

local function FormatLargeDamageNumber(value)
    if LargeDamageTextDB and LargeDamageTextDB.compact == false then
        return FormatWithCommas(value)
    end

    return FormatChineseDamageNumber(value)
end

local function ResolveSpellName(spellId)
    spellId = tonumber(spellId) or 0
    if spellId <= 0 or not GetSpellInfo then
        return nil
    end

    local name = GetSpellInfo(spellId)
    if type(name) ~= "string" or name == "" then
        return nil
    end

    return name
end

local REAL_COMBAT_LOG_FILTER_EVENTS = {
    "CHAT_MSG_COMBAT_SELF_HITS",
    "CHAT_MSG_SPELL_SELF_DAMAGE",
    "CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE",
    "CHAT_MSG_COMBAT_PET_HITS",
    "CHAT_MSG_SPELL_PET_DAMAGE",
    "CHAT_MSG_SPELL_PERIODIC_PET_DAMAGE",
    "CHAT_MSG_COMBAT_CREATURE_VS_SELF_HITS",
    "CHAT_MSG_COMBAT_HOSTILEPLAYER_HITS",
    "CHAT_MSG_SPELL_CREATURE_VS_SELF_DAMAGE",
    "CHAT_MSG_SPELL_HOSTILEPLAYER_DAMAGE",
    "CHAT_MSG_SPELL_PERIODIC_CREATURE_DAMAGE",
    "CHAT_MSG_SPELL_PERIODIC_HOSTILEPLAYER_DAMAGE",
}

local function FilterLegacyOutgoingCombatLog()
    return true
end

local function InstallRealCombatLogFilters()
    if State.combatLogFiltersInstalled then
        return
    end

    if ChatFrame_AddMessageEventFilter then
        for _, eventName in ipairs(REAL_COMBAT_LOG_FILTER_EVENTS) do
            ChatFrame_AddMessageEventFilter(eventName, FilterLegacyOutgoingCombatLog)
        end
    end

    local combatLog = _G.ChatFrame2
    if combatLog and combatLog.AddMessage and not combatLog.DamageDisplayUIOriginalAddMessage then
        combatLog.DamageDisplayUIOriginalAddMessage = combatLog.AddMessage
        combatLog.AddMessage = function(self, text, ...)
            local message = tostring(text or "")
            if message:find("2147483647", 1, true)
                or message:find("2147483648", 1, true)
                or message:find("2147483520", 1, true) then
                return
            end
            return self:DamageDisplayUIOriginalAddMessage(text, ...)
        end
    end
    State.combatLogFiltersInstalled = true
end

local function AddRealCombatLogLine(amountText, spellName, displayType, attackerName)
    local combatLog = _G.ChatFrame2
    if not combatLog or not combatLog.AddMessage then
        return
    end

    local amount = FormatLargeDamageNumber(amountText)
    local sourceName = spellName
    local color = "ffffd21a"
    local action = "造成"
    if displayType == "HEAL" then
        sourceName = sourceName or "恢复"
        color = "ff33ff3d"
        action = "恢复"
    elseif displayType == "SPELL" then
        sourceName = sourceName or "技能"
        color = "ffff1f1f"
    else
        sourceName = sourceName or "近战攻击"
    end

    if displayType == "INCOMING" then
        attackerName = attackerName or "未知目标"
        local attackName = spellName or "近战攻击"
        combatLog:AddMessage("|cffff4d4d" .. attackerName .. "的" .. attackName .. "对你造成了 " .. amount .. " 点伤害。|r")
    else
        combatLog:AddMessage("|c" .. color .. "你的" .. sourceName .. action .. "了 " .. amount .. " 点" .. (displayType == "HEAL" and "生命值。" or "伤害。") .. "|r")
    end
end

local function GetSchoolColor(schoolMask)
    schoolMask = tonumber(schoolMask) or 1

    for _, mask in ipairs(SCHOOL_ORDER) do
        local color = SCHOOL_COLORS[mask]
        if bit and bit.band and bit.band(schoolMask, mask) ~= 0 then
            return color[1], color[2], color[3]
        end
    end

    return SCHOOL_COLORS[1][1], SCHOOL_COLORS[1][2], SCHOOL_COLORS[1][3]
end

local function GetDamageVisual(amountText, critical, schoolMask, displayType)
    local red, green, blue = GetSchoolColor(schoolMask)
    local digitCount = string.len(amountText or "")
    local scale = critical and 1.18 or 0.88

    if digitCount >= 12 then
        scale = scale * 0.82
    elseif digitCount <= 5 then
        scale = scale * 0.96
    end

    if displayType == "HEAL" then
        red, green, blue = 0.20, 1.00, 0.24
    elseif displayType == "SPELL" then
        red, green, blue = 1.00, 0.12, 0.12
    elseif critical then
        local school = tonumber(schoolMask) or 1
        if bit and bit.band and bit.band(school, 1) ~= 0 then
            red, green, blue = 1.00, 0.38, 0.08
        else
            red = math.min(1, red + 0.22)
            green = math.min(1, green + 0.06)
            blue = math.max(0, blue - 0.10)
        end
    end

    return red, green, blue, scale
end

local function ApplyOfficialCombatTextState()
	if not LargeDamageTextDB then
		return
	end

    if not SetCVar and not ConsoleExec then
        return
    end

	State.applyingOfficialState = true
	if DEX_Set then
		pcall(DEX_Set, "DEX_ShowDamageHealth", 0)
	end
	local cvarValue = LargeDamageTextDB.disableOfficial and "0" or "1"
	for _, cvarName in ipairs(OFFICIAL_DAMAGE_CVARS) do
		if SetCVar then
			pcall(SetCVar, cvarName, cvarValue)
		end
		if ConsoleExec then
			pcall(ConsoleExec, cvarName .. " " .. cvarValue)
        end
    end
    State.applyingOfficialState = false

    if CombatText_UpdateDisplayedMessages then
        pcall(CombatText_UpdateDisplayedMessages)
    end
end

local function SendControlMessage(message, force)
    local now = GetTime and GetTime() or 0
    if not force and (now - State.lastControlMessageAt) < 1 then
        return
    end

    local playerName = UnitName and UnitName("player") or nil
    if not playerName then
        return
    end

    State.lastControlMessageAt = now
    if SendAddonMessage then
        SendAddonMessage(LARGE_DAMAGE_PREFIX, message, "WHISPER", playerName)
    elseif C_ChatInfo and C_ChatInfo.SendAddonMessage then
        C_ChatInfo.SendAddonMessage(LARGE_DAMAGE_PREFIX, message, "WHISPER", playerName)
    end
end

local function SendReadyState(force)
    CopyDefaults()

    SendControlMessage("LDT_READY", force)
end

local function EnsureHolder()
    if State.holder then
        return State.holder
    end

    local holder = CreateFrame("Frame", "DamageDisplayUIFloatHolder", UIParent)
    holder:SetAllPoints(UIParent)
    holder:SetFrameStrata("HIGH")
    holder:SetFrameLevel(40)
    State.holder = holder
    return holder
end

local function EnsureLargeLayer()
    if State.largeLayer then
        return State.largeLayer
    end

    local layer = CreateFrame("Frame", "DamageDisplayUILargeDamageLayer", UIParent)
    layer:SetAllPoints(UIParent)
    layer:SetFrameStrata("HIGH")
    layer:SetFrameLevel(120)
    State.largeLayer = layer
    return layer
end

local function ApplyTextScale(fontString, scale)
    scale = tonumber(scale) or 1

    if fontString.SetScale then
        fontString:SetScale(scale)
        return
    end

    if fontString.SetFont then
        local font = fontString.damageDisplayBaseFont
        local size = fontString.damageDisplayBaseSize
        local flags = fontString.damageDisplayBaseFlags

        if (not font or not size) and fontString.GetFont then
            font, size, flags = fontString:GetFont()
            fontString.damageDisplayBaseFont = font
            fontString.damageDisplayBaseSize = size
            fontString.damageDisplayBaseFlags = flags
        end

        if font and size then
            fontString:SetFont(font, math.max(8, math.floor(size * scale + 0.5)), flags)
            return
        end
    end

    if fontString.SetTextHeight then
        fontString:SetTextHeight(math.max(8, math.floor(28 * scale + 0.5)))
    end
end

local function ConfigureLargeFontString(fontString)
    fontString:SetJustifyH("CENTER")
    fontString:SetJustifyV("MIDDLE")
    if fontString.SetWidth then
        fontString:SetWidth(360)
    end
    if fontString.SetHeight then
        fontString:SetHeight(64)
    end
    if fontString.GetFont then
        local font, size = fontString:GetFont()
        fontString.damageDisplayBaseFont = font
        fontString.damageDisplayBaseSize = size
        fontString.damageDisplayBaseFlags = "OUTLINE"
        if font and fontString.SetFont then
            fontString:SetFont(font, math.max(14, size or 28), "OUTLINE")
        end
    end
    if fontString.SetShadowColor then
        fontString:SetShadowColor(0, 0, 0, 0.95)
    end
    if fontString.SetShadowOffset then
        fontString:SetShadowOffset(1, -1)
    end
    if fontString.SetWordWrap then
        fontString:SetWordWrap(false)
    end
    if fontString.SetNonSpaceWrap then
        fontString:SetNonSpaceWrap(false)
    end
end

local function FindLargeMergeItem(mergeKey)
    local mergeWindow = tonumber(DamageDisplayUIDB.largeDamageMergeWindow) or DEFAULT_DB.largeDamageMergeWindow
    if type(mergeKey) == "string" and mergeKey:match("^NORMAL:") then
        mergeWindow = tonumber(DamageDisplayUIDB.normalDamageMergeWindow) or DEFAULT_DB.normalDamageMergeWindow
    end

    for _, item in ipairs(State.largePool) do
        if item.active and item.mergeKey == mergeKey and item.elapsed <= mergeWindow then
            return item
        end
    end

    return nil
end

local function GetLargeFloatLane()
    local laneCount = #LARGE_DAMAGE_LANES
    local startIndex = ((State.largeSequence - 1) % laneCount) + 1

    for offset = 0, laneCount - 1 do
        local index = ((startIndex + offset - 1) % laneCount) + 1
        local available = true

        for _, item in ipairs(State.largePool) do
            if item.active and item.laneIndex == index and item.elapsed < 0.32 then
                available = false
                break
            end
        end

        if available then
            return LARGE_DAMAGE_LANES[index], index
        end
    end

    return LARGE_DAMAGE_LANES[startIndex], startIndex
end

local function TrimLargeDamageTexts()
    local activeCount = 0
    for _, item in ipairs(State.largePool) do
        if item.active then
            activeCount = activeCount + 1
        end
    end

    local maxTexts = tonumber(DamageDisplayUIDB.maxLargeDamageTexts) or DEFAULT_DB.maxLargeDamageTexts
    while activeCount > maxTexts do
        local oldest = nil
        for _, item in ipairs(State.largePool) do
            if item.active and (not oldest or item.elapsed > oldest.elapsed) then
                oldest = item
            end
        end

        if not oldest then
            return
        end

        oldest.active = false
        oldest.text:Hide()
        State.largeActiveCount = math.max(0, State.largeActiveCount - 1)
        activeCount = activeCount - 1
    end
end

local function ApplyLargeFloatPosition(item, progress)
    local eased = 1 - ((1 - progress) * (1 - progress))
    item.text:ClearAllPoints()
    item.text:SetPoint("CENTER", UIParent, "CENTER", item.x + (item.drift * progress), item.y + (item.rise * eased))
end

local function AcquireLargeText()
    local layer = EnsureLargeLayer()

    for _, item in ipairs(State.largePool) do
        if not item.active then
            return item
        end
    end

    local maxTexts = tonumber(LargeDamageTextDB and LargeDamageTextDB.maxTexts) or LEGACY_LARGE_DAMAGE_DEFAULTS.maxTexts
    maxTexts = math.min(maxTexts, (tonumber(DamageDisplayUIDB.maxLargeDamageTexts) or DEFAULT_DB.maxLargeDamageTexts) + 2)
    if #State.largePool >= maxTexts then
        local oldest = State.largePool[1]
        for _, item in ipairs(State.largePool) do
            if item.elapsed > oldest.elapsed then
                oldest = item
            end
        end

        if oldest.active then
            oldest.active = false
            State.largeActiveCount = math.max(0, State.largeActiveCount - 1)
        end
        return oldest
    end

    local fontString = layer:CreateFontString(nil, "OVERLAY", "GameFontNormalHuge")
    ConfigureLargeFontString(fontString)

    local item = {
        text = fontString,
        active = false,
        elapsed = 0,
        duration = 1.15,
        laneIndex = 0,
        x = 0,
        y = 0,
        rise = 92,
        drift = 0,
        scale = 1,
        startAlpha = 1,
        hitCount = 1,
        mergeKey = nil,
        amountText = nil,
        displayText = nil,
    }

    table.insert(State.largePool, item)
    return item
end

local function UpdateLargeTexts(self, elapsed)
    local hasActive = false

    for _, item in ipairs(State.largePool) do
        if item.active then
            item.elapsed = item.elapsed + elapsed
            if item.elapsed >= item.duration then
                item.active = false
                item.text:Hide()
                State.largeActiveCount = math.max(0, State.largeActiveCount - 1)
            else
                hasActive = true
                local progress = item.elapsed / item.duration
                local fadeStart = item.critical and 0.72 or 0.58
                local alphaProgress = math.max(0, (progress - fadeStart) / (1 - fadeStart))
                ApplyLargeFloatPosition(item, progress)
                item.text:SetAlpha((item.startAlpha or 1) * (1 - alphaProgress))
                ApplyTextScale(item.text, item.scale)
            end
        end
    end

    if not hasActive then
        self:SetScript("OnUpdate", nil)
    end
end

local function BuildLargeDamageText(amountText, critical, spellName, displayType)
    local damageText = FormatLargeDamageNumber(amountText)
    local hasSpellName = type(spellName) == "string" and spellName ~= ""

    if displayType == "HEAL" then
        if hasSpellName then
            return spellName .. " +" .. damageText, hasSpellName
        end

        return "+" .. damageText, hasSpellName
    end

    if critical then
        if hasSpellName then
            return spellName .. " 暴击 " .. damageText, hasSpellName
        end

        return "暴击 " .. damageText, hasSpellName
    end

    if hasSpellName then
        return spellName .. " " .. damageText, hasSpellName
    end

    return damageText, hasSpellName
end

local function ShowLargeDamage(amountText, critical, schoolMask, spellName, displayType)
    CopyDefaults()

    amountText = NormalizeDamageDigits(amountText)
    if not amountText then
        return
    end

    displayType = displayType or ((spellName and spellName ~= "") and "SPELL" or "NORMAL")
    local text, hasSpellName = BuildLargeDamageText(amountText, critical, spellName, displayType)

    State.largeSequence = State.largeSequence + 1
    local baseX = tonumber(LargeDamageTextDB.anchorX) or LEGACY_LARGE_DAMAGE_DEFAULTS.anchorX
    local baseY = tonumber(LargeDamageTextDB.anchorY) or LEGACY_LARGE_DAMAGE_DEFAULTS.anchorY
    local baseScale = tonumber(LargeDamageTextDB.fontScale) or LEGACY_LARGE_DAMAGE_DEFAULTS.fontScale
    local red, green, blue, visualScale = GetDamageVisual(amountText, critical, schoolMask, displayType)
    if hasSpellName then
        visualScale = visualScale * 0.92
    end

    local isNormalDamage = displayType == "NORMAL"
    local mergeKey
    if isNormalDamage then
        mergeKey = "NORMAL:" .. tostring(critical and 1 or 0) .. ":" .. tostring(tonumber(schoolMask) or 1)
    else
        mergeKey = displayType .. ":" .. tostring(critical and 1 or 0) .. ":" .. tostring(tonumber(schoolMask) or 1) .. ":" .. text
    end

    local item
    if not isNormalDamage then
        item = FindLargeMergeItem(mergeKey)
    end
    if item then
        item.hitCount = (item.hitCount or 1) + 1
        item.elapsed = math.min(item.elapsed or 0, 0.34)
        item.duration = critical and 1.28 or 1.08
        item.displayText = item.displayText or text
        item.scale = baseScale * visualScale
        item.text:SetText(item.displayText)
        item.text:SetTextColor(red, green, blue)
        item.text:SetAlpha(1)
        ApplyTextScale(item.text, item.scale)
        EnsureLargeLayer():SetScript("OnUpdate", UpdateLargeTexts)
        return
    end

    local laneInfo, laneIndex = GetLargeFloatLane()
    TrimLargeDamageTexts()
    item = AcquireLargeText()

    item.active = true
    item.elapsed = 0
    item.duration = critical and 1.28 or 1.08
    item.laneIndex = laneIndex
    item.critical = critical
    item.x = baseX + laneInfo[1] + math.random(-5, 5)
    item.y = baseY + laneInfo[2] + math.random(-3, 3)
    item.rise = laneInfo[4] + (critical and 18 or 0)
    item.drift = laneInfo[3]
    item.scale = baseScale * visualScale
    item.startAlpha = critical and 1 or 0.92
    item.hitCount = 1
    item.mergeKey = mergeKey
    item.amountText = amountText
    item.displayText = text

    item.text:SetText(text)
    item.text:SetTextColor(red, green, blue)
    item.text:SetAlpha(item.startAlpha)
    ApplyTextScale(item.text, item.scale)
    if item.text.SetWidth then
        item.text:SetWidth(hasSpellName and 520 or (critical and 460 or 340))
    end
    if item.text.SetHeight then
        item.text:SetHeight(critical and 58 or 46)
    end
    item.text:ClearAllPoints()
    ApplyLargeFloatPosition(item, 0)
    item.text:Show()

    State.largeActiveCount = State.largeActiveCount + 1
    EnsureLargeLayer():SetScript("OnUpdate", UpdateLargeTexts)
end

local function RemoveActiveFrame(frame)
    for index, activeFrame in ipairs(State.activeFrames) do
        if activeFrame == frame then
            table.remove(State.activeFrames, index)
            return
        end
    end
end

local function ReleaseFrame(frame)
    if not frame or frame._releasing then
        return
    end

    frame._releasing = true
    RemoveActiveFrame(frame)
    frame:Hide()
    frame:ClearAllPoints()
    frame:SetAlpha(1)
    frame.elapsed = 0
    frame.isAnimating = nil
    frame.displayText = nil
    frame.damageSource = nil

    if frame.text then
        frame.text:SetText("")
        frame.text:SetAlpha(1)
    end
    if frame.glow then
        frame.glow:SetText("")
        frame.glow:SetAlpha(0.7)
    end

    frame:SetParent(EnsureHolder())
    frame._releasing = nil
    table.insert(State.pool, frame)
end

local function CreateFloatFrame()
    State.sequence = State.sequence + 1

    local frame = CreateFrame("Frame", "DamageDisplayUIFloatText" .. State.sequence, EnsureHolder())
    frame:SetSize(260, 44)

    local fontPath = STANDARD_TEXT_FONT or "Fonts\\FRIZQT__.TTF"

    local glow = frame:CreateFontString(nil, "ARTWORK")
    glow:SetPoint("CENTER", 1, -1)
    glow:SetFont(fontPath, (tonumber(DamageDisplayUIDB.fontSize) or DEFAULT_DB.fontSize) + 2, "OUTLINE")
    glow:SetShadowOffset(0, 0)
    frame.glow = glow

    local text = frame:CreateFontString(nil, "OVERLAY")
    text:SetPoint("CENTER")
    text:SetFont(fontPath, tonumber(DamageDisplayUIDB.fontSize) or DEFAULT_DB.fontSize, "OUTLINE")
    text:SetShadowOffset(0.8, -0.8)
    text:SetShadowColor(0, 0, 0, 0.65)
    frame.text = text

    return frame
end

local function AcquireFrame()
    local maxActive = tonumber(DamageDisplayUIDB.maxActiveTexts) or DEFAULT_DB.maxActiveTexts
    if #State.activeFrames >= maxActive then
        ReleaseFrame(State.activeFrames[1])
    end

    local frame = table.remove(State.pool)
    if not frame then
        frame = CreateFloatFrame()
    end

    frame:SetParent(EnsureHolder())
    frame:Show()
    table.insert(State.activeFrames, frame)
    return frame
end

local function BuildFloatingText(source, damage)
    return string.format("%s+%s", source.label or "伤害", FormatChineseDamageNumber(damage))
end

local function ApplyFrameColors(frame, source)
    local color = source.color or { 1, 0.2, 0.2, 1 }
    local glow = source.glow or { color[1], color[2], color[3], 0.42 }
    frame.text:SetTextColor(color[1], color[2], color[3], color[4] or 1)
    frame.glow:SetTextColor(glow[1], glow[2], glow[3], glow[4] or 0.42)
end

local function ActivateFloatingText(entry)
    if not entry or not entry.text or entry.text == "" then
        return
    end

    local frame = AcquireFrame()
    local anchorX = tonumber(DamageDisplayUIDB.anchorX) or DEFAULT_DB.anchorX
    local anchorY = tonumber(DamageDisplayUIDB.anchorY) or DEFAULT_DB.anchorY

    frame:ClearAllPoints()
    frame:SetPoint("CENTER", EnsureHolder(), "CENTER", anchorX, anchorY)
    frame.startX = anchorX
    frame.startY = anchorY
    frame.elapsed = 0
    frame.isAnimating = true
    frame:SetAlpha(1)
    frame.displayText = entry.text
    frame.damageSource = entry.sourceKey

    ApplyFrameColors(frame, entry.source or {})
    frame.glow:SetText(entry.text)
    frame.text:SetText(entry.text)
    frame.glow:SetAlpha(0.7)
    frame.text:SetAlpha(1)
end

local function ClampNextDispatchTime(now)
    now = tonumber(now) or (GetTime and GetTime() or 0)
    local delayStep = tonumber(DamageDisplayUIDB.delayStep) or DEFAULT_DB.delayStep
    local maxQueued = tonumber(DamageDisplayUIDB.maxQueuedTexts) or DEFAULT_DB.maxQueuedTexts
    local maxFuture = now + math.max(delayStep, 0.01) * math.max(maxQueued, 1)

    if State.nextDispatchAt > maxFuture then
        State.nextDispatchAt = maxFuture
    end
end

local function FlushPending(sourceKey)
    local pending = State.pending[sourceKey]
    if not pending then
        return
    end

    State.pending[sourceKey] = nil
    local source = DAMAGE_SOURCES[sourceKey]
    if not source then
        return
    end

    local now = GetTime and GetTime() or 0
    if State.nextDispatchAt < now then
        State.nextDispatchAt = now
    end

    local maxQueued = tonumber(DamageDisplayUIDB.maxQueuedTexts) or DEFAULT_DB.maxQueuedTexts
    if #State.queue >= maxQueued then
        local lastEntry = State.queue[#State.queue]
        if lastEntry and lastEntry.sourceKey == sourceKey then
            lastEntry.damage = AddDamageDigits(lastEntry.damage, pending.damage)
            lastEntry.count = (tonumber(lastEntry.count) or 0) + (tonumber(pending.count) or 0)
            lastEntry.text = BuildFloatingText(source, lastEntry.damage)
            ClampNextDispatchTime(now)
            return
        end

        table.remove(State.queue, 1)
        ClampNextDispatchTime(now)
    end

    table.insert(State.queue, {
        sourceKey = sourceKey,
        source = source,
        damage = NormalizeDamageDigits(pending.damage) or "0",
        count = tonumber(pending.count) or 1,
        text = BuildFloatingText(source, pending.damage),
        dispatchAt = State.nextDispatchAt,
    })
    State.nextDispatchAt = State.nextDispatchAt + (tonumber(DamageDisplayUIDB.delayStep) or DEFAULT_DB.delayStep)
end

local function EnqueueFloatingDamage(sourceKey, damage)
    CopyDefaults()

    damage = NormalizeDamageDigits(damage)
    if not damage then
        return
    end

    local source = DAMAGE_SOURCES[sourceKey]
    if not source then
        return
    end

    local now = GetTime and GetTime() or 0
    if State.nextDispatchAt < now then
        State.nextDispatchAt = now
    end

    local maxQueued = tonumber(DamageDisplayUIDB.maxQueuedTexts) or DEFAULT_DB.maxQueuedTexts
    if #State.queue >= maxQueued then
        table.remove(State.queue, 1)
        ClampNextDispatchTime(now)
    end

    table.insert(State.queue, {
        sourceKey = sourceKey,
        source = source,
        damage = damage,
        count = 1,
        text = BuildFloatingText(source, damage),
        dispatchAt = State.nextDispatchAt,
    })
    State.nextDispatchAt = State.nextDispatchAt + (tonumber(DamageDisplayUIDB.delayStep) or DEFAULT_DB.delayStep)
end

local function StartDriver()
    if not State.driver then
        State.driver = CreateFrame("Frame", nil, UIParent)
    end

    if State.driver:GetScript("OnUpdate") then
        return
    end

    State.driver:SetScript("OnUpdate", function(self, elapsed)
        local now = GetTime and GetTime() or 0

        for sourceKey, pending in pairs(State.pending) do
            if pending and now >= pending.mergeUntil then
                FlushPending(sourceKey)
            end
        end

        while #State.queue > 0 do
            local nextEntry = State.queue[1]
            if not nextEntry or (tonumber(nextEntry.dispatchAt) or 0) > now then
                break
            end

            table.remove(State.queue, 1)
            ActivateFloatingText(nextEntry)
        end

        local duration = tonumber(DamageDisplayUIDB.duration) or DEFAULT_DB.duration
        local distance = tonumber(DamageDisplayUIDB.distance) or DEFAULT_DB.distance
        for index = #State.activeFrames, 1, -1 do
            local frame = State.activeFrames[index]
            if frame and frame.isAnimating then
                frame.elapsed = (frame.elapsed or 0) + (elapsed or 0)
                local progress = frame.elapsed / duration

                if progress >= 1 then
                    ReleaseFrame(frame)
                else
                    local yOffset = progress * distance
                    local alpha = 1 - progress
                    frame:ClearAllPoints()
                    frame:SetPoint("CENTER", EnsureHolder(), "CENTER", frame.startX or DEFAULT_DB.anchorX, (frame.startY or DEFAULT_DB.anchorY) + yOffset)
                    frame.text:SetAlpha(alpha)
                    frame.glow:SetAlpha(alpha * 0.7)
                end
            end
        end

        if next(State.pending) == nil and #State.queue == 0 and #State.activeFrames == 0 then
            State.nextDispatchAt = 0
            self:SetScript("OnUpdate", nil)
        end
    end)
end

local function QueueDamage(sourceKey, damage)
    CopyDefaults()

    damage = NormalizeDamageDigits(damage)
    if not damage then
        return
    end

    local now = GetTime and GetTime() or 0
    local pending = State.pending[sourceKey]
    if pending and now <= pending.mergeUntil then
        pending.damage = AddDamageDigits(pending.damage, damage)
        pending.count = (tonumber(pending.count) or 0) + 1
    else
        FlushPending(sourceKey)
        State.pending[sourceKey] = {
            damage = damage,
            count = 1,
            mergeUntil = now + (tonumber(DamageDisplayUIDB.mergeWindow) or DEFAULT_DB.mergeWindow),
        }
    end

    StartDriver()
end

local function QueueDamageList(sourceKey, payload)
    CopyDefaults()

    local damages = SplitString(payload or "", "~")
    local normalized = {}
    for _, damageText in ipairs(damages) do
        damageText = NormalizeDamageDigits(damageText)
        if damageText then
            table.insert(normalized, damageText)
        end
    end

    local damageCount = #normalized
    if damageCount == 0 then
        return
    end

    local maxBurstTexts = tonumber(DamageDisplayUIDB.maxBurstTexts) or DEFAULT_DB.maxBurstTexts
    maxBurstTexts = math.max(1, math.min(maxBurstTexts, tonumber(DamageDisplayUIDB.maxQueuedTexts) or DEFAULT_DB.maxQueuedTexts))
    if damageCount <= maxBurstTexts then
        for _, damageText in ipairs(normalized) do
            EnqueueFloatingDamage(sourceKey, damageText)
        end
        StartDriver()
        return
    end

    local groupCount = maxBurstTexts
    local groupSize = math.ceil(damageCount / groupCount)
    local index = 1
    while index <= damageCount do
        local total = "0"
        for _ = 1, groupSize do
            if index > damageCount then
                break
            end
            total = AddDamageDigits(total, normalized[index])
            index = index + 1
        end

        EnqueueFloatingDamage(sourceKey, total)
    end
    StartDriver()
end

local function ConsumeChunkedMessage(sourceKey, message)
    if type(message) ~= "string" then
        return message
    end

    local chunkNum, totalChunks, chunkData = string.match(message, "^CHUNK:(%d+):(%d+):(.*)$")
    if not chunkNum or not totalChunks then
        return message
    end

    chunkNum = tonumber(chunkNum) or 0
    totalChunks = tonumber(totalChunks) or 0
    if chunkNum <= 0 or totalChunks <= 0 or chunkNum > totalChunks then
        State.chunkBuffers[sourceKey] = nil
        return nil
    end

    local buffer = State.chunkBuffers[sourceKey]
    if not buffer or chunkNum == 1 or buffer.total ~= totalChunks then
        buffer = {
            total = totalChunks,
            received = 0,
            chunks = {},
        }
        State.chunkBuffers[sourceKey] = buffer
    end

    if buffer.chunks[chunkNum] == nil then
        buffer.received = buffer.received + 1
    end
    buffer.chunks[chunkNum] = chunkData or ""

    if buffer.received < buffer.total then
        return nil
    end

    local chunks = {}
    for index = 1, buffer.total do
        if buffer.chunks[index] == nil then
            State.chunkBuffers[sourceKey] = nil
            return nil
        end

        chunks[index] = buffer.chunks[index]
    end

    State.chunkBuffers[sourceKey] = nil
    return table.concat(chunks)
end

local function HandleSourceMessage(sourceKey, message)
    if type(message) ~= "string" then
        return false
    end

    message = ConsumeChunkedMessage(sourceKey, message)
    if not message then
        return true
    end

    local source = DAMAGE_SOURCES[sourceKey]
    if not source then
        return false
    end

    local payload = string.match(message, source.hitsPattern)
    if payload then
        QueueDamageList(sourceKey, payload)
        return true
    end

    payload = string.match(message, source.hitPattern)
    if payload then
        QueueDamage(sourceKey, payload)
        return true
    end

    return false
end

local function RecordSourceMessage(sourceKey, message, eventName)
    local source = DAMAGE_SOURCES[sourceKey]
    local sourceName = (source and source.label) or sourceKey
    State.sourceMessageCounts[sourceKey] = (tonumber(State.sourceMessageCounts[sourceKey]) or 0) + 1
    State.lastSourceMessageAt = GetTime and GetTime() or 0
    State.lastSourceMessage = string.format("%s %s", sourceName, string.sub(tostring(message or ""), 1, 80))
    DebugPrint(string.format("%s 收到%s: %s", tostring(eventName or "消息"), tostring(sourceName), tostring(message or "")))
end

local function IsRecentSourceMessage(sourceKey, message, eventName)
    local now = GetTime and GetTime() or 0
    local key = tostring(sourceKey or "") .. "\001" .. tostring(message or "")
    eventName = tostring(eventName or "")

    for recentKey, recentInfo in pairs(State.recentSourcePayloads) do
        if now - (tonumber(recentInfo and recentInfo.time) or 0) > 0.08 then
            State.recentSourcePayloads[recentKey] = nil
        end
    end

    local recent = State.recentSourcePayloads[key]
    if recent and recent.eventName ~= eventName and now - (tonumber(recent.time) or 0) <= 0.08 then
        return true
    end

    State.recentSourcePayloads[key] = {
        time = now,
        eventName = eventName,
    }
    return false
end

local HandleLargeDamagePayload
local HandleLargeDamageAck

local function NormalizeAddonMessage(prefix, message)
    prefix = TrimText(StripMessageColors(prefix))
    message = TrimText(StripMessageColors(message))

    for _, source in pairs(DAMAGE_SOURCES) do
        local embedded = prefix:match("^" .. source.prefix .. "\t(.*)$")
        if embedded then
            return source.prefix, embedded
        end

        embedded = message:match("^" .. source.prefix .. "\t(.*)$")
        if embedded then
            return source.prefix, embedded
        end

        if prefix == source.prefix then
            return source.prefix, message
        end

        if message:match(source.hitsPattern) or message:match(source.hitPattern) then
            return source.prefix, message
        end
    end

    local embedded = prefix:match("^" .. LARGE_DAMAGE_PREFIX .. "\t(.*)$")
    if embedded then
        return LARGE_DAMAGE_PREFIX, embedded
    end

    embedded = message:match("^" .. LARGE_DAMAGE_PREFIX .. "\t(.*)$")
    if embedded then
        return LARGE_DAMAGE_PREFIX, embedded
    end

    if prefix == LARGE_DAMAGE_PREFIX then
        return LARGE_DAMAGE_PREFIX, message
    end

    if message:match("^DMG:") or message:match("^CLOG:") or message:match("^LDT_ACK:") then
        return LARGE_DAMAGE_PREFIX, message
    end

    if message:match("^HEAL:") then
        return LARGE_DAMAGE_PREFIX, message
    end

    return prefix, message
end

local function DispatchDamageMessage(eventName, prefix, message)
    CopyDefaults()

    local normalizedPrefix, normalizedMessage = NormalizeAddonMessage(prefix, message)
    if normalizedPrefix == "MAGICHIT" then
        if IsRecentSourceMessage("MAGICHIT", normalizedMessage, eventName) then
            return true
        end

        RecordSourceMessage("MAGICHIT", normalizedMessage, eventName)
        return HandleSourceMessage("MAGICHIT", normalizedMessage)
    end

    if normalizedPrefix == "CUT_SYS" then
        if IsRecentSourceMessage("CUT_SYS", normalizedMessage, eventName) then
            return true
        end

        RecordSourceMessage("CUT_SYS", normalizedMessage, eventName)
        return HandleSourceMessage("CUT_SYS", normalizedMessage)
    end

    if normalizedPrefix == LARGE_DAMAGE_PREFIX then
        if normalizedMessage:match("^DMG:") and HandleLargeDamagePayload then
            return HandleLargeDamagePayload(normalizedMessage)
        end

        if normalizedMessage:match("^HEAL:") and HandleLargeDamagePayload then
            return HandleLargeDamagePayload(normalizedMessage)
        end

        if normalizedMessage:match("^CLOG:") and HandleLargeDamagePayload then
            return HandleLargeDamagePayload(normalizedMessage)
        end

        if normalizedMessage:match("^LDT_ACK:") and HandleLargeDamageAck then
            return HandleLargeDamageAck(normalizedMessage)
        end
    end

    local combined = tostring(prefix or "") .. " " .. tostring(message or "")
    if combined:find("MAGICHIT", 1, true) or combined:find("CUT_SYS", 1, true) or combined:find("CT_HIT", 1, true) then
        DebugPrint(string.format("未识别伤害消息 prefix=%s message=%s", tostring(prefix or ""), tostring(message or "")))
    end

    return false
end

local function SafeDispatchDamageMessage(eventName, prefix, message)
    local ok, handled = pcall(DispatchDamageMessage, eventName, prefix, message)
    if ok then
        return handled
    end

    local now = GetTime and GetTime() or 0
    if not State.lastDispatchErrorAt or now - State.lastDispatchErrorAt >= 5 then
        State.lastDispatchErrorAt = now
        DebugPrint("消息处理异常: " .. tostring(handled))
    end
    return false
end

HandleLargeDamagePayload = function(message)
    local incomingAmount, incomingSchool, incomingSpell, incomingSeq, incomingSource = message:match("^CLOG:(%d+):(%d+):(%d+):(%d+):(.*)$")
    if incomingAmount then
        local spellName = ResolveSpellName(incomingSpell)
        AddRealCombatLogLine(incomingAmount, spellName, "INCOMING", incomingSource)
        return true
    end

    local amountText, criticalText, schoolMask, spellId = message:match("^DMG:(%d+):(%d+):(%d+):(%d+):%d+$")
    if amountText then
        local spellName = ResolveSpellName(spellId)
        local displayType = spellName and "SPELL" or "NORMAL"
        ShowLargeDamage(amountText, criticalText == "1", schoolMask, spellName, displayType)
        AddRealCombatLogLine(amountText, spellName, displayType)
        return true
    end

    amountText, schoolMask, spellId = message:match("^HEAL:(%d+):(%d+):(%d+):%d+$")
    if amountText then
        if amountText == "2000000000" or amountText == "2100000000"
            or amountText == "2147483520" or amountText == "2147483647"
            or amountText == "2147483648" then
            return true
        end
        local spellName = ResolveSpellName(spellId)
        ShowLargeDamage(amountText, false, schoolMask, spellName, "HEAL")
        AddRealCombatLogLine(amountText, spellName, "HEAL")
        return true
    end

    return false
end

HandleLargeDamageAck = function(message)
    local enabled = message:match("^LDT_ACK:(%d+)$")
    if not enabled then
        return false
    end

    State.lastReadyAck = enabled == "1" and "服务端已接管" or "服务端已恢复官方"
    return true
end

local function RegisterDamagePrefixes()
    for _, source in pairs(DAMAGE_SOURCES) do
        if RegisterAddonMessagePrefix then
            pcall(RegisterAddonMessagePrefix, source.prefix)
        elseif C_ChatInfo and C_ChatInfo.RegisterAddonMessagePrefix then
            pcall(C_ChatInfo.RegisterAddonMessagePrefix, source.prefix)
        end
    end

    if RegisterAddonMessagePrefix then
        pcall(RegisterAddonMessagePrefix, LARGE_DAMAGE_PREFIX)
    elseif C_ChatInfo and C_ChatInfo.RegisterAddonMessagePrefix then
        pcall(C_ChatInfo.RegisterAddonMessagePrefix, LARGE_DAMAGE_PREFIX)
    end
end

local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:RegisterEvent("PLAYER_LOGIN")
eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
eventFrame:RegisterEvent("CVAR_UPDATE")
eventFrame:RegisterEvent("CHAT_MSG_SYSTEM")
eventFrame:RegisterEvent("CHAT_MSG_WHISPER")
eventFrame:RegisterEvent("CHAT_MSG_ADDON")

eventFrame:SetScript("OnEvent", function(self, event, ...)
    if event == "ADDON_LOADED" then
        local loadedName = ...
        if loadedName == ADDON_NAME then
            CopyDefaults()
            RegisterDamagePrefixes()
            InstallRealCombatLogFilters()
            ApplyOfficialCombatTextState()
        end
        return
    end

    if event == "PLAYER_LOGIN" then
        CopyDefaults()
        InstallRealCombatLogFilters()
        ApplyOfficialCombatTextState()
        return
    end

    if event == "PLAYER_ENTERING_WORLD" then
        CopyDefaults()
        ApplyOfficialCombatTextState()
        SendReadyState(true)
        return
    end

    if event == "CVAR_UPDATE" then
        if State.applyingOfficialState then
            return
        end

        local cvarName = ...
        cvarName = tostring(cvarName or "")
        if OFFICIAL_DAMAGE_CVAR_LOOKUP[cvarName] or OFFICIAL_DAMAGE_CVAR_LOOKUP[string.lower(cvarName)] then
            ApplyOfficialCombatTextState()
        end
        return
    end

    if event == "CHAT_MSG_SYSTEM" or event == "CHAT_MSG_WHISPER" then
        local rawMessage = ...
        SafeDispatchDamageMessage(event, "", rawMessage)
        return
    end

    if event == "CHAT_MSG_ADDON" then
        local prefix, message = ...
        SafeDispatchDamageMessage(event, prefix, message)
    end
end)

CopyDefaults()
RegisterDamagePrefixes()
InstallRealCombatLogFilters()
ApplyOfficialCombatTextState()

local function PrintStatus()
    CopyDefaults()

    local enabledText = "专属伤害已接管"
    local largeText = "普通伤害已接管"
    local compactText = LargeDamageTextDB.compact and "中文单位" or "完整数字"
    local officialText = "关闭官方伤害"
    local debugText = DamageDisplayUIDB.debug and "调试开启" or "调试关闭"
    local magicCount = tonumber(State.sourceMessageCounts.MAGICHIT) or 0
    local cutCount = tonumber(State.sourceMessageCounts.CUT_SYS) or 0
    print("|cffff4444伤害显示插件|r " .. enabledText .. "，" .. largeText .. "，" .. compactText .. "，" .. officialText .. "，" .. debugText .. "，" .. State.lastReadyAck)
    print("|cffff4444伤害显示插件|r 魔次消息 " .. magicCount .. "，切割消息 " .. cutCount .. "，最近: " .. tostring(State.lastSourceMessage or "无"))
end

local function HandleSlashCommand(msg)
    CopyDefaults()
    msg = tostring(msg or ""):lower()

    if msg == "compact" or msg == "中文" then
        LargeDamageTextDB.compact = true
        DamageDisplayUIDB.compact = true
        PrintStatus()
        return
    end

    if msg == "full" or msg == "完整" then
        LargeDamageTextDB.compact = false
        DamageDisplayUIDB.compact = false
        PrintStatus()
        return
    end

    if msg == "official" or msg == "官方" then
        LargeDamageTextDB.disableOfficial = true
        DamageDisplayUIDB.disableOfficial = true
        ApplyOfficialCombatTextState()
        SendReadyState(true)
        PrintStatus()
        return
    end

    if msg == "ready" or msg == "握手" then
        SendReadyState(true)
        print("|cffff4444伤害显示插件|r 已重新发送接管握手")
        return
    end

    if msg == "debug" or msg == "调试" then
        DamageDisplayUIDB.debug = not DamageDisplayUIDB.debug
        PrintStatus()
        return
    end

    if msg == "status" or msg == "状态" then
        PrintStatus()
        return
    end

    if msg == "testmagic" or msg == "测试魔次" then
        DispatchDamageMessage("SlashTest", "MAGICHIT", "MAGICHIT_HITS:123456789~234567890~345678901~456789012~567890123")
        return
    end

    if msg == "testcut" or msg == "测试切割" then
        DispatchDamageMessage("SlashTest", "CUT_SYS", "CT_HITS:123456789~234567890~345678901~456789012~567890123")
        return
    end

    local testAmount = msg:match("^test%s+(%d+)$") or msg:match("^测试%s+(%d+)$")
    if testAmount then
        ShowLargeDamage(testAmount, true, 1)
        return
    end

    if msg == "test" or msg == "测试" then
        ShowLargeDamage("123456789012345", true, 1)
        QueueDamage("MAGICHIT", "123456789")
        QueueDamage("CUT_SYS", "10000000000000000")
        return
    end

    PrintStatus()
end

local function SafeHandleSlashCommand(msg)
    local ok, err = pcall(HandleSlashCommand, msg)
    if not ok then
        print("|cffff0000伤害显示插件错误:|r " .. tostring(err))
    end
end

SLASH_DAMAGEDISPLAYUI1 = "/伤害显示"
SLASH_DAMAGEDISPLAYUI2 = "/damagedisplay"
SlashCmdList["DAMAGEDISPLAYUI"] = SafeHandleSlashCommand

SLASH_LARGEDAMAGETEXT1 = "/bdmg"
SLASH_LARGEDAMAGETEXT2 = "/ldt"
SLASH_LARGEDAMAGETEXT3 = "/ldmg"
SLASH_LARGEDAMAGETEXT4 = "/大数字伤害"
SlashCmdList["LARGEDAMAGETEXT"] = SafeHandleSlashCommand

_G.DamageDisplayUI = {
    ShowDamage = QueueDamage,
    ShowLargeDamage = ShowLargeDamage,
    HandleMessage = DispatchDamageMessage,
    ShowDamages = function(sourceKey, damages)
        if type(damages) ~= "table" then
            return
        end

        for _, damage in ipairs(damages) do
            QueueDamage(sourceKey, damage)
        end
    end,
    FormatDamage = FormatChineseDamageNumber,
    FormatLargeDamage = FormatLargeDamageNumber,
    SendReady = SendReadyState,
}
