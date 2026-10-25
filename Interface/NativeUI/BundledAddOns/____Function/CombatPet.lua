local CombatPetLefSubFrames = {}
local SubFrameWidth = 200;
local SubFrameHeight = 80;
local MaxPetCount = 24;

StaticPopupDialogs["AddonDeleteDB"] = {

	text = "%s",
	button1 = "确定",
	button2 = "取消",

	OnAccept = function(Self)
        Dream_SendData("AcceptAddonDeleteDB", Self.NowIndex);
		UpdateTabSunFrameDeleteHide(Self.NowIndex);
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

local CombatPetFrame = CreateFrame("Frame", "CombatPetFrame", UIParent);
CombatPetFrame:SetSize(1024, 800);
CombatPetFrame:RegisterForDrag("LeftButton");
CombatPetFrame:SetPoint("CENTER", 0, 0);
CombatPetFrame:SetToplevel(true);
CombatPetFrame:SetClampedToScreen(true);
CombatPetFrame:SetBackdrop({ bgFile = "Interface\\Icons\\P1" });

tinsert(UISpecialFrames, "CombatPetFrame");
CombatPetFrame:Hide();

local CombatPetClose = CreateFrame("Button", "CombatPetClose", CombatPetFrame, "UIPanelCloseButton");
CombatPetClose:SetPoint("TOPRIGHT", -42, -52);
CombatPetClose:EnableMouse(true);
CombatPetClose:SetSize(52, 52);

--滚动左
local CombatPetLeftScrollFrame = CreateFrame("ScrollFrame","CombatPetLeftScrollFrame",CombatPetFrame);
CombatPetLeftScrollFrame:SetSize(220, 540);
CombatPetLeftScrollFrame:SetPoint("LEFT", 100, -20);
CombatPetLeftScrollFrame:Show();
CombatPetLeftScrollFrame:EnableMouse(true);
CombatPetLeftScrollFrame:EnableMouseWheel(true);

--滚动子窗口
local CombatPetLefScrollChildFrame = CreateFrame("Frame","CombatPetLefScrollChildFrame",CombatPetLeftScrollFrame);
CombatPetLefScrollChildFrame:SetSize(220, 540);
CombatPetLefScrollChildFrame:SetPoint("CENTER");
CombatPetLefScrollChildFrame:Show();
CombatPetLeftScrollFrame:SetScrollChild(CombatPetLefScrollChildFrame);

--滚动条
local CombatPetLefSlider = CreateFrame("Slider","CombatPetLefSlider",CombatPetLeftScrollFrame, "OptionsSliderTemplate");
CombatPetLefSlider:SetSize(20, 540);
CombatPetLefSlider:SetPoint("RIGHT",CombatPetLeftScrollFrame, 16, 0);
CombatPetLefSlider:SetOrientation("VERTICAL");
_G[CombatPetLefSlider:GetName().."High"]:Hide();
_G[CombatPetLefSlider:GetName().."Low"]:Hide();
CombatPetLefSlider:SetMinMaxValues(1, 100);
CombatPetLefSlider:SetValue(1);
CombatPetLefSlider:SetValueStep(1.0);
CombatPetLefSlider:EnableMouseWheel(true);

CombatPetLefSlider:SetScript("OnValueChanged",
function(self,offset)
    CombatPetLeftScrollFrame:SetVerticalScroll(math.ceil((CombatPetLefScrollChildFrame:GetHeight() - CombatPetLeftScrollFrame:GetHeight()) / 100 * self:GetValue()))
end);

--鼠标在左内滑动时
CombatPetLeftScrollFrame:SetScript("OnMouseWheel",
function(self, Val)
	local MinVal,MaxVal = CombatPetLefSlider:GetMinMaxValues()
	local InVal = CombatPetLefSlider:GetValue()
	local De = InVal - (Val * 4)
	De = max(De, MinVal)
	De = min(De, MaxVal)
	if (De ~= InVal) then
		CombatPetLefSlider:SetValue(De);
	end
end)

--在本体内滑动时
CombatPetLefSlider:SetScript("OnMouseWheel",
function(self, Val)
	local MinVal,MaxVal = self:GetMinMaxValues()
	local InVal = self:GetValue()
	local De = InVal - (Val * 4)
	De = max(De, MinVal)
	De = min(De, MaxVal)
	if (De ~= InVal) then
		self:SetValue(De);
	end
end)

for i=1,MaxPetCount do
	CombatPetLefSubFrames[i] = CreateFrame("Frame", "CombatPetLefSubFrame"..i, CombatPetLefScrollChildFrame);
    CombatPetLefSubFrames[i]:SetSize(SubFrameWidth, SubFrameHeight);
    CombatPetLefSubFrames[i]:SetPoint("TOP", CombatPetLefScrollChildFrame, 0, -((SubFrameHeight + 6) * (i - 1) + 10));
	CombatPetLefSubFrames[i]:EnableMouse(true);

	CombatPetLefSubFrames[i].SelectIndex = 1;
	CombatPetLefSubFrames[i].CreEntry = 0;
	CombatPetLefSubFrames[i].CreRank = 0;
	CombatPetLefSubFrames[i].CreNowXp = 1;
	CombatPetLefSubFrames[i].CreNeedXp = 0;
	CombatPetLefSubFrames[i].CreScore = 0;
	CombatPetLefSubFrames[i].MaxHp = 1;
	CombatPetLefSubFrames[i].MinDmg = 1;
	CombatPetLefSubFrames[i].MaxDmg = 2;
	CombatPetLefSubFrames[i].Stat1 = 1;
	CombatPetLefSubFrames[i].Stat2 = 1;
	CombatPetLefSubFrames[i].Stat3 = 1;
	CombatPetLefSubFrames[i].Stat4 = 1;

	CombatPetLefSubFrames[i].Texture = CombatPetLefSubFrames[i]:CreateTexture();
	CombatPetLefSubFrames[i].Texture:SetSize(64, 64);
	CombatPetLefSubFrames[i].Texture:SetPoint("LEFT", CombatPetLefSubFrames[i], 0, 0);
	CombatPetLefSubFrames[i].Texture:SetTexture("Interface\\Icons\\P3");

	CombatPetLefSubFrames[i].InfoStrs = CombatPetLefSubFrames[i]:CreateFontString("InfoStrs"..i);
	CombatPetLefSubFrames[i].InfoStrs:SetSize(120, 64);
	CombatPetLefSubFrames[i].InfoStrs:SetFont(Dream_GameFont, 18);
	CombatPetLefSubFrames[i].InfoStrs:SetPoint("CENTER", CombatPetLefSubFrames[i], 10, 0);
	CombatPetLefSubFrames[i].InfoStrs:SetText("|cFF999999无战宠|r");

	CombatPetLefSubFrames[i].Button = CreateFrame("Button", "CombatPetLefSubFrameButton"..i, CombatPetLefSubFrames[i]);
    CombatPetLefSubFrames[i].Button:SetSize(SubFrameWidth, SubFrameHeight);
	CombatPetLefSubFrames[i].Button:SetAllPoints(CombatPetLefSubFrames[i]);
	CombatPetLefSubFrames[i].Button:EnableMouse(true);
	CombatPetLefSubFrames[i].Button:SetHighlightTexture("Interface\\Icons\\P2");

	CombatPetLefSubFrames[i].Button:SetScript("OnClick",
    function(self)
		UpdateTabSunFrameShow(i);
    end)

    CombatPetLefSubFrames[i]:SetBackdrop(
    {
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 8,
        insets = { left = 4, right = 4, top = 4, bottom = 4 }
    });

	--子模型显示
	CombatPetLefSubFrames[i].CombatPetTabSubFrame = CreateFrame("Frame", "CombatPetTabSubFrame"..i, CombatPetFrame);
	CombatPetLefSubFrames[i].CombatPetTabSubFrame:SetSize(580, 480);
	CombatPetLefSubFrames[i].CombatPetTabSubFrame:SetPoint("LEFT", CombatPetFrame, 340, -10);
	CombatPetLefSubFrames[i].CombatPetTabSubFrame:Hide();

	CombatPetLefSubFrames[i].CombatPetModelFrame = CreateFrame("PlayerModel", "CombatPetModelFrame"..i, CombatPetLefSubFrames[i].CombatPetTabSubFrame);
	CombatPetLefSubFrames[i].CombatPetModelFrame:EnableMouse(true)
	CombatPetLefSubFrames[i].CombatPetModelFrame:SetSize(240, 300);
	CombatPetLefSubFrames[i].CombatPetModelFrame:SetPoint("TOPLEFT", CombatPetLefSubFrames[i].CombatPetTabSubFrame, 20, -10);
	CombatPetLefSubFrames[i].CombatPetModelFrame:SetCreature(0);
	CombatPetLefSubFrames[i].CombatPetModelFrame:SetBackdrop(
    {
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 8,
        insets = { left = 4, right = 4, top = 4, bottom = 4 }
    });

	CombatPetLefSubFrames[i].CombatPetModelFrame.PetRotationLeftButton = CreateFrame("Button", "PetRotationLeftButton"..i, CombatPetLefSubFrames[i].CombatPetModelFrame);
	CombatPetLefSubFrames[i].CombatPetModelFrame.PetRotationLeftButton:SetPoint("CENTER", CombatPetLefSubFrames[i].CombatPetModelFrame, "BOTTOM", -80, 30)
	CombatPetLefSubFrames[i].CombatPetModelFrame.PetRotationLeftButton:EnableMouse(true);
	CombatPetLefSubFrames[i].CombatPetModelFrame.PetRotationLeftButton:SetSize(35, 35);
	CombatPetLefSubFrames[i].CombatPetModelFrame.PetRotationLeftButton:SetNormalTexture("Interface\\Buttons\\UI-RotationLeft-Button-Up");
	CombatPetLefSubFrames[i].CombatPetModelFrame.PetRotationLeftButton:SetPushedTexture("Interface\\Buttons\\UI-RotationLeft-Button-Down");
	CombatPetLefSubFrames[i].CombatPetModelFrame.PetRotationLeftButton:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Round");

    CombatPetLefSubFrames[i].CombatPetModelFrame.PetRotationRightButton = CreateFrame("Button", "PetRotationRightButton"..i, CombatPetLefSubFrames[i].CombatPetModelFrame);
    CombatPetLefSubFrames[i].CombatPetModelFrame.PetRotationRightButton:SetPoint("CENTER", CombatPetLefSubFrames[i].CombatPetModelFrame, "BOTTOM", 80, 30)
    CombatPetLefSubFrames[i].CombatPetModelFrame.PetRotationRightButton:EnableMouse(true);
    CombatPetLefSubFrames[i].CombatPetModelFrame.PetRotationRightButton:SetSize(35, 35);
    CombatPetLefSubFrames[i].CombatPetModelFrame.PetRotationRightButton:SetNormalTexture("Interface\\Buttons\\UI-RotationRight-Button-Up");
    CombatPetLefSubFrames[i].CombatPetModelFrame.PetRotationRightButton:SetPushedTexture("Interface\\Buttons\\UI-RotationRight-Button-Down");
    CombatPetLefSubFrames[i].CombatPetModelFrame.PetRotationRightButton:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Round");

    local turnSpeed = 34
    CombatPetLefSubFrames[i].CombatPetModelFrame:SetPosition(0, 0, 0);
    CombatPetLefSubFrames[i].CombatPetModelFrame:SetScript(
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

    CombatPetLefSubFrames[i].CombatPetModelFrame:SetScript(
	"OnMouseUp",
	function(self, button)
		self:SetScript("OnUpdate", nil)
	end
    )

    CombatPetLefSubFrames[i].CombatPetModelFrame.PetRotationLeftButton:SetScript(
	"OnMouseDown",
	function(self, button)
		self:SetScript(
			"OnUpdate",
			function(self, elapsed)
				if (CombatPetLefSubFrames[i].CombatPetModelFrame:IsShown()) then
					CombatPetLefSubFrames[i].CombatPetModelFrame:SetFacing(CombatPetLefSubFrames[i].CombatPetModelFrame:GetFacing() + 0.03)
				end
			end
		)
	end
    )

    CombatPetLefSubFrames[i].CombatPetModelFrame.PetRotationLeftButton:SetScript(
	"OnMouseUp",
	function(self, button)
		self:SetScript("OnUpdate", nil)
	end
    )

    CombatPetLefSubFrames[i].CombatPetModelFrame.PetRotationRightButton:SetScript(
	"OnMouseDown",
	function(self, button)
		self:SetScript(
			"OnUpdate",
			function(self, elapsed)
				if (CombatPetLefSubFrames[i].CombatPetModelFrame:IsShown()) then
					CombatPetLefSubFrames[i].CombatPetModelFrame:SetFacing(CombatPetLefSubFrames[i].CombatPetModelFrame:GetFacing() - 0.03)
				end
			end
		)
	end
    )

    CombatPetLefSubFrames[i].CombatPetModelFrame.PetRotationRightButton:SetScript(
	"OnMouseUp",
	function(self, button)
		self:SetScript("OnUpdate", nil)
	end
    )

	CombatPetLefSubFrames[i].CombatPetTabSubFrame.ShowRank = CombatPetLefSubFrames[i].CombatPetTabSubFrame:CreateFontString("ShowRank"..i);
	CombatPetLefSubFrames[i].CombatPetTabSubFrame.ShowRank:SetFont(Dream_GameFont, 18);
	CombatPetLefSubFrames[i].CombatPetTabSubFrame.ShowRank:SetPoint("TOPLEFT", 270, -30);
	CombatPetLefSubFrames[i].CombatPetTabSubFrame.ShowRank:SetText("|cFF0000FF战宠阶级: "..CombatPetLefSubFrames[i].CreRank.." 阶|r");

	CombatPetLefSubFrames[i].CombatPetTabSubFrame.ShowScore = CombatPetLefSubFrames[i].CombatPetTabSubFrame:CreateFontString("ShowScore"..i);
	CombatPetLefSubFrames[i].CombatPetTabSubFrame.ShowScore:SetFont(Dream_GameFont, 18);
	CombatPetLefSubFrames[i].CombatPetTabSubFrame.ShowScore:SetPoint("TOPLEFT", 270, -60);
	CombatPetLefSubFrames[i].CombatPetTabSubFrame.ShowScore:SetText("|cFF0000FF资质评分: "..CombatPetLefSubFrames[i].CreScore.."|r");

	CombatPetLefSubFrames[i].CombatPetTabSubFrame.ShowMaxHp = CombatPetLefSubFrames[i].CombatPetTabSubFrame:CreateFontString("ShowMaxHp"..i);
	CombatPetLefSubFrames[i].CombatPetTabSubFrame.ShowMaxHp:SetFont(Dream_GameFont, 18);
	CombatPetLefSubFrames[i].CombatPetTabSubFrame.ShowMaxHp:SetPoint("TOPLEFT", 270, -90);
	CombatPetLefSubFrames[i].CombatPetTabSubFrame.ShowMaxHp:SetText("|cFF0000FF生命值: "..CombatPetLefSubFrames[i].MaxHp.."|r");

	CombatPetLefSubFrames[i].CombatPetTabSubFrame.ShowMinDmg = CombatPetLefSubFrames[i].CombatPetTabSubFrame:CreateFontString("ShowMinDmg"..i);
	CombatPetLefSubFrames[i].CombatPetTabSubFrame.ShowMinDmg:SetFont(Dream_GameFont, 18);
	CombatPetLefSubFrames[i].CombatPetTabSubFrame.ShowMinDmg:SetPoint("TOPLEFT", 270, -120);
	CombatPetLefSubFrames[i].CombatPetTabSubFrame.ShowMinDmg:SetText("|cFF0000FF最小伤害: "..CombatPetLefSubFrames[i].MinDmg.."|r");

	CombatPetLefSubFrames[i].CombatPetTabSubFrame.ShowMaxDmg = CombatPetLefSubFrames[i].CombatPetTabSubFrame:CreateFontString("ShowMaxDmg"..i);
	CombatPetLefSubFrames[i].CombatPetTabSubFrame.ShowMaxDmg:SetFont(Dream_GameFont, 18);
	CombatPetLefSubFrames[i].CombatPetTabSubFrame.ShowMaxDmg:SetPoint("TOPLEFT", 270, -150);
	CombatPetLefSubFrames[i].CombatPetTabSubFrame.ShowMaxDmg:SetText("|cFF0000FF最大伤害: "..CombatPetLefSubFrames[i].MaxDmg.."|r");

	CombatPetLefSubFrames[i].CombatPetTabSubFrame.ShowS1 = CombatPetLefSubFrames[i].CombatPetTabSubFrame:CreateFontString("ShowS1"..i);
	CombatPetLefSubFrames[i].CombatPetTabSubFrame.ShowS1:SetFont(Dream_GameFont, 18);
	CombatPetLefSubFrames[i].CombatPetTabSubFrame.ShowS1:SetPoint("TOPLEFT", 270, -180);
	CombatPetLefSubFrames[i].CombatPetTabSubFrame.ShowS1:SetText("|cFF0000FF力量: "..CombatPetLefSubFrames[i].Stat1.."|r");

	CombatPetLefSubFrames[i].CombatPetTabSubFrame.ShowS2 = CombatPetLefSubFrames[i].CombatPetTabSubFrame:CreateFontString("ShowS2"..i);
	CombatPetLefSubFrames[i].CombatPetTabSubFrame.ShowS2:SetFont(Dream_GameFont, 18);
	CombatPetLefSubFrames[i].CombatPetTabSubFrame.ShowS2:SetPoint("TOPLEFT", 270, -210);
	CombatPetLefSubFrames[i].CombatPetTabSubFrame.ShowS2:SetText("|cFF0000FF敏捷: "..CombatPetLefSubFrames[i].Stat2.."|r");

	CombatPetLefSubFrames[i].CombatPetTabSubFrame.ShowS3 = CombatPetLefSubFrames[i].CombatPetTabSubFrame:CreateFontString("ShowS3"..i);
	CombatPetLefSubFrames[i].CombatPetTabSubFrame.ShowS3:SetFont(Dream_GameFont, 18);
	CombatPetLefSubFrames[i].CombatPetTabSubFrame.ShowS3:SetPoint("TOPLEFT", 270, -240);
	CombatPetLefSubFrames[i].CombatPetTabSubFrame.ShowS3:SetText("|cFF0000FF智力: "..CombatPetLefSubFrames[i].Stat3.."|r");

	CombatPetLefSubFrames[i].CombatPetTabSubFrame.ShowS4 = CombatPetLefSubFrames[i].CombatPetTabSubFrame:CreateFontString("ShowS4"..i);
	CombatPetLefSubFrames[i].CombatPetTabSubFrame.ShowS4:SetFont(Dream_GameFont, 18);
	CombatPetLefSubFrames[i].CombatPetTabSubFrame.ShowS4:SetPoint("TOPLEFT", 270, -270);
	CombatPetLefSubFrames[i].CombatPetTabSubFrame.ShowS4:SetText("|cFF0000FF精神: "..CombatPetLefSubFrames[i].Stat4.."|r");

	CombatPetLefSubFrames[i].CombatPetTabSubFrame.SpellGts = CombatPetLefSubFrames[i].CombatPetTabSubFrame:CreateFontString("SpellGts"..i);
	CombatPetLefSubFrames[i].CombatPetTabSubFrame.SpellGts:SetFont(Dream_GameFont, 18);
	CombatPetLefSubFrames[i].CombatPetTabSubFrame.SpellGts:SetPoint("LEFT", 20, -100);
	CombatPetLefSubFrames[i].CombatPetTabSubFrame.SpellGts:SetText("|cFF0000FF战宠技能:|r");

	CombatPetLefSubFrames[i].CombatPetTabSubFrame.XpText = CombatPetLefSubFrames[i].CombatPetTabSubFrame:CreateFontString("XpText"..i);
	CombatPetLefSubFrames[i].CombatPetTabSubFrame.XpText:SetFont(Dream_GameFont, 18);
	CombatPetLefSubFrames[i].CombatPetTabSubFrame.XpText:SetPoint("LEFT", 20, -150);
	CombatPetLefSubFrames[i].CombatPetTabSubFrame.XpText:SetText("|cFF0000FF战宠经验:|r");

	--进度条
	CombatPetLefSubFrames[i].CombatPetTabSubFrame.ButtonBar = CreateFrame("Button", "ButtonBar"..i, CombatPetLefSubFrames[i].CombatPetTabSubFrame);
	CombatPetLefSubFrames[i].CombatPetTabSubFrame.ButtonBar:SetSize(400, 30);
	CombatPetLefSubFrames[i].CombatPetTabSubFrame.ButtonBar:SetPoint("BOTTOM", 30, 75);
	CombatPetLefSubFrames[i].CombatPetTabSubFrame.ButtonBar:SetBackdrop(
    {
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 12,
        insets = { left = 3, right = 3, top = 3, bottom = 3 }
    });

	CombatPetLefSubFrames[i].CombatPetTabSubFrame.AtStatusBarOne = CreateFrame("StatusBar", "AtStatusBarOne", CombatPetLefSubFrames[i].CombatPetTabSubFrame.ButtonBar);
	CombatPetLefSubFrames[i].CombatPetTabSubFrame.AtStatusBarOne:SetOrientation("HORIZONTAL");
	CombatPetLefSubFrames[i].CombatPetTabSubFrame.AtStatusBarOne:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar");
	CombatPetLefSubFrames[i].CombatPetTabSubFrame.AtStatusBarOne:SetStatusBarColor(255/255, 102/255, 0/255);
	CombatPetLefSubFrames[i].CombatPetTabSubFrame.AtStatusBarOne:SetPoint("CENTER");
	CombatPetLefSubFrames[i].CombatPetTabSubFrame.AtStatusBarOne:SetSize(CombatPetLefSubFrames[i].CombatPetTabSubFrame.ButtonBar:GetWidth() - 8, CombatPetLefSubFrames[i].CombatPetTabSubFrame.ButtonBar:GetHeight() - 8);
	CombatPetLefSubFrames[i].CombatPetTabSubFrame.AtStatusBarOne:SetMinMaxValues(1, 100);

	CombatPetLefSubFrames[i].CombatPetTabSubFrame.ButtonBarTexts = CombatPetLefSubFrames[i].CombatPetTabSubFrame.AtStatusBarOne:CreateFontString("ButtonBarTexts");
	CombatPetLefSubFrames[i].CombatPetTabSubFrame.ButtonBarTexts:SetFont(Dream_GameFont, 15);
	CombatPetLefSubFrames[i].CombatPetTabSubFrame.ButtonBarTexts:SetAllPoints(CombatPetLefSubFrames[i].CombatPetTabSubFrame.AtStatusBarOne);

	local Schedule = (CombatPetLefSubFrames[i].CreNeedXp > 0) and (CombatPetLefSubFrames[i].CreNowXp * 100 / CombatPetLefSubFrames[i].CreNeedXp) or 0;
	CombatPetLefSubFrames[i].CombatPetTabSubFrame.ButtonBarTexts:SetText("|cFF00FF00经验 "..CombatPetLefSubFrames[i].CreNowXp.."/"..CombatPetLefSubFrames[i].CreNeedXp.." 进度 "..string.format("%.f", Schedule).."%|r")
	CombatPetLefSubFrames[i].CombatPetTabSubFrame.AtStatusBarOne:SetValue(math.floor(Schedule));

	CombatPetLefSubFrames[i].CombatPetTabSubFrame.SpellButton = {};
	for B=1,8 do
		CombatPetLefSubFrames[i].CombatPetTabSubFrame.SpellButton[B] = CreateFrame("Button", "CombatPetTabSubFrameSpellButton"..i, CombatPetLefSubFrames[i].CombatPetTabSubFrame);
		CombatPetLefSubFrames[i].CombatPetTabSubFrame.SpellButton[B]:SetPoint("LEFT", 120 + (B - 1) * 50, -100);
		CombatPetLefSubFrames[i].CombatPetTabSubFrame.SpellButton[B]:SetSize(48, 48);
		CombatPetLefSubFrames[i].CombatPetTabSubFrame.SpellButton[B]:SetID(0);
		CombatPetLefSubFrames[i].CombatPetTabSubFrame.SpellButton[B]:SetBackdrop({ bgFile = "Interface\\Buttons\\UI-EmptySlot-White"});

		CombatPetLefSubFrames[i].CombatPetTabSubFrame.SpellButton[B].TextStr = CombatPetLefSubFrames[i].CombatPetTabSubFrame.SpellButton[B]:CreateFontString("CombatPetTabSubFrameSpellButtonTextStr"..i);
		CombatPetLefSubFrames[i].CombatPetTabSubFrame.SpellButton[B].TextStr:SetFont(Dream_GameFont, 12);
		CombatPetLefSubFrames[i].CombatPetTabSubFrame.SpellButton[B].TextStr:SetAllPoints(CombatPetLefSubFrames[i].CombatPetTabSubFrame.SpellButton[B]);
		CombatPetLefSubFrames[i].CombatPetTabSubFrame.SpellButton[B]:SetFontString(CombatPetLefSubFrames[i].CombatPetTabSubFrame.SpellButton[B].TextStr);
		CombatPetLefSubFrames[i].CombatPetTabSubFrame.SpellButton[B]:SetText("");

		CombatPetLefSubFrames[i].CombatPetTabSubFrame.SpellButton[B]:SetScript("OnEnter",
		function(self)
			if (self:GetID() <= 0) then
				return;
			end
			GameTooltip:SetOwner(self, "ANCHOR_BOTTOM");
			GameTooltip:SetHyperlink("spell:"..self:GetID());
			GameTooltip:Show();
		end)

		CombatPetLefSubFrames[i].CombatPetTabSubFrame.SpellButton[B]:SetScript("OnLeave",
		function(self)
			GameTooltip:Hide();
		end)
	end

	CombatPetLefSubFrames[i].CombatPetTabSubFrame.FuncButton1 = CreateFrame("Button","FuncButton1"..i, CombatPetLefSubFrames[i].CombatPetTabSubFrame);
	CombatPetLefSubFrames[i].CombatPetTabSubFrame.FuncButton1:SetSize(100, 50);
	CombatPetLefSubFrames[i].CombatPetTabSubFrame.FuncButton1:EnableMouse(true);
	CombatPetLefSubFrames[i].CombatPetTabSubFrame.FuncButton1:SetBackdrop({ bgFile = "Interface\\Icons\\P4" })
    CombatPetLefSubFrames[i].CombatPetTabSubFrame.FuncButton1:SetHighlightTexture("Interface\\Buttons\\UI-Panel-MinimizeButton-Highlight")
	CombatPetLefSubFrames[i].CombatPetTabSubFrame.FuncButton1:SetPoint("BOTTOMLEFT", 50, -30);
	CombatPetLefSubFrames[i].CombatPetTabSubFrame.FuncStr1 = CombatPetLefSubFrames[i].CombatPetTabSubFrame.FuncButton1:CreateFontString("FuncStr1"..i);
	CombatPetLefSubFrames[i].CombatPetTabSubFrame.FuncStr1:SetFont(Dream_GameFont, 18);
	CombatPetLefSubFrames[i].CombatPetTabSubFrame.FuncButton1:SetFontString(CombatPetLefSubFrames[i].CombatPetTabSubFrame.FuncStr1);
	CombatPetLefSubFrames[i].CombatPetTabSubFrame.FuncButton1:SetText("|cffFFC125战宠合体|r");

	CombatPetLefSubFrames[i].CombatPetTabSubFrame.FuncButton1:SetScript("OnClick",
    function(self)
		if (CombatPetLefSubFrames[i].SelectIndex == 0) then
			return;
		end
		Dream_SendData("FitCombatPetNow", tostring(CombatPetLefSubFrames[i].SelectIndex));
    end)

	CombatPetLefSubFrames[i].CombatPetTabSubFrame.FuncButton2 = CreateFrame("Button","FuncButton2"..i, CombatPetLefSubFrames[i].CombatPetTabSubFrame);
	CombatPetLefSubFrames[i].CombatPetTabSubFrame.FuncButton2:SetSize(100, 50);
	CombatPetLefSubFrames[i].CombatPetTabSubFrame.FuncButton2:EnableMouse(true);
	CombatPetLefSubFrames[i].CombatPetTabSubFrame.FuncButton2:SetBackdrop({ bgFile = "Interface\\Icons\\P4" })
    CombatPetLefSubFrames[i].CombatPetTabSubFrame.FuncButton2:SetHighlightTexture("Interface\\Buttons\\UI-Panel-MinimizeButton-Highlight")
	CombatPetLefSubFrames[i].CombatPetTabSubFrame.FuncButton2:SetPoint("BOTTOMLEFT", 150, -30);
	CombatPetLefSubFrames[i].CombatPetTabSubFrame.FuncStr2 = CombatPetLefSubFrames[i].CombatPetTabSubFrame.FuncButton2:CreateFontString("FuncStr2"..i);
	CombatPetLefSubFrames[i].CombatPetTabSubFrame.FuncStr2:SetFont(Dream_GameFont, 18);
	CombatPetLefSubFrames[i].CombatPetTabSubFrame.FuncButton2:SetFontString(CombatPetLefSubFrames[i].CombatPetTabSubFrame.FuncStr2);
	CombatPetLefSubFrames[i].CombatPetTabSubFrame.FuncButton2:SetText("|cffFFC125解除合体|r");

	CombatPetLefSubFrames[i].CombatPetTabSubFrame.FuncButton2:SetScript("OnClick",
    function(self)
		if (CombatPetLefSubFrames[i].SelectIndex == 0) then
			return;
		end
		Dream_SendData("ApartCombatPetNow", tostring(CombatPetLefSubFrames[i].SelectIndex));
    end)

	CombatPetLefSubFrames[i].CombatPetTabSubFrame.FuncButton3 = CreateFrame("Button","FuncButton3"..i, CombatPetLefSubFrames[i].CombatPetTabSubFrame);
	CombatPetLefSubFrames[i].CombatPetTabSubFrame.FuncButton3:SetSize(100, 50);
	CombatPetLefSubFrames[i].CombatPetTabSubFrame.FuncButton3:EnableMouse(true);
	CombatPetLefSubFrames[i].CombatPetTabSubFrame.FuncButton3:SetBackdrop({ bgFile = "Interface\\Icons\\P4" })
    CombatPetLefSubFrames[i].CombatPetTabSubFrame.FuncButton3:SetHighlightTexture("Interface\\Buttons\\UI-Panel-MinimizeButton-Highlight")
	CombatPetLefSubFrames[i].CombatPetTabSubFrame.FuncButton3:SetPoint("BOTTOMLEFT", 250, -30);
	CombatPetLefSubFrames[i].CombatPetTabSubFrame.FuncStr3 = CombatPetLefSubFrames[i].CombatPetTabSubFrame.FuncButton3:CreateFontString("FuncStr3"..i);
	CombatPetLefSubFrames[i].CombatPetTabSubFrame.FuncStr3:SetFont(Dream_GameFont, 18);
	CombatPetLefSubFrames[i].CombatPetTabSubFrame.FuncButton3:SetFontString(CombatPetLefSubFrames[i].CombatPetTabSubFrame.FuncStr3);
	CombatPetLefSubFrames[i].CombatPetTabSubFrame.FuncButton3:SetText("|cffFFC125战宠出战|r");

	CombatPetLefSubFrames[i].CombatPetTabSubFrame.FuncButton3:SetScript("OnClick",
    function(self)
		if (CombatPetLefSubFrames[i].SelectIndex == 0) then
			return;
		end
		Dream_SendData("AddonToggleSummon", tostring(CombatPetLefSubFrames[i].SelectIndex));
    end)

	CombatPetLefSubFrames[i].CombatPetTabSubFrame.FuncButton4 = CreateFrame("Button","FuncButton4"..i, CombatPetLefSubFrames[i].CombatPetTabSubFrame);
	CombatPetLefSubFrames[i].CombatPetTabSubFrame.FuncButton4:SetSize(100, 50);
	CombatPetLefSubFrames[i].CombatPetTabSubFrame.FuncButton4:EnableMouse(true);
	CombatPetLefSubFrames[i].CombatPetTabSubFrame.FuncButton4:SetBackdrop({ bgFile = "Interface\\Icons\\P4" })
    CombatPetLefSubFrames[i].CombatPetTabSubFrame.FuncButton4:SetHighlightTexture("Interface\\Buttons\\UI-Panel-MinimizeButton-Highlight")
	CombatPetLefSubFrames[i].CombatPetTabSubFrame.FuncButton4:SetPoint("BOTTOMLEFT", 350, -30);
	CombatPetLefSubFrames[i].CombatPetTabSubFrame.FuncStr4 = CombatPetLefSubFrames[i].CombatPetTabSubFrame.FuncButton4:CreateFontString("FuncStr4"..i);
	CombatPetLefSubFrames[i].CombatPetTabSubFrame.FuncStr4:SetFont(Dream_GameFont, 18);
	CombatPetLefSubFrames[i].CombatPetTabSubFrame.FuncButton4:SetFontString(CombatPetLefSubFrames[i].CombatPetTabSubFrame.FuncStr4);
	CombatPetLefSubFrames[i].CombatPetTabSubFrame.FuncButton4:SetText("|cffFFC125解散当前|r");

	CombatPetLefSubFrames[i].CombatPetTabSubFrame.FuncButton4:SetScript("OnClick",
    function(self)
		if (CombatPetLefSubFrames[i].SelectIndex == 0) then
			return;
		end
		Dream_SendData("AddonDismissCritter", tostring(CombatPetLefSubFrames[i].SelectIndex));
    end)

	CombatPetLefSubFrames[i].CombatPetTabSubFrame.FuncButton5 = CreateFrame("Button","FuncBFuncButton5utton4"..i, CombatPetLefSubFrames[i].CombatPetTabSubFrame);
	CombatPetLefSubFrames[i].CombatPetTabSubFrame.FuncButton5:SetSize(100, 50);
	CombatPetLefSubFrames[i].CombatPetTabSubFrame.FuncButton5:EnableMouse(true);
	CombatPetLefSubFrames[i].CombatPetTabSubFrame.FuncButton5:SetBackdrop({ bgFile = "Interface\\Icons\\P4" })
    CombatPetLefSubFrames[i].CombatPetTabSubFrame.FuncButton5:SetHighlightTexture("Interface\\Buttons\\UI-Panel-MinimizeButton-Highlight")
	CombatPetLefSubFrames[i].CombatPetTabSubFrame.FuncButton5:SetPoint("BOTTOMLEFT", 450, -30);
	CombatPetLefSubFrames[i].CombatPetTabSubFrame.FuncStr5 = CombatPetLefSubFrames[i].CombatPetTabSubFrame.FuncButton5:CreateFontString("FuncStr5"..i);
	CombatPetLefSubFrames[i].CombatPetTabSubFrame.FuncStr5:SetFont(Dream_GameFont, 18);
	CombatPetLefSubFrames[i].CombatPetTabSubFrame.FuncButton5:SetFontString(CombatPetLefSubFrames[i].CombatPetTabSubFrame.FuncStr5);
	CombatPetLefSubFrames[i].CombatPetTabSubFrame.FuncButton5:SetText("|cffFFC125彻底丢弃|r");

	CombatPetLefSubFrames[i].CombatPetTabSubFrame.FuncButton5:SetScript("OnClick",
    function(self)
		if (CombatPetLefSubFrames[i].SelectIndex == 0) then
		    return;
	    end
		local Dialog = StaticPopup_Show("AddonDeleteDB", "\n|cFF00FF00你确定永久丢弃此战宠?|r\n\n");
		if (Dialog) then
		    Dialog.NowIndex = CombatPetLefSubFrames[i].SelectIndex;
		end
    end)

	CombatPetLefSubFrames[i].CombatPetTabSubFrame.KGs = CombatPetLefSubFrames[i].CombatPetTabSubFrame:CreateFontString("KGs"..i);
	CombatPetLefSubFrames[i].CombatPetTabSubFrame.KGs:SetFont(Dream_GameFont, 16);
	CombatPetLefSubFrames[i].CombatPetTabSubFrame.KGs:SetPoint("BOTTOM", 0, -60);
	CombatPetLefSubFrames[i].CombatPetTabSubFrame.KGs:SetText("|cFF0000FF战宠合体后主人获得它的一些血量属性等 并且获得其专属的合体特效|r");
end

CombatPetLefScrollChildFrame:SetHeight((SubFrameHeight + 8) * MaxPetCount);

function UpdateTabSunFrameDeleteHide(Index)
	if (CombatPetLefSubFrames[Index].CreEntry ~= 0) then
		CombatPetLefSubFrames[Index].InfoStrs:SetText("|cFF999999无战宠|r");
		CombatPetLefSubFrames[Index].SelectIndex = 1;
		CombatPetLefSubFrames[Index].CreEntry = 0;
		CombatPetLefSubFrames[Index].CreRank = 0;
		CombatPetLefSubFrames[Index].CreNowXp = 1;
		CombatPetLefSubFrames[Index].CreNeedXp = 0;
		CombatPetLefSubFrames[Index].CreScore = 0;
		CombatPetLefSubFrames[Index].MaxHp = 1;
		CombatPetLefSubFrames[Index].MinDmg = 1;
		CombatPetLefSubFrames[Index].MaxDmg = 2;
		CombatPetLefSubFrames[Index].Stat1 = 1;
		CombatPetLefSubFrames[Index].Stat2 = 1;
		CombatPetLefSubFrames[Index].Stat3 = 1;
		CombatPetLefSubFrames[Index].Stat4 = 1;

		CombatPetLefSubFrames[Index].Button:UnlockHighlight();
		CombatPetLefSubFrames[Index].CombatPetModelFrame:SetCreature(0);
		CombatPetLefSubFrames[Index].CombatPetTabSubFrame.ShowRank:SetText("|cFF0000FF战宠阶级: "..CombatPetLefSubFrames[Index].CreRank.." 阶|r");
		CombatPetLefSubFrames[Index].CombatPetTabSubFrame.ShowScore:SetText("|cFF0000FF资质评分: "..CombatPetLefSubFrames[Index].CreScore.."|r");
		CombatPetLefSubFrames[Index].CombatPetTabSubFrame.ShowMaxHp:SetText("|cFF0000FF生命值: "..CombatPetLefSubFrames[Index].MaxHp.."|r");
		CombatPetLefSubFrames[Index].CombatPetTabSubFrame.ShowMinDmg:SetText("|cFF0000FF最小伤害: "..CombatPetLefSubFrames[Index].MinDmg.."|r");
		CombatPetLefSubFrames[Index].CombatPetTabSubFrame.ShowMaxDmg:SetText("|cFF0000FF最大伤害: "..CombatPetLefSubFrames[Index].MaxDmg.."|r");
		CombatPetLefSubFrames[Index].CombatPetTabSubFrame.ShowS1:SetText("|cFF0000FF力量: "..CombatPetLefSubFrames[Index].Stat1.."|r");
		CombatPetLefSubFrames[Index].CombatPetTabSubFrame.ShowS2:SetText("|cFF0000FF敏捷: "..CombatPetLefSubFrames[Index].Stat2.."|r");
		CombatPetLefSubFrames[Index].CombatPetTabSubFrame.ShowS3:SetText("|cFF0000FF智力: "..CombatPetLefSubFrames[Index].Stat3.."|r");
		CombatPetLefSubFrames[Index].CombatPetTabSubFrame.ShowS4:SetText("|cFF0000FF精神: "..CombatPetLefSubFrames[Index].Stat4.."|r");
		for B=1,8 do
			CombatPetLefSubFrames[Index].CombatPetTabSubFrame.SpellButton[B]:SetText("");
		end

		local Schedule = (CombatPetLefSubFrames[Index].CreNeedXp > 0) and (CombatPetLefSubFrames[Index].CreNowXp * 100 / CombatPetLefSubFrames[Index].CreNeedXp) or 0;
		CombatPetLefSubFrames[Index].CombatPetTabSubFrame.ButtonBarTexts:SetText("|cFF00FF00经验 "..CombatPetLefSubFrames[Index].CreNowXp.."/"..CombatPetLefSubFrames[Index].CreNeedXp.." 进度 "..string.format("%.f", Schedule).."%|r")
		CombatPetLefSubFrames[Index].CombatPetTabSubFrame.AtStatusBarOne:SetValue(math.floor(Schedule));

		CombatPetLefSubFrames[Index].CombatPetTabSubFrame:Hide();
	end
end

function UpdateTabSunFrameShow(Index)
	for N=1,MaxPetCount do
		CombatPetLefSubFrames[N].SelectIndex = 0;
		CombatPetLefSubFrames[N].Button:UnlockHighlight();
		CombatPetLefSubFrames[N].CombatPetTabSubFrame:Hide();
	end

	if (CombatPetLefSubFrames[Index].CreEntry ~= 0) then
		CombatPetLefSubFrames[Index].SelectIndex = Index;
		CombatPetLefSubFrames[Index].Button:LockHighlight();
		CombatPetLefSubFrames[Index].CombatPetTabSubFrame:Show();
	    CombatPetLefSubFrames[Index].CombatPetModelFrame:SetCreature(CombatPetLefSubFrames[Index].CreEntry);
		CombatPetLefSubFrames[Index].CombatPetTabSubFrame.ShowRank:SetText("|cFF0000FF战宠阶级: "..CombatPetLefSubFrames[Index].CreRank.." 阶|r");
		CombatPetLefSubFrames[Index].CombatPetTabSubFrame.ShowScore:SetText("|cFF0000FF资质评分: "..CombatPetLefSubFrames[Index].CreScore.."|r");
		CombatPetLefSubFrames[Index].CombatPetTabSubFrame.ShowMaxHp:SetText("|cFF0000FF生命值: "..CombatPetLefSubFrames[Index].MaxHp.."|r");
		CombatPetLefSubFrames[Index].CombatPetTabSubFrame.ShowMinDmg:SetText("|cFF0000FF最小伤害: "..CombatPetLefSubFrames[Index].MinDmg.."|r");
		CombatPetLefSubFrames[Index].CombatPetTabSubFrame.ShowMaxDmg:SetText("|cFF0000FF最大伤害: "..CombatPetLefSubFrames[Index].MaxDmg.."|r");
		CombatPetLefSubFrames[Index].CombatPetTabSubFrame.ShowS1:SetText("|cFF0000FF力量: "..CombatPetLefSubFrames[Index].Stat1.."|r");
		CombatPetLefSubFrames[Index].CombatPetTabSubFrame.ShowS2:SetText("|cFF0000FF敏捷: "..CombatPetLefSubFrames[Index].Stat2.."|r");
		CombatPetLefSubFrames[Index].CombatPetTabSubFrame.ShowS3:SetText("|cFF0000FF智力: "..CombatPetLefSubFrames[Index].Stat3.."|r");
		CombatPetLefSubFrames[Index].CombatPetTabSubFrame.ShowS4:SetText("|cFF0000FF精神: "..CombatPetLefSubFrames[Index].Stat4.."|r");
		for B=1,8 do
			local SpellButton = CombatPetLefSubFrames[Index].CombatPetTabSubFrame.SpellButton[B];
			local SpellId = SpellButton:GetID();
			local SpellIcon = (SpellId > 0) and DreamGetSpellIcon(SpellId) or nil;
			SpellButton:SetText(SpellIcon and ("|T"..SpellIcon..":48|t") or "");
		end

		local Schedule = (CombatPetLefSubFrames[Index].CreNeedXp > 0) and (CombatPetLefSubFrames[Index].CreNowXp * 100 / CombatPetLefSubFrames[Index].CreNeedXp) or 0;
		CombatPetLefSubFrames[Index].CombatPetTabSubFrame.ButtonBarTexts:SetText("|cFF00FF00经验 "..CombatPetLefSubFrames[Index].CreNowXp.."/"..CombatPetLefSubFrames[Index].CreNeedXp.." 进度 "..string.format("%.f", Schedule).."%|r")
		CombatPetLefSubFrames[Index].CombatPetTabSubFrame.AtStatusBarOne:SetValue(math.floor(Schedule));
	end
end

CombatPetFrame:SetScript("OnShow",
function(self)
	UpdateTabSunFrameShow(1);
end)

local function SetCombatPetSpellData(Index, Args, FirstSpellArg)
	local PetFrame = Index and CombatPetLefSubFrames[Index];
	if (not PetFrame or not PetFrame.CombatPetTabSubFrame or not PetFrame.CombatPetTabSubFrame.SpellButton) then
		return;
	end

	for B=1,8 do
		local SpellButton = PetFrame.CombatPetTabSubFrame.SpellButton[B];
		if (SpellButton) then
			local SpellId = tonumber(Args[FirstSpellArg + B - 1]) or 0;
			local SpellIcon = (SpellId > 0) and DreamGetSpellIcon(SpellId) or nil;
			SpellButton:SetID(SpellId);
			SpellButton:SetText(SpellIcon and ("|T"..SpellIcon..":48|t") or "");
		end
	end
end

--消息处理
local function Dream_OnCombatPetEvent(Self, event, Packet, Msg, Type, Sender)
    if (event == "CHAT_MSG_ADDON") then
		if (Packet == "FillCombatPetPlayerDataAll") then
			local Arg = Dream_Split(Msg, "#");
			local Index = tonumber(Arg[1]);
			if (not Index or not CombatPetLefSubFrames[Index]) then
				return;
			end
			local CreEntry = tonumber(Arg[2]);
			local CreRank = tonumber(Arg[3]);

			local CreNowXp = tonumber(Arg[4]);
			local CreNeedXp = tonumber(Arg[5]);

			local CreScore = tonumber(Arg[6]);
			local CreName = Arg[7] or "Unk";
			local MaxHp = Arg[8] or "0";
			local MinDmg = Arg[9] or "0";
			local MaxDmg = Arg[10] or "0";
			local Stat1 = tonumber(Arg[11]) or 0;
			local Stat2 = tonumber(Arg[12]) or 0;
			local Stat3 = tonumber(Arg[13]) or 0;
			local Stat4 = tonumber(Arg[14]) or 0;

			CombatPetLefSubFrames[Index].CreEntry = CreEntry;
			CombatPetLefSubFrames[Index].CreRank = CreRank;
			CombatPetLefSubFrames[Index].CreNowXp = CreNowXp;
			CombatPetLefSubFrames[Index].CreNeedXp = CreNeedXp;
			CombatPetLefSubFrames[Index].CreScore = CreScore;
			CombatPetLefSubFrames[Index].MaxHp = MaxHp;
			CombatPetLefSubFrames[Index].MinDmg = MinDmg;
			CombatPetLefSubFrames[Index].MaxDmg = MaxDmg;
			CombatPetLefSubFrames[Index].Stat1 = Stat1;
			CombatPetLefSubFrames[Index].Stat2 = Stat2;
			CombatPetLefSubFrames[Index].Stat3 = Stat3;
			CombatPetLefSubFrames[Index].Stat4 = Stat4;

			SetCombatPetSpellData(Index, Arg, 15);

			CreName = (CreName == "Unk") and "|cFF999999无战宠|r" or "|cFF00FF00"..CreName.."|r";
			CombatPetLefSubFrames[Index].InfoStrs:SetText(CreName);

			if (Index == 1) then
				UpdateTabSunFrameShow(Index);
			end
		elseif (Packet == "FillCombatPetPlayerDataOne") then
			local Arg = Dream_Split(Msg, "#");
			local Index = tonumber(Arg[1]);
			if (not Index or not CombatPetLefSubFrames[Index]) then
				return;
			end
			local CreEntry = tonumber(Arg[2]);
			local CreRank = tonumber(Arg[3]);

			local CreNowXp = tonumber(Arg[4]);
			local CreNeedXp = tonumber(Arg[5]);

			local CreScore = tonumber(Arg[6]);
			local CreName = Arg[7] or "Unk";
			local MaxHp = Arg[8] or "0";
			local MinDmg = Arg[9] or "0";
			local MaxDmg = Arg[10] or "0";
			local Stat1 = tonumber(Arg[11]) or 0;
			local Stat2 = tonumber(Arg[12]) or 0;
			local Stat3 = tonumber(Arg[13]) or 0;
			local Stat4 = tonumber(Arg[14]) or 0;

			CombatPetLefSubFrames[Index].CreEntry = CreEntry;
			CombatPetLefSubFrames[Index].CreRank = CreRank;
			CombatPetLefSubFrames[Index].CreNowXp = CreNowXp;
			CombatPetLefSubFrames[Index].CreNeedXp = CreNeedXp;
			CombatPetLefSubFrames[Index].CreScore = CreScore;
			CombatPetLefSubFrames[Index].MaxHp = MaxHp;
			CombatPetLefSubFrames[Index].MinDmg = MinDmg;
			CombatPetLefSubFrames[Index].MaxDmg = MaxDmg;
			CombatPetLefSubFrames[Index].Stat1 = Stat1;
			CombatPetLefSubFrames[Index].Stat2 = Stat2;
			CombatPetLefSubFrames[Index].Stat3 = Stat3;
			CombatPetLefSubFrames[Index].Stat4 = Stat4;

			SetCombatPetSpellData(Index, Arg, 15);

			CombatPetLefSubFrames[Index].InfoStrs:SetText("|cFF00FF00"..CreName.."|r");
			UpdateTabSunFrameShow(Index);
		elseif (Packet == "FillCombatPetPlayerStats") then
			local Arg = Dream_Split(Msg, "#");
			local Index = tonumber(Arg[1]);
			local PetFrame = Index and CombatPetLefSubFrames[Index];
			if (not PetFrame) then
				return;
			end

			PetFrame.MaxHp = Arg[2] or PetFrame.MaxHp or "0";
			PetFrame.MinDmg = Arg[3] or PetFrame.MinDmg or "0";
			PetFrame.MaxDmg = Arg[4] or PetFrame.MaxDmg or "0";
			PetFrame.Stat1 = tonumber(Arg[5]) or PetFrame.Stat1 or 0;
			PetFrame.Stat2 = tonumber(Arg[6]) or PetFrame.Stat2 or 0;
			PetFrame.Stat3 = tonumber(Arg[7]) or PetFrame.Stat3 or 0;
			PetFrame.Stat4 = tonumber(Arg[8]) or PetFrame.Stat4 or 0;

			if (tonumber(Arg[9]) == 1) then
				UpdateTabSunFrameShow(Index);
			end
		elseif (Packet == "FillCombatPetPlayerSpells") then
			local Arg = Dream_Split(Msg, "#");
			SetCombatPetSpellData(tonumber(Arg[1]), Arg, 2);
		elseif (Packet == "UpdatePlayerDataXpAndRankOne") then
			local Arg = Dream_Split(Msg, "#");
			local Index = tonumber(Arg[1]);
			local CreRank = tonumber(Arg[2]);
			local CreNowXp = tonumber(Arg[3]);
			local CreNeedXp = tonumber(Arg[4]);
			CombatPetLefSubFrames[Index].CreRank = CreRank;
			CombatPetLefSubFrames[Index].CreNowXp = CreNowXp;
			CombatPetLefSubFrames[Index].CreNeedXp = CreNeedXp;
			UpdateTabSunFrameShow(Index);
		elseif (Packet == "DoUpdateFitCombatPetNow") then
			local Index = tonumber(Msg);
			local CreName = CombatPetLefSubFrames[Index].InfoStrs:GetText();
			CombatPetLefSubFrames[Index].InfoStrs:SetText(CreName.."-合体");
		elseif (Packet == "DoApartCombatPetNow") then
			local Index = tonumber(Msg);
			local RText = CombatPetLefSubFrames[Index].InfoStrs:GetText();
			local CreName = string.gsub(RText, "-合体", "");
			CombatPetLefSubFrames[Index].InfoStrs:SetText(CreName);
		end
	elseif (event == "PLAYER_LOGIN") then
		Dream_SendData("GetCombatPetPlayerData");
	end
end

--交互消息事件
local CombatPetAddonFrame = CreateFrame("Frame", "CombatPetAddonFrame");
CombatPetAddonFrame:RegisterEvent("CHAT_MSG_ADDON");
CombatPetAddonFrame:RegisterEvent("PLAYER_LOGIN");
CombatPetAddonFrame:SetScript("OnEvent", Dream_OnCombatPetEvent);

--------------------------------------------------------------------



