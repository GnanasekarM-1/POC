import store from "store";

export const MEMBER_NAME = "Name";
export const DEFAULT_START_DATE = "defaultStartDate";
export const DEFAULT_END_DATE = "defaultEndDate";
export const EVENT_START_DATE = "eventsStartDate";
export const EVENT_END_DATE = "eventsEndDate";

let schedulerState;
const loadSchedulerState = () => {
  const state = store.getState();
  const { schedulerState: currentState } = state;
  return currentState;
};

export const getSchedulerState = (key, defValue) => {
  let value = defValue;
  schedulerState = loadSchedulerState();
  if (schedulerState && schedulerState[key]) {
    value = schedulerState[key];
  }
  return value;
};
