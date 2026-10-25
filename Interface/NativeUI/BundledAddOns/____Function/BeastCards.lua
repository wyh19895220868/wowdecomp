---@diagnostic disable: missing-parameter

local PAGE_SIZE = 24
local MAX_CARDS = 72
local MAX_QUALITY = 9
local PAGE_COUNT = 3
local CARDS_PER_ROW = 6
local CARD_WIDTH = 74
local CARD_HEIGHT = 104
local CARD_STEP_X = 108
local CARD_STEP_Y = 146
local DARK_PATH = "Interface\\Icons\\BeastCards\\Dark\\"
local COLOR_PATH = "Interface\\Icons\\BeastCards\\Color\\"

local GOLD = { 0.95, 0.70, 0.20, 1.0 }
local GOLD_MUTED = { 0.48, 0.34, 0.12, 0.9 }
local GREEN = { 0.30, 0.95, 0.48, 1.0 }
local TEXT = { 0.92, 0.90, 0.82, 1.0 }
local TEXT_MUTED = { 0.58, 0.58, 0.55, 1.0 }

local QUALITY = {
    [0] = { name = "D", hex = "9d9d9d", color = { 0.62, 0.62, 0.62, 1.0 } },
    [1] = { name = "C", hex = "ffffff", color = { 1.00, 1.00, 1.00, 1.0 } },
    [2] = { name = "B", hex = "1eff00", color = { 0.12, 1.00, 0.00, 1.0 } },
    [3] = { name = "A", hex = "0070dd", color = { 0.00, 0.44, 0.87, 1.0 } },
    [4] = { name = "S", hex = "a335ee", color = { 0.64, 0.21, 0.93, 1.0 } },
    [5] = { name = "SS", hex = "ff8000", color = { 1.00, 0.50, 0.00, 1.0 } },
    [6] = { name = "SSR", hex = "c69b6d", color = { 0.78, 0.61, 0.43, 1.0 } },
    [7] = { name = "SSS", hex = "ff2020", color = { 1.00, 0.13, 0.13, 1.0 } },
    [8] = { name = "SR", hex = "ff4fd8", color = { 1.00, 0.31, 0.85, 1.0 } },
    [9] = { name = "UR", hex = "ff4fd8", color = { 1.00, 0.31, 0.85, 1.0 }, rainbow = true }
}

local BeastCardState = {}
local BeastCardButtons = {}
local CurrentPage = 1
local SelectedCardId = nil
local EnabledCount = 0
local OpenedCount = 0

local function QualityInfo(quality)
    quality = math.max(0, math.min(MAX_QUALITY, tonumber(quality) or 0))
    return QUALITY[quality], quality
end

local function RainbowColor(offset)
    local position = ((GetTime() * 0.18) + (offset or 0)) % 1
    local section = math.floor(position * 6)
    local fraction = position * 6 - section

    if section == 0 then
        return 1, fraction, 0
    elseif section == 1 then
        return 1 - fraction, 1, 0
    elseif section == 2 then
        return 0, 1, fraction
    elseif section == 3 then
        return 0, 1 - fraction, 1
    elseif section == 4 then
        return fraction, 0, 1
    end

    return 1, 0, 1 - fraction
end

local function ColorHex(red, green, blue)
    return string.format("%02x%02x%02x",
        math.floor(red * 255 + 0.5),
        math.floor(green * 255 + 0.5),
        math.floor(blue * 255 + 0.5))
end

local function QualityText(quality)
    local info = QualityInfo(quality)
    if info.rainbow then
        local red1, green1, blue1 = RainbowColor(0)
        local red2, green2, blue2 = RainbowColor(0.38)
        return "|cff" .. ColorHex(red1, green1, blue1) .. "U|cff" ..
            ColorHex(red2, green2, blue2) .. "R|r"
    end

    return "|cff" .. info.hex .. info.name .. "|r"
end

local function CardTexturePath(cardId, opened)
    return (opened and COLOR_PATH or DARK_PATH) .. tostring(cardId)
end

local function CreateText(parent, template, width, height)
    local text = parent:CreateFontString(nil, "OVERLAY", template or "GameFontHighlightSmall")
    if width then
        text:SetWidth(width)
    end
    if height then
        text:SetHeight(height)
    end
    text:SetJustifyH("LEFT")
    text:SetJustifyV("TOP")
    return text
end

local function CreateSection(parent, title, x, y, width, height)
    local section = CreateFrame("Frame", nil, parent)
    section:SetSize(width, height)
    section:SetPoint("TOPLEFT", x, y)
    section:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8X8",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 10,
        insets = { left = 3, right = 3, top = 3, bottom = 3 }
    })
    section:SetBackdropColor(0.005, 0.006, 0.008, 0.92)
    section:SetBackdropBorderColor(unpack(GOLD_MUTED))

    section.title = CreateText(section, "GameFontNormal", width - 20, 20)
    section.title:SetPoint("TOPLEFT", 10, -8)
    section.title:SetText(title)
    section.title:SetTextColor(unpack(GOLD))

    section.body = CreateText(section, "GameFontHighlightSmall", width - 20, height - 38)
    section.body:SetPoint("TOPLEFT", 10, -31)
    section.body:SetTextColor(unpack(TEXT))
    section.body:SetText("")
    return section
end

local BeastCardFrame = CreateFrame("Frame", "BeastCardFrame", UIParent)
BeastCardFrame:SetSize(1120, 760)
BeastCardFrame:SetPoint("CENTER")
BeastCardFrame:SetToplevel(true)
BeastCardFrame:SetMovable(true)
BeastCardFrame:EnableMouse(true)
BeastCardFrame:RegisterForDrag("LeftButton")
BeastCardFrame:SetClampedToScreen(true)
BeastCardFrame:SetBackdrop({
    bgFile = "Interface\\Buttons\\WHITE8X8",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    edgeSize = 18,
    insets = { left = 5, right = 5, top = 5, bottom = 5 }
})
BeastCardFrame:SetBackdropColor(0.002, 0.003, 0.004, 0.965)
BeastCardFrame:SetBackdropBorderColor(0.88, 0.62, 0.13, 1.0)
BeastCardFrame:SetScript("OnDragStart", BeastCardFrame.StartMoving)
BeastCardFrame:SetScript("OnDragStop", BeastCardFrame.StopMovingOrSizing)
BeastCardFrame:Hide()
tinsert(UISpecialFrames, "BeastCardFrame")

local CloseButton = CreateFrame("Button", nil, BeastCardFrame, "UIPanelCloseButton")
CloseButton:SetPoint("TOPRIGHT", -7, -7)

local Title = CreateText(BeastCardFrame, "GameFontNormalLarge", 300, 24)
Title:SetPoint("TOP", 0, -20)
Title:SetJustifyH("CENTER")
Title:SetText("神兽翻牌")
Title:SetTextColor(unpack(GOLD))

local Progress = CreateText(BeastCardFrame, "GameFontHighlight", 660, 24)
Progress:SetPoint("TOPLEFT", 38, -54)
Progress:SetText("已激活 0 / 0")

local Divider = BeastCardFrame:CreateTexture(nil, "ARTWORK")
Divider:SetTexture(0.83, 0.58, 0.16, 0.58)
Divider:SetSize(1, 630)
Divider:SetPoint("TOPLEFT", 735, -82)

local CardArea = CreateFrame("Frame", nil, BeastCardFrame)
CardArea:SetSize(650, 570)
CardArea:SetPoint("TOPLEFT", 42, -88)

local IntroSection = CreateSection(BeastCardFrame, "神兽介绍", 760, -82, 325, 170)
local DetailTitle = CreateText(IntroSection, "GameFontNormalLarge", 295, 24)
DetailTitle:SetPoint("TOPLEFT", 14, -34)
DetailTitle:SetTextColor(unpack(GOLD))
DetailTitle:SetText("请选择一张神兽牌")

local DetailState = CreateText(IntroSection, "GameFontHighlightSmall", 295, 20)
DetailState:SetPoint("TOPLEFT", 14, -62)
DetailState:SetText("")

local DetailQuality = CreateText(IntroSection, "GameFontHighlightSmall", 295, 20)
DetailQuality:SetPoint("TOPLEFT", 14, -84)
DetailQuality:SetText("品质：|cff9d9d9dD|r")

local IntroText = CreateText(IntroSection, "GameFontHighlightSmall", 295, 45)
IntroText:SetPoint("TOPLEFT", 14, -108)
IntroText:SetTextColor(unpack(TEXT))
IntroText:SetText("选择卡牌后查看介绍。")

local NeedSection = CreateSection(BeastCardFrame, "翻牌需求", 760, -262, 325, 105)
local RewardSection = CreateSection(BeastCardFrame, "翻牌奖励", 760, -377, 325, 105)
local KillSection = CreateSection(BeastCardFrame, "生物击杀", 760, -492, 158, 145)
local AttributeSection = CreateSection(BeastCardFrame, "品质效果", 927, -492, 158, 145)

local FlipButton = CreateFrame("Button", nil, BeastCardFrame, "UIPanelButtonTemplate")
FlipButton:SetSize(180, 32)
FlipButton:SetPoint("BOTTOMRIGHT", -42, 35)
FlipButton:SetText("翻开此牌")
FlipButton:Disable()

local ShowingBonds = false
local BondEntries = {}

local BondToggleButton = CreateFrame("Button", nil, BeastCardFrame, "UIPanelButtonTemplate")
BondToggleButton:SetSize(110, 25)
BondToggleButton:SetPoint("TOPRIGHT", -42, -50)
BondToggleButton:SetText("查看羁绊")

local BondsPanel = CreateFrame("Frame", nil, BeastCardFrame)
BondsPanel:SetSize(325, 590)
BondsPanel:SetPoint("TOPLEFT", 760, -82)
BondsPanel:SetBackdrop({
    bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true,
    tileSize = 16,
    edgeSize = 12,
    insets = { left = 4, right = 4, top = 4, bottom = 4 }
})
BondsPanel:SetBackdropColor(0.01, 0.012, 0.016, 0.96)
BondsPanel:SetBackdropBorderColor(unpack(GOLD_MUTED))

BondsPanel.title = CreateText(BondsPanel, "GameFontNormalLarge", 295, 25)
BondsPanel.title:SetPoint("TOPLEFT", 15, -14)
BondsPanel.title:SetText("神兽羁绊")
BondsPanel.title:SetTextColor(unpack(GOLD))

BondsPanel.scroll = CreateFrame("ScrollingMessageFrame", nil, BondsPanel)
BondsPanel.scroll:SetSize(291, 525)
BondsPanel.scroll:SetPoint("TOPLEFT", 16, -50)
BondsPanel.scroll:SetFont(Dream_GameFont, 13)
BondsPanel.scroll:SetSpacing(7)
BondsPanel.scroll:SetFading(false)
BondsPanel.scroll:SetInsertMode("BOTTOM")
BondsPanel.scroll:SetMaxLines(256)
BondsPanel.scroll:EnableMouseWheel(true)
BondsPanel.scroll:SetScript("OnMouseWheel", function(self, delta)
    if delta < 0 then
        self:ScrollDown()
    else
        self:ScrollUp()
    end
end)
BondsPanel:Hide()

local function RenderBondEntries()
    BondsPanel.scroll:Clear()
    if #BondEntries == 0 then
        BondsPanel.scroll:AddMessage("|cff888888暂未配置神兽羁绊。|r")
        return
    end

    for _, entry in ipairs(BondEntries) do
        local status = entry.active and "|cff55ff77已激活|r" or "|cffffcc55未激活|r"
        local nameColor = entry.active and "|cff55ff77" or "|cffffcc55"
        BondsPanel.scroll:AddMessage(string.format(
            "%s%s|r  %s\n进度：%d/%d（组合%d张）\n卡牌：%s\n|cffff4fd8%s|r\n",
            nameColor, entry.name, status, entry.openedCount, entry.requiredCount, entry.totalCount,
            entry.cardText, entry.description))
    end
end

local function SetBondPanelShown(show)
    ShowingBonds = show and true or false
    if ShowingBonds then
        IntroSection:Hide()
        NeedSection:Hide()
        RewardSection:Hide()
        KillSection:Hide()
        AttributeSection:Hide()
        FlipButton:Hide()
        BondsPanel:Show()
        BondToggleButton:SetText("返回卡牌")
        BondEntries = {}
        BondsPanel.scroll:Clear()
        BondsPanel.scroll:AddMessage("|cffffcc55正在读取羁绊配置...|r")
        Dream_SendData("BeastCardBondState")
    else
        BondsPanel:Hide()
        IntroSection:Show()
        NeedSection:Show()
        RewardSection:Show()
        KillSection:Show()
        AttributeSection:Show()
        FlipButton:Show()
        BondToggleButton:SetText("查看羁绊")
    end
end

BondToggleButton:SetScript("OnClick", function()
    SetBondPanelShown(not ShowingBonds)
end)

local function UpdateProgress()
    Progress:SetText(string.format("已激活 |cff55ef7f%d|r / %d", OpenedCount, EnabledCount))
end

local function UpdateCardVisual(button)
    local state = button.cardId and BeastCardState[button.cardId]
    if not state then
        button:Hide()
        return
    end

    button:Show()
    button.image:SetTexture(CardTexturePath(button.cardId, state.opened))
    button.name:SetText(state.name or string.format("神兽牌 %02d", button.cardId))
    button.image:SetVertexColor(1, 1, 1)
    local qualityInfo = QualityInfo(state.quality)
    button.quality:SetText(QualityText(state.quality))
    if qualityInfo.rainbow then
        local red, green, blue = RainbowColor((button.cardId or 0) * 0.071)
        button:SetBackdropBorderColor(red, green, blue, 1)
    else
        button:SetBackdropBorderColor(unpack(qualityInfo.color))
    end
    button:SetBackdropColor(0.003, 0.004, 0.005, 0.98)

    if state.opened then
        if qualityInfo.rainbow then
            local red, green, blue = RainbowColor((button.cardId or 0) * 0.071)
            button.name:SetTextColor(red, green, blue, 1)
        else
            button.name:SetTextColor(unpack(qualityInfo.color))
        end
    elseif button.cardId == SelectedCardId then
        button.name:SetTextColor(1.0, 0.82, 0.38, 1.0)
        button:SetBackdropColor(0.16, 0.10, 0.025, 0.98)
    elseif state.ready then
        button.name:SetTextColor(unpack(GOLD))
    elseif state.enabled then
        button.name:SetTextColor(0.76, 0.74, 0.69, 1.0)
    else
        button.name:SetTextColor(unpack(TEXT_MUTED))
        button.image:SetVertexColor(0.34, 0.34, 0.34)
    end

    if button.cardId == SelectedCardId then
        button:SetBackdropColor(0.16, 0.10, 0.025, 0.98)
    end
end

local function RefreshPage()
    for index, button in ipairs(BeastCardButtons) do
        button.cardId = (CurrentPage - 1) * PAGE_SIZE + index
        button.flipping = false
        button.colorApplied = nil
        button:SetScript("OnUpdate", nil)
        button.image:SetAlpha(1)

        if button.cardId <= MAX_CARDS and BeastCardState[button.cardId] then
            UpdateCardVisual(button)
        else
            button:Hide()
        end
    end
end

local function SetDetailStatus(state)
    if not state.enabled then
        DetailState:SetText("|cff888888尚未开放|r")
        FlipButton:SetText("尚未开放")
        FlipButton:Disable()
    elseif state.opened then
        DetailState:SetText("|cff55ef7f已激活|r · 当前" .. QualityText(state.quality))
        if (state.quality or 0) >= MAX_QUALITY then
            FlipButton:SetText("已达UR品质")
            FlipButton:Disable()
        elseif state.canUpgrade then
            FlipButton:SetText("升级至" .. QualityText((state.quality or 0) + 1))
            FlipButton:Enable()
        else
            FlipButton:SetText("下一品质未开放")
            FlipButton:Disable()
        end
    elseif state.ready then
        DetailState:SetText("|cffffcf55可翻牌|r")
        FlipButton:SetText("翻开此牌")
        FlipButton:Enable()
    else
        DetailState:SetText("|cffff9f43击杀条件未达成|r")
        FlipButton:SetText("击杀未达标")
        FlipButton:Disable()
    end
end

local function SetSelectedCard(cardId)
    local state = BeastCardState[cardId]
    if not state then
        return
    end

    SelectedCardId = cardId
    DetailTitle:SetText(state.name or "神兽牌")
    DetailQuality:SetText("品质：" .. QualityText(state.quality))
    IntroText:SetText("正在读取神兽介绍...")
    NeedSection.title:SetText(state.opened and "品质升级需求" or "翻牌需求")
    NeedSection.body:SetText("正在读取...")
    RewardSection.body:SetText("正在读取...")
    KillSection.body:SetText(string.format("进度 %d / %d", state.killCount or 0, state.killNeed or 0))
    AttributeSection.body:SetText("正在读取...")
    SetDetailStatus(state)
    RefreshPage()
    Dream_SendData("BeastCardDetail", tostring(cardId))
end

local function PlayFlipAnimation(button)
    if not button then
        return
    end

    button.flipElapsed = 0
    button.flipping = true
    button.image:SetAlpha(1)
    button:SetScript("OnUpdate", function(self, elapsed)
        self.flipElapsed = self.flipElapsed + elapsed
        local duration = 0.48
        local half = duration / 2

        if self.flipElapsed < half then
            self.image:SetAlpha(math.max(0.05, 1 - self.flipElapsed / half))
        elseif self.flipElapsed < duration then
            if not self.colorApplied then
                self.colorApplied = true
                self.image:SetTexture(CardTexturePath(self.cardId, true))
            end
            self.image:SetAlpha(math.max(0.05, (self.flipElapsed - half) / half))
        else
            self.image:SetAlpha(1)
            self.flipping = false
            self.colorApplied = nil
            self:SetScript("OnUpdate", nil)
            UpdateCardVisual(self)
        end
    end)
end

for index = 1, PAGE_SIZE do
    local column = (index - 1) % CARDS_PER_ROW
    local row = math.floor((index - 1) / CARDS_PER_ROW)
    local button = CreateFrame("Button", nil, CardArea)
    button:SetSize(CARD_WIDTH + 8, CARD_HEIGHT + 8)
    button:SetPoint("TOPLEFT", column * CARD_STEP_X, -row * CARD_STEP_Y)
    button:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8X8",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 8,
        insets = { left = 2, right = 2, top = 2, bottom = 2 }
    })
    button:SetBackdropColor(0.003, 0.004, 0.005, 0.98)
    button:SetBackdropBorderColor(unpack(GOLD_MUTED))

    button.image = button:CreateTexture(nil, "ARTWORK")
    button.image:SetSize(CARD_WIDTH, CARD_HEIGHT)
    button.image:SetPoint("CENTER")

    button.quality = CreateText(button, "GameFontHighlightSmall", CARD_WIDTH - 8, 18)
    button.quality:SetPoint("TOP", button.image, "TOP", 0, -5)
    button.quality:SetJustifyH("CENTER")
    button.quality:SetShadowColor(0, 0, 0, 1)
    button.quality:SetShadowOffset(1, -1)
    button.quality:SetText("|cff9d9d9dD|r")

    button.highlight = button:CreateTexture(nil, "HIGHLIGHT")
    button.highlight:SetTexture("Interface\\Buttons\\ButtonHilight-Square")
    button.highlight:SetBlendMode("ADD")
    button.highlight:SetAllPoints(button.image)

    button.name = CreateText(button, "GameFontHighlightSmall", CARD_STEP_X - 4, 22)
    button.name:SetPoint("TOP", button, "BOTTOM", 0, -3)
    button.name:SetJustifyH("CENTER")
    button.name:SetText("")

    button:SetScript("OnClick", function(self)
        if self.cardId and BeastCardState[self.cardId] then
            SetSelectedCard(self.cardId)
        end
    end)
    button:SetScript("OnEnter", function(self)
        local state = self.cardId and BeastCardState[self.cardId]
        if not state then
            return
        end

        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        local qualityInfo = QualityInfo(state.quality)
        GameTooltip:SetText(state.name or string.format("神兽牌 %02d", self.cardId), unpack(qualityInfo.color))
        GameTooltip:AddLine("品质：" .. QualityText(state.quality), 1, 1, 1)
        if state.opened then
            GameTooltip:AddLine("已激活", 0.30, 0.95, 0.48)
        elseif state.ready then
            GameTooltip:AddLine("可翻牌", 1.0, 0.80, 0.32)
        elseif state.enabled then
            GameTooltip:AddLine(string.format("击杀进度 %d / %d", state.killCount or 0, state.killNeed or 0), 1.0, 0.62, 0.28)
        else
            GameTooltip:AddLine("尚未开放", 0.55, 0.55, 0.55)
        end
        GameTooltip:Show()
    end)
    button:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)
    BeastCardButtons[index] = button
end

local PageText = CreateText(BeastCardFrame, "GameFontHighlight", 70, 24)
PageText:SetPoint("BOTTOMLEFT", 314, 34)
PageText:SetJustifyH("CENTER")
PageText:SetText("1 / 3")
PageText:SetTextColor(unpack(GOLD))

local PrevButton = CreateFrame("Button", nil, BeastCardFrame)
PrevButton:SetSize(32, 32)
PrevButton:SetPoint("RIGHT", PageText, "LEFT", -14, 0)
PrevButton:SetNormalTexture("Interface\\Buttons\\UI-SpellbookIcon-PrevPage-Up")
PrevButton:SetPushedTexture("Interface\\Buttons\\UI-SpellbookIcon-PrevPage-Down")
PrevButton:SetDisabledTexture("Interface\\Buttons\\UI-SpellbookIcon-PrevPage-Disabled")
PrevButton:SetHighlightTexture("Interface\\Buttons\\UI-Common-MouseHilight", "ADD")
PrevButton:SetScript("OnClick", function()
    if CurrentPage > 1 then
        CurrentPage = CurrentPage - 1
        SelectedCardId = nil
        PageText:SetText(string.format("%d / %d", CurrentPage, PAGE_COUNT))
        RefreshPage()
    end
end)

local NextButton = CreateFrame("Button", nil, BeastCardFrame)
NextButton:SetSize(32, 32)
NextButton:SetPoint("LEFT", PageText, "RIGHT", 14, 0)
NextButton:SetNormalTexture("Interface\\Buttons\\UI-SpellbookIcon-NextPage-Up")
NextButton:SetPushedTexture("Interface\\Buttons\\UI-SpellbookIcon-NextPage-Down")
NextButton:SetDisabledTexture("Interface\\Buttons\\UI-SpellbookIcon-NextPage-Disabled")
NextButton:SetHighlightTexture("Interface\\Buttons\\UI-Common-MouseHilight", "ADD")
NextButton:SetScript("OnClick", function()
    if CurrentPage < PAGE_COUNT then
        CurrentPage = CurrentPage + 1
        SelectedCardId = nil
        PageText:SetText(string.format("%d / %d", CurrentPage, PAGE_COUNT))
        RefreshPage()
    end
end)

FlipButton:SetScript("OnClick", function()
    local state = SelectedCardId and BeastCardState[SelectedCardId]
    if state and state.enabled and state.ready and not state.opened then
        FlipButton:Disable()
        FlipButton:SetText("翻牌中...")
        Dream_SendData("BeastCardFlip", tostring(SelectedCardId))
    elseif state and state.enabled and state.opened and state.canUpgrade and (state.quality or 0) < MAX_QUALITY then
        FlipButton:Disable()
        FlipButton:SetText("品质提升中...")
        Dream_SendData("BeastCardUpgrade", tostring(SelectedCardId) .. "#" .. tostring(state.quality or 0))
    end
end)

BeastCardFrame:SetScript("OnShow", function()
    local fitScale = math.min(1, (UIParent:GetWidth() - 24) / 1120, (UIParent:GetHeight() - 24) / 760)
    BeastCardFrame:SetScale(fitScale)
    SetBondPanelShown(false)
    Dream_SendData("BeastCardState")
end)

local function ParseCardDetail(message)
    local values = Dream_Split(message, "#")
    local cardId = tonumber(values[1])
    if cardId ~= SelectedCardId then
        return
    end

    local state = BeastCardState[cardId]
    if not state then
        return
    end

    state.name = values[2] or state.name
    state.opened = values[11] == "1"
    state.ready = values[12] == "1"
    state.killCount = tonumber(values[7]) or state.killCount or 0
    state.killNeed = tonumber(values[8]) or state.killNeed or 0
    state.quality = tonumber(values[13]) or state.quality or 0
    state.canUpgrade = values[14] == "1"

    DetailTitle:SetText(state.name or "神兽牌")
    DetailQuality:SetText("品质：" .. QualityText(state.quality))
    IntroText:SetText(values[3] or "暂无介绍")
    NeedSection.title:SetText(state.opened and "品质升级需求" or "翻牌需求")
    NeedSection.body:SetText(state.opened and (values[15] or "下一品质尚未开放") or (values[4] or "无需额外消耗"))
    RewardSection.body:SetText(values[5] or "无物品奖励")

    if state.killNeed > 0 then
        local progressColor = state.killCount >= state.killNeed and "|cff55ef7f" or "|cffffa34d"
        KillSection.body:SetText(string.format("%s\n%s%d / %d|r", values[6] or "未知生物", progressColor, state.killCount, state.killNeed))
    else
        KillSection.body:SetText("无需击杀\n|cff55ef7f条件已满足|r")
    end

    local effectStatus = state.opened and "\n|cff55ef7f已激活|r" or "\n|cffb7b7b7翻开后生效|r"
    local effectText = values[9] or "未配置品质效果"
    if state.opened and (state.quality or 0) < MAX_QUALITY then
        effectText = "当前：" .. effectText .. "\n下一档：" .. (values[16] or "暂无配置")
    end
    AttributeSection.body:SetText(effectText .. effectStatus)
    SetDetailStatus(state)
    RefreshPage()
end

local function OnBeastCardEvent(_, event, packet, message)
    if event ~= "CHAT_MSG_ADDON" then
        return
    end

    if packet == "OpenBeastCardUI" then
        BeastCardFrame:Show()
    elseif packet == "BeastCardStateBegin" then
        BeastCardState = {}
        SelectedCardId = nil
        local values = Dream_Split(message, "#")
        EnabledCount = tonumber(values[1]) or 0
        OpenedCount = tonumber(values[2]) or 0
        UpdateProgress()
    elseif packet == "BeastCardStateCard" then
        local values = Dream_Split(message, "#")
        local cardId = tonumber(values[1])
        if cardId then
            BeastCardState[cardId] = {
                enabled = values[2] == "1",
                ready = values[3] == "1",
                opened = values[4] == "1",
                killCount = tonumber(values[5]) or 0,
                killNeed = tonumber(values[6]) or 0,
                name = values[7] or string.format("神兽牌 %02d", cardId),
                quality = tonumber(values[8]) or 0,
                canUpgrade = values[9] == "1"
            }
        end
    elseif packet == "BeastCardStateEnd" then
        RefreshPage()
        local firstId = (CurrentPage - 1) * PAGE_SIZE + 1
        if BeastCardState[firstId] then
            SetSelectedCard(firstId)
        end
    elseif packet == "BeastCardDetail" then
        ParseCardDetail(message)
    elseif packet == "BeastCardBondBegin" then
        BondEntries = {}
        BondsPanel.scroll:Clear()
    elseif packet == "BeastCardBondData" then
        local values = Dream_Split(message, "#")
        table.insert(BondEntries, {
            id = tonumber(values[1]) or 0,
            active = values[2] == "1",
            openedCount = tonumber(values[3]) or 0,
            requiredCount = tonumber(values[4]) or 0,
            totalCount = tonumber(values[5]) or 0,
            name = values[6] or "神兽羁绊",
            cardText = values[7] or "未配置卡牌",
            description = values[8] or "未配置羁绊效果"
        })
    elseif packet == "BeastCardBondEnd" then
        RenderBondEntries()
    elseif packet == "BeastCardKillProgress" then
        local values = Dream_Split(message, "#")
        local cardId = tonumber(values[1])
        local state = cardId and BeastCardState[cardId]
        if state then
            state.killCount = tonumber(values[2]) or state.killCount
            state.killNeed = tonumber(values[3]) or state.killNeed
            state.ready = values[4] == "1"
            RefreshPage()
            if cardId == SelectedCardId then
                Dream_SendData("BeastCardDetail", tostring(cardId))
            end
        end
    elseif packet == "BeastCardFlipResult" then
        local values = Dream_Split(message, "#")
        local cardId = tonumber(values[1])
        local state = cardId and BeastCardState[cardId]
        if state and not state.opened then
            state.opened = true
            state.ready = false
            state.quality = tonumber(values[2]) or 0
            state.canUpgrade = values[3] == "1"
            OpenedCount = OpenedCount + 1
            UpdateProgress()
            for _, button in ipairs(BeastCardButtons) do
                if button.cardId == cardId then
                    PlayFlipAnimation(button)
                    break
                end
            end
            SetSelectedCard(cardId)
            if ShowingBonds then
                Dream_SendData("BeastCardBondState")
            end
        end
    elseif packet == "BeastCardUpgradeResult" then
        local values = Dream_Split(message, "#")
        local cardId = tonumber(values[1])
        local state = cardId and BeastCardState[cardId]
        if state then
            state.quality = tonumber(values[2]) or state.quality or 0
            state.canUpgrade = values[3] == "1"
            RefreshPage()
            if cardId == SelectedCardId then
                SetSelectedCard(cardId)
            end
        end
    elseif packet == "BeastCardFlipRejected" then
        local cardId = tonumber(message)
        local state = cardId and BeastCardState[cardId]
        if cardId == SelectedCardId and state then
            SetDetailStatus(state)
        end
    elseif packet == "BeastCardUpgradeRejected" then
        local cardId = tonumber(message)
        local state = cardId and BeastCardState[cardId]
        if cardId == SelectedCardId and state then
            SetDetailStatus(state)
            Dream_SendData("BeastCardDetail", tostring(cardId))
        end
    end
end

local BeastCardEventFrame = CreateFrame("Frame")
BeastCardEventFrame:RegisterEvent("CHAT_MSG_ADDON")
BeastCardEventFrame:SetScript("OnEvent", OnBeastCardEvent)

local RainbowAnimator = CreateFrame("Frame")
local RainbowElapsed = 0
RainbowAnimator:SetScript("OnUpdate", function(_, elapsed)
    RainbowElapsed = RainbowElapsed + elapsed
    if RainbowElapsed < 0.04 then
        return
    end
    RainbowElapsed = 0

    for _, button in ipairs(BeastCardButtons) do
        local state = button.cardId and BeastCardState[button.cardId]
        if state and state.opened and (state.quality or 0) == MAX_QUALITY and button:IsShown() then
            local red, green, blue = RainbowColor((button.cardId or 0) * 0.071)
            button:SetBackdropBorderColor(red, green, blue, 1)
            button.quality:SetText(QualityText(MAX_QUALITY))
            button.name:SetTextColor(red, green, blue, 1)
        end
    end

    local selectedState = SelectedCardId and BeastCardState[SelectedCardId]
    if selectedState and selectedState.opened and (selectedState.quality or 0) == MAX_QUALITY then
        DetailQuality:SetText("品质：" .. QualityText(MAX_QUALITY))
        DetailState:SetText("|cff55ef7f已激活|r · 当前" .. QualityText(MAX_QUALITY))
    end
end)
