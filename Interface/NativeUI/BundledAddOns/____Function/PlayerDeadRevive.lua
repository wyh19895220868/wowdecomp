---@diagnostic disable: missing-parameter

local AliveCount = 0;
local OnAliveDead = true;

local ReviveFrame = CreateFrame("Frame", "ReviveFrame", UIParent)
ReviveFrame:SetSize(300, 300)
ReviveFrame:SetBackdrop({ bgFile = "Interface\\Icons\\Revive" });
ReviveFrame:SetPoint("CENTER",0,0)
ReviveFrame:Hide()

ReviveFrame:SetScript("OnHide",
function(self)
    StaticPopup_Hide("ReviveMe");
end)

local ReviveClose = CreateFrame("Button", "ReviveClose", ReviveFrame, "UIPanelCloseButton");
ReviveClose:SetPoint("TOPRIGHT", -5, -5)
ReviveClose:EnableMouse(true);
ReviveClose:SetSize(30, 30);

local ReviveRightButton = CreateFrame("Button", "ReviveRightButton", ReviveFrame, "UIPanelButtonTemplate")
ReviveRightButton:SetSize(100, 30)
ReviveRightButton:SetPoint("BOTTOMRIGHT", -45, 30)
ReviveRightButton:EnableMouse(true)

local ReviveRightButtonStr = ReviveRightButton:CreateFontString("ReviveRightButtonStr")
ReviveRightButtonStr:SetFont(Dream_GameFont, 15)
ReviveRightButton:SetFontString(ReviveRightButtonStr)
ReviveRightButton:SetText("免费|cFF00FF00["..AliveCount.."次]|r")

local ReviveLeftButton = CreateFrame("Button", "ReviveLeftButton", ReviveFrame, "UIPanelButtonTemplate")
ReviveLeftButton:SetSize(100, 30)
ReviveLeftButton:SetPoint("BOTTOMLEFT", 45, 30)
ReviveLeftButton:EnableMouse(true)

local ReviveLeftButtonStr = ReviveLeftButton:CreateFontString("ReviveLeftButtonStr")
ReviveLeftButtonStr:SetFont(Dream_GameFont, 15)
ReviveLeftButton:SetFontString(ReviveLeftButtonStr)
ReviveLeftButton:SetText("涅槃重生")

--静态弹出框
StaticPopupDialogs["ReviveMe"] = {

	text = "%s",
	button1 = "接受",
	button2 = "拒绝",

	OnAccept = function(Self)
        Dream_SendData("ReviveReset");
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

function ApplyReviveMeInfo(Msg)
	StaticPopup_Show("ReviveMe", "\n|cFF00FF00[涅槃重生]|r\n"..Msg.."|cFF00FF00你确定要这么做吗?|r");
end

ReviveRightButton:SetScript("OnClick",
function(self)

	Dream_SendData("ReviveRequest");
end)

ReviveLeftButton:SetScript("OnClick",
function(self)

	Dream_SendData("ReqReviveMe");
end)

function ApplyAliveData(Msg)
    AliveCount = tonumber(Msg);
	ReviveRightButton:SetText("免费|cFF00FF00["..AliveCount.."次]|r")
end

function ApplyAliveFrame(Apply)
    if (Apply) then
        ReviveFrame:Show();
	else
        ReviveFrame:Hide();
	end
end

--消息处理
local function Dream_OnReviveAddonEvent(Self, event, Packet, Msg, Type, Sender)
    if (event == "CHAT_MSG_ADDON") then
		--复活
		if (Packet == "PlayerAliveData") then
		    ApplyAliveData(Msg);
		elseif (Packet == "SendReviveMe") then
		    ApplyReviveMeInfo(Msg);
		elseif (Packet == "OnPlayerAliveDead") then
			OnAliveDead = (tonumber(Msg) > 0);
		end
	elseif (event == "PLAYER_LOGIN") then
		Dream_SendData("GetAliveData");
	elseif (event == "PLAYER_DEAD") then
		if (OnAliveDead) then
			ApplyAliveFrame(true);
		end
	elseif (event == "PLAYER_ALIVE") then
		if (OnAliveDead) then
			ApplyAliveFrame(false);
		end
	end
end

--交互消息事件
local ReviveAddonFrame = CreateFrame("Frame", "ReviveAddonFrame");
ReviveAddonFrame:RegisterEvent("CHAT_MSG_ADDON");
ReviveAddonFrame:RegisterEvent("PLAYER_LOGIN");
ReviveAddonFrame:RegisterEvent("PLAYER_DEAD");
ReviveAddonFrame:RegisterEvent("PLAYER_ALIVE");
ReviveAddonFrame:SetScript("OnEvent", Dream_OnReviveAddonEvent);

