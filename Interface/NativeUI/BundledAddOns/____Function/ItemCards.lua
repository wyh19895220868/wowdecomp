---@diagnostic disable: missing-parameter

local CARD_COUNT = 8
local MAX_LEVEL = 10
local CARD_W = 108
local CARD_H = 148
local CARD_GAP_X = 14
local CARD_GAP_Y = 12

local DARK_PATH = "Interface\\Icons\\ItemCards\\Dark\\"
local COLOR_PATH = "Interface\\Icons\\ItemCards\\Color\\"
local FRAME_PATH = "Interface\\Icons\\ItemCards\\Frame\\level_"
local PANEL_BG = "Interface\\Icons\\ItemCards\\UI\\panel_bg"
local BTN_UPGRADE = "Interface\\Icons\\ItemCards\\UI\\btn_upgrade"

local GOLD = { 0.95, 0.78, 0.28, 1 }
local GOLD_MUTED = { 0.55, 0.42, 0.16, 0.95 }
local TEXT = { 0.92, 0.90, 0.82, 1 }
local TEXT_MUTED = { 0.62, 0.62, 0.58, 1 }

ItemCardsUIState = ItemCardsUIState or {
    levels = { 1, 1, 1, 1, 1, 1, 1, 1 },
    opened = { false, false, false, false, false, false, false, false },
}

local CardsLeftButtons = {}
local CardsTaskButtons = {}
local SelectedSlot = nil

local function ClampLevel(level)
    level = tonumber(level) or 1
    if level < 1 then
        return 1
    end
    if level > MAX_LEVEL then
        return MAX_LEVEL
    end
    return math.floor(level)
end

local function GetSlotLevel(slot)
    ItemCardsUIState.levels = ItemCardsUIState.levels or {}
    return ClampLevel(ItemCardsUIState.levels[slot] or 1)
end

local function SetSlotLevel(slot, level)
    ItemCardsUIState.levels = ItemCardsUIState.levels or {}
    ItemCardsUIState.levels[slot] = ClampLevel(level)
end

local function IsOpened(slot)
    ItemCardsUIState.opened = ItemCardsUIState.opened or {}
    return ItemCardsUIState.opened[slot] and true or false
end

local function SetOpened(slot, opened)
    ItemCardsUIState.opened = ItemCardsUIState.opened or {}
    ItemCardsUIState.opened[slot] = opened and true or false
end

local function CreateLabel(parent, size, width)
    local text = parent:CreateFontString(nil, "OVERLAY")
    text:SetFont(Dream_GameFont, size or 14)
    if width then
        text:SetWidth(width)
    end
    text:SetJustifyH("LEFT")
    text:SetJustifyV("TOP")
    return text
end

local ItemCardsFrame = CreateFrame("Frame", "ItemCardsFrame", UIParent)
ItemCardsFrame:SetSize(1020, 740)
ItemCardsFrame:SetPoint("CENTER", 0, 40)
ItemCardsFrame:SetClampedToScreen(true)
ItemCardsFrame:EnableMouse(true)
ItemCardsFrame:SetMovable(true)
ItemCardsFrame:RegisterForDrag("LeftButton")
ItemCardsFrame:SetScript("OnDragStart", ItemCardsFrame.StartMoving)
ItemCardsFrame:SetScript("OnDragStop", ItemCardsFrame.StopMovingOrSizing)
ItemCardsFrame:SetToplevel(true)
ItemCardsFrame:SetBackdrop({
    bgFile = "Interface\\Buttons\\WHITE8X8",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    edgeSize = 16,
    insets = { left = 4, right = 4, top = 4, bottom = 4 }
})
ItemCardsFrame:SetBackdropColor(0.01, 0.012, 0.015, 0.92)
ItemCardsFrame:SetBackdropBorderColor(0.78, 0.58, 0.18, 1)
ItemCardsFrame:Hide()
tinsert(UISpecialFrames, "ItemCardsFrame")

local PanelBg = ItemCardsFrame:CreateTexture(nil, "BACKGROUND")
PanelBg:SetTexture(PANEL_BG)
PanelBg:SetAllPoints(ItemCardsFrame)
PanelBg:SetVertexColor(1, 1, 1, 0.88)

local ItemCardsBtnClose = CreateFrame("Button", "ItemCardsBtnClose", ItemCardsFrame, "UIPanelCloseButton")
ItemCardsBtnClose:SetPoint("TOPRIGHT", 2, 2)
ItemCardsBtnClose:SetSize(36, 36)

local ItemCardsFrameText = CreateLabel(ItemCardsFrame, 16, 700)
ItemCardsFrameText:SetPoint("TOP", 0, -18)
ItemCardsFrameText:SetJustifyH("CENTER")
ItemCardsFrameText:SetText("|cffF0C850卡牌展柜|r  |cffB8B0A0同效果可组成 2 / 4 / 6 / 8 套装|r")

local CardArea = CreateFrame("Frame", "ItemCardsLeftFrame", ItemCardsFrame)
CardArea:SetSize(500, 360)
CardArea:SetPoint("TOPLEFT", 36, -58)

local SetArea = CreateFrame("Frame", nil, ItemCardsFrame)
SetArea:SetSize(430, 560)
SetArea:SetPoint("TOPRIGHT", -28, -58)

local function CreateSetPanel(parent, key, y)
    local panel = CreateFrame("Frame", "ItemCardGroupFrame" .. key, parent)
    panel:SetSize(430, 128)
    panel:SetPoint("TOPLEFT", 0, y)
    panel:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8X8",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 12,
        insets = { left = 3, right = 3, top = 3, bottom = 3 }
    })
    panel:SetBackdropColor(0.02, 0.025, 0.03, 0.82)
    panel:SetBackdropBorderColor(unpack(GOLD_MUTED))

    local title = CreateLabel(panel, 15, 400)
    title:SetPoint("TOPLEFT", 12, -10)
    title:SetText("|cff999999[ " .. key .. " ]|r |cff999999套装技能(未激活)|r")

    local body = CreateLabel(panel, 13, 400)
    body:SetPoint("TOPLEFT", 12, -34)
    body:SetHeight(82)
    body:SetText("|cff777777镶嵌相同效果的卡牌后，在此显示套装属性描述。|r")

    panel.Title = title
    panel.Body = body
    return panel
end

local ItemCardGroupFrame2 = CreateSetPanel(SetArea, 2, 0)
local ItemCardGroupFrame4 = CreateSetPanel(SetArea, 4, -140)
local ItemCardGroupFrame6 = CreateSetPanel(SetArea, 6, -280)
local ItemCardGroupFrame8 = CreateSetPanel(SetArea, 8, -420)

local GroupText2 = ItemCardGroupFrame2.Title
local GroupText4 = ItemCardGroupFrame4.Title
local GroupText6 = ItemCardGroupFrame6.Title
local GroupText8 = ItemCardGroupFrame8.Title
local GroupBody2 = ItemCardGroupFrame2.Body
local GroupBody4 = ItemCardGroupFrame4.Body
local GroupBody6 = ItemCardGroupFrame6.Body
local GroupBody8 = ItemCardGroupFrame8.Body

local function ApplySetText(titleFS, bodyFS, piece, active, detail)
    if active then
        titleFS:SetText("|cFFFFFF00[ " .. piece .. " ]|r |cff00FF66套装技能(已激活)|r")
        bodyFS:SetText(detail or "")
        titleFS:GetParent():SetBackdropBorderColor(0.95, 0.78, 0.28, 1)
    else
        titleFS:SetText("|cff999999[ " .. piece .. " ]|r |cff999999套装技能(未激活)|r")
        bodyFS:SetText("|cff777777镶嵌相同效果的卡牌后，在此显示套装属性描述。|r")
        titleFS:GetParent():SetBackdropBorderColor(unpack(GOLD_MUTED))
    end
end

local function RefreshCardVisual(slot)
    local btn = CardsLeftButtons[slot]
    if not btn then
        return
    end

    local hasItem = (btn:GetID() or 0) > 0
    local opened = hasItem or IsOpened(slot)
    local level = GetSlotLevel(slot)

    if opened then
        btn.Art:SetTexture(COLOR_PATH .. tostring(slot))
        btn.Art:SetVertexColor(1, 1, 1, 1)
        btn.Frame:SetTexture(FRAME_PATH .. tostring(level))
        btn.Frame:Show()
        btn.Lock:Hide()
        btn.LevelText:SetText("Lv." .. level)
        btn.LevelText:Show()
    else
        btn.Art:SetTexture(DARK_PATH .. tostring(slot))
        btn.Art:SetVertexColor(0.85, 0.85, 0.85, 1)
        btn.Frame:SetTexture(FRAME_PATH .. "1")
        btn.Frame:Show()
        btn.Lock:Show()
        btn.LevelText:Hide()
    end

    if hasItem then
        btn.IconText:SetText("|T" .. DreamGetItemIcon(btn:GetID()) .. ":48|t")
        CardsTaskButtons[slot]:Show()
    else
        btn.IconText:SetText("")
        CardsTaskButtons[slot]:Hide()
    end

    if SelectedSlot == slot then
        btn.Select:Show()
    else
        btn.Select:Hide()
    end
end

local function RefreshAllCards()
    for i = 1, CARD_COUNT do
        RefreshCardVisual(i)
    end
end

local function RefreshUpgradeLabel()
    local slot = SelectedSlot
    if not slot then
        ItemCardsLevelText:SetText("|cff999999未选择卡牌|r")
        ItemCardsUpgradeBtn:Disable()
        return
    end

    local level = GetSlotLevel(slot)
    local hasItem = (CardsLeftButtons[slot]:GetID() or 0) > 0
    ItemCardsLevelText:SetText(string.format("|cffF0C850槽位 %d|r  Lv.%d / %d", slot, level, MAX_LEVEL))
    if hasItem and level < MAX_LEVEL then
        ItemCardsUpgradeBtn:Enable()
    else
        ItemCardsUpgradeBtn:Disable()
    end
end

local function SelectSlot(slot)
    SelectedSlot = slot
    RefreshAllCards()
    RefreshUpgradeLabel()
end

local function FlipSlot(slot)
    if (CardsLeftButtons[slot]:GetID() or 0) > 0 then
        SetOpened(slot, true)
    else
        SetOpened(slot, not IsOpened(slot))
    end
    RefreshCardVisual(slot)
end

for i = 1, CARD_COUNT do
    local row = math.floor((i - 1) / 4)
    local col = (i - 1) % 4

    local btn = CreateFrame("Button", "CardsLeftButtons" .. i, CardArea)
    btn:SetSize(CARD_W, CARD_H)
    btn:SetPoint("TOPLEFT", col * (CARD_W + CARD_GAP_X), -row * (CARD_H + CARD_GAP_Y))
    btn:EnableMouse(true)
    btn:RegisterForClicks("LeftButtonUp", "RightButtonUp")

    btn.Art = btn:CreateTexture(nil, "BACKGROUND")
    btn.Art:SetAllPoints(btn)

    btn.Frame = btn:CreateTexture(nil, "ARTWORK")
    btn.Frame:SetAllPoints(btn)

    btn.Select = btn:CreateTexture(nil, "OVERLAY")
    btn.Select:SetAllPoints(btn)
    btn.Select:SetTexture("Interface\\Buttons\\UI-ActionButton-Border")
    btn.Select:SetBlendMode("ADD")
    btn.Select:SetVertexColor(1, 0.82, 0.25, 0.85)
    btn.Select:Hide()

    btn.Lock = btn:CreateTexture(nil, "OVERLAY")
    btn.Lock:SetSize(28, 28)
    btn.Lock:SetPoint("CENTER", 0, 8)
    btn.Lock:SetTexture("Interface\\GLUES\\CharacterSelect\\Glues-AddOn-Icons")
    btn.Lock:SetTexCoord(0, 0.25, 0, 1)
    btn.Lock:SetVertexColor(0.75, 0.75, 0.75, 0.9)

    btn.IconText = btn:CreateFontString(nil, "OVERLAY")
    btn.IconText:SetFont(Dream_GameFont, 12)
    btn.IconText:SetPoint("CENTER", 0, -8)

    btn.LevelText = btn:CreateFontString(nil, "OVERLAY")
    btn.LevelText:SetFont(Dream_GameFont, 12, "OUTLINE")
    btn.LevelText:SetPoint("TOPLEFT", 6, -4)
    btn.LevelText:SetTextColor(unpack(GOLD))

    btn:SetID(0)
    btn.TopLink = "item:0"
    btn:SetText("")

    btn:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        if (self:GetID() or 0) > 0 then
            Dream_SetTooltipHyperlink(GameTooltip, self.TopLink)
        else
            GameTooltip:AddLine("卡牌槽 " .. i, 1, 0.82, 0.2)
            if IsOpened(i) then
                GameTooltip:AddLine("已翻开，拖入卡牌物品可镶嵌", 0.8, 0.8, 0.8)
            else
                GameTooltip:AddLine("点击翻开彩色牌面", 0.8, 0.8, 0.8)
                GameTooltip:AddLine("或拖入卡牌物品进行镶嵌", 0.8, 0.8, 0.8)
            end
            GameTooltip:AddLine("当前边框等级 Lv." .. GetSlotLevel(i), 0.95, 0.78, 0.28)
        end
        GameTooltip:Show()
    end)

    btn:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)

    btn:SetScript("OnClick", function(self, mouseButton)
        if mouseButton == "RightButton" then
            if (self:GetID() or 0) > 0 then
                TaskUpdateBtn(i)
            end
            return
        end

        local cursorType = GetCursorInfo()
        if cursorType == "item" then
            UpdateLeftBtnShow(i)
            SelectSlot(i)
            return
        end

        if (self:GetID() or 0) == 0 then
            FlipSlot(i)
        else
            SetOpened(i, true)
            RefreshCardVisual(i)
        end
        SelectSlot(i)
    end)

    local removeBtn = CreateFrame("Button", "CardsTaskButtons" .. i, btn)
    removeBtn:SetSize(22, 22)
    removeBtn:SetPoint("TOPRIGHT", -2, -2)
    removeBtn:SetNormalTexture("Interface\\Buttons\\UI-Panel-MinimizeButton-Up")
    removeBtn:SetPushedTexture("Interface\\Buttons\\UI-Panel-MinimizeButton-Down")
    removeBtn:SetHighlightTexture("Interface\\Buttons\\UI-Panel-MinimizeButton-Highlight")
    removeBtn:SetScript("OnClick", function()
        TaskUpdateBtn(i)
    end)
    removeBtn:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText("移除卡牌", 1, 0.82, 0.2)
        GameTooltip:Show()
    end)
    removeBtn:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)
    removeBtn:Hide()

    CardsLeftButtons[i] = btn
    CardsTaskButtons[i] = removeBtn
end

local ItemCardsUpgradeBtn = CreateFrame("Button", "ItemCardsUpgradeBtn", ItemCardsFrame)
ItemCardsUpgradeBtn:SetSize(180, 48)
ItemCardsUpgradeBtn:SetPoint("TOP", CardArea, "BOTTOM", -40, -24)
ItemCardsUpgradeBtn:EnableMouse(true)
ItemCardsUpgradeBtn:SetNormalTexture(BTN_UPGRADE)
ItemCardsUpgradeBtn:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square")
ItemCardsUpgradeBtn:GetHighlightTexture():SetBlendMode("ADD")

local UpgradeBtnText = ItemCardsUpgradeBtn:CreateFontString(nil, "OVERLAY")
UpgradeBtnText:SetFont(Dream_GameFont, 16)
UpgradeBtnText:SetPoint("CENTER", 0, 0)
UpgradeBtnText:SetText("|cffFFD56A升级卡牌|r")
ItemCardsUpgradeBtn:SetFontString(UpgradeBtnText)

local ItemCardsLevelText = CreateLabel(ItemCardsFrame, 15, 220)
ItemCardsLevelText:SetPoint("LEFT", ItemCardsUpgradeBtn, "RIGHT", 16, 0)
ItemCardsLevelText:SetText("|cff999999未选择卡牌|r")

ItemCardsUpgradeBtn:SetScript("OnClick", function()
    if not SelectedSlot then
        DEFAULT_CHAT_FRAME:AddMessage("|cffFFC125[提示]: 请先点击选择一张卡牌|r")
        return
    end
    local slot = SelectedSlot
    local itemId = CardsLeftButtons[slot]:GetID() or 0
    if itemId == 0 then
        DEFAULT_CHAT_FRAME:AddMessage("|cffFFC125[提示]: 该槽位没有镶嵌卡牌，无法升级|r")
        return
    end
    local level = GetSlotLevel(slot)
    if level >= MAX_LEVEL then
        DEFAULT_CHAT_FRAME:AddMessage("|cffFFC125[提示]: 该卡牌已达最高等级|r")
        return
    end

    -- 客户端先刷新边框；服务端持久化可后续接 UpgradeItemCards
    SetSlotLevel(slot, level + 1)
    SetOpened(slot, true)
    RefreshCardVisual(slot)
    RefreshUpgradeLabel()
    Dream_SendData("UpgradeItemCards", tostring(itemId) .. "#" .. tostring(slot) .. "#" .. tostring(GetSlotLevel(slot)))
    DEFAULT_CHAT_FRAME:AddMessage(string.format("|cff00FF66[卡牌]: 槽位 %d 升至 Lv.%d|r", slot, GetSlotLevel(slot)))
end)

ItemCardsUpgradeBtn:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_TOP")
    GameTooltip:AddLine("升级卡牌边框", 1, 0.82, 0.2)
    GameTooltip:AddLine("1-5 银框角光，6-10 金框角光", 0.8, 0.8, 0.8, true)
    GameTooltip:Show()
end)
ItemCardsUpgradeBtn:SetScript("OnLeave", function()
    GameTooltip:Hide()
end)

local TipLine = CreateLabel(ItemCardsFrame, 13, 480)
TipLine:SetPoint("BOTTOMLEFT", 36, 22)
TipLine:SetText("|cff8A8680左键翻开/选择 · 拖入物品镶嵌 · 右键或角上×移除 · 右侧查看套装属性|r")

-- 静态弹出框
StaticPopupDialogs["CardsOnTask"] = {
    text = "%s",
    button1 = "确定",
    button2 = "取消",
    OnAccept = function(Self)
        Dream_SendData("AcceptItemCards", tostring(Self.ItemId) .. "#" .. tostring(Self.Num))
    end,
    OnCancel = function()
    end,
    OnShow = function()
    end,
    exclusive = true,
    whileDead = true,
    hideOnEscape = true,
    timeout = 0,
    hasEditBox = false,
}

function TaskUpdateBtn(Num)
    local ItemId = CardsLeftButtons[Num]:GetID()
    if (CardsLeftButtons[Num].IconText:GetText() == "" or ItemId == 0) then
        DEFAULT_CHAT_FRAME:AddMessage("|cffFFC125[提示]: 你这个位置没有镶嵌卡牌|r")
        return
    end

    CardsLeftButtons[Num].IconText:SetText("")
    CardsLeftButtons[Num].TopLink = "item:0"
    NowShowTips(CardsLeftButtons[Num], "item:0")
    CardsLeftButtons[Num]:SetID(0)
    SetOpened(Num, false)
    RefreshCardVisual(Num)
    if SelectedSlot == Num then
        RefreshUpgradeLabel()
    end
    Dream_SendData("TaskItemCards", tostring(ItemId) .. "#" .. tostring(Num))
end

function UpdateLeftBtnShow(Num)
    local IType, ItemId, ItemLink = GetCursorInfo()
    if (IType ~= "item") then
        return
    end

    if (CardsLeftButtons[Num]:GetID() ~= 0 and CardsLeftButtons[Num]:GetID() == ItemId) then
        DEFAULT_CHAT_FRAME:AddMessage("|cffFFC125[提示]: 你这个位置已经镶嵌了同样的卡牌|r")
        return
    end

    Dream_SendData("GetCardsNeedInfo", tostring(ItemId) .. "#" .. tostring(Num))
    ClearCursor()
end

local function ParseAuraPacket(Msg)
    local Args = Dream_Split(Msg, "#")
    local active = false
    local detail = ""
    for i = 1, #Args do
        local aura = Args[i]
        if aura and aura ~= "" and aura ~= "nullptr" then
            active = true
            detail = detail .. "|cFFFF6600效果:|r " .. aura .. "\n"
        end
    end
    return active, detail
end

local function Dream_OnCardsAddonEvent(Self, event, Packet, Msg, Type, Sender)
    if (event == "CHAT_MSG_ADDON") then
        if (Packet == "NowCardsNeedInfo") then
            local Args = Dream_Split(Msg, "#")
            local Dialog = StaticPopup_Show("CardsOnTask", "\n|cFF00FF00[卡牌镶嵌 位置 " .. tonumber(Args[3]) .. " ]|r\n" .. Args[2] .. "|cFF00FF00如果已镶嵌会替换 你确定要这么做吗?|r")
            if (Dialog) then
                Dialog.ItemId = tonumber(Args[1])
                Dialog.Num = tonumber(Args[3])
                FuncFrameUpdateAlpha(ItemCardsFrame, false)
                Dialog:SetScript("OnHide", function()
                    FuncFrameUpdateAlpha(ItemCardsFrame, true)
                end)
            end
        elseif (Packet == "NotCardsForItemId") then
            local Num = tonumber(Msg)
            CardsLeftButtons[Num].IconText:SetText("")
            CardsLeftButtons[Num].TopLink = "item:0"
            NowShowTips(CardsLeftButtons[Num], "item:0")
            CardsLeftButtons[Num]:SetID(0)
            SetOpened(Num, false)
            RefreshCardVisual(Num)
        elseif (Packet == "YesCardsForItemId") then
            local Args = Dream_Split(Msg, "#")
            local ItemId = tonumber(Args[1])
            local Num = tonumber(Args[2])
            CardsLeftButtons[Num].IconText:SetText("|T" .. DreamGetItemIcon(ItemId) .. ":48|t")
            CardsLeftButtons[Num].TopLink = "|Hitem:" .. ItemId
            CardsLeftButtons[Num]:SetID(ItemId)
            SetOpened(Num, true)
            SelectSlot(Num)
            RefreshCardVisual(Num)
        elseif (Packet == "AutoMeItemCards") then
            local Args = Dream_Split(Msg, "#")
            for i = 1, CARD_COUNT do
                local ItemId = tonumber(Args[i]) or 0
                if (ItemId > 0) then
                    CardsLeftButtons[i].IconText:SetText("|T" .. DreamGetItemIcon(ItemId) .. ":48|t")
                    CardsLeftButtons[i].TopLink = "|Hitem:" .. ItemId
                    CardsLeftButtons[i]:SetID(ItemId)
                    SetOpened(i, true)
                else
                    CardsLeftButtons[i].IconText:SetText("")
                    CardsLeftButtons[i].TopLink = "item:0"
                    CardsLeftButtons[i]:SetID(0)
                end
                RefreshCardVisual(i)
            end
            RefreshUpgradeLabel()
        elseif (Packet == "AutoMeItemCardsAuras8") then
            local active, detail = ParseAuraPacket(Msg)
            ApplySetText(GroupText8, GroupBody8, 8, active, detail)
        elseif (Packet == "AutoMeItemCardsAuras6") then
            local active, detail = ParseAuraPacket(Msg)
            ApplySetText(GroupText6, GroupBody6, 6, active, detail)
        elseif (Packet == "AutoMeItemCardsAuras4") then
            local active, detail = ParseAuraPacket(Msg)
            ApplySetText(GroupText4, GroupBody4, 4, active, detail)
        elseif (Packet == "AutoMeItemCardsAuras2") then
            local active, detail = ParseAuraPacket(Msg)
            ApplySetText(GroupText2, GroupBody2, 2, active, detail)
        end
    elseif (event == "PLAYER_LOGIN") then
        Dream_SendData("GetMeItemCards")
        RefreshAllCards()
        RefreshUpgradeLabel()
    end
end

local CardsAddonFrame = CreateFrame("Frame", "CardsAddonFrame")
CardsAddonFrame:RegisterEvent("CHAT_MSG_ADDON")
CardsAddonFrame:RegisterEvent("PLAYER_LOGIN")
CardsAddonFrame:SetScript("OnEvent", Dream_OnCardsAddonEvent)

ItemCardsFrame:SetScript("OnShow", function()
    RefreshAllCards()
    RefreshUpgradeLabel()
end)

RefreshAllCards()
RefreshUpgradeLabel()
