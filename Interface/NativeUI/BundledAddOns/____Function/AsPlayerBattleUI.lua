local ADDON_NAME = "____Function"
local RESPONSE_PREFIX = "AsPlayerBattleUI"

AsPlayerBattleUI = AsPlayerBattleUI or {}
local UI = AsPlayerBattleUI

UI.data = nil
UI.frame = nil
UI.queryElapsed = 0
UI.pendingQuery = true

local TEAM_ALLIANCE = 1
local TEAM_HORDE = 2

local function Split(text, separator)
    local values = {}
    local start = 1
    text = tostring(text or "")

    while true do
        local position = string.find(text, separator, start, true)
        if not position then
            table.insert(values, string.sub(text, start))
            break
        end

        table.insert(values, string.sub(text, start, position - 1))
        start = position + string.len(separator)
    end

    return values
end

local function Clamp(value, minimum, maximum)
    value = tonumber(value) or 0
    if value < minimum then return minimum end
    if value > maximum then return maximum end
    return value
end

local function TeamName(team)
    return team == TEAM_ALLIANCE and "联盟" or "部落"
end

local function TeamColor(team)
    if team == TEAM_ALLIANCE then
        return 0.12, 0.42, 0.92
    end
    return 0.78, 0.08, 0.08
end

local function TeamLogo(team)
    if team == TEAM_ALLIANCE then
        return "Interface\\timer\\alliance-logo"
    end
    return "Interface\\timer\\horde-logo"
end

local function CreateProgressRow(parent, yOffset)
    local row = CreateFrame("Frame", nil, parent)
    row:SetSize(402, 48)
    row:SetPoint("TOPLEFT", parent, "TOPLEFT", 14, yOffset)

    row.logo = row:CreateTexture(nil, "ARTWORK")
    row.logo:SetSize(42, 42)
    row.logo:SetPoint("LEFT", row, "LEFT", 0, 0)

    row.teamText = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    row.teamText:SetPoint("CENTER", row.logo, "CENTER", 0, -1)
    row.teamText:SetShadowOffset(1, -1)

    row.label = row:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    row.label:SetPoint("TOPLEFT", row, "TOPLEFT", 52, -1)
    row.label:SetPoint("TOPRIGHT", row, "TOPRIGHT", -2, -1)
    row.label:SetJustifyH("LEFT")
    row.label:SetWordWrap(false)

    row.barBorder = CreateFrame("Frame", nil, row)
    row.barBorder:SetSize(348, 20)
    row.barBorder:SetPoint("BOTTOMLEFT", row, "BOTTOMLEFT", 52, 1)
    row.barBorder:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8X8",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 9,
        insets = { left = 2, right = 2, top = 2, bottom = 2 }
    })
    row.barBorder:SetBackdropColor(0.015, 0.02, 0.025, 0.92)
    row.barBorder:SetBackdropBorderColor(0.42, 0.42, 0.42, 0.9)

    row.bar = CreateFrame("StatusBar", nil, row.barBorder)
    row.bar:SetPoint("TOPLEFT", row.barBorder, "TOPLEFT", 3, -3)
    row.bar:SetPoint("BOTTOMRIGHT", row.barBorder, "BOTTOMRIGHT", -3, 3)
    row.bar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
    row.bar:SetMinMaxValues(0, 1)
    row.bar:SetValue(0)

    row.barText = row.bar:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    row.barText:SetPoint("CENTER", row.bar, "CENTER", 0, 0)
    row.barText:SetShadowOffset(1, -1)

    return row
end

function UI:CreateFrame()
    if self.frame then return end

    local frame = CreateFrame("Frame", "AsPlayerBattleUIFrame", UIParent)
    frame:SetSize(430, 148)
    frame:SetFrameStrata("MEDIUM")
    frame:SetPoint("RIGHT", UIParent, "RIGHT", -18, 205)
    frame:SetClampedToScreen(true)
    frame:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background-Dark",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true,
        tileSize = 16,
        edgeSize = 12,
        insets = { left = 4, right = 4, top = 4, bottom = 4 }
    })
    frame:SetBackdropColor(0.018, 0.022, 0.028, 0.9)
    frame:SetBackdropBorderColor(0.68, 0.57, 0.3, 0.95)

    frame.title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    frame.title:SetPoint("TOPLEFT", frame, "TOPLEFT", 14, -10)
    frame.title:SetText("全服对战资源争夺")
    frame.title:SetTextColor(1.0, 0.82, 0.35)

    frame.ruleText = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    frame.ruleText:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -14, -13)
    frame.ruleText:SetJustifyH("RIGHT")

    frame.alliance = CreateProgressRow(frame, -38)
    frame.horde = CreateProgressRow(frame, -88)

    self.frame = frame
    frame:Hide()
end

function UI:UpdateRow(row, team, current, target, isPlayerTeam)
    local red, green, blue = TeamColor(team)
    local maximum = math.max(tonumber(target) or 0, 1)
    local value = Clamp(current, 0, maximum)
    local playerMark = isPlayerTeam and "  |cffffd24a[我方]|r" or ""

    row.logo:SetTexture(TeamLogo(team))
    row.teamText:SetText(TeamName(team))
    row.teamText:SetTextColor(red, green, blue)
    row.label:SetText(string.format("%s方：全服混排阵营  ·  占领资源点%s", TeamName(team), playerMark))
    row.label:SetTextColor(red + (1 - red) * 0.28, green + (1 - green) * 0.28, blue + (1 - blue) * 0.28)
    row.bar:SetStatusBarColor(red, green, blue, 1)
    row.bar:SetMinMaxValues(0, maximum)
    row.bar:SetValue(value)
    row.barText:SetText(string.format("%d / %d", tonumber(current) or 0, tonumber(target) or 0))
end

function UI:UpdateDisplay()
    if not self.frame then self:CreateFrame() end
    if not self.data then return end

    local data = self.data
    self.frame.ruleText:SetText(string.format("目标资源点 %d    每秒增加 +%d", data.target, data.increment))
    self:UpdateRow(self.frame.alliance, TEAM_ALLIANCE, data.alliance, data.target, data.role == TEAM_ALLIANCE)
    self:UpdateRow(self.frame.horde, TEAM_HORDE, data.horde, data.target, data.role == TEAM_HORDE)
    self.frame:Show()
end

function UI:Clear()
    self.data = nil
    if self.frame then
        self.frame:Hide()
    end
end

function UI:ParseData(message)
    local fields = Split(message, "|")
    if fields[1] == "CLEAR" then
        self:Clear()
        return
    end

    if fields[1] ~= "DATA" then return end

    self.data = {
        alliance = tonumber(fields[2]) or 0,
        horde = tonumber(fields[3]) or 0,
        target = tonumber(fields[4]) or 0,
        increment = tonumber(fields[5]) or 0,
        role = tonumber(fields[6]) or 0
    }
    self:UpdateDisplay()
end

function UI:Query()
    if Dream_SendData then
        Dream_SendData("GetAsPlayerBattleUI")
    end
end

function UI:ScheduleQuery()
    self.pendingQuery = true
    self.queryElapsed = 0
end

local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:RegisterEvent("PLAYER_LOGIN")
eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
eventFrame:RegisterEvent("CHAT_MSG_ADDON")
eventFrame:SetScript("OnEvent", function(_, event, ...)
    if event == "ADDON_LOADED" then
        local addonName = ...
        if addonName == ADDON_NAME then
            UI:CreateFrame()
            UI:ScheduleQuery()
        end
    elseif event == "PLAYER_LOGIN" or event == "PLAYER_ENTERING_WORLD" then
        UI:ScheduleQuery()
    elseif event == "CHAT_MSG_ADDON" then
        local prefix, message = ...
        if prefix == RESPONSE_PREFIX and message then
            UI:ParseData(message)
        end
    end
end)

eventFrame:SetScript("OnUpdate", function(_, elapsed)
    if not UI.pendingQuery then return end

    UI.queryElapsed = UI.queryElapsed + elapsed
    if UI.queryElapsed >= 1 then
        UI.pendingQuery = false
        UI.queryElapsed = 0
        UI:Query()
    end
end)

SLASH_ASPLAYERBATTLEUI1 = "/apbui"
SlashCmdList.ASPLAYERBATTLEUI = function()
    UI:Query()
end
