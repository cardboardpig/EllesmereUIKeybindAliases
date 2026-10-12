-------------------------------------------------------------------------------
-- OptionsIntegration.lua
-- Registers a standalone settings section through the EllesmereUI Plugin API.
-------------------------------------------------------------------------------

local _, ns = ...

local PLUGIN_ID = "EllesmereUIKeybindAliases"
local MODULE_KEY = "Aliases"
local PAGE_ALIASES = "Keybind Aliases"

-------------------------------------------------------------------------------
-- Helpers
-------------------------------------------------------------------------------

local function RefreshPage()

-- Defer rebuilding until the current control's callback has returned. Only
-- invalidate our own module if the user switches pages before this runs.
C_Timer.After(0, function()
local eui = EllesmereUI
if not eui or not eui.GetPluginModuleKey then return end
local key = eui.GetPluginModuleKey(PLUGIN_ID, MODULE_KEY)
if not key then return end
eui:InvalidateModulePageCache(key)
if eui:GetActiveModule() == key then eui:RefreshPage(true) end
end)

end

local function MakeEditBox(parent, value)

local PP = EllesmereUI.PanelPP
local fontPath = EllesmereUI.EXPRESSWAY or "Fonts\\FRIZQT__.TTF"

local box = CreateFrame("EditBox", nil, parent)

PP.Size(box, 100, 28)

box:SetAutoFocus(false)
box:SetMaxLetters(50)
box:SetText(value or "")
box:SetTextInsets(8, 8, 0, 0)
box:SetFont(fontPath, 12, "")
box:SetTextColor(1, 1, 1, 0.9)

local bg = EllesmereUI.SolidTex(
box, "BACKGROUND",
EllesmereUI.DD_BG_R, EllesmereUI.DD_BG_G, EllesmereUI.DD_BG_B, EllesmereUI.DD_BG_A
)

bg:SetAllPoints()

local border = EllesmereUI.MakeBorder(
box, 1, 1, 1, EllesmereUI.DD_BRD_A, PP
)

box:SetScript("OnEnter", function(self)

bg:SetColorTexture(
EllesmereUI.DD_BG_R, EllesmereUI.DD_BG_G, EllesmereUI.DD_BG_B, EllesmereUI.DD_BG_HA
)

border:SetColor(1, 1, 1, EllesmereUI.DD_BRD_HA)

end)

box:SetScript("OnLeave", function(self)

bg:SetColorTexture(
EllesmereUI.DD_BG_R, EllesmereUI.DD_BG_G, EllesmereUI.DD_BG_B, EllesmereUI.DD_BG_A
)

border:SetColor(1, 1, 1, EllesmereUI.DD_BRD_A)

end)

return box

end

local function MakeButton(parent, width, text)

local PP = EllesmereUI.PanelPP

local button = CreateFrame("Button", nil, parent)

PP.Size(button, width, 28)

local bg = EllesmereUI.SolidTex(
button, "BACKGROUND",
EllesmereUI.DD_BG_R, EllesmereUI.DD_BG_G, EllesmereUI.DD_BG_B, EllesmereUI.DD_BG_A
)

bg:SetAllPoints()

local border = EllesmereUI.MakeBorder(
button, 1, 1, 1, EllesmereUI.DD_BRD_A, PP
)

local label = EllesmereUI.MakeFont(button, 12, nil, 1, 1, 1)

label:SetPoint("CENTER")
label:SetText(EllesmereUI.L(text))
label:SetAlpha(EllesmereUI.DD_TXT_A or 0.8)

button:SetScript("OnEnter", function()

bg:SetColorTexture(
EllesmereUI.DD_BG_R, EllesmereUI.DD_BG_G, EllesmereUI.DD_BG_B, EllesmereUI.DD_BG_HA
)

border:SetColor(1, 1, 1, EllesmereUI.DD_BRD_HA)

label:SetAlpha(EllesmereUI.DD_TXT_HA or 1)

end)

button:SetScript("OnLeave", function()

bg:SetColorTexture(
EllesmereUI.DD_BG_R, EllesmereUI.DD_BG_G, EllesmereUI.DD_BG_B, EllesmereUI.DD_BG_A
)

border:SetColor(1, 1, 1, EllesmereUI.DD_BRD_A)

label:SetAlpha(EllesmereUI.DD_TXT_A or 0.8)

end)

return button

end

-------------------------------------------------------------------------------
-- Keybind Aliases page
-------------------------------------------------------------------------------

local function BuildAliasesPage(parent, yOffset)

-- This editor uses real frames, so hidden search pre-builds must not create
-- controls or initialize saved variables.
if EllesmereUI.IsSearchPrebuild() then return 0 end

local db = ns.EnsureDB and ns.EnsureDB()

if not db then return 0 end

local W = EllesmereUI.Widgets
local PP = EllesmereUI.PanelPP
local L = EllesmereUI.L
local pad = EllesmereUI.CONTENT_PAD or 16
local y = yOffset
local _, h

_, h = W:SectionHeader(parent, "KEYBIND ALIASES FOR ELLESMEREUI", y)
y = y - h

local info = EllesmereUI.MakeFont(parent, 11, nil, 1, 1, 1, 0.55)

PP.Point(info, "TOPLEFT", parent, "TOPLEFT", pad, y)
PP.Point(info, "TOPRIGHT", parent, "TOPRIGHT", -pad, y)

info:SetJustifyH("LEFT")
info:SetWordWrap(true)
info:SetText(L(
"Replace the shortened keybind labels shown on EllesmereUI action bars. "
.. "This changes only the displayed text; your actual WoW key bindings are untouched."
.. "\n\nAn unofficial companion addon for EllesmereUI. Not affiliated with or endorsed by the EllesmereUI team."
))

y = y - math.max(42, info:GetStringHeight() + 16)

local leftHeader = EllesmereUI.MakeFont(parent, 10, nil, 1, 1, 1, 0.48)
local rightHeader = EllesmereUI.MakeFont(parent, 10, nil, 1, 1, 1, 0.48)

PP.Point(leftHeader, "TOPLEFT", parent, "TOPLEFT", pad + 12, y)
leftHeader:SetText(L("CURRENT EUI TEXT"))

PP.Point(rightHeader, "TOP", parent, "TOP", 55, y)
rightHeader:SetText(L("DISPLAY AS"))

y = y - 22

for index, entry in ipairs(db.aliases) do

local rowFrame = CreateFrame("Frame", nil, parent)

PP.Size(rowFrame, parent:GetWidth() - pad * 2, 54)
PP.Point(rowFrame, "TOPLEFT", parent, "TOPLEFT", pad, y)

local rowBg = rowFrame:CreateTexture(nil, "BACKGROUND")
rowBg:SetAllPoints()
rowBg:SetColorTexture(1, 1, 1, index % 2 == 0 and 0.025 or 0.045)

local removeButton = MakeButton(rowFrame, 92, "Remove")

PP.Point(removeButton, "RIGHT", rowFrame, "RIGHT", -10, 0)

local toLabel = EllesmereUI.MakeFont(rowFrame, 10, nil, 1, 1, 1, 0.45)

toLabel:SetWidth(26)
toLabel:SetJustifyH("CENTER")
toLabel:SetText(L("TO"))
PP.Point(toLabel, "CENTER", rowFrame, "CENTER", -47, 0)

local leftRegion = CreateFrame("Frame", nil, rowFrame)
local rightRegion = CreateFrame("Frame", nil, rowFrame)

leftRegion:SetHeight(28)
rightRegion:SetHeight(28)

PP.Point(leftRegion, "LEFT", rowFrame, "LEFT", 12, 0)
PP.Point(leftRegion, "RIGHT", toLabel, "LEFT", -10, 0)
PP.Point(rightRegion, "LEFT", toLabel, "RIGHT", 10, 0)
PP.Point(rightRegion, "RIGHT", removeButton, "LEFT", -8, 0)

local fromBox = MakeEditBox(leftRegion, entry.from)
local toBox = MakeEditBox(rightRegion, entry.to)

fromBox:SetAllPoints(leftRegion)
toBox:SetAllPoints(rightRegion)

local function Commit()

entry.from = strtrim(fromBox:GetText() or "")
entry.to = toBox:GetText() or ""

if ns.RefreshAliases then ns.RefreshAliases() end

end

fromBox:SetScript("OnEnterPressed", function(self)

Commit()
self:ClearFocus()

end)

fromBox:SetScript("OnEscapePressed", function(self)

self:SetText(entry.from or "")
self:ClearFocus()

end)

fromBox:SetScript("OnEditFocusLost", Commit)

toBox:SetScript("OnEnterPressed", function(self)

Commit()
self:ClearFocus()

end)

toBox:SetScript("OnEscapePressed", function(self)

self:SetText(entry.to or "")
self:ClearFocus()

end)

toBox:SetScript("OnEditFocusLost", Commit)

removeButton:SetScript("OnClick", function()

table.remove(db.aliases, index)

if ns.RefreshAliases then ns.RefreshAliases() end

RefreshPage()

end)

y = y - 54

end

y = y - 6

local addButton = MakeButton(parent, 140, "+ Add Replacement")
local clearButton = MakeButton(parent, 90, "Clear All")

PP.Point(addButton, "TOPLEFT", parent, "TOPLEFT", pad, y)
PP.Point(clearButton, "LEFT", addButton, "RIGHT", 10, 0)

addButton:SetScript("OnClick", function()

db.aliases[#db.aliases + 1] = { from = "", to = "" }

RefreshPage()

end)

clearButton:SetScript("OnClick", function()

if ns.ClearAliases then ns.ClearAliases() end
if ns.RefreshAliases then ns.RefreshAliases() end

RefreshPage()

end)

y = y - 52

local note = EllesmereUI.MakeFont(parent, 10, nil, 1, 1, 1, 0.42)

PP.Point(note, "TOPLEFT", parent, "TOPLEFT", pad, y)
PP.Point(note, "TOPRIGHT", parent, "TOPRIGHT", -pad, y)

note:SetJustifyH("LEFT")
note:SetWordWrap(true)
note:SetText(L(
"Changes apply when you press Enter or click away from a field. "
.. "Aliases are account-wide and persist across reloads."
))

y = y - 34

return math.abs(y)

end

-------------------------------------------------------------------------------
-- Plugin registration
-------------------------------------------------------------------------------

if EllesmereUI and type(EllesmereUI.RegisterPlugin) == "function" then
EllesmereUI.RegisterPlugin(PLUGIN_ID, {
label = "Keybind Aliases",
modules = {
{
key = MODULE_KEY,
title = "Keybind Aliases",
description = "Custom display labels for EllesmereUI action-bar keybinds.",
pages = { PAGE_ALIASES },
-- Custom edit boxes need real frames; the page itself remains searchable.
searchPrebuild = false,
buildPage = function(pageName, parent, yOffset)
if pageName == PAGE_ALIASES then
return BuildAliasesPage(parent, yOffset)
end
return 0
end,
},
},
})
end

SLASH_EUIKEYBINDALIASES1 = "/euika"
SlashCmdList.EUIKEYBINDALIASES = function()
if EllesmereUI and type(EllesmereUI.OpenPlugin) == "function" then
EllesmereUI.OpenPlugin(PLUGIN_ID, MODULE_KEY, PAGE_ALIASES)
else
print("Keybind Aliases: update EllesmereUI to a version with Plugin API v1, then reload the interface.")
end
end
