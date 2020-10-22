import { UPDATE_GRID_STATE } from "constants/ActionConstants";

export function gridStateChanged(value, type, config) {
  if (config) {
    return { changed: value, config, type };
  }
  return { changed: value, type };
}

export function reducer(state = null, action) {
  const { config = undefined, changed = {}, type } = action;
  // const { page } = changed;
  switch (type) {
    case UPDATE_GRID_STATE:
      if (config) {
        const deleteKeys = config["-"];
        if (deleteKeys && deleteKeys.length) {
          deleteKeys.map(deleteKey => {
            // eslint-disable-next-line no-param-reassign
            delete state[`${deleteKey}`];
            return undefined;
          });
        }
      }
      return { ...state, ...changed };
    default:
      return state;
  }
}
