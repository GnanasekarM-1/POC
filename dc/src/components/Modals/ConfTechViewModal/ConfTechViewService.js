const confTechViewService = {};
let modifiedUserSettings = {};
let modifiedOperands = null;
let activeRuleIndex = NaN;
let isRuleModified = false;
let rulesAfterDeletion = null;

confTechViewService.getmodifiedUserSettings = () => modifiedUserSettings;

confTechViewService.setmodifiedUserSettings = settings => {
  if (!settings) {
    modifiedUserSettings = {};
    return;
  }
  modifiedUserSettings = { ...modifiedUserSettings, ...settings };
};

confTechViewService.getModifiedOperands = () => modifiedOperands;

confTechViewService.setModifiedOperands = operands => {
  modifiedOperands = operands;
};

confTechViewService.getActiveRuleIndex = () => activeRuleIndex;

confTechViewService.setActiveRuleIndex = index => {
  activeRuleIndex = index;
};

confTechViewService.getIsRuleModified = () => isRuleModified;

confTechViewService.setIsRuleModified = value => {
  isRuleModified = value;
};

confTechViewService.getRulesAfterDeletion = () => rulesAfterDeletion;

confTechViewService.setRulesAfterDeletion = colorRules => {
  rulesAfterDeletion = colorRules;
};

export default confTechViewService;
