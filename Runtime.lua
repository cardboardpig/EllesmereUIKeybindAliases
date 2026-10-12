-------------------------------------------------------------------------------
-- Runtime.lua
-- Display-only aliases for EllesmereUI action-bar keybind text.
-------------------------------------------------------------------------------

local _, ns = ...

local aliasMap = {}
local hooked = setmetatable({}, { __mode = "k" })
local applying = setmetatable({}, { __mode = "k" })
local sourceText = setmetatable({}, { __mode = "k" })

-------------------------------------------------------------------------------
-- SavedVariables
-------------------------------------------------------------------------------

local function EnsureDB()

if type(EllesmereUIKeybindAliasesDB) ~= "table" then
EllesmereUIKeybindAliasesDB = {}
end

local db = EllesmereUIKeybindAliasesDB

if type(db.aliases) ~= "table" then
db.aliases = {}
end

return db

end

local function ClearAliases()

local db = EnsureDB()

wipe(db.aliases)

end

-------------------------------------------------------------------------------
-- Alias map
-------------------------------------------------------------------------------

local function RebuildAliasMap()

wipe(aliasMap)

local db = EnsureDB()

for _, entry in ipairs(db.aliases) do

if type(entry) == "table" then

local from = strtrim(tostring(entry.from or ""))
local to = tostring(entry.to or "")

if from ~= "" then
aliasMap[from] = to
end

end

end

end

local function GetAlias(text)

if text == nil then return nil end

return aliasMap[text]

end

-------------------------------------------------------------------------------
-- Hotkey hooks
-------------------------------------------------------------------------------

local function ApplyAlias(hotkey, text)

if not hotkey or applying[hotkey] then return end

local alias = GetAlias(text)
local displayText = alias ~= nil and alias or text

if hotkey:GetText() == displayText then return end

applying[hotkey] = true
hotkey:SetText(displayText)
applying[hotkey] = nil

end

local function HookHotkey(hotkey)

if not hotkey or hooked[hotkey] then return end
if type(hotkey.GetText) ~= "function" or type(hotkey.SetText) ~= "function" then return end

hooked[hotkey] = true

hooksecurefunc(hotkey, "SetText", function(self, text)

if applying[self] then return end

sourceText[self] = text

local alias = GetAlias(text)

if alias ~= nil and alias ~= text then

applying[self] = true
self:SetText(alias)
applying[self] = nil

end

end)

local text = hotkey:GetText()

sourceText[hotkey] = text
ApplyAlias(hotkey, text)

end

local function HookActionBarButtons()

-- Discover hotkey regions through WoW's named frames and GetChildren API.
-- Never read EUI's private module registry or hook its Lua functions.
local function HookBar(barName)
local bar = _G["EABBar_" .. barName]
if not bar then return end
for _, button in ipairs({ bar:GetChildren() }) do
if button.HotKey then HookHotkey(button.HotKey) end
end
end

HookBar("MainBar")
for index = 2, 10 do HookBar("Bar" .. index) end
HookBar("StanceBar")
HookBar("PetBar")

end

local function RefreshAliases()

RebuildAliasMap()
HookActionBarButtons()

for hotkey in pairs(hooked) do

local text = sourceText[hotkey]

if text ~= nil then
ApplyAlias(hotkey, text)
end

end

end

-------------------------------------------------------------------------------
-- Public API
-------------------------------------------------------------------------------

ns.EnsureDB = EnsureDB
ns.ClearAliases = ClearAliases
ns.RefreshAliases = RefreshAliases

-------------------------------------------------------------------------------
-- Initialization
-------------------------------------------------------------------------------

local initFrame = CreateFrame("Frame")

initFrame:RegisterEvent("PLAYER_LOGIN")
initFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
initFrame:RegisterEvent("UPDATE_BINDINGS")

initFrame:SetScript("OnEvent", function(_, event)

EnsureDB()
RebuildAliasMap()
HookActionBarButtons()

if event == "PLAYER_LOGIN" then

C_Timer.After(0, RefreshAliases)

else

RefreshAliases()

end

end)
