local ADDON_NAME = "____Function"
local PREFIX = "MPRG"

MapProgressUI = MapProgressUI or {}
local UI = MapProgressUI

UI.frame = nil
UI.data = nil
UI.queryElapsed = 0
UI.pendingQuery = true

local RANK_NAMES = {
    [0] = "|cffd8d8d8普通|r",
    [1] = "|cff46d979精英|r",
    [2] = "|cffb56bff稀有精英|r",
    [3] = "|cffff4a4aBoss|r",
    [4] = "|cffffb347稀有|r"
}

local function GetDB()
    MapProgressUIDB = MapProgressUIDB or {}
    if MapProgressUIDB.point == nil then
        MapProgressUIDB.point = "TOP"
        MapProgressUIDB.relativePoint = "TOP"
        MapProgressUIDB.xOffset = 0
        MapProgressUIDB.yOffset = -120
    end
    return MapProgressUIDB
end

local function Split(text, sep)
    local result = {}
    text = tostring(text or "")
    sep = sep or "|"
    local start = 1
    while true do
        local pos = string.find(text, sep, start, true)
        if not pos then
            table.insert(result, string.sub(text, start))
            break
        end
        table.insert(result, string.sub(text, start, pos - 1))
        start = pos + string.len(sep)
    end
    return result
end

local function RegisterPrefix(prefix)
    if RegisterAddonMessagePrefix then
        RegisterAddonMessagePrefix(prefix)
    elseif C_ChatInfo and C_ChatInfo.RegisterAddonMessagePrefix then
        C_ChatInfo.RegisterAddonMessagePrefix(prefix)
    end
end

local function SendAddon(prefix, message)
    local playerName = UnitName("player")
    if not playerName then return end

    if C_ChatInfo and C_ChatInfo.SendAddonMessage then
        C_ChatInfo.SendAddonMessage(prefix, message, "WHISPER", playerName)
    else
        SendAddonMessage(prefix, message, "WHISPER", playerName)
    end
end

local function FormatTime(seconds)
    seconds = tonumber(seconds) or 0
    if seconds < 0 then seconds = 0 end
    local minutes = math.floor(seconds / 60)
    local remain = math.floor(seconds - minutes * 60)
    return string.format("%02d:%02d", minutes, remain)
end

local function Clamp(value, minValue, maxValue)
    value = tonumber(value) or 0
    if value < minValue then return minValue end
    if value > maxValue then return maxValue end
    return value
end

local function ParseRewardList(text)
    local rewards = {}
    for _, token in ipairs(Split(text or "", "~")) do
        if token ~= "" then
            local parts = Split(token, "^")
            table.insert(rewards, {
                progress = tonumber(parts[1]) or 0,
                reward = tonumber(parts[2]) or 0,
                rewarded = tonumber(parts[3]) == 1
            })
        end
    end
    table.sort(rewards, function(a, b) return (a.progress or 0) < (b.progress or 0) end)
    return rewards
end

local function ParseProgressRules(text)
    local rules = {}
    for _, token in ipairs(Split(text or "", "~")) do
        if token ~= "" then
            local parts = Split(token, "^")
            local rank = tonumber(parts[1]) or 0
            local value = tonumber(parts[2]) or 0
            if value > 0 then
                table.insert(rules, { rank = rank, value = value })
            end
        end
    end
    return rules
end

local function GetMaxRewardProgress(rewards)
    local maxProgress = 0
    for _, reward in ipairs(rewards or {}) do
        if (reward.progress or 0) > maxProgress then
            maxProgress = reward.progress
        end
    end
    return maxProgress
end

local function FormatProgressRules(rules)
    if not rules or #rules == 0 then
        return ""
    end

    local texts = {}
    for _, rule in ipairs(rules) do
        local rankName = RANK_NAMES[rule.rank] or ("Rank " .. tostring(rule.rank))
        table.insert(texts, rankName .. " +" .. tostring(rule.value))
    end
    return table.concat(texts, " / ")
end

function UI:SavePosition()
    if not self.frame then return end

    local db = GetDB()
    local point, _, relativePoint, xOfs, yOfs = self.frame:GetPoint()
    db.point = point
    db.relativePoint = relativePoint
    db.xOffset = xOfs
    db.yOffset = yOfs
end

function UI:LoadPosition()
    if not self.frame then return end

    local db = GetDB()
    self.frame:ClearAllPoints()
    self.frame:SetPoint(db.point or "TOP", UIParent, db.relativePoint or "TOP", db.xOffset or 0, db.yOffset or -120)
end

function UI:CreateFrame()
    if self.frame then return end

    local frame = CreateFrame("Frame", "MapProgressUIFrame", UIParent)
    frame:SetSize(420, 132)
    frame:SetFrameStrata("LOW")
    frame:SetFrameLevel(1)
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetClampedToScreen(true)
    frame:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background-Dark",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true,
        tileSize = 16,
        edgeSize = 12,
        insets = { left = 4, right = 4, top = 4, bottom = 4 }
    })
    frame:SetBackdropColor(0.02, 0.04, 0.07, 0.82)
    frame:SetBackdropBorderColor(0.35, 0.62, 0.9, 0.9)
    frame:SetScript("OnDragStart", function(self) self:StartMoving() end)
    frame:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        UI:SavePosition()
    end)
    frame:SetScript("OnShow", function()
        UI:Query()
    end)

    frame.title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    frame.title:SetPoint("TOPLEFT", frame, "TOPLEFT", 16, -11)
    frame.title:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -16, -11)
    frame.title:SetJustifyH("CENTER")
    frame.title:SetTextColor(0.72, 0.9, 1.0)
    frame.title:SetText("地图进度")

    frame.bar = CreateFrame("StatusBar", nil, frame)
    frame.bar:SetSize(360, 18)
    frame.bar:SetPoint("TOP", frame.title, "BOTTOM", 0, -8)
    frame.bar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
    frame.bar:SetStatusBarColor(0.15, 0.62, 1.0, 1.0)
    frame.bar:SetMinMaxValues(0, 100)
    frame.bar:SetValue(0)

    frame.bar.bg = frame.bar:CreateTexture(nil, "BACKGROUND")
    frame.bar.bg:SetAllPoints(frame.bar)
    frame.bar.bg:SetTexture("Interface\\TargetingFrame\\UI-StatusBar")
    frame.bar.bg:SetVertexColor(0.02, 0.06, 0.09, 0.9)

    frame.bar.spark = frame.bar:CreateTexture(nil, "OVERLAY")
    frame.bar.spark:SetTexture("Interface\\CastingBar\\UI-CastingBar-Spark")
    frame.bar.spark:SetBlendMode("ADD")
    frame.bar.spark:SetWidth(24)
    frame.bar.spark:SetHeight(32)
    frame.bar.spark:SetPoint("CENTER", frame.bar, "LEFT", 0, 0)

    frame.barText = frame.bar:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    frame.barText:SetPoint("CENTER", frame.bar, "CENTER", 0, 0)
    frame.barText:SetTextColor(1, 1, 1)
    frame.barText:SetShadowOffset(1, -1)
    frame.barText:SetText("0 / 0")

    frame.rewardText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    frame.rewardText:SetPoint("TOPLEFT", frame.bar, "BOTTOMLEFT", 0, -8)
    frame.rewardText:SetPoint("TOPRIGHT", frame.bar, "BOTTOMRIGHT", 0, -8)
    frame.rewardText:SetJustifyH("CENTER")
    frame.rewardText:SetTextColor(1.0, 0.82, 0.42)

    frame.deathText = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    frame.deathText:SetPoint("TOPLEFT", frame, "TOPLEFT", 30, -82)
    frame.deathText:SetPoint("TOPRIGHT", frame, "TOP", -8, -82)
    frame.deathText:SetJustifyH("LEFT")
    frame.deathText:SetTextColor(1.0, 0.42, 0.42)

    frame.timeText = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    frame.timeText:SetPoint("TOPLEFT", frame, "TOP", 8, -82)
    frame.timeText:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -30, -82)
    frame.timeText:SetJustifyH("RIGHT")
    frame.timeText:SetTextColor(0.42, 0.95, 1.0)

    frame.ruleText = frame:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    frame.ruleText:SetPoint("TOPLEFT", frame, "TOPLEFT", 20, -105)
    frame.ruleText:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -20, -105)
    frame.ruleText:SetJustifyH("CENTER")

    self.frame = frame
    self:LoadPosition()
    frame:Hide()

    table.insert(UISpecialFrames, "MapProgressUIFrame")
end

function UI:SetSpark(percent)
    if not self.frame or not self.frame.bar or not self.frame.bar.spark then return end

    percent = Clamp(percent, 0, 1)
    local width = self.frame.bar:GetWidth() or 330
    self.frame.bar.spark:ClearAllPoints()
    self.frame.bar.spark:SetPoint("CENTER", self.frame.bar, "LEFT", width * percent, 0)
end

function UI:UpdateDisplay()
    if not self.frame then self:CreateFrame() end
    if not self.frame or not self.data then return end

    local data = self.data
    local rewards = data.rewards or {}
    local maxReward = GetMaxRewardProgress(rewards)
    local progress = tonumber(data.progress) or 0
    local nextProgress = tonumber(data.nextProgress) or 0
    local barMax = nextProgress > 0 and nextProgress or maxReward

    if barMax <= 0 then
        barMax = progress > 0 and progress or 100
    end

    local value = Clamp(progress, 0, barMax)
    self.frame.title:SetText((data.title and data.title ~= "") and data.title or "地图进度")
    self.frame.bar:SetMinMaxValues(0, barMax)
    self.frame.bar:SetValue(value)
    self:SetSpark(barMax > 0 and (value / barMax) or 0)

    if nextProgress > 0 then
        local missing = nextProgress - progress
        if missing < 0 then missing = 0 end
        self.frame.barText:SetText(string.format("%d / %d", progress, nextProgress))
        self.frame.rewardText:SetText(string.format("下个奖励: %d 点进度  还差: %d", nextProgress, missing))
    elseif maxReward > 0 then
        self.frame.barText:SetText(string.format("%d / %d", progress, maxReward))
        self.frame.rewardText:SetText("奖励目标已全部达成")
    else
        self.frame.barText:SetText(tostring(progress))
        self.frame.rewardText:SetText("当前地图未配置进度奖励")
    end

    local deathLimit = tonumber(data.deathLimit) or 0
    if deathLimit > 0 then
        local deathCount = tonumber(data.deathCount) or 0
        local deathRemain = deathLimit - deathCount
        if deathRemain < 0 then deathRemain = 0 end
        self.frame.deathText:SetText(string.format("死亡剩余: %d / %d", deathRemain, deathLimit))
        self.frame.deathText:Show()
    else
        self.frame.deathText:SetText("")
        self.frame.deathText:Hide()
    end

    local timeLimit = tonumber(data.timeLimit) or 0
    if timeLimit > 0 then
        self.frame.timeText:SetText("剩余: " .. FormatTime(data.remaining))
        self.frame.timeText:Show()
    else
        self.frame.timeText:SetText("")
        self.frame.timeText:Hide()
    end

    local ruleText = FormatProgressRules(data.rules)
    self.frame.ruleText:SetText(ruleText ~= "" and ("击杀进度: " .. ruleText) or "")
    self.frame:Show()
end

function UI:Clear()
    self.data = nil
    if self.frame then
        self.frame:Hide()
    end
end

function UI:ParseData(message)
    local parts = Split(message, "|")
    if parts[1] == "CLEAR" then
        self:Clear()
        return
    end

    if parts[1] ~= "DATA" then
        return
    end

    self.data = {
        templateId = tonumber(parts[2]) or 0,
        title = parts[3] or "",
        progress = tonumber(parts[4]) or 0,
        nextProgress = tonumber(parts[5]) or 0,
        nextReward = tonumber(parts[6]) or 0,
        deathCount = tonumber(parts[7]) or 0,
        deathLimit = tonumber(parts[8]) or 0,
        remaining = tonumber(parts[9]) or 0,
        timeLimit = tonumber(parts[10]) or 0,
        elapsed = tonumber(parts[11]) or 0,
        loop = tonumber(parts[12]) or 0,
        comment = parts[13] or "",
        rewards = ParseRewardList(parts[14] or ""),
        rules = ParseProgressRules(parts[15] or "")
    }

    self:UpdateDisplay()
end

function UI:Query()
    SendAddon(PREFIX, "QUERY")
end

function UI:ScheduleQuery()
    self.pendingQuery = true
    self.queryElapsed = 0
end

local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:RegisterEvent("PLAYER_LOGIN")
eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
eventFrame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
eventFrame:RegisterEvent("CHAT_MSG_ADDON")
eventFrame:SetScript("OnEvent", function(_, event, ...)
    if event == "ADDON_LOADED" then
        local addonName = ...
        if addonName == ADDON_NAME then
            RegisterPrefix(PREFIX)
            UI:CreateFrame()
            UI:ScheduleQuery()
        end
    elseif event == "PLAYER_LOGIN" or event == "PLAYER_ENTERING_WORLD" or event == "ZONE_CHANGED_NEW_AREA" then
        UI:ScheduleQuery()
    elseif event == "CHAT_MSG_ADDON" then
        local prefix, message = ...
        if prefix == PREFIX and message then
            UI:ParseData(message)
        end
    end
end)

eventFrame:SetScript("OnUpdate", function(_, elapsed)
    if not UI.pendingQuery then
        return
    end

    UI.queryElapsed = (UI.queryElapsed or 0) + elapsed
    if UI.queryElapsed >= 1.0 then
        UI.pendingQuery = false
        UI.queryElapsed = 0
        UI:Query()
    end
end)

SLASH_MAPPROGRESSUI1 = "/mapprogress"
SLASH_MAPPROGRESSUI2 = "/地图进度"
SlashCmdList["MAPPROGRESSUI"] = function()
    if UI.frame and UI.frame:IsShown() then
        UI.frame:Hide()
    else
        UI:Query()
    end
end
