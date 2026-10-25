---@diagnostic disable: missing-parameter

-- ============================================================
-- 活动公告：全背景图卡片（参考 GecUI WorldBossUI 的 3x3 排版）
-- 数据来源：服务端 _活动_公告 + _事件 + 需求/奖励模版
-- ============================================================

local MAX_CARDS = 9;
local CARD_WIDTH = 270;
local CARD_HEIGHT = 160;
local PADDING_X = 6;
local PADDING_Y = 10;
local START_X = 28;
local START_Y = -100;
local DEFAULT_BG = "Interface\\DialogFrame\\UI-DialogBox-Background";

local EventShowData = {};
local EventShowTotal = 0;
local EventShowCards = {};
local EventShowDirty = false;
local EventShowLastRequest = -math.huge;
local function EventShowRequestData()
    local Now = GetTime();
    if Now - EventShowLastRequest < 1 then return; end
    EventShowLastRequest = Now;
    Dream_SendData("GetEventDataNow");
end

local function EventShowSplitKeepEmpty(Str)
    local List = {};
    local Start = 1;
    while true do
        local Pos = string.find(Str, "^", Start, true);
        if not Pos then
            table.insert(List, string.sub(Str, Start));
            break;
        end
        table.insert(List, string.sub(Str, Start, Pos - 1));
        Start = Pos + 1;
    end
    return List;
end

local function EventShowFormatRemain(Sec)
    Sec = math.max(0, math.floor(tonumber(Sec) or 0));
    local Days = math.floor(Sec / 86400);
    local Hours = math.floor((Sec % 86400) / 3600);
    local Minutes = math.floor((Sec % 3600) / 60);
    local Seconds = Sec % 60;
    if (Days > 0) then
        return string.format("%d天 %02d:%02d:%02d", Days, Hours, Minutes, Seconds);
    elseif (Hours > 0) then
        return string.format("%02d:%02d:%02d", Hours, Minutes, Seconds);
    end
    return string.format("%02d:%02d", Minutes, Seconds);
end

local EventShowFrame = CreateFrame("Frame", "EventShowFrame", UIParent);
EventShowFrame:SetSize(880, 640);
EventShowFrame:SetPoint("CENTER");
EventShowFrame:SetClampedToScreen(true);
EventShowFrame:SetMovable(true);
EventShowFrame:EnableMouse(true);
EventShowFrame:RegisterForDrag("LeftButton");
EventShowFrame:SetScript("OnDragStart", EventShowFrame.StartMoving);
EventShowFrame:SetScript("OnDragStop", EventShowFrame.StopMovingOrSizing);
EventShowFrame:SetBackdrop(
{
    bgFile = "Interface\\Icons\\bgfile",
    tile = false,
    insets = { left = 0, right = 0, top = 0, bottom = 0 }
});

tinsert(UISpecialFrames, "EventShowFrame");
EventShowFrame:Hide();

-- 背景图由 SetBackdrop 铺满；这一层只做压暗，保证文字可读
local EventShowFrameBg = EventShowFrame:CreateTexture("EventShowFrameBg", "BACKGROUND");
EventShowFrameBg:SetAllPoints(EventShowFrame);
EventShowFrameBg:SetTexture("Interface\\Buttons\\WHITE8X8");
EventShowFrameBg:SetVertexColor(0, 0, 0, 0.12);
EventShowFrameBg:Hide();

local EventShowFrameButtonClose = CreateFrame("Button", "EventShowFrameButtonClose", EventShowFrame, "UIPanelCloseButton");
EventShowFrameButtonClose:SetPoint("TOPRIGHT", 12, -4);
EventShowFrameButtonClose:EnableMouse(true);
EventShowFrameButtonClose:SetSize(36, 36);

local EventShowFrameTitleBar = CreateFrame("Frame", "EventShowFrameTitleBar", EventShowFrame);
EventShowFrameTitleBar:SetSize(280, 30);
EventShowFrameTitleBar:SetPoint("TOP", -12, -25);

local EventShowFrameTitleBarText = EventShowFrameTitleBar:CreateFontString("EventShowFrameTitleBarText");
EventShowFrameTitleBarText:SetFont(Dream_GameFont, 16);
EventShowFrameTitleBarText:SetPoint("CENTER");
EventShowFrameTitleBarText:SetShadowColor(0, 0, 0, 1);
EventShowFrameTitleBarText:SetShadowOffset(1, -1);
EventShowFrameTitleBarText:SetText("|cffFFD100活动公告|r");

local EventShowFrameSubTitle = EventShowFrame:CreateFontString("EventShowFrameSubTitle");
EventShowFrameSubTitle:SetFont(Dream_GameFont, 12);
EventShowFrameSubTitle:SetPoint("TOP", 0, -62);
EventShowFrameSubTitle:SetText("|cffB2B2B2进行中的活动会排在前面，点击卡片查看或前往|r");

local EventShowFrameCountText = EventShowFrame:CreateFontString("EventShowFrameCountText");
EventShowFrameCountText:SetFont(Dream_GameFont, 12);
EventShowFrameCountText:SetPoint("TOPRIGHT", -24, -16);
EventShowFrameCountText:SetText("|cffB2B2B2共 0 个活动|r");

local EventShowFrameRefreshButton = CreateFrame("Button", "EventShowFrameRefreshButton", EventShowFrame, "UIPanelButtonTemplate");
EventShowFrameRefreshButton:SetSize(60, 22);
EventShowFrameRefreshButton:SetPoint("TOPRIGHT", -44, -64);
EventShowFrameRefreshButton:SetText("刷新");
EventShowFrameRefreshButton:GetFontString():SetFont(Dream_GameFont, 12);
EventShowFrameRefreshButton:SetScript("OnClick",
function()
    EventShowRequestData();
end);

local EventShowScrollFrame = CreateFrame("ScrollFrame", "EventShowScrollFrame", EventShowFrame, "FauxScrollFrameTemplate");
EventShowScrollFrame:SetSize(870, 530);
EventShowScrollFrame:SetPoint("TOPLEFT", 8, -95);
EventShowScrollFrame:EnableMouse(true);
EventShowScrollFrame:EnableMouseWheel(true);
EventShowScrollFrame:SetScript("OnVerticalScroll",
function(self, offset)
    FauxScrollFrame_OnVerticalScroll(self, offset, CARD_HEIGHT + PADDING_Y, function()
        EventShow_UpdateCards();
    end);
end);
EventShowScrollFrame:SetScript("OnMouseWheel",
function(self, Delta)
    local ScrollBar = _G[self:GetName() .. "ScrollBar"];
    if (ScrollBar) then
        local MinValue, MaxValue = ScrollBar:GetMinMaxValues();
        local Value = ScrollBar:GetValue() - (Delta * (CARD_HEIGHT + PADDING_Y));
        if (Value < MinValue) then Value = MinValue; end
        if (Value > MaxValue) then Value = MaxValue; end
        ScrollBar:SetValue(Value);
    end
end);

local EventShowEmptyText = EventShowFrame:CreateFontString("EventShowEmptyText");
EventShowEmptyText:SetFont(Dream_GameFont, 14);
EventShowEmptyText:SetPoint("CENTER", 0, -60);
EventShowEmptyText:SetWidth(620);
EventShowEmptyText:SetJustifyH("CENTER");
EventShowEmptyText:SetText("|cffB2B2B2暂无活动公告|r\n|cff888888请在数据库表 _活动_公告 中添加活动|r");
EventShowEmptyText:Hide();

local function EventShowClickCard(Card)
    if not Card or not Card.canClick or not Card.noticeId then
        return;
    end
    Dream_SendData("ActivityNoticeClick", tostring(Card.noticeId));
end

local function EventShowUpdateStatus(Card)
    local Remain = math.max(0, math.floor((Card.startTime or 0) + (Card.remain or 0) - GetTime()));
    if (Card.eventId and Card.eventId > 0) then
        if (Card.isActive) then
            if (Remain > 0) then
                Card.statusText:SetText("|cffff3333冷却倒计时: |r|cffff6666" .. EventShowFormatRemain(Remain) .. "|r");
            else
                Card.statusText:SetText("|cff00ff00进行中|r");
            end
        else
            if (Remain > 0) then
                Card.statusText:SetText("|cffffff00开放倒计时: |r|cffffcc00" .. EventShowFormatRemain(Remain) .. "|r");
            else
                Card.statusText:SetText("|cffffff00即将开始|r");
            end
        end
    else
        Card.statusText:SetText("|cff00ff00可随时使用|r");
    end
end

local function EventShowCreateCard(Index)
    local Card = CreateFrame("Button", "EventShowCard" .. Index, EventShowFrame);
    Card:SetSize(CARD_WIDTH, CARD_HEIGHT);
    -- Keep cards above the decorative window background.
    Card:SetFrameStrata("DIALOG");
    Card:SetFrameLevel(EventShowFrame:GetFrameLevel() + 10);
    Card:SetBackdrop(
    {
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 12,
        insets = { left = 4, right = 4, top = 4, bottom = 4 }
    });
    Card:SetBackdropColor(0, 0, 0, 0.85);
    Card:SetBackdropBorderColor(0.65, 0.55, 0.20, 1);
    Card:EnableMouse(true);
    Card:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square");
    Card:GetHighlightTexture():SetVertexColor(1, 0.82, 0, 0.15);

    -- 整卡背景图
    Card.bg = Card:CreateTexture(nil, "BACKGROUND");
    Card.bg:SetAllPoints(Card);
    Card.bg:SetTexture(DEFAULT_BG);
    Card.bg:SetTexCoord(0, 1, 0, 1);

    Card.bgOverlay = Card:CreateTexture(nil, "ARTWORK", nil, -8);
    Card.bgOverlay:SetAllPoints(Card);
    Card.bgOverlay:SetTexture("Interface\\Buttons\\WHITE8X8");
    Card.bgOverlay:SetVertexColor(0, 0, 0, 0.28);

    -- 顶部状态条
    Card.topBar = Card:CreateTexture(nil, "ARTWORK", nil, -7);
    Card.topBar:SetPoint("TOPLEFT", 3, -3);
    Card.topBar:SetPoint("TOPRIGHT", -3, -3);
    Card.topBar:SetHeight(22);
    Card.topBar:SetTexture("Interface\\Buttons\\WHITE8X8");
    Card.topBar:SetVertexColor(0, 0, 0, 0.45);

    -- 底部信息条
    Card.bottomBar = Card:CreateTexture(nil, "ARTWORK", nil, -6);
    Card.bottomBar:SetPoint("BOTTOMLEFT", 3, 3);
    Card.bottomBar:SetPoint("BOTTOMRIGHT", -3, 3);
    Card.bottomBar:SetHeight(32);
    Card.bottomBar:SetTexture("Interface\\Buttons\\WHITE8X8");
    Card.bottomBar:SetVertexColor(0, 0, 0, 0.68);

    Card.statusText = Card:CreateFontString(nil, "OVERLAY");
    Card.statusText:SetFont(Dream_GameFont, 11);
    Card.statusText:SetPoint("TOP", 0, -7);
    Card.statusText:SetWidth(258);
    Card.statusText:SetJustifyH("CENTER");
    Card.statusText:SetText("");

    -- 大标题（类似截图中间的艺术字）
    Card.bigTitle = Card:CreateFontString(nil, "OVERLAY");
    Card.bigTitle:SetFont(Dream_GameFont, 24);
    Card.bigTitle:SetPoint("CENTER", 0, 4);
    Card.bigTitle:SetWidth(258);
    Card.bigTitle:SetHeight(66);
    Card.bigTitle:SetJustifyH("CENTER");
    Card.bigTitle:SetJustifyV("CENTER");
    Card.bigTitle:SetShadowColor(0, 0, 0, 1);
    Card.bigTitle:SetShadowOffset(2, -2);
    Card.bigTitle:SetText("");

    -- 底部名称 + 类型
    Card.bottomText = Card:CreateFontString(nil, "OVERLAY");
    Card.bottomText:SetFont(Dream_GameFont, 11);
    Card.bottomText:SetPoint("BOTTOMLEFT", 8, 10);
    Card.bottomText:SetWidth(190);
    Card.bottomText:SetJustifyH("LEFT");
    Card.bottomText:SetText("");

    Card.button = CreateFrame("Button", "EventShowCardButton" .. Index, Card, "UIPanelButtonTemplate");
    Card.button:SetSize(56, 22);
    Card.button:SetPoint("BOTTOMRIGHT", -8, 7);
    Card.button:SetText("传送");
    Card.button:GetFontString():SetFont(Dream_GameFont, 12);
    Card.button:SetScript("OnClick", function()
        EventShowClickCard(Card);
    end);

    Card:SetScript("OnClick", function()
        EventShowClickCard(Card);
    end);

    Card:SetScript("OnEnter",
    function(self)
        if not self.noticeId then
            return;
        end
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
        GameTooltip:SetText(self.name or "活动", 1, 0.82, 0);
        if (self.typeName and self.typeName ~= "") then
            GameTooltip:AddLine("[" .. self.typeName .. "]", 1, 0.35, 0.35);
        end
        if (self.description and self.description ~= "") then
            GameTooltip:AddLine(self.description, 1, 1, 1, true);
        end
        if (self.needText and self.needText ~= "") then
            GameTooltip:AddLine("|cff00ff00需求：|r" .. self.needText, 1, 1, 1, true);
        end
        if (self.rewardText and self.rewardText ~= "") then
            GameTooltip:AddLine("|cffffff00奖励：|r" .. self.rewardText, 1, 1, 1, true);
        end
        if (self.canClick) then
            GameTooltip:AddLine("|cff00ff00点击卡片执行|r", 0, 1, 0);
        else
            GameTooltip:AddLine("|cff888888当前不可点击|r", 0.7, 0.7, 0.7);
        end
        GameTooltip:Show();
    end);
    Card:SetScript("OnLeave",
    function()
        GameTooltip:Hide();
    end);

    Card:SetScript("OnUpdate",
    function(self, elapsed)
        self.updateTimer = (self.updateTimer or 0) + elapsed;
        if (self.updateTimer >= 0.5) then
            self.updateTimer = 0;
            EventShowUpdateStatus(self);
        end
    end);

    Card:Hide();
    return Card;
end

for i = 1, MAX_CARDS do
    EventShowCards[i] = EventShowCreateCard(i);
end

local function EventShowLayoutCards()
    for i = 1, MAX_CARDS do
        local Row = math.floor((i - 1) / 3);
        local Col = (i - 1) % 3;
        local X = START_X + (Col * (CARD_WIDTH + PADDING_X));
        local Y = START_Y - (Row * (CARD_HEIGHT + PADDING_Y));
        EventShowCards[i]:ClearAllPoints();
        EventShowCards[i]:SetPoint("TOPLEFT", EventShowFrame, "TOPLEFT", X, Y);
    end
end
EventShowLayoutCards();

function EventShow_UpdateCards()
    FauxScrollFrame_Update(EventShowScrollFrame, math.ceil(EventShowTotal / 3), 3, CARD_HEIGHT + PADDING_Y);
    local Offset = FauxScrollFrame_GetOffset(EventShowScrollFrame) or 0;

    for i = 1, MAX_CARDS do
        local Card = EventShowCards[i];
        local DataIndex = (Offset * 3) + i;
        local Data = EventShowData[DataIndex];

        if (Data) then
            Card:Show();
            Card.noticeId = Data.noticeId;
            Card.eventId = Data.eventId;
            Card.isActive = Data.active;
            Card.remain = Data.remain;
            Card.startTime = GetTime();
            Card.name = Data.name;
            Card.description = Data.description;
            Card.typeName = Data.typeName;
            Card.needText = Data.needText;
            Card.rewardText = Data.rewardText;
            Card.canClick = Data.canClick;

            local Background = Data.bg ~= "" and Data.bg or DEFAULT_BG;
            if Card.nativeBackground ~= Background then
                Card.nativeBackground = Background;
                Card.bg:SetTexture(Background);
            end
            Card.bg:Show();
            Card.bgOverlay:Show();
            Card.topBar:Show();
            Card.bottomBar:Show();

            local TitleSize = (string.len(Data.name) > 20) and 20 or 24;
            if Card.nativeTitleSize ~= TitleSize then
                Card.nativeTitleSize = TitleSize;
                Card.bigTitle:SetFont(Dream_GameFont, TitleSize);
            end
            if (Data.active) then
                Card.bigTitle:SetText("|cff35e0c8" .. Data.name .. "|r");
            else
                Card.bigTitle:SetText("|cffB2B2B2" .. Data.name .. "|r");
            end

            local TypeStr = "";
            if (Data.typeName ~= "") then
                TypeStr = "  |cffff3333[" .. Data.typeName .. "]|r";
            end
            Card.bottomText:SetText("|cffffd100" .. Data.name .. "|r" .. TypeStr);

            Card.button:SetText(Data.button ~= "" and Data.button or "传送");
            if (Data.canClick) then
                Card.button:Enable();
                Card.button:SetAlpha(1);
            else
                Card.button:Disable();
                Card.button:SetAlpha(0.45);
            end

            Card:SetBackdropBorderColor(Data.active and 0.20 or 0.65, Data.active and 0.85 or 0.55, Data.active and 0.35 or 0.20, 1);
            EventShowUpdateStatus(Card);
        else
            Card:Hide();
            Card.noticeId = nil;
        end
    end

    if (EventShowTotal <= 0) then
        EventShowEmptyText:Show();
        EventShowScrollFrame:Hide();
    else
        EventShowEmptyText:Hide();
        EventShowScrollFrame:Show();
    end
end

EventShowFrame:SetScript("OnShow",
function()
    EventShowRequestData();
end);

-- Network replies arrive as a burst. Repaint visible cards once per frame,
-- and leave hidden windows dirty until they are shown.
EventShowFrame:SetScript("OnUpdate", function()
    if EventShowDirty then
        EventShowDirty = false;
        EventShow_UpdateCards();
    end
end);

local function AddonEventShowFrameEvent(Self, event, Packet, Msg, Type, Sender)
    if (event ~= "CHAT_MSG_ADDON") then
        return;
    end

    if (Packet == "AutoEventSizeNow") then
        EventShowTotal = tonumber(Msg) or 0;
        wipe(EventShowData);
        EventShowFrameCountText:SetText("|cffB2B2B2共 " .. EventShowTotal .. " 个活动|r");
        EventShowDirty = true;
    elseif (Packet == "AutoEventDataNow") then
        local Args = EventShowSplitKeepEmpty(Msg);
        local Index = tonumber(Args[1]);
        if (not Index or Index <= 0) then
            return;
        end
        if (Index > EventShowTotal) then
            EventShowTotal = Index;
            EventShowFrameCountText:SetText("|cffB2B2B2共 " .. EventShowTotal .. " 个活动|r");
        end
        EventShowData[Index] =
        {
            noticeId = tonumber(Args[2]) or 0,
            eventId = tonumber(Args[3]) or 0,
            name = Args[4] or "",
            description = Args[5] or "",
            bg = Args[6] or "",
            button = Args[7] or "传送",
            needText = Args[8] or "",
            rewardText = Args[9] or "",
            active = (Args[10] == "1"),
            remain = tonumber(Args[11]) or 0,
            typeName = Args[12] or "",
            canClick = (Args[13] == "1"),
        };
        EventShowDirty = true;
    end
end

local AddonEventShowFrame = CreateFrame("Frame", "AddonEventShowFrame");
AddonEventShowFrame:RegisterEvent("CHAT_MSG_ADDON");
AddonEventShowFrame:SetScript("OnEvent", AddonEventShowFrameEvent);

--------------------------------------------------------------------
