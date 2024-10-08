local _, addon = ...;

local strfind = _G.strfind;

local InCombatLockdown = _G.InCombatLockdown;
local IsAddOnLoaded = _G.C_AddOns.IsAddOnLoaded;
local GetAddOnEnableState = _G.C_AddOns.GetAddOnEnableState;

local UIParent = _G.UIParent;
local SetPoint = UIParent.SetPoint;

local LEFTBUTTON = 'LeftButton';
local MIDDLEBUTTON = 'MiddleButton';

local PLAYER_NAME = _G.UnitName('player');

local saved = addon.saved;
local draggedFrames = {};
local frameGroups = addon.frameGroups;

local SCALING_ENABLED = false;

saved.framePositions = saved.framePositions or {};
saved.frameScales = saved.frameScales or {};

local function debug (...)
  print(...);
end

local function findFrame (frame)
  if (type(frame) == 'string') then
    return _G[frame];
  else
    return frame;
  end
end

local function getFrameGroup (frame)
  return frameGroups[frame:GetName()] or frame:GetName();
end

local function dragFrame (frame)
  if (draggedFrames[frame]) then
    return;
  end

  frame:SetMovable(true);
  draggedFrames[frame] = true;
  frame:StartMoving();
end

local function setFramePosition (frame, ...)
  frame:ClearAllPoints();
  SetPoint(frame, ...);
end

local function getCenteredPoints (frame)
  local points = {frame:GetCenter()};

  return {
    x = points[1] * frame:GetEffectiveScale(),
    y = points[2] * frame:GetEffectiveScale(),
  };
end

local function transformFrameAnchors (frame)
  local points = getCenteredPoints(frame);
  local parentPoints = getCenteredPoints(UIParent);

  return {
    'CENTER',
    nil,
    'CENTER',
    (points.x - parentPoints.x) / frame:GetEffectiveScale(),
    (points.y - parentPoints.y) / frame:GetEffectiveScale(),
  };
end

local function storeFramePosition (frame)
  saved.framePositions[getFrameGroup(frame)] = transformFrameAnchors(frame);
end

local function stopDraggingFrame (frame)
  if (not draggedFrames[frame]) then
    return;
  end

  frame:SetMovable(false);
  frame:StopMovingOrSizing();
  draggedFrames[frame] = nil;
  storeFramePosition(frame);
end

local function restoreFramePosition (frame)
  local points = saved.framePositions[getFrameGroup(frame)];

  if (not points) then
    return;
  end

  local success, error = pcall(setFramePosition, frame, unpack(points));

  if (not success) then
    debug('Encountered error when moving frame:', frame:GetName());
    debug(error);
    saved.framePositions[getFrameGroup(frame)] = nil;
  end
end

local function lockFrame (frame)
  addon.hookSafe(frame, 'SetPoint', restoreFramePosition);
end

local function restoreFrameScale (frame)
  local scale = saved.frameScales[getFrameGroup(frame)];

  if (not scale) then
    return;
  end

  frame:SetScale(scale);
end

local function restoreFrame (frame)
  restoreFramePosition(frame);

  if (SCALING_ENABLED) then
    restoreFrameScale(frame);
  end
end

local function handleMouseDown (frame, button)
  if (button == LEFTBUTTON) then
    dragFrame(frame);
  elseif (button == MIDDLEBUTTON) then
    frame:SetScale(1);
    saved.frameScales[getFrameGroup(frame)] = nil;
  end
end

local function handleMouseUp (frame, button)
  if (button == LEFTBUTTON) then
    stopDraggingFrame(frame);
  end
end

local function handleMouseWheel (frame, delta)
  if (frame:IsProtected() and InCombatLockdown()) then
    return;
  end

  local newScale = frame:GetScale() + delta * 0.05;

  frame:SetScale(newScale);
  saved.frameScales[getFrameGroup(frame)] = newScale;
end

local function addMouseWheelListener (frame)
  if (frame.NineSlice ~= nil or
      frame:GetScript('OnMouseWheel') ~= nil) then return end

  addon.hookScriptSafe(frame, 'OnMouseWheel', handleMouseWheel);
end

local function initFrame (frame)
  frame:SetClampedToScreen(true);
  restoreFrame(frame);
  frame:HookScript('OnMouseDown', handleMouseDown);
  frame:HookScript('OnMouseUp', handleMouseUp);

  if (SCALING_ENABLED) then
    addMouseWheelListener(frame);
  end

  addon.hookScriptSafe(frame, 'OnShow', restoreFramePosition);
  lockFrame(frame);
end

local function forAddonFrame (frameName, callback)
  local frame = findFrame(frameName);

  if (frame == nil) then
    debug('could not find frame:', frameName);
    return;
  end

  callback(frame);
end

local function forEachAddonFrame (frameList, callback)
  if (frameList == nil) then
    return;
  end

  if (type(frameList) == 'table') then
    for _, frameName in ipairs(frameList) do
      forAddonFrame(frameName, callback);
    end
  else
    forAddonFrame(frameList, callback);
  end
end

local function restoreAddonFrames (loadedAddon)
  forEachAddonFrame(addon.frames[loadedAddon], initFrame);
end

local function removeAddonInfo (addonName)
  addon.frames[addonName] = nil;
end

local function handleAddon (addonName)
  addon.patch(addonName);
  restoreAddonFrames(addonName);
  removeAddonInfo(addonName);
end

local function hasAddOnFinishedLoading (addonName)
  return select(2, IsAddOnLoaded(addonName));
end

local function isAddonEnabled (addonName)
  return (GetAddOnEnableState(PLAYER_NAME, addonName) == 2);
end

local function isBlizzardAddon (addonName)
  return (strfind(addonName, 'Blizzard_', 1, true) == 1);
end

local function checkLoadedAddons ()
  for addonName in pairs(addon.frames) do
    if (hasAddOnFinishedLoading(addonName)) then
      handleAddon(addonName);
    end
  end
end

local function checkDisabledAddons ()
  for addonName in pairs(addon.frames) do
    if (not isAddonEnabled(addonName) and not isBlizzardAddon(addonName)) then
      removeAddonInfo(addonName);
    end
  end
end

local function areAddonsPending ()
  return (next(addon.frames) ~= nil);
end

addon.onOnceSafe('PLAYER_LOGIN', function ()
  checkLoadedAddons();
  checkDisabledAddons();

  if (not areAddonsPending()) then
    return;
  end

  local handler;

  handler = addon.createCombatCallback(function (addonName)
    handleAddon(addonName);

    if (not areAddonsPending()) then
      addon.off('ADDON_LOADED', handler);
    end
  end);

  addon.on('ADDON_LOADED', handler);
end);
