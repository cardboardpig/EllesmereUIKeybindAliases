-- Run from the addon root with Lua 5.1. No WoW client required.
local frames, timers = {}, {}
local ns = {}
local function Frame(kind)
    local frame = { kind = kind, scripts = {}, children = {} }
    setmetatable(frame, { __index = function(_, key)
        return function() end
    end })
    function frame:SetScript(event, fn) self.scripts[event] = fn end
    function frame:SetText(text) self.text = text end
    function frame:GetText() return rawget(self, "text") end
    function frame:GetWidth() return 800 end
    function frame:GetStringHeight() return 30 end
    function frame:GetChildren() return unpack(self.children) end
    function frame:CreateTexture() return Frame("Texture") end
    frames[#frames + 1] = frame
    return frame
end
CreateFrame = Frame
function wipe(t) for key in pairs(t) do t[key] = nil end end
function strtrim(s) return (s:gsub("^%s+", ""):gsub("%s+$", "")) end
local hooks = 0
function hooksecurefunc(object, method, callback)
    assert(method == "SetText", "Only WoW FontString methods may be hooked")
    hooks = hooks + 1
    local original = object[method]
    object[method] = function(self, ...)
        original(self, ...)
        callback(self, ...)
    end
end
C_Timer = { After = function(_, callback) timers[#timers + 1] = callback end }
local function FlushTimers()
    local pending = timers
    timers = {}
    for _, callback in ipairs(pending) do callback() end
end
SlashCmdList = {}
local saved = { aliases = {
    { from = "SMwU", to = "SMU" },
    { from = "SMwD", to = "" },
    { from = "SMwU", to = "UP" },
} }
EllesmereUIKeybindAliasesDB = saved
local function Bar(name, text)
    local hotkey = Frame("FontString")
    hotkey:SetText(text)
    local bar = Frame("Frame")
    bar.children = { { HotKey = hotkey }, {} }
    _G["EABBar_" .. name] = bar
    return hotkey
end
local main = Bar("MainBar", "SMwU")
local pet = Bar("PetBar", "SMwD")
local stance = Bar("StanceBar", "sMwU")
local extra = Bar("Bar10", "SMwU")
assert(loadfile("Runtime.lua"))("EllesmereUIKeybindAliases", ns)
ns.RefreshAliases()
assert(EllesmereUIKeybindAliasesDB == saved, "Migration must preserve saved data")
assert(main:GetText() == "UP" and extra:GetText() == "UP", "Last alias wins")
assert(pet:GetText() == "", "Empty replacement hides text")
assert(stance:GetText() == "sMwU", "Matching must stay case-sensitive")
main:SetText("SMwD")
assert(main:GetText() == "", "New source text must be aliased")
ns.RefreshAliases()
assert(hooks == 4, "Refresh must not duplicate hooks")
ns.ClearAliases()
ns.RefreshAliases()
assert(main:GetText() == "SMwD" and extra:GetText() == "SMwU")
assert(pet:GetText() == "SMwD", "Clearing must restore original source text")
local late = Bar("Bar9", "SMwU")
saved.aliases[1] = { from = "SMwU", to = "SMU" }
ns.RefreshAliases()
assert(late:GetText() == "SMU", "Later-created bars must be discovered")

local pluginID = "EllesmereUIKeybindAliases"
local moduleKey = "plugin:" .. pluginID .. ":Aliases"
local spec, active, prebuild, refreshes = nil, moduleKey, false, 0
local invalidations, opened = {}, nil
EllesmereUI = setmetatable({
    PanelPP = { Size = function() end, Point = function() end },
    L = function(s) return s end,
    MakeFont = function() return Frame("FontString") end,
    SolidTex = function() return Frame("Texture") end,
    MakeBorder = function() return Frame("Border") end,
    IsSearchPrebuild = function() return prebuild end,
    Widgets = { SectionHeader = function() return {}, 24 end },
    RegisterPlugin = function(id, config)
        assert(id == pluginID and not spec)
        assert(config.label == "Keybind Aliases")
        assert(#config.modules == 1 and config.modules[1].key == "Aliases")
        assert(config.modules[1].searchPrebuild == false)
        spec = config
        return true
    end,
    GetPluginModuleKey = function(id, key)
        assert(id == pluginID and key == "Aliases")
        return moduleKey
    end,
    GetActiveModule = function() return active end,
    InvalidateModulePageCache = function(_, key)
        assert(key == moduleKey)
        invalidations[#invalidations + 1] = key
    end,
    RefreshPage = function(_, force)
        assert(force == true and active == moduleKey)
        refreshes = refreshes + 1
    end,
    OpenPlugin = function(id, key, page)
        opened = { id, key, page }
        return true
    end,
}, {
    __index = function(_, key)
        assert(key:sub(1, 1) ~= "_", "Private EUI field accessed: " .. key)
    end,
    __newindex = function() error("EUI functions/fields must not be overwritten") end,
})
assert(loadfile("OptionsIntegration.lua"))(pluginID, ns)
assert(spec and SLASH_EUIKEYBINDALIASES1 == "/euika")
SlashCmdList.EUIKEYBINDALIASES()
assert(opened[1] == pluginID and opened[2] == "Aliases" and opened[3] == "Keybind Aliases")
local build = spec.modules[1].buildPage
local parent = Frame("Frame")
prebuild = true
local before = #frames
local originalEnsure = ns.EnsureDB
ns.EnsureDB = function() error("Search must not touch saved data") end
assert(build("Keybind Aliases", parent, -10) == 0 and #frames == before)
ns.EnsureDB = originalEnsure
prebuild = false
local function BuildEditor()
    local start = #frames
    assert(build("Keybind Aliases", parent, -10) > 0)
    local buttons, edits = {}, {}
    for index = start + 1, #frames do
        local frame = frames[index]
        if frame.kind == "Button" then buttons[#buttons + 1] = frame end
        if frame.kind == "EditBox" then edits[#edits + 1] = frame end
    end
    return buttons, edits
end
local buttons, edits = BuildEditor()
assert(#buttons == 3 and #edits == 2)
edits[2]:SetText("Wheel Up")
edits[2].scripts.OnEnterPressed(edits[2])
assert(late:GetText() == "Wheel Up")
buttons[2].scripts.OnClick() -- Add
FlushTimers()
assert(#saved.aliases == 2 and refreshes == 1)
buttons = BuildEditor()
buttons[1].scripts.OnClick() -- Remove first alias
active = "UnrelatedModule" -- User switches away before deferred refresh
FlushTimers()
assert(#saved.aliases == 1 and refreshes == 1 and #invalidations == 2)
assert(late:GetText() == "SMwU")
active = moduleKey
buttons = BuildEditor()
buttons[#buttons].scripts.OnClick() -- Clear all
FlushTimers()
assert(#saved.aliases == 0 and refreshes == 2)

-- Older EUI must not receive the old RegisterModule monkey patch.
EllesmereUI = {}
assert(loadfile("OptionsIntegration.lua"))(pluginID, ns)
assert(next(EllesmereUI) == nil)
print("PASS: runtime aliases, plugin registration, search safety, editor changes, cache isolation, legacy guard")
