import React, { Component } from "react";
import PropTypes from "prop-types";
import { Grid, GridRow, GridItem } from "@svmx/ui-components-lightning";
import {
  TEAM_INDEX,
  CONFIGURE_TECH_VIEW,
  CONFIGURE_TECH_TEAM_SEARCH
} from "constants/AppConstants";
import { getDisplayValue } from "utils/DCUtils";
import ConfTechViewModal from "components/Modals/ConfTechViewModal";
import TeamAndTechnicianSearchModel from "components/Modals/TeamAndTechnicianSearchModel";
import { TAG043, TAG058 } from "constants/DisplayTagConstants";
import AdvancedSearch from "./AdvancedSearch";
import SchedulerTechnicianSearch from "./SchedulerTechnicianSearch";
import FilterTechnician from "./FilterTechnician";
import Reset from "./Reset";
import DateRange from "./DateRange";
import Zoom from "./Zoom";
import TimeZoneBtn from "./TimeZoneBtn";
import SchedulerConfig from "./SchedulerConfig";
import AddAndDeleteEvent from "./AddAndDeleteEvent";
import "./SchedulerToolbar.scss";

class SchedulerToolbar extends Component {
  state = { isTechTeamSearchOpen: false, isTechViewOpen: false };

  handleOpenModel = btnName => {
    if (btnName === CONFIGURE_TECH_VIEW) {
      this.setState({ isTechViewOpen: true });
    } else if (btnName === CONFIGURE_TECH_TEAM_SEARCH) {
      this.setState({ isTechTeamSearchOpen: true });
    }
  };

  handleHide = () => {
    this.setState({ isTechTeamSearchOpen: false, isTechViewOpen: false });
  };

  handleSchedulerReset = () => {
    this.SchedulerTechSearch.handleSearchTxtReset();
    const { onSchedulerReset } = this.props;
    if (onSchedulerReset) {
      onSchedulerReset();
    }
  };

  handleMapSetting = () => {
    this.SchedulerTechConfig.handleMapSetting(true);
  };

  isEmptyResults = () => {
    const { activeView, teamView, territoryView } = this.props;
    return activeView === TEAM_INDEX
      ? teamView.length === 0
      : territoryView.length === 0;
  };

  render() {
    const {
      applyATS,
      applyTimeZone,
      eventsEndDate,
      eventsStartDate,
      filterTechnicians,
      filterWorkOrderEvents,
      handleEndDateChange,
      handleProjectView,
      handleStartDateChange,
      handleResetTime,
      handleViewZoomIn,
      handleViewZoomOut,
      loading,
      onMapConfig,
      onSave,
      onSearchChange,
      onTechConfigChange,
      newViewState,
      selectedWO,
      gridActive,
      startEventCall,
      submitForm,
      timeZones,
      updateAppStatus,
      userTimezone,
      userSettings,
      onSchedulerReset,
      zoomInState,
      zoomOutState,
      woFields
    } = this.props;
    const { isTechViewOpen, isTechTeamSearchOpen } = this.state;
    return (
      <Grid>
        <GridRow className="SchedulerToolbar">
          <SchedulerTechnicianSearch
            onSchedulerTechSearchChildRef={SchedulerTechSearch => {
              this.SchedulerTechSearch = SchedulerTechSearch;
              return undefined;
            }}
            woFields={woFields}
            loading={loading}
            selectedWO={selectedWO}
            gridActive={gridActive}
            userTimezone={userTimezone}
            onSearchChange={onSearchChange}
            handleSettingClick={this.handleOpenModel}
            onHandleMapSetting={this.handleMapSetting}
            onSchedulerReset={onSchedulerReset}
          />
          <AdvancedSearch
            loading={loading}
            selectedWO={selectedWO}
            applyATS={applyATS}
            updateAppStatus={updateAppStatus}
          />
          <FilterTechnician
            loading={loading}
            newViewState={newViewState}
            filterTechnicians={filterTechnicians}
            filterWorkOrderEvents={filterWorkOrderEvents}
          />
          <Reset
            loading={loading}
            newViewState={newViewState}
            onSchedulerReset={this.handleSchedulerReset}
          />
          <DateRange
            loading={loading}
            eventsEndDate={eventsEndDate}
            eventsStartDate={eventsStartDate}
            handleStartDateChange={handleStartDateChange}
            handleEndDateChange={handleEndDateChange}
            startEventCall={startEventCall}
          />
          <Zoom
            loading={loading}
            isEmpty={this.isEmptyResults}
            handleProjectView={handleProjectView}
            handleResetTime={handleResetTime}
            handleViewZoomIn={handleViewZoomIn}
            handleViewZoomOut={handleViewZoomOut}
            newViewState={newViewState}
            zoomInState={zoomInState}
            zoomOutState={zoomOutState}
          />
          <TimeZoneBtn
            loading={loading}
            applyTimeZone={applyTimeZone}
            timeZones={timeZones}
            userTimezone={userTimezone}
          />
          <AddAndDeleteEvent {...this.props} />
          <GridItem />
          <SchedulerConfig
            onSchedulerTechConfiChildRef={SchedulerTechConfig => {
              this.SchedulerTechConfig = SchedulerTechConfig;
              return undefined;
            }}
            loading={loading}
            onMapConfig={onMapConfig}
            handleButtonClick={this.handleOpenModel}
          />
        </GridRow>
        {isTechTeamSearchOpen && (
          <TeamAndTechnicianSearchModel
            header={getDisplayValue(TAG043)}
            isOpen={isTechTeamSearchOpen}
            handleHide={this.handleHide}
          />
        )}
        {isTechViewOpen && (
          <ConfTechViewModal
            header={getDisplayValue(TAG058)}
            isOpen={isTechViewOpen}
            handleHide={this.handleHide}
            onSave={onSave}
            onTechConfigChange={onTechConfigChange}
            submitForm={submitForm}
            userTimezone={userTimezone}
            userSettings={userSettings}
          />
        )}
      </Grid>
    );
  }
}

SchedulerToolbar.propTypes = {
  applyATS: PropTypes.func.isRequired,
  applyTimeZone: PropTypes.func.isRequired,
  eventsEndDate: PropTypes.string.isRequired,
  eventsStartDate: PropTypes.string.isRequired,
  filterTechnicians: PropTypes.string.isRequired,
  filterWorkOrderEvents: PropTypes.string.isRequired,
  handleEndDateChange: PropTypes.func.isRequired,
  handleProjectView: PropTypes.func.isRequired,
  handleResetTime: PropTypes.func.isRequired,
  handleStartDateChange: PropTypes.func.isRequired,
  handleViewZoomIn: PropTypes.func.isRequired,
  handleViewZoomOut: PropTypes.func.isRequired,
  onMapConfig: PropTypes.func.isRequired,
  onSave: PropTypes.func.isRequired,
  onSchedulerReset: PropTypes.func.isRequired,
  onSearchChange: PropTypes.func.isRequired,
  onTechConfigChange: PropTypes.func.isRequired,
  newViewState: PropTypes.number.isRequired,
  selectedWO: PropTypes.shape({}).isRequired,
  startEventCall: PropTypes.func.isRequired,
  submitForm: PropTypes.func.isRequired,
  timeZones: PropTypes.arrayOf(PropTypes.object).isRequired,
  updateAppStatus: PropTypes.func.isRequired,
  userSettings: PropTypes.shape({}).isRequired,
  userTimezone: PropTypes.shape({}).isRequired
};

export default SchedulerToolbar;
