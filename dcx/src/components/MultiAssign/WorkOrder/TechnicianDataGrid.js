import React, { useEffect, useState } from "react";
import {
  Button,
  Checkbox,
  DataGrid,
  Grid,
  GridRow,
  GridItem,
  Icon,
  Label,
  Radio,
  Search,
  ButtonGroup
} from "@svmx/ui-components-lightning";
import moment from "moment";
import PropTypes from "prop-types";
import { getDisplayValue, getFieldValue } from "utils/DCUtils";
import {
  DCON001_SET054,
  DCON001_SET064,
  getSettingValue
} from "constants/AppSettings";
import {
  TAG046,
  TAG050,
  TAG053,
  TAG189,
  TAG190,
  TAG191,
  TAG247,
  TAG346,
  TAG351,
  TAG352,
  TAG353,
  TAG356,
  TAG376
} from "constants/DisplayTagConstants";
import { MINUTES, DATE_TIME_FORMAT } from "constants/DateTimeConstants";
import { NONE, HOURS, DURATION } from "constants/AppConstants";
import { getUserTimeSettings } from "utils/DateAndTimeUtils";
import DateTimeInlineEdit from "./DateTimeInlineEdit";
import { isContrastColor } from "utils/ColorUtils";
import TextEdit from "./TextEdit";

import "./TechnicianDataGrid.scss";

const END_DATE = "endDate";
const START_DATE = "startDate";

const TechnicianDataGrid = props => {
  const {
    rows = [],
    searchText,
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
    handleRemoveSelectedRows,
    handleFieldUpdates,
    handleEditSchedule,
    isDayEvent,
    isRowSelected,
    updateScheduleDate,
    isOverLappingRecord,
    getOverLappingBgColor
  } = props;

  const dateFormat = getUserTimeSettings("dateFormat");
  const timeFormat = getUserTimeSettings("timeFormat");
  const [dataRows, setDataRows] = useState(
    rows.map(obj => ({ ...obj, editable: false }))
  );
  const [startDateEdit, setStartDateEdit] = useState(false);
  const [endDateEdit, setEndDateEdit] = useState(false);

  useEffect(() => {
    setDataRows(rows.map(obj => ({ ...obj, editable: false })));
  }, [rows]);

  const setDateEditable = (value, id, name) => {
    setStartDateEdit(false);
    setEndDateEdit(false);
    setDataRows(
      dataRows.map(obj =>
        obj.id === id ? { ...obj, editable: true } : { ...obj, editable: false }
      )
    );
    if (name === START_DATE) setStartDateEdit(true);
    if (name === END_DATE) setEndDateEdit(true);
  };

  const getTechnician = () => {
    const owner = rows.find(row => row.id === isOwner);
    return (owner && owner.name) || ownerName || NONE;
  };

  const showDuration =
    getSettingValue(DCON001_SET064, "End Date Time") === DURATION;
  const measureUnitInHours = getSettingValue(DCON001_SET054, HOURS) === HOURS;

  const getMinEndDate = event => {
    const { startDate } = event;
    const minEndDate = moment(
      moment(startDate, DATE_TIME_FORMAT)
        .startOf("day")
        .subtract(1, "day")
        .format(dateFormat),
      dateFormat
    );
    return minEndDate;
  };

  const getMinEndTime = event => {
    const { endDate, startDate, serviceDuration } = event;
    const isSameDay = moment(endDate, DATE_TIME_FORMAT).isSame(
      moment(startDate, DATE_TIME_FORMAT),
      "day"
    );
    if (isSameDay) {
      const newEndDateTime = moment(startDate, DATE_TIME_FORMAT);
      return moment(newEndDateTime.format(timeFormat), timeFormat);
    }
    return undefined;
  };

  const showTodayButton = event => {
    const { startDate } = event;
    const startDateTime = moment(startDate, DATE_TIME_FORMAT).startOf("day");
    return moment()
      .startOf("day")
      .isSameOrAfter(startDateTime);
  };

  const sortMethod = (a, b) =>
    moment(a, DATE_TIME_FORMAT).diff(moment(b, DATE_TIME_FORMAT), MINUTES);

  const columns = [
    {
      Cell: row => {
        const { original } = row;
        const { id } = original;
        return (
          <Checkbox
            name={id}
            value={isRowSelected(id)}
            isChecked={isRowSelected(id)}
            isDisabled={isDisabled}
            onCheckedChange={() => handleRowSelection(id)}
          />
        );
      },
      className: "DataGridWithSelection__input-cell",
      Header: () => (
        <Checkbox
          isDisabled={!rows.length || isDisabled}
          name="withSelectionAll"
          isChecked={selectAllRows}
          onCheckedChange={eventData => handleSelectAllRows(eventData)}
        />
      ),
      headerClassName: "DataGridWithSelection__select-all",
      resizable: false,
      sortable: false,
      width: 35
    },
    {
      accessor: "teamName",
      Header: getDisplayValue(TAG046),
      className: "label",
      Cell: row => {
        const { original } = row;
        const { teamName } = original;
        return <div className="long-and-truncated">{teamName}</div>;
      }
    },
    {
      accessor: "name",
      Header: getDisplayValue(TAG050),
      className: "label",
      Cell: row => {
        const { original } = row;
        const { name } = original;
        return <div className="long-and-truncated">{name}</div>;
      }
    },
    {
      Cell: row => {
        const { original } = row;
        const { id } = original;
        return (
          <Checkbox
            name={id}
            value={isDayEvent(id)}
            isChecked={isDayEvent(id)}
            isDisabled={isDisabled}
            onCheckedChange={() => handleDayEventSelection(id)}
          >
            {getDisplayValue(TAG376)}
          </Checkbox>
        );
      },
      className: "DataGridWithSelection__input-cell label",
      Header: () => (
        <Checkbox
          isDisabled={!rows.length || isDisabled}
          name={getDisplayValue(TAG247)}
          isChecked={allDayEvent}
          onCheckedChange={eventData => handleAllDayEvent(eventData)}
        >
          {getDisplayValue(TAG376)}
        </Checkbox>
      ),
      headerClassName: "DataGridWithSelection__select-all",
      sortable: false,
      width: 110
    },
    {
      Cell: row => {
        const { original } = row;
        const { id, editable } = original;
        return (
          <DateTimeInlineEdit
            name={START_DATE}
            event={original}
            isDayEvent={isDayEvent}
            key={`${id}-${START_DATE}`}
            updateScheduleDate={updateScheduleDate}
            editable={editable && startDateEdit}
            setDateEditable={setDateEditable}
          />
        );
      },
      id: START_DATE,
      accessor: row => row.startDate,
      sortMethod,
      Header: getDisplayValue(TAG351)
    },
    {
      Cell: row => {
        const { original } = row;
        const { id, serviceDuration, editable } = original;
        if (showDuration) {
          // if (measureUnitInHours) {
          //   let hours = Math.round(serviceDuration / 60);
          //   if (hours < 10) {
          //     hours = moment(hours, 'hh').format('hh');
          //   }
          //   const minutes = serviceDuration - hours * 60;
          //   return <span>{`${hours}:${moment(minutes, 'mm').format('mm')}`}</span>;
          // }
          // return <span>{serviceDuration}</span>;
          return (
            <TextEdit
              event={original}
              updateScheduleDate={updateScheduleDate}
            />
          );
        }
        return (
          <DateTimeInlineEdit
            name={END_DATE}
            event={original}
            isDayEvent={isDayEvent}
            key={`${id}-${END_DATE}`}
            minDate={getMinEndDate(original)}
            minTime={getMinEndTime(original)}
            showTodayButton={showTodayButton(original)}
            updateScheduleDate={updateScheduleDate}
            editable={editable && endDateEdit}
            setDateEditable={setDateEditable}
          />
        );
      },
      id: END_DATE,
      accessor: row => row.endDate,
      sortMethod,
      Header: showDuration ? getDisplayValue(TAG053) : getDisplayValue(TAG352)
    },
    {
      Cell: row => {
        const { original } = row;
        const { id } = original;
        return (
          <Radio
            name={id}
            value={id}
            isChecked={isOwner === id}
            isDisabled={isDisabled}
            onCheckedChange={() => handleOwnerChange(id)}
          />
        );
      },
      className:
        "DataGridWithSelection__input-cell TechnicianDataGrid__Column-center",
      Header: getDisplayValue(TAG189),
      headerClassName: "DataGridWithSelection__select-all",
      sortable: false,
      width: 80
    },
    {
      Cell: row => {
        const { original } = row;
        const { id } = original;
        return (
          <Button
            type="icon-bare"
            size="medium"
            isDisabled={isDisabled}
            onClick={() => handleRemoveRow(id)}
          >
            <Icon icon="close" size="small" />
          </Button>
        );
      },
      className:
        "DataGridWithSelection__input-cell TechnicianDataGrid__Column-center",
      headerClassName: "DataGridWithSelection__select-all",
      resizable: false,
      sortable: false,
      width: 50
    }
  ];

  // Remove All Day event column if SET064 is Enabled.
  if (showDuration) {
    columns.splice(3, 1);
  }

  return (
    <Grid isVertical className="TechnicianDataGrid">
      <GridRow className="TechnicianDataGrid__GridRow">
        <GridItem noFlex className="TechnicianDataGrid__GridItem-search">
          <Search
            onValueChange={event => handleSearchChange(event)}
            placeholder={getDisplayValue(TAG353)}
            value={searchText}
          />
        </GridItem>
        <GridItem />
        <GridItem noFlex className="TechnicianDataGrid__GridItem-vcenter">
          <Checkbox
            isChecked={showPastEvents}
            isDisabled={!hasPastEvents}
            onCheckedChange={event => handlePastEventChange(event)}
            name={getDisplayValue(TAG356)}
          >
            {getDisplayValue(TAG356)}
          </Checkbox>
        </GridItem>
        <GridItem />
        <GridItem noFlex className="TechnicianDataGrid__GridItem-vcenter">
          <Label>{getDisplayValue(TAG189)}</Label>
        </GridItem>
        <GridItem className="TechnicianDataGrid__GridItem-vcenter">
          <Label>
            <b>{getTechnician()}</b>
          </Label>
        </GridItem>
        <GridItem />
        <GridItem noFlex className="TechnicianDataGrid__GridItem">
          <ButtonGroup>
            <Button type="neutral" onClick={() => handleFieldUpdates()}>
              <Icon icon="record_update" align="left" size="x-small" />
              {getDisplayValue(TAG346)}
            </Button>
            <Button
              isDisabled={
                isDisabled || !rows.filter(row => isRowSelected(row.id)).length
              }
              type="neutral"
              onClick={() => handleEditSchedule()}
            >
              <Icon icon="edit" align="left" size="x-small" />
              {getDisplayValue(TAG190)}
            </Button>
            <Button
              isDisabled={
                isDisabled || !rows.filter(row => isRowSelected(row.id)).length
              }
              type="neutral"
              onClick={() => handleRemoveSelectedRows()}
            >
              <Icon icon="delete" align="left" size="x-small" />
              {getDisplayValue(TAG191)}
            </Button>
          </ButtonGroup>
        </GridItem>
      </GridRow>
      <GridRow className="TechnicianDataGrid__GridRow">
        <GridItem>
          <DataGrid
            className="TechnicianDataGrid__data-grid -bordered"
            columns={columns}
            data={dataRows}
            multiSort={false}
            defaultItemsPerPage={500}
            showPagination={false}
            sortable
            hasColumnBorder
            getTrProps={(state, rowInfo) => {
              if (rowInfo && rowInfo.original) {
                let background = "#FFF";
                let className = "overlapping__constrast";
                const overlappingRecord = isOverLappingRecord(rowInfo.original);
                if (overlappingRecord) {
                  background = getOverLappingBgColor(rowInfo.original);
                  className = isContrastColor(background)
                    ? "overlapping__light"
                    : className;
                }
                return {
                  className,
                  style: {
                    background
                  }
                };
              }
              return {};
            }}
          />
        </GridItem>
      </GridRow>
    </Grid>
  );
};

TechnicianDataGrid.propTypes = {
  selectedWO: PropTypes.shape({}).isRequired
};

export default TechnicianDataGrid;
