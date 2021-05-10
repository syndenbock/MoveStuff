local addonName, addon = ...;

local SAVEDVARS_KEY = _G.GetAddOnMetadata(addonName, 'X-SavedVariables') or
    addonName .. '_saved';
local SAVEDCHARVARS_KEY =
    _G.GetAddOnMetadata(addonName, 'X-SavedVariablesPerCharacter') or
    addonName .. 'charSaved';

addon.saved = {};
addon.charSaved = {};

local function updateOptions (options, update)
  if (type(update) ~= 'table') then
    return;
  end

  for key, value in pairs(update) do
    options[key] = value;
  end
end

local function globalizeOptions (options, globalName)
  if (type(_G[globalName]) == 'table') then
    for option, value in pairs(options) do
      _G[globalName][option] = value;
    end
  else
    _G[globalName] = options;
  end
end

local function addonLoadHandler (loadedAddonName)
  if (loadedAddonName ~= addonName) then
    return;
  end

  updateOptions(addon.saved, _G[SAVEDVARS_KEY] or {});
  updateOptions(addon.charSaved, _G[SAVEDCHARVARS_KEY] or {});
  addon.off('ADDON_LOADED', addonLoadHandler);
end

addon.on('ADDON_LOADED', addonLoadHandler);

addon.on('PLAYER_LOGOUT', function ()
  globalizeOptions(addon.saved, SAVEDVARS_KEY);
  globalizeOptions(addon.charSaved, SAVEDCHARVARS_KEY);
end);
