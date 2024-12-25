local GarrisonOrderHallReport = LibStub("AceAddon-3.0"):NewAddon("GarrisonOrderHallReport")

GarrisonOrderHallReport.Buttons = {}
GarrisonOrderHallReport.Garrisons = {}
GarrisonOrderHallReport.Covenant = 0
GarrisonOrderHallReport.Overlays = {}

function GarrisonOrderHallReport:FixFrame()
	if GarrisonLandingPage.garrTypeID == 111 then
		GarrisonLandingPage.Report.Sections:Show()
	elseif self.Covenant > 0 then
		GarrisonLandingPage.Report.Sections:Hide()
		GarrisonLandingPage.FollowerTabButton:SetText("Followers")
	end
end

ExpansionLandingPageMinimapButton:SetScript("OnClick", function(self, button, down)
	GarrisonOrderHallReport.Covenant = C_Covenants.GetActiveCovenantID()
	if button == GarrisonOrderHallReportButton then
		if GarrisonLandingPage ~= nil then
			HideUIPanel(GarrisonLandingPage)
		end
		if ExpansionLandingPage ~= nil then
			HideUIPanel(ExpansionLandingPage)
		end
		GarrisonOrderHallReport:ContextMenu(self)
	elseif button == "LeftButton" then
		if GarrisonOrderHallReportGarrison == nil then
			if C_PlayerInfo.IsExpansionLandingPageUnlockedForPlayer(9) or C_PlayerInfo.IsExpansionLandingPageUnlockedForPlayer(10) then
				ExpansionLandingPage:RefreshExpansionOverlay()
				ToggleExpansionLandingPage()
			else
				GarrisonLandingPage_Toggle()
				GarrisonOrderHallReport:FixFrame()
				GarrisonOrderHallReport:SetupFollowerTab()
			end
		else
			if not tonumber(GarrisonOrderHallReportGarrison) then
				if GarrisonLandingPage ~= nil then
					HideUIPanel(GarrisonLandingPage)
				end
				ToggleExpansionLandingPage()
				if ExpansionLandingPage.overlayFrame ~= nil then
					ExpansionLandingPage.overlayFrame:Hide();
					ExpansionLandingPage.overlay = GarrisonOrderHallReport.Overlays[GarrisonOrderHallReportGarrison]
					ExpansionLandingPage.overlayFrame = ExpansionLandingPage.overlay.CreateOverlay(ExpansionLandingPage.Overlay);
					ExpansionLandingPage.overlayFrame:Show();
				end
			else
				if ExpansionLandingPage ~= nil then
					HideUIPanel(ExpansionLandingPage)
				end
				if GarrisonLandingPage ~= nil and GarrisonLandingPage:IsShown() then
					HideUIPanel(GarrisonLandingPage)
				else
					if (GarrisonOrderHallReportGarrison == 111 and GarrisonOrderHallReport.Covenant > 0) or GarrisonOrderHallReportGarrison ~= 111 then
						if not not (C_Garrison.GetGarrisonInfo(GarrisonOrderHallReportGarrison)) then
							ShowGarrisonLandingPage(GarrisonOrderHallReportGarrison)
							GarrisonOrderHallReport:FixFrame()
							GarrisonOrderHallReport:SetupFollowerTab()
						end
					end
				end
			end
		end
	end
end)

function GarrisonOrderHallReport:SetupFollowerTab()
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

function GarrisonOrderHallReport:FrameOnEvent()
	local show = false
	local garrisons = { 2, 3, 9 }
	for i = 1, table.getn(garrisons) do
		local available = not not (C_Garrison.GetGarrisonInfo(garrisons[i]))
		show = available or show
	end
	if GarrisonOrderHallReport.Covenant ~= nil and GarrisonOrderHallReport.Covenant > 0 then
		show = true
	end
	local available = C_PlayerInfo.IsExpansionLandingPageUnlockedForPlayer(9) or C_PlayerInfo.IsExpansionLandingPageUnlockedForPlayer(10)
	show = available or show
	if show then
		ExpansionLandingPageMinimapButton:Show()
	end
	if GarrisonOrderHallReportGarrison ~= nil then
		GarrisonOrderHallReport:SetButtonLook()
	end
end

function GarrisonOrderHallReport:ContextMenu(parent)
	MenuUtil.CreateContextMenu(parent, function(owner, root)
		if not not (C_Garrison.GetGarrisonInfo(2)) then
			root:CreateButton("Garrison", function() self:ContextMenuClick(2) end)
		end
		if not not (C_Garrison.GetGarrisonInfo(3)) then
			root:CreateButton("Order Hall", function() self:ContextMenuClick(3) end)
		end
		if not not (C_Garrison.GetGarrisonInfo(9)) then
			root:CreateButton("Missions", function() self:ContextMenuClick(9) end)
		end
		if self.Covenant ~= nil and self.Covenant > 0 then
			root:CreateButton("Covenant Sanctum", function() self:ContextMenuClick(111) end)
		end
		if C_PlayerInfo.IsExpansionLandingPageUnlockedForPlayer(9) then
			root:CreateButton("Dragon Isles", function() self:ContextMenuClick("df") end)
		end
		if C_PlayerInfo.IsExpansionLandingPageUnlockedForPlayer(10) then
			root:CreateButton("Khaz Algar", function() self:ContextMenuClick("tww") end)
		end
	end)
end

function GarrisonOrderHallReport:ContextMenuClick(value)
	if value == 111 and self.Covenant == 0 then
		return
	end
	if tonumber(value) then
		ShowGarrisonLandingPage(value)
		self:FixFrame()
		self:SetupFollowerTab()
	else
		ToggleExpansionLandingPage()
		ExpansionLandingPage.overlayFrame:Hide();
		ExpansionLandingPage.overlay = self.Overlays[value]
		ExpansionLandingPage.overlayFrame = ExpansionLandingPage.overlay.CreateOverlay(ExpansionLandingPage.Overlay);
		ExpansionLandingPage.overlayFrame:Show();
	end
end

function GarrisonOrderHallReport:SetButtonLook()
	ExpansionLandingPageMinimapButton.garrisonType = GarrisonOrderHallReportGarrison
	self:ApplyAnchor(ExpansionLandingPageMinimapButton, GarrisonOrderHallReportGarrison)
	if (GarrisonOrderHallReportGarrison == 2) then
		local faction = UnitFactionGroup("player")
		self:IconFromAtlas(ExpansionLandingPageMinimapButton, self:WoDAtlas(faction))
		self.title = GARRISON_LANDING_PAGE_TITLE;
		self.description = MINIMAP_GARRISON_LANDING_PAGE_TOOLTIP;
	elseif (GarrisonOrderHallReportGarrison == 3) then
		local _, className = UnitClass("player");
		self:IconFromAtlas(ExpansionLandingPageMinimapButton, self:LegionAtlas(className))
		ExpansionLandingPageMinimapButton.title = ORDER_HALL_LANDING_PAGE_TITLE
		ExpansionLandingPageMinimapButton.description = MINIMAP_ORDER_HALL_LANDING_PAGE_TOOLTIP
	elseif (GarrisonOrderHallReportGarrison == 9) then
		local faction = UnitFactionGroup("player")
		self:IconFromAtlas(ExpansionLandingPageMinimapButton, self:BfaAtlas(faction))
		ExpansionLandingPageMinimapButton.title = GARRISON_TYPE_8_0_LANDING_PAGE_TITLE
		ExpansionLandingPageMinimapButton.description = GARRISON_TYPE_8_0_LANDING_PAGE_TOOLTIP
	elseif (GarrisonOrderHallReportGarrison == 111) then
		local covenantData = C_Covenants.GetCovenantData(C_Covenants.GetActiveCovenantID())
		if covenantData ~= nil then
			self:IconFromAtlas(ExpansionLandingPageMinimapButton, self:SlAtlas(covenantData));
			ExpansionLandingPageMinimapButton.title = GARRISON_TYPE_9_0_LANDING_PAGE_TITLE
			ExpansionLandingPageMinimapButton.description = GARRISON_TYPE_9_0_LANDING_PAGE_TOOLTIP
		else
			self:IconFromAtlas(ExpansionLandingPageMinimapButton, self:TwwAtlas());
			ExpansionLandingPageMinimapButton.title = WARIWTHIN_LANDING_PAGE_TITLE
			ExpansionLandingPageMinimapButton.description = WARIWTHIN_LANDING_PAGE_TOOLTIP
		end
	elseif (GarrisonOrderHallReportGarrison == "df") then
		self:IconFromAtlas(ExpansionLandingPageMinimapButton, self:DfAtlas());
		ExpansionLandingPageMinimapButton.title = DRAGONFLIGHT_LANDING_PAGE_TITLE
		ExpansionLandingPageMinimapButton.description = DRAGONFLIGHT_LANDING_PAGE_TOOLTIP
	elseif (GarrisonOrderHallReportGarrison == "tww") then
		self:IconFromAtlas(ExpansionLandingPageMinimapButton, self:TwwAtlas());
		ExpansionLandingPageMinimapButton.title = WARIWTHIN_LANDING_PAGE_TITLE
		ExpansionLandingPageMinimapButton.description = WARIWTHIN_LANDING_PAGE_TOOLTIP
	end
end

function GarrisonOrderHallReport:WoDAtlas(faction)
	if faction == "Horde" then
		return "garrlanding-minimapIcon-horde-up", "garrLanding-minimapIcon-horde-down", "garrlanding-circleglow", "garrlanding-sidetoast-glow" 
	else
		return "garrlanding-minimapIcon-alliance-up", "garrLanding-minimapIcon-alliance-down", "garrlanding-circleglow", "garrlanding-sidetoast-glow"
	end
end

local garrisonType7_0AtlasFormats = {"legionmission-landingbutton-%s-up",
									 "legionmission-landingbutton-%s-down",
									 "garrlanding-circleglow",
									 "garrlanding-sidetoast-glow"};

function GarrisonOrderHallReport:LegionAtlas(className)
	if className == "EVOKER" then
		local faction = UnitFactionGroup("player")
		return self:WoDAtlas(faction)
	else
		local t = garrisonType7_0AtlasFormats
		return t[1]:format(className), t[2]:format(className), t[3], t[4]
	end
end

function GarrisonOrderHallReport:BfaAtlas(faction)
	if faction == "Horde" then
		return "bfa-landingbutton-horde-up", "bfa-landingbutton-horde-down", "bfa-landingbutton-horde-diamondhighlight", "bfa-landingbutton-horde-diamondglow"
	else
		return "bfa-landingbutton-alliance-up", "bfa-landingbutton-alliance-down", "bfa-landingbutton-alliance-shieldhighlight", "bfa-landingbutton-alliance-shieldglow"
	end
end

local garrisonTypeAnchors = {
	["default"] = AnchorUtil.CreateAnchor("TOPLEFT", "MinimapBackdrop", "TOPLEFT", 5, -162),
	[111] = AnchorUtil.CreateAnchor("TOPLEFT", "MinimapBackdrop", "TOPLEFT", -3, -150),
	["df"] = AnchorUtil.CreateAnchor("TOPLEFT", "MinimapBackdrop", "TOPLEFT", -3, -150),
	["tww"] = AnchorUtil.CreateAnchor("TOPLEFT", "MinimapBackdrop", "TOPLEFT", 12, -152)
}

function GarrisonOrderHallReport:GetAnchor(garrisonType)
	return garrisonTypeAnchors[garrisonType or "default"] or garrisonTypeAnchors["default"];
end

function GarrisonOrderHallReport:ApplyAnchor(self, garrisonType)
	if C_AddOns.IsAddOnLoaded("SexyMap") then
		ExpansionLandingPageMinimapButton:SetSize(36, 36)
	elseif garrisonType ~= nil then
		local anchor = GarrisonOrderHallReport:GetAnchor(garrisonType);
		local clearAllPoints = true
		anchor:SetPoint(self, clearAllPoints)
	end
end

local garrisonType9_0AtlasFormats = {"shadowlands-landingbutton-%s-up",
									 "shadowlands-landingbutton-%s-down",
									 "shadowlands-landingbutton-%s-highlight",
									 "shadowlands-landingbutton-%s-glow"};

function GarrisonOrderHallReport:SlAtlas(covenantData)
	local kit = covenantData and covenantData.textureKit or "kyrian"
	if kit then
		local t = garrisonType9_0AtlasFormats
		return t[1]:format(kit), t[2]:format(kit), t[3]:format(kit), t[4]:format(kit)
	end
end

function GarrisonOrderHallReport:DfAtlas()
	return "dragonflight-landingbutton-up", "dragonflight-landingbutton-down", "dragonflight-landingbutton-circlehighlight", "dragonflight-landingbutton-circleglow", true
end

function GarrisonOrderHallReport:TwwAtlas()
	return "warwithin-landingbutton-up", "warwithin-landingbutton-down", "warwithin-landingbutton-circlehighlight", "warwithin-landingbutton-circleglow", true
end

function GarrisonOrderHallReport:IconFromAtlas(self, up, down, highlight, glow, useDefaultButtonSize)
	local width, height
	if useDefaultButtonSize then
		width = self.defaultWidth
		height = self.defaultHeight
		self.LoopingGlow:SetSize(self.defaultGlowWidth, self.defaultGlowHeight)
	else
		local info = C_Texture.GetAtlasInfo(up)
		width = info and info.width or 0
		height = info and info.height or 0
	end
	self:SetSize(width, height)
	local useAtlasSize = not useDefaultButtonSize
	self:GetNormalTexture():SetAtlas(up, useAtlasSize)
	self:GetPushedTexture():SetAtlas(down, useAtlasSize)
	self:GetHighlightTexture():SetAtlas(highlight, useAtlasSize)
	self.LoopingGlow:SetAtlas(glow, useAtlasSize)
end

function GarrisonOrderHallReport:OnInitialize()
	self.frame = CreateFrame("FRAME", nil, UIParent)
	self.frame:RegisterEvent("PLAYER_ENTERING_WORLD")
	self.frame:RegisterEvent("PLAYER_UPDATE_RESTING")
	self.frame:RegisterEvent("ZONE_CHANGED")
	self.frame:RegisterEvent("ZONE_CHANGED_INDOORS")
	self.frame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
	self.frame:RegisterEvent("PLAYER_LOGIN")
	self.frame:SetScript("OnEvent", self.FrameOnEvent)
	if GarrisonOrderHallReportButton == nil then
		GarrisonOrderHallReportButton = "RightButton"
	end
	self.Covenant = C_Covenants.GetActiveCovenantID()
	ExpansionLandingPageMinimapButton:RegisterForClicks("LeftButtonUp", "RightButtonUp", "MiddleButtonUp")
	ExpansionLandingPageMinimapButton:SetScript("OnEnter", function() end)
	local show = false
	local garrisons = { 2, 3, 9, 111 }
	for i = 1, table.getn(garrisons) do
		local available = not not (C_Garrison.GetGarrisonInfo(garrisons[i]))
		show = available or show
	end
	local available = C_PlayerInfo.IsExpansionLandingPageUnlockedForPlayer(9) or C_PlayerInfo.IsExpansionLandingPageUnlockedForPlayer(10)
	show = available or show
	if show then
		ExpansionLandingPageMinimapButton:Show()
	end
	GarrisonOrderHallReport.Overlays = {
		["df"] = CreateFromMixins(DragonflightLandingOverlayMixin),
		["tww"] = CreateFromMixins(WarWithinLandingOverlayMixin)
	}
	local options = {
		name = "Garrison Order Hall Report",
		handler = GarrisonOrderHallReport,
		type = "group",
		args = {
			button = {
				name = "Mouse Button",
				type = "select",
				desc = "select mouse button that opens dropdown menu",
				values = {
					["RightButton"] = "Right Mouse Button",
					["MiddleButton"] = "Middle Mouse Button"
				},
				set = "SetButton",
				get = "GetButton",
				style = "radio"
			},
			garrison = {
				name = "Report Type",
				type = "select",
				desc = "select report type that will be available as your default under left mouse button. Choosing Default option requires reload or changing area to load button look.",
				values = {
					[1] = "Default",
					[2] = "Garrison",
					[3] = "Order Hall",
					[9] = "Missions",
					[111] = "Covenant Sanctum",
					["df"] = "Dragon Isles",
					["tww"] = "Khaz Algar",
				},
				set = "SetGarrison",
				get = "GetGarrison",
				style = "radio"
			}
		}
	}
	LibStub("AceConfig-3.0"):RegisterOptionsTable("GarrisonOrderHallReport", options, nil)
	LibStub("AceConfigDialog-3.0"):AddToBlizOptions("GarrisonOrderHallReport", "Garrison Order Hall Report")
end

function GarrisonOrderHallReport:SetButton(info, val)
	GarrisonOrderHallReportButton = val
end

function GarrisonOrderHallReport:GetButton(info)
	return GarrisonOrderHallReportButton
end

function GarrisonOrderHallReport:SetGarrison(info, val)
	if val == 1 then
		GarrisonOrderHallReportGarrison = nil
	else
		GarrisonOrderHallReportGarrison = val
	end
	self:SetButtonLook()
end

function GarrisonOrderHallReport:GetGarrison(info)
	if GarrisonOrderHallReportGarrison == nil then
		return 1
	end
	return GarrisonOrderHallReportGarrison
end
