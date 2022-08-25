local _, addon = ...;

local patches = {
  Blizzard_Collections = function ()
    local checkBox = _G.WardrobeTransmogFrame.ToggleSecondaryAppearanceCheckbox;
    local label = checkBox.Label;

    label:ClearAllPoints();
    label:SetPoint('LEFT', checkBox, 'RIGHT', 2, 1);
    label:SetPoint('RIGHT', checkBox, 'RIGHT', 160, 1);
  end,
  Blizzard_EncounterJournal = function ()
    _G.EncounterJournalTooltip:ClearAllPoints();
  end
};

function addon.patch (addonName)
  if (patches[addonName] == nil) then return end

  patches[addonName]();
  patches[addonName] = nil;
end
