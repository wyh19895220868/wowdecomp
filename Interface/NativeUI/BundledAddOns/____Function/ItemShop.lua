---@diagnostic disable: missing-parameter

local ItemShopTabButton = { };
local ItemShopTabButtonStr = { };

local ItemShopListFrame = { };
local ItemShopAtButton = { };
local ItemShopAtButtonStr = { };

local ItemTitleLinkStr = { };
local ItemTitleButton = { };
local ItemTitleButtonStr = { };

--静态弹出框
StaticPopupDialogs["BuyShopItem"] = {

	text = "%s",
	button1 = "确定",
	button2 = "取消",
	
	OnAccept = function(Self)
	
	    local Num = Self.editBox:GetNumber();
        Dream_SendData("AcceptBuyShopItem", tostring(Self.ItemId).."#"..tostring(Num));

	end,
	
	OnCancel = function(Self)

	end,
	
	OnShow = function (Self)
	    Self.editBox:ClearFocus();
	    Self.editBox:SetNumeric(true)
        Self.editBox:SetNumber(1);
    end,

	exclusive = true,
	whileDead = true,
	hideOnEscape = true,
	timeout = 0,
	hasEditBox = true,
};

--处理 购买信息
function ApplyBuyNeedInfo(Msg)
    local Args = Dream_Split(Msg, "$");
    local Dialog = StaticPopup_Show("BuyShopItem", "\n|cFF00FF00购买|r\n"..Args[1].."\n"..Args[2].."|r\n|cFF00FF00你确定要这么做吗?\n\n购买数量|r");
	if (Dialog) then
	    Dialog.ItemId = GetItemIdByLink(Args[1]);

		ItemShopFrame:SetAlpha(0.6);
		for i=1,9 do
		    ItemTitleButtonStr[i]:SetAlpha(0.3);
		end
			
		Dialog:SetScript("OnHide",
        function(self)
    		ItemShopFrame:SetAlpha(1.0);
		    for i=1,9 do
		        ItemTitleButtonStr[i]:SetAlpha(1.0);
		    end
        end)
	end
end

local SelectTab = 1;                    --起始分类页
local SelectPage = 1;                   --起始第一页
local MaxPageForTab = 1;                --最大页数

--处理 分类名称
function ApplyTabName(Msg)
    local Args = Dream_Split(Msg, "$");
	for i=1,6 do
		ItemShopTabButton[i]:Hide();
		ItemShopTabButtonStr[i]:SetText(Args[i]);
		if (Args[i] ~= "nullptr") then
			ItemShopTabButton[i]:Show();
		end
	end
end

--处理 分类中的指定页
function ApplyShopTabPage(Msg)
    local Args = Dream_Split(Msg, "$");
	MaxPageForTab = tonumber(Args[1]);
	ItemShopPageStr:SetText("|cFF00FF00第 "..SelectPage.." 页 共 "..MaxPageForTab.." 页|r");
	
	--排列物品
	local Arg = Dream_Split(Args[2], "#");
	for i=1,9 do
	    local ItemLink = Arg[i];
		if (ItemLink) then
		    ItemTitleButton[i]:SetHighlightTexture("Interface\\BUTTONS\\CheckButtonHilight");
		    ItemShopAtButton[i]:Show();
			ItemTitleLinkStr[i]:SetText(ItemLink);
		    local ItemId = GetItemIdByLink(ItemLink);
	        ItemTitleButton[i]:SetText("|T"..DreamGetItemIcon(tonumber(ItemId))..":64|t");
			ItemShopAtButton[i]:SetID(tonumber(ItemId));
		else
		    ItemShopAtButton[i]:SetID(0);
		    ItemShopAtButton[i]:Hide();
		    ItemTitleLinkStr[i]:SetText("");
		    ItemTitleButton[i]:SetText("");
			ItemTitleButton[i]:SetHighlightTexture("");
		end
	end
end

--处理 搜索结果
function ApplyShopSearch(Msg)
    local Args = Dream_Split(Msg, "#");
	ItemShopPageStr:SetText("|cFF00FF00第 1 页 共 1 页|r");
	
	--排列物品
	for i=1,9 do
	    local ItemLink = Args[i];
		if (ItemLink) then
		    ItemTitleButton[i]:SetHighlightTexture("Interface\\BUTTONS\\CheckButtonHilight");
		    ItemShopAtButton[i]:Show();
			ItemTitleLinkStr[i]:SetText(ItemLink);
		    local ItemId = GetItemIdByLink(ItemLink);
	        ItemTitleButton[i]:SetText("|T"..DreamGetItemIcon(tonumber(ItemId))..":64|t");
			ItemShopAtButton[i]:SetID(tonumber(ItemId));
		else
		    ItemShopAtButton[i]:SetID(0);
		    ItemShopAtButton[i]:Hide();
		    ItemTitleLinkStr[i]:SetText("");
		    ItemTitleButton[i]:SetText("");
			ItemTitleButton[i]:SetHighlightTexture("");
		end
	end
	
	SelectTab = 1;
    SelectPage = 1;
	ItemShopNextButton:Disable();
end

local ItemShopFrame = CreateFrame("Frame", "ItemShopFrame", UIParent);
ItemShopFrame:SetSize(720, 720);
ItemShopFrame:RegisterForDrag("LeftButton");
ItemShopFrame:SetPoint("CENTER", 0, 0);
ItemShopFrame:SetToplevel(true);
ItemShopFrame:SetClampedToScreen(true);

ItemShopFrame:SetBackdrop({ bgFile = ShopBIcon })

--页数信息
local ItemShopPageStr = ItemShopFrame:CreateFontString("ItemShopPageStr");
ItemShopPageStr:SetFont(Dream_GameFont, 15);
ItemShopPageStr:SetPoint("BOTTOM", 0, 40);
ItemShopPageStr:SetText("|cFF00FF00第 1 页 共 1 页|r");

tinsert(UISpecialFrames, "ItemShopFrame");

ItemShopFrame:Hide();

-- 关闭按钮
local ItemShopClose = CreateFrame("Button", "ItemShopClose", ItemShopFrame, "UIPanelCloseButton");
ItemShopClose:SetPoint("TOPRIGHT", -8, -80)
ItemShopClose:EnableMouse(true);
ItemShopClose:SetSize(30, 30);

for i=1,6 do
    ItemShopTabButton[i] = CreateFrame("Button","ItemShopTabButton"..i, ItemShopFrame);
	ItemShopTabButton[i]:SetSize(120, 44);

    ItemShopTabButton[i]:SetPoint("TOPRIGHT", 100 , -((i - 1) * 50 + 240));
    ItemShopTabButton[i]:EnableMouse(true);
    ItemShopTabButton[i]:SetBackdrop({ bgFile = ShopSubIcon });
    ItemShopTabButton[i]:SetHighlightTexture("Interface\\BUTTONS\\OldButtonHilight-Square");

	ItemShopTabButtonStr[i] = ItemShopTabButton[i]:CreateFontString("ItemShopTabButtonStr"..i);
	ItemShopTabButtonStr[i]:SetFont(Dream_GameFont, 16);
	ItemShopTabButtonStr[i]:SetVertexColor(0/255, 255/255, 0/255);
	ItemShopTabButton[i]:SetFontString(ItemShopTabButtonStr[i]);
    ItemShopTabButton[i]:SetText("");

	ItemShopTabButton[i]:SetScript("OnClick",
    function(self)
        UpdateTabClick(i);
    end)
end

--处理 点击分类
function UpdateTabClick(Num)
	ItemShopNextButton:Enable();
	SelectTab = Num;
	SelectPage = 1;
	Dream_SendData("GetShopTabPage", tostring(SelectTab).."#"..tostring(SelectPage));
end

ItemShopFrame:SetScript("OnShow",
function(self)
    SearchEditBox:SetText("");
    UpdateTabClick(1);
	ItemShopFrame:SetAlpha(1.0);
	for i=1,9 do
		ItemTitleButtonStr[i]:SetAlpha(1.0);
	end
end)

ItemShopFrame:SetScript("OnHide",
function(self)
    StaticPopup_Hide("BuyShopItem");
end)

for i=1,9 do
    ItemShopListFrame[i] = CreateFrame("Frame","ItemShopListFrame"..i, ItemShopFrame);
	ItemShopListFrame[i]:SetSize(220, 150);
    ItemShopListFrame[i]:SetBackdrop({ bgFile = ShopListIcon });
	
	ItemTitleLinkStr[i] = ItemShopListFrame[i]:CreateFontString("ItemTitleLinkStr"..i);
	ItemTitleLinkStr[i]:SetPoint("TOP", 0, -24);
	ItemTitleLinkStr[i]:SetFont(Dream_GameFont, 15);
	ItemTitleLinkStr[i]:SetText("");
	
	ItemTitleButton[i] = CreateFrame("Button","ItemTitleButton"..i, ItemShopListFrame[i]);
	ItemTitleButton[i]:SetSize(64, 64);
	ItemTitleButton[i]:EnableMouse(true);
	ItemTitleButton[i]:SetPoint("CENTER", 0, 0);
	
	ItemTitleButtonStr[i] = ItemTitleButton[i]:CreateFontString("ItemTitleButtonStr"..i);
    ItemTitleButtonStr[i]:SetFont(Dream_GameFont, 12);
    ItemTitleButton[i]:SetFontString(ItemTitleButtonStr[i]);
    ItemTitleButton[i]:SetText("");
	
	ItemShopAtButton[i] = CreateFrame("Button","ItemShopAtButton"..i, ItemShopListFrame[i]);
	ItemShopAtButton[i]:SetSize(150, 30);
	ItemShopAtButton[i]:EnableMouse(true);
	ItemShopAtButton[i]:SetBackdrop({ bgFile = NormalBtnIcon })
    ItemShopAtButton[i]:SetHighlightTexture("Interface\\Buttons\\UI-Panel-MinimizeButton-Highlight")
	ItemShopAtButton[i]:SetPoint("BOTTOM", 0, 10);
	ItemShopAtButtonStr[i] = ItemShopAtButton[i]:CreateFontString("ItemShopAtButtonStr"..i);
	ItemShopAtButtonStr[i]:SetFont(Dream_GameFont, 15);
	ItemShopAtButton[i]:SetFontString(ItemShopAtButtonStr[i]);
	ItemShopAtButton[i]:SetText("|cffFFC125购买|r");
	
	ItemShopAtButton[i]:SetID(0);
	
	ItemShopAtButton[i]:SetScript("OnClick",
    function(self)
	    local ItemId = self:GetID();
		if (ItemId ~= 0) then
		    Dream_SendData("RequestBuyNeedInfo", tostring(ItemId));
		end
    end)
	
	if (i < 4) then
	    ItemShopListFrame[i]:SetPoint("TOPLEFT", (i - 1) * 210 + 40 , -170);
	elseif (i < 7) then
	    ItemShopListFrame[i]:SetPoint("TOPLEFT", (i - 4) * 210 + 40 , -320);
	else
	    ItemShopListFrame[i]:SetPoint("TOPLEFT", (i - 7) * 210 + 40 , -470);
	end

    ItemTitleButton[i]:SetScript("OnEnter", 
    function(self)
        GameTooltip:SetOwner(ItemTitleButton[i], "ANCHOR_LEFT");
        Dream_SetTooltipItemId(GameTooltip, ItemShopAtButton[i]:GetID());
		GameTooltip:AddLine("|cFF00FF00点击图标可预览武器装备|r")
        GameTooltip:Show();
    end)

    ItemTitleButton[i]:SetScript("OnLeave",
    function(self)
        GameTooltip:Hide();
    end)

	ItemTitleButton[i]:SetScript("OnClick",
    function(self)
		ModelFrame_ShowPlayerUpdate(ItemShopAtButton[i]:GetID());
    end)
end

--预览模型
local ShopModelFrame = CreateFrame("Frame", nil, ItemShopFrame)
ShopModelFrame:SetSize(400, 360)
ShopModelFrame:SetPoint("LEFT", -400, 0)
ShopModelFrame:Hide()

-- Background texture
ShopModelFrame.Background = ShopModelFrame:CreateTexture(nil, "BACKGROUND")
ShopModelFrame.Background:SetSize(ShopModelFrame:GetSize())
ShopModelFrame.Background:SetPoint("CENTER", ShopModelFrame, "CENTER")
ShopModelFrame:SetBackdrop(
	{
		bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
		edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
		edgeSize = 12,
		insets = { left = 3, right = 3, top = 3, bottom = 3 }
	});

ShopModelFrame:SetScript(
	"OnHide",
	function()

	end
)

ShopModelFrame:SetScript(
	"OnShow",
	function()

	end
)

ShopModelFrame.CloseButton = CreateFrame("Button", nil, ShopModelFrame, "UIPanelCloseButton")
ShopModelFrame.CloseButton:SetSize(28, 28)
ShopModelFrame.CloseButton:SetPoint("TOPRIGHT", ShopModelFrame, "TOPRIGHT", 4, 3)
ShopModelFrame.CloseButton:EnableMouse(true)
ShopModelFrame.CloseButton:SetScript(
	"OnClick",
	function()
		ShopModelFrame:Hide()
	end
)

ShopModelFrame.playerModel = CreateFrame("DressUpModel", nil, ShopModelFrame)
ShopModelFrame.playerModel:SetPoint("CENTER", ShopModelFrame, "CENTER", 0, 1)
ShopModelFrame.playerModel:SetSize(360, 300)


local turnSpeed = 34
local zoomSpeed = 0.5
ShopModelFrame.playerModel:SetPosition(0, 0, 0)
ShopModelFrame.playerModel:EnableMouse(true)
ShopModelFrame.playerModel:EnableMouseWheel(true)
ShopModelFrame.playerModel:SetScript(
	"OnMouseDown",
	function(self, button)
		local startPos = {
			GetCursorPosition()
		}
		if button == "LeftButton" then
			self:SetScript(
				"OnUpdate",
				function(self)
					local curX = ({
						GetCursorPosition()
					})[1]
					self:SetFacing(
						((curX - startPos[1]) / turnSpeed) + self:GetFacing()
					)
					startPos[1] = curX
				end
			)
		end
	end
)

ShopModelFrame.playerModel:SetScript(
	"OnMouseUp",
	function(self, button)
		self:SetScript("OnUpdate", nil)
	end
)

ShopModelFrame.playerModel:SetScript(
	"OnMouseWheel",
	function(self, zoom)
		local pos = {
			self:GetPosition()
		}
		if zoom == 1 then
			pos[1] = pos[1] + zoomSpeed
		else
			pos[1] = pos[1] - zoomSpeed
		end

		if (pos[1] > 1) then
			pos[1] = 1
		elseif (pos[1] < -0.5) then
			pos[1] = -0.5
		end

		self:SetPosition(pos[1], pos[2], pos[3])
	end
)

ShopModelFrame.leftButton = CreateFrame("Button", nil, ShopModelFrame)
ShopModelFrame.leftButton:SetSize(35, 35)
ShopModelFrame.leftButton:SetFrameLevel(ShopModelFrame:GetFrameLevel() + 2)
ShopModelFrame.leftButton:SetPoint("CENTER", ShopModelFrame, "BOTTOM", -30, 40)
ShopModelFrame.leftButton:SetNormalTexture("Interface\\buttons\\ui-rotationleft-button-up")
ShopModelFrame.leftButton:SetHighlightTexture("Interface\\buttons\\ui-common-mousehilight")
ShopModelFrame.leftButton:SetPushedTexture("Interface\\buttons\\ui-rotationleft-button-down")

ShopModelFrame.leftButton:SetScript(
	"OnMouseDown",
	function(self, button)
		PlaySound("igInventoryRotateCharacter")
		self:SetScript(
			"OnUpdate",
			function(self, elapsed)
				if (ShopModelFrame.playerModel:IsShown()) then
					ShopModelFrame.playerModel:SetFacing(ShopModelFrame.playerModel:GetFacing() + 0.03)
				end
			end
		)
	end
)

ShopModelFrame.leftButton:SetScript(
	"OnMouseUp",
	function(self, button)
		self:SetScript("OnUpdate", nil)
	end
)

-- Rotate right button
ShopModelFrame.rightButton = CreateFrame("Button", nil, ShopModelFrame)
ShopModelFrame.rightButton:SetSize(35, 35)
ShopModelFrame.rightButton:SetFrameLevel(ShopModelFrame:GetFrameLevel() + 2)
ShopModelFrame.rightButton:SetPoint("CENTER", ShopModelFrame, "BOTTOM", 30, 40)
ShopModelFrame.rightButton:SetNormalTexture("Interface\\buttons\\ui-rotationright-button-up")
ShopModelFrame.rightButton:SetHighlightTexture("Interface\\buttons\\ui-common-mousehilight")
ShopModelFrame.rightButton:SetPushedTexture("Interface\\buttons\\ui-rotationright-button-down")

ShopModelFrame.rightButton:SetScript(
	"OnMouseDown",
	function(self, button)
		PlaySound("igInventoryRotateCharacter")
		self:SetScript(
			"OnUpdate",
			function(self, elapsed)
				if (ShopModelFrame.playerModel:IsShown()) then
					ShopModelFrame.playerModel:SetFacing(ShopModelFrame.playerModel:GetFacing() - 0.03)
				end
			end
		)
	end
)

ShopModelFrame.rightButton:SetScript(
	"OnMouseUp",
	function(self, button)
		self:SetScript("OnUpdate", nil)
	end
)

function ModelFrame_ShowPlayerUpdate(displayId)
	ShopModelFrame.playerModel:Hide()
	ShopModelFrame:Hide()

	if(displayId > 0) then
		local _, ItemLink, _, _, _, ItemType = Dream_GetItemInfoOnce(displayId);
		if (ItemLink and (ItemType == "武器" or ItemType == "护甲")) then
			ShopModelFrame.playerModel:SetUnit("player")
			ShopModelFrame.playerModel:Show()
			ShopModelFrame:Show()
			ShopModelFrame.playerModel:TryOn(displayId)
		end
	end
end

local ItemShopPreButton = CreateFrame("Button", "ItemShopPreButton", ItemShopFrame)
ItemShopPreButton:SetPoint("BOTTOM", -160, 30)
ItemShopPreButton:EnableMouse(true)
ItemShopPreButton:SetSize(100, 30)
ItemShopPreButton:SetBackdrop({ bgFile = NormalBtnIcon })
ItemShopPreButton:SetHighlightTexture("Interface\\Buttons\\UI-Panel-MinimizeButton-Highlight")
local ItemShopPreButtonStr = ItemShopPreButton:CreateFontString("ItemShopPreButtonStr");
ItemShopPreButtonStr:SetFont(Dream_GameFont, 15);
ItemShopPreButton:SetFontString(ItemShopPreButtonStr);
ItemShopPreButton:SetText("|cffFFC125上一页|r");

local ItemShopNextButton = CreateFrame("Button", "ItemShopNextButton", ItemShopFrame)
ItemShopNextButton:SetPoint("BOTTOM", 160, 30)
ItemShopNextButton:EnableMouse(true)
ItemShopNextButton:SetSize(100, 30)
ItemShopNextButton:SetBackdrop({ bgFile = NormalBtnIcon })
ItemShopNextButton:SetHighlightTexture("Interface\\Buttons\\UI-Panel-MinimizeButton-Highlight")
local ItemShopNextButtonStr = ItemShopNextButton:CreateFontString("ItemShopNextButtonStr");
ItemShopNextButtonStr:SetFont(Dream_GameFont, 15);
ItemShopNextButton:SetFontString(ItemShopNextButtonStr);
ItemShopNextButton:SetText("|cffFFC125下一页|r");

--上一页发包
ItemShopPreButton:SetScript("OnClick",
function(self)
	if (SelectPage <= 1) then
	    SelectPage = 1;
		return;
	end

	SelectPage = SelectPage - 1;
	Dream_SendData("GetShopTabPage", tostring(SelectTab).."#"..tostring(SelectPage));
end)

--下一页发包
ItemShopNextButton:SetScript("OnClick",
function(self)
	if (SelectPage >= MaxPageForTab) then
	    SelectPage = MaxPageForTab;
		return;
	end

	SelectPage = SelectPage + 1;
	Dream_SendData("GetShopTabPage", tostring(SelectTab).."#"..tostring(SelectPage));
end)

local SearchText = ItemShopFrame:CreateFontString("SearchText");
SearchText:SetFont(Dream_GameFont, 15);
SearchText:SetPoint("TOP", -160, -130);
SearchText:SetText("|cFF00FF00搜索 [ ID或名称 · 支持模糊搜索 ]|r");

--搜索
local SearchEditBox = CreateFrame("EditBox", "SearchEditBox", ItemShopFrame, "InputBoxTemplate");
SearchEditBox:SetSize(180, 24)
SearchEditBox:SetAutoFocus(false)
SearchEditBox:SetPoint("TOP", 100, -125)
SearchEditBox:SetScript("OnEnterPressed", SearchEditBox.ClearFocus)
SearchEditBox:SetScript("OnEscapePressed", SearchEditBox.ClearFocus)

local SearchButton = CreateFrame("Button", "SearchButton", ItemShopFrame);
SearchButton:SetSize(100, 30);
SearchButton:SetPoint("TOP", 240, -122)
SearchButton:SetBackdrop({ bgFile = NormalBtnIcon })
SearchButton:SetHighlightTexture("Interface\\Buttons\\UI-Panel-MinimizeButton-Highlight")
SearchButton:EnableMouse(true);
SearchButton:SetScript("OnClick",
function(self)
    local Search = SearchEditBox:GetText();
	if (Search == "") then
	    return;
	end
	Dream_SendData("SearchShop", Search);
end)

local SearchStr = SearchButton:CreateFontString("SearchStr");
SearchStr:SetFont(Dream_GameFont, 14);
SearchButton:SetFontString(SearchStr);
SearchButton:SetText("|cffFFC125搜索|r");

--消息处理
local function Dream_OnShopAddonEvent(Self, event, Packet, Msg, Type, Sender)
    if (event == "CHAT_MSG_ADDON") then
		--商城
		if (Packet == "ShowTabName") then
		    ApplyTabName(Msg);
		elseif (Packet == "ShowShopTabPage") then
		    ApplyShopTabPage(Msg);
		elseif (Packet == "ShowSearchShop") then
		    ApplyShopSearch(Msg);
		elseif (Packet == "ShowBuyNeedInfo") then
		    ApplyBuyNeedInfo(Msg);
		elseif (Packet == "CloseItemShopFrame") then
		    if (ItemShopFrame:IsShown()) then
			    ItemShopFrame:Hide();
			    ItemShopFrame:Show();
			end
		end
	elseif (event == "PLAYER_LOGIN") then
	    Dream_SendData("GetShopTabName");
	end
end

--交互消息事件
local ShopAddonFrame = CreateFrame("Frame", "ShopAddonFrame");
ShopAddonFrame:RegisterEvent("CHAT_MSG_ADDON");
ShopAddonFrame:RegisterEvent("PLAYER_LOGIN");
ShopAddonFrame:SetScript("OnEvent", Dream_OnShopAddonEvent);

