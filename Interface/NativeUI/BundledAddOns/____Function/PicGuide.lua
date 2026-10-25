---@diagnostic disable: missing-parameter

local NavBtnCount = 2;           --导航条数量 如果增加导航条 必须修改对应此项数量
local ChildHeight = 640;         --不可更改

local BtnFirstY = -20;                        --导航条起始位置
local BtnSpace = 10;                          --导航条位置间的间距
local BtnHeight = 40;                         --导航条高度 可修改 必须比子项高
local SubBtnHeight = 40;                      --子项导航条高度 可修改
local BtnLastIndex = NavBtnCount + 1;         --不可更改
local PageSize = 20;
local CreaturePageSize = 7;
local CreatureCameraScale = {
	[11321] = 0.55,
};
local IsFirstShow = true;                     --不可更改
local ScaleFactor = 1.0;                      --缩放因子 默认为1.0

local PicGuideFrame = CreateFrame("Frame", "PicGuideFrame", UIParent);
PicGuideFrame:SetSize(1080, 720);
PicGuideFrame:RegisterForDrag("LeftButton");
PicGuideFrame:SetPoint("CENTER");
PicGuideFrame:SetToplevel(true);
PicGuideFrame:SetClampedToScreen(true);
PicGuideFrame:SetBackdrop({ bgFile = PicGuideFile });
tinsert(UISpecialFrames, "PicGuideFrame");
PicGuideFrame:SetScale(ScaleFactor);
PicGuideFrame:Hide();

-- 关闭按钮
local PicGuideClose = CreateFrame("Button", "PicGuideClose", PicGuideFrame, "UIPanelCloseButton");
PicGuideClose:SetPoint("TOPRIGHT", 8, -12);
PicGuideClose:EnableMouse(true);
PicGuideClose:SetSize(40, 40);

-- 图标
PicGuideFrame.Logo = CreateFrame("Button", "PicGuideLogo", PicGuideFrame);
PicGuideFrame.Logo:SetSize(65, 65);
PicGuideFrame.Logo:SetPoint("TOPLEFT", 15, -15);
PicGuideFrame.Logo:SetNormalTexture("Interface\\Icons\\Logo");

-- 标题
PicGuideFrame.Title = PicGuideFrame:CreateFontString();
PicGuideFrame.Title:SetFont(Dream_GameFont, 24);
PicGuideFrame.Title:SetShadowOffset(1, -1);
PicGuideFrame.Title:SetPoint("TOP", PicGuideFrame, "TOP", 0, -20);
PicGuideFrame.Title:SetText(PicGuideTitle);

-- 缩放控制
local ScaleControlFrame = CreateFrame("Frame", "ScaleControlFrame", PicGuideFrame);
ScaleControlFrame:SetSize(120, 24);
ScaleControlFrame:SetPoint("TOPRIGHT", PicGuideFrame, "TOPRIGHT", -60, -20);

-- Create the label before the button callbacks close over it.  Declaring it
-- below the callbacks makes Lua resolve ScaleText as a missing global when a
-- scale button is clicked.
local ScaleText = ScaleControlFrame:CreateFontString();
ScaleText:SetFont(Dream_GameFont, 10);
ScaleText:SetPoint("CENTER");
ScaleText:SetText(string.format("缩放: %.1fx", ScaleFactor));

-- 缩小按钮
local ScaleDownBtn = CreateFrame("Button", "ScaleDownBtn", ScaleControlFrame, "UIPanelButtonTemplate");
ScaleDownBtn:SetSize(30, 18);
ScaleDownBtn:SetPoint("LEFT");
ScaleDownBtn:SetText("-");
ScaleDownBtn:SetScript("OnClick", function(self)
    ScaleFactor = math.max(0.5, ScaleFactor - 0.1);
    PicGuideFrame:SetScale(ScaleFactor);
    ScaleText:SetText(string.format("缩放: %.1fx", ScaleFactor));
end);

-- 放大按钮
local ScaleUpBtn = CreateFrame("Button", "ScaleUpBtn", ScaleControlFrame, "UIPanelButtonTemplate");
ScaleUpBtn:SetSize(30, 18);
ScaleUpBtn:SetPoint("RIGHT");
ScaleUpBtn:SetText("+");
ScaleUpBtn:SetScript("OnClick", function(self)
    ScaleFactor = math.min(2.0, ScaleFactor + 0.1);
    PicGuideFrame:SetScale(ScaleFactor);
    ScaleText:SetText(string.format("缩放: %.1fx", ScaleFactor));
end);

local PicGuideScrollFrame = CreateFrame("ScrollFrame", "PicGuideScrollFrame", PicGuideFrame);
PicGuideScrollFrame:SetSize(320, ChildHeight);
PicGuideScrollFrame:SetPoint("LEFT", 20, -50);
PicGuideScrollFrame:Show();
PicGuideScrollFrame:EnableMouse(true);
PicGuideScrollFrame:EnableMouseWheel(true);

local PicGuideScrollChildFrame = CreateFrame("Frame", "PicGuideScrollChildFrame", PicGuideScrollFrame);
PicGuideScrollChildFrame:SetSize(320, ChildHeight);
PicGuideScrollChildFrame:SetPoint("CENTER");
PicGuideScrollChildFrame:Show();
PicGuideScrollFrame:SetScrollChild(PicGuideScrollChildFrame);

local PicGuideSlider = CreateFrame("Slider", "PicGuideSlider", PicGuideScrollFrame, "OptionsSliderTemplate");
PicGuideSlider:SetOrientation("VERTICAL");
_G[PicGuideSlider:GetName().."High"]:Hide();
_G[PicGuideSlider:GetName().."Low"]:Hide();
PicGuideSlider:SetMinMaxValues(0, 100);
PicGuideSlider:SetValue(0);
PicGuideSlider:SetValueStep(1.0);
PicGuideSlider:SetPoint("RIGHT", PicGuideScrollFrame, "RIGHT", -15, 0);
PicGuideSlider:SetSize(20, PicGuideScrollFrame:GetHeight() - 20);
PicGuideSlider:Hide();

PicGuideSlider:SetScript("OnValueChanged",
function(self, offset)
	if (self:IsShown()) then
        PicGuideScrollFrame:SetVerticalScroll(math.ceil((PicGuideScrollChildFrame:GetHeight() - PicGuideScrollFrame:GetHeight()) / 100 * self:GetValue()))
	end
end);

PicGuideScrollFrame:SetScript("OnMouseWheel",
function(self, Val)
	if (not PicGuideSlider:IsShown()) then return; end
	local MinVal,MaxVal = PicGuideSlider:GetMinMaxValues()
	local InVal = PicGuideSlider:GetValue()
	local De = InVal - (Val * 8)
	De = max(De, MinVal)
	De = min(De, MaxVal)
	if (De ~= InVal) then
		PicGuideSlider:SetValue(De);
	end
end);

local NavBtn1 = CreateFrame("CheckButton", "NavBtn1", PicGuideScrollChildFrame);
NavBtn1:SetNormalTexture("Interface\\AchievementFrame\\UI-Achievement-Category-Background");
NavBtn1:SetHighlightTexture("Interface\\AchievementFrame\\UI-Achievement-Category-Highlight");
NavBtn1:GetNormalTexture():SetTexCoord(0, 0.6640625, 0.105, 0.6855);
NavBtn1:GetHighlightTexture():SetTexCoord(0, 0.6640625, 0.105, 0.6855);
NavBtn1:SetSize(250, BtnHeight);
local NavBtnNavBtnStr1 = NavBtn1:CreateFontString("NavBtnNavBtnStr1");
NavBtnNavBtnStr1:SetFont(Dream_GameFont, 18);
NavBtnNavBtnStr1:SetAllPoints(NavBtn1);
NavBtn1:SetFontString(NavBtnNavBtnStr1);
NavBtn1:SetPoint("TOPLEFT", 0, BtnFirstY);
NavBtn1:SetText(NavBtnText1);
NavBtn1:SetID(1);
NavBtn1.SubBtnCount = 0;
NavBtn1.NowSubPageId = 0;
NavBtn1.SubBtns = {};

NavBtn1:SetScript("OnClick",
function(self)
	NavBtnClickUpdateSelect(1);
end);

local NavBtn2 = CreateFrame("CheckButton", "NavBtn2", PicGuideScrollChildFrame);
NavBtn2:SetNormalTexture("Interface\\AchievementFrame\\UI-Achievement-Category-Background");
NavBtn2:SetHighlightTexture("Interface\\AchievementFrame\\UI-Achievement-Category-Highlight");
NavBtn2:GetNormalTexture():SetTexCoord(0, 0.6640625, 0.105, 0.6855);
NavBtn2:GetHighlightTexture():SetTexCoord(0, 0.6640625, 0.105, 0.6855);
NavBtn2:SetSize(250, BtnHeight);
local NavBtnNavBtnStr2 = NavBtn2:CreateFontString("NavBtnNavBtnStr2");
NavBtnNavBtnStr2:SetFont(Dream_GameFont, 18);
NavBtnNavBtnStr2:SetAllPoints(NavBtn2);
NavBtn2:SetFontString(NavBtnNavBtnStr2);
NavBtn2:SetPoint("TOPLEFT", 0, BtnFirstY - BtnHeight - BtnSpace);
NavBtn2:SetText(NavBtnText2);
NavBtn2:SetID(2);
NavBtn2.SubBtnCount = 0;
NavBtn2.NowSubPageId = 0;
NavBtn2.SubBtns = {};

NavBtn2:SetScript("OnClick",
function(self)
	NavBtnClickUpdateSelect(2);
end);

-- 预先创建每个子项的页面框架
local NavBtnSubFrame = CreateFrame("Frame", "NavBtnSubFrame", PicGuideFrame);
NavBtnSubFrame:SetSize(835, 600);
NavBtnSubFrame:RegisterForDrag("LeftButton");
NavBtnSubFrame:SetPoint("CENTER", 150, -45);
NavBtnSubFrame.PageIndex = 1;
NavBtnSubFrame.PageCount = 1;
NavBtnSubFrame.TypeIndex = 1;
NavBtnSubFrame.ListBtns = {};
for N = 1, PageSize do
	NavBtnSubFrame.ListBtns[N] = CreateFrame("Button", NavBtnSubFrame:GetName().."ListBtns"..N, NavBtnSubFrame);
	NavBtnSubFrame.ListBtns[N]:SetBackdrop({ edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", edgeSize = 12, insets = { left = 3, right = 3, top = 3, bottom = 3 }});
	NavBtnSubFrame.ListBtns[N].NormalTexture = NavBtnSubFrame.ListBtns[N]:CreateTexture(nil, "BACKGROUND");
    NavBtnSubFrame.ListBtns[N].NormalTexture:SetTexture("Interface\\Icons\\CPic2");
	NavBtnSubFrame.ListBtns[N].NormalTexture:ClearAllPoints();
    NavBtnSubFrame.ListBtns[N].NormalTexture:SetPoint("TOPLEFT", NavBtnSubFrame.ListBtns[N], 5, -5);
    NavBtnSubFrame.ListBtns[N].NormalTexture:SetSize(72, 72);
	NavBtnSubFrame.ListBtns[N]:SetNormalTexture(NavBtnSubFrame.ListBtns[N].NormalTexture);
	NavBtnSubFrame.ListBtns[N]:SetHighlightTexture("Interface\\Icons\\CPic4");
	NavBtnSubFrame.ListBtns[N]:SetSize(155, 185);
	if (N < 6) then
		NavBtnSubFrame.ListBtns[N]:SetPoint("TOPLEFT", (N - 1) * NavBtnSubFrame.ListBtns[N]:GetWidth() + 15, -(NavBtnSubFrame.ListBtns[N]:GetHeight() * 0 + 10));
	elseif (N < 11) then
		NavBtnSubFrame.ListBtns[N]:SetPoint("TOPLEFT", (N - 6) * NavBtnSubFrame.ListBtns[N]:GetWidth() + 15, -(NavBtnSubFrame.ListBtns[N]:GetHeight() * 1 + 10));
	else
		NavBtnSubFrame.ListBtns[N]:SetPoint("TOPLEFT", (N - 11) * NavBtnSubFrame.ListBtns[N]:GetWidth() + 15, -(NavBtnSubFrame.ListBtns[N]:GetHeight() * 2 + 10));
	end

	NavBtnSubFrame.ListBtns[N]:SetID(0);
	NavBtnSubFrame.ListBtns[N].CreatureName = "";

    NavBtnSubFrame.ListBtns[N].SmButton1 = CreateFrame("Button", NavBtnSubFrame.ListBtns[N]:GetName().."SmButton1", NavBtnSubFrame.ListBtns[N], "DreamPicGuideSmButtonTemplate");
    NavBtnSubFrame.ListBtns[N].SmButton1:SetSize(28, 28);
    NavBtnSubFrame.ListBtns[N].SmButton1:SetPoint("TOPRIGHT", NavBtnSubFrame.ListBtns[N], "TOPRIGHT", -10, -10);
    NavBtnSubFrame.ListBtns[N].SmButtonStr1 = NavBtnSubFrame.ListBtns[N].SmButton1:CreateFontString(NavBtnSubFrame.ListBtns[N]:GetName().."SmButtonStr1");
    NavBtnSubFrame.ListBtns[N].SmButtonStr1:SetFont(Dream_GameFont, 15);
    NavBtnSubFrame.ListBtns[N].SmButtonStr1:SetAllPoints(NavBtnSubFrame.ListBtns[N].SmButton1);
    NavBtnSubFrame.ListBtns[N].SmButton1:SetFontString(NavBtnSubFrame.ListBtns[N].SmButtonStr1);
	NavBtnSubFrame.ListBtns[N].SmButtonStr1:SetText("属");
	NavBtnSubFrame.ListBtns[N].SmButton1:Hide();

	NavBtnSubFrame.ListBtns[N].SmButton1:SetScript("OnEnter",
    function(self)
        GameTooltip:SetOwner(NavBtnSubFrame.ListBtns[N].SmButton1, "ANCHOR_CURSOR_RIGHT", 20, 0);
		GameTooltip:SetText("激活后可附加属性");
        GameTooltip:Show();
    end);
	NavBtnSubFrame.ListBtns[N].SmButton1:SetScript("OnLeave",
    function(self)
        GameTooltip:Hide();
    end);

	NavBtnSubFrame.ListBtns[N].SmButton2 = CreateFrame("Button", NavBtnSubFrame.ListBtns[N]:GetName().."SmButton2", NavBtnSubFrame.ListBtns[N], "DreamPicGuideSmButtonTemplate");
    NavBtnSubFrame.ListBtns[N].SmButton2:SetSize(28, 28);
    NavBtnSubFrame.ListBtns[N].SmButton2:SetPoint("TOPRIGHT", NavBtnSubFrame.ListBtns[N], "TOPRIGHT", -40, -10);
	NavBtnSubFrame.ListBtns[N].SmButtonStr2 = NavBtnSubFrame.ListBtns[N].SmButton2:CreateFontString(NavBtnSubFrame.ListBtns[N]:GetName().."SmButtonStr2");
    NavBtnSubFrame.ListBtns[N].SmButtonStr2:SetFont(Dream_GameFont, 15);
    NavBtnSubFrame.ListBtns[N].SmButtonStr2:SetAllPoints(NavBtnSubFrame.ListBtns[N].SmButton2);
    NavBtnSubFrame.ListBtns[N].SmButton2:SetFontString(NavBtnSubFrame.ListBtns[N].SmButtonStr2);
	NavBtnSubFrame.ListBtns[N].SmButtonStr2:SetText("技");
	NavBtnSubFrame.ListBtns[N].SmButton2:Hide();

	NavBtnSubFrame.ListBtns[N].SmButton2:SetScript("OnEnter",
    function(self)
        GameTooltip:SetOwner(self, "ANCHOR_CURSOR_RIGHT", 20, 0);
		GameTooltip:SetText("激活后可附加技能");
        GameTooltip:Show();
    end);
	NavBtnSubFrame.ListBtns[N].SmButton2:SetScript("OnLeave",
    function(self)
        GameTooltip:Hide();
    end);

	-- 难度
	NavBtnSubFrame.ListBtns[N].DiffStr = NavBtnSubFrame.ListBtns[N]:CreateFontString();
	NavBtnSubFrame.ListBtns[N].DiffStr:SetSize(80, 30);
    NavBtnSubFrame.ListBtns[N].DiffStr:SetFont(Dream_GameFont, 15);
	NavBtnSubFrame.ListBtns[N].DiffStr:SetPoint("TOP", NavBtnSubFrame.ListBtns[N], "TOP", 35, 0);
	NavBtnSubFrame.ListBtns[N].DiffStr:SetTextColor(255/255, 102/255, 0/255);

	-- Keep the creature name above the model and directly below the difficulty.
	NavBtnSubFrame.ListBtns[N].NameOverlay = CreateFrame("Frame", nil, NavBtnSubFrame.ListBtns[N]);
	NavBtnSubFrame.ListBtns[N].NameOverlay:SetAllPoints(NavBtnSubFrame.ListBtns[N]);
	NavBtnSubFrame.ListBtns[N].NameOverlay:SetFrameLevel(NavBtnSubFrame.ListBtns[N]:GetFrameLevel() + 2);
	NavBtnSubFrame.ListBtns[N].NameStr = NavBtnSubFrame.ListBtns[N].NameOverlay:CreateFontString();
	NavBtnSubFrame.ListBtns[N].NameStr:SetSize(145, 28);
    NavBtnSubFrame.ListBtns[N].NameStr:SetFont(Dream_GameFont, 14);
	NavBtnSubFrame.ListBtns[N].NameStr:SetPoint("TOP", NavBtnSubFrame.ListBtns[N], "TOP", 0, -24);
	NavBtnSubFrame.ListBtns[N].NameStr:SetTextColor(255/255, 255/255, 0/255);
	NavBtnSubFrame.ListBtns[N].NameStr:SetJustifyH("CENTER");

	-- 属性
	NavBtnSubFrame.ListBtns[N].StatAsStr = NavBtnSubFrame.ListBtns[N]:CreateFontString();
	NavBtnSubFrame.ListBtns[N].StatAsStr:SetSize(150, 30);
    NavBtnSubFrame.ListBtns[N].StatAsStr:SetFont(Dream_GameFont, 15);
    NavBtnSubFrame.ListBtns[N].StatAsStr:SetPoint("BOTTOM", NavBtnSubFrame.ListBtns[N], "BOTTOM", 0, 20);
	NavBtnSubFrame.ListBtns[N].StatAsStr:SetTextColor(0/255, 255/255, 0/255);

	-- 击杀
	NavBtnSubFrame.ListBtns[N].KillCountStr = NavBtnSubFrame.ListBtns[N]:CreateFontString();
	NavBtnSubFrame.ListBtns[N].KillCountStr:SetSize(150, 30);
    NavBtnSubFrame.ListBtns[N].KillCountStr:SetFont(Dream_GameFont, 15);
    NavBtnSubFrame.ListBtns[N].KillCountStr:SetPoint("BOTTOM", NavBtnSubFrame.ListBtns[N], "BOTTOM", 0, 0);
	NavBtnSubFrame.ListBtns[N].KillCountStr:SetTextColor(0/255, 255/255, 0/255);
	NavBtnSubFrame.ListBtns[N].KillCountStr:SetWordWrap(true);

	NavBtnSubFrame.ListBtns[N].IconBtnCenter = CreateFrame("Button", NavBtnSubFrame.ListBtns[N]:GetName().."IconBtnCenter", NavBtnSubFrame.ListBtns[N]);
    NavBtnSubFrame.ListBtns[N].IconBtnCenter:SetSize(64, 64);
    NavBtnSubFrame.ListBtns[N].IconBtnCenter:SetPoint("CENTER", NavBtnSubFrame.ListBtns[N], "CENTER", 0, 0);
	NavBtnSubFrame.ListBtns[N].IconBtnCenter:EnableMouse(false);
	NavBtnSubFrame.ListBtns[N].IconBtnCenter:SetNormalTexture("");
	NavBtnSubFrame.ListBtns[N].IconBtnCenter:GetNormalTexture():SetDesaturated(true);

	NavBtnSubFrame.ListBtns[N].ModelFrame = CreateFrame("PlayerModel", NavBtnSubFrame.ListBtns[N]:GetName().."ModelFrame", NavBtnSubFrame.ListBtns[N]);
    NavBtnSubFrame.ListBtns[N].ModelFrame:SetSize(128, 128);
    NavBtnSubFrame.ListBtns[N].ModelFrame:SetPoint("CENTER", NavBtnSubFrame.ListBtns[N], "CENTER", 0, 10);
	NavBtnSubFrame.ListBtns[N].ModelFrame:SetPosition(0, 0, 0);
	NavBtnSubFrame.ListBtns[N].ModelFrame:SetFrameLevel(NavBtnSubFrame.ListBtns[N]:GetFrameLevel() + 1);
	NavBtnSubFrame.ListBtns[N].ModelFrame.CreatureID = 0;
	NavBtnSubFrame.ListBtns[N].ModelFrame.ModelRetryElapsed = 0;
	NavBtnSubFrame.ListBtns[N].ModelFrame.ModelRetryCount = 0;
	NavBtnSubFrame.ListBtns[N].ModelFrame:SetScript("OnUpdate", function(self, elapsed)
		if (not self:IsShown() or self.CreatureID == 0 or self.ModelRetryCount <= 0) then return; end
		self.ModelRetryElapsed = self.ModelRetryElapsed + elapsed;
		if (self.ModelRetryElapsed >= 0.5) then
			self.ModelRetryElapsed = 0;
			self.ModelRetryCount = self.ModelRetryCount - 1;
			self:SetCreature(self.CreatureID);
		end
	end);

	NavBtnSubFrame.ListBtns[N].ActBtn = CreateFrame("Button", NavBtnSubFrame.ListBtns[N]:GetName().."ActBtn", NavBtnSubFrame.ListBtns[N], "UIPanelButtonTemplate");
    NavBtnSubFrame.ListBtns[N].ActBtn:SetSize(100, 30);
    NavBtnSubFrame.ListBtns[N].ActBtn:SetPoint("BOTTOM", NavBtnSubFrame.ListBtns[N], "BOTTOM", 0, 20);
	NavBtnSubFrame.ListBtns[N].ActBtn:SetText("|cFF006E00激活|r");
	NavBtnSubFrame.ListBtns[N].ActBtn:SetScript("OnClick",
    function(self)
	    Dream_SendData("ActivateItemPicGuide", tostring(NavBtn1.NowSubPageId).."#"..tostring(NavBtnSubFrame.ListBtns[N]:GetID()).."#"..tostring(N));
    end);

	NavBtnSubFrame.ListBtns[N]:SetScript("OnEnter",
    function(self)
		if (NavBtn1.NowSubPageId > 0) then
			GameTooltip:SetOwner(NavBtnSubFrame.ListBtns[N], "ANCHOR_RIGHT", 0, -NavBtnSubFrame.ListBtns[N]:GetHeight());
		    Dream_SetTooltipItemId(GameTooltip, self:GetID());
            GameTooltip:Show();
		elseif (NavBtn2.NowSubPageId > 0) then
			GameTooltip:SetOwner(NavBtnSubFrame.ListBtns[N], "ANCHOR_RIGHT", 0, -NavBtnSubFrame.ListBtns[N]:GetHeight());
		    GameTooltip:SetText("需要击杀怪物名称-> ["..NavBtnSubFrame.ListBtns[N].CreatureName.."]\n需要击杀怪物编号-> ["..NavBtnSubFrame.ListBtns[N]:GetID().."]");
            GameTooltip:Show();
		end
    end);
	NavBtnSubFrame.ListBtns[N]:SetScript("OnLeave",
    function(self)
        GameTooltip:Hide();
    end);
	NavBtnSubFrame.ListBtns[N]:SetScript("OnClick", function(self)
		if (NavBtn2.NowSubPageId > 0 and self:GetID() > 0 and ShowPicGuideCreaturePreview) then
			ShowPicGuideCreaturePreview(self);
		end
	end);

	NavBtnSubFrame.ListBtns[N]:Hide();
end

local function SafeModelCall(Model, Method, ...)
	if (not Model or not Model[Method]) then return false; end
	local Args = { ... };
	return pcall(function() Model[Method](Model, unpack(Args)); end);
end

NavBtnSubFrame.CreaturePreview = CreateFrame("Frame", "PicGuideCreaturePreview", NavBtnSubFrame);
NavBtnSubFrame.CreaturePreview:SetSize(390, 445);
NavBtnSubFrame.CreaturePreview:SetPoint("TOPRIGHT", NavBtnSubFrame, "TOPRIGHT", -40, -10);
NavBtnSubFrame.CreaturePreview:SetBackdrop({ bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", tile = true, tileSize = 16, edgeSize = 12, insets = { left = 4, right = 4, top = 4, bottom = 4 } });
NavBtnSubFrame.CreaturePreview:SetBackdropColor(0.03, 0.03, 0.03, 0.82);
NavBtnSubFrame.CreaturePreview.Title = NavBtnSubFrame.CreaturePreview:CreateFontString();
NavBtnSubFrame.CreaturePreview.Title:SetFont(Dream_GameFont, 18);
NavBtnSubFrame.CreaturePreview.Title:SetPoint("TOP", 0, -18);
NavBtnSubFrame.CreaturePreview.Title:SetTextColor(1, 0.82, 0);
NavBtnSubFrame.CreaturePreview.Difficulty = NavBtnSubFrame.CreaturePreview:CreateFontString();
NavBtnSubFrame.CreaturePreview.Difficulty:SetFont(Dream_GameFont, 15);
NavBtnSubFrame.CreaturePreview.Difficulty:SetPoint("TOP", 0, -46);
NavBtnSubFrame.CreaturePreview.Difficulty:SetTextColor(1, 0.4, 0);
NavBtnSubFrame.CreaturePreview.Model = CreateFrame("DressUpModel", "PicGuideCreaturePreviewModel", NavBtnSubFrame.CreaturePreview);
NavBtnSubFrame.CreaturePreview.Model:SetSize(370, 270);
NavBtnSubFrame.CreaturePreview.Model:SetPoint("TOP", 0, -70);
NavBtnSubFrame.CreaturePreview.Model:EnableMouse(true);
NavBtnSubFrame.CreaturePreview.AttributeTitle = NavBtnSubFrame.CreaturePreview:CreateFontString();
NavBtnSubFrame.CreaturePreview.AttributeTitle:SetFont(Dream_GameFont, 16);
NavBtnSubFrame.CreaturePreview.AttributeTitle:SetPoint("BOTTOM", 0, 72);
NavBtnSubFrame.CreaturePreview.AttributeTitle:SetText("|cffff3333激活属性|r");
NavBtnSubFrame.CreaturePreview.Info = NavBtnSubFrame.CreaturePreview:CreateFontString();
NavBtnSubFrame.CreaturePreview.Info:SetFont(Dream_GameFont, 14);
NavBtnSubFrame.CreaturePreview.Info:SetPoint("BOTTOM", 0, 10);
NavBtnSubFrame.CreaturePreview.Info:SetSize(350, 55);
NavBtnSubFrame.CreaturePreview.Info:SetTextColor(0, 1, 0);
NavBtnSubFrame.CreaturePreview.Info:SetJustifyH("CENTER");
NavBtnSubFrame.CreaturePreview.Info:SetWordWrap(true);
NavBtnSubFrame.CreaturePreview.Model.CreatureID = 0;
NavBtnSubFrame.CreaturePreview.Model.Facing = 0.35;
NavBtnSubFrame.CreaturePreview.Model.CameraScale = 1.35;
NavBtnSubFrame.CreaturePreview.Model.IsRotating = false;
NavBtnSubFrame.CreaturePreview.Model.LastCursorX = 0;
NavBtnSubFrame.CreaturePreview.Model.RetryElapsed = 0;
NavBtnSubFrame.CreaturePreview.Model.RetryCount = 0;
NavBtnSubFrame.CreaturePreview.Model:SetScript("OnUpdate", function(self, Elapsed)
	if (self.IsRotating) then
		local CursorX = GetCursorPosition();
		local Scale = self:GetEffectiveScale();
		if (Scale and Scale > 0) then CursorX = CursorX / Scale; end
		local DeltaX = CursorX - self.LastCursorX;
		self.LastCursorX = CursorX;
		self.Facing = self.Facing + DeltaX * 0.01;
		SafeModelCall(self, "SetFacing", self.Facing);
	end
	if (not self:IsShown() or self.CreatureID <= 0 or self.RetryCount <= 0) then return; end
	self.RetryElapsed = self.RetryElapsed + Elapsed;
	if (self.RetryElapsed >= 0.5) then
		self.RetryElapsed = 0;
		self.RetryCount = self.RetryCount - 1;
		SafeModelCall(self, "ClearModel");
		SafeModelCall(self, "SetCreature", self.CreatureID);
		SafeModelCall(self, "SetCamDistanceScale", self.CameraScale);
		SafeModelCall(self, "SetFacing", self.Facing);
		if (self.DisplayIDs and #self.DisplayIDs > 0) then
			local DisplayIndex = math.min(#self.DisplayIDs, 7 - self.RetryCount);
			local DisplayID = self.DisplayIDs[DisplayIndex];
			if (DisplayID and DisplayID > 0) then SafeModelCall(self, "SetDisplayInfo", DisplayID); end
		end
	end
end);
NavBtnSubFrame.CreaturePreview.Model:SetScript("OnMouseDown", function(self, Button)
	if (Button ~= "LeftButton") then return; end
	local CursorX = GetCursorPosition();
	local Scale = self:GetEffectiveScale();
	if (Scale and Scale > 0) then CursorX = CursorX / Scale; end
	self.LastCursorX = CursorX;
	self.IsRotating = true;
end);
NavBtnSubFrame.CreaturePreview.Model:SetScript("OnMouseUp", function(self, Button)
	if (Button == "LeftButton") then self.IsRotating = false; end
end);
NavBtnSubFrame.CreaturePreview.Model:SetScript("OnHide", function(self)
	self.IsRotating = false;
end);
NavBtnSubFrame.CreaturePreview:Hide();

-- The creature reward details use their own panel below the model. Bonds are
-- rendered in the external CPic5 panel shared with the item guide.
NavBtnSubFrame.CreaturePreview.AttributeTitle:Hide();
NavBtnSubFrame.CreaturePreview.Info:Hide();
NavBtnSubFrame.CreatureAttributePanel = CreateFrame("Frame", "PicGuideCreatureAttributePanel", NavBtnSubFrame);
NavBtnSubFrame.CreatureAttributePanel:SetSize(390, 105);
NavBtnSubFrame.CreatureAttributePanel:SetPoint("TOPLEFT", NavBtnSubFrame.CreaturePreview, "BOTTOMLEFT", 0, -5);
NavBtnSubFrame.CreatureAttributePanel:SetBackdrop({ bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", tile = true, tileSize = 16, edgeSize = 12, insets = { left = 4, right = 4, top = 4, bottom = 4 } });
NavBtnSubFrame.CreatureAttributePanel:SetBackdropColor(0.03, 0.03, 0.03, 0.78);
NavBtnSubFrame.CreatureAttributePanel.Title = NavBtnSubFrame.CreatureAttributePanel:CreateFontString();
NavBtnSubFrame.CreatureAttributePanel.Title:SetFont(Dream_GameFont, 18);
NavBtnSubFrame.CreatureAttributePanel.Title:SetPoint("TOP", 0, -12);
NavBtnSubFrame.CreatureAttributePanel.Title:SetText("|cffff3333激活属性|r");
NavBtnSubFrame.CreatureAttributePanel.Info = NavBtnSubFrame.CreatureAttributePanel:CreateFontString();
NavBtnSubFrame.CreatureAttributePanel.Info:SetFont(Dream_GameFont, 16);
NavBtnSubFrame.CreatureAttributePanel.Info:SetPoint("TOP", 0, -38);
NavBtnSubFrame.CreatureAttributePanel.Info:SetSize(362, 58);
NavBtnSubFrame.CreatureAttributePanel.Info:SetTextColor(0, 1, 0);
NavBtnSubFrame.CreatureAttributePanel.Info:SetJustifyH("CENTER");
NavBtnSubFrame.CreatureAttributePanel.Info:SetWordWrap(true);
NavBtnSubFrame.CreatureAttributePanel:Hide();
NavBtnSubFrame.CreaturePreview.AttributeTitle = NavBtnSubFrame.CreatureAttributePanel.Title;
NavBtnSubFrame.CreaturePreview.Info = NavBtnSubFrame.CreatureAttributePanel.Info;

function ShowPicGuideCreaturePreview(Button)
	local Preview = NavBtnSubFrame.CreaturePreview;
	local Model = Preview.Model;
	Preview:Show();
	NavBtnSubFrame.CreatureAttributePanel:Show();
	for i = 1, PageSize do NavBtnSubFrame.ListBtns[i]:UnlockHighlight(); end
	Button:LockHighlight();
	Preview.Title:SetText(Button.CreatureName or "");
	Preview.Difficulty:SetText(Button.DifficultyText or "");
	Preview.Info:SetText(Button.RewardText or ((Button.StatText or "").."\n"..(Button.KillText or "")));
	Model.CreatureID = Button:GetID();
	Model.DisplayID = Button.DisplayID or 0;
	Model.DisplayIDs = Button.DisplayIDs or {};
	Model.Facing = 0.35;
	Model.CameraScale = CreatureCameraScale[Model.CreatureID] or 1.35;
	Model.RetryElapsed = 0;
	Model.RetryCount = 6;
	Model:Show();
	SafeModelCall(Model, "ClearModel");
	SafeModelCall(Model, "SetCreature", Model.CreatureID);
	Dream_SendData("CachePicGuideCreatureModel", tostring(Model.CreatureID));
	SafeModelCall(Model, "SetCamDistanceScale", Model.CameraScale);
	SafeModelCall(Model, "SetFacing", Model.Facing);
end

local BondsPanel;

local function SetPicGuideCreatureLayout(IsCreature)
	NavBtnSubFrame.CreaturePreview:Hide();
	NavBtnSubFrame.CreatureAttributePanel:Hide();
	NavBtnSubFrame.CreaturePreview.Title:SetText("");
	NavBtnSubFrame.CreaturePreview.Difficulty:SetText("");
	NavBtnSubFrame.CreaturePreview.Info:SetText("");
	NavBtnSubFrame.CreaturePreview.Model.CreatureID = 0;
	NavBtnSubFrame.CreaturePreview.Model.RetryCount = 0;
	SafeModelCall(NavBtnSubFrame.CreaturePreview.Model, "ClearModel");
	if (BondsPanel) then
		BondsPanel:ClearAllPoints();
		if (IsCreature) then
			BondsPanel:SetParent(PicGuideFrame);
			BondsPanel:SetFrameLevel(PicGuideFrame:GetFrameLevel() + 20);
			BondsPanel:SetSize(200, 700);
			BondsPanel:SetPoint("TOPLEFT", PicGuideFrame, "TOPRIGHT", 0, -20);
			BondsPanel:SetBackdrop({ bgFile = "Interface\\Icons\\CPic5", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", tile = false, edgeSize = 12, insets = { left = 4, right = 4, top = 4, bottom = 4 } });
			BondsPanel:SetBackdropColor(1, 1, 1, 1);
			BondsPanel.Title:SetFont(Dream_GameFont, 18);
			BondsPanel.Title:ClearAllPoints(); BondsPanel.Title:SetPoint("TOPLEFT", BondsPanel, "TOPLEFT", 16, -14);
			BondsPanel.ScrollFrame:SetSize(168, 170);
			BondsPanel.ScrollFrame:ClearAllPoints(); BondsPanel.ScrollFrame:SetPoint("TOPLEFT", BondsPanel, "TOPLEFT", 16, -70);
			BondsPanel.ScrollFrame:SetFont(Dream_GameFont, 16);
			BondsPanel.ScrollFrame:SetSpacing(12);
			NavBtnSubFrame.PrevBtn:ClearAllPoints(); NavBtnSubFrame.PrevBtn:SetPoint("BOTTOMRIGHT", NavBtnSubFrame, "BOTTOMRIGHT", -140, -10);
			NavBtnSubFrame.PageText:ClearAllPoints(); NavBtnSubFrame.PageText:SetPoint("BOTTOMRIGHT", NavBtnSubFrame, "BOTTOMRIGHT", -85, -10);
			NavBtnSubFrame.NextBtn:ClearAllPoints(); NavBtnSubFrame.NextBtn:SetPoint("BOTTOMRIGHT", NavBtnSubFrame, "BOTTOMRIGHT", -60, -10);
		else
			BondsPanel:SetParent(PicGuideFrame);
			BondsPanel:SetFrameLevel(PicGuideFrame:GetFrameLevel() + 20);
			BondsPanel:SetSize(200, 700);
			BondsPanel:SetPoint("TOPLEFT", PicGuideFrame, "TOPRIGHT", 0, -20);
			BondsPanel:SetBackdrop({ bgFile = "Interface\\Icons\\CPic5", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", tile = false, edgeSize = 12, insets = { left = 4, right = 4, top = 4, bottom = 4 } });
			BondsPanel:SetBackdropColor(1, 1, 1, 1);
			BondsPanel.Title:SetFont(Dream_GameFont, 18);
			BondsPanel.Title:ClearAllPoints(); BondsPanel.Title:SetPoint("TOPLEFT", BondsPanel, "TOPLEFT", 16, -14);
			BondsPanel.ScrollFrame:SetSize(168, 170);
			BondsPanel.ScrollFrame:ClearAllPoints(); BondsPanel.ScrollFrame:SetPoint("TOPLEFT", BondsPanel, "TOPLEFT", 16, -70);
			BondsPanel.ScrollFrame:SetFont(Dream_GameFont, 16);
			BondsPanel.ScrollFrame:SetSpacing(12);
			NavBtnSubFrame.PrevBtn:ClearAllPoints(); NavBtnSubFrame.PrevBtn:SetPoint("BOTTOMRIGHT", NavBtnSubFrame, "BOTTOMRIGHT", -140, 0);
			NavBtnSubFrame.PageText:ClearAllPoints(); NavBtnSubFrame.PageText:SetPoint("BOTTOMRIGHT", NavBtnSubFrame, "BOTTOMRIGHT", -85, 0);
			NavBtnSubFrame.NextBtn:ClearAllPoints(); NavBtnSubFrame.NextBtn:SetPoint("BOTTOMRIGHT", NavBtnSubFrame, "BOTTOMRIGHT", -60, 0);
		end
	end
	for N = 1, PageSize do
		NavBtnSubFrame.ListBtns[N]:UnlockHighlight();
		local Button = NavBtnSubFrame.ListBtns[N];
		Button:ClearAllPoints();
		Button.NormalTexture:ClearAllPoints();
		if (IsCreature) then
			Button:SetSize(390, 75);
			Button:SetPoint("TOPLEFT", 10, -10 - ((N - 1) * 80));
			Button.NormalTexture:SetSize(54, 54);
			Button.NormalTexture:SetPoint("LEFT", Button, "LEFT", 8, 0);
			Button.ModelFrame:Hide();
			Button.NameStr:ClearAllPoints(); Button.NameStr:SetPoint("TOPLEFT", Button, "TOPLEFT", 72, -7); Button.NameStr:SetSize(205, 24); Button.NameStr:SetJustifyH("LEFT");
			Button.DiffStr:ClearAllPoints(); Button.DiffStr:SetPoint("TOPRIGHT", Button, "TOPRIGHT", -8, -5);
			Button.StatAsStr:Hide();
			Button.KillCountStr:ClearAllPoints(); Button.KillCountStr:SetPoint("BOTTOMLEFT", Button, "BOTTOMLEFT", 72, 3);
			Button.KillCountStr:SetSize(310, 38); Button.KillCountStr:SetFont(Dream_GameFont, 11); Button.KillCountStr:SetJustifyH("LEFT");
		else
			Button:SetSize(155, 135);
			local Col = (N - 1) % 5; local Row = math.floor((N - 1) / 5);
			Button:SetPoint("TOPLEFT", Col * 155 + 15, -(Row * 137 + 10));
			Button.NormalTexture:SetSize(58, 58); Button.NormalTexture:SetPoint("TOPLEFT", Button, 5, -5);
			Button.NameStr:ClearAllPoints(); Button.NameStr:SetPoint("TOP", Button, "TOP", 0, -16); Button.NameStr:SetSize(145, 24); Button.NameStr:SetJustifyH("CENTER");
			Button.DiffStr:ClearAllPoints(); Button.DiffStr:SetPoint("TOP", Button, "TOP", 35, 0);
			Button.IconBtnCenter:SetSize(52, 52); Button.IconBtnCenter:ClearAllPoints(); Button.IconBtnCenter:SetPoint("CENTER", Button, "CENTER", 0, 5);
			Button.ActBtn:SetSize(92, 24); Button.ActBtn:ClearAllPoints(); Button.ActBtn:SetPoint("BOTTOM", Button, "BOTTOM", 0, 7);
			Button.StatAsStr:ClearAllPoints(); Button.StatAsStr:SetPoint("BOTTOM", Button, "BOTTOM", 0, 10);
			Button.KillCountStr:ClearAllPoints(); Button.KillCountStr:SetPoint("BOTTOM", Button, "BOTTOM", 0, 0);
			Button.KillCountStr:SetSize(150, 30); Button.KillCountStr:SetFont(Dream_GameFont, 15); Button.KillCountStr:SetJustifyH("CENTER");
		end
	end
end

NavBtnSubFrame.PrevBtn = CreateFrame("Button", NavBtnSubFrame:GetName().."PreBtn", NavBtnSubFrame);
NavBtnSubFrame.PrevBtn:SetNormalTexture("Interface\\Buttons\\UI-SpellbookIcon-PrevPage-Up");
NavBtnSubFrame.PrevBtn:SetPushedTexture("Interface\\Buttons\\UI-SpellbookIcon-PrevPage-Down");
NavBtnSubFrame.PrevBtn:SetHighlightTexture("Interface\\Buttons\\UI-Panel-MinimizeButton-Highlight");
NavBtnSubFrame.PrevBtn:SetDisabledTexture("Interface\\Buttons\\UI-SpellbookIcon-PrevPage-Disabled");
NavBtnSubFrame.PrevBtn:SetSize(30, 30);
NavBtnSubFrame.PrevBtn:SetPoint("BOTTOMRIGHT", NavBtnSubFrame, "BOTTOMRIGHT", -140, 0);
NavBtnSubFrame.PrevBtn:SetFrameLevel(NavBtnSubFrame:GetFrameLevel() + 20);
NavBtnSubFrame.PrevBtn:EnableMouse(true);
NavBtnSubFrame.PrevBtn:Disable();
NavBtnSubFrame.PrevBtn:SetScript("OnClick",
function(self)
	NavBtnSubFrame.PageIndex = NavBtnSubFrame.PageIndex - 1;
	if (NavBtnSubFrame.PageIndex <= 1) then
		NavBtnSubFrame.PageIndex = 1;
	end
	NavSubBtnsUpdateSelect(NavBtnSubFrame.TypeIndex, NavBtnSubFrame.PageIndex);
end);
NavBtnSubFrame.PageText = NavBtnSubFrame:CreateFontString();
NavBtnSubFrame.PageText:SetSize(60, 30);
NavBtnSubFrame.PageText:SetFont(Dream_GameFont, 14);
NavBtnSubFrame.PageText:SetPoint("BOTTOMRIGHT", NavBtnSubFrame, "BOTTOMRIGHT", -85, 0);
NavBtnSubFrame.PageText:SetText("1/1");
NavBtnSubFrame.NextBtn = CreateFrame("Button", NavBtnSubFrame:GetName().."NextBtn", NavBtnSubFrame);
NavBtnSubFrame.NextBtn:SetNormalTexture("Interface\\Buttons\\UI-SpellbookIcon-NextPage-Up");
NavBtnSubFrame.NextBtn:SetPushedTexture("Interface\\Buttons\\UI-SpellbookIcon-NextPage-Down");
NavBtnSubFrame.NextBtn:SetHighlightTexture("Interface\\Buttons\\UI-Panel-MinimizeButton-Highlight");
NavBtnSubFrame.NextBtn:SetDisabledTexture("Interface\\Buttons\\UI-SpellbookIcon-NextPage-Disabled");
NavBtnSubFrame.NextBtn:SetSize(30, 30);
NavBtnSubFrame.NextBtn:SetPoint("BOTTOMRIGHT", NavBtnSubFrame, "BOTTOMRIGHT", -60, 0);
NavBtnSubFrame.NextBtn:SetFrameLevel(NavBtnSubFrame:GetFrameLevel() + 20);
NavBtnSubFrame.NextBtn:EnableMouse(true);
NavBtnSubFrame.NextBtn:Disable();
NavBtnSubFrame.NextBtn:SetScript("OnClick",
function(self)
	NavBtnSubFrame.PageIndex = NavBtnSubFrame.PageIndex + 1;
	if (NavBtnSubFrame.PageIndex >= NavBtnSubFrame.PageCount) then
		NavBtnSubFrame.PageIndex = NavBtnSubFrame.PageCount;
	end
	NavSubBtnsUpdateSelect(NavBtnSubFrame.TypeIndex, NavBtnSubFrame.PageIndex);
end);
NavBtnSubFrame.LeftGtsText = NavBtnSubFrame:CreateFontString();
NavBtnSubFrame.LeftGtsText:SetFont(Dream_GameFont, 18);
NavBtnSubFrame.LeftGtsText:SetPoint("BOTTOMLEFT", NavBtnSubFrame, "BOTTOMLEFT", 30, 5);
NavBtnSubFrame.LeftGtsText:SetTextColor(0/255, 255/255, 0/255);
NavBtnSubFrame.LeftGtsText.TotalCount = 0;

BondsPanel = CreateFrame("Frame", "PicGuideBondsPanel", PicGuideScrollChildFrame);
BondsPanel:SetSize(245, 190);
BondsPanel:SetPoint("BOTTOMLEFT", PicGuideScrollChildFrame, "BOTTOMLEFT", 5, 18);
BondsPanel:SetBackdrop({ bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", tile = true, tileSize = 16, edgeSize = 12, insets = { left = 4, right = 4, top = 4, bottom = 4 } });
BondsPanel:SetBackdropColor(0.03, 0.03, 0.03, 0.78);
BondsPanel:SetFrameLevel(PicGuideScrollChildFrame:GetFrameLevel() + 5);
BondsPanel.Title = BondsPanel:CreateFontString();
BondsPanel.Title:SetFont(Dream_GameFont, 16);
BondsPanel.Title:SetPoint("TOPLEFT", BondsPanel, "TOPLEFT", 14, -12);
BondsPanel.Title:SetText("|cffffcc55羁绊目标|r");
BondsPanel.ScrollFrame = CreateFrame("ScrollingMessageFrame", "PicGuideBondsScrollFrame", BondsPanel);
BondsPanel.ScrollFrame:SetSize(217, 142);
BondsPanel.ScrollFrame:SetPoint("TOPLEFT", BondsPanel, "TOPLEFT", 14, -38);
BondsPanel.ScrollFrame:SetFont(Dream_GameFont, 13);
BondsPanel.ScrollFrame:SetSpacing(5);
BondsPanel.ScrollFrame:SetFading(false);
BondsPanel.ScrollFrame:SetInsertMode("BOTTOM");
BondsPanel.ScrollFrame:SetMaxLines(64);
BondsPanel.ScrollFrame:EnableMouseWheel(true);
BondsPanel.ScrollFrame:SetScript("OnMouseWheel", function(self, Delta)
	if (Delta < 0) then self:ScrollDown(); else self:ScrollUp(); end
end);
BondsPanel.ScrollFrame:Hide();
BondsPanel:Hide();
BondsPanel.Entries = {};

local function RenderBondsPanel(ActCount)
	BondsPanel.ScrollFrame:Clear();
	if (#BondsPanel.Entries == 0) then
		BondsPanel:Hide();
		return;
	end
	BondsPanel:Show();
	BondsPanel.ScrollFrame:Show();
	for i = 1, #BondsPanel.Entries do
		local Entry = BondsPanel.Entries[i];
		local IsActive = ActCount >= Entry.Count;
		local StatusText = IsActive and "|cff55ff77已激活|r" or "|cffffcc55未激活|r";
		local ProgressColor = IsActive and "|cff55ff77" or "|cffffcc55";
		BondsPanel.ScrollFrame:AddMessage(string.format("%s收集 %u/%u|r  %s\n|cffdddddd%s|r", ProgressColor, ActCount, Entry.Count, StatusText, Entry.Comment));
	end
end

function HideNavBtnSubFrameListBtns()
	NavBtnSubFrame.PageIndex = 1;
	NavBtnSubFrame.PageCount = 1;
	NavBtnSubFrame.TypeIndex = 1;
	NavBtnSubFrame.PrevBtn:Disable();
	NavBtnSubFrame.NextBtn:Disable();
	NavBtnSubFrame.CreaturePreview:Hide();
	NavBtnSubFrame.CreaturePreview.Title:SetText("");
	NavBtnSubFrame.CreaturePreview.Difficulty:SetText("");
	NavBtnSubFrame.CreaturePreview.Info:SetText("");
	NavBtnSubFrame.CreaturePreview.Model.CreatureID = 0;
	NavBtnSubFrame.CreaturePreview.Model.RetryCount = 0;
	SafeModelCall(NavBtnSubFrame.CreaturePreview.Model, "ClearModel");
	NavBtnSubFrame.CreatureAttributePanel:Hide();
	for N = 1, PageSize do
		NavBtnSubFrame.ListBtns[N].ModelFrame.CreatureID = 0;
		NavBtnSubFrame.ListBtns[N].ModelFrame.ModelRetryCount = 0;
		NavBtnSubFrame.ListBtns[N].ModelFrame:SetCreature(0);
		NavBtnSubFrame.ListBtns[N].ModelFrame:Hide();
		NavBtnSubFrame.ListBtns[N].ActBtn:Hide();
		NavBtnSubFrame.ListBtns[N].IconBtnCenter:Hide();
		NavBtnSubFrame.ListBtns[N].SmButton1:Hide();
		NavBtnSubFrame.ListBtns[N].SmButton2:Hide();
		NavBtnSubFrame.ListBtns[N].DiffStr:SetText("");
		NavBtnSubFrame.ListBtns[N].DiffStr:Hide();
		NavBtnSubFrame.ListBtns[N].NameStr:SetText("");
		NavBtnSubFrame.ListBtns[N].NameStr:Hide();
		NavBtnSubFrame.ListBtns[N].StatAsStr:SetText("");
		NavBtnSubFrame.ListBtns[N].StatAsStr:Hide();
		NavBtnSubFrame.ListBtns[N].KillCountStr:SetText("");
		NavBtnSubFrame.ListBtns[N].KillCountStr:Hide();
		NavBtnSubFrame.ListBtns[N].CreatureName = "";
		NavBtnSubFrame.ListBtns[N].DisplayID = 0;
		NavBtnSubFrame.ListBtns[N].DisplayIDs = {};
		NavBtnSubFrame.ListBtns[N].DifficultyText = "";
		NavBtnSubFrame.ListBtns[N].StatText = "";
		NavBtnSubFrame.ListBtns[N].KillText = "";
		NavBtnSubFrame.ListBtns[N].RewardText = "";
		NavBtnSubFrame.ListBtns[N].Rewards = {};
		NavBtnSubFrame.ListBtns[N]:SetID(0);
		NavBtnSubFrame.ListBtns[N]:Hide();
	end
	for N = 1, NavBtn1.SubBtnCount do
		NavBtn1.SubBtns[N]:UnlockHighlight();
		NavBtn1.SubBtns[N].ScrollFrame:Clear();
		NavBtn1.SubBtns[N].ScrollFrame:Hide();
	end
	for N = 1, NavBtn2.SubBtnCount do
		NavBtn2.SubBtns[N]:UnlockHighlight();
		NavBtn2.SubBtns[N].ScrollFrame:Clear();
		NavBtn2.SubBtns[N].ScrollFrame:Hide();
	end
	BondsPanel:Hide();
end

function NavBtnClickUpdateSelect(Index)
	NavBtn1.NowSubPageId = 0;
	NavBtn2.NowSubPageId = 0;
	HideNavBtnSubFrameListBtns();
	NavBtnSubFrame.PrevBtn:Disable();
	NavBtnSubFrame.PageText:SetText("1/1");
	NavBtnSubFrame.LeftGtsText:SetText("");
	NavBtnSubFrame.LeftGtsText.TotalCount = 0;
	NavBtnSubFrame.NextBtn:Disable();

	if (Index == 0) then
		if (NavBtn1.SubBtnCount > 0) then
		    for i = 1, NavBtn1.SubBtnCount do
			    NavBtn1.SubBtns[i]:UnlockHighlight();
			    NavBtn1.SubBtns[i]:Disable();
		        NavBtn1.SubBtns[i]:Hide();
		    end
		    NavBtn1:SetChecked(nil);
	    end

		if (NavBtn2.SubBtnCount > 0) then
		    for i = 1, NavBtn2.SubBtnCount do
			    NavBtn2.SubBtns[i]:UnlockHighlight();
			    NavBtn2.SubBtns[i]:Disable();
		        NavBtn2.SubBtns[i]:Hide();
		    end
		    NavBtn2:SetChecked(nil);
	    end

		return;
	end

	local CurrentBtn = _G["NavBtn"..Index];
	local TogtBtn = _G["NavBtn"..(BtnLastIndex - Index)];
	if ((not CurrentBtn) or (not TogtBtn)) then
		return;
	end

	if (TogtBtn.SubBtnCount > 0) then
		for i = 1, TogtBtn.SubBtnCount do
			TogtBtn.SubBtns[i]:UnlockHighlight();
			TogtBtn.SubBtns[i]:Disable();
		    TogtBtn.SubBtns[i]:Hide();
		end
		TogtBtn:SetChecked(nil);
	end

	TogtBtn:UnlockHighlight();
	CurrentBtn:LockHighlight();

	local LastBtnY = BtnFirstY - BtnHeight - BtnSpace;
	if (not CurrentBtn:GetChecked()) then
		if (CurrentBtn.SubBtnCount > 0) then
			for i = 1, CurrentBtn.SubBtnCount do
				CurrentBtn.SubBtns[i]:UnlockHighlight();
				CurrentBtn.SubBtns[i]:Disable();
		        CurrentBtn.SubBtns[i]:Hide();
		    end
		end
		CurrentBtn:UnlockHighlight();
	else
		if (CurrentBtn.SubBtnCount > 0) then
			for i = 1, CurrentBtn.SubBtnCount do
			    CurrentBtn.SubBtns[i]:Enable();
		        CurrentBtn.SubBtns[i]:Show();
		    end
			if (Index == 1) then
		        LastBtnY = -(SubBtnHeight * CurrentBtn.SubBtnCount + BtnSpace * 2 + BtnHeight);
			end
		end
	end

	if (Index == 1) then
		TogtBtn:SetPoint("TOPLEFT", 0, LastBtnY);
	else
		CurrentBtn:SetPoint("TOPLEFT", 0, LastBtnY);
	end

	local AsHeight = (SubBtnHeight * CurrentBtn.SubBtnCount + BtnSpace * 2 + BtnHeight + 30);
	if (AsHeight > ChildHeight) then
	    PicGuideScrollChildFrame:SetHeight(AsHeight);
		PicGuideSlider:Show();
		PicGuideSlider:SetValue(0);
	else
		PicGuideScrollChildFrame:SetHeight(ChildHeight);
		PicGuideSlider:Hide();
		PicGuideSlider:SetValue(0);
	end
end

function CreateAllSubBtn()
	NavBtn1.SubBtns = {};
	for i = 1, NavBtn1.SubBtnCount do
		NavBtn1.SubBtns[i] = CreateFrame("Button", NavBtn1:GetName().."SubBtns"..i, NavBtn1);
        NavBtn1.SubBtns[i]:SetNormalTexture(PicGuideCoordsFile);
        NavBtn1.SubBtns[i]:SetHighlightTexture(PicGuideCoordsFile);
        NavBtn1.SubBtns[i]:GetNormalTexture():SetTexCoord(0.7504, 0.9985, 0.8764, 0.9370);
        NavBtn1.SubBtns[i]:GetHighlightTexture():SetTexCoord(0.7504, 0.9985, 0.9379, 0.9985);
		NavBtn1.SubBtns[i]:SetSize(NavBtn1:GetWidth() - 45, SubBtnHeight);
	    NavBtn1.SubBtns[i].NavBtnStr = {};
	    NavBtn1.SubBtns[i].NavBtnStr[i] = NavBtn1.SubBtns[i]:CreateFontString(NavBtn1:GetName().."NavBtnStr"..i);
        NavBtn1.SubBtns[i].NavBtnStr[i]:SetFont(Dream_GameFont, 18);
        NavBtn1.SubBtns[i].NavBtnStr[i]:SetAllPoints(NavBtn1.SubBtns[i]);
        NavBtn1.SubBtns[i]:SetFontString(NavBtn1.SubBtns[i].NavBtnStr[i]);
        NavBtn1.SubBtns[i]:SetPoint("TOPLEFT", 30, -(i * SubBtnHeight + (BtnHeight - SubBtnHeight)));
		NavBtn1.SubBtns[i].Icon = NavBtn1.SubBtns[i]:CreateTexture(nil, "BACKGROUND");
        NavBtn1.SubBtns[i].Icon:SetSize(SubBtnHeight, SubBtnHeight - 10);
        NavBtn1.SubBtns[i].Icon:SetPoint("LEFT", NavBtn1.SubBtns[i], "LEFT", 8, 0);
		NavBtn1.SubBtns[i]:SetID(0);

		NavBtn1.SubBtns[i].ScrollFrame = BondsPanel.ScrollFrame;

        NavBtn1.SubBtns[i]:SetScript("OnClick",
        function(self)
			if (NavBtn1.NowSubPageId ~= self:GetID()) then
				NavBtn1.NowSubPageId = self:GetID();
				HideNavBtnSubFrameListBtns();
		        Dream_SendData("GetPicGuideItemPageCount", tostring(NavBtn1.NowSubPageId));
                self:LockHighlight();
			end
        end);
	end

	NavBtn2.SubBtns = {};
	for i = 1, NavBtn2.SubBtnCount do
		NavBtn2.SubBtns[i] = CreateFrame("Button", NavBtn2:GetName().."SubBtns"..i, NavBtn2);
        NavBtn2.SubBtns[i]:SetNormalTexture(PicGuideCoordsFile);
        NavBtn2.SubBtns[i]:SetHighlightTexture(PicGuideCoordsFile);
        NavBtn2.SubBtns[i]:GetNormalTexture():SetTexCoord(0.7504, 0.9985, 0.8764, 0.9370);
        NavBtn2.SubBtns[i]:GetHighlightTexture():SetTexCoord(0.7504, 0.9985, 0.9379, 0.9985);
		NavBtn2.SubBtns[i]:SetSize(NavBtn2:GetWidth() - 45, SubBtnHeight);
	    NavBtn2.SubBtns[i].NavBtnStr = {};
	    NavBtn2.SubBtns[i].NavBtnStr[i] = NavBtn2.SubBtns[i]:CreateFontString(NavBtn2:GetName().."NavBtnStr"..i);
        NavBtn2.SubBtns[i].NavBtnStr[i]:SetFont(Dream_GameFont, 18);
        NavBtn2.SubBtns[i].NavBtnStr[i]:SetAllPoints(NavBtn2.SubBtns[i]);
        NavBtn2.SubBtns[i]:SetFontString(NavBtn2.SubBtns[i].NavBtnStr[i]);
        NavBtn2.SubBtns[i]:SetPoint("TOPLEFT", 30, -(i * SubBtnHeight + (BtnHeight - SubBtnHeight)));
		NavBtn2.SubBtns[i].Icon = NavBtn2.SubBtns[i]:CreateTexture(nil, "BACKGROUND");
        NavBtn2.SubBtns[i].Icon:SetSize(SubBtnHeight, SubBtnHeight - 10);
        NavBtn2.SubBtns[i].Icon:SetPoint("LEFT", NavBtn2.SubBtns[i], "LEFT", 8, 0);
		NavBtn2.SubBtns[i]:SetID(0);

		NavBtn2.SubBtns[i].ScrollFrame = BondsPanel.ScrollFrame;

        NavBtn2.SubBtns[i]:SetScript("OnClick",
        function(self)
			if (NavBtn2.NowSubPageId ~= self:GetID()) then
				NavBtn2.NowSubPageId = self:GetID();
				HideNavBtnSubFrameListBtns();
		        Dream_SendData("GetPicGuideCreaturePageCount", tostring(NavBtn2.NowSubPageId));
                self:LockHighlight();
			end
        end);
	end

	NavBtnClickUpdateSelect(0);
	Dream_SendData("GetItemPicGuideSubBtnsData");
	Dream_SendData("GetCreaturePicGuideSubBtnsData");
end

function NavSubBtnsUpdateSelect(TypeIndex, NowPage)
	SetPicGuideCreatureLayout(TypeIndex == 2);
	NavBtnSubFrame.TypeIndex = TypeIndex;
	if (NowPage and NowPage > 0) then
		NavBtnSubFrame.PageIndex = NowPage;
	end
	if (NavBtnSubFrame.PageCount < 1) then
		NavBtnSubFrame.PageCount = 1;
	end
	if (NavBtnSubFrame.PageIndex < 1) then
		NavBtnSubFrame.PageIndex = 1;
	elseif (NavBtnSubFrame.PageIndex > NavBtnSubFrame.PageCount) then
		NavBtnSubFrame.PageIndex = NavBtnSubFrame.PageCount;
	end
	if (NavBtnSubFrame.PageIndex > 1) then
		NavBtnSubFrame.PrevBtn:Enable();
	else
		NavBtnSubFrame.PrevBtn:Disable();
	end
	if (NavBtnSubFrame.PageIndex < NavBtnSubFrame.PageCount) then
		NavBtnSubFrame.NextBtn:Enable();
	else
		NavBtnSubFrame.NextBtn:Disable();
	end
	for N = 1, PageSize do
		NavBtnSubFrame.ListBtns[N]:SetID(0);
		NavBtnSubFrame.ListBtns[N].CreatureName = "";
		NavBtnSubFrame.ListBtns[N].NameStr:SetText("");
		NavBtnSubFrame.ListBtns[N].NameStr:Hide();
	end
	NavBtnSubFrame.PageText:SetText(NavBtnSubFrame.PageIndex.."/"..(NavBtnSubFrame.PageCount > 0 and NavBtnSubFrame.PageCount or 1));

	if (TypeIndex == 1) then
		Dream_SendData("GetItemPicGuideSubListData", string.format("%u#%u#%u", NavBtn1.NowSubPageId, NowPage, PageSize));
    else
		Dream_SendData("GetCreaturePicGuideSubListData", string.format("%u#%u#%u", NavBtn2.NowSubPageId, NowPage, CreaturePageSize));
	end
end

-- 只是检测背包状态变化的机制 这种机制包含物品堆叠和摊开的情况 所以建议这类物品不要设置堆叠状态
local CurrentItems  = {};
function ScanItemIds()
    local Items = {}
    for Bag = 0, 4 do
        for Slot = 1, GetContainerNumSlots(Bag) do
            local ItemLink = GetContainerItemLink(Bag, Slot);
            if ItemLink then
             	local ItemId = GetItemIdByLink(ItemLink);
                if ItemId > 0 then
                    Items[tonumber(ItemId)] = true;
                end
            end
        end
    end
    return Items;
end

PicGuideFrame:SetScript("OnShow",
function(self)
	-- 缓存当前背包物品
    CurrentItems = ScanItemIds();

	--第一次默认显示物品图鉴第一项
	if (IsFirstShow) then
		IsFirstShow = false;
		NavBtn1:Click();
		if (NavBtn1.SubBtns[1]) then
			NavBtn1.SubBtns[1]:Click();
		end
	end
end);

local function BuildCreatureRewardText(Rewards, PlayerKillCount)
	if (#Rewards == 0) then return ""; end
	local CompletedKills = 0;
	for i = 1, #Rewards do
		local Reward = Rewards[i];
		local NeedKills = Reward.KillCount or 0;
		local CurrentKills = math.max((PlayerKillCount or 0) - CompletedKills, 0);
		if (CurrentKills < NeedKills or i == #Rewards) then
			CurrentKills = math.min(CurrentKills, NeedKills);
			local StatValue = Reward.StatValue or 0;
			local ValueText = StatValue >= 0 and ("+"..StatValue) or tostring(StatValue);
			local CurrentText = string.format("|cffffcc55当前等级：%u|r  |cff55ff77击杀：%u/%u|r  |cff66dd88激活属性：%s%s|r", Reward.Level or i, CurrentKills, NeedKills, GetStatStr(Reward.StatType or 0), ValueText);
			if (i < #Rewards) then
				local NextReward = Rewards[i + 1];
				local NextStatValue = NextReward.StatValue or 0;
				local NextValueText = NextStatValue >= 0 and ("+"..NextStatValue) or tostring(NextStatValue);
				return CurrentText..string.format("\n|cff88ccff下个等级：%u  击杀：0/%u  激活属性：%s%s|r", NextReward.Level or (i + 1), NextReward.KillCount or 0, GetStatStr(NextReward.StatType or 0), NextValueText);
			end
			return CurrentText.."\n|cffffcc55已达到最高等级|r";
		end
		CompletedKills = CompletedKills + NeedKills;
	end
	return "";
end

--消息处理
local function Dream_OnPicGuideEvent(Self, event, Packet, Msg, Type, Sender)
    if (event == "CHAT_MSG_ADDON") then
		if (Packet == "ItemPicGuideSubBtnCount") then
			local Args = Dream_Split(Msg, "#");
			local SubBtnCount1 = tonumber(Args[1]);
			local SubBtnCount2 = tonumber(Args[2]);
            NavBtn1.SubBtnCount = tonumber(SubBtnCount1);
			NavBtn2.SubBtnCount = tonumber(SubBtnCount2);
            CreateAllSubBtn();
        elseif (Packet == "PicGuideItemConfig") then
			local Args = Dream_Split(Msg, "$");
            for i=1,#Args do
				if (Args[i]) then
					local TheArgs = Dream_Split(Args[i], "#");
                    local Index = tonumber(TheArgs[1]);
			        local SubName = TheArgs[2];
			        local SubIcon = TheArgs[3];
			        local SubPageId = tonumber(TheArgs[4]);
			        local CurSubBtn = NavBtn1.SubBtns[Index];
			        if (CurSubBtn) then
				        CurSubBtn:SetText(SubName);
			            CurSubBtn:SetID(SubPageId);
			            CurSubBtn.Icon:SetTexture("Interface\\Icons\\"..SubIcon);
			        end
				end
            end
		elseif (Packet == "PicGuideItemPageCount") then
			local CurSubBtn = NavBtn1.SubBtns[NavBtn1.NowSubPageId];
			if (not CurSubBtn) then
				return;
			end
			local ActCount = 0;
	        local Args = Dream_Split(Msg, "&");
			if (Args[1]) then
				local BDatas = Args[1];
			    local KArgs = Dream_Split(BDatas, "#");
			    ActCount = tonumber(KArgs[1]) or 0;
			    local TotalCount = tonumber(KArgs[2]);
			    NavBtnSubFrame.PageCount = math.ceil(TotalCount / PageSize);
			    NavBtnSubFrame.PageCount = math.max(NavBtnSubFrame.PageCount, 1);
			    if (NavBtnSubFrame.PageCount > 1) then
		            NavBtnSubFrame.NextBtn:Enable();
			    end
			    NavBtnSubFrame.LeftGtsText.TotalCount = TotalCount;
			    NavBtnSubFrame.LeftGtsText:SetText(string.format("[%s]: 总计收集%u/%u", CurSubBtn:GetText(), ActCount, TotalCount));
			    NavBtnSubFrame.PageText:SetText(NavBtnSubFrame.PageIndex.."/"..(NavBtnSubFrame.PageCount > 0 and NavBtnSubFrame.PageCount or 1));
			end
			BondsPanel.ScrollFrame:Clear();
			BondsPanel:Hide();
			BondsPanel.Entries = {};
			if (Args[2]) then
				local TheArgs = Dream_Split(Args[2], "$");
				for i=1,#TheArgs do
				    local DArgs = Dream_Split(TheArgs[i], "#");
					if (DArgs) then
						local BondsCount = tonumber(DArgs[1]) or 0;
			            local Comment = DArgs[2];
						table.insert(BondsPanel.Entries, { Count = BondsCount, Comment = Comment or "" });
					end
                end
			end
			RenderBondsPanel(ActCount);
			NavSubBtnsUpdateSelect(1, 1);
		elseif (Packet == "PicGuideItemPageMult") then
			local Args = Dream_Split(Msg, "$");
            for i=1,#Args do
				if (Args[i]) then
					local TheArgs = Dream_Split(Args[i], "#");
					local Index = tonumber(TheArgs[1]);
					local ItemId = tonumber(TheArgs[2]);
					local IsActStat = tonumber(TheArgs[3]);
					local IsActSpell = tonumber(TheArgs[4]);
					local IsActPlayer = tonumber(TheArgs[5]);
					NavBtnSubFrame.ListBtns[Index].ActBtn:Show();
					if (IsActPlayer == 1) then
						NavBtnSubFrame.ListBtns[Index].NormalTexture:SetTexture("Interface\\Icons\\CPic3");
						NavBtnSubFrame.ListBtns[Index].ActBtn:Disable();
					else
						NavBtnSubFrame.ListBtns[Index].NormalTexture:SetTexture("Interface\\Icons\\CPic2");
						NavBtnSubFrame.ListBtns[Index].ActBtn:Enable();
					end
					NavBtnSubFrame.ListBtns[Index].ActBtn:SetText((IsActPlayer == 1) and "已激活" or "|cFF006E00激活|r");

					if (IsActStat == 1) then
						NavBtnSubFrame.ListBtns[Index].SmButton1:Show();
					else
						NavBtnSubFrame.ListBtns[Index].SmButton1:Hide();
					end
					if (IsActSpell == 1) then
						NavBtnSubFrame.ListBtns[Index].SmButton2:Show();
					else
						NavBtnSubFrame.ListBtns[Index].SmButton2:Hide();
					end

			        NavBtnSubFrame.ListBtns[Index]:SetID(ItemId);
					NavBtnSubFrame.ListBtns[Index].IconBtnCenter:Show();
			        NavBtnSubFrame.ListBtns[Index].IconBtnCenter:SetNormalTexture(DreamGetItemIcon(ItemId));
			        NavBtnSubFrame.ListBtns[Index].IconBtnCenter:GetNormalTexture():SetDesaturated(true);
			        NavBtnSubFrame.ListBtns[Index]:Show();
				end
			end

			for i = 1, PageSize do
				if (NavBtnSubFrame.ListBtns[i]:GetID() == 0) then
					NavBtnSubFrame.ListBtns[i]:Hide();
				end

				if (NavBtnSubFrame.ListBtns[i]:IsEnabled()) then
					local ItemId = NavBtnSubFrame.ListBtns[i]:GetID();
					if (ItemInBagPlayer(ItemId)) then
						NavBtnSubFrame.ListBtns[i].IconBtnCenter:GetNormalTexture():SetDesaturated(false);
						NavBtnSubFrame.ListBtns[i].ActBtn:SetText("|cFF00FF00激活|r");
					end
				end
			end
		elseif (Packet == "ActivateItemPicGuideYes") then
			local Args = Dream_Split(Msg, "#");
			local ItemId = tonumber(Args[2]);
			local N = tonumber(Args[3]);
			if (NavBtnSubFrame.ListBtns[N] and NavBtnSubFrame.ListBtns[N]:GetID() == ItemId) then
				NavBtnSubFrame.ListBtns[N]:SetID(0);
				NavBtnSubFrame.ListBtns[N].NormalTexture:SetTexture("Interface\\Icons\\CPic3");
			    NavBtnSubFrame.ListBtns[N].IconBtnCenter:GetNormalTexture():SetDesaturated(true);
			    NavBtnSubFrame.ListBtns[N].ActBtn:SetText("已激活");
			    NavBtnSubFrame.ListBtns[N].ActBtn:Disable();
			end
		elseif (Packet == "PicGuideCreatureConfig") then
			local Args = Dream_Split(Msg, "$");
            for i=1,#Args do
				if (Args[i]) then
					local TheArgs = Dream_Split(Args[i], "#");
                    local Index = tonumber(TheArgs[1]);
			        local SubName = TheArgs[2];
			        local SubIcon = TheArgs[3];
			        local SubPageId = tonumber(TheArgs[4]);
			        local CurSubBtn = NavBtn2.SubBtns[Index];
			        if (CurSubBtn) then
				        CurSubBtn:SetText(SubName);
			            CurSubBtn:SetID(SubPageId);
			            CurSubBtn.Icon:SetTexture("Interface\\Icons\\"..SubIcon);
			        end
				end
            end
		elseif (Packet == "PicGuideCreaturePageCount") then
			local CurSubBtn = NavBtn2.SubBtns[NavBtn2.NowSubPageId];
			if (not CurSubBtn) then
				return;
			end
			local ActCount = 0;
	        local Args = Dream_Split(Msg, "&");
			if (Args[1]) then
				local BDatas = Args[1];
			    local KArgs = Dream_Split(BDatas, "#");
			    ActCount = tonumber(KArgs[1]) or 0;
			    local TotalCount = tonumber(KArgs[2]);
			    NavBtnSubFrame.PageCount = math.ceil(TotalCount / CreaturePageSize);
			    NavBtnSubFrame.PageCount = math.max(NavBtnSubFrame.PageCount, 1);
			    if (NavBtnSubFrame.PageCount > 1) then
		            NavBtnSubFrame.NextBtn:Enable();
			    end
			    NavBtnSubFrame.LeftGtsText.TotalCount = TotalCount;
			    NavBtnSubFrame.LeftGtsText:SetText(string.format("[%s]: 总计收集%u/%u", CurSubBtn:GetText(), ActCount, TotalCount));
			    NavBtnSubFrame.PageText:SetText(NavBtnSubFrame.PageIndex.."/"..(NavBtnSubFrame.PageCount > 0 and NavBtnSubFrame.PageCount or 1));
			end
			BondsPanel.ScrollFrame:Clear();
			BondsPanel:Hide();
			BondsPanel.Entries = {};
			if (Args[2]) then
				local TheArgs = Dream_Split(Args[2], "$");
				for i=1,#TheArgs do
				    local DArgs = Dream_Split(TheArgs[i], "#");
				    local BondsCount = tonumber(DArgs[1]) or 0;
			        local Comment = DArgs[2];
					table.insert(BondsPanel.Entries, { Count = BondsCount, Comment = Comment or "" });
                end
			end
			RenderBondsPanel(ActCount);
			NavSubBtnsUpdateSelect(2, 1);
		elseif (Packet == "PicGuideCreaturePageMult") then
			local Args = Dream_Split(Msg, "$");
            for i=1,#Args do
				if (Args[i]) then
					local TheArgs = Dream_Split(Args[i], "#");
					local Index = tonumber(TheArgs[1]);
					local CreId = tonumber(TheArgs[2]);
					local CreName = TheArgs[3];
					local Diff = tonumber(TheArgs[4]);
					local KillCount = tonumber(TheArgs[5]);
					local StatType = tonumber(TheArgs[6]);
					local StatValue = tonumber(TheArgs[7]);
					local pKCount = tonumber(TheArgs[8]);
					local DisplayID = tonumber(TheArgs[9]) or 0;
					local DisplayIDs = {};
					for DisplayIndex = 9, 12 do
						local Candidate = tonumber(TheArgs[DisplayIndex]) or 0;
						if (Candidate > 0) then table.insert(DisplayIDs, Candidate); end
					end
					local Rewards = {};
					if (TheArgs[13] and TheArgs[13] ~= "") then
						local RewardArgs = Dream_Split(TheArgs[13], "~");
						for RewardIndex = 1, #RewardArgs do
							local RewardData = Dream_Split(RewardArgs[RewardIndex], ":");
							if (#RewardData >= 4) then
								table.insert(Rewards, { Level = tonumber(RewardData[1]) or RewardIndex, KillCount = tonumber(RewardData[2]) or 0, StatType = tonumber(RewardData[3]) or 0, StatValue = tonumber(RewardData[4]) or 0 });
							elseif (#RewardData >= 3) then
								table.insert(Rewards, { Level = RewardIndex, KillCount = tonumber(RewardData[1]) or 0, StatType = tonumber(RewardData[2]) or 0, StatValue = tonumber(RewardData[3]) or 0 });
							end
						end
					end
					if (#Rewards == 0) then
						table.insert(Rewards, { Level = 1, KillCount = KillCount, StatType = StatType, StatValue = StatValue });
					end
					if (pKCount == KillCount) then
						NavBtnSubFrame.ListBtns[Index].NormalTexture:SetTexture("Interface\\Icons\\CPic3");
					else
						NavBtnSubFrame.ListBtns[Index].NormalTexture:SetTexture("Interface\\Icons\\CPic2");
					end
					NavBtnSubFrame.ListBtns[Index].CreatureName = CreName;
					NavBtnSubFrame.ListBtns[Index].DisplayID = DisplayID;
					NavBtnSubFrame.ListBtns[Index].DisplayIDs = DisplayIDs;
					NavBtnSubFrame.ListBtns[Index].NameStr:SetText(CreName or "");
					NavBtnSubFrame.ListBtns[Index].NameStr:Show();
					local DifficultyText = GetDiffStr(Diff);
					NavBtnSubFrame.ListBtns[Index].DifficultyText = DifficultyText;
					NavBtnSubFrame.ListBtns[Index].DiffStr:SetText(DifficultyText);
		            NavBtnSubFrame.ListBtns[Index].DiffStr:Show();
					local RewardText = BuildCreatureRewardText(Rewards, pKCount);
					NavBtnSubFrame.ListBtns[Index].Rewards = Rewards;
					NavBtnSubFrame.ListBtns[Index].RewardText = RewardText;
					NavBtnSubFrame.ListBtns[Index].StatText = "";
					NavBtnSubFrame.ListBtns[Index].StatAsStr:Hide();
					NavBtnSubFrame.ListBtns[Index].KillText = RewardText;
					NavBtnSubFrame.ListBtns[Index].KillCountStr:SetText(RewardText);
					NavBtnSubFrame.ListBtns[Index].KillCountStr:Show();
					NavBtnSubFrame.ListBtns[Index]:SetID(CreId);
					NavBtnSubFrame.ListBtns[Index].ModelFrame:Hide();
					NavBtnSubFrame.ListBtns[Index]:Show();
				end
			end
			if (NavBtnSubFrame.ListBtns[1]:GetID() > 0) then ShowPicGuideCreaturePreview(NavBtnSubFrame.ListBtns[1]); end

			for i = 1, PageSize do
				if (NavBtnSubFrame.ListBtns[i]:GetID() == 0) then
					NavBtnSubFrame.ListBtns[i]:Hide();
				end
			end
		elseif (Packet == "PicGuideCreatureModelCached") then
			local Args = Dream_Split(Msg, "#");
			local CreId = tonumber(Args[1]) or 0;
			if (NavBtnSubFrame.CreaturePreview.Model.CreatureID == CreId) then
				NavBtnSubFrame.CreaturePreview.Model.RetryCount = 2;
				NavBtnSubFrame.CreaturePreview.Model.RetryElapsed = 0.5;
			end
		elseif (Packet == "PicGuideCreatureKillCount") then
			local Args = Dream_Split(Msg, "#");
			local SubPageId = tonumber(Args[1]);
			local CreId = tonumber(Args[2]);
			local pKCount = tonumber(Args[3]);
			local KillCount = tonumber(Args[4]);
			if (NavBtn2.NowSubPageId > 0 and NavBtn2.NowSubPageId == SubPageId) then
				for i = 1, PageSize do
				    if (NavBtnSubFrame.ListBtns[i]:GetID() == CreId) then
						if (pKCount == KillCount) then
						    NavBtnSubFrame.ListBtns[i].NormalTexture:SetTexture("Interface\\Icons\\CPic3");
						else
						    NavBtnSubFrame.ListBtns[i].NormalTexture:SetTexture("Interface\\Icons\\CPic2");
					    end
						local RewardText = BuildCreatureRewardText(NavBtnSubFrame.ListBtns[i].Rewards or {}, pKCount);
						if (RewardText == "") then RewardText = string.format("击杀:%u/%u", pKCount, KillCount); end
						NavBtnSubFrame.ListBtns[i].RewardText = RewardText;
						NavBtnSubFrame.ListBtns[i].KillText = RewardText;
						NavBtnSubFrame.ListBtns[i].KillCountStr:SetText(RewardText);
					    NavBtnSubFrame.ListBtns[i].KillCountStr:Show();
						if (NavBtnSubFrame.CreaturePreview.Model.CreatureID == CreId) then
							NavBtnSubFrame.CreaturePreview.Info:SetText(RewardText);
						end
				    end
			    end
			end
		elseif (Packet == "PicGuideBondsCount") then
			local Args = Dream_Split(Msg, "#");
			local SubPageId = tonumber(Args[1]);
			local ActCount = tonumber(Args[2]);
			if (NavBtn1.NowSubPageId > 0 and NavBtn1.NowSubPageId == SubPageId) then
				local SubName = NavBtn1.SubBtns[NavBtn1.NowSubPageId] and NavBtn1.SubBtns[NavBtn1.NowSubPageId]:GetText() or "";
				NavBtnSubFrame.LeftGtsText:SetText(string.format("[%s]: 总计收集%u/%u", SubName, ActCount, NavBtnSubFrame.LeftGtsText.TotalCount));
				RenderBondsPanel(ActCount);
			elseif (NavBtn2.NowSubPageId > 0 and NavBtn2.NowSubPageId == SubPageId) then
				local SubName = NavBtn2.SubBtns[NavBtn2.NowSubPageId] and NavBtn2.SubBtns[NavBtn2.NowSubPageId]:GetText() or "";
				NavBtnSubFrame.LeftGtsText:SetText(string.format("[%s]: 总计收集%u/%u", SubName, ActCount, NavBtnSubFrame.LeftGtsText.TotalCount));
				RenderBondsPanel(ActCount);
			end
		end
	elseif (event == "BAG_UPDATE") then
		if (not PicGuideFrame:IsShown() or NavBtn1.NowSubPageId == 0) then
			return;
		end
		-- 获取当前背包物品的缓存
		local NewItems = ScanItemIds();

		-- 对比当前缓存和旧的缓存是否有物品从背包中移除
		for ItemId in pairs(CurrentItems) do
            if (not NewItems[ItemId]) then
                for i = 1, PageSize do
				    if (NavBtnSubFrame.ListBtns[i]:IsEnabled()) then
					    local KItemId = NavBtnSubFrame.ListBtns[i]:GetID();
					    if (tonumber(ItemId) == KItemId) then
						    NavBtnSubFrame.ListBtns[i].IconBtnCenter:GetNormalTexture():SetDesaturated(true);
						    NavBtnSubFrame.ListBtns[i].ActBtn:SetText("|cFF006E00激活|r");
					    end
				    end
			    end
            end
        end

		-- 对比当前缓存和旧的缓存是否有物品从背包中增加
		for ItemId in pairs(NewItems) do
            if (not CurrentItems[ItemId]) then
                for i = 1, PageSize do
				    if (NavBtnSubFrame.ListBtns[i]:IsEnabled()) then
					    local KItemId = NavBtnSubFrame.ListBtns[i]:GetID();
					    if (tonumber(ItemId) == KItemId) then
						    NavBtnSubFrame.ListBtns[i].IconBtnCenter:GetNormalTexture():SetDesaturated(false);
						    NavBtnSubFrame.ListBtns[i].ActBtn:SetText("|cFF00FF00激活|r");
					    end
				    end
			    end
            end
        end

		-- 更新背包物品的缓存
        CurrentItems = NewItems;
	elseif (event == "PLAYER_LOGIN") then
        Dream_SendData("GetItemPicGuideSubBtnCount");
	end
end

--交互消息事件
PicGuideFrame:RegisterEvent("CHAT_MSG_ADDON");
PicGuideFrame:RegisterEvent("BAG_UPDATE")
PicGuideFrame:RegisterEvent("PLAYER_LOGIN");
PicGuideFrame:SetScript("OnEvent", Dream_OnPicGuideEvent);
