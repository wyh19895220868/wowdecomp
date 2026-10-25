---@diagnostic disable: missing-parameter

local Px = -4;
local AtItemZodiacButtons = {};

StaticPopupDialogs["TaskItemZodiacNow"] = {

	text = "%s",
	button1 = "确定",
	button2 = "取消",

	OnAccept = function(Self)
		Dream_SendData("TaskItemZodiacNow", Self.NumStr);
	end,

	OnCancel = function(Self)

	end,

	OnShow = function (Self)

    end,

	exclusive = true,
	whileDead = true,
	hideOnEscape = true,
	timeout = 0,
};

StaticPopupDialogs["AddItemZodiacNow"] = {

	text = "%s",
	button1 = "确定",
	button2 = "取消",

	OnAccept = function(Self)
		Dream_SendData("AddItemZodiacNow", Self.GuidLowStr.."#"..Self.NumStr);
	end,

	OnCancel = function(Self)

	end,

	OnShow = function (Self)

    end,

	exclusive = true,
	whileDead = true,
	hideOnEscape = true,
	timeout = 0,
};

local ItemZodiacFrame = CreateFrame("Frame", "ItemZodiacFrame", UIParent);
ItemZodiacFrame:SetSize(640, 480);
ItemZodiacFrame:SetPoint("CENTER");
ItemZodiacFrame:SetToplevel(true);
ItemZodiacFrame:SetClampedToScreen(true);
ItemZodiacFrame:SetBackdrop( { bgFile = "Interface\\Icons\\Z1" });

local InItemZodiacFrame = CreateFrame("Frame", "InItemZodiacFrame", ItemZodiacFrame);
InItemZodiacFrame:SetSize(300, 300);
InItemZodiacFrame:SetPoint("CENTER", Px / 2, -30);
InItemZodiacFrame:SetBackdrop( { bgFile = "Interface\\Icons\\Z2" });

tinsert(UISpecialFrames, "ItemZodiacFrame");
ItemZodiacFrame:Hide();

-- 关闭按钮
local ItemZodiacFrameButtonClose = CreateFrame("Button", "ItemZodiacFrameButtonClose", ItemZodiacFrame, "UIPanelCloseButton");
ItemZodiacFrameButtonClose:SetPoint("TOPRIGHT", -90, -35);
ItemZodiacFrameButtonClose:EnableMouse(true);
ItemZodiacFrameButtonClose:SetSize(30, 30);

local TopGtsText = ItemZodiacFrame:CreateFontString("TopGtsText");
TopGtsText:SetFont(Dream_GameFont, 15);
TopGtsText:SetPoint("TOP", 0, -80);
TopGtsText:SetText("|cFF00FF00将生肖物品插入即可获得光环 左键拖入插入 右键取出|r");

local CenterItemZodiacButton = CreateFrame("Button", "CenterItemZodiacButton", ItemZodiacFrame, "DreamZcRingSmButtonTemplate")
CenterItemZodiacButton:SetPoint("CENTER", Px, -28)
CenterItemZodiacButton:SetSize(80, 80);
CenterItemZodiacButton:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-Ping-Expand");

CenterItemZodiacButton.ButtonTexture = CenterItemZodiacButton:CreateTexture("CenterItemZodiacButtonTexture");
CenterItemZodiacButton.ButtonTexture:SetSize(60, 60);
CenterItemZodiacButton.ButtonTexture:SetPoint("CENTER");
CenterItemZodiacButton.ButtonTexture:SetTexture("Interface\\Icons\\Z4");

CenterItemZodiacButton.SpellId = 0;
CenterItemZodiacButton.SpellLink = "spell:0";

CenterItemZodiacButton:SetScript("OnEnter",
function(self)
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	Dream_SetTooltipHyperlink(GameTooltip, self.SpellLink);
	GameTooltip:Show();
end)
CenterItemZodiacButton:SetScript("OnLeave",
function(self)
	GameTooltip:Hide();
end)

for i=1,12 do
	AtItemZodiacButtons[i]= CreateFrame("Button", "AtItemZodiacButtons"..i, ItemZodiacFrame, "DreamZcRingSmButtonTemplate")
	AtItemZodiacButtons[i]:SetSize(60, 60);
	AtItemZodiacButtons[i]:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-Ping-Expand");

	AtItemZodiacButtons[i].ButtonTexture = AtItemZodiacButtons[i]:CreateTexture("AtItemZodiacButtonTexture"..i);
	AtItemZodiacButtons[i].ButtonTexture:SetSize(40, 40);
    AtItemZodiacButtons[i].ButtonTexture:SetPoint("CENTER");
    AtItemZodiacButtons[i].ButtonTexture:SetTexture("");
	if (i == 1) then
		AtItemZodiacButtons[i]:SetPoint("CENTER", Px, 90);
	elseif (i == 2) then
		AtItemZodiacButtons[i]:SetPoint("CENTER", 56.5, 75);
	elseif (i == 3) then
		AtItemZodiacButtons[i]:SetPoint("CENTER", 102, 30);
	elseif (i == 4) then
		AtItemZodiacButtons[i]:SetPoint("CENTER", 118, -30);
	elseif (i == 5) then
		AtItemZodiacButtons[i]:SetPoint("CENTER", 100, -90);
	elseif (i == 6) then
		AtItemZodiacButtons[i]:SetPoint("CENTER", 56.5, -134);
	elseif (i == 7) then
		AtItemZodiacButtons[i]:SetPoint("CENTER", Px, -150);
	elseif (i == 8) then
		AtItemZodiacButtons[i]:SetPoint("CENTER", -64, -134);
	elseif (i == 9) then
		AtItemZodiacButtons[i]:SetPoint("CENTER", -106, -90);
	elseif (i == 10) then
		AtItemZodiacButtons[i]:SetPoint("CENTER", -124, -30);
	elseif (i == 11) then
		AtItemZodiacButtons[i]:SetPoint("CENTER", -107, 30);
	elseif (i == 12) then
		AtItemZodiacButtons[i]:SetPoint("CENTER", -65, 75);
	end

	AtItemZodiacButtons[i].SpellId = 0;
	AtItemZodiacButtons[i].SpellLink = "spell:0";

	AtItemZodiacButtons[i]:RegisterForClicks("AnyDown");

	AtItemZodiacButtons[i]:SetScript("OnClick",
	function(self, BtnType)
		if (BtnType == "LeftButton") then
			local IType, _, ItemLink = GetCursorInfo();
			if (IType ~= "item") then
				return;
			end
			local _, _, _, _, _, _, _, _, ItemGuidLow, _ = Dream_DoSplit(":", string.match(ItemLink, "item[%-?%d:]+"));
			local GuidLow = tonumber(ItemGuidLow) - MaxGuidIndex
			Dream_SendData("InItemZodiacQuery", tostring(GuidLow).."#"..i);
			ClearCursor();
		elseif (BtnType == "RightButton") then
			if (self.SpellId ~= 0) then
				Dream_SendData("OutItemZodiacQuery", tostring(i));
			end
		end
    end)

	AtItemZodiacButtons[i]:SetScript("OnEnter",
	function(self)
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
		Dream_SetTooltipHyperlink(GameTooltip, self.SpellLink);
		GameTooltip:Show();
	end)
	AtItemZodiacButtons[i]:SetScript("OnLeave",
	function(self)
		GameTooltip:Hide();
	end)
end

ItemZodiacFrame:SetScript("OnShow",
function(self)

end)

ItemZodiacFrame:SetScript("OnHide",
function(self)

end)

--消息处理
local function Dream_OnItemZodiacAddonEvent(Self, event, Packet, Msg, Type, Sender)
    if (event == "CHAT_MSG_ADDON") then
		if (Packet == "AutoZodiacItemData") then
			local Args = Dream_Split(Msg, "#");
			for i=1,#Args do
				local SpellId = tonumber(Args[i]);
				if (i < 13) then
					AtItemZodiacButtons[i].ButtonTexture:SetTexture(DreamGetSpellIcon(SpellId));
					AtItemZodiacButtons[i].SpellId = SpellId;
					AtItemZodiacButtons[i].SpellLink = "|Hspell:"..SpellId;
				else
					if (SpellId > 0) then
						CenterItemZodiacButton.ButtonTexture:SetTexture(DreamGetSpellIcon(SpellId));
					else
						CenterItemZodiacButton.ButtonTexture:SetTexture("Interface\\Icons\\Z4");
					end

                    CenterItemZodiacButton.SpellId = SpellId;
					CenterItemZodiacButton.SpellLink = "|Hspell:"..SpellId;
				end
			end
		elseif (Packet == "NotItemZodiac") then
			local Num = tonumber(Msg);
			if (AtItemZodiacButtons[Num].SpellId == 0) then
				AtItemZodiacButtons[Num].ButtonTexture:SetTexture("");
				AtItemZodiacButtons[Num].SpellLink = "spell:0";
			end
		elseif (Packet == "NeedInfoItemZodiac") then
			local Args = Dream_Split(Msg, "#");
			local GuidLow = Args[1];
			local Num = Args[2];
			local Gts = Args[3];
			local Dialog = StaticPopup_Show("AddItemZodiacNow", Gts);
			Dialog.GuidLowStr= GuidLow;
			Dialog.NumStr = Num;
		elseif (Packet == "UpdateZodiacItemData") then
			local Args = Dream_Split(Msg, "#");
			local Num = tonumber(Args[1]);
			local SpellId = tonumber(Args[2]);
			AtItemZodiacButtons[Num].ButtonTexture:SetTexture(DreamGetSpellIcon(SpellId));
			AtItemZodiacButtons[Num].SpellId = SpellId;
			AtItemZodiacButtons[Num].SpellLink = "|Hspell:"..SpellId;
			NowShowTips(AtItemZodiacButtons[Num], "|Hspell:"..Args[2]);
		elseif (Packet == "UpdateCenterZodiacItemData") then
			local SpellId = tonumber(Msg);
			if (SpellId > 0) then
				CenterItemZodiacButton.ButtonTexture:SetTexture(DreamGetSpellIcon(SpellId));
			else
				CenterItemZodiacButton.ButtonTexture:SetTexture("Interface\\Icons\\Z4");
			end
			CenterItemZodiacButton.SpellId = SpellId;
			CenterItemZodiacButton.SpellLink = "|Hspell:"..SpellId;
		elseif (Packet == "OutNeedInfoItemZodiac") then
			local Args = Dream_Split(Msg, "#");
			local Num = Args[1];
			local Gts = Args[2];
			local Dialog = StaticPopup_Show("TaskItemZodiacNow", Gts);
			Dialog.NumStr = Num;
		end
	elseif (event == "PLAYER_LOGIN") then
		Dream_SendData("GetMeZodiacItemData");
	end
end

--交互消息事件
local IItemZodiacAddonFrame = CreateFrame("Frame", "IItemZodiacAddonFrame");
IItemZodiacAddonFrame:RegisterEvent("CHAT_MSG_ADDON");
IItemZodiacAddonFrame:RegisterEvent("PLAYER_LOGIN");
IItemZodiacAddonFrame:SetScript("OnEvent", Dream_OnItemZodiacAddonEvent);




--------------------------------------------------------------------



