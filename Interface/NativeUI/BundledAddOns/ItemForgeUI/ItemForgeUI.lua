local ADDON_NAME = "ItemForgeUI"
local ENHANCE_PREFIX = "IENH"
local GROWTH_PREFIX = "IGRO"
local RUNE_PREFIX = "IRUN"
local REFINE_PREFIX = "IREF"
local IDENTIFICATION_PREFIX = "UITQ"

local function ItemForge_GetItemInfo(Entry)
    if Dream_GetItemInfoOnce then
        return Dream_GetItemInfoOnce(Entry)
    end
    return nil
end

local function ItemForge_SetItemTooltip(Tooltip, EntryOrLink)
    if not Tooltip then return false end
    if type(EntryOrLink) == "string" and string.find(EntryOrLink, "item:", 1, true) then
        if Dream_SetTooltipHyperlink then
            return Dream_SetTooltipHyperlink(Tooltip, EntryOrLink)
        end
        return false
    end
    if Dream_SetTooltipItemId then
        return Dream_SetTooltipItemId(Tooltip, EntryOrLink)
    end
    return false
end

ItemForgeUI = ItemForgeUI or {}
local UI = ItemForgeUI

UI.frame = nil
UI.launcherButton = nil
UI.selected = nil
UI.activeTab = "enhance"
UI.lastPickedLocation = nil
UI.pickupHooksInstalled = false
UI.modifiedClickHooksInstalled = false
UI.selectedRuneSlot = nil
UI.selectedRuneItemId = nil
UI.runeBagPage = 1
UI.recycleLevels = {}
UI.recycleLevel = 0
UI.data = {
    enhance = { level = 0, canUse = false, status = "", attrs = "" },
    growth = { level = 0, exp = 0, required = 0, canUse = false, status = "", attrs = "", percentAttrs = "" },
    rune = { total = 0, filled = 0, status = "", slots = {}, bagRunes = {} },
    refine = { canUse = false, requirementId = 0, categories = {}, materials = {}, currentEnchants = "", comparison = nil, status = "" }
}

local STAT_NAMES = {
    [0] = "法力值", [1] = "生命值", [2] = "护甲", [3] = "敏捷", [4] = "力量", [5] = "智力", [6] = "精神", [7] = "耐力",
    [12] = "防御等级", [13] = "躲闪等级", [14] = "招架等级", [15] = "格挡等级",
    [16] = "近战命中", [17] = "远程命中", [18] = "法术命中", [19] = "近战暴击", [20] = "远程暴击", [21] = "法术暴击",
    [22] = "近战命中回避", [23] = "远程命中回避", [24] = "法术命中回避", [25] = "近战致命回避", [26] = "远程致命回避", [27] = "法术致命回避",
    [28] = "近战急速", [29] = "远程急速", [30] = "法术急速", [33] = "命中回避等级", [34] = "致命回避等级",
    [31] = "命中等级", [32] = "暴击等级", [35] = "韧性等级", [36] = "急速等级", [37] = "精准等级",
    [38] = "攻击强度", [39] = "远程强度", [40] = "形态攻击强度", [41] = "法术治疗", [42] = "法术伤害", [43] = "法力恢复", [44] = "护甲穿透", [45] = "法术强度", [46] = "生命恢复", [47] = "法术穿透", [48] = "格挡值"
    , [120] = "武器速度", [121] = "武器伤害", [122] = "每秒伤害",
    [123] = "神圣最小伤害", [124] = "神圣最大伤害", [125] = "火焰最小伤害", [126] = "火焰最大伤害",
    [127] = "自然最小伤害", [128] = "自然最大伤害", [129] = "冰霜最小伤害", [130] = "冰霜最大伤害",
    [131] = "暗影最小伤害", [132] = "暗影最大伤害", [133] = "奥术最小伤害", [134] = "奥术最大伤害",
    [135] = "护甲", [136] = "格挡值", [137] = "物品等级",
    [150] = "神圣抗性", [151] = "火焰抗性", [152] = "自然抗性", [153] = "冰霜抗性", [154] = "暗影抗性", [155] = "奥术抗性",
    [200] = "PVP物理伤害%", [201] = "PVP物理伤害", [202] = "PVP魔法伤害%", [203] = "PVP魔法伤害",
    [204] = "PVP治疗效果%", [205] = "PVP治疗效果", [206] = "PVP物理减伤%", [207] = "PVP物理减伤",
    [208] = "PVP魔法减伤%", [209] = "PVP魔法减伤", [210] = "PVP受到治疗%", [211] = "PVP受到治疗",
    [212] = "PVP吸血%", [213] = "PVP吸血", [214] = "PVP魔法暴伤%", [215] = "PVP魔法暴伤",
    [216] = "PVP物理暴伤%", [217] = "PVP物理暴伤", [218] = "PVP物理反弹%", [219] = "PVP物理反弹",
    [220] = "PVP魔法反弹%", [221] = "PVP魔法反弹", [222] = "PVP真实伤害%",
    [223] = "PVP魔法暴伤减免", [224] = "PVP魔法暴伤减免%", [225] = "PVP物理暴伤减免", [226] = "PVP物理暴伤减免%",
    [227] = "PVP固定切割", [228] = "PVP固定切割几率%", [229] = "PVP百分比切割", [230] = "PVP百分比切割几率%",
    [300] = "PVE物理伤害", [301] = "PVE物理伤害%", [302] = "PVE魔法伤害", [303] = "PVE魔法伤害%",
    [304] = "PVE治疗效果", [305] = "PVE治疗效果%", [306] = "PVE物理减伤", [307] = "PVE物理减伤%",
    [308] = "PVE魔法减伤", [309] = "PVE魔法减伤%", [310] = "PVE受到治疗", [311] = "PVE受到治疗%",
    [312] = "PVE吸血", [313] = "PVE吸血%", [314] = "PVE魔法暴伤", [315] = "PVE魔法暴伤%",
    [316] = "PVE物理暴伤", [317] = "PVE物理暴伤%", [318] = "PVE物理反弹", [319] = "PVE物理反弹%",
    [320] = "PVE魔法反弹", [321] = "PVE魔法反弹%", [322] = "PVE真实伤害",
    [323] = "PVE魔法暴伤减免%", [324] = "PVE魔法暴伤减免", [325] = "PVE物理暴伤减免%", [326] = "PVE物理暴伤减免",
    [327] = "PVE固定切割", [328] = "PVE固定切割几率%", [329] = "PVE百分比切割%", [330] = "PVE百分比切割几率%",
    [400] = "经验获取%", [401] = "掉宝几率%", [402] = "多倍掉宝倍率", [403] = "多倍掉宝几率%"
}

local RUNE_QUALITY_COLORS = {
    [0] = { r = 0.75, g = 0.75, b = 0.75 },
    [1] = { r = 0.1, g = 1.0, b = 0.1 },
    [2] = { r = 0.0, g = 0.45, b = 1.0 },
    [3] = { r = 0.65, g = 0.25, b = 1.0 },
    [4] = { r = 1.0, g = 0.5, b = 0.0 },
}

local RUNE_MAX_VISIBLE_SLOTS = 20
local RUNE_BAG_PAGE_SIZE = 8

local function GetDB()
    ItemForgeUIDB = ItemForgeUIDB or {}
    if ItemForgeUIDB.launcherX == nil then
        ItemForgeUIDB.launcherX = -360
    end
    if ItemForgeUIDB.launcherY == nil then
        ItemForgeUIDB.launcherY = 120
    end
    return ItemForgeUIDB
end

local function Atan2(y, x)
    if math.atan2 then
        return math.atan2(y, x)
    end
    if x > 0 then
        return math.atan(y / x)
    elseif x < 0 and y >= 0 then
        return math.atan(y / x) + math.pi
    elseif x < 0 and y < 0 then
        return math.atan(y / x) - math.pi
    elseif x == 0 and y > 0 then
        return math.pi / 2
    elseif x == 0 and y < 0 then
        return -math.pi / 2
    end
    return 0
end

local function Split(text, sep)
    local result = {}
    text = tostring(text or "")
    sep = sep or "|"
    local start = 1
    while true do
        local pos = string.find(text, sep, start, true)
        if not pos then
            table.insert(result, string.sub(text, start))
            break
        end
        table.insert(result, string.sub(text, start, pos - 1))
        start = pos + string.len(sep)
    end
    return result
end

local function RegisterPrefix(prefix)
    if RegisterAddonMessagePrefix then
        RegisterAddonMessagePrefix(prefix)
    elseif C_ChatInfo and C_ChatInfo.RegisterAddonMessagePrefix then
        C_ChatInfo.RegisterAddonMessagePrefix(prefix)
    end
end

local function SendAddon(prefix, message)
    local playerName = UnitName("player")
    if not playerName then return end

    if C_ChatInfo and C_ChatInfo.SendAddonMessage then
        C_ChatInfo.SendAddonMessage(prefix, message, "WHISPER", playerName)
    else
        SendAddonMessage(prefix, message, "WHISPER", playerName)
    end
end

local function ParseItemId(link)
    if not link then return nil end
    return tonumber(string.match(link, "item:(%d+)"))
end

local function GetItemIdFromLinkOrId(value)
    if type(value) == "number" then return value end
    return ParseItemId(value)
end

local function SameItem(link, itemId, wantedLink)
    if wantedLink and link == wantedLink then
        return true
    end
    return itemId and ParseItemId(link) == itemId
end

local function FindItemLocation(itemId, wantedLink)
    for inv = 1, 19 do
        local link = GetInventoryItemLink("player", inv)
        if SameItem(link, itemId, wantedLink) then
            return { itemId = ParseItemId(link) or itemId, link = link, bag = -1, slot = inv, equip = 1 }
        end
    end

    for bag = 0, 4 do
        local count = GetContainerNumSlots and GetContainerNumSlots(bag) or 0
        for slot = 1, count do
            local link = GetContainerItemLink(bag, slot)
            if SameItem(link, itemId, wantedLink) then
                return { itemId = ParseItemId(link) or itemId, link = link, bag = bag, slot = slot, equip = 0 }
            end
        end
    end

    return nil
end

local function CaptureCursorItemLocation(bag, slot, equip)
    local cursorType, value1, value2 = GetCursorInfo()
    if cursorType ~= "item" then return end

    local link = type(value2) == "string" and value2 or (type(value1) == "string" and value1 or nil)
    local itemId = GetItemIdFromLinkOrId(link) or GetItemIdFromLinkOrId(value1) or GetItemIdFromLinkOrId(value2)
    if not itemId then return end

    UI.lastPickedLocation = {
        itemId = itemId,
        link = link,
        bag = bag,
        slot = slot,
        equip = equip and 1 or 0
    }
end

local function InstallPickupHooks()
    if UI.pickupHooksInstalled then return end
    UI.pickupHooksInstalled = true

    if hooksecurefunc then
        if type(PickupContainerItem) == "function" then
            hooksecurefunc("PickupContainerItem", function(bag, slot)
                CaptureCursorItemLocation(bag, slot, false)
            end)
        end
        if type(PickupInventoryItem) == "function" then
            hooksecurefunc("PickupInventoryItem", function(slot)
                CaptureCursorItemLocation(-1, slot, true)
            end)
        end
    end
end

local function OpenRuneUIForLocation(location)
    if not location or not location.itemId then return end

    UI:CreateFrame()
    UI.frame:Show()
    UI:SetActiveTab("rune")
    UI:SetSelected(location)
    UI:SetActiveTab("rune")
end

local function TryOpenRuneFromContainerButton(button, mouseButton)
    if mouseButton ~= "RightButton" or not IsShiftKeyDown or not IsShiftKeyDown() then return end
    if not button or not button.GetParent or not button.GetID then return end

    local parent = button:GetParent()
    local bag = parent and parent.GetID and parent:GetID()
    local slot = button:GetID()
    if bag == nil or not slot then return end

    local link = GetContainerItemLink and GetContainerItemLink(bag, slot)
    local itemId = ParseItemId(link)
    if not itemId then return end

    OpenRuneUIForLocation({ itemId = itemId, link = link, bag = bag, slot = slot, equip = 0 })
end

local function TryOpenRuneFromInventoryButton(button, mouseButton)
    if mouseButton ~= "RightButton" or not IsShiftKeyDown or not IsShiftKeyDown() then return end
    if not button or not button.GetID then return end

    local slot = button:GetID()
    local link = GetInventoryItemLink and GetInventoryItemLink("player", slot)
    local itemId = ParseItemId(link)
    if not itemId then return end

    OpenRuneUIForLocation({ itemId = itemId, link = link, bag = -1, slot = slot, equip = 1 })
end

local function InstallModifiedClickHooks()
    if UI.modifiedClickHooksInstalled then return end
    UI.modifiedClickHooksInstalled = true

    if not hooksecurefunc then return end
    if type(ContainerFrameItemButton_OnModifiedClick) == "function" then
        hooksecurefunc("ContainerFrameItemButton_OnModifiedClick", TryOpenRuneFromContainerButton)
    end
    if type(PaperDollItemSlotButton_OnModifiedClick) == "function" then
        hooksecurefunc("PaperDollItemSlotButton_OnModifiedClick", TryOpenRuneFromInventoryButton)
    end
end

local function FormatAttrs(attrs)
    if not attrs or attrs == "" then
        return "无"
    end

    local lines = {}
    for part in string.gmatch(attrs, "([^,]+)") do
        local stat, value = string.match(part, "^%s*(%d+)%s+([%-]?%d+)")
        stat = tonumber(stat)
        if stat and value then
            table.insert(lines, "|cffffffff" .. (STAT_NAMES[stat] or ("属性" .. stat)) .. "|r |cff40ff40+" .. value .. "|r")
        end
    end

    if #lines == 0 then
        return attrs
    end
    return table.concat(lines, "\n")
end

local function PositionLauncherButton(button)
    if not button or not UIParent then return end

    local db = GetDB()
    button:ClearAllPoints()
    button:SetPoint("CENTER", UIParent, "CENTER", db.launcherX or -360, db.launcherY or 120)
end

local function SetTextColorByQuality(font, quality)
    if quality and ITEM_QUALITY_COLORS and ITEM_QUALITY_COLORS[quality] then
        local c = ITEM_QUALITY_COLORS[quality]
        font:SetTextColor(c.r, c.g, c.b)
    else
        font:SetTextColor(1, 1, 1)
    end
end

local function GetRuneQualityColor(quality)
    quality = tonumber(quality) or 0
    if RUNE_QUALITY_COLORS[quality] then
        return RUNE_QUALITY_COLORS[quality]
    end
    if ITEM_QUALITY_COLORS and ITEM_QUALITY_COLORS[quality] then
        return ITEM_QUALITY_COLORS[quality]
    end
    return { r = 0.75, g = 0.75, b = 0.75 }
end

local function TrimText(text, limit)
    text = tostring(text or "")
    limit = limit or 24
    if string.len(text) > limit then
        return string.sub(text, 1, limit) .. "..."
    end
    return text
end

local function MakePanel(parent, name, x, y, w, h)
    local panel = CreateFrame("Frame", name, parent)
    panel:SetSize(w, h)
    panel:SetPoint("TOPLEFT", x, y)
    panel:SetBackdrop({
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true,
        tileSize = 16,
        edgeSize = 14,
        insets = { left = 4, right = 4, top = 4, bottom = 4 }
    })
    panel:SetBackdropColor(0.05, 0.05, 0.07, 0.86)
    panel:SetBackdropBorderColor(0.45, 0.35, 0.18, 0.9)
    return panel
end

local function MakeLine(parent, text, x, y, template)
    local line = parent:CreateFontString(nil, "OVERLAY", template or "GameFontHighlight")
    line:SetPoint("TOPLEFT", x, y)
    line:SetJustifyH("LEFT")
    line:SetJustifyV("TOP")
    line:SetText(text or "")
    return line
end

function UI:SetStatus(text, r, g, b)
    if self.frame and self.frame.status then
        self.frame.status:SetText(text or "")
        self.frame.status:SetTextColor(r or 0.9, g or 0.82, b or 0.55)
    end
end

StaticPopupDialogs["ITEMFORGEUI_BATCH_RECYCLE"] = {
    text = "确定批量回收背包内%s且配置了回收奖励的装备吗？\n\n装备栏、银行和其他鉴定等级的物品不会被处理。",
    button1 = ACCEPT,
    button2 = CANCEL,
    OnAccept = function(self)
        local identificationLevel = tonumber(self.recycleLevel or 0) or 0
        UI:SetStatus("正在批量回收背包装备...", 1, 0.82, 0.25)
        SendAddon(IDENTIFICATION_PREFIX, "RECYCLE_BATCH:" .. tostring(identificationLevel))
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    preferredIndex = 3
}

function UI:RequestBatchRecycle()
    local identificationLevel = tonumber(self.recycleLevel or 0) or 0
    local levelText = identificationLevel > 0 and ("鉴定等级 " .. tostring(identificationLevel)) or "全部鉴定等级"
    local dialog = StaticPopup_Show("ITEMFORGEUI_BATCH_RECYCLE", levelText)
    if dialog then
        dialog.recycleLevel = identificationLevel
    end
end

function UI:RefreshRecycleLevelDropdown()
    if not self.frame or not self.frame.recycleLevelDropDown then return end

    local selectedLevel = tonumber(self.recycleLevel or 0) or 0
    local text = selectedLevel > 0 and ("鉴定等级 " .. tostring(selectedLevel)) or "全部等级"
    UIDropDownMenu_SetSelectedValue(self.frame.recycleLevelDropDown, selectedLevel)
    UIDropDownMenu_SetText(self.frame.recycleLevelDropDown, text)
end

function UI:ApplyRecycleLevels(levelText)
    self.recycleLevels = {}
    for value in string.gmatch(levelText or "", "[^,]+") do
        local level = tonumber(value)
        if level and level > 0 then
            table.insert(self.recycleLevels, level)
        end
    end
    table.sort(self.recycleLevels)

    if (self.recycleLevel or 0) > 0 then
        local found = false
        for i = 1, #self.recycleLevels do
            if self.recycleLevels[i] == self.recycleLevel then
                found = true
                break
            end
        end
        if not found then
            self.recycleLevel = 0
        end
    end
    self:RefreshRecycleLevelDropdown()
end

function UI:SendModuleCommand(moduleName, command, extra)
    if not self.selected then
        self:SetStatus("请先把装备拖到左侧装备槽", 1, 0.25, 0.25)
        return
    end

    local prefix = moduleName == "growth" and GROWTH_PREFIX or (moduleName == "refine" and REFINE_PREFIX or ENHANCE_PREFIX)
    local msg = command .. "|" .. tostring(self.selected.itemId or 0) .. "|" .. tostring(self.selected.bag or -1) .. "|" .. tostring(self.selected.slot or -1) .. "|" .. tostring(self.selected.equip or 0)
    if moduleName == "refine" then
        local guid = tonumber(self.selected.guid or 0) or 0
        if guid <= 0 then
            return
        end
        msg = msg .. "|" .. tostring(guid)
    end
    if extra then msg = msg .. "|" .. tostring(extra) end
    SendAddon(prefix, msg)
end

function UI:SendRuneCommand(command, extra)
    if command ~= "BAG" and not self.selected then
        self:SetStatus("请先把装备拖到左侧装备槽", 1, 0.25, 0.25)
        return
    end

    local msg
    if command == "BAG" then
        msg = "BAG"
    else
        msg = command .. "|" .. tostring(self.selected.itemId or 0) .. "|" .. tostring(self.selected.bag or -1) .. "|" .. tostring(self.selected.slot or -1) .. "|" .. tostring(self.selected.equip or 0)
        if extra and extra ~= "" then
            msg = msg .. "|" .. extra
        end
    end
    SendAddon(RUNE_PREFIX, msg)
end

function UI:QuerySelected()
    if not self.selected then return end
    self:SendModuleCommand("enhance", "QUERY")
    self:SendModuleCommand("growth", "QUERY")
    self:SendRuneCommand("QUERY")
    self:SendModuleCommand("refine", "QUERY")
end

function UI:RefreshSelectedDisplay()
    if not self.frame then return end

    local f = self.frame
    if not self.selected then
        f.itemName:SetText("拖入一件装备")
        f.itemName:SetTextColor(1, 0.82, 0)
        f.itemHint:SetText("支持背包与已穿戴装备")
        f.itemIcon:SetTexture(nil)
        f.itemSlot:SetBackdropBorderColor(0.58, 0.44, 0.22, 0.95)
        self.data.enhance = { level = 0, canUse = false, status = "", attrs = "" }
        self.data.growth = { level = 0, exp = 0, required = 0, canUse = false, status = "", attrs = "", percentAttrs = "" }
        self.data.rune = { total = 0, filled = 0, status = "", slots = {}, bagRunes = {} }
        self.data.refine = { canUse = false, requirementId = 0, categories = {}, materials = {}, currentEnchants = "", comparison = nil, status = "" }
        self.selectedRuneSlot = nil
        self.selectedRuneItemId = nil
        self.runeBagPage = 1
        self:RefreshContent()
        return
    end

    local name, _, quality, _, _, _, _, _, _, texture = ItemForge_GetItemInfo(self.selected.link or self.selected.itemId)
    f.itemName:SetText(name or self.selected.link or ("物品ID " .. tostring(self.selected.itemId)))
    SetTextColorByQuality(f.itemName, quality)
    f.itemHint:SetText(self.selected.equip == 1 and "来源：装备栏" or ("来源：背包 " .. tostring(self.selected.bag) .. " / 格子 " .. tostring(self.selected.slot)))
    f.itemIcon:SetTexture(texture or "Interface\\Icons\\INV_Misc_QuestionMark")
    f.itemIcon:SetVertexColor(1, 1, 1, 1)
    f.itemSlot:SetBackdropBorderColor(1, 0.74, 0.22, 1)
end

function UI:ClearSelected(statusText)
    self.selected = nil
    self.lastPickedLocation = nil
    self.data.enhance = { level = 0, canUse = false, status = "", attrs = "" }
    self.data.growth = { level = 0, exp = 0, required = 0, canUse = false, status = "", attrs = "", percentAttrs = "" }
    self.data.rune = { total = 0, filled = 0, status = "", slots = {}, bagRunes = {} }
    self.data.refine = { canUse = false, requirementId = 0, categories = {}, materials = {}, currentEnchants = "", comparison = nil, status = "" }
    self.selectedRuneSlot = nil
    self.selectedRuneItemId = nil
    self.runeBagPage = 1
    self:RefreshSelectedDisplay()
    self:SetStatus(statusText or "")
end

function UI:SetSelected(location)
    self.selected = location
    self:RefreshSelectedDisplay()
    self:SetStatus("正在读取装备强化、成长与符文信息...", 1, 0.82, 0.25)
    self:QuerySelected()
end

function UI:PickCursorItem()
    local cursorType, value1, value2 = GetCursorInfo()
    if cursorType ~= "item" then return end

    local link = type(value2) == "string" and value2 or (type(value1) == "string" and value1 or nil)
    local itemId = GetItemIdFromLinkOrId(link) or GetItemIdFromLinkOrId(value1) or GetItemIdFromLinkOrId(value2)
    local location = nil
    if self.lastPickedLocation and self.lastPickedLocation.itemId == itemId then
        location = {
            itemId = self.lastPickedLocation.itemId,
            link = link or self.lastPickedLocation.link,
            bag = self.lastPickedLocation.bag,
            slot = self.lastPickedLocation.slot,
            equip = self.lastPickedLocation.equip
        }
    end
    if not location then
        location = FindItemLocation(itemId, link)
    end
    ClearCursor()
    self.lastPickedLocation = nil

    if location then
        self:SetSelected(location)
    else
        self:SetStatus("没有在背包或装备栏找到该装备", 1, 0.25, 0.25)
    end
end

function UI:SetActiveTab(tabName)
    self.activeTab = tabName
    if tabName == "rune" then
        self:SendRuneCommand("BAG")
        if self.selected then
            self:SendRuneCommand("QUERY")
        end
    elseif tabName == "refine" and self.selected then
        self:SendModuleCommand("refine", "QUERY")
    end
    self:RefreshContent()
end

function UI:RefreshTabs()
    if not self.frame then return end

    local f = self.frame
    local enhanceActive = self.activeTab == "enhance"
    local growthActive = self.activeTab == "growth"
    local runeActive = self.activeTab == "rune"
    local refineActive = self.activeTab == "refine"

    f.enhanceTab:SetBackdropColor(enhanceActive and 0.25 or 0.08, enhanceActive and 0.15 or 0.08, enhanceActive and 0.04 or 0.08, 0.92)
    f.growthTab:SetBackdropColor(growthActive and 0.03 or 0.08, growthActive and 0.18 or 0.08, growthActive and 0.24 or 0.08, 0.92)
    f.runeTab:SetBackdropColor(runeActive and 0.18 or 0.08, runeActive and 0.08 or 0.08, runeActive and 0.22 or 0.08, 0.92)
    f.refineTab:SetBackdropColor(refineActive and 0.22 or 0.08, refineActive and 0.12 or 0.08, refineActive and 0.03 or 0.08, 0.92)
    f.enhanceTab.text:SetTextColor(enhanceActive and 1 or 0.75, enhanceActive and 0.82 or 0.75, enhanceActive and 0.32 or 0.75)
    f.growthTab.text:SetTextColor(growthActive and 0.45 or 0.75, growthActive and 0.9 or 0.75, growthActive and 1 or 0.75)
    f.runeTab.text:SetTextColor(runeActive and 0.95 or 0.75, runeActive and 0.55 or 0.75, runeActive and 1 or 0.75)
    f.refineTab.text:SetTextColor(refineActive and 1 or 0.75, refineActive and 0.62 or 0.75, refineActive and 0.2 or 0.75)
end

function UI:RefreshRunePanel()
    if not self.frame or not self.frame.runePanel then return end

    local f = self.frame
    local data = self.data.rune or { slots = {}, bagRunes = {} }
    local slots = data.slots or {}
    local bagRunes = data.bagRunes or {}
    local selectedSlotExists = false

    for i = 1, #slots do
        if slots[i] and slots[i].slotId == self.selectedRuneSlot then
            selectedSlotExists = true
            break
        end
    end
    if self.selectedRuneSlot and not selectedSlotExists then
        self.selectedRuneSlot = nil
    end

    for i = 1, RUNE_MAX_VISIBLE_SLOTS do
        local button = f.runeSlots[i]
        local slotData = slots[i]
        if not slotData then
            button.slotId = nil
            button.runeItemId = nil
            button:Hide()
        else
            button:Show()
        end
        local isActive = slotData ~= nil
        local slotId = slotData and slotData.slotId or i
        local runeItemId = slotData and slotData.runeItemId or 0
        local filled = runeItemId and runeItemId > 0
        local color = GetRuneQualityColor(slotData and slotData.quality or 0)

        if not isActive then
            button.selected:Hide()
        else
        button.slotId = slotId
        button.runeItemId = runeItemId
        button.runeName = slotData and slotData.name or ""
        button.runeDesc = slotData and slotData.desc or ""
        button:SetAlpha(1)
        button.label:SetText(tostring(slotId))
        button.name:SetText(filled and TrimText(slotData.name, 12) or "空")
        button.name:SetTextColor(filled and color.r or 0.55, filled and color.g or 0.55, filled and color.b or 0.55)

        if filled then
            local _, _, _, _, _, _, _, _, _, texture = ItemForge_GetItemInfo(runeItemId)
            button.icon:SetTexture(texture or "Interface\\Icons\\INV_Misc_Gem_Variety_01")
            button:SetBackdropBorderColor(color.r, color.g, color.b, 1)
        elseif isActive then
            button.icon:SetTexture("Interface\\ItemSocketingFrame\\UI-EmptySocket-Prismatic")
            button:SetBackdropBorderColor(self.selectedRuneSlot == slotId and 0.95 or 0.38, self.selectedRuneSlot == slotId and 0.55 or 0.32, self.selectedRuneSlot == slotId and 1 or 0.42, 1)
        else
            button.icon:SetTexture(nil)
            button:SetBackdropBorderColor(0.22, 0.22, 0.26, 0.8)
        end

        if self.selectedRuneSlot == slotId and isActive then
            button.selected:Show()
        else
            button.selected:Hide()
        end
        end
    end

    local maxPage = math.max(1, math.ceil(#bagRunes / RUNE_BAG_PAGE_SIZE))
    if self.runeBagPage > maxPage then self.runeBagPage = maxPage end
    if self.runeBagPage < 1 then self.runeBagPage = 1 end

    for i = 1, RUNE_BAG_PAGE_SIZE do
        local button = f.runeBagButtons[i]
        local index = (self.runeBagPage - 1) * RUNE_BAG_PAGE_SIZE + i
        local rune = bagRunes[index]
        if rune then
            local color = GetRuneQualityColor(rune.quality)
            button.runeItemId = rune.itemId
            button.runeSlot = rune.runeSlot
            button.name:SetText(TrimText(rune.name, 22) .. "  x" .. tostring(rune.count or 0))
            button.name:SetTextColor(color.r, color.g, color.b)
            button.slot:SetText("槽位 " .. tostring(rune.runeSlot or 0))
            button.desc:SetText(TrimText(rune.desc, 34))
            button:SetBackdropBorderColor(self.selectedRuneItemId == rune.itemId and 1 or 0.34, self.selectedRuneItemId == rune.itemId and 0.72 or 0.28, self.selectedRuneItemId == rune.itemId and 0.28 or 0.34, 1)
            button:Show()
        else
            button.runeItemId = nil
            button:Hide()
        end
    end

    f.runeBagPageText:SetText(tostring(self.runeBagPage) .. "/" .. tostring(maxPage))
    if #bagRunes == 0 then
        f.runeEmptyBag:Show()
    else
        f.runeEmptyBag:Hide()
    end
end

function UI:SocketSelectedRune()
    if not self.selectedRuneSlot then
        self:SetStatus("请先选择一个符文槽位", 1, 0.35, 0.3)
        return
    end
    if not self.selectedRuneItemId then
        self:SetStatus("请先选择背包里的符文", 1, 0.35, 0.3)
        return
    end

    self:SendRuneCommand("SOCKET", tostring(self.selectedRuneSlot) .. "|" .. tostring(self.selectedRuneItemId))
end

function UI:RefreshContent()
    if not self.frame then return end

    local f = self.frame
    self:RefreshTabs()
    if f.runePanel then f.runePanel:Hide() end
    if f.refinePanel then f.refinePanel:Hide() end
    if f.detail then f.detail:Show() end
    if f.sectionTitle then f.sectionTitle:Show() end
    if f.summary then f.summary:Show() end
    f.primary:Show()

    if self.activeTab == "enhance" then
        local data = self.data.enhance
        local function MaterialLine(label, itemId, count, available, bonus)
            local labelColor = label == "幸运材料" and "|cffffd040" or "|cffb878ff"
            if not itemId or itemId <= 0 or not count or count <= 0 then
                return labelColor .. label .. "：|r|cff888888未配置|r"
            end
            local name, link, _, _, _, _, _, _, _, texture = ItemForge_GetItemInfo(itemId)
            local itemText = link or name or ("物品 " .. tostring(itemId))
            local icon = texture and ("|T" .. texture .. ":16:16:0:0|t ") or ""
            local state = available and "|cff40ff40已持有|r" or "|cffff5050缺少|r"
            local bonusText = bonus and bonus > 0 and ("，|cff40ff40+" .. string.format("%.2f", bonus) .. "%|r") or ""
            return labelColor .. label .. "：|r" .. icon .. itemText .. " |cffffffffx" .. tostring(count) .. "|r（" .. state .. bonusText .. "）"
        end
        local failureNames = { [0] = "|cffffffff等级不变|r", [1] = "|cffff5050等级清零|r", [2] = "|cffff2020装备摧毁|r", [3] = "|cffff9f40降低 " .. tostring(data.failureDropLevels or 1) .. " 级|r" }
        local pityText = "|cff888888关闭|r"
        if (data.pityCount or 0) > 0 then
            pityText = "|cff40d8ff" .. tostring(math.min(data.failureCount or 0, data.pityCount)) .. "/" .. tostring(data.pityCount) .. "|r"
            if (data.pityBonus or 0) > 0 then
                pityText = pityText .. "（每次失败 |cff40ff40+" .. string.format("%.2f", data.pityBonus) .. "%|r）"
            end
        end
        f.sectionTitle:SetText("追加强化")
        f.sectionTitle:SetTextColor(1, 0.82, 0.25)
        local rateText = data.maxLevelReached and "|cff40ff40已满级|r" or ("|cffffd040当前成功率：|r|cff40ff40" .. string.format("%.2f", data.successRate or 0) .. "%|r")
        f.summary:SetText("|cffffd040强化等级：|r|cffffffff+" .. tostring(data.level or 0) .. "|r    " .. rateText)
        f.detail:ClearAllPoints()
        f.detail:SetPoint("TOPLEFT", 20, -78)
        f.detail:SetText("|cffffd040强化属性|r\n" .. FormatAttrs(data.attrs) ..
            "\n\n|cff40d8ff保底进度：|r" .. pityText ..
            "\n|cffff9f40失败规则：|r" .. (failureNames[data.failureType or 0] or "|cffff5050未知|r") ..
            "\n" .. MaterialLine("幸运材料", data.luckItemId, data.luckItemCount, data.hasLuck, data.luckBonus) ..
            "\n" .. MaterialLine("保护材料", data.protectionItemId, data.protectionItemCount, data.hasProtection, 0))
        f.expBar:Hide()
        f.expText:Hide()
        f.primary:SetText("强化")
        f.primary:SetScript("OnClick", function() UI:SendModuleCommand("enhance", "ENHANCE") end)
        f.refresh:SetScript("OnClick", function() UI:SendModuleCommand("enhance", "QUERY") end)
        if data.status and data.status ~= "" then
            self:SetStatus(data.status, data.canUse and 0.3 or 1, data.canUse and 1 or 0.4, data.canUse and 0.45 or 0.3)
        end
    elseif self.activeTab == "growth" then
        local data = self.data.growth
        local required = data.required or 0
        local exp = data.exp or 0
        local percent = 0
        if required > 0 then
            percent = math.min(100, math.max(0, exp / required * 100))
        end

        f.sectionTitle:SetText("追加成长")
        f.sectionTitle:SetTextColor(0.45, 0.9, 1)
        f.summary:SetText("成长等级：" .. tostring(data.level or 0) .. "    经验：" .. tostring(exp) .. "/" .. tostring(required))
        f.detail:ClearAllPoints()
        f.detail:SetPoint("TOPLEFT", 20, -102)
        f.detail:SetText("成长属性\n" .. FormatAttrs(data.attrs) .. "\n\n百分比属性\n" .. FormatAttrs(data.percentAttrs))
        f.expBar:Show()
        f.expText:Show()
        f.expBar:SetValue(percent)
        f.expText:SetText(string.format("%.1f%%", percent))
        f.primary:SetText("成长")
        f.primary:SetScript("OnClick", function() UI:SendModuleCommand("growth", "UPGRADE") end)
        f.refresh:SetScript("OnClick", function() UI:SendModuleCommand("growth", "QUERY") end)
        if data.status and data.status ~= "" then
            self:SetStatus(data.status, data.canUse and 0.3 or 1, data.canUse and 1 or 0.4, data.canUse and 0.45 or 0.3)
        end
    elseif self.activeTab == "rune" then
        local data = self.data.rune
        f.sectionTitle:SetText("追加符文")
        f.sectionTitle:SetTextColor(0.95, 0.55, 1)
        f.summary:SetText("符文槽位：" .. tostring(data.filled or 0) .. "/" .. tostring(data.total or 0))
        f.detail:Hide()
        f.expBar:Hide()
        f.expText:Hide()
        f.primary:SetText("镶嵌")
        f.primary:SetScript("OnClick", function() UI:SocketSelectedRune() end)
        f.refresh:SetScript("OnClick", function()
            UI:SendRuneCommand("QUERY")
            UI:SendRuneCommand("BAG")
        end)
        if f.runePanel then f.runePanel:Show() end
        self:RefreshRunePanel()
        if data.status and data.status ~= "" then
            self:SetStatus(data.status, 0.85, 0.62, 1)
        end
    else
        local data = self.data.refine
        f.sectionTitle:Hide()
        f.summary:Hide()
        local materialLines = {}
        for i = 1, #(data.materials or {}) do
            local material = data.materials[i]
            local name, link, _, _, _, _, _, _, _, texture = ItemForge_GetItemInfo(material.itemId)
            local icon = texture and ("|T" .. texture .. ":16:16:0:0|t ") or ""
            local itemText = link or name or ("物品 " .. tostring(material.itemId))
            local state = material.available and "|cff40ff40已持有|r" or "|cffff5050缺少|r"
            table.insert(materialLines, icon .. itemText .. " ×" .. tostring(material.count) .. "（" .. state .. "）")
        end
        local materialText = #materialLines > 0 and table.concat(materialLines, "\n") or "|cff888888无|r"
        f.refineMaterialText:SetText("|cffff9f40洗炼材料|r\n" .. materialText)
        f.detail:Hide()
        f.expBar:Hide()
        f.expText:Hide()
        f.primary:Hide()
        f.refinePanel:Show()
        for category, button in pairs(f.refineButtons) do
            if data.categories[category] then button:Show() else button:Hide() end
        end
        local names = { [1] = "基础属性", [2] = "追加属性", [3] = "追加技能", [4] = "随机附魔属性" }
        local function FormatEnchants(value)
            if not value or value == "" then return "|cff888888无|r" end
            local lines = {}
            for enchantId in string.gmatch(value, "[^,]+") do
                local display = "附魔 " .. enchantId
                if GetEnchantDes then
                    local description = GetEnchantDes(enchantId)
                    if description and description ~= "" and description ~= "0" then
                        display = description
                    end
                end
                table.insert(lines, display)
            end
            return table.concat(lines, "\n")
        end
        local function CompareText(value, category)
            if not value or value == "" then return "|cff888888无|r" end
            if category == 1 or category == 2 then return FormatAttrs(value) end
            if category == 4 then return FormatEnchants(value) end
            return string.gsub(value, ",", "\n")
        end
        if data.comparison then
            local compareName = names[data.comparison.category] or "属性"
            f.refineBeforeText:SetText("|cffffd040洗炼前 · " .. compareName .. "|r\n\n" .. CompareText(data.comparison.before, data.comparison.category))
            f.refineAfterText:SetText("|cff40ff40洗炼后 · " .. compareName .. "|r\n\n" .. CompareText(data.comparison.after, data.comparison.category))
        elseif data.categories[4] and data.currentEnchants and data.currentEnchants ~= "" then
            f.refineBeforeText:SetText("|cffffd040当前 · 随机附魔属性|r\n\n" .. FormatEnchants(data.currentEnchants))
            f.refineAfterText:SetText("|cff40ff40洗炼后 · 随机附魔属性|r\n\n|cff888888点击右侧按钮后显示|r")
        else
            f.refineBeforeText:SetText("|cffffd040洗炼前|r\n\n|cff888888完成一次洗炼后显示|r")
            f.refineAfterText:SetText("|cff40ff40洗炼后|r\n\n|cff888888完成一次洗炼后显示|r")
        end
        f.refresh:SetScript("OnClick", function() UI:SendModuleCommand("refine", "QUERY") end)
        if data.status and data.status ~= "" then
            self:SetStatus(data.status, data.canUse and 1 or 1, data.canUse and 0.65 or 0.3, data.canUse and 0.2 or 0.3)
        end
    end
end

function UI:IsCurrentItemResponse(itemId, guid)
    if not self.selected or itemId <= 0 or itemId ~= (tonumber(self.selected.itemId or 0) or 0) then
        return false
    end

    local selectedGuid = tonumber(self.selected.guid or 0) or 0
    return selectedGuid <= 0 or guid <= 0 or selectedGuid == guid
end

function UI:ApplyEnhanceData(parts)
    local itemId = tonumber(parts[2] or "0") or 0
    local guid = tonumber(parts[3] or "0") or 0
    if not self:IsCurrentItemResponse(itemId, guid) then return end
    self.data.enhance.level = tonumber(parts[4] or "0") or 0
    self.data.enhance.canUse = tonumber(parts[5] or "0") == 1
    self.data.enhance.status = parts[6] or ""
    self.data.enhance.attrs = parts[7] or ""
    self.data.enhance.successRate = tonumber(parts[8] or "0") or 0
    self.data.enhance.failureCount = tonumber(parts[9] or "0") or 0
    self.data.enhance.pityCount = tonumber(parts[10] or "0") or 0
    self.data.enhance.pityBonus = tonumber(parts[11] or "0") or 0
    self.data.enhance.luckItemId = tonumber(parts[12] or "0") or 0
    self.data.enhance.luckItemCount = tonumber(parts[13] or "0") or 0
    self.data.enhance.luckBonus = tonumber(parts[14] or "0") or 0
    self.data.enhance.hasLuck = tonumber(parts[15] or "0") == 1
    self.data.enhance.protectionItemId = tonumber(parts[16] or "0") or 0
    self.data.enhance.protectionItemCount = tonumber(parts[17] or "0") or 0
    self.data.enhance.hasProtection = tonumber(parts[18] or "0") == 1
    self.data.enhance.failureType = tonumber(parts[19] or "0") or 0
    self.data.enhance.failureDropLevels = tonumber(parts[20] or "0") or 0
    self.data.enhance.maxLevelReached = tonumber(parts[21] or "0") == 1

    if self.selected and itemId > 0 then
        local needsRefinementQuery = (tonumber(self.selected.guid or 0) or 0) <= 0 and guid > 0
        self.selected.itemId = itemId
        if guid > 0 then self.selected.guid = guid end
        if needsRefinementQuery then
            self:SendModuleCommand("refine", "QUERY")
        end
    end
    self:RefreshContent()
end

function UI:ApplyGrowthData(parts)
    local itemId = tonumber(parts[2] or "0") or 0
    local guid = tonumber(parts[3] or "0") or 0
    if not self:IsCurrentItemResponse(itemId, guid) then return end
    self.data.growth.canUse = tonumber(parts[4] or "0") == 1
    self.data.growth.level = tonumber(parts[5] or "0") or 0
    self.data.growth.exp = tonumber(parts[6] or "0") or 0
    self.data.growth.required = tonumber(parts[7] or "0") or 0
    self.data.growth.status = parts[8] or ""
    self.data.growth.attrs = parts[9] or ""
    self.data.growth.percentAttrs = parts[10] or ""

    if self.selected and itemId > 0 then
        local needsRefinementQuery = (tonumber(self.selected.guid or 0) or 0) <= 0 and guid > 0
        self.selected.itemId = itemId
        if guid > 0 then self.selected.guid = guid end
        if needsRefinementQuery then
            self:SendModuleCommand("refine", "QUERY")
        end
    end
    self:RefreshContent()
end

function UI:ApplyRuneData(parts)
    local itemId = tonumber(parts[2] or "0") or 0
    local guid = tonumber(parts[3] or "0") or 0
    if not self:IsCurrentItemResponse(itemId, guid) then return end
    self.data.rune.total = tonumber(parts[4] or "0") or 0
    self.data.rune.filled = tonumber(parts[5] or "0") or 0
    self.data.rune.status = parts[6] or ""
    self.data.rune.slots = {}

    local listText = parts[7] or ""
    if listText ~= "" then
        local records = Split(listText, "~")
        for i = 1, #records do
            if records[i] ~= "" then
                local fields = Split(records[i], "^")
                table.insert(self.data.rune.slots, {
                    slotId = tonumber(fields[1] or "0") or i,
                    runeItemId = tonumber(fields[2] or "0") or 0,
                    name = fields[3] or "",
                    quality = tonumber(fields[4] or "0") or 0,
                    desc = fields[5] or ""
                })
            end
        end
    end

    if self.selected and itemId > 0 then
        local needsRefinementQuery = (tonumber(self.selected.guid or 0) or 0) <= 0 and guid > 0
        self.selected.itemId = itemId
        if guid > 0 then self.selected.guid = guid end
        if needsRefinementQuery then
            self:SendModuleCommand("refine", "QUERY")
        end
    end
    self:RefreshContent()
end

function UI:ApplyRefinementData(parts)
    self.data.refine.canUse = tonumber(parts[2] or "0") == 1
    self.data.refine.requirementId = tonumber(parts[3] or "0") or 0
    self.data.refine.categories = {}
    for value in string.gmatch(parts[4] or "", "([^,]+)") do
        local category = tonumber(value)
        if category then self.data.refine.categories[category] = true end
    end
    self.data.refine.status = parts[5] or ""
    self.data.refine.currentEnchants = parts[7] or ""
    self.data.refine.materials = {}
    for record in string.gmatch(parts[6] or "", "([^~]+)") do
        local fields = Split(record, "^")
        local itemId = tonumber(fields[1] or "0") or 0
        local count = tonumber(fields[2] or "0") or 0
        if itemId > 0 and count > 0 then
            table.insert(self.data.refine.materials, {
                itemId = itemId, count = count, available = tonumber(fields[3] or "0") == 1
            })
        end
    end
    self:RefreshContent()
end

function UI:ApplyRuneBagData(parts)
    self.data.rune.bagRunes = {}
    local listText = parts[2] or ""
    if listText ~= "" then
        local records = Split(listText, "~")
        for i = 1, #records do
            if records[i] ~= "" then
                local fields = Split(records[i], "^")
                local itemId = tonumber(fields[1] or "0") or 0
                if itemId > 0 then
                    table.insert(self.data.rune.bagRunes, {
                        itemId = itemId,
                        name = fields[2] or ("符文 " .. tostring(itemId)),
                        quality = tonumber(fields[3] or "0") or 0,
                        count = tonumber(fields[4] or "0") or 0,
                        runeSlot = tonumber(fields[5] or "0") or 0,
                        desc = fields[6] or ""
                    })
                end
            end
        end
    end

    table.sort(self.data.rune.bagRunes, function(a, b)
        if (a.runeSlot or 0) == (b.runeSlot or 0) then
            return (a.itemId or 0) < (b.itemId or 0)
        end
        return (a.runeSlot or 0) < (b.runeSlot or 0)
    end)

    if self.selectedRuneItemId then
        local found = false
        for i = 1, #self.data.rune.bagRunes do
            if self.data.rune.bagRunes[i].itemId == self.selectedRuneItemId then
                found = true
                break
            end
        end
        if not found then
            self.selectedRuneItemId = nil
        end
    end

    self:RefreshContent()
end

function UI:HandleGrowthPayload(message)
    local parts = Split(message, "|")
    if parts[1] == "DATA" then
        self:ApplyGrowthData(parts)
    elseif parts[1] == "RESULT" then
        local ok = tonumber(parts[2] or "0") == 1
        self:SetStatus(parts[3] or "", ok and 0.3 or 1, ok and 1 or 0.35, ok and 0.45 or 0.25)
        self:SendModuleCommand("growth", "QUERY")
    end
end

function UI:OnAddonMessage(prefix, message)
    if prefix == IDENTIFICATION_PREFIX then
        local recycleParts = Split(message, ":")
        if recycleParts[1] == "RECYCLE_LEVELS_RESULT" then
            self:ApplyRecycleLevels(recycleParts[2] or "")
        elseif recycleParts[1] == "RECYCLE_BATCH_RESULT" then
            local recycled = tonumber(recycleParts[2] or "0") or 0
            local skipped = tonumber(recycleParts[3] or "0") or 0
            local identificationLevel = tonumber(recycleParts[4] or "0") or 0
            local levelText = identificationLevel > 0 and ("鉴定等级 " .. tostring(identificationLevel)) or "全部等级"
            self:ClearSelected("")
            if recycled > 0 then
                self:SetStatus(levelText .. "回收完成：成功 " .. tostring(recycled) .. " 件，跳过 " .. tostring(skipped) .. " 件", 0.3, 1, 0.45)
            elseif skipped > 0 then
                self:SetStatus(levelText .. "没有可回收装备，跳过 " .. tostring(skipped) .. " 件无回收配置装备", 1, 0.55, 0.25)
            else
                self:SetStatus("背包中没有" .. levelText .. "的可回收装备", 1, 0.55, 0.25)
            end
        end
        return
    end

    local parts = Split(message, "|")
    if prefix == ENHANCE_PREFIX then
        if parts[1] == "DATA" then
            self:ApplyEnhanceData(parts)
        elseif parts[1] == "RESULT" then
            local ok = tonumber(parts[2] or "0") == 1
            self:SetStatus(parts[3] or "", ok and 0.3 or 1, ok and 1 or 0.35, ok and 0.45 or 0.25)
            self:SendModuleCommand("enhance", "QUERY")
        end
    elseif prefix == GROWTH_PREFIX then
        -- New clients get the same payload from NativeUIGrowthData(); ignore
        -- the chat copy there so the data is not applied twice.
        if not NativeUIGrowthData then
            self:HandleGrowthPayload(message)
        end
    elseif prefix == RUNE_PREFIX then
        if parts[1] == "DATA" then
            self:ApplyRuneData(parts)
        elseif parts[1] == "BAG" then
            self:ApplyRuneBagData(parts)
        elseif parts[1] == "RESULT" then
            local ok = tonumber(parts[2] or "0") == 1
            self:SetStatus(parts[3] or "", ok and 0.35 or 1, ok and 1 or 0.35, ok and 0.55 or 0.25)
            self:SendRuneCommand("QUERY")
            self:SendRuneCommand("BAG")
        end
    elseif prefix == REFINE_PREFIX then
        if parts[1] == "DATA" then
            self:ApplyRefinementData(parts)
        elseif parts[1] == "RESULT" then
            local ok = tonumber(parts[2] or "0") == 1
            if ok then
                self.data.refine.comparison = {
                    category = tonumber(parts[4] or "0") or 0,
                    before = parts[5] or "",
                    after = parts[6] or ""
                }
            end
            self:SetStatus(parts[3] or "", ok and 0.3 or 1, ok and 1 or 0.3, ok and 0.35 or 0.25)
            self:QuerySelected()
        end
    end
end

function UI:CreateFrame()
    if self.frame then return end

    local f = CreateFrame("Frame", "ItemForgeUIFrame", UIParent)
    f:SetSize(540, 660)
    f:SetPoint("CENTER")
    f:SetFrameStrata("HIGH")
    f:SetMovable(true)
    f:EnableMouse(true)
    f:RegisterForDrag("LeftButton")
    f:SetScript("OnDragStart", f.StartMoving)
    f:SetScript("OnDragStop", f.StopMovingOrSizing)
    f:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background-Dark",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Gold-Border",
        tile = true,
        tileSize = 32,
        edgeSize = 32,
        insets = { left = 10, right = 10, top = 10, bottom = 10 }
    })
    f:SetBackdropColor(0.02, 0.02, 0.025, 0.98)

    local title = f:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOP", 0, -18)
    title:SetText("装备锻造")
    title:SetTextColor(1, 0.82, 0.25)

    local subTitle = f:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    subTitle:SetPoint("TOP", title, "BOTTOM", 0, -3)
    subTitle:SetText("强化、成长与符文")

    local close = CreateFrame("Button", nil, f, "UIPanelCloseButton")
    close:SetPoint("TOPRIGHT", -5, -5)

    local itemPanel = MakePanel(f, nil, 24, -66, 492, 102)

    local slot = CreateFrame("Button", nil, itemPanel)
    slot:SetSize(64, 64)
    slot:SetPoint("LEFT", 18, 0)
    slot:SetBackdrop({
        bgFile = "Interface\\Buttons\\UI-Slot-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = false,
        edgeSize = 14,
        insets = { left = 4, right = 4, top = 4, bottom = 4 }
    })
    slot:SetBackdropColor(0.03, 0.025, 0.02, 1)
    slot:SetBackdropBorderColor(0.58, 0.44, 0.22, 0.95)
    slot:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square")
    slot:GetHighlightTexture():SetPoint("TOPLEFT", 6, -6)
    slot:GetHighlightTexture():SetPoint("BOTTOMRIGHT", -6, 6)
    slot:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    slot:RegisterForDrag("LeftButton")
    slot:SetScript("OnReceiveDrag", function() UI:PickCursorItem() end)
    slot:SetScript("OnClick", function()
        if CursorHasItem and CursorHasItem() then
            UI:PickCursorItem()
        elseif UI.selected then
            UI:ClearSelected("已取回装备")
        end
    end)
    slot:SetScript("OnEnter", function()
        if UI.selected and UI.selected.link then
            GameTooltip:SetOwner(slot, "ANCHOR_RIGHT")
            ItemForge_SetItemTooltip(GameTooltip, UI.selected.link)
            GameTooltip:Show()
        end
    end)
    slot:SetScript("OnLeave", function() GameTooltip:Hide() end)

    f.itemSlot = slot

    local iconBg = slot:CreateTexture(nil, "BACKGROUND")
    iconBg:SetPoint("TOPLEFT", slot, "TOPLEFT", 6, -6)
    iconBg:SetPoint("BOTTOMRIGHT", slot, "BOTTOMRIGHT", -6, 6)
    iconBg:SetTexture("Interface\\Buttons\\WHITE8X8")
    iconBg:SetVertexColor(0.03, 0.03, 0.035, 0.95)

    f.itemIcon = slot:CreateTexture(nil, "ARTWORK")
    f.itemIcon:SetPoint("TOPLEFT", slot, "TOPLEFT", 8, -8)
    f.itemIcon:SetPoint("BOTTOMRIGHT", slot, "BOTTOMRIGHT", -8, 8)
    f.itemIcon:SetTexture(nil)

    f.itemName = MakeLine(itemPanel, "拖入一件装备", 98, -24, "GameFontNormalLarge")
    f.itemName:SetWidth(362)
    f.itemHint = MakeLine(itemPanel, "支持背包与已穿戴装备", 100, -52, "GameFontDisable")
    f.itemHint:SetWidth(362)

    f.enhanceTab = CreateFrame("Button", nil, f)
    f.enhanceTab:SetSize(110, 32)
    f.enhanceTab:SetPoint("TOPLEFT", 34, -178)
    f.enhanceTab:SetBackdrop({ bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", tile = true, tileSize = 16, edgeSize = 12, insets = { left = 3, right = 3, top = 3, bottom = 3 } })
    f.enhanceTab:SetBackdropBorderColor(0.55, 0.42, 0.18, 1)
    f.enhanceTab.text = MakeLine(f.enhanceTab, "追加强化", 0, 0, "GameFontNormal")
    f.enhanceTab.text:ClearAllPoints()
    f.enhanceTab.text:SetPoint("CENTER")
    f.enhanceTab:SetScript("OnClick", function() UI:SetActiveTab("enhance") end)

    f.growthTab = CreateFrame("Button", nil, f)
    f.growthTab:SetSize(110, 32)
    f.growthTab:SetPoint("LEFT", f.enhanceTab, "RIGHT", 8, 0)
    f.growthTab:SetBackdrop({ bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", tile = true, tileSize = 16, edgeSize = 12, insets = { left = 3, right = 3, top = 3, bottom = 3 } })
    f.growthTab:SetBackdropBorderColor(0.25, 0.55, 0.65, 1)
    f.growthTab.text = MakeLine(f.growthTab, "追加成长", 0, 0, "GameFontNormal")
    f.growthTab.text:ClearAllPoints()
    f.growthTab.text:SetPoint("CENTER")
    f.growthTab:SetScript("OnClick", function() UI:SetActiveTab("growth") end)

    f.runeTab = CreateFrame("Button", nil, f)
    f.runeTab:SetSize(110, 32)
    f.runeTab:SetPoint("LEFT", f.growthTab, "RIGHT", 8, 0)
    f.runeTab:SetBackdrop({ bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", tile = true, tileSize = 16, edgeSize = 12, insets = { left = 3, right = 3, top = 3, bottom = 3 } })
    f.runeTab:SetBackdropBorderColor(0.55, 0.28, 0.65, 1)
    f.runeTab.text = MakeLine(f.runeTab, "追加符文", 0, 0, "GameFontNormal")
    f.runeTab.text:ClearAllPoints()
    f.runeTab.text:SetPoint("CENTER")
    f.runeTab:SetScript("OnClick", function() UI:SetActiveTab("rune") end)

    f.refineTab = CreateFrame("Button", nil, f)
    f.refineTab:SetSize(110, 32)
    f.refineTab:SetPoint("LEFT", f.runeTab, "RIGHT", 8, 0)
    f.refineTab:SetBackdrop({ bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", tile = true, tileSize = 16, edgeSize = 12, insets = { left = 3, right = 3, top = 3, bottom = 3 } })
    f.refineTab:SetBackdropBorderColor(0.65, 0.35, 0.12, 1)
    f.refineTab.text = MakeLine(f.refineTab, "追加洗炼", 0, 0, "GameFontNormal")
    f.refineTab.text:ClearAllPoints()
    f.refineTab.text:SetPoint("CENTER")
    f.refineTab:SetScript("OnClick", function() UI:SetActiveTab("refine") end)

    local content = MakePanel(f, nil, 24, -218, 492, 298)
    f.sectionTitle = MakeLine(content, "追加强化", 18, -18, "GameFontNormalLarge")
    f.summary = MakeLine(content, "", 20, -48, "GameFontHighlight")
    f.summary:SetWidth(440)

    f.expBar = CreateFrame("StatusBar", nil, content)
    f.expBar:SetSize(440, 16)
    f.expBar:SetPoint("TOPLEFT", 20, -74)
    f.expBar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
    f.expBar:SetStatusBarColor(0.2, 0.75, 1)
    f.expBar:SetMinMaxValues(0, 100)
    f.expBar:SetValue(0)
    f.expBar.bg = f.expBar:CreateTexture(nil, "BACKGROUND")
    f.expBar.bg:SetAllPoints()
    f.expBar.bg:SetTexture("Interface\\TargetingFrame\\UI-StatusBar")
    f.expBar.bg:SetVertexColor(0.08, 0.08, 0.1, 1)
    f.expText = f.expBar:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    f.expText:SetPoint("CENTER")
    f.expText:SetText("0%")

    f.detail = MakeLine(content, "", 20, -78, "GameFontHighlightSmall")
    f.detail:SetWidth(440)
    f.detail:SetHeight(176)

    local runePanel = CreateFrame("Frame", nil, content)
    runePanel:SetAllPoints(content)
    runePanel:Hide()
    f.runePanel = runePanel

    local refinePanel = CreateFrame("Frame", nil, content)
    refinePanel:SetAllPoints(content)
    refinePanel:Hide()
    f.refinePanel = refinePanel

    local beforePanel = MakePanel(refinePanel, nil, 8, -8, 150, 282)
    f.refineBeforeText = MakeLine(beforePanel, "", 10, -12, "GameFontHighlightSmall")
    f.refineBeforeText:SetWidth(130)
    f.refineBeforeText:SetHeight(254)

    local afterPanel = MakePanel(refinePanel, nil, 166, -8, 150, 282)
    f.refineAfterText = MakeLine(afterPanel, "", 10, -12, "GameFontHighlightSmall")
    f.refineAfterText:SetWidth(130)
    f.refineAfterText:SetHeight(254)

    local materialPanel = MakePanel(refinePanel, nil, 324, -200, 160, 90)
    f.refineMaterialText = MakeLine(materialPanel, "", 9, -10, "GameFontHighlightSmall")
    f.refineMaterialText:SetWidth(140)
    f.refineMaterialText:SetHeight(68)

    f.refineButtons = {}
    local categoryNames = {
        [1] = "洗炼基础属性", [2] = "洗炼追加属性", [3] = "洗炼追加技能", [4] = "洗炼随机附魔"
    }
    local refineCategories = { 1, 2, 3, 4 }
    for index, category in ipairs(refineCategories) do
        local button = CreateFrame("Button", nil, refinePanel, "UIPanelButtonTemplate")
        button:SetSize(160, 40)
        button:SetPoint("TOPLEFT", 324, -8 - (index - 1) * 48)
        button:SetText(categoryNames[category])
        button:SetScript("OnClick", function() UI:SendModuleCommand("refine", "REFINE", category) end)
        f.refineButtons[category] = button
    end

    local slotTitle = MakeLine(runePanel, "符文槽", 20, -74, "GameFontNormalSmall")
    slotTitle:SetTextColor(0.95, 0.55, 1)
    local bagTitle = MakeLine(runePanel, "背包符文", 236, -74, "GameFontNormalSmall")
    bagTitle:SetTextColor(1, 0.82, 0.25)

    f.runeSlots = {}
    for i = 1, RUNE_MAX_VISIBLE_SLOTS do
        local runeSlot = CreateFrame("Button", nil, runePanel)
        runeSlot:SetSize(38, 38)
        runeSlot:SetPoint("TOPLEFT", 20 + ((i - 1) % 5) * 41, -96 - math.floor((i - 1) / 5) * 44)
        runeSlot:SetBackdrop({
            bgFile = "Interface\\Buttons\\UI-Slot-Background",
            edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
            tile = false,
            edgeSize = 12,
            insets = { left = 3, right = 3, top = 3, bottom = 3 }
        })
        runeSlot:SetBackdropColor(0.03, 0.025, 0.04, 1)
        runeSlot:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square")
        runeSlot:RegisterForClicks("LeftButtonUp", "RightButtonUp")
        runeSlot.icon = runeSlot:CreateTexture(nil, "ARTWORK")
        runeSlot.icon:SetPoint("TOPLEFT", 6, -6)
        runeSlot.icon:SetPoint("BOTTOMRIGHT", -6, 6)
        runeSlot.selected = runeSlot:CreateTexture(nil, "OVERLAY")
        runeSlot.selected:SetTexture("Interface\\Buttons\\UI-ActionButton-Border")
        runeSlot.selected:SetBlendMode("ADD")
        runeSlot.selected:SetSize(58, 58)
        runeSlot.selected:SetPoint("CENTER")
        runeSlot.selected:SetVertexColor(0.95, 0.55, 1, 0.9)
        runeSlot.selected:Hide()
        runeSlot.label = runeSlot:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        runeSlot.label:SetPoint("TOPLEFT", 3, -2)
        runeSlot.label:SetTextColor(1, 0.9, 0.55)
        runeSlot.name = runeSlot:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
        runeSlot.name:SetPoint("TOP", runeSlot, "BOTTOM", 0, -1)
        runeSlot.name:SetWidth(40)
        runeSlot.name:SetJustifyH("CENTER")
        runeSlot:SetScript("OnClick", function(self, mouseButton)
            if not self.slotId or self:GetAlpha() < 0.5 then
                UI:SetStatus("该位置没有可用符文槽", 1, 0.35, 0.3)
                return
            end
            if mouseButton == "RightButton" and self.runeItemId and self.runeItemId > 0 then
                UI:SendRuneCommand("UNSOCKET", tostring(self.slotId))
                return
            end
            UI.selectedRuneSlot = self.slotId
            UI:SetStatus("已选择符文槽 " .. tostring(self.slotId), 0.85, 0.62, 1)
            UI:RefreshRunePanel()
        end)
        runeSlot:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:AddLine("符文槽 " .. tostring(self.slotId or i), 0.95, 0.55, 1)
            if self.runeItemId and self.runeItemId > 0 then
                GameTooltip:AddLine(self.runeName or "", 1, 1, 1)
                if self.runeDesc and self.runeDesc ~= "" then
                    GameTooltip:AddLine(self.runeDesc, 0.3, 1, 0.45, true)
                end
                GameTooltip:AddLine("右键移除", 0.8, 0.8, 0.8)
            else
                GameTooltip:AddLine("空槽", 0.8, 0.8, 0.8)
            end
            GameTooltip:Show()
        end)
        runeSlot:SetScript("OnLeave", function() GameTooltip:Hide() end)
        f.runeSlots[i] = runeSlot
    end

    f.runeBagButtons = {}
    for i = 1, RUNE_BAG_PAGE_SIZE do
        local row = CreateFrame("Button", nil, runePanel)
        row:SetSize(230, 24)
        row:SetPoint("TOPLEFT", 236, -96 - (i - 1) * 25)
        row:SetBackdrop({
            bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
            edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
            tile = true,
            tileSize = 16,
            edgeSize = 10,
            insets = { left = 3, right = 3, top = 3, bottom = 3 }
        })
        row:SetBackdropColor(0.045, 0.04, 0.055, 0.92)
        row.name = MakeLine(row, "", 8, -4, "GameFontHighlightSmall")
        row.name:SetWidth(128)
        row.slot = MakeLine(row, "", 145, -4, "GameFontDisableSmall")
        row.slot:SetWidth(52)
        row.desc = MakeLine(row, "", 8, -14, "GameFontDisableSmall")
        row.desc:SetWidth(205)
        row:RegisterForClicks("LeftButtonUp")
        row:SetScript("OnClick", function(self)
            if not self.runeItemId then return end
            UI.selectedRuneItemId = self.runeItemId
            UI:SetStatus("已选择符文 " .. tostring(self.name:GetText() or ""), 1, 0.82, 0.25)
            UI:RefreshRunePanel()
        end)
        row:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            if self.runeItemId then
                local link = select(2, ItemForge_GetItemInfo(self.runeItemId))
                local shown = link and ItemForge_SetItemTooltip(GameTooltip, link)
                if not shown then
                    GameTooltip:AddLine(self.name:GetText() or "符文", 1, 1, 1)
                end
            end
            GameTooltip:Show()
        end)
        row:SetScript("OnLeave", function() GameTooltip:Hide() end)
        f.runeBagButtons[i] = row
    end

    f.runeEmptyBag = MakeLine(runePanel, "背包中没有可用符文", 240, -112, "GameFontDisable")
    f.runeEmptyBag:SetWidth(220)
    f.runeBagPrev = CreateFrame("Button", nil, runePanel, "UIPanelButtonTemplate")
    f.runeBagPrev:SetSize(52, 22)
    f.runeBagPrev:SetPoint("BOTTOMLEFT", runePanel, "BOTTOMLEFT", 274, 18)
    f.runeBagPrev:SetText("上一页")
    f.runeBagPrev:SetScript("OnClick", function()
        UI.runeBagPage = math.max(1, UI.runeBagPage - 1)
        UI:RefreshRunePanel()
    end)
    f.runeBagPageText = MakeLine(runePanel, "1/1", 0, 0, "GameFontNormalSmall")
    f.runeBagPageText:ClearAllPoints()
    f.runeBagPageText:SetPoint("LEFT", f.runeBagPrev, "RIGHT", 10, 0)
    f.runeBagPageText:SetWidth(42)
    f.runeBagPageText:SetJustifyH("CENTER")
    f.runeBagNext = CreateFrame("Button", nil, runePanel, "UIPanelButtonTemplate")
    f.runeBagNext:SetSize(52, 22)
    f.runeBagNext:SetPoint("LEFT", f.runeBagPageText, "RIGHT", 10, 0)
    f.runeBagNext:SetText("下一页")
    f.runeBagNext:SetScript("OnClick", function()
        local maxPage = math.max(1, math.ceil(#(UI.data.rune.bagRunes or {}) / RUNE_BAG_PAGE_SIZE))
        UI.runeBagPage = math.min(maxPage, UI.runeBagPage + 1)
        UI:RefreshRunePanel()
    end)

    f.status = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    f.status:SetPoint("BOTTOM", 0, 110)
    f.status:SetWidth(460)
    f.status:SetTextColor(0.9, 0.82, 0.55)

    f.recycleLevelLabel = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    f.recycleLevelLabel:SetPoint("BOTTOMLEFT", 54, 76)
    f.recycleLevelLabel:SetText("回收鉴定等级")
    f.recycleLevelLabel:SetTextColor(1, 0.82, 0.25)

    f.recycleLevelDropDown = CreateFrame("Frame", "ItemForgeUIRecycleLevelDropDown", f, "UIDropDownMenuTemplate")
    f.recycleLevelDropDown:SetPoint("BOTTOMLEFT", 168, 61)
    UIDropDownMenu_SetWidth(f.recycleLevelDropDown, 140)
    UIDropDownMenu_JustifyText(f.recycleLevelDropDown, "LEFT")
    UIDropDownMenu_Initialize(f.recycleLevelDropDown, function()
        local function AddLevelOption(text, value)
            local info = UIDropDownMenu_CreateInfo()
            info.text = text
            info.value = value
            info.checked = (UI.recycleLevel or 0) == value
            info.func = function()
                UI.recycleLevel = value
                UI:RefreshRecycleLevelDropdown()
            end
            UIDropDownMenu_AddButton(info)
        end

        AddLevelOption("全部等级", 0)
        for i = 1, #UI.recycleLevels do
            local level = UI.recycleLevels[i]
            AddLevelOption("鉴定等级 " .. tostring(level), level)
        end
    end)

    f.primary = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
    f.primary:SetSize(104, 30)
    f.primary:SetPoint("BOTTOMLEFT", 46, 30)
    f.primary:SetText("强化")

    f.refresh = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
    f.refresh:SetSize(104, 30)
    f.refresh:SetPoint("LEFT", f.primary, "RIGHT", 8, 0)
    f.refresh:SetText("刷新")

    f.clear = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
    f.clear:SetSize(104, 30)
    f.clear:SetPoint("LEFT", f.refresh, "RIGHT", 8, 0)
    f.clear:SetText("清空")
    f.clear:SetScript("OnClick", function()
        UI:ClearSelected("已清空")
    end)

    f.batchRecycle = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
    f.batchRecycle:SetSize(104, 30)
    f.batchRecycle:SetPoint("LEFT", f.clear, "RIGHT", 8, 0)
    f.batchRecycle:SetText("批量回收")
    f.batchRecycle:SetScript("OnClick", function()
        UI:RequestBatchRecycle()
    end)
    f.batchRecycle:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_TOP")
        GameTooltip:AddLine("批量回收", 1, 0.3, 0.2)
        GameTooltip:AddLine("按左侧选择的鉴定等级回收背包装备", 1, 1, 1, true)
        GameTooltip:AddLine("不会处理装备栏和银行物品", 0.75, 0.75, 0.75, true)
        GameTooltip:Show()
    end)
    f.batchRecycle:SetScript("OnLeave", function() GameTooltip:Hide() end)
    f:SetScript("OnHide", function()
        UI:ClearSelected("")
    end)

    f:Hide()
    self.frame = f
    if UISpecialFrames then
        tinsert(UISpecialFrames, "ItemForgeUIFrame")
    end
    self:RefreshSelectedDisplay()
    self:RefreshContent()
    self:RefreshRecycleLevelDropdown()
end

function UI:CreateLauncherButton()
    if self.launcherButton or not UIParent then return end

    local button = CreateFrame("Button", "ItemForgeUILauncherButton", UIParent)
    button:SetSize(64, 58)
    button:SetFrameStrata("MEDIUM")
    button:SetFrameLevel(10)
    button:SetMovable(true)
    button:EnableMouse(true)
    button:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    button:RegisterForDrag("LeftButton")

    local iconFrame = CreateFrame("Frame", nil, button)
    iconFrame:SetSize(31, 31)
    iconFrame:SetPoint("TOP", 0, -1)
    iconFrame:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8X8",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = false,
        edgeSize = 10,
        insets = { left = 2, right = 2, top = 2, bottom = 2 }
    })
    iconFrame:SetBackdropColor(0.02, 0.01, 0.01, 0.95)
    iconFrame:SetBackdropBorderColor(0.95, 0.68, 0.18, 1)

    local icon = iconFrame:CreateTexture(nil, "ARTWORK")
    icon:SetPoint("TOPLEFT", 4, -4)
    icon:SetPoint("BOTTOMRIGHT", -4, 4)
    icon:SetTexture("Interface\\Icons\\INV_Hammer_20")
    button.icon = icon

    local hover = button:CreateTexture(nil, "OVERLAY")
    hover:SetTexture("Interface\\Buttons\\UI-ActionButton-Border")
    hover:SetBlendMode("ADD")
    hover:SetSize(48, 48)
    hover:SetPoint("CENTER", iconFrame, "CENTER", 0, 0)
    hover:SetVertexColor(1, 0.72, 0.15, 0.9)
    hover:Hide()
    button.hover = hover

    local label = button:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    label:SetPoint("TOP", iconFrame, "BOTTOM", 0, -2)
    label:SetText("装备锻造")
    label:SetTextColor(1, 0.82, 0.25)
    label:SetShadowColor(0, 0, 0, 1)
    label:SetShadowOffset(1, -1)
    button.label = label

    button:SetScript("OnEnter", function(self)
        if self.hover then self.hover:Show() end
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:AddLine("装备锻造", 1, 0.82, 0.25)
        GameTooltip:AddLine("左键：打开/关闭界面", 0.8, 0.8, 0.8)
        GameTooltip:AddLine("右键：切换强化/成长/符文", 0.8, 0.8, 0.8)
        GameTooltip:AddLine("拖动：移动按钮", 0.55, 0.75, 1)
        GameTooltip:Show()
    end)
    button:SetScript("OnLeave", function(self)
        if self.hover then self.hover:Hide() end
        GameTooltip:Hide()
    end)
    button:SetScript("OnClick", function(_, mouseButton)
        if mouseButton == "RightButton" then
            if UI.activeTab == "enhance" then
                UI:SetActiveTab("growth")
            elseif UI.activeTab == "growth" then
                UI:SetActiveTab("rune")
            else
                UI:SetActiveTab("enhance")
            end
            UI:CreateFrame()
            SendAddon(IDENTIFICATION_PREFIX, "RECYCLE_LEVELS")
            UI.frame:Show()
        else
            UI:Toggle()
        end
    end)
    button:SetScript("OnDragStart", function(self)
        self:StartMoving()
    end)
    button:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        local cx, cy = self:GetCenter()
        local ux, uy = UIParent:GetCenter()
        if cx and cy and ux and uy then
            local db = GetDB()
            db.launcherX = cx - ux
            db.launcherY = cy - uy
        end
        PositionLauncherButton(self)
    end)

    self.launcherButton = button
    PositionLauncherButton(button)
end

function UI:Toggle()
    self:CreateFrame()
    if self.frame:IsShown() then
        self.frame:Hide()
    else
        SendAddon(IDENTIFICATION_PREFIX, "RECYCLE_LEVELS")
        self.frame:Show()
    end
end

local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:RegisterEvent("CHAT_MSG_ADDON")
eventFrame:SetScript("OnEvent", function(_, event, ...)
    if event == "ADDON_LOADED" then
        local addon = ...
        if addon == ADDON_NAME then
            RegisterPrefix(ENHANCE_PREFIX)
            RegisterPrefix(GROWTH_PREFIX)
            RegisterPrefix(RUNE_PREFIX)
            RegisterPrefix(REFINE_PREFIX)
            RegisterPrefix(IDENTIFICATION_PREFIX)
            InstallPickupHooks()
            InstallModifiedClickHooks()
            UI:CreateFrame()
        end
    elseif event == "CHAT_MSG_ADDON" then
        local prefix, message = ...
        if (prefix == ENHANCE_PREFIX or prefix == GROWTH_PREFIX or prefix == RUNE_PREFIX or prefix == REFINE_PREFIX or prefix == IDENTIFICATION_PREFIX) and message then
            UI:OnAddonMessage(prefix, message)
        end
    end
end)

SLASH_ITEMFORGEUI1 = "/forgeui"
SLASH_ITEMFORGEUI2 = "/锻造界面"
SlashCmdList["ITEMFORGEUI"] = function()
    UI:Toggle()
end


-- Native IGRO channel: the server sends kind=4 snapshots for NativeUI
-- sessions; the addon message above remains the fallback for old clients.
local NativeGrowthFrame = CreateFrame("Frame")
local nativeGrowthElapsed = 0
local lastNativeGrowthRevision = nil
local lastNativeGrowthData = nil
NativeGrowthFrame:SetScript("OnUpdate", function(_, elapsed)
    nativeGrowthElapsed = nativeGrowthElapsed + (elapsed or 0)
    if nativeGrowthElapsed < 0.2 then return end
    nativeGrowthElapsed = 0
    if not NativeUIGrowthData then return end
    local payload, revision = NativeUIGrowthData()
    if not payload or payload == "" then return end
    if revision == lastNativeGrowthRevision and payload == lastNativeGrowthData then return end
    lastNativeGrowthRevision = revision
    lastNativeGrowthData = payload
    if UI and UI.HandleGrowthPayload then
        UI:HandleGrowthPayload(payload)
    end
end)