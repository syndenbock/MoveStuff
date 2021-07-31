local addonName, addon = ...;

local GROUP_GOSSIP = 'GROUP_GOSSIP';

addon.frameGroups = {
  GossipFrame = GROUP_GOSSIP,
  QuestFrame = GROUP_GOSSIP,
};

addon.frames = {
  [addonName] = {
    'CharacterFrame',
    'DressUpFrame',
    'FriendsFrame',
    'GossipFrame',
    'ItemTextFrame',
    'LootFrame',
    'MailFrame',
    'MerchantFrame',
    'PetStableFrame',
    'PVEFrame',
    'QuestFrame',
    'SpellBookFrame',
    'TaxiFrame',
    'TradeFrame',
    'UIWidgetBelowMinimapContainerFrame',
    'WorldMapFrame',
  },
  Blizzard_AchievementUI = 'AchievementFrame',
  Blizzard_AuctionHouseUI = 'AuctionHouseFrame',
  Blizzard_AzeriteRespecUI = 'AzeriteRespecFrame',
  Blizzard_AzeriteUI = 'AzeriteEmpoweredItemUI',
  Blizzard_Calendar = 'CalendarFrame',
  Blizzard_Collections = {
    'CollectionsJournal',
    'WardrobeFrame',
  },
  Blizzard_CovenantSanctum = 'CovenantSanctumFrame',
  Blizzard_CovenantRenown = 'CovenantRenownFrame',
  Blizzard_Communities = 'CommunitiesFrame',
  Blizzard_EncounterJournal = 'EncounterJournal',
  Blizzard_GarrisonUI = {
    'CovenantMissionFrame',
    'GarrisonCapacitiveDisplayFrame',
    'GarrisonLandingPage',
  },
  Blizzard_GuildBankUI = 'GuildBankFrame',
  Blizzard_InspectUI = 'InspectFrame',
  Blizzard_ItemSocketingUI = 'ItemSocketingFrame',
  Blizzard_ItemUpgradeUI = 'ItemUpgradeFrame',
  Blizzard_MacroUI = 'MacroFrame',
  Blizzard_OrderHallUI = 'OrderHallTalentFrame',
  Blizzard_RuneforgeUI = 'RuneforgeFrame',
  Blizzard_ScrappingMachineUI =  'ScrappingMachineFrame',
  Blizzard_Soulbinds = 'SoulbindViewer',
  Blizzard_TalentUI = 'PlayerTalentFrame',
  Blizzard_TalkingHeadUI = 'TalkingHeadFrame',
  Blizzard_TradeSkillUI = 'TradeSkillFrame',
  Blizzard_TrainerUI = 'ClassTrainerFrame',
  Blizzard_VoidStorageUI = 'VoidStorageFrame',
  ElvUI = {
    'ElvUI_BankContainerFrame',
    'ElvUI_ContainerFrame',
  }
};

addon.conflictFrames = {
  Blizzard_EncounterJournal = 'EncounterJournalTooltip',
};
