import moment from "moment";
import store from "store";
import {
  ID,
  NAME,
  CONDITION_NULL,
  CONDITION_NOT_NULL,
  CONDITION_MATCHES,
  CONDITION_MATCHES_NOT,
  CONDITION_STARTS_WITH,
  CONDITION_CONTAINS,
  CONDITION_CONTAINS_NOT,
  CONDITION_IN,
  CONDITION_NOT_IN,
  CONDITION_LESS,
  CONDITION_GE,
  CONDITION_LE,
  ORG_NAMESPACE,
  CONDITION_GREATER
} from "constants/AppConstants";
import { TAG168 } from "constants/DisplayTagConstants";
import { getSettingValue, DCON005_SET003 } from "constants/AppSettings";
import { lightOrDark, convertUint2Hex } from "utils/DCUtils";
import { OVERNIGHT_STAY_EVENT_TYPE } from "constants/EventConstants";
import {
  compact,
  flatMap,
  isUndefined,
  isEmpty,
  range,
  find,
  filter
} from "lodash";
import { isObject } from "util";

import {
  YODA_DATE_FORMAT,
  DATE_TIME_24H_FORMAT,
  YODA_DATE_TIME_ZONE_FORMAT,
  TIME_FORMAT_24H
} from "constants/DateTimeConstants";
import {
  DATE_FORMAT,
  DATE_TIME_FORMAT,
  TIME_FORMAT
} from "constants/DateTimeConstants";

import { getUserTimeSettings } from "utils/DateAndTimeUtils";

const isActive = rule => {
  if (!rule) {
    return false;
  }
  const { status } = rule;
  return status === TAG168;
};

export const COLOR_GROUP_WHITE = "WHITE";
export const COLOR_GROUP_PINK = "PINK";
export const COLOR_GROUP_PURPLE = "PURPLE";
export const COLOR_GROUP_RED = "RED";
export const COLOR_GROUP_ORANGE = "ORANGE";
export const COLOR_GROUP_YELLOW = "YELLOW";
export const COLOR_GROUP_GREEN = "GREEN";
export const COLOR_GROUP_CYAN = "CYAN";
export const COLOR_GROUP_BLUE = "BLUE";
export const COLOR_GROUP_BROWN = "BROWN";
export const COLOR_GROUP_GREY = "GREY";

export const COLOR_GROUP_NAMES = [
  COLOR_GROUP_WHITE,
  COLOR_GROUP_PINK,
  COLOR_GROUP_PURPLE,
  COLOR_GROUP_RED,
  COLOR_GROUP_ORANGE,
  COLOR_GROUP_YELLOW,
  COLOR_GROUP_GREEN,
  COLOR_GROUP_CYAN,
  COLOR_GROUP_BLUE,
  COLOR_GROUP_BROWN,
  COLOR_GROUP_GREY
];

export const COLORS_BY_GROUPS = {
  [COLOR_GROUP_PINK]: [
    "Pink",
    "LightPink",
    "HotPink",
    "DeepPink",
    "PaleVioletRed",
    "MediumVioletRed"
  ],
  [COLOR_GROUP_PURPLE]: [
    "#E6E6FA", //Lavender
    "#D8BFD8", //Thistle
    "#DDA0DD", //Plum
    "#DA70D6", //Orchid
    "#EE82EE", //Violet
    "#FF00FF", //Fuchsia
    "#FF00FF", //Magenta
    "#BA55D3", //MediumOrchid
    "#9932CC", //DarkOrchid
    "#9400D3", //DarkViolet
    "#8A2BE2", //BlueViolet
    "#8B008B", //DarkMagenta
    "#800080", //Purple
    "#9370DB", //MediumPurple
    "#7B68EE", //MediumSlateBlue
    "#6A5ACD", //SlateBlue
    "#483D8B", //DarkSlateBlue
    "#663399", //RebeccaPurple
    "#4B0082" //Indigo
  ],
  [COLOR_GROUP_RED]: [
    "#FFA07A", //LightSalmon
    "#FA8072", //Salmon
    "#E9967A", //DarkSalmon
    "#F08080", //LightCoral
    "#CD5C5C", //IndianRed
    "#DC143C", //Crimson
    "#FF0000", //Red
    "#B22222", //FireBrick
    "#8B0000" //DarkRed
  ],
  [COLOR_GROUP_ORANGE]: [
    "#FFA500", //Orange
    "#FF8C00", //DarkOrange
    "#FF7F50", //Coral
    "#FF6347", //Tomato
    "#FF4500" //OrangeRed
  ],
  [COLOR_GROUP_YELLOW]: [
    "#FFD700", //Gold
    "#BDB76B" //DarkKhaki
  ],
  [COLOR_GROUP_GREEN]: [
    "#ADFF2F", //GreenYellow
    "#7FFF00", //Chartreuse
    "#7CFC00", //LawnGreen
    "#00FF00", //Lime
    "#32CD32", //LimeGreen
    "#98FB98", //PaleGreen
    "#90EE90", //LightGreen
    "#00FA9A", //MediumSpringGreen
    "#00FF7F", //SpringGreen
    "#3CB371", //MediumSeaGreen
    "#2E8B57", //SeaGreen
    "#228B22", //ForestGreen
    "#008000", //Green
    "#006400", //DarkGreen
    "#9ACD32", //YellowGreen
    "#6B8E23", //OliveDrab
    "#556B2F", //DarkOliveGreen
    "#66CDAA", //MediumAquaMarine
    "#8FBC8F", //DarkSeaGreen
    "#20B2AA", //LightSeaGreen
    "#008B8B", //DarkCyan
    "#008080" //Teal
  ],
  [COLOR_GROUP_CYAN]: [
    "#00FFFF", //Aqua
    "#00FFFF", //Cyan
    "#E0FFFF", //LightCyan
    "#AFEEEE", //PaleTurquoise
    "#7FFFD4", //Aquamarine
    "#40E0D0", //Turquoise
    "#48D1CC", //MediumTurquoise
    "#00CED1" //DarkTurquoise
  ],
  [COLOR_GROUP_BLUE]: [
    "#5F9EA0", //CadetBlue
    "#4682B4", //SteelBlue
    "#B0C4DE", //LightSteelBlue
    "#ADD8E6", //LightBlue
    "#B0E0E6", //PowderBlue
    "#87CEFA", //LightSkyBlue
    "#87CEEB", //SkyBlue
    "#6495ED", //CornflowerBlue
    "#00BFFF", //DeepSkyBlue
    "#1E90FF", //DodgerBlue
    "#4169E1", //RoyalBlue
    "#0000FF", //Blue
    "#0000CD", //MediumBlue
    "#00008B", //DarkBlue
    "#000080", //Navy
    "#191970" //MidnightBlue
  ],
  [COLOR_GROUP_BROWN]: [
    "#FFF8DC", //Cornsilk
    "#FFEBCD", //BlanchedAlmond
    "#FFE4C4", //Bisque
    "#FFDEAD", //NavajoWhite
    "#F5DEB3", //Wheat
    "#DEB887", //BurlyWood
    "#D2B48C", //Tan
    "#BC8F8F", //RosyBrown
    "#F4A460", //SandyBrown
    "#DAA520", //GoldenRod
    "#B8860B", //DarkGoldenRod
    "#CD853F", //Peru
    "#D2691E", //Chocolate
    "#808000", //Olive
    "#8B4513", //SaddleBrown
    "#A0522D", //Sienna
    "#A52A2A", //Brown
    "#800000" //Maroon
  ],
  [COLOR_GROUP_GREY]: [
    "#DCDCDC", //Gainsboro
    "#D3D3D3", //LightGray
    "#C0C0C0", //Silver
    "#A9A9A9", //DarkGray
    "#696969", //DimGray
    "#808080", //Gray
    "#778899", //LightSlateGray
    "#708090", //SlateGray
    "#2F4F4F", //DarkSlateGray
    "#000000" //Black
  ],
  [COLOR_GROUP_WHITE]: [
    "#FFFFFF", //White
    "#FFFAFA", //Snow
    "#F0FFF0", //HoneyDew
    "#F5FFFA", //MintCream
    "#F0FFFF", //Azure
    "#F0F8FF", //AliceBlue
    "#F8F8FF", //GhostWhite
    "#F5F5F5", //WhiteSmoke
    "#FFF5EE", //SeaShell
    "#F5F5DC", //Beige
    "#FDF5E6", //OldLace
    "#FFFAF0", //FloralWhite
    "#FFFFF0", //Ivory
    "#FAEBD7", //AntiqueWhite
    "#FAF0E6", //Linen
    "#FFF0F5", //LavenderBlush
    "#FFE4E1" //MistyRose
  ]
};

function rgbToYIQ({ r, g, b }) {
  return (r * 299 + g * 587 + b * 114) / 1000;
}

function hexToRgb(hex) {
  if (!hex || hex === undefined || hex === "") {
    return undefined;
  }

  const result = /^#?([a-f\d]{2})([a-f\d]{2})([a-f\d]{2})$/i.exec(hex);

  return result
    ? {
        r: parseInt(result[1], 16),
        g: parseInt(result[2], 16),
        b: parseInt(result[3], 16)
      }
    : undefined;
}

export function isContrastColor(colorHex, threshold = 128) {
  if (colorHex === undefined) {
    return false;
  }
  const rgb = hexToRgb(colorHex);
  if (rgb === undefined) {
    return false;
  }
  return (
    Math.round(
      (parseInt(rgb.r) * 299 + parseInt(rgb.g) * 587 + parseInt(rgb.b) * 114) /
        1000
    ) < threshold
  );
}

export const isDarkColor = colorHex => {
  if (colorHex === undefined) {
    return false;
  }
  const rgb = hexToRgb(colorHex);
  if (rgb === undefined) {
    return false;
  }
  return (
    Math.round(
      (parseInt(rgb.r) * 299 + parseInt(rgb.g) * 587 + parseInt(rgb.b) * 114) /
        1000
    ) < 125
  );
};

function validateConditionForString(condition, propertyValue, expressionValue) {
  let result = false;
  if (condition === CONDITION_NULL) {
    if (!propertyValue) {
      result = true;
    }
  } else if (condition === CONDITION_NOT_NULL) {
    if (propertyValue) {
      result = true;
    }
  } else if (condition === CONDITION_MATCHES) {
    if (propertyValue === expressionValue) {
      result = true;
    }
  } else if (condition === CONDITION_MATCHES_NOT) {
    if (propertyValue !== expressionValue) {
      result = true;
    }
  } else if (condition === CONDITION_STARTS_WITH) {
    if (propertyValue && propertyValue.startsWith(expressionValue)) {
      result = true;
    }
  } else if (condition === CONDITION_CONTAINS) {
    if (propertyValue && propertyValue.includes(expressionValue)) {
      result = true;
    }
  } else if (condition === CONDITION_CONTAINS_NOT) {
    if (!propertyValue || !propertyValue.includes(expressionValue)) {
      result = true;
    }
  } else if (condition === CONDITION_IN) {
    if (expressionValue && expressionValue.search(propertyValue) !== -1) {
      result = true;
    }
  } else if (condition === CONDITION_NOT_IN) {
    if (expressionValue && expressionValue.search(propertyValue) === -1) {
      result = true;
    }
  }
  return result;
}

function validateConditionForNumber(condition, propertyValue, expressionValue) {
  let result = false;
  if (condition === CONDITION_NULL) {
    if (!propertyValue) {
      result = true;
    }
  } else if (condition === CONDITION_NOT_NULL) {
    if (propertyValue) {
      result = true;
    }
  } else if (condition === CONDITION_MATCHES) {
    if (propertyValue && Number(propertyValue) === Number(expressionValue)) {
      result = true;
    }
  } else if (condition === CONDITION_MATCHES_NOT) {
    if (propertyValue && Number(propertyValue) !== Number(expressionValue)) {
      result = true;
    }
  } else if (condition === CONDITION_LESS) {
    if (propertyValue && Number(propertyValue) < Number(expressionValue)) {
      result = true;
    }
  } else if (condition === CONDITION_LE) {
    if (propertyValue && Number(propertyValue) <= Number(expressionValue)) {
      result = true;
    }
  } else if (condition === CONDITION_GREATER) {
    if (propertyValue && Number(propertyValue) > Number(expressionValue)) {
      result = true;
    }
  } else if (condition === CONDITION_GE) {
    if (propertyValue && Number(propertyValue) >= Number(expressionValue)) {
      result = true;
    }
  } else if (condition === CONDITION_CONTAINS) {
    if (
      propertyValue &&
      propertyValue.toString().search(expressionValue) !== -1
    ) {
      result = true;
    }
  } else if (condition === CONDITION_CONTAINS_NOT) {
    if (
      propertyValue &&
      propertyValue.toString().search(expressionValue) === -1
    ) {
      result = true;
    }
  } else if (condition === CONDITION_IN) {
    if (
      expressionValue &&
      expressionValue.search(propertyValue.toString()) !== -1
    ) {
      result = true;
    }
  } else if (condition === CONDITION_NOT_IN) {
    if (
      expressionValue &&
      expressionValue.search(propertyValue.toString()) === -1
    ) {
      result = true;
    }
  } else if (condition === CONDITION_STARTS_WITH) {
    if (
      propertyValue &&
      propertyValue.toString().indexOf(expressionValue) === 0
    ) {
      result = true;
    }
  }
  return result;
}

function validateConditionForBoolean(
  condition,
  propertyValue,
  expressionValue
) {
  let result = false;
  if (condition === CONDITION_NULL) {
    if (!propertyValue) {
      result = true;
    }
  } else if (condition === CONDITION_NOT_NULL) {
    if (propertyValue) {
      result = true;
    }
  } else if (condition === CONDITION_MATCHES) {
    try {
      if (
        expressionValue &&
        JSON.parse(propertyValue) ===
          JSON.parse(expressionValue.trim().toLowerCase())
      ) {
        result = true;
      }
    } catch (e) {}
  } else if (condition === CONDITION_MATCHES_NOT) {
    try {
      if (
        expressionValue &&
        JSON.parse(propertyValue) !==
          JSON.parse(expressionValue.trim().toLowerCase())
      ) {
        result = true;
      }
    } catch (e) {}
  }
  return result;
}

function validateConditionForDate(condition, propertyValue, expressionValue) {
  let result = false;
  if (condition === CONDITION_NULL) {
    if (!propertyValue) {
      result = true;
    }
  } else if (condition === CONDITION_NOT_NULL) {
    if (propertyValue) {
      result = true;
    }
  } else if (condition === CONDITION_MATCHES) {
    if (
      propertyValue &&
      expressionValue &&
      propertyValue.getTime() === expressionValue.getTime()
    ) {
      result = true;
    }
  } else if (condition === CONDITION_MATCHES_NOT) {
    if (
      propertyValue &&
      expressionValue &&
      propertyValue.getTime() !== expressionValue.getTime()
    ) {
      result = true;
    }
  } else if (condition === CONDITION_LESS) {
    if (
      propertyValue &&
      expressionValue &&
      propertyValue.getTime() < expressionValue.getTime()
    ) {
      result = true;
    }
  } else if (condition === CONDITION_LE) {
    if (
      propertyValue &&
      expressionValue &&
      propertyValue.getTime() <= expressionValue.getTime()
    ) {
      result = true;
    }
  } else if (condition === CONDITION_GREATER) {
    if (
      propertyValue &&
      expressionValue &&
      propertyValue.getTime() > expressionValue.getTime()
    ) {
      result = true;
    }
  } else if (condition === CONDITION_GE) {
    if (
      propertyValue &&
      expressionValue &&
      propertyValue.getTime() >= expressionValue.getTime()
    ) {
      result = true;
    }
  }
  return result;
}

function checkConditionForWO(rowInfo, rule) {
  let advExp;
  let cnt = 0;
  let result = false;
  const resultMap = {};
  const woFields = loadWOFields();

  if (isActive(rule)) {
    const { operand = [] } = rule;
    const rowLen = (operand && operand.length) || 0;
    while (cnt < rowLen) {
      const ruleRow = operand[cnt];
      let {
        compare: condition,
        value: expressionValue,
        fieldType,
        property
      } = ruleRow;

      const fieldDesc = woFields[property];
      if (!fieldDesc || !fieldType) {
        cnt += 1;
        continue;
      }

      fieldType = fieldType.toUpperCase();
      const { original = {} } = rowInfo;
      let propertyValue = original[property];

      const isDate = fieldType === "DATE";
      const isTime = fieldType === "TIME";
      const isBoolean = fieldType === "BOOLEAN";
      const isDateTime = fieldType === "DATETIME";
      const isReference = fieldType === "ID" || fieldType === "REFERENCE";
      const isNumber =
        fieldType === "INT" ||
        fieldType === "INTEGER" ||
        fieldType === "DOUBLE" ||
        fieldType === "DECIMAL";
      const isString =
        fieldType === "STRING" ||
        fieldType === "EMAIL" ||
        fieldType === "URL" ||
        fieldType === "COMBOBOX" ||
        fieldType === "PHONE" ||
        fieldType === "TEXTAREA";
      const isPickList = fieldType === "PICKLIST";

      if (isString) {
        resultMap[`${cnt}`] = validateConditionForString(
          condition,
          propertyValue,
          expressionValue
        );
      } else if (isPickList) {
        const { refField } = fieldDesc;
        const listOfValues = JSON.parse(refField) || {};
        propertyValue = listOfValues[propertyValue] || propertyValue;
        resultMap[`${cnt}`] = validateConditionForString(
          condition,
          propertyValue,
          expressionValue
        );
      } else if (isNumber) {
        resultMap[`${cnt}`] = validateConditionForNumber(
          condition,
          propertyValue,
          expressionValue
        );
      } else if (isBoolean) {
        resultMap[`${cnt}`] = validateConditionForBoolean(
          condition,
          propertyValue,
          expressionValue
        );
      } else if (isReference) {
        resultMap[`${cnt}`] = validateConditionForString(
          condition,
          propertyValue,
          expressionValue
        );
      } else if (isTime) {
        propertyValue = propertyValue
          ? moment(propertyValue, TIME_FORMAT)
              .utc()
              .toDate()
          : undefined;
        expressionValue = expressionValue
          ? moment(expressionValue, TIME_FORMAT)
              .utc()
              .toDate()
          : undefined;
        resultMap[`${cnt}`] = validateConditionForDate(
          condition,
          propertyValue,
          expressionValue
        );
      } else if (isDate) {
        propertyValue = propertyValue
          ? moment(propertyValue, getUserTimeSettings("dateFormat"))
              .utc()
              .startOf("day")
              .toDate()
          : undefined;
        expressionValue = expressionValue
          ? moment(expressionValue, DATE_FORMAT)
              .utc()
              .startOf("day")
              .toDate()
          : undefined;
        resultMap[`${cnt}`] = validateConditionForDate(
          condition,
          propertyValue,
          expressionValue
        );
      } else if (isDateTime) {
        propertyValue = propertyValue
          ? moment(propertyValue, getUserTimeSettings("dateTimeFormat"))
              .utc()
              .toDate()
          : undefined;
        expressionValue = expressionValue
          ? moment(expressionValue, DATE_TIME_24H_FORMAT)
              .utc()
              .toDate()
          : undefined;
        resultMap[`${cnt}`] = validateConditionForDate(
          condition,
          propertyValue,
          expressionValue
        );
      } else {
        resultMap[`${cnt}`] = false;
      }
      cnt += 1;
    }

    advExp = rule.expression.trim().toUpperCase();
    if (advExp !== "" && advExp.search("null") === -1) {
      for (let i = 1; i <= rule.operand.length; i += 1) {
        advExp = advExp.replace(
          new RegExp(`\\b${i}\\b`, "g"),
          resultMap[`${i - 1}`].toString()
        );
      }
      advExp = advExp.replace(/AND/g, "&&").replace(/OR/g, "||");
      result = eval(advExp);
    } // If no expression is present the AND all the results
    else {
      result = true;
      for (let i = 0; i < rule.operand.length; i += 1) {
        result = result && resultMap[`${i}`];
      }
    }
  }
  return result;
}

export function applyWOColorRule(rowInfo, rules) {
  let rowColor = "#ffffff";
  for (let i = 0; i < rules.length; i += 1) {
    const rule = rules[i];
    const result = checkConditionForWO(rowInfo, rule);
    if (result) {
      const { color } = rule;
      rowColor = color;
      break;
    }
  }
  return rowColor;
}

function checkConditionForEvent(rule, event, woInfo) {
  let result = false;
  let vo;
  let fieldType;
  let propertyValue;
  let condition;
  let expressionValue;
  let cnt = 0;
  const resultMap = {};
  let advExp;

  const woFields = loadWOFields();
  const eventFields = loadEventFields();

  if (rule.status === "TAG168") {
    const { operand = [] } = rule;
    const rowLen = (operand && operand.length) || 0;
    while (cnt < rowLen) {
      const ruleRow = operand[cnt];
      const { property, type } = ruleRow;
      if (type !== "EVENT") {
        const { WOId } = event;
        if (WOId) {
          const woFieldDesc = woFields[property];
          if (!woFieldDesc) {
            cnt += 1;
            continue;
          }
          vo = woInfo[WOId];
        }
      } else {
        const evtFieldDesc = eventFields[property];
        if (!evtFieldDesc) {
          cnt += 1;
          continue;
        }
        vo = event;
      }

      if (vo) {
        condition = ruleRow.compare;
        expressionValue = ruleRow.value;
        propertyValue = vo[property];
      } else {
        resultMap[`${cnt}`] = false;
        cnt += 1;
        continue;
      }

      fieldType = ruleRow.fieldType.toUpperCase();
      const isString =
        fieldType === "STRING" ||
        fieldType === "EMAIL" ||
        fieldType === "URL" ||
        fieldType === "COMBOBOX" ||
        fieldType === "PHONE" ||
        fieldType === "TEXTAREA";
      const isPickList = fieldType === "PICKLIST";

      const isTime = fieldType === "TIME";
      const isNumber =
        fieldType === "INT" ||
        fieldType === "INTEGER" ||
        fieldType === "DOUBLE" ||
        fieldType === "DECIMAL";
      const isBoolean = fieldType === "BOOLEAN";
      const isReference = fieldType === "ID" || fieldType === "REFERENCE";
      const isDate = fieldType === "DATE";
      const isDateTime = fieldType === "DATETIME";

      if (isString) {
        resultMap[`${cnt}`] = validateConditionForString(
          condition,
          propertyValue,
          expressionValue
        );
      } else if (isPickList) {
        const fieldMetaData = type !== "EVENT" ? woFields : eventFields;
        const fieldDesc = fieldMetaData[property];
        const { refField } = fieldDesc;
        const listOfValues = JSON.parse(refField) || {};
        propertyValue = listOfValues[propertyValue] || propertyValue;
        resultMap[`${cnt}`] = validateConditionForString(
          condition,
          propertyValue,
          expressionValue
        );
      } else if (isNumber) {
        resultMap[`${cnt}`] = validateConditionForNumber(
          condition,
          propertyValue,
          expressionValue
        );
      } else if (isBoolean) {
        resultMap[`${cnt}`] = validateConditionForBoolean(
          condition,
          propertyValue,
          expressionValue
        );
      } else if (isReference) {
        resultMap[`${cnt}`] = validateConditionForString(
          condition,
          propertyValue,
          expressionValue
        );
      } else if (isTime) {
        propertyValue = propertyValue
          ? moment(propertyValue, moment.HTML5_FMT.TIME_MS)
              .utc()
              .toDate()
          : undefined;
        expressionValue = expressionValue
          ? moment(expressionValue, TIME_FORMAT)
              .utc()
              .toDate()
          : undefined;
        resultMap[`${cnt}`] = validateConditionForDate(
          condition,
          propertyValue,
          expressionValue
        );
      } else if (isDate) {
        propertyValue = propertyValue
          ? moment(propertyValue, getUserTimeSettings("dateFormat"))
              .utc()
              .startOf("day")
              .toDate()
          : undefined;
        expressionValue = expressionValue
          ? moment(expressionValue, DATE_FORMAT)
              .utc()
              .startOf("day")
              .toDate()
          : undefined;
        resultMap[`${cnt}`] = validateConditionForDate(
          condition,
          propertyValue,
          expressionValue
        );
      } else if (isDateTime) {
        propertyValue = propertyValue
          ? moment(propertyValue, getUserTimeSettings("dateTimeFormat"))
              .utc()
              .toDate()
          : undefined;
        expressionValue = expressionValue
          ? moment(expressionValue, DATE_TIME_24H_FORMAT)
              .utc()
              .toDate()
          : undefined;
        resultMap[`${cnt}`] = validateConditionForDate(
          condition,
          propertyValue,
          expressionValue
        );
      } else {
        resultMap[`${cnt}`] = false;
      }
      cnt += 1;
    }

    advExp = rule.expression.trim().toUpperCase();
    if (advExp !== "" && advExp.search("null") === -1) {
      for (let i = 1; i <= rule.operand.length; i += 1) {
        advExp = advExp.replace(
          new RegExp(`${i}`, "g"),
          resultMap[`${i - 1}`].toString()
        );
      }

      advExp = advExp.replace(/AND/g, "&&").replace(/OR/g, "||");
      advExp = advExp.replace(/true/g, "T").replace(/false/g, "F");

      let resultStr = advExp;
      while (resultStr.length !== 1) {
        // replace T && F or (T && F) with F
        resultStr = resultStr.replace(/(T && F)|(\(T && F\))/gi, "F");
        resultStr = resultStr.replace(/(F && T)|(\(F && T\))/gi, "F");
        resultStr = resultStr.replace(/(F && F)|(\(F && F\))/gi, "F");
        resultStr = resultStr.replace(/(T && T)|(\(T && T\))/gi, "T");
        resultStr = resultStr.replace(/(T \|\| T)|(\(T \|\| T\))/gi, "T");
        resultStr = resultStr.replace(/(T \|\| F)|(\(T \|\| F\))/gi, "T");
        resultStr = resultStr.replace(/(F \|\| T)|(\(F \|\| T\))/gi, "T");
        resultStr = resultStr.replace(/(F \|\| F)|(\(F \|\| F\))/gi, "F");
        resultStr = resultStr.replace(/!T/g, "F");
        resultStr = resultStr.replace(/!F/g, "T");
        // replace (F) with F
        resultStr = resultStr.replace(/\(F\)/g, "F");
        resultStr = resultStr.replace(/\(T\)/g, "T");
      }
      if (resultStr === "T") result = true;
      else if (resultStr === "F") result = false;
    } else {
      result = true;
      for (let i = 0; i < operand.length; i += 1) {
        result = result && resultMap[`${i}`];
      }
    }
  }
  return result;
}

export function applyEventColorRule(woInfo, event, rulesNColor) {
  let bgColor;
  let colorApplied = false;
  const {
    eventRules = [],
    defaultEventColor,
    defaultWOEventColor,
    relatedEventColor
  } = rulesNColor || {};

  const { isWorkOrder, relatedEvent } = event || {};
  if (isWorkOrder) {
    bgColor = defaultWOEventColor;
  } else {
    bgColor = defaultEventColor;
  }
  if (relatedEvent) bgColor = relatedEventColor;

  const eventRulesForEvents = [];
  const eventRulesForCombined = [];
  const eventRulesForWOrkOrder = [];

  flatMap(eventRules, ruleObj => {
    const { operand = [], status } = ruleObj;
    if (operand && operand.length) {
      const eventType = operand.find(oprnd => oprnd.type === "EVENT");
      const woType = operand.find(oprnd => oprnd.type === "WO");

      if (eventType && woType) {
        ruleObj.ruleType = "CombinedRule";
      } else if (eventType) {
        ruleObj.ruleType = "EventRule";
      } else if (woType) {
        ruleObj.ruleType = "WorkOrderRule";
      }
    }

    if (ruleObj.ruleType && status === TAG168) {
      if (ruleObj.ruleType === "WorkOrderRule") {
        eventRulesForWOrkOrder.push(ruleObj);
      }
      if (ruleObj.ruleType === "EventRule") {
        eventRulesForEvents.push(ruleObj);
        eventRulesForCombined.push(ruleObj);
      }
      if (ruleObj.ruleType === "CombinedRule") {
        eventRulesForCombined.push(ruleObj);
      }
    }
  });

  let RuleTypeNonWorkOrder = false;
  let RuleTypeWorkOrderEvent = false;
  if (isWorkOrder) {
    RuleTypeWorkOrderEvent = true;
  } else {
    RuleTypeNonWorkOrder = true;
  }

  if (RuleTypeWorkOrderEvent) {
    flatMap(eventRules, rule => {
      const result = colorApplied
        ? false
        : checkConditionForEvent(rule, event, woInfo);
      if (result) {
        bgColor = rule.color;
        colorApplied = true;
        return bgColor;
      }
      if (isWorkOrder && !colorApplied) {
        bgColor = defaultWOEventColor;
        return bgColor;
      }
    });
  }

  if (RuleTypeNonWorkOrder) {
    flatMap(eventRulesForCombined, rule => {
      const result = checkConditionForEvent(rule, event, woInfo);
      if (result) {
        bgColor = rule.color;
        colorApplied = true;
        return bgColor;
      }
      if (isWorkOrder && !colorApplied) {
        bgColor = defaultWOEventColor;
        return bgColor;
      }
    });
  }
  return bgColor;
}

const getDriveTimeEvents = (event, eventColor) => {
  let beforeDriveTime = 0;
  let afterDriveTime = 0;
  const driveTimeEvents = [];
  const {
    Driving_Time: driveTimeBefore = 0,
    Driving_Time_Home: driveTimeAfter = 0,
    startDateTime,
    endDateTime,
    TechId: resourceId
  } = event;
  try {
    beforeDriveTime = Math.round(parseInt(driveTimeBefore, 10));
    afterDriveTime = Math.round(parseInt(driveTimeAfter, 10));
  } catch (e) {
    console.log(e);
  }
  if (beforeDriveTime) {
    driveTimeEvents.push({
      endDate: moment(startDateTime).add(beforeDriveTime, "minutes"),
      eventColor,
      isDriveStartTime: true,
      name: "",
      resourceId,
      startDate: moment(startDateTime)
    });
  } else {
    driveTimeEvents.push(null);
  }
  if (afterDriveTime) {
    driveTimeEvents.push({
      endDate: moment(endDateTime),
      eventColor,
      isDriveEndTime: true,
      name: "",
      resourceId,
      startDate: moment(endDateTime).subtract(afterDriveTime, "minutes")
    });
  }
  return driveTimeEvents;
};

const getOverHeadTimeEvents = (event, eventColor) => {
  const overHeadTimeEvents = [];
  // OverHead Time events should be displayed on based on SET003 status.
  const SET003 = JSON.parse(getSettingValue(DCON005_SET003).toLowerCase());
  if (SET003) {
    let beforeDriveTime = 0;
    let afterDriveTime = 0;
    let beforeOverHeadTime = 0;
    let afterOverHeadTime = 0;
    const {
      Driving_Time: driveTimeBefore = 0,
      Driving_Time_Home: driveTimeAfter = 0,
      Overhead_Time_Before: overHeadTimeBefore = 0,
      Overhead_Time_After: overHeadTimeAfter = 0,
      startDateTime,
      endDateTime,
      TechId: resourceId
    } = event;
    try {
      beforeDriveTime = Math.round(parseInt(driveTimeBefore, 10));
      afterDriveTime = Math.round(parseInt(driveTimeAfter, 10));
      beforeOverHeadTime = Math.round(parseInt(overHeadTimeBefore, 10));
      afterOverHeadTime = Math.round(parseInt(overHeadTimeAfter, 10));
    } catch (e) {
      console.log(e);
    }
    if (beforeOverHeadTime) {
      overHeadTimeEvents.push({
        endDate: beforeDriveTime
          ? moment(startDateTime).add(
              beforeDriveTime + beforeOverHeadTime,
              "minutes"
            )
          : moment(startDateTime).add(beforeOverHeadTime, "minutes"),
        eventColor,
        isOverHeadStartTime: true,
        name: "",
        resourceId,
        startDate: beforeDriveTime
          ? moment(startDateTime).add(beforeDriveTime, "minutes")
          : moment(startDateTime)
      });
    } else {
      overHeadTimeEvents.push(null);
    }
    if (afterOverHeadTime) {
      overHeadTimeEvents.push({
        endDate: afterDriveTime
          ? moment(endDateTime).subtract(afterDriveTime, "minutes")
          : moment(endDateTime),
        eventColor,
        isOverHeadEndTime: true,
        name: "",
        resourceId,
        startDate: afterDriveTime
          ? moment(endDateTime).subtract(
              afterDriveTime + afterOverHeadTime,
              "minutes"
            )
          : moment(endDateTime).subtract(afterOverHeadTime, "minutes")
      });
    }
  }
  return overHeadTimeEvents;
};

const loadWOFields = () => {
  const state = store.getState();
  const { metaData } = state;
  const { workOrderFields } = metaData;
  const { content } = workOrderFields;
  return content;
};

const loadEventFields = () => {
  const state = store.getState();
  const { metaData } = state;
  const { eventFields } = metaData;
  const { content } = eventFields;
  return content;
};

const loadSettings = () => {
  const state = store.getState();
  const { metaData } = state;
  const { appSettings } = metaData;
  const { content } = appSettings;
  return content;
};

const SET038 = "DCON001_SET038";
const SET039 = "DCON001_SET039";
const SET040 = "DCON001_SET040";
const SET041 = "DCON001_SET041";
const SET042 = "DCON001_SET042";
const SET043 = "DCON001_SET043";
const SET044 = "DCON001_SET044";
const SET045 = "DCON001_SET045";
const SET046 = "DCON001_SET046";
const SET047 = "DCON001_SET047";

const getEventFieldDetails = (apiName, settingKey) => {
  let field;
  const fieldApi = apiName.replace(`/^${ORG_NAMESPACE}__|__c$/gi`, "");
  const evtFields = loadEventFields();
  field = evtFields[apiName];
  if (!field) {
    if (fieldApi === "SM_Latitude") {
      field = evtFields.latitude;
    } else if (fieldApi === "SM_Longitude") {
      field = evtFields.longitude;
    } else if (fieldApi === "SM_Location") {
      field = evtFields.location;
    }
  }
  if (field) {
    field.settingKey = settingKey;
    field.eventField = true;
  }
  return field;
};

const getEventFields = () => {
  const settings = loadSettings();
  const fieldUpdateSettings = [
    SET038,
    SET039,
    SET040,
    SET041,
    SET042,
    SET043,
    SET044,
    SET045,
    SET046,
    SET047
  ];

  const fields = compact(
    fieldUpdateSettings.map(key => {
      if (settings[key]) {
        const apiName = settings[key];
        if (apiName.startsWith("Event.")) {
          return getEventFieldDetails(apiName.replace("Event.", ""), key);
        }
      }
    })
  );

  return fields;
};

const evaluvateEventRule = (
  rule = {},
  event = {},
  workOrder = {},
  woFields = {}
) => {
  let result = false;
  let vo;
  // let fieldType;
  let propertyValue;
  let condition;
  let expressionValue;
  const resultMap = {};
  let advExp;

  const { expression, operand } = rule;
  let expnIndexs = range(operand.length);
  if (!isEmpty(expression)) {
    const expressionIndexs = compact(
      expression
        .trim()
        .replace(/\D+/g, ",")
        .split(",")
    );
    expnIndexs = flatMap(
      expressionIndexs,
      expIndex => parseInt(expIndex.trim(), 10) - 1
    );
  }
  const eventFields = loadEventFields();
  expnIndexs.forEach(expnIndex => {
    const ruleRow = operand[expnIndex];
    // In case if expn is missing its due to AutoCorrect. Hence always true.
    if (!ruleRow) {
      resultMap[`${expnIndex}`] = true;
      return;
    }
    let { compare, fieldType, property, type, value } = ruleRow;
    if (type !== "EVENT") {
      const woFieldDesc = woFields[property];
      if (!woFieldDesc) {
        resultMap[`${expnIndex}`] = false;
        return;
      }
      vo = workOrder;
    } else {
      const evtFieldDesc = eventFields[property];
      if (!evtFieldDesc) {
        resultMap[`${expnIndex}`] = false;
        return;
      }
      const { value, wrapperName } = evtFieldDesc;
      property = wrapperName || value;
      vo = event;
    }

    // In case if the WO/Event doesn't have any fields. Ignore the expression and mark it as failed.
    if (Object.keys(vo).length) {
      condition = compare;
      expressionValue = value;
    } else {
      resultMap[`${expnIndex}`] = false;
      return;
    }

    fieldType = fieldType.toUpperCase();
    const isTime = fieldType === "TIME";
    const isDate = fieldType === "DATE";
    const isBoolean = fieldType === "BOOLEAN";
    const isDateTime = fieldType === "DATETIME";
    const isReference = fieldType === "ID" || fieldType === "REFERENCE";
    const isNumber =
      fieldType === "INT" ||
      fieldType === "INTEGER" ||
      fieldType === "DOUBLE" ||
      fieldType === "DECIMAL";
    const isString =
      fieldType === "STRING" ||
      fieldType === "EMAIL" ||
      fieldType === "URL" ||
      fieldType === "COMBOBOX" ||
      fieldType === "PHONE" ||
      fieldType === "TEXTAREA";
    const isPickList = fieldType === "PICKLIST";
    let lstKey = "";
    let settingValue = "";
    const fieldKeyObj = [
      { key: "SET038", value: "DCON001_SET038" },
      { key: "SET039", value: "DCON001_SET039" },
      { key: "SET040", value: "DCON001_SET040" },
      { key: "SET041", value: "DCON001_SET041" },
      { key: "SET042", value: "DCON001_SET042" },
      { key: "SET043", value: "DCON001_SET043" },
      { key: "SET044", value: "DCON001_SET044" },
      { key: "SET045", value: "DCON001_SET045" },
      { key: "SET046", value: "DCON001_SET046" },
      { key: "SET047", value: "DCON001_SET047" }
    ];

    propertyValue = vo[property];

    if (type == "EVENT" && !propertyValue) {
      const eventFieldUpdates = getEventFields();
      const evtField = filter(eventFieldUpdates, { value: property });
      const evtFieldDesc = evtField.length ? evtField[0] : [];
      if (evtFieldDesc) {
        const { settingKey } = evtFieldDesc;
        const { lstKeyValuePair } = vo;
        lstKey = find(fieldKeyObj, { value: settingKey })
          ? find(fieldKeyObj, { value: settingKey }).key
          : "";
        settingValue =
          lstKey && lstKeyValuePair
            ? find(lstKeyValuePair, { key: lstKey })
            : "";
        propertyValue = settingValue ? settingValue.value : "";
      }
    }

    if (isString) {
      resultMap[`${expnIndex}`] = validateConditionForString(
        condition,
        propertyValue,
        expressionValue
      );
    } else if (isPickList) {
      const fieldMetaData = type !== "EVENT" ? woFields : eventFields;
      const fieldDesc = fieldMetaData[property];
      const { refField } = fieldDesc;
      const listOfValues = JSON.parse(refField) || {};
      propertyValue = listOfValues[propertyValue] || propertyValue;
      resultMap[`${expnIndex}`] = validateConditionForString(
        condition,
        propertyValue,
        expressionValue
      );
    } else if (isNumber) {
      resultMap[`${expnIndex}`] = validateConditionForNumber(
        condition,
        propertyValue,
        expressionValue
      );
    } else if (isBoolean) {
      resultMap[`${expnIndex}`] = validateConditionForBoolean(
        condition,
        propertyValue,
        expressionValue
      );
    } else if (isReference) {
      const { property } = ruleRow;
      const fieldDesc =
        type !== "EVENT"
          ? woFields[property] || {}
          : eventFields[property] || {};
      const { refField } = fieldDesc;
      if (property.endsWith("__c")) {
        propertyValue = vo[property.replace("__c", "__r")];
      } else if (property.endsWith(ID)) {
        propertyValue = vo[property.replace(ID, "")] || propertyValue;
      }
      propertyValue = isObject(propertyValue)
        ? propertyValue[refField || NAME]
        : propertyValue;
      resultMap[`${expnIndex}`] = validateConditionForString(
        condition,
        propertyValue,
        expressionValue
      );
    } else if (isTime) {
      propertyValue = propertyValue
        ? moment(propertyValue, moment.HTML5_FMT.TIME_MS)
            .utc()
            .toDate()
        : undefined;
      expressionValue = expressionValue
        ? moment(expressionValue, TIME_FORMAT)
            .utc()
            .toDate()
        : undefined;
      resultMap[`${expnIndex}`] = validateConditionForDate(
        condition,
        propertyValue,
        expressionValue
      );
    } else if (isDate) {
      propertyValue = propertyValue
        ? moment(propertyValue, [
            "DD-MM-YYYY",
            "DD.MM.YYYY",
            "YYYY-MM-DD",
            getUserTimeSettings("dateFormat")
          ])
            .startOf("day")
            .toDate()
        : undefined;
      expressionValue = expressionValue
        ? moment(expressionValue, DATE_FORMAT)
            .startOf("day")
            .toDate()
        : undefined;
      resultMap[`${expnIndex}`] = validateConditionForDate(
        condition,
        propertyValue,
        expressionValue
      );
    } else if (isDateTime) {
      propertyValue = propertyValue
        ? moment(propertyValue, getUserTimeSettings("dateTimeFormat"))
            .utc()
            .toDate()
        : undefined;
      expressionValue = expressionValue
        ? moment(expressionValue, DATE_TIME_24H_FORMAT)
            .utc()
            .toDate()
        : undefined;
      resultMap[`${expnIndex}`] = validateConditionForDate(
        condition,
        propertyValue,
        expressionValue
      );
    } else {
      resultMap[`${expnIndex}`] = false;
    }
  });

  const { length } = expnIndexs;
  if (length > 1) {
    const isAdvExpn = isEmpty(expression);
    advExp = !isAdvExpn
      ? expression.trim().toUpperCase()
      : expnIndexs.join(" AND ");
    expnIndexs.forEach(expnIndex => {
      // advExp = advExp.replace(new RegExp(`${isAdvExpn ? expnIndex : expnIndex + 1 }`, 'g'), resultMap[`${expnIndex}`].toString());
      const value = isAdvExpn ? expnIndex : expnIndex + 1;
      advExp = advExp.replace(
        new RegExp(`\\b${value}\\b`, "g"),
        resultMap[`${expnIndex}`].toString()
      );
    });
    advExp = advExp.replace(/AND/g, "&&").replace(/OR/g, "||");
    result = eval(advExp);
    return result;
  }
  return resultMap[0] || false;
};

export function getEventColorInfo(event, workOrder, eventColorRules = {}) {
  const {
    eventRules,
    defaultEventColor,
    defaultWOEventColor,
    overNightStayColor,
    relatedEventColor,
    driveTimeEventColor,
    overHeadEventColor
  } = eventColorRules;

  let eventColor;
  const agenda = [];
  let isDriveStartTime = false;
  let isDriveEndTime = false;
  let isOverHeadStartTime = false;
  let isOverHeadEndTime = false;
  let isOverNightStay = false;

  let beforeDriveTimeEvent = null;
  let afterDriveTimeEvent = null;
  const beforeOverHeadTimeEvent = null;
  const afterOverHeadTimeEvent = null;

  if (event.isWorkOrder) {
    eventColor = convertUint2Hex(defaultWOEventColor);
  } else if (event.relatedEvent) {
    eventColor = convertUint2Hex(relatedEventColor);
  } else {
    eventColor = convertUint2Hex(defaultEventColor);
  }

  const {
    TechId: resourceId,
    startDateTime,
    endDateTime,
    subject: name
  } = event;

  const { length } = eventRules;
  const woFields = loadWOFields();
  for (let i = 0; i < length; i += 1) {
    const eventRule = eventRules[i];
    if (
      isActive(eventRule) &&
      evaluvateEventRule(eventRule, event, workOrder, woFields)
    ) {
      const { color } = eventRule;
      eventColor = convertUint2Hex(color);
      break;
    }
  }

  if (event.isWorkOrder) {
    const driveTimeEvents = getDriveTimeEvents(
      event,
      convertUint2Hex(driveTimeEventColor)
    );
    [beforeDriveTimeEvent = null, afterDriveTimeEvent = null] = driveTimeEvents;
    if (beforeDriveTimeEvent) {
      isDriveStartTime = true;
      agenda.push(beforeDriveTimeEvent);
    }
    if (afterDriveTimeEvent) {
      isDriveEndTime = true;
      //agenda.push(afterDriveTimeEvent);
    }

    const overHeadTimeEvents = getOverHeadTimeEvents(
      event,
      convertUint2Hex(overHeadEventColor)
    );
    const [
      beforeOverHeadTimeEvent = null,
      afterOverHeadTimeEvent = null
    ] = overHeadTimeEvents;
    if (beforeOverHeadTimeEvent) {
      isOverHeadStartTime = true;
      agenda.push(beforeOverHeadTimeEvent);
    }
    if (afterOverHeadTimeEvent) {
      isOverHeadEndTime = true;
      //agenda.push(afterOverHeadTimeEvent);
    }

    const actualEvent = {
      // eslint-disable-next-line no-nested-ternary
      endDate: isOverHeadEndTime
        ? afterOverHeadTimeEvent.startDate
        : isDriveEndTime
        ? afterDriveTimeEvent.startDate
        : moment(endDateTime),
      eventColor,
      isActualEvent: true,
      name,
      resourceId,
      // eslint-disable-next-line no-nested-ternary
      startDate: isOverHeadStartTime
        ? beforeOverHeadTimeEvent.endDate
        : isDriveStartTime
        ? beforeDriveTimeEvent.endDate
        : moment(startDateTime)
    };
    if (
      isDriveStartTime ||
      isDriveEndTime ||
      isOverHeadStartTime ||
      isOverHeadEndTime
    ) {
      agenda.push(actualEvent);
    }
    if (afterOverHeadTimeEvent) {
      //isOverHeadEndTime = true;
      agenda.push(afterOverHeadTimeEvent);
    }
    if (afterDriveTimeEvent) {
      //isDriveEndTime = true;
      agenda.push(afterDriveTimeEvent);
    }
  } else {
    const { Type } = event;
    if (Type === OVERNIGHT_STAY_EVENT_TYPE) {
      isOverNightStay = true;
      eventColor = convertUint2Hex(overNightStayColor);
    }
  }
  let eventBorderColor = LightenDarkenColor(eventColor, -20);
  if (lightOrDark(eventColor) !== "light") {
    eventBorderColor = LightenDarkenColor(eventColor, 20);
  }
  const style = `border: ${1}px solid ${eventBorderColor};`;
  return {
    actualEndDate: new Date(endDateTime),
    actualStartDate: new Date(startDateTime),
    afterDriveTimeEvent,
    afterOverHeadTimeEvent,
    agenda,
    beforeDriveTimeEvent,
    beforeOverHeadTimeEvent,
    eventColor,
    isDriveEndTime,
    isDriveStartTime,
    isOverHeadEndTime,
    isOverHeadStartTime,
    isOverNightStay,
    style
  };
}

export const LightenDarkenColor = (col, amt) => {
  let usePound = false;

  if (col[0] == "#") {
    col = col.slice(1);
    usePound = true;
  }

  const num = parseInt(col, 16);

  let r = (num >> 16) + amt;

  if (r > 255) r = 255;
  else if (r < 0) r = 0;

  let b = ((num >> 8) & 0x00ff) + amt;

  if (b > 255) b = 255;
  else if (b < 0) b = 0;

  let g = (num & 0x0000ff) + amt;

  if (g > 255) g = 255;
  else if (g < 0) g = 0;

  return (usePound ? "#" : "") + (g | (b << 8) | (r << 16)).toString(16);
};

export const shadeColor = (color, percent) => {
  let R = parseInt(color.substring(1, 3), 16);
  let G = parseInt(color.substring(3, 5), 16);
  let B = parseInt(color.substring(5, 7), 16);

  R = parseInt((R * (100 + percent)) / 100);
  G = parseInt((G * (100 + percent)) / 100);
  B = parseInt((B * (100 + percent)) / 100);

  R = R < 255 ? R : 255;
  G = G < 255 ? G : 255;
  B = B < 255 ? B : 255;

  const RR = R.toString(16).length == 1 ? `0${R.toString(16)}` : R.toString(16);
  const GG = G.toString(16).length == 1 ? `0${G.toString(16)}` : G.toString(16);
  const BB = B.toString(16).length == 1 ? `0${B.toString(16)}` : B.toString(16);

  return `#${RR}${GG}${BB}`;
};
