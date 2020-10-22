const activityModalService = {};

let modifiedColorRules = [];

let modifiedOperands = null;

let rulesAfterDeletion = null;

let activeRuleIndex = NaN;

let hoverColor = null;

let selectionColor = null;

let modifiedViewCounter = null;

let isRuleModified = false;

activityModalService.getModifiedColorRules = () => modifiedColorRules;

activityModalService.setModifiedColorRules = colorRules => {
  modifiedColorRules = colorRules;
};

activityModalService.getModifiedOperands = () => modifiedOperands;

activityModalService.setModifiedOperands = operands => {
  modifiedOperands = operands;
};

activityModalService.getRulesAfterDeletion = () => rulesAfterDeletion;

activityModalService.setRulesAfterDeletion = colorRules => {
  rulesAfterDeletion = colorRules;
};

activityModalService.getActiveRuleIndex = () => activeRuleIndex;

activityModalService.setActiveRuleIndex = index => {
  activeRuleIndex = index;
};

activityModalService.getModifiedHoverColor = () => hoverColor;

activityModalService.setModifiedHoverColor = color => {
  hoverColor = color;
};

activityModalService.getModifiedSelectionColor = () => selectionColor;

activityModalService.setModifiedSelectionColor = color => {
  selectionColor = color;
};

activityModalService.getModifiedViewCounter = () => modifiedViewCounter;

activityModalService.setModifiedViewCounter = viewCounter => {
  modifiedViewCounter = viewCounter;
};

activityModalService.getIsRuleModified = () => isRuleModified;

activityModalService.setIsRuleModified = value => {
  isRuleModified = value;
};

export default activityModalService;
