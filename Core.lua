local msg_chat_welcome_intro = "|cffc3a8dbHello " .. UnitName("player") .. "! Welcome to the alpha version of|r |cff9a29ffW|r|cff9c29ffy|r|cff9e2affr|r|cff9f2affm|r|cffa12affu|r|cffa32bff'|r|cffa52bffs|r|cffa72cff |r|cffa82cffF|r|cffaa2cffu|r|cffac2dffn|r|cffae2dffd|r|cffaf2dffa|r|cffb12effm|r|cffb32effe|r|cffb52fffn|r|cffb72ffft|r|cffb82fffa|r|cffba30ffl|r|cffbc30ffs|r|cffc3a8db!|r"
local msg_chat_welcome_version = "|cffc3a8dbCurrent revision is 0.4-alpha. For latest updates, contact Wyrmu (US-Aggramar)!|r"

-- Default values

local currentTimer = 0 -- KILL Current Timer
local maxTimer = 3 -- KILL Max Timer
local currentTimer_Loot = 0 -- LOOT Current Timer
local maxTimer_Loot = 3 -- LOOT Max Timer
local currentCycle = "|cff505050IDLE|r"
local ticker = {}
local temp_int = 0
local text_prefix = "|cffffffff"
local startState = 1
local maxTimer_def = maxTimer
local maxTimer_Loot_def = maxTimer_Loot
local oBtn_clicked = false

---------------------------------------------------------

-- Popups! :D

StaticPopupDialogs["PLACEHOLDER"] = {
  text = "This is a placeholder.",
  button1 = "Wow, okay.",
  button2 = "I refuse to believe.",
  timeout = 0,
  whileDead = true,
  hideOnEscape = true,
  preferredIndex = 3,  -- avoid some UI taint, see http://www.wowace.com/announcements/how-to-avoid-some-ui-taint/
}

StaticPopupDialogs["INVALID"] = {
  text = "I'm afraid I can't do that.",
  button1 = "Okay.",
  button2 = "Okaaaaay.",
  timeout = 0,
  whileDead = true,
  hideOnEscape = true,
  preferredIndex = 3,  -- avoid some UI taint, see http://www.wowace.com/announcements/how-to-avoid-some-ui-taint/
}

-- Main stuffs

local frame = CreateFrame("Frame", "DragFrame2", UIParent)
frame:SetMovable(true)
frame:EnableMouse(true)
frame:RegisterForDrag("LeftButton")
frame:SetScript("OnDragStart", frame.StartMoving)
frame:SetScript("OnDragStop", frame.StopMovingOrSizing)

-- Initialization 

print(msg_chat_welcome_intro)
print(msg_chat_welcome_version)
local lolscammed = C_Timer.NewTicker(1, function() 
	temp_int =temp_int + 1
	if (temp_int < 4) then
		print("|cfffffb00A buyer has been found for your auction of Vial of the Sands.|r")
	else
		print("|cfffffb00Just kidding. None of them sold.|r")
	end
 end, 4)

-- UIConfig

local UIConfig = CreateFrame("Frame", "WT_MainFrame", UIParent, "BasicFrameTemplateWithInset");
UIConfig:SetSize(300, 140);
UIConfig:SetPoint("CENTER", UIParent, "CENTER");
UIConfig:SetMovable(true)
UIConfig:EnableMouse(true)
UIConfig:RegisterForDrag("LeftButton")
UIConfig:SetScript("OnDragStart", frame.StartMoving)
UIConfig:SetScript("OnDragStop", frame.StopMovingOrSizing)
UIConfig:SetClampedToScreen(true)


-- Child Frames

UIConfig.title = UIConfig:CreateFontString(nil, "OVERLAY")
UIConfig.title:SetFontObject("GameFontHighlight")
UIConfig.title:SetPoint("LEFT", UIConfig.TitleBg, "LEFT", 5, 0)
UIConfig.title:SetText("|cff9a29ffW|r|cff9c29ffy|r|cff9e2affr|r|cff9f2affm|r|cffa12affu|r|cffa32bff'|r|cffa52bffs|r|cffa72cff |r|cffa82cffF|r|cffaa2cffu|r|cffac2dffn|r|cffae2dffd|r|cffaf2dffa|r|cffb12effm|r|cffb32effe|r|cffb52fffn|r|cffb72ffft|r|cffb82fffa|r|cffba30ffl|r|cffbc30ffs|r |cffc3a8dbv0.3-alpha|r")

UIConfig.timertext = UIConfig:CreateFontString(nil, "OVERLAY")
UIConfig.timertext:SetFontObject("GameFontNormalLarge")
UIConfig.timertext:SetPoint("LEFT", UIConfig.TitleBg, "LEFT", 50, -60)
UIConfig.timertext:SetText("|cff505050Timer: " .. currentTimer .. "s" .. " / " .. maxTimer .. "s" .. " -- |r" .. currentCycle)

UIConfig.timertextKill_Options = UIConfig:CreateFontString(nil, "OVERLAY")
UIConfig.timertextKill_Options:SetFontObject("GameFontNormalLarge")
UIConfig.timertextKill_Options:SetPoint("LEFT", UIConfig.TitleBg, "LEFT", 85, -100)
UIConfig.timertextKill_Options:SetText("|cff00ff00KILL:|r |cffffffff       " .. maxTimer .. "s|r")
UIConfig.timertextKill_Options:Hide()

UIConfig.timertextLoot_Options = UIConfig:CreateFontString(nil, "OVERLAY")
UIConfig.timertextLoot_Options:SetFontObject("GameFontNormalLarge")
UIConfig.timertextLoot_Options:SetPoint("LEFT", UIConfig.TitleBg, "LEFT", 85, -120)
UIConfig.timertextLoot_Options:SetText("LOOT: |cffffffff     " .. maxTimer_Loot .. "s|r")
UIConfig.timertextLoot_Options:Hide()

-- Buttons

function CreateButton(point, relativeFrame, relativePoint, xOffset, yOffset, xSize, ySize, text)
	local btn = CreateFrame("Button", nil, UIConfig, "GameMenuButtonTemplate");
	btn:SetPoint(point, relativeFrame, relativePoint, xOffset, yOffset)
	btn:SetSize(xSize, ySize)
	btn:SetText(text)
	btn:SetNormalFontObject("GameFontNormalLarge")
	btn:SetHighlightFontObject("GameFontHighlightLarge")
	return btn
end

-- TOP MENU ----------------------------------

UIConfig.oBtn = CreateButton("LEFT", UIConfig.TitleBg, "LEFT", 4, -27, 25, 25, "O");
UIConfig.oBtn:SetNormalFontObject("GameFontNormalSmall")
UIConfig.oBtn:SetHighlightFontObject("GameFontHighlightSmall")
UIConfig.oBtn:SetScript("OnClick", function (self, button, down)
	if (oBtn_clicked == false) then
		maxTimer_def = maxTimer
		maxTimer_Loot_def = maxTimer_Loot
		oBtn_clicked = true
		UIConfig:SetSize(300, 220)
		UIConfig.timertextKill_Options:Show()
		UIConfig.timertextLoot_Options:Show()
		UIConfig.killDecBtn:Show()
		UIConfig.killIncBtn:Show()	
		UIConfig.lootDecBtn:Show()
		UIConfig.lootIncBtn:Show()
		UIConfig.saveBtn:Show()
		UIConfig.startBtn:Hide()
	else
		oBtn_clicked = false
		UIConfig:SetSize(300, 140)
		UIConfig.timertextKill_Options:Hide()
		UIConfig.timertextLoot_Options:Hide()
		UIConfig.killDecBtn:Hide()
		UIConfig.killIncBtn:Hide()	
		UIConfig.lootDecBtn:Hide()
		UIConfig.lootIncBtn:Hide()
		UIConfig.saveBtn:Hide()
		UIConfig.startBtn:Show()
	end
end);

UIConfig.hBtn = CreateButton("LEFT", UIConfig.TitleBg, "LEFT", 29, -27, 25, 25, "?");
UIConfig.hBtn:SetNormalFontObject("GameFontNormalSmall")
UIConfig.hBtn:SetHighlightFontObject("GameFontHighlightSmall")
UIConfig.hBtn:SetScript("OnClick", function (self, button, down)
	StaticPopup_Show ("PLACEHOLDER")
end);

UIConfig.qBtn = CreateButton("LEFT", UIConfig.TitleBg, "LEFT", 54, -27, 25, 25, "Q");
UIConfig.qBtn:SetNormalFontObject("GameFontNormalSmall")
UIConfig.qBtn:SetHighlightFontObject("GameFontHighlightSmall")
UIConfig.qBtn:SetScript("OnClick", function (self, button, down)
	StaticPopup_Show ("PLACEHOLDER")
end);

----------------------------------------------

UIConfig.startBtn = CreateButton("BOTTOM", UIConfig, "BOTTOM", 0, 10, 200, 40, "Load");
UIConfig.startBtn:SetScript("OnClick", function (self, button, down)
	if (startState == 1) then
		print("|cffc3a8db[WF] Loading...|r")
		SendChatMessage("[WF] Loaded Wyrmu's Timers v0.3-alpha", "Party", "Orcish");
		SendChatMessage("[WF] KILL timer: " .. maxTimer .. "s", "Party", "Orcish");
		SendChatMessage("[WF] LOOT timer: " .. maxTimer_Loot .. "s", "Party", "Orcish");
		SendChatMessage("[WF] Have fun!", "Party", "Orcish");
		UIConfig.timertext:SetText("|cffffffffTimer: " .. currentTimer .. "s" .. " / " .. maxTimer .. "s" .. " -- |r" .. currentCycle)
		UIConfig.startBtn:SetText("Start: Check")
	end
	if (startState == 2) then
		print("|cffc3a8db[WF] RESET!|r")
		SendChatMessage("[WF] ---- RESET ----", "Party", "Orcish");
		SendChatMessage("[WF] ---- RESET ----", "Party", "Orcish");
		SendChatMessage("[WF] ---- RESET ----", "Party", "Orcish");
		UIConfig.startBtn:SetText("Start: KILL")
		DoReadyCheck()
	end
	if (startState == 3) then
		ticker = C_Timer.NewTicker(1, function() 
			UIConfig.timertext:SetText("|cffffffffTimer: " .. currentTimer .. "s" .. " / " .. maxTimer .. "s" .. " -- |r" .. currentCycle)
			currentTimer = currentTimer + 1
			if (currentTimer == maxTimer + 1) then
				currentTimer = currentTimer - 1 -- Idk I'm bad at math.
				print("|cffc3a8db[WF] LOOT!|r")			
				tickerLoot = C_Timer.NewTicker(1, function() 
					UIConfig.timertext:SetText("|cffffffffTimer: " .. currentTimer_Loot .. "s" .. " / " .. maxTimer_Loot .. "s" .. " -- |r" .. currentCycle)
					currentTimer_Loot = currentTimer_Loot + 1
						if (currentTimer_Loot == maxTimer_Loot + 1) then
							currentTimer_Loot = currentTimer_Loot - 1 -- Similarly.
							if(currentCycle == "LOOT") then
								currentCycle = "|cff00ffffRESET|r"
							else
								currentCycle = "LOOT"
							end
							UIConfig.timertext:SetText("|cffffffffTimer:|r |cff00ff00" .. currentTimer_Loot .. "s|r" .. "|cffffffff / |r|cff00ff00" .. maxTimer_Loot .. "s|r" .. " -- |r" .. currentCycle)
							UIConfig.startBtn:SetText("Reset")
							currentTimer_Loot = 0	
						end
					end, maxTimer_Loot + 1)
				SendChatMessage("[WF] ---- LOOT ----", "Party", "Orcish");
				SendChatMessage("[WF] ---- LOOT ----", "Party", "Orcish");
				SendChatMessage("[WF] ---- LOOT ----", "Party", "Orcish");
				SendChatMessage("[WF] Timer: " .. maxTimer_Loot, "Party", "Orcish");
				if(currentCycle == "LOOT") then
					currentCycle = "|cff00ffffRESET|r"
				else
					currentCycle = "LOOT"
				end
				UIConfig.timertext:SetText("|cffffffffTimer:|r |cff00ff00" .. currentTimer_Loot .. "s|r" .. "|cffffffff / |r|cff00ff00" .. maxTimer .. "s|r" .. " -- |r" .. currentCycle)
				currentTimer = 0	
			end
		end, maxTimer + 1)
		print("|cffc3a8db[WF] KILL!|r")	
		SendChatMessage("[WF] ---- KILL ----", "Party", "Orcish");
		SendChatMessage("[WF] ---- KILL ----", "Party", "Orcish");
		SendChatMessage("[WF] ---- KILL ----", "Party", "Orcish");
		SendChatMessage("[WF] Timer: " .. maxTimer, "Party", "Orcish");
		currentCycle = "|cff00ff00KILL|r"
		UIConfig.timertext:SetText("|cffffffffTimer:|r |cff00ff00" .. currentTimer .. "s|r" .. "|cffffffff / |r|cff00ff00" .. maxTimer .. "s|r" .. " -- |r" .. currentCycle)
		UIConfig.startBtn:SetText("Force Reset")
	end
	if (startState == 4) then
		print("|cffc3a8db[WF] RESET!|r")
		currentCycle = "|cff00ffffRESET|r"
		startState = startState - 2
		ticker:Cancel()
		currentTimer = 0
		UIConfig.timertext:SetText("|cffffffffTimer:|r |cff00ff00" .. currentTimer .. "s|r" .. "|cffffffff / |r|cff00ff00" .. maxTimer .. "s|r" .. " -- |r" .. currentCycle)
		SendChatMessage("[WF] ---- RESET ----", "Party", "Orcish");
		SendChatMessage("[WF] ---- RESET ----", "Party", "Orcish");
		SendChatMessage("[WF] ---- RESET ----", "Party", "Orcish");
		UIConfig.startBtn:SetText("Start: KILL")
		DoReadyCheck()
	end
	--if (startState > 4 and startState < 10) then
	--	print("|cffc3a8db[WF] Whelp, you've encountered a bug. Probably because of my terribad programming skills plus this mess of uncategorized hellhole is a swamp to deal with. Anyways, startState is listed at more than 10 (max of 1-4 and 10). I've reset it to 0 which is the Load state. Hopefully it works this time.|r")
	--	startState = 0 -- Wow I'm actually doing self-aware debugs? Blizzard please hire me.
	--	UIConfig.startBtn:SetText("Load?")
	--end
	startState = startState + 1
end)

-- Save Button

UIConfig.saveBtn = CreateButton("BOTTOM", UIConfig, "BOTTOM", 0, 10, 200, 40, "Save");
UIConfig.saveBtn:SetScript("OnClick", function (self, button, down)
	if (maxTimer_def ~= maxTimer) then
		SendChatMessage("[WF] KILL Timer changed from " .. maxTimer .. " to " .. maxTimer_def, "Party", "Orcish");
		maxTimer = maxTimer_def
		UIConfig.timertext:SetText("|cffffffffTimer:|r |cff00ff00" .. currentTimer .. "s|r" .. "|cffffffff / |r|cff00ff00" .. maxTimer .. "s|r" .. " -- |r" .. currentCycle)
	end
	if (maxTimer_Loot ~= maxTimer_Loot_def) then
		SendChatMessage("[WF] LOOT Timer changed from " .. maxTimer_Loot .. " to " .. maxTimer_Loot_def, "Party", "Orcish");
		maxTimer_Loot = maxTimer_Loot_def
		UIConfig.timertext:SetText("|cffffffffTimer:|r |cff00ff00" .. currentTimer .. "s|r" .. "|cffffffff / |r|cff00ff00" .. maxTimer_Loot .. "s|r" .. " -- |r" .. currentCycle)
	end
	oBtn_clicked = false
	UIConfig:SetSize(300, 140)
	UIConfig.timertextKill_Options:Hide()
	UIConfig.timertextLoot_Options:Hide()
	UIConfig.killDecBtn:Hide()
	UIConfig.killIncBtn:Hide()	
	UIConfig.lootDecBtn:Hide()
	UIConfig.lootIncBtn:Hide()
	UIConfig.saveBtn:Hide()
	UIConfig.startBtn:Show()
end)
UIConfig.saveBtn:Hide()
UIConfig.saveBtn:SetEnabled(false)

-- Increase/Decrease Buttons

UIConfig.killDecBtn = CreateButton("LEFT", UIConfig.TitleBg, "LEFT", 140, -100, 22, 22, "-");
UIConfig.killDecBtn:SetNormalFontObject("GameFontNormalSmall")
UIConfig.killDecBtn:SetHighlightFontObject("GameFontHighlightSmall")
UIConfig.killDecBtn:SetScript("OnClick", function (self, button, down)
	if (maxTimer_def > 3) then
		maxTimer_def = maxTimer_def - 3
		UIConfig.timertextKill_Options:SetText("|cff00ff00KILL:|r |cffffffff       " .. maxTimer_def .. "s|r")
	else
		StaticPopup_Show ("INVALID")
	end
	if (maxTimer_def ~= maxTimer) then
		UIConfig.saveBtn:SetEnabled(true)
	else
		UIConfig.saveBtn:SetEnabled(false)
	end
end);
UIConfig.killDecBtn:Hide()

UIConfig.killIncBtn = CreateButton("LEFT", UIConfig.TitleBg, "LEFT", 205, -100, 22, 22, "+");
UIConfig.killIncBtn:SetNormalFontObject("GameFontNormalSmall")
UIConfig.killIncBtn:SetHighlightFontObject("GameFontHighlightSmall")
UIConfig.killIncBtn:SetScript("OnClick", function (self, button, down)
	maxTimer_def = maxTimer_def + 3
	UIConfig.timertextKill_Options:SetText("|cff00ff00KILL:|r |cffffffff       " .. maxTimer_def .. "s|r")
	if (maxTimer_def ~= maxTimer) then
		UIConfig.saveBtn:SetEnabled(true)
	else
		UIConfig.saveBtn:SetEnabled(false)
	end
end);
UIConfig.killIncBtn:Hide()

UIConfig.lootDecBtn = CreateButton("LEFT", UIConfig.TitleBg, "LEFT", 140, -120, 22, 22, "-");
UIConfig.lootDecBtn:SetNormalFontObject("GameFontNormalSmall")
UIConfig.lootDecBtn:SetHighlightFontObject("GameFontHighlightSmall")
UIConfig.lootDecBtn:SetScript("OnClick", function (self, button, down)
	if (maxTimer_Loot_def > 3) then
		maxTimer_Loot_def = maxTimer_Loot_def - 3
		UIConfig.timertextLoot_Options:SetText("LOOT: |cffffffff     " .. maxTimer_Loot_def .. "s|r")
	else
		StaticPopup_Show ("INVALID")
	end
	if (maxTimer_Loot_def ~= maxTimer_Loot) then
		UIConfig.saveBtn:SetEnabled(true)
	else
		UIConfig.saveBtn:SetEnabled(false)
	end
end);
UIConfig.lootDecBtn:Hide()

UIConfig.lootIncBtn = CreateButton("LEFT", UIConfig.TitleBg, "LEFT", 205, -120, 22, 22, "+");
UIConfig.lootIncBtn:SetNormalFontObject("GameFontNormalSmall")
UIConfig.lootIncBtn:SetHighlightFontObject("GameFontHighlightSmall")
UIConfig.lootIncBtn:SetScript("OnClick", function (self, button, down)
	maxTimer_Loot_def = maxTimer_Loot_def + 3
	UIConfig.timertextLoot_Options:SetText("LOOT: |cffffffff     " .. maxTimer_Loot_def .. "s|r")
	if (maxTimer_Loot_def ~= maxTimer_Loot) then
		UIConfig.saveBtn:SetEnabled(true)
	else
		UIConfig.saveBtn:SetEnabled(false)
	end
end);
UIConfig.lootIncBtn:Hide()