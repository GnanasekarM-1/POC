import React, { Component } from "react";
import PropTypes from "prop-types";
import { Grid, GridRow, GridItem } from "@svmx/ui-components-lightning";
import ConfigureQueueModal from "components/Modals/ConfigureQueueModal";
import ActivityModal from "components/Modals/ActivityModal";
import { TAG071, TAG077 } from "constants/DisplayTagConstants";
import { getDisplayValue } from "utils/DCUtils";
import { DISPLAY, NAME } from "constants/AppConstants";
import { cloneDeep, orderBy, isEqual, transform, isObject } from "lodash";
import View from "./View";
import Filter from "./Filter";
import Status from "./Status";
import WOConfigure from "./WOConfigure";

import "./GridViewToolbar.scss";

class GridViewToolbar extends Component {
  state = { isActivityOpen: false, isSettingOpen: false };

  handleClick = btnName => {
    if (btnName === "activity") {
      this.setState({ isActivityOpen: true });
    } else {
      this.setState({ isSettingOpen: true });
    }
  };

  handleSaveClick = () => {
    const { saveUserSettings } = this.props;
    setTimeout(() => saveUserSettings(), 0);
  };

  handleHide = () => {
    this.setState({ isActivityOpen: false, isSettingOpen: false });
  };

  difference = (object, base) => {
    // eslint-disable-next-line no-shadow
    function changes(object, base) {
      return transform(object, (result, value, key) => {
        if (!isEqual(value, base[key])) {
          // eslint-disable-next-line no-param-reassign
          result[key] =
            isObject(value) && isObject(base[key])
              ? changes(value, base[key])
              : value;
        }
      });
    }
    return changes(object, base);
  };

  isUserSettingDirty = () => {
    const text = sessionStorage.getItem("LastSaved");
    const oldSettings = JSON.parse(text || {});
    const { userSettings } = this.props;
    const dirty = !isEqual(oldSettings, userSettings);
    if (dirty) {
      console.log(this.difference(oldSettings, userSettings));
    }
    return dirty;
  };

  render() {
    const {
      clearFilter,
      defaultViewChanged,
      dispatch,
      filterColumnChanged,
      filterTextChanged,
      gridColorRuleChanged,
      gridColumnChanged,
      gridState,
      loading,
      resetForm,
      statusFilterChanged,
      submitForm,
      userSettings,
      userTimezone,
      viewCount,
      views,
      updateAppStatus,
      viewSelectionChanged,
      woFieldObj,
      filterDetail
    } = this.props;

    const { view } = gridState;
    const {
      wo_autorefresh: autorefresh,
      wo_defaultView: defaultView,
      wo_refreshtime: refreshtime,
      wo_viewCounter: viewCounter = [],
      wo_woCol: woCol = []
    } = userSettings;

    const { isActivityOpen, isSettingOpen } = this.state;
    const woFields = cloneDeep(woFieldObj);
    const nameObj = woFields[NAME];
    if (nameObj) {
      nameObj.locked = true;
    }
    const targetValues = [];
    const sourceItems = orderBy(Object.values(woFields), [DISPLAY]);
    const sourceItems1 = orderBy(Object.values(woFieldObj), [DISPLAY]);
    if (woCol) {
      woCol.map(col => {
        const { name } = col;
        if (woFields[name] && !targetValues.includes(name)) {
          targetValues.push(name);
        }
      });
    }
    return (
      <Grid>
        <GridRow className="GridViewToolbar">
          <GridItem className="GridViewToolbar__Layout-center" noFlex>
            <View
              views={views}
              counters={cloneDeep(viewCounter)}
              viewCount={viewCount}
              view={view}
              loading={loading}
              defaultViewChanged={defaultViewChanged}
              viewSelectionChanged={viewSelectionChanged}
              defaultView={defaultView}
            />
          </GridItem>
          <GridItem className="GridViewToolbar__Layout-center" noFlex padded>
            <Filter
              clearFilter={clearFilter}
              view={view}
              loading={loading}
              userSettings={userSettings}
              userTimezone={userTimezone}
              woFieldObj={woFieldObj}
              filterColumnChanged={filterColumnChanged}
              filterTextChanged={filterTextChanged}
              filterDetail={filterDetail}
              updateAppStatus={updateAppStatus}
            />
          </GridItem>
          <GridItem className="GridViewToolbar__Layout-center" noFlex>
            <Status
              loading={loading}
              statusFilterChanged={statusFilterChanged}
            />
          </GridItem>
          <GridItem />
          <GridItem
            noFlex
            padded
            className="GridViewToolbar__Layout-center GridViewToolbar__setting-container"
          >
            <WOConfigure
              autorefresh={JSON.parse(autorefresh)}
              handleClick={this.handleClick}
              loading={loading}
              refreshtime={parseInt(refreshtime, 10)}
              view={view}
              viewSelectionChanged={viewSelectionChanged}
              saveUserSettings={this.handleSaveClick}
              isUserSettingDirty={this.isUserSettingDirty()}
            />
          </GridItem>
        </GridRow>
        {isSettingOpen && (
          <ConfigureQueueModal
            autorefresh={JSON.parse(autorefresh)}
            refreshtime={parseInt(refreshtime, 10)}
            header={getDisplayValue(TAG077)}
            isOpen={isSettingOpen}
            handleHide={this.handleHide}
            handleDone={gridColumnChanged}
            sourceItems={sourceItems}
            targetValues={targetValues}
          />
        )}
        {isActivityOpen && (
          <ActivityModal
            header={getDisplayValue(TAG071)}
            isOpen={isActivityOpen}
            handleHide={this.handleHide}
            onSave={gridColorRuleChanged}
            sourceItems={sourceItems1}
            userSettings={userSettings}
            views={views}
            dispatch={dispatch}
            resetForm={resetForm}
            submitForm={submitForm}
          />
        )}
      </Grid>
    );
  }
}

GridViewToolbar.propTypes = {
  clearFilter: PropTypes.func.isRequired,
  defaultViewChanged: PropTypes.func.isRequired,
  dispatch: PropTypes.func.isRequired,
  filterColumnChanged: PropTypes.func.isRequired,
  filterTextChanged: PropTypes.func.isRequired,
  loading: PropTypes.bool,
  gridColorRuleChanged: PropTypes.func.isRequired,
  gridColumnChanged: PropTypes.func.isRequired,
  gridState: PropTypes.shape({}).isRequired,
  resetForm: PropTypes.func.isRequired,
  saveUserSettings: PropTypes.func.isRequired,
  statusFilterChanged: PropTypes.func.isRequired,
  submitForm: PropTypes.func.isRequired,
  userSettings: PropTypes.shape({}).isRequired,
  viewCount: PropTypes.shape({}).isRequired,
  views: PropTypes.arrayOf(PropTypes.shape({})).isRequired,
  viewSelectionChanged: PropTypes.func.isRequired,
  woFieldObj: PropTypes.shape({}).isRequired,
  filterDetail: PropTypes.shape({}).isRequired
};

export default GridViewToolbar;
