import React from "react";
import moment from "moment-timezone";
import {
  ID,
  NAME,
  OWNER,
  OWNERID,
  PICKLIST,
  CREATEDBY,
  REFERENCE,
  CREATEDBYID,
  LASTMODIFIEDBY,
  LASTMODIFIEDBYID,
  TIME_FIELD_TYPE,
  DATE_FIELD_TYPE,
  BOOLEAN_FIELD_TYPE,
  DATETIME_FIELD_TYPE,
  WO_SERVICE_DURATION_FIELD,
  WO_OVERHEAD_TIME_BEFORE_FIELD,
  WO_OVERHEAD_TIME_AFTER_FIELD,
  WO_DRIVING_TIME_FIELD,
  WO_DRIVING_TIME_HOME_FIELD,
  WO_VIOLATION_MESSAGE,
  WO_VIOLATION_STATUS,
  SALESFORCE_EVENT,
  TECH_SALESFORCE_USER_FIELD,
  WORKORDER_TECHNICIAN_API_NAME,
  WO_DISPATCH_STATUS_FIELD
} from "constants/AppConstants";
import { compact, isNull, remove, sum } from "lodash";
import {
  getSettingValue,
  DEFAULT_PAGE_SIZE,
  GLOB001_GBL025
} from "constants/AppSettings";
import {
  DATE_TIME_FORMAT,
  YODA_DATE_FORMAT,
  YODA_DATE_TIME_ZONE_24_HR_FORMAT,
  MINUTES
} from "constants/DateTimeConstants";
import { getFieldValue } from "utils/DCUtils";
import { getUserTimeSettings } from "utils/DateAndTimeUtils";

const dateFormat = getUserTimeSettings("dateFormat");
const timeFormat = getUserTimeSettings("timeFormat");
const dateTimeFormat = getUserTimeSettings("dateTimeFormat");

/* eslint-disable no-restricted-syntax */
function getViewColumns(view) {
  let columns = [];
  const { columnInfo } = view;
  if (columnInfo) {
    columns = columnInfo.split(",");
  }
  return columns;
}

function isObject(value) {
  return value && typeof value === "object" && value.constructor === Object;
}

function GridColumn(...args) {
  const [accessor, Header, width, fixed, minResizeWidth, gridCell] = args;
  this.accessor = accessor;
  this.Header = Header;
  this.Cell = gridCell;
  if (width) {
    try {
      this.width = parseFloat(width);
    } catch (e) {
      console.log(`Failed to convert to float ${width}`);
    }
  }
  if (fixed) {
    this.fixed = fixed;
  }
  if (minResizeWidth) {
    this.minResizeWidth = minResizeWidth;
  }
}

export function toDateTime(dateTime) {
  return moment(dateTime).format("L LT");
}

export function toTimeZone(time, zone) {
  return moment.tz(time, zone).format(dateTimeFormat);
}

export function gridCell(row) {
  const { value } = row;
  return (
    <span className="slds-truncate" title={value}>
      {value}
    </span>
  );
}

export function toTime(zone) {
  return moment()
    .tz(zone)
    .format();
}

export function getReferenceValue(woRow, fieldName, refField = NAME) {
  let refFieldName = fieldName;
  if (fieldName.endsWith("__c")) {
    refFieldName = fieldName.replace("__c", "__r");
  } else if (fieldName.endsWith(ID)) {
    refFieldName = fieldName.replace(ID, "");
  }
  const refObj = woRow[refFieldName] || woRow[fieldName];
  return (refObj && refObj[refField]) || "";
}

export function createRow(woRow, columns, woFieldObj, timeZone) {
  const row = {
    Id: woRow.Id,
    [WO_VIOLATION_MESSAGE]: woRow[WO_VIOLATION_MESSAGE],
    [WO_VIOLATION_STATUS]: woRow[WO_VIOLATION_STATUS],
    [WORKORDER_TECHNICIAN_API_NAME]: woRow[WORKORDER_TECHNICIAN_API_NAME],
    [WO_DISPATCH_STATUS_FIELD]: woRow[WO_DISPATCH_STATUS_FIELD]
  };
  const woFieldKeys = Object.keys(woRow);
  const index = woFieldKeys.indexOf("attributes");
  if (index !== -1) {
    woFieldKeys.splice(index, 1);
  }

  columns.forEach(column => {
    const { accessor } = column;
    let fieldValue =
      isNull(woRow[accessor]) || woRow[accessor] === undefined
        ? ""
        : woRow[accessor];
    const fieldDesc = woFieldObj[accessor];
    if (fieldDesc) {
      const { fieldType, refField = NAME } = fieldDesc;
      switch (fieldType) {
        case BOOLEAN_FIELD_TYPE:
          fieldValue = fieldValue !== "" ? fieldValue.toString() : "";
          break;
        case PICKLIST:
          const listOfValues = JSON.parse(refField) || {};
          fieldValue = listOfValues[fieldValue] || fieldValue;
          break;
        case REFERENCE:
          fieldValue = getReferenceValue(woRow, accessor, refField);
          break;
        case TIME_FIELD_TYPE:
          fieldValue =
            fieldValue &&
            moment(fieldValue, moment.HTML5_FMT.TIME_MS)
              .tz(timeZone)
              .format(dateTimeFormat);

          fieldValue = fieldValue && toTimeZone(fieldValue, timeFormat);
          break;
        case DATE_FIELD_TYPE:
          fieldValue =
            fieldValue &&
            moment(fieldValue, moment.ISO_8601).format(dateFormat);
          break;
        case DATETIME_FIELD_TYPE:
          fieldValue =
            fieldValue &&
            moment(fieldValue, moment.ISO_8601)
              .tz(timeZone)
              .format(dateTimeFormat);
          break;
        default:
          break;
      }
    }
    row[`${accessor}`] = isNull(fieldValue) ? fieldValue : `${fieldValue}`;
  });
  return row;
}

export function normalizeColumnName(column) {
  if (!column) {
    return column;
  }
  let colName = column;
  if (isObject(column)) {
    colName = column && column.name;
  }
  const index = colName.indexOf(".");
  if (index !== -1) {
    colName = colName.substr(0, index);
    if (colName.endsWith("__r")) {
      colName = colName.replace("__r", "__c");
    } else if (colName === CREATEDBY) {
      colName = CREATEDBYID;
    } else if (colName === LASTMODIFIEDBY) {
      colName = LASTMODIFIEDBYID;
    } else if (colName === OWNER) {
      colName = OWNERID;
    }
  }
  return colName;
}

// eslint-disable-next-line import/prefer-default-export
export function getGridColumns(view, configuredColumns, fieldMap) {
  const queue = configuredColumns && Array.isArray(configuredColumns);
  const [firstColumn] = (queue && configuredColumns) || [];
  if (firstColumn) {
    const { name } = firstColumn;
    if (name !== NAME) {
      const lockedCols = remove(
        configuredColumns,
        configuredColumn => configuredColumn.name === NAME
      );
      if (lockedCols.length) {
        configuredColumns.unshift(...lockedCols);
      }
    }
  }

  const columns = queue ? configuredColumns : getViewColumns(view);
  return compact(
    columns.map((column, index) => {
      const name = normalizeColumnName(column);
      const field = fieldMap[name];
      const columList = field
        ? new GridColumn(
            name,
            (field && field.display) || name,
            column && (index === 0 ? 190 : column.width),
            index === 0 ? "right" : undefined,
            index === 0 ? 190 : 50,
            gridCell
          )
        : undefined;
      return columList;
    })
  );
}

export function getGridRows(
  workOrders = [],
  columns,
  woFieldObj,
  userTimeZone
) {
  const { defaultTZ } = userTimeZone || {};
  return workOrders
    ? workOrders.map(workOrder =>
        createRow(workOrder, columns, woFieldObj, defaultTZ)
      )
    : [];
}

export function getWorkOrderFields(record = {}) {
  const woFields = [];
  for (const key in record) {
    if (!isObject(record[key])) {
      woFields.push(key);
    }
  }
  return woFields;
}

export function calculateTotalPage(
  { totalSize = 0 },
  batchSize = DEFAULT_PAGE_SIZE
) {
  if (totalSize <= 0) {
    return totalSize;
  }
  let pages = Math.floor(totalSize / batchSize);
  if (totalSize % batchSize) pages += 1;
  return pages;
}

export function getRecordIndex(pageIndex, batchSize = DEFAULT_PAGE_SIZE) {
  return pageIndex * batchSize;
}

function getMultiAssignmentMapper() {
  return {
    ActivityDate: { format: YODA_DATE_FORMAT, key: "startDate", type: "Date" },
    ActivityDateTime: {
      format: YODA_DATE_TIME_ZONE_24_HR_FORMAT,
      key: "startDate",
      type: "Date"
    },
    Description: "description",
    DurationInMinutes: "serviceDuration",
    EndDateTime: {
      format: YODA_DATE_TIME_ZONE_24_HR_FORMAT,
      key: "endDate",
      type: "Date"
    },
    isAllDayEvent: "dayEvent",
    Location: "location",
    StartDateTime: {
      format: YODA_DATE_TIME_ZONE_24_HR_FORMAT,
      key: "startDate",
      type: "Date"
    },
    [WO_DRIVING_TIME_FIELD]: "beforeDriveTime",
    [WO_DRIVING_TIME_HOME_FIELD]: "afterDriveTime",
    [WO_OVERHEAD_TIME_AFTER_FIELD]: "afterOHTime",
    [WO_OVERHEAD_TIME_BEFORE_FIELD]: "beforeOHTime"
  };
}

export function createMultiAssignmentEvent(
  event,
  selectedWO,
  subject,
  technicians = {}
) {
  const multiAssignEvent = {};
  const { endDate, dayEvent, startDate } = event;
  if (dayEvent) {
    const alllDayStartDate = moment(startDate, DATE_TIME_FORMAT).startOf("day");
    const alllDayEndDate = moment(endDate, DATE_TIME_FORMAT)
      .subtract(1, "minutes")
      .endOf("day");
    const days = alllDayEndDate.diff(alllDayStartDate, "days") + 1;
    // eslint-disable-next-line no-param-reassign
    event.startDate = alllDayStartDate.format(DATE_TIME_FORMAT);
    // eslint-disable-next-line no-param-reassign
    event.endDate = moment(startDate, DATE_TIME_FORMAT)
      .startOf("day")
      .add(days, "days")
      .subtract(1, "minutes")
      .format(DATE_TIME_FORMAT);
    // eslint-disable-next-line no-param-reassign
    event.serviceDuration =
      moment(event.endDate, DATE_TIME_FORMAT).diff(
        moment(event.startDate, DATE_TIME_FORMAT),
        MINUTES
      ) + 1;
  }
  const mapper = getMultiAssignmentMapper();
  Object.keys(mapper).map(sourceKey => {
    const targetKey = mapper[sourceKey];
    let targetValue = event[targetKey];
    if (isObject(targetKey)) {
      const { format, key, type } = targetKey;
      // In case of date field types, format them into YODA Date Time format.
      if (type === "Date") {
        targetValue = moment.utc(event[key], DATE_TIME_FORMAT).format(format);
      }
    }
    multiAssignEvent[sourceKey] = targetValue;
    return undefined;
  });

  const {
    Id,
    id,
    scheduledEvent,
    serviceDuration,
    afterDriveTime = 0,
    afterOHTime = 0,
    beforeDriveTime = 0,
    beforeOHTime = 0
  } = event;
  // In case of GBL025 enabled, Pass Salesforce User Id as event Owner Id.
  multiAssignEvent.OwnerId = Id;
  const isSaleforceEvent = getSettingValue(GLOB001_GBL025) === SALESFORCE_EVENT;
  if (isSaleforceEvent && technicians[Id]) {
    const { technician_O: technicianObj } = technicians[Id];
    multiAssignEvent.OwnerId = getFieldValue(
      technicianObj,
      TECH_SALESFORCE_USER_FIELD,
      Id
    );
  }
  multiAssignEvent.Subject = subject;
  multiAssignEvent.WhatId = selectedWO.Id;
  multiAssignEvent.Id = scheduledEvent ? id : "";
  multiAssignEvent[WO_SERVICE_DURATION_FIELD] =
    60 *
    (serviceDuration -
      sum([afterDriveTime, beforeDriveTime, afterOHTime, beforeOHTime]));
  return multiAssignEvent;
}

export function isValidViolationMessage(statusMsg) {
  const violationArrayCollection = [];
  // const obj = {};
  const arrCap = statusMsg.split("<");
  if (arrCap.length) {
    for (let i = 0; i < arrCap.length; i++) {
      const str = arrCap[i];
      if (str.search(">") != -1) {
        const strarr = str.split(">");
        let violationArr = [];
        if (strarr.length) {
          const str1 = strarr[0];
          violationArr = str1.split(":");
          const obj = {};
          if (violationArr.length) {
            obj.category = violationArr[0];
            obj.type = violationArr[1];
            obj.name = "  ";
            obj.severity = "  ";
            if (violationArr.length > 2) {
              obj.name = violationArr[2];
            }
            if (violationArr.length > 3) {
              obj.severity = violationArr[3];
            }
            violationArrayCollection.push(obj);
          }
        }
      }
    }
  }
  return violationArrayCollection;
}
