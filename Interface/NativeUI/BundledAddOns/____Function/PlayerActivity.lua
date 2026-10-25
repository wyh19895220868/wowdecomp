---@diagnostic disable: missing-parameter

local MaxActivityCount = 240;     --最大显示
local MaxActivityPop = 24;     --最大段
local ActivityShowSubFrames = {}
local ActivityShowSubFrameStrs = {};
local ActivityShowPopBtns = {};
local ActivityOnTextures = {};

local PlayerActivityData = {}

local AsPlayerActivity = 0;    --服务端活跃值
local NowPlayerActivity = 0;   --玩家当前活跃值

local ActivityShowFrame = CreateFrame("Frame", "ActivityShowFrame", UIParent);
ActivityShowFrame:SetSize(800, 600);
ActivityShowFrame:RegisterForDrag("LeftButton");
ActivityShowFrame:SetPoint("CENTER");
ActivityShowFrame:SetClampedToScreen(true);
ActivityShowFrame:SetBackdrop(
{
    bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    edgeSize = 12,
    insets = { left = 3, right = 3, top = 3, bottom = 3 }
});

tinsert(UISpecialFrames, "ActivityShowFrame");
ActivityShowFrame:Hide();

-- 关闭按钮
local ActivityShowFrameButtonClose = CreateFrame("Button", "ActivityShowFrameButtonClose", ActivityShowFrame, "UIPanelCloseButton");
ActivityShowFrameButtonClose:SetPoint("TOPRIGHT", 5, 5);
ActivityShowFrameButtonClose:EnableMouse(true);
ActivityShowFrameButtonClose:SetSize(36, 36);

--标题模块
local ActivityShowFrameTitleBar = CreateFrame("Frame", "ActivityShowFrameTitleBar", ActivityShowFrame);
ActivityShowFrameTitleBar:SetSize(200, 30);
ActivityShowFrameTitleBar:SetPoint("TOP", 0, 24);
ActivityShowFrameTitleBar:SetBackdrop(
{
    bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true,
    edgeSize = 16,
    tileSize = 16,
    insets = { left = 4, right = 4, top = 4, bottom = 4 }
})

--标题模块文字描述
local ActivityShowFrameTitleBarText = ActivityShowFrameTitleBar:CreateFontString("ActivityShowFrameTitleBarText");
ActivityShowFrameTitleBarText:SetFont(Dream_GameFont, 15);
ActivityShowFrameTitleBarText:SetPoint("CENTER");
ActivityShowFrameTitleBarText:SetText("|cffFFC125活跃度奖励|r");

--进度条
local ActivityButtonBar = CreateFrame("Button", "ActivityButtonBar", ActivityShowFrame);
ActivityButtonBar:SetSize(ActivityShowFrame:GetWidth() - 4, 20);
ActivityButtonBar:SetPoint("TOP", 0, -30);
ActivityButtonBar:SetBackdrop(
{
     bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
     edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
     edgeSize = 12,
     insets = { left = 3, right = 3, top = 3, bottom = 3 }
});

local ActivityStatusBarOne = CreateFrame("StatusBar", "ActivityStatusBarOne", ActivityButtonBar);
ActivityStatusBarOne:SetOrientation("HORIZONTAL");
ActivityStatusBarOne:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar");
--ActivityStatusBarOne:SetStatusBarTexture("Interface\\Icons\\StatusBar");
ActivityStatusBarOne:SetStatusBarColor(255/255, 102/255, 0/255);
ActivityStatusBarOne:SetPoint("CENTER");
ActivityStatusBarOne:SetSize(ActivityButtonBar:GetWidth() - 8, ActivityButtonBar:GetHeight() - 8);
ActivityStatusBarOne:SetMinMaxValues(1, 100);

local ActivityButtonBarText = ActivityStatusBarOne:CreateFontString("ActivityButtonBarText")
ActivityButtonBarText:SetFont(Dream_GameFont, 14);
ActivityButtonBarText:SetAllPoints(ActivityStatusBarOne);

--主要提示
local ActivityStrGtsText = ActivityShowFrame:CreateFontString("ActivityStrGtsText");
ActivityStrGtsText:SetFont(Dream_GameFont, 14);
ActivityStrGtsText:SetPoint("TOPLEFT", 12, -110);
ActivityStrGtsText:SetText("");

for i=1, MaxActivityPop do
    ActivityShowPopBtns[i] = CreateFrame("Button", "ActivityShowPopBtns"..i, ActivityShowFrame);
    ActivityShowPopBtns[i]:SetSize(48, 48);
    ActivityShowPopBtns[i]:SetPoint("TOPLEFT", 0, -48);
    ActivityShowPopBtns[i]:EnableMouse(true);
    ActivityShowPopBtns[i]:SetHighlightTexture("Interface\\Icons\\NodeH1");
    ActivityShowPopBtns[i]:SetBackdrop( { bgFile = "Interface\\Icons\\NodeNormal" });

    ActivityOnTextures[i] = ActivityShowPopBtns[i]:CreateTexture("ActivityOnTextures"..i);
	ActivityOnTextures[i]:SetSize(30, 30);
    ActivityOnTextures[i]:SetPoint("BOTTOM", 0, -20);
	ActivityOnTextures[i]:SetTexture("");

    ActivityShowPopBtns[i].PopValue = 0;
    ActivityShowPopBtns[i].NowPopValue = 0;
    ActivityShowPopBtns[i].RGts = "";
    ActivityShowPopBtns[i].InCom = false;
    ActivityShowPopBtns[i].OnRew = false;
    ActivityShowPopBtns[i]:Hide();

    ActivityShowPopBtns[i]:SetScript("OnEnter",
    function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT", 0, -50);
        local On = self.OnRew and "|cFFFFFF00[已领取]|r" or "|cFFFFFF00[未领取]|r";
        local Com = self.InCom and "|cFF00FF00当前已达成 点击图标|r "..On or "|cFF999999当前未达成|r";
        GameTooltip:SetText("|cFF00FF00达到活跃度: "..self.PopValue.." 获得以下奖励|r\n"..Com.."\n"..self.RGts);
        GameTooltip:Show();
    end)

    ActivityShowPopBtns[i]:SetScript("OnLeave",
    function(self)
        GameTooltip:Hide();
    end)

    ActivityShowPopBtns[i]:SetScript("OnClick",
    function(self)
        Dream_SendData("NowRewPlayerActivity", tostring(self.PopValue));
    end)
end

--滚动窗口
local ActivityShowScrollFrame = CreateFrame("ScrollFrame","ActivityShowScrollFrame",ActivityShowFrame);
ActivityShowScrollFrame:SetSize(ActivityShowFrame:GetWidth() - 20, ActivityShowFrame:GetHeight() - 150);
ActivityShowScrollFrame:SetPoint("TOP", 0, -130);
ActivityShowScrollFrame:EnableMouse(true);
ActivityShowScrollFrame:EnableMouseWheel(true);
ActivityShowScrollFrame:Show();

--滚动子窗口
local ActivityShowScrollChildFrame = CreateFrame("Frame","ActivityShowScrollChildFrame",ActivityShowScrollFrame);
ActivityShowScrollChildFrame:SetSize(ActivityShowFrame:GetWidth() - 20, ActivityShowFrame:GetHeight() - 150);
ActivityShowScrollChildFrame:SetPoint("TOP", 0, -130);
ActivityShowScrollFrame:SetScrollChild(ActivityShowScrollChildFrame);
ActivityShowScrollChildFrame:Show();
ActivityShowScrollChildFrame:SetBackdrop(
{
     bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
});

--滚动条
local ActivityShowScrollBar = CreateFrame("Slider", "ActivityShowScrollBar", ActivityShowScrollFrame, "OptionsSliderTemplate");
ActivityShowScrollBar:SetSize(20, ActivityShowScrollFrame:GetHeight() - 2);
ActivityShowScrollBar:SetPoint("RIGHT", ActivityShowScrollFrame, -5, 0);
ActivityShowScrollBar:EnableMouseWheel(true);
ActivityShowScrollBar:SetOrientation("VERTICAL");
_G[ActivityShowScrollBar:GetName().."High"]:Hide();
_G[ActivityShowScrollBar:GetName().."Low"]:Hide();
ActivityShowScrollBar:SetMinMaxValues(0, 100);
ActivityShowScrollBar:SetValue(0);
ActivityShowScrollBar:SetValueStep(1.0);

ActivityShowScrollBar:SetScript("OnValueChanged",
function(self, offset)
    ActivityShowScrollFrame:SetVerticalScroll(math.ceil((ActivityShowScrollChildFrame:GetHeight() - ActivityShowScrollFrame:GetHeight()) / 100 * self:GetValue()));
end)

ActivityShowScrollFrame:SetScript("OnMouseWheel",
function(self, Val)
	local MinVal,MaxVal = ActivityShowScrollBar:GetMinMaxValues();
	local InVal = ActivityShowScrollBar:GetValue();
	local De = InVal - (Val * 4);
	De = max(De, MinVal);
	De = min(De, MaxVal);
	if (De ~= InVal) then
		ActivityShowScrollBar:SetValue(De);
	end
end)

for i=1, MaxActivityCount do
    ActivityShowSubFrames[i] = CreateFrame("Frame","ActivityShowSubFrames", ActivityShowScrollChildFrame);
    ActivityShowSubFrames[i]:SetSize(ActivityShowFrame:GetWidth() - 60, 40);
    ActivityShowSubFrames[i]:SetPoint("TOP", ActivityShowScrollChildFrame, -10, -(i - 1) * 40 - 5);

    ActivityShowSubFrameStrs[i] = ActivityShowSubFrames[i]:CreateFontString("ActivityShowSubFrameStrs"..i);
    ActivityShowSubFrameStrs[i]:SetFont(Dream_GameFont, 15);
    ActivityShowSubFrameStrs[i]:SetPoint("LEFT", ActivityShowSubFrames[i], 20, 0);
    ActivityShowSubFrameStrs[i]:SetText("");

    ActivityShowSubFrames[i]:SetID(0);
    ActivityShowSubFrames[i]:Hide();
end
ActivityShowScrollChildFrame:SetHeight(40 * MaxActivityCount);

ActivityShowFrame:SetScript("OnShow",
function(self)
    ActivityShowScrollBar:SetValue(0);
    Dream_SendData("GetActivityStoreData");
end)

local function GetPlayerActivityData(Num, Index)
    if (Num == 0) then
        return 0;
    end
    if (PlayerActivityData[Num] == nil) then
        return 0;
    end
    if (PlayerActivityData[Num][Index] == nil) then
        return 0;
    end
    return PlayerActivityData[Num][Index];
end

local function AutoPopBtnPoint(Num)
    if (ActivityShowPopBtns[Num] == nil) then
        return 0;
    end
    local PopValue = ActivityShowPopBtns[Num].PopValue;
    if (PopValue == 0) then
        return 0;
    end
    ActivityShowPopBtns[Num]:Show();
    if (PopValue <= NowPlayerActivity) then
        ActivityShowPopBtns[Num]:SetBackdrop( { bgFile = "Interface\\Icons\\NodeShow" });
        ActivityShowPopBtns[Num].InCom = true;
    end

    local Width = ActivityShowFrame:GetWidth();
    local Sp = Width / 100;
    local Sce = (AsPlayerActivity > 0) and (PopValue * 100 / AsPlayerActivity) or 0;
    local LeftPoint = Sp * Sce;
    ActivityShowPopBtns[Num]:SetPoint("TOPLEFT", LeftPoint - 24, -48);
end

--消息处理
local function AddonActivityShowFrameEvent(Self, event, Packet, Msg, Type, Sender)
    if (event == "CHAT_MSG_ADDON") then
		if (Packet == "DaySendActivityStoreData") then
            local TheArgs = Dream_Split(Msg, "$");
            local Num = tonumber(TheArgs[1]);
            local AType = tonumber(TheArgs[2]);
            ActivityShowSubFrames[Num]:Show();
            ActivityShowSubFrames[Num]:SetID(Num);

            local InfoStr = "";
            if (AType == 1) then
                InfoStr = "|cFF00FFFF需要击杀怪物|r |cFF00FF00["..TheArgs[5].."] ("..GetPlayerActivityData(Num, 4).."/"..TheArgs[4]..")|r";
            elseif (AType == 2) then
                InfoStr = "|cFF00FFFF需要收集物品|r |T"..DreamGetItemIcon(tonumber(TheArgs[3]))..":20|t "..DreamGetItemLink(tonumber(TheArgs[3])).." |cFF00FF00("..GetPlayerActivityData(Num, 4).."/"..TheArgs[4]..")|r";
            elseif (AType == 3) then
                InfoStr = "|cFF00FFFF需要完成任务|r "..TheArgs[5].." |cFF00FF00("..GetPlayerActivityData(Num, 4).."/1)|r";
            elseif (AType == 4) then
                InfoStr = "|cFF00FFFF需要击杀玩家|r |cFF00FF00("..GetPlayerActivityData(Num, 4).."/"..TheArgs[4]..")|r";
            elseif (AType == 5) then
                InfoStr = "|cFF00FFFF需要赢得战场|r |cFF00FF00("..GetPlayerActivityData(Num, 4).."/"..TheArgs[4]..")|r";
            end
            
            ActivityShowSubFrameStrs[Num]:SetText("|cFF00FFFF"..Num.."#|r "..InfoStr.." |cFF00FFFF获得活跃值:|r |cFFFF6600"..TheArgs[6].."|r".."        |cFFFFFF00提示: "..TheArgs[7].."|r");
        elseif (Packet == "DaySendRewActivityStore") then
            local TheArgs = Dream_Split(Msg, "$");
            local Num = tonumber(TheArgs[1]);
            ActivityShowPopBtns[Num].PopValue = tonumber(TheArgs[2]);
            ActivityShowPopBtns[Num].RGts = TheArgs[3];
            AutoPopBtnPoint(Num);
        elseif (Packet == "DaySendActivityDataSize") then
            local Count = tonumber(Msg);
            if not Count then
                ActivityShowScrollChildFrame:Hide();
            else
                ActivityShowScrollChildFrame:SetHeight(40 * Count);
            end
        elseif (Packet == "AutoPlayerActivityData1") then
            if (Msg == "Nullptr") then
                PlayerActivityData = {};
            else
                local TheArgs = Dream_Split(Msg, "$");
                local Num = tonumber(TheArgs[1]);
                PlayerActivityData[Num] = { Num, tonumber(TheArgs[2]), tonumber(TheArgs[3]) , tonumber(TheArgs[4]) };
            end
        elseif (Packet == "AutoPlayerActivityData2") then
            if (Msg == "Nullptr") then
                for i=1, MaxActivityPop do
                    ActivityShowPopBtns[i]:Hide();
                end
            else
                local TheArgs = Dream_Split(Msg, "$");
                local Num = tonumber(TheArgs[1]);
                local NowPopValue = tonumber(TheArgs[2]);
                local OnRew = tonumber(TheArgs[3]);
                ActivityShowPopBtns[Num].NowPopValue = NowPopValue;
                ActivityShowPopBtns[Num].OnRew = OnRew;
                if (OnRew > 0) then
                    ActivityOnTextures[Num]:SetTexture("Interface\\Icons\\OnRew")
                else
                    ActivityOnTextures[Num]:SetTexture("")
                end
            end
        elseif (Packet == "AutoAsNowPlayerActivity") then
            local Store = Dream_Split(Msg, "#");
            NowPlayerActivity = tonumber(Store[1]);
            AsPlayerActivity = tonumber(Store[2]);
            local Sce = (AsPlayerActivity > 0) and (NowPlayerActivity * 100 / AsPlayerActivity) or 0;
            ActivityStatusBarOne:SetValue(math.floor(Sce));
            ActivityButtonBarText:SetText("|cFF00FF00当前活跃值 "..NowPlayerActivity.."/"..AsPlayerActivity.." @ "..string.format("%.f", Sce).."%|r")
            ActivityStrGtsText:SetText("|cFFFFFF00达成下列条件可以获得活跃值 当活跃值到达一定阶段可以点击上方图示领取阶段奖励 活跃系统每天会按时重置|r")
        elseif (Packet == "CloseActivity") then
            ActivityShowFrame:Hide();
        end
	elseif (event == "PLAYER_LOGIN") then
        Dream_SendData("GetPlayerActivityData");
	end
end

--交互消息事件
local AddonActivityShowFrame = CreateFrame("Frame", "AddonActivityShowFrame");
AddonActivityShowFrame:RegisterEvent("CHAT_MSG_ADDON");
AddonActivityShowFrame:RegisterEvent("PLAYER_LOGIN");
AddonActivityShowFrame:SetScript("OnEvent", AddonActivityShowFrameEvent);

--------------------------------------------------------------------


