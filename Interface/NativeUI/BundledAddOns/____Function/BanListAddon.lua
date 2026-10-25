
--插件禁用
local OnBanList ={
	"Tooltip",
	"GearScore",
	"Item",
    "Rating",
    "鼠标",
    "装备",
    "Tip",
    "tip",
	"信息",
	"自定义核心综合插件",
	"饰品管理",
	"aaAddon",
	"家园魔兽专用插件",
	"GhostCore",
	"艾泽拉斯的遗产",
	"AY",
	"YafisTools",
	"Mendeleev",
};

function DoCheckAddonBan(name, title)
	-- 独立装备锻造插件由本核心提供，不能被通用的 "Item"/"装备" 关键字误禁用。
	if name == "ItemForgeUI" then
		return false;
	end

	for k,v in pairs(OnBanList) do
		if string.find(name,v) then
			return true;
		end
	end

	for k,v in pairs(OnBanList) do
		if string.find(title,v) then
			return true;
		end
	end

	return false;
end

function DoBanAddon()
	for i=1, GetNumAddOns() do
		local name, title, notes, enabled, loadable, reason, security = GetAddOnInfo(i);
		if enabled and DoCheckAddonBan(name, title) then
			DisableAddOn(i);
		end
	end
end

local BanFrame = CreateFrame("Frame", "BanFrame");
BanFrame:RegisterEvent("PLAYER_LOGIN");
BanFrame:SetScript("OnEvent", function(self, event, ...) DoBanAddon(); end);
