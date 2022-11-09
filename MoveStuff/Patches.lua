local _, addon = ...;

local patches = {
  Blizzard_Collections = function ()
    local checkBox = _G.WardrobeTransmogFrame.ToggleSecondaryAppearanceCheckbox;
    local label = checkBox.Label;

    label:ClearAllPoints();
    label:SetPoint('LEFT', checkBox, 'RIGHT', 2, 1);
    label:SetPoint('RIGHT', checkBox, 'RIGHT', 160, 1);
  end,
  Blizzard_Communities = function ()
    local dialog = _G.CommunitiesFrame.NotificationSettingsDialog;

    if (dialog) then
      dialog:ClearAllPoints();
      dialog:SetAllPoints();
    end
  end,
  Blizzard_EncounterJournal = function ()
    _G.EncounterJournalTooltip:ClearAllPoints();
  end,
  ElvUI = function ()
    _G.MailFrameInset.SetPoint = _G.MailFrameInset.ClearAllPoints;
    _G.OpenMailFrameInset.SetPoint = _G.OpenMailFrameInset.ClearAllPoints;
  end
};

function addon.patch (addonName)
  if (patches[addonName] == nil) then return end

  patches[addonName]();
  patches[addonName] = nil;
end
