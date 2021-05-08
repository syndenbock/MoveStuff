local addonName, addon = ...;

local InCombatLockdown = _G.InCombatLockdown;
local IsAddOnLoaded = _G.IsAddOnLoaded;

local hooksecurefunc = _G.hooksecurefunc;
local UIParent = _G.UIParent;
local SetPoint = UIParent.SetPoint;

local LEFTBUTTON = 'LeftButton';
local MIDDLEBUTTON = 'MiddleButton';

local saved = addon.saved;
local draggedFrames = {};
local frameGroups = addon.frameGroups;

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

local function transformFrameAnchors (frame)
  local points = {frame:GetCenter()};
  local parentPoints = {UIParent:GetCenter()};

  return {
    'CENTER',
    nil,
    'CENTER',
    points[1] - parentPoints[1],
    points[2] - parentPoints[2],
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
  hooksecurefunc(frame, 'SetPoint', restoreFramePosition);
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
  restoreFrameScale(frame);
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

  addon.hookScriptSecure(frame, 'OnMouseWheel', handleMouseWheel);
end

local function initFrame (frame)
  frame:SetClampedToScreen(true);
  restoreFrame(frame);
  frame:HookScript('OnMouseDown', handleMouseDown);
  frame:HookScript('OnMouseUp', handleMouseUp);
  addMouseWheelListener(frame);

  addon.hookScriptSecure(frame, 'OnShow', restoreFramePosition);
  lockFrame(frame);
end

local function clearConflictFrame (frame)
  frame:ClearAllPoints();
end

local function forEachAddonFrame (frameMap, loadedAddon, callback)
  local frameList = frameMap[loadedAddon];

  if (frameList == nil) then
    return;
  end

  if (type(frameList) ~= 'table') then
    frameList = {frameList};
  end

  for _, frameName in ipairs(frameList) do
    local frame = findFrame(frameName);

    if (frame) then
      callback(frame);
    else
      debug('could not find frame:', frameName);
    end
  end

  frameMap[loadedAddon] = nil;
end

local function restoreAddonFrames (loadedAddon)
  forEachAddonFrame(addon.frames, loadedAddon, initFrame);
end

local function clearConflictFrames (loadedAddon)
  forEachAddonFrame(addon.conflictFrames, loadedAddon, clearConflictFrame);
end

local function handleAddonLoad (loadedAddon)
  restoreAddonFrames(loadedAddon);
  clearConflictFrames(loadedAddon);
end

local function hasAddOnFinishedLoading (name)
  return select(2, IsAddOnLoaded(name));
end

local function checkLoadedAddons ()
  for name in pairs(addon.frames) do
    if (hasAddOnFinishedLoading(name)) then
      handleAddonLoad(name);
    end
  end
end

addon.on('PLAYER_LOGIN', function ()
  handleAddonLoad(addonName);
  checkLoadedAddons();

  addon.on('ADDON_LOADED', function (loadedAddon)
    if (loadedAddon ~= addonName) then
      handleAddonLoad(loadedAddon);
    end
  end);
end);
