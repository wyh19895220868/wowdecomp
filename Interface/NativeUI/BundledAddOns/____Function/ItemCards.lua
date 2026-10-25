---@diagnostic disable: missing-parameter

local CardsLeftButtons = {};
local CardsLeftBtnStrs = {};

local CardsTaskButtons = {};
local CardsTaskBtnStrs = {};

local ItemCardsFrame = CreateFrame("Frame", "ItemCardsFrame", UIParent);
ItemCardsFrame:SetSize(820, 720);
ItemCardsFrame:RegisterForDrag("LeftButton");
ItemCardsFrame:SetPoint("CENTER", 0, 50);
ItemCardsFrame:SetClampedToScreen(true);
ItemCardsFrame:SetBackdrop(
{
    bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    edgeSize = 12,
    insets = { left = 3, right = 3, top = 3, bottom = 3 }
});

tinsert(UISpecialFrames, "ItemCardsFrame");
ItemCardsFrame:Hide();

-- 关闭按钮
local ItemCardsBtnClose = CreateFrame("Button", "ItemCardsBtnClose", ItemCardsFrame, "UIPanelCloseButton");
ItemCardsBtnClose:SetPoint("TOPRIGHT", 5, 5);
ItemCardsBtnClose:EnableMouse(true);
ItemCardsBtnClose:SetSize(36, 36);

--提示
local ItemCardsFrameText = ItemCardsFrame:CreateFontString("ItemCardsFrameText");
ItemCardsFrameText:SetFont(Dream_GameFont, 18);
ItemCardsFrameText:SetPoint("TOP", 0, -20);
ItemCardsFrameText:SetText("|cFF00FF00同样的卡牌技能效果可组合成套装技能效果\n同样的效果越多组合的套装效果越多 分别为 2 4 6 8 套装效果|r");

local ItemCardsLeftFrame = CreateFrame("Frame", "ItemCardsLeftFrame", ItemCardsFrame);
ItemCardsLeftFrame:SetSize(180, 640);
ItemCardsLeftFrame:RegisterForDrag("LeftButton");
ItemCardsLeftFrame:SetPoint("LEFT", 0, -40);

local ItemCardGroupFrame2 = CreateFrame("Frame", "ItemCardGroupFrame2", ItemCardsFrame);
ItemCardGroupFrame2:SetSize(300, 300);
ItemCardGroupFrame2:RegisterForDrag("LeftButton");
ItemCardGroupFrame2:SetPoint("TOPLEFT", 190, -80);
ItemCardGroupFrame2:SetBackdrop(
{
    bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    edgeSize = 12,
    insets = { left = 3, right = 3, top = 3, bottom = 3 }
});

local ItemCardGroupFrame4 = CreateFrame("Frame", "ItemCardGroupFrame4", ItemCardsFrame);
ItemCardGroupFrame4:SetSize(300, 300);
ItemCardGroupFrame4:RegisterForDrag("LeftButton");
ItemCardGroupFrame4:SetPoint("TOPLEFT", 500, -80);
ItemCardGroupFrame4:SetBackdrop(
{
    bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    edgeSize = 12,
    insets = { left = 3, right = 3, top = 3, bottom = 3 }
});

local ItemCardGroupFrame6 = CreateFrame("Frame", "ItemCardGroupFrame6", ItemCardsFrame);
ItemCardGroupFrame6:SetSize(300, 300);
ItemCardGroupFrame6:RegisterForDrag("LeftButton");
ItemCardGroupFrame6:SetPoint("TOPLEFT", 190, -400);
ItemCardGroupFrame6:SetBackdrop(
{
    bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    edgeSize = 12,
    insets = { left = 3, right = 3, top = 3, bottom = 3 }
});

local ItemCardGroupFrame8 = CreateFrame("Frame", "ItemCardGroupFrame8", ItemCardsFrame);
ItemCardGroupFrame8:SetSize(300, 300);
ItemCardGroupFrame8:RegisterForDrag("LeftButton");
ItemCardGroupFrame8:SetPoint("TOPLEFT", 500, -400);
ItemCardGroupFrame8:SetBackdrop(
{
    bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    edgeSize = 12,
    insets = { left = 3, right = 3, top = 3, bottom = 3 }
});

local GroupText2 = ItemCardGroupFrame2:CreateFontString("GroupText2");
GroupText2:SetFont(Dream_GameFont, 15);
GroupText2:SetPoint("TOP", 0, -10);
GroupText2:SetWidth(ItemCardGroupFrame2:GetWidth() - 12);
GroupText2:SetText("|cFF999999[ 2 ]|r |cFF999999套装技能(未激活)|r");

local GroupText4 = ItemCardGroupFrame4:CreateFontString("GroupText4");
GroupText4:SetFont(Dream_GameFont, 15);
GroupText4:SetPoint("TOP", 0, -10);
GroupText4:SetWidth(ItemCardGroupFrame4:GetWidth() - 12);
GroupText4:SetText("|cFF999999[ 4 ]|r |cFF999999套装技能(未激活)|r");

local GroupText6 = ItemCardGroupFrame6:CreateFontString("GroupText6");
GroupText6:SetFont(Dream_GameFont, 15);
GroupText6:SetPoint("TOP", 0, -10);
GroupText6:SetWidth(ItemCardGroupFrame6:GetWidth() - 12);
GroupText6:SetText("|cFF999999[ 6 ]|r |cFF999999套装技能(未激活)|r");

local GroupText8 = ItemCardGroupFrame8:CreateFontString("GroupText8");
GroupText8:SetFont(Dream_GameFont, 15);
GroupText8:SetPoint("TOP", 0, -10);
GroupText8:SetWidth(ItemCardGroupFrame8:GetWidth() - 12);
GroupText8:SetText("|cFF999999[ 8 ]|r |cFF999999套装技能(未激活)|r");

for i=1,8 do
	CardsLeftButtons[i] = CreateFrame("Button", "CardsLeftButtons"..i, ItemCardsLeftFrame);
	CardsLeftButtons[i]:SetSize(80, 80);
    CardsLeftButtons[i]:SetPoint("TOPLEFT", 0, -(i - 1) * 75);
    CardsLeftButtons[i]:SetBackdrop( { bgFile = "Interface\\BUTTONS\\UI-EmptySlot" });
	CardsLeftButtons[i]:SetHighlightTexture("Interface\\BUTTONS\\OldButtonHilight-Square");

	CardsLeftBtnStrs[i] = CardsLeftButtons[i]:CreateFontString("CardsLeftBtnStrs"..i);
	CardsLeftBtnStrs[i]:SetFont(Dream_GameFont, 12);
	CardsLeftBtnStrs[i]:SetAllPoints(CardsLeftButtons[i]);
	CardsLeftButtons[i]:SetFontString(CardsLeftBtnStrs[i]);

	CardsLeftButtons[i]:SetID(0);
	CardsLeftButtons[i].TopLink = "item:0";
	CardsLeftButtons[i]:SetText("");

	CardsLeftButtons[i]:SetScript("OnEnter",
    function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
        Dream_SetTooltipHyperlink(GameTooltip, self.TopLink);
        GameTooltip:Show();
    end)

    CardsLeftButtons[i]:SetScript("OnLeave",
    function(self)
        GameTooltip:Hide();
    end)

	CardsLeftButtons[i]:SetScript("OnClick",
    function(self)
        UpdateLeftBtnShow(i);
    end)

	CardsTaskButtons[i] = CreateFrame("Button", "CardsTaskButtons"..i, CardsLeftButtons[i]);
	CardsTaskButtons[i]:SetSize(108, 30);
    CardsTaskButtons[i]:SetPoint("RIGHT", 90, 0);
	CardsTaskButtons[i]:EnableMouse(true);
	CardsTaskButtons[i]:SetBackdrop({ bgFile = NormalBtnIcon })
	CardsTaskButtons[i]:SetHighlightTexture("Interface\\Buttons\\UI-Panel-MinimizeButton-Highlight")

	CardsTaskBtnStrs[i] = CardsTaskButtons[i]:CreateFontString("CardsTaskBtnStrs"..i);
	CardsTaskBtnStrs[i]:SetFont(Dream_GameFont, 15);
	CardsTaskButtons[i]:SetFontString(CardsTaskBtnStrs[i]);
	CardsTaskButtons[i]:SetText("|cffFFC125移除卡牌|r");

	CardsTaskButtons[i]:SetScript("OnClick",
    function(self)
        TaskUpdateBtn(i);
    end)
end

--静态弹出框
StaticPopupDialogs["CardsOnTask"] = {

	text = "%s",
	button1 = "确定",
	button2 = "取消",

	OnAccept = function(Self)
		Dream_SendData("AcceptItemCards", tostring(Self.ItemId).."#"..tostring(Self.Num));
	end,

	OnCancel = function(Self)

	end,

	OnShow = function(Self)

	end,

	exclusive = true,
	whileDead = true,
	hideOnEscape = true,
	timeout = 0,
	hasEditBox = false,
};

function TaskUpdateBtn(Num)
	local ItemId = CardsLeftButtons[Num]:GetID();
    if (CardsLeftButtons[Num]:GetText() == "" or ItemId == 0) then
		DEFAULT_CHAT_FRAME:AddMessage("|cffFFC125[提示]: 你这个位置没有镶嵌卡牌|r");
		return;
    end

	CardsLeftButtons[Num]:SetText("");
	CardsLeftButtons[Num].TopLink = "item:0";
	NowShowTips(CardsLeftButtons[Num], "item:0");
	CardsLeftButtons[Num]:SetID(0);
	Dream_SendData("TaskItemCards", tostring(ItemId).."#"..tostring(Num));
end

function UpdateLeftBtnShow(Num)
    local IType, ItemId, ItemLink = GetCursorInfo()
    if (IType ~= "item") then
		return
    end

	if (CardsLeftButtons[Num]:GetID() ~= 0 and CardsLeftButtons[Num]:GetID() == ItemId) then
		DEFAULT_CHAT_FRAME:AddMessage("|cffFFC125[提示]: 你这个位置已经镶嵌了同样的卡牌|r");
		return
	end
	
	Dream_SendData("GetCardsNeedInfo", tostring(ItemId).."#"..tostring(Num));
	ClearCursor();
end

--消息处理
local function Dream_OnCardsAddonEvent(Self, event, Packet, Msg, Type, Sender)
    if (event == "CHAT_MSG_ADDON") then
		--卡牌
		if (Packet == "NowCardsNeedInfo") then
			local Args = Dream_Split(Msg, "#");
			local Dialog = StaticPopup_Show("CardsOnTask", "\n|cFF00FF00[卡牌镶嵌 位置 "..tonumber(Args[3]).." ]|r\n"..Args[2].."|cFF00FF00如果已镶嵌会替换 你确定要这么做吗?|r");
			if (Dialog) then
				Dialog.ItemId = tonumber(Args[1]);
				Dialog.Num = tonumber(Args[3]);
				FuncFrameUpdateAlpha(ItemCardsFrame, false);
				Dialog:SetScript("OnHide",
				function(self)
					FuncFrameUpdateAlpha(ItemCardsFrame, true);
				end)
			end
		elseif (Packet == "NotCardsForItemId") then
			local Num = tonumber(Msg);
			CardsLeftButtons[Num]:SetText("");
			CardsLeftButtons[Num].TopLink = "item:0";
			NowShowTips(CardsLeftButtons[Num], "item:0");
			CardsLeftButtons[Num]:SetID(0);
		elseif (Packet == "YesCardsForItemId") then
			local Args = Dream_Split(Msg, "#");
			local ItemId = tonumber(Args[1]);
			local Num = tonumber(Args[2]);
			CardsLeftButtons[Num]:SetText("|T"..DreamGetItemIcon(ItemId)..":64|t");
			CardsLeftButtons[Num].TopLink = "|Hitem:"..ItemId;
			CardsLeftButtons[Num]:SetID(ItemId);
		elseif (Packet == "AutoMeItemCards") then
			local Args = Dream_Split(Msg, "#");
			for i=1,#Args do
				local ItemId = tonumber(Args[i]);
				if (ItemId > 0) then
					CardsLeftButtons[i]:SetText("|T"..DreamGetItemIcon(ItemId)..":64|t");
					CardsLeftButtons[i].TopLink = "|Hitem:"..ItemId;
					CardsLeftButtons[i]:SetID(ItemId);
				end
			end
		elseif (Packet == "AutoMeItemCardsAuras8") then
			local Args = Dream_Split(Msg, "#");
			local In = false;
			local OnText = "";
			for i=1,#Args do
				local Aura8 = Args[i];
			    if (Aura8 ~= "nullptr") then
					In = true;
					OnText = OnText.."|cFFFF6600效果:|r "..Aura8.."\n";
			    end
			end
			local HText = (In) and "|cFFFFFF00[ 8 ]|r |cFF00FF00套装技能(已激活)|r\n\n"..OnText or "|cFF999999[ 8 ]|r |cFF999999套装技能(未激活)|r";
			GroupText8:SetText(HText);
		elseif (Packet == "AutoMeItemCardsAuras6") then
			local Args = Dream_Split(Msg, "#");
			local In = false;
			local OnText = "";
			for i=1,#Args do
				local Aura6 = Args[i];
			    if (Aura6 ~= "nullptr") then
					In = true;
					OnText = OnText.."|cFFFF6600效果:|r "..Aura6.."\n";
			    end
			end
			local HText = (In) and "|cFFFFFF00[ 6 ]|r |cFF00FF00套装技能(已激活)|r\n\n"..OnText or "|cFF999999[ 6 ]|r |cFF999999套装技能(未激活)|r";
			GroupText6:SetText(HText);
		elseif (Packet == "AutoMeItemCardsAuras4") then
			local Args = Dream_Split(Msg, "#");
			local In = false;
			local OnText = "";
			for i=1,#Args do
				local Aura4 = Args[i];
			    if (Aura4 ~= "nullptr") then
					In = true;
					OnText = OnText.."|cFFFF6600效果:|r "..Aura4.."\n";
			    end
			end
			local HText = (In) and "|cFFFFFF00[ 4 ]|r |cFF00FF00套装技能(已激活)|r\n\n"..OnText or "|cFF999999[ 4 ]|r |cFF999999套装技能(未激活)|r";
			GroupText4:SetText(HText);
		elseif (Packet == "AutoMeItemCardsAuras2") then
			local Args = Dream_Split(Msg, "#");
			local In = false;
			local OnText = "";
			for i=1,#Args do
				local Aura2 = Args[i];
			    if (Aura2 ~= "nullptr") then
					In = true;
					OnText = OnText.."|cFFFF6600效果:|r "..Aura2.."\n";
			    end
			end
			local HText = (In) and "|cFFFFFF00[ 2 ]|r |cFF00FF00套装技能(已激活)|r\n\n"..OnText or "|cFF999999[ 2 ]|r |cFF999999套装技能(未激活)|r";
			GroupText2:SetText(HText);
		end
	elseif (event == "PLAYER_LOGIN") then
		Dream_SendData("GetMeItemCards");
	end
end

--交互消息事件
local CardsAddonFrame = CreateFrame("Frame", "CardsAddonFrame");
CardsAddonFrame:RegisterEvent("CHAT_MSG_ADDON");
CardsAddonFrame:RegisterEvent("PLAYER_LOGIN");
CardsAddonFrame:SetScript("OnEvent", Dream_OnCardsAddonEvent);

--------------------------------------------------------------------



