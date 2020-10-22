import { combineReducers } from "redux";
import { reducer as formReducer } from "redux-form";
import { reducer as MetaDataReducer } from "actions/MetaDataAction";
import { reducer as ViewReducer } from "actions/ViewDataAction";
import { reducer as WorkOrderReducer } from "actions/WorkOrderAction";
import { reducer as GridStateReducer } from "actions/GridViewAction";
import { reducer as UserSettingReducer } from "actions/UserSettingAction";
import { reducer as TechnicianReducer } from "actions/TechnicianAction";
import { reducer as EventsReducer } from "actions/EventsAction";
import { reducer as AppStatusReducer } from "actions/AppStatusAction";
import { reducer as SchedulerAction } from "actions/SchedulerAction";
import { reducer as DeployUserSettings } from "actions/DeployUserSettingsAction";

export default function makeReducer() {
  return combineReducers({
    appStatus: AppStatusReducer,
    deployusersettings: DeployUserSettings,
    eventsData: EventsReducer,
    form: formReducer,
    gridState: GridStateReducer,
    metaData: MetaDataReducer,
    schedulerState: SchedulerAction,
    technicianData: TechnicianReducer,
    userSettings: UserSettingReducer,
    viewData: ViewReducer,
    workOrderData: WorkOrderReducer
  });
}
