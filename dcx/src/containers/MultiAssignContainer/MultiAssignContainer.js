import React from "react";
import PropTypes from "prop-types";
import { Grid, GridRow, GridItem } from "@svmx/ui-components-lightning";
import TreeView from "components/MultiAssign/TreeView";
import WorkOrderDetail from "components/MultiAssign/WorkOrder/WorkOrderDetail";
import { DEFAULT_TREE_DATA, TEAM_SEARCH_RESULT } from "constants/AppConstants";

const MultiAssignContainer = props => {
  const {
    eventSubject,
    rows,
    newViewState,
    handleSearchChange,
    hasPastEvents,
    showPastEvents,
    handlePastEventChange,
    selectAllRows,
    handleRowSelection,
    handleSelectAllRows,
    allDayEvent,
    handleDayEventSelection,
    handleAllDayEvent,
    isDisabled,
    isOwner,
    ownerName,
    subject,
    handleOwnerChange,
    handleRemoveRow,
    handleSubjectChange,
    updateScheduleDate,
    handleRemoveSelectedRows,
    handleFieldUpdates,
    handleEditSchedule,
    isOverLappingRecord,
    getOverLappingBgColor,
    isDayEvent,
    isRowSelected,
    onSelection,
    selections,
    selectedWO,
    selectedIndex,
    teamView,
    territoryView,
    fullTeamView,
    fullTerritoryView,
    teamIds,
    techFields,
    technicians,
    territoryList,
    searchTechnicians,
    userSettings
  } = props;

  const convertToActualViewState = activeState => {
    let newStateValue = activeState;
    const sign = Math.sign(activeState);
    if (sign < 0) {
      if (activeState < -100) {
        newStateValue = activeState + 100;
      }
    } else if (activeState > 100) {
      newStateValue = activeState - 100;
    }
    return newStateValue;
  };

  const activeViewState = convertToActualViewState(newViewState);

  return (
    <Grid>
      <GridRow className="MultipleAssignmentModal__content_GridRow">
        <GridItem className="MultipleAssignmentModal__content-leftPanel">
          <TreeView
            teamView={teamView}
            fullTeamView={fullTeamView}
            techFields={techFields}
            territoryView={territoryView}
            fullTerritoryView={fullTerritoryView}
            isDisabled={isDisabled}
            selectedIndex={selectedIndex}
            teamIds={teamIds}
            technicians={technicians}
            territoryList={territoryList}
            onSelection={onSelection}
            userSettings={userSettings}
            searchTechnicians={searchTechnicians}
            snapshotTree={
              activeViewState > 0 && activeViewState !== DEFAULT_TREE_DATA
            }
            expandValues={
              activeViewState > 0 && activeViewState !== TEAM_SEARCH_RESULT
            }
          />
        </GridItem>
        <GridItem className="MultipleAssignmentModal__content-rightPanel">
          <WorkOrderDetail
            eventSubject={eventSubject}
            selectedWO={selectedWO}
            selections={selections}
            rows={rows}
            updateScheduleDate={updateScheduleDate}
            handleSearchChange={handleSearchChange}
            hasPastEvents={hasPastEvents}
            showPastEvents={showPastEvents}
            handlePastEventChange={handlePastEventChange}
            selectAllRows={selectAllRows}
            handleRowSelection={handleRowSelection}
            handleSelectAllRows={handleSelectAllRows}
            allDayEvent={allDayEvent}
            handleDayEventSelection={handleDayEventSelection}
            handleSubjectChange={handleSubjectChange}
            handleAllDayEvent={handleAllDayEvent}
            isDisabled={isDisabled}
            isOwner={isOwner}
            subject={subject}
            ownerName={ownerName}
            handleOwnerChange={handleOwnerChange}
            handleRemoveRow={handleRemoveRow}
            handleRemoveSelectedRows={handleRemoveSelectedRows}
            isDayEvent={isDayEvent}
            isRowSelected={isRowSelected}
            isOverLappingRecord={isOverLappingRecord}
            getOverLappingBgColor={getOverLappingBgColor}
            handleFieldUpdates={handleFieldUpdates}
            handleEditSchedule={handleEditSchedule}
          />
        </GridItem>
      </GridRow>
    </Grid>
  );
};

MultiAssignContainer.propTypes = {
  onSelection: PropTypes.func.isRequired,
  selectedWO: PropTypes.shape({}).isRequired,
  selections: PropTypes.arrayOf(PropTypes.object).isRequired,
  teamIds: PropTypes.arrayOf(String).isRequired,
  technicians: PropTypes.arrayOf(PropTypes.object).isRequired,
  territoryList: PropTypes.arrayOf(PropTypes.object).isRequired
};

export default MultiAssignContainer;
