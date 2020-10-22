import store from "store";
import {
  TAG248,
  TAG249,
  TAG250,
  TAG289,
  TAG290,
  TAG291,
  TAG292,
  TAG293,
  TAG294,
  TAG295,
  TAG296,
  TAG400,
  TAG401,
  TAG280
} from "constants/DisplayTagConstants";
import { compact, flatMap, filter, remove, reverse } from "lodash";
import { isObject } from "util";

export const isSingleWOLaunch = () => {
  const queryParams = getURLParams();
  const { wid } = queryParams;
  return !!wid;
};

export const getURLParams = () => {
  const vars = {};
  window.location.href.replace(/[?&]+([^=&]+)=([^&]*)/gi, (m, key, value) => {
    vars[key] = value;
  });
  return vars;
};

export function getUserSetting(key, defaultValue) {
  let value = defaultValue;
  const state = store.getState();
  const { userSettings } = state;
  if (userSettings[key]) {
    value = userSettings[key];
  }
  return value;
}

export function convertUint2Hex(color) {
  let hex = "";
  const maxChars = 6;
  if (color && color.toString().includes("#")) {
    hex = color;
  } else {
    const digits = "0123456789ABCDEF";
    while (color > 0) {
      const next = color & 0xf;
      color >>= 4;
      hex = digits.charAt(next) + hex;
    }
    if (hex.length === 0) hex = "000000";
    let prefixConunt = maxChars - hex.length;
    while (prefixConunt > 0) {
      hex = `0${hex}`;
      prefixConunt -= 1;
    }
    hex = `#${hex}`;
  }
  return hex;
}

export const getFormValues = formName => {
  const state = store.getState();
  const { form } = state;
  const { values } = form[formName];
  return values;
};

let tags;
const loadDisplayTags = () => {
  const state = store.getState();
  const { metaData } = state;
  const { displayTags } = metaData;
  const { content } = displayTags;
  return content;
};

export const getDisplayValue = (tagKey, defaultValue = tagKey) => {
  if (!tags) tags = loadDisplayTags();
  let displayValue = defaultValue;
  if (tags && tags[tagKey]) {
    displayValue = tags[tagKey];
  }
  return displayValue;
};

export const getClauses = () => [
  { display: getDisplayValue(TAG249), value: "eq" },
  { display: getDisplayValue(TAG289), value: "neq" },
  { display: getDisplayValue(TAG248), value: "Less Than" },
  { display: getDisplayValue(TAG291), value: "Less or Equal To" },
  { display: getDisplayValue(TAG250), value: "Greater Than" },
  { display: getDisplayValue(TAG290), value: "Greater or Equal To" },
  { display: getDisplayValue(TAG292), value: "Starts With" },
  { display: getDisplayValue(TAG293), value: "Contains" },
  { display: getDisplayValue(TAG294), value: "Does Not Contain" },
  { display: getDisplayValue(TAG295), value: "Is Null" },
  { display: getDisplayValue(TAG296), value: "Is Not Null" }
];

export const stringToBoolean = val => {
  if (String(val).toLowerCase() === "true") {
    return true;
  }
  return false;
};

export const getDeltaWorkOrderIds = WOIds => {
  const workOrderIds = WOIds;
  const state = store.getState();
  const { workOrderData } = state;
  const { workOrders } = workOrderData;
  const { content } = workOrders;
  const { records } = content;
  const deltaWorkOrderIds = [];
  workOrderIds.map(item => {
    let checkId = false;
    records.map(recordIds => {
      if (recordIds.Id === item) {
        checkId = true;
      }
    });
    if (!checkId) {
      deltaWorkOrderIds.push(item);
    }
  });
  return deltaWorkOrderIds;
};

export const getWorkOrderFromNumber = woNum => {
  const workOrderNumber = woNum;
  const state = store.getState();
  const { workOrderData } = state;
  const { workOrders } = workOrderData;
  const { content } = workOrders;
  if (!content) {
    return null;
  }
  const { records = [] } = content;
  let workOrderInfo = null;

  records.map(recordIds => {
    if (recordIds.Name === workOrderNumber) {
      workOrderInfo = recordIds;
    }
  });
  return workOrderInfo;
};

export const getWorkOrderIdsInfo = WOIds => {
  const workOrderIds = WOIds;
  const state = store.getState();
  const { workOrderData } = state;
  const { workOrders, deltaWorkOrder } = workOrderData;
  const { content } = workOrders;
  if (!content) {
    return null;
  }
  const { records = [] } = content;
  let tWorkOrderData = [];
  if (deltaWorkOrder) {
    const { content: deltaWorkOrderData } = deltaWorkOrder;
    tWorkOrderData = deltaWorkOrderData;
  }
  const workOrderInfo = {};
  workOrderIds.map(item => {
    let checkId = false;
    records.map(recordIds => {
      if (recordIds.Id === item) {
        checkId = true;
        workOrderInfo[item] = recordIds;
      }
    });
    if (!checkId) {
      const deltaData = Object.keys(tWorkOrderData);
      if (deltaData) {
        deltaData.map(() => {
          if (tWorkOrderData[item]) {
            workOrderInfo[item] = tWorkOrderData[item];
          }
        });
      }
    }
  });
  return workOrderInfo;
};

export const isNumeric = value => {
  const REGEX = /^[0-9]+$/;
  return REGEX.test(value);
};

export const getFieldValue = (obj, fName, defaultValue) =>
  (obj && obj[fName]) || defaultValue;

export const getFieldValueFromHtml = (obj, fName, defaultValue) =>
  (obj && obj[fName] && obj[fName].props && obj[fName].props.value) ||
  (obj && obj[fName]) ||
  defaultValue;

export const setFieldValue = (obj, fName, fValue) => {
  if (obj && isObject(obj)) {
    obj[fName] = fValue;
  }
};

export const getPickListItems = (refField, eventField, scheduledEvent) => {
  let defaultPickListItem = getDisplayValue(TAG280);
  const pickListItems = [
    {
      name: getDisplayValue(TAG280),
      display: getDisplayValue(TAG280)
    }
  ].concat(
    reverse(Object.keys(JSON.parse(refField))).map(key => ({
      name: key,
      display: JSON.parse(refField)[key]
    }))
  );

  const defaultPickListObj = remove(
    pickListItems,
    obj => obj.name === "defaultValue"
  );

  if (defaultPickListObj.length && eventField && !scheduledEvent) {
    defaultPickListItem = defaultPickListObj[0].display;
  }

  return { pickListItems, defaultPickListItem };
};

export const getEventFieldUpdates = (fields = []) => {
  if (!fields) {
    return undefined;
  }
  const fieldKeyObj = {
    SET038: "DCON001_SET038",
    SET039: "DCON001_SET039",
    SET040: "DCON001_SET040",
    SET041: "DCON001_SET041",
    SET042: "DCON001_SET042",
    SET043: "DCON001_SET043",
    SET044: "DCON001_SET044",
    SET045: "DCON001_SET045",
    SET046: "DCON001_SET046",
    SET047: "DCON001_SET047"
  };
  const obj = {};
  const eventFields = filter(fields, { keyType: "Settingfield" });
  eventFields.forEach(field => {
    obj[fieldKeyObj[field.key]] = field.value;
  });
  return obj;
};

export const getFieldValues = (obj, fields = [], compactValues) => {
  if (!obj) {
    return undefined;
  }
  const valueArray = flatMap(fields, field => getFieldValue(obj, field));
  return compactValues ? compact(valueArray) : valueArray;
};

export const getWOFieldValueFromApiName = (apiName, field) => {
  const state = store.getState();
  const { metaData } = state;
  const { workOrderFields } = metaData;
  const { content } = workOrderFields;
  if (field) {
    return content[apiName].refField;
  }
  return content[apiName].display;
};

export const convertErrorToObject = response => {
  if (Array.isArray(response)) {
    const [errorObject] = response;
    return { ...errorObject };
  }
  return response;
};

export const lightOrDark = color => {
  // Variables for red, green, blue values
  let r;
  let g;
  let b;
  let hsp;
  // Check the format of the color, HEX or RGB?
  if (color.match(/^rgb/)) {
    // If HEX --> store the red, green, blue values in separate variables
    color = color.match(
      /^rgba?\((\d+),\s*(\d+),\s*(\d+)(?:,\s*(\d+(?:\.\d+)?))?\)$/
    );
    r = color[1];
    g = color[2];
    b = color[3];
  } else {
    // If RGB --> Convert it to HEX: http://gist.github.com/983661
    color = +`0x${color.slice(1).replace(color.length < 5 && /./g, "$&$&")}`;
    r = color >> 16;
    g = (color >> 8) & 255;
    b = color & 255;
  }
  // HSP (Highly Sensitive Poo) equation from http://alienryderflex.com/hsp.html
  hsp = Math.sqrt(0.299 * (r * r) + 0.587 * (g * g) + 0.114 * (b * b));
  // Using the HSP value, determine whether the color is light or dark
  if (hsp > 127.5) {
    return "light";
  }
  return "dark";
};
