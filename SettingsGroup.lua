local _, ns = ...
local group = PaperBaconBitsSettings

if not group then
    group = {}
    PaperBaconBitsSettings = group
    local modules = {}

    local function Register()
        if group.pluginID then return true end
        local eui = EllesmereUI
        if not eui or type(eui.RegisterPlugin) ~= "function" then return false end

        local providers = {}
        for addonName in pairs(modules) do
            providers[#providers + 1] = addonName
        end
        table.sort(providers)
        if #providers == 0 then return false end

        local specs = {}
        for _, addonName in ipairs(providers) do
            specs[#specs + 1] = modules[addonName]
        end
        local pluginID = providers[1]
        if not eui.RegisterPlugin(pluginID, { label = "Paper Bacon Bits", modules = specs }) then
            return false
        end
        group.pluginID = pluginID
        return true
    end

    function group.AddModule(addonName, spec)
        if group.pluginID then return false end
        modules[addonName] = spec
        return true
    end

    function group.Open(moduleKey, pageName)
        if not Register() then return false end
        return EllesmereUI.OpenPlugin(group.pluginID, moduleKey, pageName)
    end

    local frame = CreateFrame("Frame")
    frame:RegisterEvent("PLAYER_LOGIN")
    frame:SetScript("OnEvent", function(self)
        self:UnregisterEvent("PLAYER_LOGIN")
        Register()
    end)
end

ns.SettingsGroup = group
