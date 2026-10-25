
--静态弹出框
StaticPopupDialogs["BuyInfoItem"] = {

	text = "%s",
	button1 = "确定",
	button2 = "取消",
	
	OnAccept = function(Self)
        Dream_SendData("AcceptBuyInfoItem");
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

--消息处理
local function Dream_OnItemVsInfoAddonEvent(Self, event, Packet, Msg, Type, Sender)
    if (event == "CHAT_MSG_ADDON") then
		--购买
		if (Packet == "PopBuyInfoItem") then
            local Args = Dream_Split(Msg, "#");
            StaticPopup_Show("BuyInfoItem", "\n|cFF00FF00购买|r\n\n"..Args[1].."\n"..Args[2].."|r\n|cFF00FF00你确定要这么做吗?|r");
		end
	elseif (event == "PLAYER_LOGIN") then
	    
	end
end

--交互消息事件
local ItemVsInfoAddonFrame = CreateFrame("Frame", "ItemVsInfoAddonFrame");
ItemVsInfoAddonFrame:RegisterEvent("CHAT_MSG_ADDON");
ItemVsInfoAddonFrame:RegisterEvent("PLAYER_LOGIN");
ItemVsInfoAddonFrame:SetScript("OnEvent", Dream_OnItemVsInfoAddonEvent);