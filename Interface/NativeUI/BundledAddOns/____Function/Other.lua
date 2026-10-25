
--拍卖行类型
CustomAuctionType = 1;
CustomAItemLink = "";

function Dream_ForceReload()
	local ReFrame = CreateFrame("BUTTON");
	ReFrame:SetToplevel(true);
	ReFrame:SetFrameStrata("TOOLTIP");
	ReFrame:SetFrameLevel(100);
	ReFrame:SetAllPoints(WorldFrame);
	ReFrame:SetScript("OnClick", ReloadUI);
end

--消息处理
local function Dream_OnOtherEvent(Self, event, Packet, Msg, Type, Sender)
    if (event == "CHAT_MSG_ADDON") then
		if (Packet == "AuctionHouseInfo") then
			CloseAuctionHouse();
			local Args = Dream_Split(Msg, "#");
		    CustomAuctionType = tonumber(Args[1]);
			CustomAItemLink = Args[2];
		elseif (Packet == "LoginUpdateUI") then
			DEFAULT_CHAT_FRAME:AddMessage("|cffFFC125[界面提示]: 由于在副本掉线小退 需要点击一下屏幕重载界面 卡背包物品需要切换地图读条即可|r");
			Dream_ForceReload();
		elseif (Packet == "ResponsePlayerName") then
			SetCVar("UnitNameOwn", 0);
			SetCVar("UnitNameOwn", 1);
			SetCVar("UnitNameFriendlyPlayerName", 0);
			SetCVar("UnitNameFriendlyPlayerName", 1);
			SetCVar("UnitNameEnemyPlayerName", 0);
			SetCVar("UnitNameEnemyPlayerName", 1);
		end
	elseif (event == "PLAYER_LOGIN") then
		Dream_SendData("GetAuctionHouseInfo");
	end
end

--交互消息事件
local OtherFrame = CreateFrame("Frame", "OtherFrame");
OtherFrame:RegisterEvent("CHAT_MSG_ADDON");
OtherFrame:RegisterEvent("PLAYER_LOGIN");
OtherFrame:SetScript("OnEvent", Dream_OnOtherEvent);

--------------------------------------------------------------------


