export const newRelicMiddleware = ({ getState }) => next => action => {
  const { enableUsageStats = "Disallow" } = window.configData || {};
  const trackUsageStats = enableUsageStats === "Allow";
  if (
    process.env.NODE_ENV !== "development" &&
    trackUsageStats &&
    window.newrelic
  ) {
    const { type } = action;
    window.newrelic.addPageAction(type);
  }
  return next(action);
};
