local GarrisonOrderHallReportButtons = {}
local GarrisonOrderHallReportGarrisons = {}
local GarrisonOrderHallReportCovenant
GarrisonOrderHallReportGarrison = nil

function GarrisonOrderHallReportFixFrame()
	if GarrisonLandingPage.garrTypeID == 111 then
		GarrisonLandingPage.Report.Sections:Show()
	elseif GarrisonOrderHallReportCovenant > 0 then
		GarrisonLandingPage.Report.Sections:Hide()
		GarrisonLandingPage.FollowerTabButton:SetText("Followers")
	end
end

ExpansionLandingPageMinimapButton:SetScript("OnClick", function(self, button, down)
	GarrisonOrderHallReportCovenant = C_Covenants.GetActiveCovenantID()
	if button == GarrisonOrderHallReportButton then
		if GarrisonLandingPage ~= nil then
			HideUIPanel(GarrisonLandingPage)
		end
		if ExpansionLandingPage ~= nil then
			HideUIPanel(ExpansionLandingPage)
		end
		ToggleDropDownMenu(1, nil, GarrisonReportDropDown, self, 0, 0)
	elseif button == "LeftButton" then
		if GarrisonOrderHallReportGarrison == nil then
			if UnitLevel("PLAYER") >= 60 then
				ToggleExpansionLandingPage()
			else
				GarrisonLandingPage_Toggle()
				GarrisonOrderHallReportFixFrame()
				SetupFollowerTab()
			end
		else
			if GarrisonOrderHallReportGarrison == "df" then
				if GarrisonLandingPage ~= nil then
					HideUIPanel(GarrisonLandingPage)
				end
				ToggleExpansionLandingPage()
			else
				if ExpansionLandingPage ~= nil then
					HideUIPanel(ExpansionLandingPage)
				end
				if GarrisonLandingPage ~= nil and GarrisonLandingPage:IsShown() then
					HideUIPanel(GarrisonLandingPage)
				else
					if (GarrisonOrderHallReportGarrison == 111 and GarrisonOrderHallReportCovenant > 0) or GarrisonOrderHallReportGarrison ~= 111 then
						if not not (C_Garrison.GetGarrisonInfo(GarrisonOrderHallReportGarrison)) then
							ShowGarrisonLandingPage(GarrisonOrderHallReportGarrison)
							GarrisonOrderHallReportFixFrame()
							SetupFollowerTab()
						end
					end
				end
			end
		end
	end
end)

function SetupFollowerTab()
	GarrisonLandingPage.FollowerTab:SetScript("OnShow", function(self)
		if GarrisonLandingPage.garrTypeID ~= 111 then
			GarrisonLandingPage.FollowerList:Show()
			GarrisonLandingPage.FollowerList.LandingPageHeader:SetText("Followers")
			self.CovenantFollowerPortraitFrame:Hide()
			self.autoSpellPool:ReleaseAll()
			self.AbilitiesFrame.Abilities[1]:Hide()
			self.AbilitiesFrame.Abilities[2]:Hide()
			self:ShowFollower(self.followerID)
		end
	end)
end

function GarrisonOrderHallReportFrameOnEvent(self, event, arg1)
	if event == "ADDON_LOADED" and arg1 == "GarrisonOrderHallReport" then
		if GarrisonOrderHallReportButton == nil then
			GarrisonOrderHallReportButton = "RightButton"
		end
	elseif event == "PLAYER_LOGIN" then
		GarrisonOrderHallReportCovenant = C_Covenants.GetActiveCovenantID()
		ExpansionLandingPageMinimapButton:RegisterForClicks("LeftButtonUp", "RightButtonUp", "MiddleButtonUp")
		ExpansionLandingPageMinimapButton:SetScript("OnEnter", function() end)
		GarrisonReportDropDown = CreateFrame("FRAME", "GarrisonReportDropDown", UIParent, "UIDropDownMenuTemplate")
		UIDropDownMenu_Initialize(GarrisonReportDropDown, GarrisonReportDropDownOnLoad, "MENU")
		self:UnregisterEvent("ADDON_LOADED")
	end
	local show = false
	local garrisons = { 2, 3, 9, 111 }
	for i = 1, table.getn(garrisons) do
		local available = not not (C_Garrison.GetGarrisonInfo(garrisons[i]))
		show = available or show
	end
	local available = C_PlayerInfo.IsExpansionLandingPageUnlockedForPlayer(9)
	show = available or show
	if show then
		ExpansionLandingPageMinimapButton:Show()
	end
end

function GarrisonReportDropDownOnLoad()
	local garrison = {}
	garrison.text = "Garrison"
	garrison.value = 2
	garrison.func = GarrisonReportDropDownOnClick
	local order = {}
	order.text = "Order Hall"
	order.value = 3
	order.func = GarrisonReportDropDownOnClick
	local missions = {}
	missions.text = "Missions"
	missions.value = 9
	missions.func = GarrisonReportDropDownOnClick
	local covenant = {}
	covenant.text = "Covenant Sanctum"
	covenant.value = 111
	covenant.func = GarrisonReportDropDownOnClick
	local dragon = {}
	dragon.text = "Dragon Isles"
	dragon.value = "df"
	dragon.func = GarrisonReportDropDownOnClick
	if not not (C_Garrison.GetGarrisonInfo(2)) then
		UIDropDownMenu_AddButton(garrison)
	end
	if not not (C_Garrison.GetGarrisonInfo(3)) then
		UIDropDownMenu_AddButton(order)
	end
	if not not (C_Garrison.GetGarrisonInfo(9)) then
		UIDropDownMenu_AddButton(missions)
	end
	if GarrisonOrderHallReportCovenant ~= nil and GarrisonOrderHallReportCovenant > 0 then
		UIDropDownMenu_AddButton(covenant)
	end
	if C_PlayerInfo.IsExpansionLandingPageUnlockedForPlayer(9) then
		UIDropDownMenu_AddButton(dragon)
	end
end

function GarrisonReportDropDownOnClick(value)
	if value.value == 111 and GarrisonOrderHallReportCovenant == 0 then
		return
	end
	if value.value == "df" then
		ToggleExpansionLandingPage()
	else
		ShowGarrisonLandingPage(value.value)
		GarrisonOrderHallReportFixFrame()
		SetupFollowerTab()
	end
end

function GarrisonOrderHallReportRadioButtonClick(self)
	for i = 1, table.getn(GarrisonOrderHallReportButtons) do
		GarrisonOrderHallReportButtons[i]:SetChecked(false)
	end
	self:SetChecked(true)
end

function GarrisonOrderHallReportRadioGarrisonClick(self)
	for i = 1, table.getn(GarrisonOrderHallReportGarrisons) do
		GarrisonOrderHallReportGarrisons[i]:SetChecked(false)
	end
	self:SetChecked(true)
end

function GarrisonOrderHallReportRadioButton(text, parent, x, y)
	local button = CreateFrame("CheckButton", nil, parent, "UIRadioButtonTemplate")
	local font = button:CreateFontString(nil, nil, "GameFontNormal")
	font:SetText(text)
	font:SetPoint("LEFT", x, 0)
	button:SetFontString(font)
	button:SetPoint("TOPLEFT", x, y)
	button:Show()
	button:SetScript("OnClick", GarrisonOrderHallReportRadioButtonClick)
	table.insert(GarrisonOrderHallReportButtons, button)
end

function GarrisonOrderHallReportRadioGarrison(text, parent, x, y)
	local button = CreateFrame("CheckButton", nil, parent, "UIRadioButtonTemplate")
	local font = button:CreateFontString(nil, nil, "GameFontNormal")
	font:SetText(text)
	font:SetPoint("LEFT", x, 0)
	button:SetFontString(font)
	button:SetPoint("TOPLEFT", x, y)
	button:Show()
	button:SetScript("OnClick", GarrisonOrderHallReportRadioGarrisonClick)
	table.insert(GarrisonOrderHallReportGarrisons, button)
end

function GarrisonOrderHallReportOptionsRefresh()
	if GarrisonOrderHallReportButton == "RightButton" then
		GarrisonOrderHallReportButtons[1]:SetChecked(true)
		GarrisonOrderHallReportButtons[2]:SetChecked(false)
	else
		GarrisonOrderHallReportButtons[1]:SetChecked(false)
		GarrisonOrderHallReportButtons[2]:SetChecked(true)
	end
	if GarrisonOrderHallReportGarrison == 2 then
		GarrisonOrderHallReportGarrisons[1]:SetChecked(true)
		GarrisonOrderHallReportGarrisons[2]:SetChecked(false)
		GarrisonOrderHallReportGarrisons[3]:SetChecked(false)
		GarrisonOrderHallReportGarrisons[4]:SetChecked(false)
		GarrisonOrderHallReportGarrisons[5]:SetChecked(false)
	elseif GarrisonOrderHallReportGarrison == 3 then
		GarrisonOrderHallReportGarrisons[1]:SetChecked(false)
		GarrisonOrderHallReportGarrisons[2]:SetChecked(true)
		GarrisonOrderHallReportGarrisons[3]:SetChecked(false)
		GarrisonOrderHallReportGarrisons[4]:SetChecked(false)
		GarrisonOrderHallReportGarrisons[5]:SetChecked(false)
	elseif GarrisonOrderHallReportGarrison == 9 then
		GarrisonOrderHallReportGarrisons[1]:SetChecked(false)
		GarrisonOrderHallReportGarrisons[2]:SetChecked(false)
		GarrisonOrderHallReportGarrisons[3]:SetChecked(true)
		GarrisonOrderHallReportGarrisons[4]:SetChecked(false)
		GarrisonOrderHallReportGarrisons[5]:SetChecked(false)
	elseif GarrisonOrderHallReportGarrison == 111 then
		GarrisonOrderHallReportGarrisons[1]:SetChecked(false)
		GarrisonOrderHallReportGarrisons[2]:SetChecked(false)
		GarrisonOrderHallReportGarrisons[3]:SetChecked(false)
		GarrisonOrderHallReportGarrisons[4]:SetChecked(true)
		GarrisonOrderHallReportGarrisons[5]:SetChecked(false)
	elseif GarrisonOrderHallReportGarrison == "df" then
		GarrisonOrderHallReportGarrisons[1]:SetChecked(false)
		GarrisonOrderHallReportGarrisons[2]:SetChecked(false)
		GarrisonOrderHallReportGarrisons[3]:SetChecked(false)
		GarrisonOrderHallReportGarrisons[4]:SetChecked(false)
		GarrisonOrderHallReportGarrisons[5]:SetChecked(true)
	end
end

function GarrisonOrderHallReportOptionsOkay()
	if GarrisonOrderHallReportButtons[1]:GetChecked() then
		GarrisonOrderHallReportButton = "RightButton"
	else
		GarrisonOrderHallReportButton = "MiddleButton"
	end
	if GarrisonOrderHallReportGarrisons[1]:GetChecked() then
		GarrisonOrderHallReportGarrison = 2
	elseif GarrisonOrderHallReportGarrisons[2]:GetChecked() then
		GarrisonOrderHallReportGarrison = 3
	elseif GarrisonOrderHallReportGarrisons[3]:GetChecked() then
		GarrisonOrderHallReportGarrison = 9
	elseif GarrisonOrderHallReportGarrisons[4]:GetChecked() then
		GarrisonOrderHallReportGarrison = 111
	elseif GarrisonOrderHallReportGarrisons[5]:GetChecked() then
		GarrisonOrderHallReportGarrison = "df"
	end
end

local GarrisonOrderHallReportFrame = CreateFrame("FRAME", nil, UIParent)
GarrisonOrderHallReportFrame:RegisterEvent("ADDON_LOADED")
GarrisonOrderHallReportFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
GarrisonOrderHallReportFrame:RegisterEvent("PLAYER_UPDATE_RESTING")
GarrisonOrderHallReportFrame:RegisterEvent("ZONE_CHANGED")
GarrisonOrderHallReportFrame:RegisterEvent("ZONE_CHANGED_INDOORS")
GarrisonOrderHallReportFrame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
GarrisonOrderHallReportFrame:RegisterEvent("PLAYER_LOGIN")
GarrisonOrderHallReportFrame:SetScript("OnEvent", GarrisonOrderHallReportFrameOnEvent)

local GarrisonOrderHallReportOptions = CreateFrame("FRAME")
GarrisonOrderHallReportOptions.name = "Garrison Order Hall Report"
GarrisonOrderHallReportRadioButton("Right Mouse Button", GarrisonOrderHallReportOptions, 20, -20)
GarrisonOrderHallReportRadioButton("Middle Mouse Button", GarrisonOrderHallReportOptions, 20, -40)
GarrisonOrderHallReportRadioGarrison("Garrison", GarrisonOrderHallReportOptions, 20, -100)
GarrisonOrderHallReportRadioGarrison("Order Hall", GarrisonOrderHallReportOptions, 20, -120)
GarrisonOrderHallReportRadioGarrison("Missions", GarrisonOrderHallReportOptions, 20, -140)
GarrisonOrderHallReportRadioGarrison("Covenant Sanctum", GarrisonOrderHallReportOptions, 20, -160)
GarrisonOrderHallReportRadioGarrison("Dragon Isles", GarrisonOrderHallReportOptions, 20, -180)
GarrisonOrderHallReportOptions.refresh = GarrisonOrderHallReportOptionsRefresh
GarrisonOrderHallReportOptions.okay = GarrisonOrderHallReportOptionsOkay
GarrisonOrderHallReportOptions.cancel = GarrisonOrderHallReportOptionsRefresh
InterfaceOptions_AddCategory(GarrisonOrderHallReportOptions)