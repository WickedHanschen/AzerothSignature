local ADDON_NAME = ...

------------------------------------------------------------
-- Constants
------------------------------------------------------------

local DEFAULT_PREFIX = "<MyMain> "
local ACCENT = { 0.84, 0.69, 0.36 }          -- gold
local WHITE8X8 = "Interface\\Buttons\\WHITE8X8"
local MAX_MESSAGE_BYTES = 255

local CHANNELS = {
    { key = "SAY",           label = "Say (/say)" },
    { key = "YELL",          label = "Yell (/yell)" },
    { key = "PARTY",         label = "Party (/party)" },
    { key = "RAID",          label = "Raid (/raid)" },
    { key = "INSTANCE_CHAT", label = "Instance Chat" },
    { key = "GUILD",         label = "Guild (/guild)" },
    { key = "OFFICER",       label = "Officer (/officer)" },
    { key = "WHISPER",       label = "Whisper (/whisper)" },
    { key = "CHANNEL",       label = "Custom channels (/1, /2...)" },
}

local DEFAULTS = {
    prefix = DEFAULT_PREFIX,
    enabled = true,
    excludedCharacter = "",
}

local settingsCategory

------------------------------------------------------------
-- Helpers
------------------------------------------------------------

local function PrintMessage(message)
    if DEFAULT_CHAT_FRAME then
        DEFAULT_CHAT_FRAME:AddMessage(
            "|cffd5b15bAzeroth Signature:|r " .. tostring(message)
        )
    end
end

local function Trim(text)
    return (tostring(text or ""):match("^%s*(.-)%s*$"))
end

------------------------------------------------------------
-- Saved variables
------------------------------------------------------------

local function MigrateLegacySettings()
    local oldDB = Name2ChatSafeDB
    if type(oldDB) ~= "table" then
        return
    end

    for _, key in ipairs({ "prefix", "enabled", "excludedCharacter" }) do
        if AzerothSignatureDB[key] == nil and oldDB[key] ~= nil then
            AzerothSignatureDB[key] = oldDB[key]
        end
    end

    if type(oldDB.channels) == "table" then
        AzerothSignatureDB.channels = AzerothSignatureDB.channels or {}
        for key, value in pairs(oldDB.channels) do
            if AzerothSignatureDB.channels[key] == nil then
                AzerothSignatureDB.channels[key] = value
            end
        end
    end
end

local function Initialize()
    AzerothSignatureDB = AzerothSignatureDB or {}
    MigrateLegacySettings()

    for key, value in pairs(DEFAULTS) do
        if AzerothSignatureDB[key] == nil then
            AzerothSignatureDB[key] = value
        end
    end

    if type(AzerothSignatureDB.channels) ~= "table" then
        AzerothSignatureDB.channels = {}
    end

    for _, channel in ipairs(CHANNELS) do
        if AzerothSignatureDB.channels[channel.key] == nil then
            AzerothSignatureDB.channels[channel.key] = true
        end
    end
end

------------------------------------------------------------
-- Core logic
------------------------------------------------------------

local function IsCharacterExcluded()
    local playerName = UnitName("player")
    if not playerName then
        return false
    end
    playerName = playerName:lower()

    for name in (AzerothSignatureDB.excludedCharacter or ""):gmatch("[^,]+") do
        if Trim(name):lower() == playerName then
            return true
        end
    end

    return false
end

local function GetChatType(editBox)
    local chatType

    pcall(function()
        chatType = editBox:GetAttribute("chatType")
    end)

    if not chatType then
        pcall(function()
            chatType = editBox.chatType
        end)
    end

    return chatType
end

local function OnPreSendText(_, editBox)
    local db = AzerothSignatureDB
    if not db or not db.enabled then
        return
    end

    -- Never modify outgoing chat text during combat (Retail restrictions).
    if InCombatLockdown and InCombatLockdown() then
        return
    end

    if IsCharacterExcluded() then
        return
    end

    -- Fall back to the active edit box if the callback didn't provide one.
    if type(editBox) ~= "table" and type(editBox) ~= "userdata" then
        editBox = nil
    end
    if not editBox or type(editBox.GetText) ~= "function" then
        editBox = ChatEdit_GetActiveWindow and ChatEdit_GetActiveWindow()
    end
    if not editBox or type(editBox.GetText) ~= "function" then
        return
    end

    local chatType = GetChatType(editBox)
    if not chatType then
        return
    end

    local channels = db.channels or {}
    local enabled = channels[chatType]

    -- /raid inside an instance group is reported as INSTANCE_CHAT.
    if chatType == "INSTANCE_CHAT" and channels.RAID then
        enabled = true
    end
    if not enabled then
        return
    end

    local prefix = db.prefix or DEFAULT_PREFIX
    if prefix == "" then
        return
    end

    local ok, text = pcall(editBox.GetText, editBox)
    if not ok or type(text) ~= "string" or text == "" then
        return
    end

    -- Don't break slash commands (e.g. /dance, /roll) or double-sign.
    if text:sub(1, 1) == "/" or text:sub(1, #prefix) == prefix then
        return
    end

    -- Chat messages are capped at 255 bytes; signing a long message would
    -- silently cut off its end, so leave it unsigned instead.
    if #prefix + #text > MAX_MESSAGE_BYTES then
        return
    end

    local success, err = pcall(editBox.SetText, editBox, prefix .. text)
    if not success then
        PrintMessage("Could not update chat text: " .. tostring(err))
    end
end

------------------------------------------------------------
-- GUI building blocks
------------------------------------------------------------

local function CreateCard(parent, titleText, height)
    local card = CreateFrame("Frame", nil, parent, "BackdropTemplate")
    card:SetHeight(height)
    card:SetBackdrop({
        bgFile = WHITE8X8,
        edgeFile = WHITE8X8,
        edgeSize = 1,
    })
    card:SetBackdropColor(0.06, 0.06, 0.08, 0.85)
    card:SetBackdropBorderColor(0.28, 0.24, 0.15, 1)

    card.title = card:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    card.title:SetPoint("TOPLEFT", 14, -11)
    card.title:SetText(titleText)
    card.title:SetTextColor(unpack(ACCENT))

    local line = card:CreateTexture(nil, "ARTWORK")
    line:SetColorTexture(ACCENT[1], ACCENT[2], ACCENT[3], 0.35)
    line:SetHeight(1)
    line:SetPoint("TOPLEFT", 14, -30)
    line:SetPoint("TOPRIGHT", -14, -30)

    return card
end

local function CreateCheckbox(parent, label)
    local check = CreateFrame("CheckButton", nil, parent, "UICheckButtonTemplate")
    check:SetSize(26, 26)

    check.label = parent:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    check.label:SetPoint("LEFT", check, "RIGHT", 2, 1)
    check.label:SetText(label)

    check:SetHitRectInsets(0, -(check.label:GetStringWidth() + 6), 0, 0)
    return check
end

local function CreateInput(parent, width)
    local input = CreateFrame("EditBox", nil, parent, "InputBoxTemplate")
    input:SetSize(width, 22)
    input:SetAutoFocus(false)
    input:SetScript("OnEscapePressed", input.ClearFocus)
    input:SetScript("OnEnterPressed", input.ClearFocus)
    return input
end

------------------------------------------------------------
-- Options panel
------------------------------------------------------------

local function CreateOptions()
    local panel = CreateFrame("Frame")
    panel.name = "Azeroth Signature"

    -- Header ------------------------------------------------
    local title = panel:CreateFontString(nil, "ARTWORK", "GameFontNormalHuge")
    title:SetPoint("TOPLEFT", 16, -16)
    title:SetText("Azeroth Signature")
    title:SetTextColor(unpack(ACCENT))

    local subtitle = panel:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
    subtitle:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -6)
    subtitle:SetTextColor(0.7, 0.7, 0.7)
    subtitle:SetText("Automatically sign your messages with a custom prefix.")

    -- Card 1: Signature -------------------------------------
    local sigCard = CreateCard(panel, "Signature", 124)
    sigCard:SetPoint("TOPLEFT", 16, -68)
    sigCard:SetPoint("TOPRIGHT", -16, -68)

    local enabled = CreateCheckbox(sigCard, "Enable automatic signature")
    enabled:SetPoint("TOPLEFT", 10, -36)

    local prefixLabel = sigCard:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    prefixLabel:SetPoint("TOPLEFT", 16, -72)
    prefixLabel:SetText("Signature / prefix")

    local prefixInput = CreateInput(sigCard, 220)
    prefixInput:SetPoint("TOPLEFT", prefixLabel, "BOTTOMLEFT", 6, -4)
    prefixInput:SetMaxLetters(100)

    local previewLabel = sigCard:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    previewLabel:SetPoint("TOPLEFT", prefixLabel, "TOPLEFT", 270, 0)
    previewLabel:SetText("Preview")

    local preview = sigCard:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    preview:SetPoint("LEFT", prefixInput, "LEFT", 276, 0)
    preview:SetPoint("RIGHT", sigCard, "RIGHT", -14, 0)
    preview:SetJustifyH("LEFT")

    local function UpdatePreview()
        local p = Trim(prefixInput:GetText())
        if p == "" then
            preview:SetText("|cff888888(no signature)|r")
        else
            preview:SetText(p .. " Hello, Azeroth!")
        end
    end
    prefixInput:SetScript("OnTextChanged", UpdatePreview)

    -- Card 2: Exclusions ------------------------------------
    local exclCard = CreateCard(panel, "Excluded characters", 100)
    exclCard:SetPoint("TOPLEFT", sigCard, "BOTTOMLEFT", 0, -10)
    exclCard:SetPoint("TOPRIGHT", sigCard, "BOTTOMRIGHT", 0, -10)

    local excludedInput = CreateInput(exclCard, 330)
    excludedInput:SetPoint("TOPLEFT", 20, -40)
    excludedInput:SetMaxLetters(255)

    local addCurrent = CreateFrame("Button", nil, exclCard, "UIPanelButtonTemplate")
    addCurrent:SetSize(130, 22)
    addCurrent:SetPoint("LEFT", excludedInput, "RIGHT", 10, 0)
    addCurrent:SetText("Add current")
    addCurrent:SetScript("OnClick", function()
        local name = UnitName("player")
        if not name then return end

        local list = Trim(excludedInput:GetText())
        for existing in list:gmatch("[^,]+") do
            if Trim(existing):lower() == name:lower() then
                return
            end
        end
        excludedInput:SetText(list == "" and name or (list .. ", " .. name))
    end)

    local exclHint = exclCard:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    exclHint:SetPoint("TOPLEFT", excludedInput, "BOTTOMLEFT", -6, -8)
    exclHint:SetText("Comma-separated names. Example: AltCharacter, Mage123, MyWarrior")

    -- Card 3: Channels --------------------------------------
    local rows = math.ceil(#CHANNELS / 2)
    local chanCard = CreateCard(panel, "Channels", 46 + rows * 26 + 10)
    chanCard:SetPoint("TOPLEFT", exclCard, "BOTTOMLEFT", 0, -10)
    chanCard:SetPoint("TOPRIGHT", exclCard, "BOTTOMRIGHT", 0, -10)

    local checks = {}
    for i, channel in ipairs(CHANNELS) do
        local col = (i - 1) % 2
        local row = math.floor((i - 1) / 2)
        local check = CreateCheckbox(chanCard, channel.label)
        check:SetPoint("TOPLEFT", 10 + col * 270, -38 - row * 26)
        checks[channel.key] = check
    end

    local function SetAllChannels(value)
        for _, check in pairs(checks) do
            check:SetChecked(value)
        end
    end

    local selectNone = CreateFrame("Button", nil, chanCard, "UIPanelButtonTemplate")
    selectNone:SetSize(80, 20)
    selectNone:SetPoint("TOPRIGHT", -12, -6)
    selectNone:SetText("None")
    selectNone:SetScript("OnClick", function() SetAllChannels(false) end)

    local selectAll = CreateFrame("Button", nil, chanCard, "UIPanelButtonTemplate")
    selectAll:SetSize(80, 20)
    selectAll:SetPoint("RIGHT", selectNone, "LEFT", -4, 0)
    selectAll:SetText("All")
    selectAll:SetScript("OnClick", function() SetAllChannels(true) end)

    -- Footer ------------------------------------------------
    local saveButton = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    saveButton:SetSize(140, 26)
    saveButton:SetPoint("BOTTOMLEFT", 16, 16)
    saveButton:SetText("Save Settings")

    local resetButton = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    resetButton:SetSize(140, 26)
    resetButton:SetPoint("LEFT", saveButton, "RIGHT", 8, 0)
    resetButton:SetText("Reset to defaults")

    local status = panel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    status:SetPoint("LEFT", resetButton, "RIGHT", 14, 0)

    local statusToken = 0
    local function ShowStatus(text, r, g, b)
        statusToken = statusToken + 1
        local token = statusToken
        status:SetText(text)
        status:SetTextColor(r, g, b)
        C_Timer.After(3, function()
            if token == statusToken then
                status:SetText("")
            end
        end)
    end

    -- Load / save -------------------------------------------
    local function LoadSettings()
        enabled:SetChecked(AzerothSignatureDB.enabled)
        prefixInput:SetText(Trim(AzerothSignatureDB.prefix or DEFAULT_PREFIX))
        prefixInput:SetCursorPosition(0)
        excludedInput:SetText(AzerothSignatureDB.excludedCharacter or "")
        excludedInput:SetCursorPosition(0)

        for _, channel in ipairs(CHANNELS) do
            checks[channel.key]:SetChecked(
                AzerothSignatureDB.channels[channel.key] == true
            )
        end
        UpdatePreview()
    end

    saveButton:SetScript("OnClick", function()
        local prefix = Trim(prefixInput:GetText())
        if prefix == "" then
            ShowStatus("Please enter a valid signature.", 1, 0.3, 0.3)
            return
        end

        AzerothSignatureDB.prefix = prefix .. " "
        AzerothSignatureDB.excludedCharacter = Trim(excludedInput:GetText())
        AzerothSignatureDB.enabled = enabled:GetChecked() and true or false

        for _, channel in ipairs(CHANNELS) do
            AzerothSignatureDB.channels[channel.key] =
                checks[channel.key]:GetChecked() and true or false
        end

        ShowStatus("Settings saved.", 0.3, 1, 0.4)
    end)

    resetButton:SetScript("OnClick", function()
        enabled:SetChecked(DEFAULTS.enabled)
        prefixInput:SetText(Trim(DEFAULTS.prefix))
        excludedInput:SetText(DEFAULTS.excludedCharacter)
        SetAllChannels(true)
        ShowStatus("Defaults loaded - click Save to apply.", 0.9, 0.8, 0.4)
    end)

    panel:SetScript("OnShow", LoadSettings)

    settingsCategory = Settings.RegisterCanvasLayoutCategory(panel, panel.name)
    Settings.RegisterAddOnCategory(settingsCategory)
end

------------------------------------------------------------
-- Chat hook & slash command
------------------------------------------------------------

local function RegisterChatHook()
    if not EventRegistry or not EventRegistry.RegisterCallback then
        PrintMessage("Retail chat callback API unavailable.")
        return
    end

    EventRegistry:RegisterCallback(
        "ChatFrame.OnEditBoxPreSendText",
        OnPreSendText,
        ADDON_NAME
    )
end

SLASH_AZEROTHSIGNATURE1 = "/azsig"
SlashCmdList["AZEROTHSIGNATURE"] = function()
    if settingsCategory and Settings and Settings.OpenToCategory then
        Settings.OpenToCategory(settingsCategory:GetID())
    end
end

------------------------------------------------------------
-- Events
------------------------------------------------------------

local frame = CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("PLAYER_LOGIN")

local initialized, hookRegistered = false, false

frame:SetScript("OnEvent", function(_, event, addonName)
    if event == "ADDON_LOADED" then
        if addonName ~= ADDON_NAME or initialized then
            return
        end
        initialized = true
        Initialize()
        CreateOptions()

    elseif event == "PLAYER_LOGIN" then
        if hookRegistered then
            return
        end
        hookRegistered = true
        RegisterChatHook()
    end
end)
