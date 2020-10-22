import React from "react";
import {
  Input,
  InputWrapper,
  Grid,
  GridRow,
  GridItem,
  Label
} from "@svmx/ui-components-lightning";
import PropTypes from "prop-types";
import { TAG051, TAG035, TAG063 } from "constants/DisplayTagConstants";
import { FALSE } from "constants/AppConstants";
import { DCON001_SET037, getSettingValue } from "constants/AppSettings";
import { getDisplayValue } from "utils/DCUtils";
import TechnicianDataGrid from "./TechnicianDataGrid";

import "./WorkOrderDetail.scss";

const WorkOrderDetail = props => {
  const {
    subject,
    selectedWO,
    selections,
    rows,
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
    handleOwnerChange,
    handleRemoveRow,
    updateScheduleDate,
    handleRemoveSelectedRows,
    handleFieldUpdates,
    handleEditSchedule,
    handleSubjectChange,
    isOverLappingRecord,
    getOverLappingBgColor,
    isDayEvent,
    isRowSelected
  } = props;

  const isSubjectEditable = JSON.parse(
    getSettingValue(DCON001_SET037, FALSE).toLowerCase()
  );

  return (
    <Grid isVertical className="WorkOrderDetail">
      <GridRow className="WorkOrderDetail__GridRow">
        <GridItem>
          <Label>
            <b>{getDisplayValue(TAG051)}</b>
          </Label>
        </GridItem>
      </GridRow>
      <GridRow className="WorkOrderDetail__GridRow">
        <GridItem noFlex className="WorkOrderDetail__GridRow-vcenter">
          <Label>
            <b>{getDisplayValue(TAG035)}</b>
          </Label>
        </GridItem>
        <GridItem>
          <InputWrapper>
            <Input
              placeholder={getDisplayValue(TAG063)}
              name="WORKORDER_NUMBER"
              value={subject}
              onValueChange={data => handleSubjectChange(data)}
              isDisabled={isDisabled || !isSubjectEditable}
            />
          </InputWrapper>
        </GridItem>
      </GridRow>
      <GridRow className="WorkOrderDetail__GridRow">
        <GridItem>
          <TechnicianDataGrid
            selections={selections}
            selectedWO={selectedWO}
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
            handleAllDayEvent={handleAllDayEvent}
            isDisabled={isDisabled}
            isOwner={isOwner}
            ownerName={ownerName}
            handleOwnerChange={handleOwnerChange}
            handleRemoveRow={handleRemoveRow}
            handleRemoveSelectedRows={handleRemoveSelectedRows}
            handleFieldUpdates={handleFieldUpdates}
            handleEditSchedule={handleEditSchedule}
            isDayEvent={isDayEvent}
            isRowSelected={isRowSelected}
            isOverLappingRecord={isOverLappingRecord}
            getOverLappingBgColor={getOverLappingBgColor}
          />
        </GridItem>
      </GridRow>
    </Grid>
  );
};

WorkOrderDetail.propTypes = {
  selectedWO: PropTypes.shape({}).isRequired,
  selections: PropTypes.arrayOf(PropTypes.object).isRequired
};

export default WorkOrderDetail;
