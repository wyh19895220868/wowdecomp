---@diagnostic disable: missing-parameter

local ItemMagicFrameButtons = { [1] = {}, [2] = {}, [3] = {}, [4] = {}, [5] = {}, [6] = {}, [7] = {} };

local ItemMagicFrame = CreateFrame("Frame", "ItemMagicFrame", UIParent);
ItemMagicFrame:SetSize(1024, 768);
ItemMagicFrame:SetPoint("LEFT", 0, 60);
ItemMagicFrame:SetToplevel(true);
ItemMagicFrame:SetClampedToScreen(true);
ItemMagicFrame:SetBackdrop(
{
    bgFile = "Interface\\Icons\\Magic",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    edgeSize = 8,
    insets = { left = 2, right = 2, top = 2, bottom = 2 }
});

tinsert(UISpecialFrames, "ItemMagicFrame");
ItemMagicFrame:Hide();

-- 关闭按钮
local ItemMagicFrameButtonClose = CreateFrame("Button", "ItemMagicFrameButtonClose", ItemMagicFrame, "UIPanelCloseButton");
ItemMagicFrameButtonClose:SetPoint("TOPRIGHT", 5, 5);
ItemMagicFrameButtonClose:EnableMouse(true);
ItemMagicFrameButtonClose:SetSize(30, 30);

local RightTopGtsText = ItemMagicFrame:CreateFontString("RightTopGtsText");
RightTopGtsText:SetFont(Dream_GameFont, 15);
RightTopGtsText:SetPoint("TOPRIGHT", -10, -60);
RightTopGtsText:SetText("|cFF00FF00将法宝插入即可获得法宝光环或技能 左键拖入插入 右键取出|r");

local LeftTopGtsText = ItemMagicFrame:CreateFontString("LeftTopGtsText");
LeftTopGtsText:SetFont(Dream_GameFont, 15);
LeftTopGtsText:SetPoint("TOPLEFT", 10, -60);
LeftTopGtsText:SetText("|cFF00FF00对应的法宝类型才能插入该位置|r");

local GroupText1 = ItemMagicFrame:CreateFontString("GroupText1");
GroupText1:SetFont(Dream_GameFont, 30, "OUTLINE");
GroupText1:SetPoint("CENTER", 10, 166);
GroupText1:SetText("|cFFFFFFFF金|r");

local GroupText2 = ItemMagicFrame:CreateFontString("GroupText2");
GroupText2:SetFont(Dream_GameFont, 30, "OUTLINE");
GroupText2:SetPoint("CENTER", 326, -24);
GroupText2:SetText("|cFF00FF00木|r");

local GroupText3 = ItemMagicFrame:CreateFontString("GroupText3");
GroupText3:SetFont(Dream_GameFont, 30, "OUTLINE");
GroupText3:SetPoint("CENTER", 201, -297);
GroupText3:SetText("|cFFFF0000火|r");

local GroupText4 = ItemMagicFrame:CreateFontString("GroupText4");
GroupText4:SetFont(Dream_GameFont, 30, "OUTLINE");
GroupText4:SetPoint("CENTER", -225, -297);
GroupText4:SetText("|cFFFF6600土|r");

local GroupText5 = ItemMagicFrame:CreateFontString("GroupText5");
GroupText5:SetFont(Dream_GameFont, 30, "OUTLINE");
GroupText5:SetPoint("CENTER", -333, -3);
GroupText5:SetText("|cFF0099FF水|r");

local GroupTextC1 = ItemMagicFrame:CreateFontString("GroupTextC1");
GroupTextC1:SetFont(Dream_GameFont, 30, "OUTLINE");
GroupTextC1:SetPoint("CENTER", 7, 8);
GroupTextC1:SetText("|cFFFF3399天|r");

local GroupTextC2 = ItemMagicFrame:CreateFontString("GroupTextC2");
GroupTextC2:SetFont(Dream_GameFont, 30, "OUTLINE");
GroupTextC2:SetPoint("CENTER", 135, -135);
GroupTextC2:SetText("|cFFFFFF00玄|r");

local GroupTextC3 = ItemMagicFrame:CreateFontString("GroupTextC3");
GroupTextC3:SetFont(Dream_GameFont, 30, "OUTLINE");
GroupTextC3:SetPoint("CENTER", -112, -140);
GroupTextC3:SetText("|cFF66CC99地|r");

--材料提示
local NewLuckStrCmText = NewLuckFrame:CreateFontString("NewLuckStrCmText");
NewLuckStrCmText:SetFont(Dream_GameFont, 16);
NewLuckStrCmText:SetPoint("TOPLEFT", 80, -80);
NewLuckStrCmText:SetText("");

--小组1
for i=1,5 do
	ItemMagicFrameButtons[1][i] = CreateFrame("Button", "ItemMagicFrameButtons1-"..i, ItemMagicFrame, "DreamZcRingSmButtonTemplate");
	ItemMagicFrameButtons[1][i]:SetSize(60, 60);
	ItemMagicFrameButtons[1][i]:SetHighlightTexture("Interface\\Icons\\HightQpOnEnter");
	
	ItemMagicFrameButtons[1][i].ButtonTexture = ItemMagicFrameButtons[1][i]:CreateTexture("ItemMagicFrameButtonsTexture1-"..i);
	ItemMagicFrameButtons[1][i].ButtonTexture:SetSize(60, 60);
	ItemMagicFrameButtons[1][i].ButtonTexture:SetPoint("CENTER");
	ItemMagicFrameButtons[1][i].ButtonTexture:SetTexture("");

	if (i == 1) then
		ItemMagicFrameButtons[1][i]:SetPoint("CENTER", 10, 310);
	elseif (i == 2) then
		ItemMagicFrameButtons[1][i]:SetPoint("CENTER", 110, 255);
	elseif (i == 3) then
		ItemMagicFrameButtons[1][i]:SetPoint("CENTER", 73, 158);
	elseif (i == 4) then
		ItemMagicFrameButtons[1][i]:SetPoint("CENTER", -53, 155);
	elseif (i == 5) then
		ItemMagicFrameButtons[1][i]:SetPoint("CENTER", -93, 255);
	end

	ItemMagicFrameButtons[1][i].AuraId = 0;
	ItemMagicFrameButtons[1][i].ItemId = 0;

	ItemMagicFrameButtons[1][i]:RegisterForClicks("AnyDown");
	ItemMagicFrameButtons[1][i]:SetScript("OnClick",
	function(self, BtnType)
		if (BtnType == "LeftButton") then
			local IType, _, ItemLink = GetCursorInfo();
			if (IType ~= "item") then
				return;
			end
			local _, _, _, _, _, _, _, _, ItemGuidLow, _ = Dream_DoSplit(":", string.match(ItemLink, "item[%-?%d:]+"));
			local GuidLow = tonumber(ItemGuidLow) - MaxGuidIndex
			Dream_SendData("InItemMagicQuery", tostring(GuidLow).."#1#"..i);
			ClearCursor();
		elseif (BtnType == "RightButton") then
			if (self.AuraId ~= 0 and self.ItemId ~= 0) then
				Dream_SendData("TaskItemMagic", "1#"..tostring(i).."#"..self.ItemId);
			end
		end
    end)

	ItemMagicFrameButtons[1][i]:SetScript("OnEnter",
	function(self)
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
		GameTooltip:SetHyperlink("spell:"..self.AuraId);
		if (self.AuraId > 0 and self.ItemId > 0) then
			GameTooltip:AddLine("\n");
			GameTooltip:AddLine("|cFF00FF00该槽的法宝物品: ["..self.ItemId.."]|r |T"..DreamGetItemIcon(tonumber(self.ItemId))..":32|t");
		end
		GameTooltip:Show();
	end)
	ItemMagicFrameButtons[1][i]:SetScript("OnLeave",
	function(self)
		GameTooltip:Hide();
	end)
end

--小组2
for i=1,5 do
	ItemMagicFrameButtons[2][i] = CreateFrame("Button", "ItemMagicFrameButtons2-"..i, ItemMagicFrame, "DreamZcRingSmButtonTemplate");
	ItemMagicFrameButtons[2][i]:SetSize(60, 60);
	ItemMagicFrameButtons[2][i]:SetHighlightTexture("Interface\\Icons\\HightQpOnEnter");
	
	ItemMagicFrameButtons[2][i].ButtonTexture = ItemMagicFrameButtons[2][i]:CreateTexture("ItemMagicFrameButtonsTexture2-"..i);
	ItemMagicFrameButtons[2][i].ButtonTexture:SetSize(60, 60);
	ItemMagicFrameButtons[2][i].ButtonTexture:SetPoint("CENTER");
	ItemMagicFrameButtons[2][i].ButtonTexture:SetTexture("");

	if (i == 1) then
		ItemMagicFrameButtons[2][i]:SetPoint("CENTER", 326, 118);
	elseif (i == 2) then
		ItemMagicFrameButtons[2][i]:SetPoint("CENTER", 426, 63);
	elseif (i == 3) then
		ItemMagicFrameButtons[2][i]:SetPoint("CENTER", 389, -35);
	elseif (i == 4) then
		ItemMagicFrameButtons[2][i]:SetPoint("CENTER", 263, -37);
	elseif (i == 5) then
		ItemMagicFrameButtons[2][i]:SetPoint("CENTER", 223, 63);
	end

	ItemMagicFrameButtons[2][i].AuraId = 0;
	ItemMagicFrameButtons[2][i].ItemId = 0;

	ItemMagicFrameButtons[2][i]:RegisterForClicks("AnyDown");
	ItemMagicFrameButtons[2][i]:SetScript("OnClick",
	function(self, BtnType)
		if (BtnType == "LeftButton") then
			local IType, _, ItemLink = GetCursorInfo();
			if (IType ~= "item") then
				return;
			end
			local _, _, _, _, _, _, _, _, ItemGuidLow, _ = Dream_DoSplit(":", string.match(ItemLink, "item[%-?%d:]+"));
			local GuidLow = tonumber(ItemGuidLow) - MaxGuidIndex
			Dream_SendData("InItemMagicQuery", tostring(GuidLow).."#2#"..i);
			ClearCursor();
		elseif (BtnType == "RightButton") then
			if (self.AuraId ~= 0 and self.ItemId ~= 0) then
				Dream_SendData("TaskItemMagic", "2#"..tostring(i).."#"..self.ItemId);
			end
		end
    end)

	ItemMagicFrameButtons[2][i]:SetScript("OnEnter",
	function(self)
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
		GameTooltip:SetHyperlink("spell:"..self.AuraId);
		if (self.AuraId > 0 and self.ItemId > 0) then
			GameTooltip:AddLine("\n");
			GameTooltip:AddLine("|cFF00FF00该槽的法宝物品: ["..self.ItemId.."]|r |T"..DreamGetItemIcon(tonumber(self.ItemId))..":32|t");
		end
		GameTooltip:Show();
	end)
	ItemMagicFrameButtons[2][i]:SetScript("OnLeave",
	function(self)
		GameTooltip:Hide();
	end)
end

--小组3
for i=1,5 do
	ItemMagicFrameButtons[3][i] = CreateFrame("Button", "ItemMagicFrameButtons3-"..i, ItemMagicFrame, "DreamZcRingSmButtonTemplate");
	ItemMagicFrameButtons[3][i]:SetSize(60, 60);
	ItemMagicFrameButtons[3][i]:SetHighlightTexture("Interface\\Icons\\HightQpOnEnter");
	
	ItemMagicFrameButtons[3][i].ButtonTexture = ItemMagicFrameButtons[3][i]:CreateTexture("ItemMagicFrameButtonsTexture3-"..i);
	ItemMagicFrameButtons[3][i].ButtonTexture:SetSize(60, 60);
	ItemMagicFrameButtons[3][i].ButtonTexture:SetPoint("CENTER");
	ItemMagicFrameButtons[3][i].ButtonTexture:SetTexture("");

	if (i == 1) then
		ItemMagicFrameButtons[3][i]:SetPoint("CENTER", 203, -152);
	elseif (i == 2) then
		ItemMagicFrameButtons[3][i]:SetPoint("CENTER", 303, -207);
	elseif (i == 3) then
		ItemMagicFrameButtons[3][i]:SetPoint("CENTER", 266, -305);
	elseif (i == 4) then
		ItemMagicFrameButtons[3][i]:SetPoint("CENTER", 140, -305);
	elseif (i == 5) then
		ItemMagicFrameButtons[3][i]:SetPoint("CENTER", 100, -207);
	end

	ItemMagicFrameButtons[3][i].AuraId = 0;
	ItemMagicFrameButtons[3][i].ItemId = 0;

	ItemMagicFrameButtons[3][i]:RegisterForClicks("AnyDown");
	ItemMagicFrameButtons[3][i]:SetScript("OnClick",
	function(self, BtnType)
		if (BtnType == "LeftButton") then
			local IType, _, ItemLink = GetCursorInfo();
			if (IType ~= "item") then
				return;
			end
			local _, _, _, _, _, _, _, _, ItemGuidLow, _ = Dream_DoSplit(":", string.match(ItemLink, "item[%-?%d:]+"));
			local GuidLow = tonumber(ItemGuidLow) - MaxGuidIndex
			Dream_SendData("InItemMagicQuery", tostring(GuidLow).."#3#"..i);
			ClearCursor();
		elseif (BtnType == "RightButton") then
			if (self.AuraId ~= 0 and self.ItemId ~= 0) then
				Dream_SendData("TaskItemMagic", "3#"..tostring(i).."#"..self.ItemId);
			end
		end
    end)

	ItemMagicFrameButtons[3][i]:SetScript("OnEnter",
	function(self)
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
		GameTooltip:SetHyperlink("spell:"..self.AuraId);
		if (self.AuraId > 0 and self.ItemId > 0) then
			GameTooltip:AddLine("\n");
			GameTooltip:AddLine("|cFF00FF00该槽的法宝物品: ["..self.ItemId.."]|r |T"..DreamGetItemIcon(tonumber(self.ItemId))..":32|t");
		end
		GameTooltip:Show();
	end)
	ItemMagicFrameButtons[3][i]:SetScript("OnLeave",
	function(self)
		GameTooltip:Hide();
	end)
end

--小组4
for i=1,5 do
	ItemMagicFrameButtons[4][i] = CreateFrame("Button", "ItemMagicFrameButtons4-"..i, ItemMagicFrame, "DreamZcRingSmButtonTemplate");
	ItemMagicFrameButtons[4][i]:SetSize(60, 60);
	ItemMagicFrameButtons[4][i]:SetHighlightTexture("Interface\\Icons\\HightQpOnEnter");
	
	ItemMagicFrameButtons[4][i].ButtonTexture = ItemMagicFrameButtons[4][i]:CreateTexture("ItemMagicFrameButtonsTexture4-"..i);
	ItemMagicFrameButtons[4][i].ButtonTexture:SetSize(60, 60);
	ItemMagicFrameButtons[4][i].ButtonTexture:SetPoint("CENTER");
	ItemMagicFrameButtons[4][i].ButtonTexture:SetTexture("");

	if (i == 1) then
		ItemMagicFrameButtons[4][i]:SetPoint("CENTER", -223, -152);
	elseif (i == 2) then
		ItemMagicFrameButtons[4][i]:SetPoint("CENTER", -125, -208);
	elseif (i == 3) then
		ItemMagicFrameButtons[4][i]:SetPoint("CENTER", -160, -306);
	elseif (i == 4) then
		ItemMagicFrameButtons[4][i]:SetPoint("CENTER", -285, -308);
	elseif (i == 5) then
		ItemMagicFrameButtons[4][i]:SetPoint("CENTER", -326, -208);
	end

	ItemMagicFrameButtons[4][i].AuraId = 0;
	ItemMagicFrameButtons[4][i].ItemId = 0;

	ItemMagicFrameButtons[4][i]:RegisterForClicks("AnyDown");
	ItemMagicFrameButtons[4][i]:SetScript("OnClick",
	function(self, BtnType)
		if (BtnType == "LeftButton") then
			local IType, _, ItemLink = GetCursorInfo();
			if (IType ~= "item") then
				return;
			end
			local _, _, _, _, _, _, _, _, ItemGuidLow, _ = Dream_DoSplit(":", string.match(ItemLink, "item[%-?%d:]+"));
			local GuidLow = tonumber(ItemGuidLow) - MaxGuidIndex
			Dream_SendData("InItemMagicQuery", tostring(GuidLow).."#4#"..i);
			ClearCursor();
		elseif (BtnType == "RightButton") then
			if (self.AuraId ~= 0 and self.ItemId ~= 0) then
				Dream_SendData("TaskItemMagic", "4#"..tostring(i).."#"..self.ItemId);
			end
		end
    end)

	ItemMagicFrameButtons[4][i]:SetScript("OnEnter",
	function(self)
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
		GameTooltip:SetHyperlink("spell:"..self.AuraId);
		if (self.AuraId > 0 and self.ItemId > 0) then
			GameTooltip:AddLine("\n");
			GameTooltip:AddLine("|cFF00FF00该槽的法宝物品: ["..self.ItemId.."]|r |T"..DreamGetItemIcon(tonumber(self.ItemId))..":32|t");
		end
		GameTooltip:Show();
	end)
	ItemMagicFrameButtons[4][i]:SetScript("OnLeave",
	function(self)
		GameTooltip:Hide();
	end)
end

--小组5
for i=1,5 do
	ItemMagicFrameButtons[5][i] = CreateFrame("Button", "ItemMagicFrameButtons5-"..i, ItemMagicFrame, "DreamZcRingSmButtonTemplate");
	ItemMagicFrameButtons[5][i]:SetSize(60, 60);
	ItemMagicFrameButtons[5][i]:SetHighlightTexture("Interface\\Icons\\HightQpOnEnter");
	
	ItemMagicFrameButtons[5][i].ButtonTexture = ItemMagicFrameButtons[5][i]:CreateTexture("ItemMagicFrameButtonsTexture5-"..i);
	ItemMagicFrameButtons[5][i].ButtonTexture:SetSize(60, 60);
	ItemMagicFrameButtons[5][i].ButtonTexture:SetPoint("CENTER");
	ItemMagicFrameButtons[5][i].ButtonTexture:SetTexture("");

	if (i == 1) then
		ItemMagicFrameButtons[5][i]:SetPoint("CENTER", -333, 138);
	elseif (i == 2) then
		ItemMagicFrameButtons[5][i]:SetPoint("CENTER", -232, 82);
	elseif (i == 3) then
		ItemMagicFrameButtons[5][i]:SetPoint("CENTER", -270, -15);
	elseif (i == 4) then
		ItemMagicFrameButtons[5][i]:SetPoint("CENTER", -394, -16);
	elseif (i == 5) then
		ItemMagicFrameButtons[5][i]:SetPoint("CENTER", -435, 82);
	end

	ItemMagicFrameButtons[5][i].AuraId = 0;
	ItemMagicFrameButtons[5][i].ItemId = 0;

	ItemMagicFrameButtons[5][i]:RegisterForClicks("AnyDown");
	ItemMagicFrameButtons[5][i]:SetScript("OnClick",
	function(self, BtnType)
		if (BtnType == "LeftButton") then
			local IType, _, ItemLink = GetCursorInfo();
			if (IType ~= "item") then
				return;
			end
			local _, _, _, _, _, _, _, _, ItemGuidLow, _ = Dream_DoSplit(":", string.match(ItemLink, "item[%-?%d:]+"));
			local GuidLow = tonumber(ItemGuidLow) - MaxGuidIndex
			Dream_SendData("InItemMagicQuery", tostring(GuidLow).."#5#"..i);
			ClearCursor();
		elseif (BtnType == "RightButton") then
			if (self.AuraId ~= 0 and self.ItemId ~= 0) then
				Dream_SendData("TaskItemMagic", "5#"..tostring(i).."#"..self.ItemId);
			end
		end
    end)

	ItemMagicFrameButtons[5][i]:SetScript("OnEnter",
	function(self)
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
		GameTooltip:SetHyperlink("spell:"..self.AuraId);
		if (self.AuraId > 0 and self.ItemId > 0) then
			GameTooltip:AddLine("\n");
			GameTooltip:AddLine("|cFF00FF00该槽的法宝物品: ["..self.ItemId.."]|r |T"..DreamGetItemIcon(tonumber(self.ItemId))..":32|t");
		end
		GameTooltip:Show();
	end)
	ItemMagicFrameButtons[5][i]:SetScript("OnLeave",
	function(self)
		GameTooltip:Hide();
	end)
end

--激活的大组
for i=1,5 do
	ItemMagicFrameButtons[6][i] = CreateFrame("Button", "ItemMagicFrameButtons6-"..i, ItemMagicFrame, "DreamZcRingSmButtonTemplate");
	ItemMagicFrameButtons[6][i]:SetSize(80, 80);
	ItemMagicFrameButtons[6][i]:SetHighlightTexture("Interface\\Icons\\HightQpOnEnter");
	
	ItemMagicFrameButtons[6][i].ButtonTexture = ItemMagicFrameButtons[6][i]:CreateTexture("ItemMagicFrameButtonsTexture6-"..i);
	ItemMagicFrameButtons[6][i].ButtonTexture:SetSize(80, 80);
	ItemMagicFrameButtons[6][i].ButtonTexture:SetPoint("CENTER");
	ItemMagicFrameButtons[6][i].ButtonTexture:SetTexture("");

	if (i == 1) then
		ItemMagicFrameButtons[6][i]:SetPoint("CENTER", 10, 226);
	elseif (i == 2) then
		ItemMagicFrameButtons[6][i]:SetPoint("CENTER", 326, 34);
	elseif (i == 3) then
		ItemMagicFrameButtons[6][i]:SetPoint("CENTER", 201, -237);
	elseif (i == 4) then
		ItemMagicFrameButtons[6][i]:SetPoint("CENTER", -225, -237);
	elseif (i == 5) then
		ItemMagicFrameButtons[6][i]:SetPoint("CENTER", -333, 53);
	end

	ItemMagicFrameButtons[6][i].AuraId = 0;

	ItemMagicFrameButtons[6][i]:SetScript("OnEnter",
	function(self)
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
		GameTooltip:SetHyperlink("spell:"..self.AuraId);
		if (self.AuraId > 0) then
			GameTooltip:AddLine("\n");
			GameTooltip:AddLine("|cFF00FF00该槽属于激活产生|r");
		end
		GameTooltip:Show();
	end)
	ItemMagicFrameButtons[6][i]:SetScript("OnLeave",
	function(self)
		GameTooltip:Hide();
	end)
end

--额外超大组
for i=1,3 do
	ItemMagicFrameButtons[7][i] = CreateFrame("Button", "ItemMagicFrameButtons7-"..i, ItemMagicFrame, "DreamZcRingSmButtonTemplate");
	ItemMagicFrameButtons[7][i]:SetSize(90, 90);
	ItemMagicFrameButtons[7][i]:SetHighlightTexture("Interface\\Icons\\HightQpOnEnter");
	
	ItemMagicFrameButtons[7][i].ButtonTexture = ItemMagicFrameButtons[7][i]:CreateTexture("ItemMagicFrameButtonsTexture7-"..i);
	ItemMagicFrameButtons[7][i].ButtonTexture:SetSize(90, 90);
	ItemMagicFrameButtons[7][i].ButtonTexture:SetPoint("CENTER");
	ItemMagicFrameButtons[7][i].ButtonTexture:SetTexture("");

	if (i == 1) then
		ItemMagicFrameButtons[7][i]:SetPoint("CENTER", 7, 68);
	elseif (i == 2) then
		ItemMagicFrameButtons[7][i]:SetPoint("CENTER", 135, -75);
	elseif (i == 3) then
		ItemMagicFrameButtons[7][i]:SetPoint("CENTER", -112, -80);
	end

	ItemMagicFrameButtons[7][i].AuraId = 0;
	ItemMagicFrameButtons[7][i].ItemId = 0;

	ItemMagicFrameButtons[7][i]:RegisterForClicks("AnyDown");
	ItemMagicFrameButtons[7][i]:SetScript("OnClick",
	function(self, BtnType)
		if (BtnType == "LeftButton") then
			local IType, _, ItemLink = GetCursorInfo();
			if (IType ~= "item") then
				return;
			end
			local _, _, _, _, _, _, _, _, ItemGuidLow, _ = Dream_DoSplit(":", string.match(ItemLink, "item[%-?%d:]+"));
			local GuidLow = tonumber(ItemGuidLow) - MaxGuidIndex
			Dream_SendData("InItemMagicQuery", tostring(GuidLow).."#7#"..i);
			ClearCursor();
		elseif (BtnType == "RightButton") then
			if (self.AuraId ~= 0 and self.ItemId ~= 0) then
				Dream_SendData("TaskItemMagic", "7#"..tostring(i).."#"..self.ItemId);
			end
		end
    end)

	ItemMagicFrameButtons[7][i]:SetScript("OnEnter",
	function(self)
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
		GameTooltip:SetHyperlink("spell:"..self.AuraId);
		if (self.AuraId > 0 and self.ItemId > 0) then
			GameTooltip:AddLine("\n");
			GameTooltip:AddLine("|cFF00FF00该槽的法宝物品: ["..self.ItemId.."]|r |T"..DreamGetItemIcon(tonumber(self.ItemId))..":32|t");
		end
		GameTooltip:Show();
	end)
	ItemMagicFrameButtons[7][i]:SetScript("OnLeave",
	function(self)
		GameTooltip:Hide();
	end)
end


ItemMagicFrame:SetScript("OnShow",
function(self)

end)

ItemMagicFrame:SetScript("OnHide",
function(self)

end)

--消息处理
local function Dream_OnItemMagicAddonEvent(Self, event, Packet, Msg, Type, Sender)
    if (event == "CHAT_MSG_ADDON") then
		if (Packet == "ItemMagicGroup1") then
			local Args = Dream_Split(Msg, "#");
			local Num = tonumber(Args[1]);
			local AuraId = tonumber(Args[2]);
			local ItemId = tonumber(Args[3]);
			ItemMagicFrameButtons[1][Num].AuraId = AuraId;
			ItemMagicFrameButtons[1][Num].ItemId = ItemId;
			ItemMagicFrameButtons[1][Num].ButtonTexture:SetTexture(DreamGetSpellIcon(AuraId));
		elseif (Packet == "ItemMagicGroup2") then
			local Args = Dream_Split(Msg, "#");
			local Num = tonumber(Args[1]);
			local AuraId = tonumber(Args[2]);
			local ItemId = tonumber(Args[3]);
			ItemMagicFrameButtons[2][Num].AuraId = AuraId;
			ItemMagicFrameButtons[2][Num].ItemId = ItemId;
			ItemMagicFrameButtons[2][Num].ButtonTexture:SetTexture(DreamGetSpellIcon(AuraId));
		elseif (Packet == "ItemMagicGroup3") then
			local Args = Dream_Split(Msg, "#");
			local Num = tonumber(Args[1]);
			local AuraId = tonumber(Args[2]);
			local ItemId = tonumber(Args[3]);
			ItemMagicFrameButtons[3][Num].AuraId = AuraId;
			ItemMagicFrameButtons[3][Num].ItemId = ItemId;
			ItemMagicFrameButtons[3][Num].ButtonTexture:SetTexture(DreamGetSpellIcon(AuraId));
		elseif (Packet == "ItemMagicGroup4") then
			local Args = Dream_Split(Msg, "#");
			local Num = tonumber(Args[1]);
			local AuraId = tonumber(Args[2]);
			local ItemId = tonumber(Args[3]);
			ItemMagicFrameButtons[4][Num].AuraId = AuraId;
			ItemMagicFrameButtons[4][Num].ItemId = ItemId;
			ItemMagicFrameButtons[4][Num].ButtonTexture:SetTexture(DreamGetSpellIcon(AuraId));
		elseif (Packet == "ItemMagicGroup5") then
			local Args = Dream_Split(Msg, "#");
			local Num = tonumber(Args[1]);
			local AuraId = tonumber(Args[2]);
			local ItemId = tonumber(Args[3]);
			ItemMagicFrameButtons[5][Num].AuraId = AuraId;
			ItemMagicFrameButtons[5][Num].ItemId = ItemId;
			ItemMagicFrameButtons[5][Num].ButtonTexture:SetTexture(DreamGetSpellIcon(AuraId));
		elseif (Packet == "ItemMagicGroup6") then
			local Args = Dream_Split(Msg, "#");
			local Num = tonumber(Args[1]);
			local AuraId = tonumber(Args[2]);
			ItemMagicFrameButtons[6][Num].AuraId = AuraId;
			ItemMagicFrameButtons[6][Num].ButtonTexture:SetTexture(DreamGetSpellIcon(AuraId));
		elseif (Packet == "ItemMagicCentre") then
			local Args = Dream_Split(Msg, "#");
			local Num = tonumber(Args[1]);
			local AuraId = tonumber(Args[2]);
			local ItemId = tonumber(Args[3]);
			ItemMagicFrameButtons[7][Num].AuraId = AuraId;
			ItemMagicFrameButtons[7][Num].ItemId = ItemId;
			ItemMagicFrameButtons[7][Num].ButtonTexture:SetTexture(DreamGetSpellIcon(AuraId));
		elseif (Packet == "NoFuncItemMagic") then
			local Args = Dream_Split(Msg, "#");
			local AtGroup = tonumber(Args[1]);
			local Num = tonumber(Args[2]);
			if (ItemMagicFrameButtons[AtGroup][Num].AuraId == 0) then
				ItemMagicFrameButtons[AtGroup][Num].ButtonTexture:SetTexture("");
			end
		elseif (Packet == "YesTaskFuncItemMagic") then
			local Args = Dream_Split(Msg, "#");
			local AtGroup = tonumber(Args[1]);
			local Num = tonumber(Args[2]);
			ItemMagicFrameButtons[AtGroup][Num].AuraId = 0;
			ItemMagicFrameButtons[AtGroup][Num].ButtonTexture:SetTexture("");
		elseif (Packet == "NowYeslItemMagic") then
			local Args = Dream_Split(Msg, "#");
			local AtGroup = tonumber(Args[1]);
			local Num = tonumber(Args[2]);
			local AuraId = tonumber(Args[3]);
			local ItemId = tonumber(Args[4]);
			ItemMagicFrameButtons[AtGroup][Num].AuraId = AuraId;
			ItemMagicFrameButtons[AtGroup][Num].ButtonTexture:SetTexture(DreamGetSpellIcon(AuraId));
			if (AtGroup ~= 6) then
				ItemMagicFrameButtons[AtGroup][Num].ItemId = ItemId;
			end
			NowShowTips(ItemMagicFrameButtons[AtGroup][Num], "|Hspell:"..AuraId);
		end
	elseif (event == "PLAYER_LOGIN") then
		Dream_SendData("InPlayerMagicQuery");
	end
end

--交互消息事件
local ItemMagicAddonFrame = CreateFrame("Frame", "ItemMagicAddonFrame");
ItemMagicAddonFrame:RegisterEvent("CHAT_MSG_ADDON");
ItemMagicAddonFrame:RegisterEvent("PLAYER_LOGIN");
ItemMagicAddonFrame:SetScript("OnEvent", Dream_OnItemMagicAddonEvent);




--------------------------------------------------------------------



