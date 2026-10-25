
DressItemId = 0;

--静态弹出框
StaticPopupDialogs["DressTransOneNow"] = {

	text = "%s",
	button1 = "确定",
	button2 = "取消",

	OnAccept = function(Self)
        Dream_SendData("AcceptDressItemOne", Self.ItemIdStr);
	end,

	OnCancel = function(Self)

	end,

	OnShow = function(Self)

	end,

	exclusive = true,
	whileDead = true,
	hideOnEscape = true,
	timeout = 0,
};

DressUpFrame:SetScript("OnShow",
function(Self)
    Self:SetAlpha(1.0);
end);

--试衣间幻化按钮
local DressTransOne = CreateFrame("Button", "DressTransOne", DressUpFrame);
DressTransOne:SetPoint("BOTTOM", -100, 78);
DressTransOne:EnableMouse(true);
DressTransOne:SetSize(120, 25);
DressTransOne:SetBackdrop({ bgFile = NormalBtnIcon })
DressTransOne:SetHighlightTexture("Interface\\Buttons\\UI-Panel-MinimizeButton-Highlight")

local StringDressTransOne = DressTransOne:CreateFontString("StringDressTransOne");
StringDressTransOne:SetFont(Dream_GameFont, 15);
DressTransOne:SetFontString(StringDressTransOne);
DressTransOne:SetText("|cffFFC125点击幻化|r");

DressTransOne:SetScript("OnClick",
function(self)
	if (DressItemId == 0) then
		return;
	end

	Dream_SendData("DressTransItemInfo", tostring(DressItemId));
end)

--消息处理
local function Dream_OnDressItemEvent(Self, event, Packet, Msg, Type, Sender)
    if (event == "CHAT_MSG_ADDON") then
		if (Packet == "NowDressTransItemNeedInfo") then
			local Args = Dream_Split(Msg, "#");
			local ItemIdStr = Args[1];
			local NeedGts = Args[2];
			local Dialog = StaticPopup_Show("DressTransOneNow", "\n|cFF00FF00幻化|r\n\n"..NeedGts.."\n|r\n|cFF00FF00你确定要这么做吗?|r");
			Dialog.ItemIdStr = ItemIdStr;
			DressUpFrame:SetAlpha(0.6);
			Dialog:SetScript("OnHide",
            function(self)
    		    DressUpFrame:SetAlpha(1.0);
            end)
		end
	elseif (event == "PLAYER_LOGIN") then

	end
end

--交互消息事件
local DressItemFrame = CreateFrame("Frame", "DressItemFrame");
DressItemFrame:RegisterEvent("CHAT_MSG_ADDON");
DressItemFrame:RegisterEvent("PLAYER_LOGIN");
DressItemFrame:SetScript("OnEvent", Dream_OnDressItemEvent);

--------------------------------------------------------------------


