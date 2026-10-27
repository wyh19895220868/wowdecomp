local ADDON_NAME = "MaterialPreview"
local TEXTURE_ROOT = "Interface\\NativeUI\\BundledAddOns\\MaterialPreview\\Textures\\"

-- This is an intentionally small, curated first page set. The converter in
-- Tools/Convert-WowUiTexturesToTga.ps1 can add more PNGs without copying the
-- complete 10+ GB extraction into the client.
local ITEMS = {
    { file = "ACHIEVEMENTFRAME__UI-ACHIEVEMENT-ACHIEVEMENTBACKGROUND.tga", name = "成就背景", source = "ACHIEVEMENTFRAME\\UI-ACHIEVEMENT-ACHIEVEMENTBACKGROUND.PNG", width = 512, height = 1024 },
    { file = "ACHIEVEMENTFRAME__UI-Achievement-Header.tga", name = "成就标题", source = "ACHIEVEMENTFRAME\\UI-Achievement-Header.PNG", width = 512, height = 256 },
    { file = "ACHIEVEMENTFRAME__UI-ACHIEVEMENT-PARCHMENT.tga", name = "成就羊皮纸", source = "ACHIEVEMENTFRAME\\UI-ACHIEVEMENT-PARCHMENT.PNG", width = 512, height = 512 },
    { file = "ACHIEVEMENTFRAME__UI-Achievement-IconFrame.tga", name = "成就图标框", source = "ACHIEVEMENTFRAME\\UI-Achievement-IconFrame.PNG", width = 128, height = 128 },
    { file = "ACHIEVEMENTFRAME__UI-Achievement-Borders.tga", name = "成就边框", source = "ACHIEVEMENTFRAME\\UI-Achievement-Borders.PNG", width = 512, height = 256 },
    { file = "ACHIEVEMENTFRAME__UI-Achievement-Tsunami-Horizontal.tga", name = "成就装饰横条", source = "ACHIEVEMENTFRAME\\UI-Achievement-Tsunami-Horizontal.PNG", width = 512, height = 16 },
    { file = "ACHIEVEMENTFRAME__UI-Achievement-Title.tga", name = "成就标题装饰", source = "ACHIEVEMENTFRAME\\UI-Achievement-Title.PNG", width = 512, height = 64 },
    { file = "ACHIEVEMENTFRAME__UIFrameAchievementWood.tga", name = "成就木框", source = "ACHIEVEMENTFRAME\\UIFrameAchievementWood.PNG", width = 128, height = 512 },

    { file = "DialogFrame__UIFrameDialogBox.tga", name = "对话框边缘", source = "DialogFrame\\UIFrameDialogBox.PNG", width = 64, height = 256 },
    { file = "DialogFrame__UIFrameDialogBoxBackground.tga", name = "对话框背景", source = "DialogFrame\\UIFrameDialogBoxBackground.PNG", width = 64, height = 64 },
    { file = "DialogFrame__UI-DialogBox-Gold-Header.tga", name = "金色对话框标题", source = "DialogFrame\\UI-DialogBox-Gold-Header.PNG", width = 256, height = 64 },
    { file = "DialogFrame__UI-DialogBox-Gold-Dragon.tga", name = "金色龙饰", source = "DialogFrame\\UI-DialogBox-Gold-Dragon.PNG", width = 128, height = 128 },
    { file = "DialogFrame__UI-DialogBox-Border.tga", name = "对话框边框", source = "DialogFrame\\UI-DialogBox-Border.PNG", width = 256, height = 32 },
    { file = "DialogFrame__UI-DialogBox-Corner.tga", name = "对话框角", source = "DialogFrame\\UI-DialogBox-Corner.PNG", width = 32, height = 32 },
    { file = "DialogFrame__DialogFrame-Top.tga", name = "对话框顶部", source = "DialogFrame\\DialogFrame-Top.PNG", width = 32, height = 16 },
    { file = "DialogFrame__DialogFrame-Corners.tga", name = "对话框四角", source = "DialogFrame\\DialogFrame-Corners.PNG", width = 64, height = 64 },

    { file = "COMMON__CommonButtons.tga", name = "通用按钮图集", source = "COMMON\\CommonButtons.PNG", width = 1024, height = 1024 },
    { file = "COMMON__CommonButtonsDropdown.tga", name = "下拉按钮图集", source = "COMMON\\CommonButtonsDropdown.PNG", width = 64, height = 64 },
    { file = "COMMON__CommonForms.tga", name = "通用控件图集", source = "COMMON\\CommonForms.PNG", width = 512, height = 256 },
    { file = "COMMON__Common-Input-Border.tga", name = "输入框边框", source = "COMMON\\Common-Input-Border.PNG", width = 128, height = 32 },
    { file = "COMMON__ParchmentPopup.tga", name = "羊皮纸弹窗", source = "COMMON\\ParchmentPopup.PNG", width = 1024, height = 1024 },
    { file = "COMMON__GoldRing.tga", name = "金环", source = "COMMON\\GoldRing.PNG", width = 64, height = 64 },
    { file = "COMMON__icon-alliance.tga", name = "联盟图标", source = "COMMON\\icon-alliance.PNG", width = 64, height = 64 },
    { file = "COMMON__icon-horde.tga", name = "部落图标", source = "COMMON\\icon-horde.PNG", width = 64, height = 64 },

    { file = "ContainerFrame__UI-BackpackBackground.tga", name = "背包背景", source = "ContainerFrame\\UI-BackpackBackground.PNG", width = 256, height = 256 },
    { file = "ContainerFrame__UI-Bag-5x4.tga", name = "5×4 背包框", source = "ContainerFrame\\UI-Bag-5x4.PNG", width = 256, height = 256 },
    { file = "CHARACTERFRAME__Char-Paperdoll-Horizontal.tga", name = "角色纸娃娃横条", source = "CHARACTERFRAME\\Char-Paperdoll-Horizontal.PNG", width = 32, height = 16 },
    { file = "CHARACTERFRAME__EquipmentManager.tga", name = "装备管理器", source = "CHARACTERFRAME\\EquipmentManager.PNG", width = 32, height = 32 },

    { file = "MainMenuBar__MainMenuBar.tga", name = "主菜单栏", source = "MainMenuBar\\MainMenuBar.PNG", width = 1024, height = 256 },
    { file = "MainMenuBar__UI-MainMenuBar-Human.tga", name = "人类主菜单栏", source = "MainMenuBar\\UI-MainMenuBar-Human.PNG", width = 256, height = 256 },
    { file = "MainMenuBar__UI-XP-Bar.tga", name = "经验条", source = "MainMenuBar\\UI-XP-Bar.PNG", width = 64, height = 64 },
    { file = "MainMenuBar__UI-MainMenu-ScrollUpButton-Up.tga", name = "菜单上滚按钮", source = "MainMenuBar\\UI-MainMenu-ScrollUpButton-Up.PNG", width = 32, height = 32 },

    { file = "TalentFrame__bg-mage-frost.tga", name = "冰霜法师背景", source = "TalentFrame\\bg-mage-frost.PNG", width = 512, height = 512 },
    { file = "TalentFrame__bg-warrior-arms.tga", name = "武器战士背景", source = "TalentFrame\\bg-warrior-arms.PNG", width = 512, height = 512 },
    { file = "TalentFrame__glyph-main.tga", name = "雕文主面板", source = "TalentFrame\\glyph-main.PNG", width = 256, height = 512 },
    { file = "SpellBook__UI-GLYPHFRAME.tga", name = "雕文框", source = "SpellBook\\UI-GLYPHFRAME.PNG", width = 1024, height = 1024 },
}

local State = {
    frame = nil,
    page = 1,
    pageSize = 20,
    tiles = {},
}

local function AddLine(parent, text, font, anchor, relative, x, y, r, g, b, a)
    local line = parent:CreateFontString(nil, "ARTWORK", font)
    line:SetPoint(anchor, relative, anchor, x, y)
    line:SetText(text)
    line:SetTextColor(r or 1, g or 1, b or 1, a or 1)
    return line
end

local function MakeButton(parent, text, width)
    local button = CreateFrame("Button", nil, parent)
    button:SetWidth(width)
    button:SetHeight(24)
    button:SetNormalFontObject(GameFontNormal)
    button:SetHighlightFontObject(GameFontHighlight)
    button:SetText(text)
    local normal = button:CreateTexture(nil, "BACKGROUND")
    normal:SetAllPoints(button)
    normal:SetTexture(0.12, 0.10, 0.07, 0.95)
    button:SetNormalTexture(normal)
    local highlight = button:CreateTexture(nil, "HIGHLIGHT")
    highlight:SetAllPoints(button)
    highlight:SetTexture(0.34, 0.24, 0.08, 0.65)
    button:SetHighlightTexture(highlight)
    return button
end

local function CreateTile(parent, index)
    local tile = CreateFrame("Button", nil, parent)
    tile:SetWidth(184)
    tile:SetHeight(128)
    tile:EnableMouse(true)

    local background = tile:CreateTexture(nil, "BACKGROUND")
    background:SetAllPoints(tile)
    background:SetTexture(0.035, 0.045, 0.06, 0.96)
    tile.background = background

    local edge = tile:CreateTexture(nil, "BORDER")
    edge:SetPoint("TOPLEFT", 0, 0)
    edge:SetPoint("BOTTOMRIGHT", 0, 0)
    edge:SetTexture(0.24, 0.20, 0.12, 1)
    tile.edge = edge

    local image = tile:CreateTexture(nil, "ARTWORK")
    image:SetPoint("TOP", 0, -6)
    image:SetWidth(164)
    image:SetHeight(88)
    image:SetTexCoord(0, 1, 0, 1)
    tile.image = image

    local label = tile:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    label:SetPoint("BOTTOMLEFT", 6, 7)
    label:SetPoint("BOTTOMRIGHT", -6, 7)
    label:SetJustifyH("CENTER")
    label:SetTextColor(0.95, 0.85, 0.58, 1)
    tile.label = label

    local highlight = tile:CreateTexture(nil, "HIGHLIGHT")
    highlight:SetAllPoints(tile)
    highlight:SetTexture(0.45, 0.32, 0.08, 0.35)
    tile:SetHighlightTexture(highlight)

    tile:SetScript("OnEnter", function(self)
        local item = self.item
        if not item then return end
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:AddLine(item.name, 1, 0.82, 0.2)
        GameTooltip:AddLine(item.source, 0.75, 0.75, 0.75, true)
        GameTooltip:AddLine(string.format("原图尺寸：%d × %d", item.width, item.height), 0.65, 0.85, 1)
        GameTooltip:AddLine("这是客户端实际加载的 TGA 贴图", 0.55, 1, 0.55)
        GameTooltip:Show()
    end)
    tile:SetScript("OnLeave", function() GameTooltip:Hide() end)
    return tile
end

local function UpdateTiles()
    local state = State
    local first = (state.page - 1) * state.pageSize + 1
    for i = 1, state.pageSize do
        local tile = state.tiles[i]
        local item = ITEMS[first + i - 1]
        if item then
            local scale = math.min(164 / item.width, 84 / item.height)
            tile.item = item
            tile.image:SetTexture(TEXTURE_ROOT .. item.file)
            tile.image:SetWidth(math.max(12, item.width * scale))
            tile.image:SetHeight(math.max(12, item.height * scale))
            tile.label:SetText(item.name)
            tile:Show()
        else
            tile.item = nil
            tile.image:SetTexture(nil)
            tile.label:SetText(nil)
            tile:Hide()
        end
    end

    local totalPages = math.max(1, math.ceil(#ITEMS / state.pageSize))
    state.pageText:SetText(string.format("第 %d / %d 页　共 %d 个精选素材", state.page, totalPages, #ITEMS))
    state.previous:SetEnabled(state.page > 1)
    state.next:SetEnabled(state.page < totalPages)
end

local function SetPage(page)
    local totalPages = math.max(1, math.ceil(#ITEMS / State.pageSize))
    State.page = math.max(1, math.min(totalPages, page))
    UpdateTiles()
end

local function EnsureFrame()
    if State.frame then return State.frame end

    local frame = CreateFrame("Frame", "MaterialPreviewFrame", UIParent)
    frame:SetWidth(1000)
    frame:SetHeight(650)
    frame:SetPoint("CENTER")
    frame:SetFrameStrata("DIALOG")
    frame:EnableMouse(true)
    frame:SetMovable(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", function(self) self:StartMoving() end)
    frame:SetScript("OnDragStop", function(self) self:StopMovingOrSizing() end)

    local background = frame:CreateTexture(nil, "BACKGROUND")
    background:SetAllPoints(frame)
    background:SetTexture(0.015, 0.02, 0.03, 0.97)

    local topLine = frame:CreateTexture(nil, "BORDER")
    topLine:SetPoint("TOPLEFT", 0, -34)
    topLine:SetPoint("TOPRIGHT", 0, -34)
    topLine:SetHeight(1)
    topLine:SetTexture(0.55, 0.40, 0.14, 1)

    AddLine(frame, "WoW UI 素材 · 游戏内预览", "GameFontNormalLarge", "TOPLEFT", frame, 16, -12, 1, 0.82, 0.24)
    AddLine(frame, "3.3.5 客户端直接加载 TGA；悬停素材可查看来源和尺寸", "GameFontHighlightSmall", "TOPLEFT", frame, 18, -40, 0.70, 0.78, 0.85)

    local close = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
    close:SetPoint("TOPRIGHT", -3, -3)
    close:SetScript("OnClick", function() frame:Hide() end)

    local grid = CreateFrame("Frame", nil, frame)
    grid:SetPoint("TOPLEFT", 16, -76)
    grid:SetWidth(968)
    grid:SetHeight(520)
    for i = 1, State.pageSize do
        local tile = CreateTile(grid, i)
        local column = (i - 1) % 5
        local row = math.floor((i - 1) / 5)
        tile:SetPoint("TOPLEFT", column * 194, -row * 130)
        State.tiles[i] = tile
    end

    local previous = MakeButton(frame, "上一页", 90)
    previous:SetPoint("BOTTOMLEFT", 16, 14)
    previous:SetScript("OnClick", function() SetPage(State.page - 1) end)
    State.previous = previous

    local nextButton = MakeButton(frame, "下一页", 90)
    nextButton:SetPoint("BOTTOMRIGHT", -16, 14)
    nextButton:SetScript("OnClick", function() SetPage(State.page + 1) end)
    State.next = nextButton

    local pageText = AddLine(frame, "", "GameFontHighlight", "BOTTOM", frame, 0, 18, 0.85, 0.85, 0.85)
    pageText:SetJustifyH("CENTER")
    State.pageText = pageText

    State.frame = frame
    tinsert(UISpecialFrames, "MaterialPreviewFrame")
    UpdateTiles()
    return frame
end

local function TogglePreview()
    local frame = EnsureFrame()
    if frame:IsShown() then
        frame:Hide()
    else
        frame:Show()
        UpdateTiles()
    end
end

SLASH_MATERIALPREVIEW1 = "/素材"
SLASH_MATERIALPREVIEW2 = "/materialpreview"
SLASH_MATERIALPREVIEW3 = "/matpreview"
SlashCmdList.MATERIALPREVIEW = TogglePreview

-- Keep the panel available after login without forcing it open.
local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("PLAYER_LOGIN")
eventFrame:SetScript("OnEvent", function()
    EnsureFrame():Hide()
    DEFAULT_CHAT_FRAME:AddMessage("|cffd9a441素材预览已加载|r：输入 /素材 查看游戏内贴图")
end)
