const UnScheduledDurationService = {};

let duration = null;

let woInfo = null;

let woId = null;

UnScheduledDurationService.getWOInfo = () => woInfo;

UnScheduledDurationService.setWOInfo = value => {
  woInfo = value;
};

UnScheduledDurationService.getSelectedWOId = () => woId;

UnScheduledDurationService.setSelectedWOId = value => {
  woId = value;
};

export default UnScheduledDurationService;
