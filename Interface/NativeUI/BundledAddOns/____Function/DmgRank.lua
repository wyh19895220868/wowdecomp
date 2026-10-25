---@diagnostic disable: missing-parameter

local MaxPm = 10;
local RankLineStr = {};
local ShowUI = true;

local function Dream_FormatDmgRankNumber(Value)
	if Dream_FormatChineseNumber then
		return Dream_FormatChineseNumber(Value);
	end
	return tostring(Value or 0);
end

local function Dream_NormalizeDmgRankDigits(Value)
	local Digits = tostring(Value or ""):gsub(",", "")
	if (not string.match(Digits, "^%d+$")) then
		return nil;
	end
	Digits = string.gsub(Digits, "^0+", "");
	return Digits == "" and "0" or Digits;
end

local function Dream_GetDmgRankMaxHealth(Fallback)
	local GuidLow = Dream_GetCreGuidLow and Dream_GetCreGuidLow() or 0;
	local Data = _G.DreamCustomTargetHealthData and _G.DreamCustomTargetHealthData[GuidLow];
	if (Data and (tonumber(Data.MaxMultipleHp) or 1) > 1) then
		local MaxHealth = Dream_NormalizeDmgRankDigits(Data.MaxHealthText);
		if (MaxHealth and MaxHealth ~= "0") then
			return MaxHealth;
		end
	end
	return Dream_NormalizeDmgRankDigits(Fallback) or "1";
end

local function Dream_FormatDmgRankPercentage(Damage, MaxHealth)
	local DamageDigits = Dream_NormalizeDmgRankDigits(Damage) or "0";
	local MaxDigits = Dream_NormalizeDmgRankDigits(MaxHealth) or "1";
	if (MaxDigits == "0") then MaxDigits = "1"; end
	if (string.len(DamageDigits) <= 15 and string.len(MaxDigits) <= 15) then
		return string.format("%.2f", (tonumber(DamageDigits) or 0) / (tonumber(MaxDigits) or 1) * 100);
	end
	local Keep = 15;
	local DamageLead = tonumber(string.sub(DamageDigits, 1, Keep)) or 0;
	local MaxLead = tonumber(string.sub(MaxDigits, 1, Keep)) or 1;
	local Scale = string.len(DamageDigits) - string.len(MaxDigits);
	local Ratio = (DamageLead / MaxLead) * (10 ^ Scale);
	return string.format("%.2f", Ratio * 100);
end

local function ApplyDataDmgRankFrame(Msg)
	local At = Dream_Split(Msg, "^");

	DmgRankCreNameText:SetText("|cFF00FF00Boss名称|r [ |cffFFC125"..At[1].."|r ]");
	DmgRankCountText:SetText("|cFF00FF00参与人数|r |cFFFF3300"..At[2].."|r");
	RankText:SetText("|cFF00FF00你的排名是|r |cFFFF3300 <"..Dream_GetNumCustom(At[3])..">|r |cFF00FF00你输出伤害|r |cFF00FFFF"..Dream_FormatDmgRankNumber(At[4]).."|r");

	local Args = Dream_Split(At[5], "$");
	for N = 1, #Args do
		local Arg = Dream_Split(Args[N], "#");
		local MaxHp = Dream_GetDmgRankMaxHealth(Arg[1]);
		local InfoName = Arg[2];
		local RItemLink = (Arg[4] == "Not" and "" or Arg[4]);
		local Percentage = Dream_FormatDmgRankPercentage(Arg[3], MaxHp);
		local DamageText = Dream_FormatDmgRankNumber(Arg[3]);

	    if (N <= MaxPm) then
			local RankIndex = "|cFFFF3300 <"..Dream_GetNumCustom(N)..">|r";
			local PlayerInfo = "|cFF00FF00"..InfoName.."|r";
			local DmgInfo = "|cFF00FFFF输出伤害|r |cFFFFFF00"..DamageText.." ("..Percentage.."%)|r";
			RankLineStr[N]:SetText(RankIndex.."  "..PlayerInfo.."  "..DmgInfo.."  |cFF00FFFF奖励:|r "..RItemLink);
		end
	end
end

local DmgRankFrame = CreateFrame("Frame", "DmgRankFrame", UIParent);
DmgRankFrame:SetSize(480, 450);
DmgRankFrame:RegisterForDrag("LeftButton");
DmgRankFrame:SetPoint("RIGHT");
DmgRankFrame:SetClampedToScreen(true);
DmgRankFrame:SetBackdrop(
{
    bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    edgeSize = 12,
    insets = { left = 3, right = 3, top = 3, bottom = 3 }
});

tinsert(UISpecialFrames, "DmgRankFrame");
DmgRankFrame:Hide();

for i=1,MaxPm do
	RankLineStr[i] = DmgRankFrame:CreateFontString("RankLineStr"..i);
	RankLineStr[i]:SetFont(Dream_GameFont, 15);
	RankLineStr[i]:SetPoint("TOP", 0, -((i - 1) * 30 + 120));
end

-- 关闭按钮
local DmgRankFramebuttonClose = CreateFrame("Button", "DmgRankFramebuttonClose", DmgRankFrame, "UIPanelCloseButton");
DmgRankFramebuttonClose:SetPoint("TOPRIGHT", 5, 5);
DmgRankFramebuttonClose:EnableMouse(true);
DmgRankFramebuttonClose:SetSize(36, 36);

--标题模块
local DmgRankFrameTitleBar = CreateFrame("Frame", "DmgRankFrameTitleBar", DmgRankFrame);
DmgRankFrameTitleBar:SetSize(240, 40);
DmgRankFrameTitleBar:SetPoint("TOP", 0, 36);
DmgRankFrameTitleBar:SetBackdrop(
{
    bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true,
    edgeSize = 16,
    tileSize = 16,
    insets = { left = 4, right = 4, top = 4, bottom = 4 }
})

--标题模块文字描述
local DmgRankFrameTitleBarText = DmgRankFrameTitleBar:CreateFontString("DmgRankFrameTitleBarText");
DmgRankFrameTitleBarText:SetFont(Dream_GameFont, 18);
DmgRankFrameTitleBarText:SetPoint("CENTER");
DmgRankFrameTitleBarText:SetText("|cffFFC125战斗伤害排行榜|r");

local ShowInfoButton = CreateFrame("Button", "ShowInfoButton", DmgRankFrame);
ShowInfoButton:SetSize(220, 30);
ShowInfoButton:SetPoint("TOP", DmgRankFrameTitleBar, 0, 28);
ShowInfoButton:EnableMouse(true);
ShowInfoButton:SetBackdrop({ bgFile = NormalBtnIcon })
ShowInfoButton:SetHighlightTexture("Interface\\Buttons\\UI-Panel-MinimizeButton-Highlight")

local ShowInfoButtonStrs = ShowInfoButton:CreateFontString("ShowInfoButtonStrs");
ShowInfoButtonStrs:SetFont(Dream_GameFont, 18);
ShowInfoButton:SetFontString(ShowInfoButtonStrs);
ShowInfoButton:SetText("|cffFFC125显示 | 隐藏|r");

ShowInfoButton:SetScript("OnClick",
function(self)
	Dream_SendData("NowShowDmgUI");
end)

--名称提示
local DmgRankCreNameText = DmgRankFrame:CreateFontString("DmgRankCreNameText");
DmgRankCreNameText:SetFont(Dream_GameFont, 18);
DmgRankCreNameText:SetPoint("TOP", 0, -20);
DmgRankCreNameText:SetText("");

--参与人数
local DmgRankCountText = DmgRankFrame:CreateFontString("DmgRankCountText");
DmgRankCountText:SetFont(Dream_GameFont, 18);
DmgRankCountText:SetPoint("TOP", 0, -50);
DmgRankCountText:SetText("");

--个人排名提示
local RankText = DmgRankFrame:CreateFontString("RankText");
RankText:SetFont(Dream_GameFont, 15);
RankText:SetPoint("TOP", 0, -80);
RankText:SetText("");

--消息处理
local function Dream_OnDmgRankAddonEvent(Self, event, Packet, Msg, Type, Sender)
    if (event == "CHAT_MSG_ADDON") then
		--伤害排行榜
		if (Packet == "DataTheRanking") then
			DmgRankFrame:Show();
			ApplyDataDmgRankFrame(Msg);
		elseif (Packet == "ClearTheRanking") then
			DmgRankFrame:Hide();
			DmgRankCreNameText:SetText("");
			DmgRankCountText:SetText("");
			RankText:SetText("");
			for i=1,MaxPm do
				RankLineStr[i]:SetText("");
			end
			ShowInfoButton.ShowInfo = true;
		elseif (Packet == "NowShowDmgUI") then
			ShowUI = (Msg == "1");
			if (not ShowUI) then
				--DmgRankFrame:Hide();
				DmgRankCreNameText:SetText("");
				DmgRankCountText:SetText("");
				RankText:SetText("");
				for i=1,MaxPm do
					RankLineStr[i]:SetText("");
				end
			end
		end
	end
end

--交互消息事件
local DmgRankAddonFrame = CreateFrame("Frame", "DmgRankAddonFrame");
DmgRankAddonFrame:RegisterEvent("CHAT_MSG_ADDON");
DmgRankAddonFrame:SetScript("OnEvent", Dream_OnDmgRankAddonEvent);
