
local ADDON_NAME = ...
local DEFAULT_PREFIX = "<MyMain> "

AzerothSignatureDB = AzerothSignatureDB or {}

local CHANNELS = {
    { key = "SAY", label = "Say (/say)" },
    { key = "YELL", label = "Yell (/yell)" },
    { key = "PARTY", label = "Party (/party)" },
    { key = "RAID", label = "Raid (/raid)" },
    { key = "INSTANCE_CHAT", label = "Instance Chat" },
    { key = "GUILD", label = "Guild (/guild)" },
    { key = "OFFICER", label = "Officer (/officer)" },
    { key = "WHISPER", label = "Whisper (/whisper)" },
    { key = "CHANNEL", label = "Custom channels (/1, /2...)" },
}

local function PrintMessage(message)
    if DEFAULT_CHAT_FRAME then
        DEFAULT_CHAT_FRAME:AddMessage(
            "|cffd5b15bAzeroth Signature:|r " .. tostring(message)
        )
    end
end

local function MigrateLegacySettings()
    local oldDB = Name2ChatSafeDB

    if type(oldDB) ~= "table" then
        return
    end

    for _, key in ipairs({
        "prefix",
        "enabled",
        "excludedCharacter",
    }) do
        if AzerothSignatureDB[key] == nil and oldDB[key] ~= nil then
            AzerothSignatureDB[key] = oldDB[key]
        end
    end

    if type(oldDB.channels) == "table" then
        AzerothSignatureDB.channels =
            AzerothSignatureDB.channels or {}

        for key, value in pairs(oldDB.channels) do
            if AzerothSignatureDB.channels[key] == nil then
                AzerothSignatureDB.channels[key] = value
            end
        end
    end
end

local function Initialize()
    MigrateLegacySettings()

    if AzerothSignatureDB.prefix == nil then
        AzerothSignatureDB.prefix = DEFAULT_PREFIX
    end

    if AzerothSignatureDB.enabled == nil then
        AzerothSignatureDB.enabled = true
    end

    if AzerothSignatureDB.excludedCharacter == nil then
        AzerothSignatureDB.excludedCharacter = ""
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

local function IsCharacterExcluded()
    local excluded =
        AzerothSignatureDB.excludedCharacter or ""

    local playerName = UnitName("player")

    if not playerName then
        return false
    end

    playerName = playerName:lower()

    for name in excluded:gmatch("[^,]+") do
        name = name:match("^%s*(.-)%s*$")

        if name and name:lower() == playerName then
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

local function OnPreSendText(owner, editBox, ...)
    Initialize()

    if not AzerothSignatureDB.enabled then
        return
    end

    -- Retail combat restrictions:
    -- never modify outgoing chat text during combat.
    if InCombatLockdown and InCombatLockdown() then
        return
    end

    if IsCharacterExcluded() then
        return
    end

    -- Retail's pre-send callback supplies the edit box.
    -- Use the active edit box only as a compatibility fallback.
    if type(editBox) ~= "table"
        and type(editBox) ~= "userdata" then
        editBox = nil
    end

    if not editBox or type(editBox.GetText) ~= "function" then
        if ChatEdit_GetActiveWindow then
            editBox = ChatEdit_GetActiveWindow()
        end
    end

    if not editBox or type(editBox.GetText) ~= "function" then
        return
    end

    local chatType = GetChatType(editBox)

    if not chatType then
        return
    end

    local channels = AzerothSignatureDB.channels or {}

    -- Treat /raid as eligible for instance raid chat too.
    local enabled = channels[chatType]

    if chatType == "INSTANCE_CHAT" and channels.RAID then
        enabled = true
    end

    if not enabled then
        return
    end

    local prefix = AzerothSignatureDB.prefix or DEFAULT_PREFIX

    if prefix == "" then
        return
    end

    local ok, text = pcall(function()
        return editBox:GetText()
    end)

    if not ok or type(text) ~= "string" or text == "" then
        return
    end

    if text:sub(1, #prefix) == prefix then
        return
    end

    -- The documented pre-send callback runs before Blizzard
    -- reads the final edit-box text. Do not call SendChatMessage.
    local success, err = pcall(function()
        editBox:SetText(prefix .. text)
    end)

    if not success then
        PrintMessage("Could not update chat text: " .. tostring(err))
    end
end

local function CreateOptions()
    local panel = CreateFrame("Frame")
    panel.name = "Azeroth Signature"

    local title = panel:CreateFontString(
        nil, "ARTWORK", "GameFontNormalLarge"
    )
    title:SetPoint("TOPLEFT", 16, -16)
    title:SetText("Azeroth Signature")

    local description = panel:CreateFontString(
        nil, "ARTWORK", "GameFontHighlight"
    )
    description:SetPoint(
        "TOPLEFT", title, "BOTTOMLEFT", 0, -10
    )
    description:SetText(
        "Configure your signature, excluded characters and chat channels."
    )

    local enabled = CreateFrame(
        "CheckButton",
        nil,
        panel,
        "InterfaceOptionsCheckButtonTemplate"
    )
    enabled:SetPoint(
        "TOPLEFT", description, "BOTTOMLEFT", -4, -18
    )
    enabled.Text:SetText("Enable automatic signature")

    local prefixLabel = panel:CreateFontString(
        nil, "ARTWORK", "GameFontNormal"
    )
    prefixLabel:SetPoint(
        "TOPLEFT", enabled, "BOTTOMLEFT", 4, -14
    )
    prefixLabel:SetText("Signature / prefix:")

    local prefixInput = CreateFrame(
        "EditBox", nil, panel, "InputBoxTemplate"
    )
    prefixInput:SetSize(230, 30)
    prefixInput:SetPoint(
        "TOPLEFT", prefixLabel, "BOTTOMLEFT", 0, -8
    )
    prefixInput:SetAutoFocus(false)
    prefixInput:SetMaxLetters(100)

    local excludedLabel = panel:CreateFontString(
        nil, "ARTWORK", "GameFontNormal"
    )
    excludedLabel:SetPoint(
        "TOPLEFT", prefixInput, "BOTTOMLEFT", 0, -16
    )
    excludedLabel:SetText(
        "Excluded character names (comma-separated):"
    )

    local excludedInput = CreateFrame(
        "EditBox", nil, panel, "InputBoxTemplate"
    )
    excludedInput:SetSize(280, 30)
    excludedInput:SetPoint(
        "TOPLEFT", excludedLabel, "BOTTOMLEFT", 0, -8
    )
    excludedInput:SetAutoFocus(false)
    excludedInput:SetMaxLetters(255)

    local excludedHint = panel:CreateFontString(
        nil, "ARTWORK", "GameFontHighlightSmall"
    )
    excludedHint:SetPoint(
        "TOPLEFT", excludedInput, "BOTTOMLEFT", 0, -5
    )
    excludedHint:SetText(
        "Example: AltCharacter, Mage123, MyWarrior"
    )

    local channelTitle = panel:CreateFontString(
        nil, "ARTWORK", "GameFontNormal"
    )
    channelTitle:SetPoint(
        "TOPLEFT", excludedHint, "BOTTOMLEFT", 0, -18
    )
    channelTitle:SetText("Apply signature to these channels:")

    local checks = {}
    local previous = channelTitle

    for _, channel in ipairs(CHANNELS) do
        local check = CreateFrame(
            "CheckButton",
            nil,
            panel,
            "InterfaceOptionsCheckButtonTemplate"
        )

        check:SetPoint(
            "TOPLEFT", previous, "BOTTOMLEFT", 0, -5
        )
        check.Text:SetText(channel.label)

        checks[channel.key] = check
        previous = check
    end

    local saveButton = CreateFrame(
        "Button",
        nil,
        panel,
        "UIPanelButtonTemplate"
    )
    saveButton:SetSize(150, 26)
    saveButton:SetPoint(
        "TOPLEFT", previous, "BOTTOMLEFT", 4, -14
    )
    saveButton:SetText("Save Settings")

    local function LoadSettings()
        Initialize()

        enabled:SetChecked(AzerothSignatureDB.enabled)

        prefixInput:SetText(
            (AzerothSignatureDB.prefix or DEFAULT_PREFIX)
                :gsub("%s+$", "")
        )

        excludedInput:SetText(
            AzerothSignatureDB.excludedCharacter or ""
        )

        for _, channel in ipairs(CHANNELS) do
            checks[channel.key]:SetChecked(
                AzerothSignatureDB.channels[channel.key] == true
            )
        end
    end

    saveButton:SetScript("OnClick", function()
        local prefix = (prefixInput:GetText() or "")
            :match("^%s*(.-)%s*$")

        if not prefix or prefix == "" then
            PrintMessage("Please enter a valid signature.")
            return
        end

        local excluded = (excludedInput:GetText() or "")
            :match("^%s*(.-)%s*$")

        AzerothSignatureDB.prefix = prefix .. " "
        AzerothSignatureDB.excludedCharacter = excluded
        AzerothSignatureDB.enabled =
            enabled:GetChecked() and true or false

        for _, channel in ipairs(CHANNELS) do
            AzerothSignatureDB.channels[channel.key] =
                checks[channel.key]:GetChecked() and true or false
        end

        PrintMessage("Settings saved.")
    end)

    panel:SetScript("OnShow", LoadSettings)

    local category = Settings.RegisterCanvasLayoutCategory(
        panel, panel.name
    )
    Settings.RegisterAddOnCategory(category)
end

local function RegisterChatHook()
    if not EventRegistry
        or not EventRegistry.RegisterCallback then
        PrintMessage("Retail chat callback API unavailable.")
        return
    end

    EventRegistry:RegisterCallback(
        "ChatFrame.OnEditBoxPreSendText",
        OnPreSendText,
        ADDON_NAME
    )

    PrintMessage("Chat callback registered.")
end

local frame = CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("PLAYER_LOGIN")

local initialized = false
local hookRegistered = false

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
