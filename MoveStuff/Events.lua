local _, addon = ...;

local tinsert = _G.tinsert;
local hooksecurefunc = _G.hooksecurefunc;

local InCombatLockdown = _G.InCombatLockdown;

local events = {}
local addonFrame = _G.CreateFrame('frame')

function addon.on (eventList, callback)
  if (type(eventList) ~= 'table') then
    eventList = {eventList};
  end

  for _, event in ipairs(eventList) do
    if (events[event] == nil) then
      events[event] = {callback};
      addonFrame:RegisterEvent(event);
    else
      tinsert(events[event], callback);
    end
  end
end

local function eventHandler (_, event, ...)
  for _, callback in ipairs(events[event]) do
    callback(...);
  end
end

addonFrame:SetScript('OnEvent', eventHandler);

--[[
///#############################################################################
/// in combat hooking
///#############################################################################
--]]
do
  local combatMap = {};
  local callbackCount = 0;

  local function createHook (script, callback)
    local callbackId = callbackCount;

    callbackCount = callbackCount + 1;

    return function (...)
      local frame = ...;

      if (InCombatLockdown() and frame:IsProtected()) then
        local funcInfo = combatMap[script];

        if (funcInfo == nil) then
          combatMap[script] = {
            params = {...},
            callbacks = {
              [callbackId] = callback,
            },
          }
        else
          funcInfo.callbacks[callbackId] = callback;
          funcInfo.params = {...};
        end
      else
        callback(...);
      end
    end
  end

  function addon.hookScriptSecure (frame, script, callback)
    frame:HookScript(script, createHook(script, callback));
  end

  function addon.hooksecure (...)
    if (select('#', ...) >= 3) then
      local frame, script, callback = ...;

      hooksecurefunc(frame, script, createHook(script, callback));
    else
      local script, callback = ...;

      hooksecurefunc(script, createHook(script, callback));
    end
  end

  addon.on('PLAYER_REGEN_ENABLED', function ()
    for _, funcInfo in pairs (combatMap) do
      for _, callback in pairs(funcInfo.callbacks) do
        callback(unpack(funcInfo.params));
      end
    end

    combatMap = {};
  end);
end
