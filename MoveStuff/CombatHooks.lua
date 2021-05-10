local _, addon = ...;

local tinsert = _G.tinsert;

local InCombatLockdown = _G.InCombatLockdown;
local hooksecurefunc = _G.hooksecurefunc;

local inCombatCallbacks = {};

addon.on('PLAYER_REGEN_ENABLED', function ()
  for callback, paramList in pairs(inCombatCallbacks) do
    for _, params in ipairs(paramList) do
      callback(unpack(params));
    end
  end
end);

local function addCallbackToCombatQueue (callback, ...)
  if (inCombatCallbacks[callback] == nil) then
    inCombatCallbacks[callback] = {{...}};
  else
    tinsert(inCombatCallbacks[callback], {...});
  end
end

local function callSafe (callback, ...)
  if (InCombatLockdown()) then
    addCallbackToCombatQueue(callback, ...);
  else
    callback(...);
  end
end

local function callFrameSafe (callback, frame, ...)
  if (InCombatLockdown() and frame:IsProtected()) then
    addCallbackToCombatQueue(callback, frame, ...);
  else
    callback(frame, ...);
  end
end

local function createCombatFrameHook (callback)
  return function (frame, ...)
    callFrameSafe(callback, frame, ...);
  end
end

local function createCombatCallback (callback)
  return function (...)
    callSafe(callback, ...);
  end
end

function addon.hookScriptSafe (frame, script, callback)
  frame:HookScript(script, createCombatFrameHook(callback));
end

function addon.hookSafe (...)
  if (select('#', ...) >= 3) then
    local frame, script, callback = ...;

    hooksecurefunc(frame, script, createCombatFrameHook(callback));
  else
    local script, callback = ...;

    hooksecurefunc(script, createCombatFrameHook(callback));
  end
end

function addon.onSafe (event, callback)
  addon.on(event, createCombatCallback(callback));
end

function addon.onOnceSafe (event, callback)
  addon.onOnce(event, createCombatCallback(callback));
end

addon.createCombatCallback = createCombatCallback;
