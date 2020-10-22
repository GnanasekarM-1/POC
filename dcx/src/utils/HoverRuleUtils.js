// /////// Hover Rules Evaluator //////////////
// Version      : 0.2
// Date         : 23 Sep 2019
// Copyright(c) : ServiceMax, Inc
// /////// Hover Rules Evaluator //////////////
import store from "store";
import {
  ID,
  NAME,
  PICKLIST,
  REFERENCE,
  DATE_FIELD_TYPE,
  DATETIME_FIELD_TYPE
} from "constants/AppConstants";
import { getUserTimeSettings } from "utils/DateAndTimeUtils";
import moment from "moment";

function toType(obj) {
  return {}.toString
    .call(obj)
    .match(/\s([a-zA-Z]+)/)[1]
    .toLowerCase();
}

function getStringRepresentation(value) {
  const t = toType(value);
  let ret = "";

  if (t == "string") {
    ret = `"${value}"`;
  } else {
    ret = value ? value.toString() : value;
  }
  return ret;
}

function replaceEverything(template, obj) {
  let ret = template;
  for (const key in obj) {
    ret = ret.replace(new RegExp(`@${key}@`, "gi"), obj[key]);
  }
  return ret;
}

// //////// end - utilities ///////

// ////// constructors ////////////
const constructors = {
  eq: equalsC,
  ne: notEqualsC,
  gt: greaterC,
  ge: greaterOrEqualsC,
  lt: lesserC,
  le: lesserOrEqualsC,
  starts: startsWithC,
  contains: containsC,
  notcontain: notContainsC,
  in: inC,
  notin: notInC,
  isnull: isNullC,
  isnotnull: isNotNullC
};

function equalsC(line) {
  const template = "EQUALS($D.@lvalue@, @rvalue@)";
  const rvalue = getStringRepresentation(line.fieldValue);
  const ret = replaceEverything(template, { lvalue: line.fieldName, rvalue });
  return ret;
}

function notEqualsC(line) {
  const template = "NOT_EQUALS($D.@lvalue@, @rvalue@)";
  const rvalue = getStringRepresentation(line.fieldValue);
  const ret = replaceEverything(template, { lvalue: line.fieldName, rvalue });
  return ret;
}

function greaterC(line) {
  const template = "GREATER_THAN($D.@lvalue@, @rvalue@)";
  const rvalue = getStringRepresentation(line.fieldValue);
  const ret = replaceEverything(template, { lvalue: line.fieldName, rvalue });
  return ret;
}

function greaterOrEqualsC(line) {
  const template = "GREATER_OR_EQUALS($D.@lvalue@, @rvalue@)";
  const rvalue = getStringRepresentation(line.fieldValue);
  const ret = replaceEverything(template, { lvalue: line.fieldName, rvalue });
  return ret;
}

function lesserC(line) {
  const template = "LESSER_THAN($D.@lvalue@, @rvalue@)";
  const rvalue = getStringRepresentation(line.fieldValue);
  const ret = replaceEverything(template, { lvalue: line.fieldName, rvalue });
  return ret;
}

function lesserOrEqualsC(line) {
  const template = "LESSER_OR_EQUALS($D.@lvalue@, @rvalue@)";
  const rvalue = getStringRepresentation(line.fieldValue);
  const ret = replaceEverything(template, { lvalue: line.fieldName, rvalue });
  return ret;
}

function startsWithC(line) {
  const template = "STARTS_WITH($D.@lvalue@, @rvalue@)";
  const rvalue = getStringRepresentation(line.fieldValue);
  const ret = replaceEverything(template, { lvalue: line.fieldName, rvalue });
  return ret;
}

function containsC(line) {
  const template = "CONTAINS($D.@lvalue@, @rvalue@)";
  const rvalue = getStringRepresentation(line.fieldValue);
  const ret = replaceEverything(template, { lvalue: line.fieldName, rvalue });
  return ret;
}

function notContainsC(line) {
  const template = "NOT_CONTAINS($D.@lvalue@, @rvalue@)";
  const rvalue = getStringRepresentation(line.fieldValue);
  const ret = replaceEverything(template, { lvalue: line.fieldName, rvalue });
  return ret;
}

function inC(line) {
  const template = "IN($D.@lvalue@, @rvalue@)";
  const rvalue = getStringRepresentation(line.fieldValue);
  const ret = replaceEverything(template, { lvalue: line.fieldName, rvalue });
  return ret;
}

function notInC(line) {
  const template = "NOT_IN($D.@lvalue@, @rvalue@)";
  const rvalue = getStringRepresentation(line.fieldValue);
  const ret = replaceEverything(template, { lvalue: line.fieldName, rvalue });
  return ret;
}

function isNullC(line) {
  const template = "IS_NULL($D.@value@)";
  const ret = replaceEverything(template, { value: line.fieldName });
  return ret;
}

function isNotNullC(line) {
  const template = "IS_NOT_NULL($D.@value@)";
  const ret = replaceEverything(template, { value: line.fieldName });
  return ret;
}
// ////// end - constructors //////

// ////// expression evaluators for constructors //////
function EQUALS(lvalue, rvalue) {
  return lvalue == rvalue;
}

function NOT_EQUALS(lvalue, rvalue) {
  return lvalue != rvalue;
}

function GREATER_THAN(lvalue, rvalue) {
  return lvalue && lvalue > rvalue;
}

function GREATER_OR_EQUALS(lvalue, rvalue) {
  return lvalue && lvalue >= rvalue;
}

function LESSER_THAN(lvalue, rvalue) {
  return lvalue && lvalue < rvalue;
}

function LESSER_OR_EQUALS(lvalue, rvalue) {
  return lvalue && lvalue <= rvalue;
}

function STARTS_WITH(lvalue, rvalue) {
  return lvalue && lvalue.startsWith(rvalue);
}

function CONTAINS(lvalue, rvalue) {
  return lvalue && lvalue.includes(rvalue);
}

function NOT_CONTAINS(lvalue, rvalue) {
  return lvalue && !lvalue.includes(rvalue);
}

function IN(lvalue, rvalue) {
  const listValues = rvalue.split(new RegExp("[,|]"));
  for (let i = 0; i < listValues.length; i++) {
    if (lvalue && lvalue.trim() == listValues[i].trim()) return true;
  }
  return false;
}

function NOT_IN(lvalue, rvalue) {
  return !IN(lvalue, rvalue);
}

function IS_NULL(value) {
  return !value;
}

function IS_NOT_NULL(value) {
  return !!value;
}
// ////// end - expression evaluator for constructors //////

// the rule executor callee
export default function evalExpressions(data = {}, expressions) {
  for (let i = 0; i < expressions.length; i++) {
    const response = evalExpression(data, expressions[i]);
    if (response) {
      const userTimezone = getUserTimezone();
      return calculateValues(data, expressions[i], userTimezone);
    }
  }
  return {};
}

function evalExpression(data, expression) {
  let response = false;
  const { lines = [] } = expression;
  if (lines && lines.length) {
    const { advExpression } = expression;
    let ae = formatAdvancedExpression(advExpression, lines.length);
    for (let i = 0; i < lines.length; i++) {
      const e = constructExpressionFromLine(lines[i]);
      ae = ae.replace(new RegExp(`@${i + 1}@`, "gi"), e);
    }
    response = getExecutor(data, ae)();
  }
  // else {
  // In case if there are no hover rules defined, show configured fields.
  // response = true;
  // const e = constructExpressionFromLine(lines[0]);
  // response = getExecutor(data, e)();
  // }
  return response;
}

function getExecutor(data, script) {
  const executor = (function(data, script) {
    const $D = data;
    const s = script;

    return function() {
      return eval(s);
    };
  })(data, script);

  return executor;
}

function getWOFields() {
  const state = store.getState();
  const { metaData } = state;
  const { workOrderFields } = metaData;
  const { content } = workOrderFields;
  return content;
}
function getUserTimezone() {
  const state = store.getState();
  const { metaData } = state;
  const { userTimezone } = metaData;
  const defaultUserTimezone = (userTimezone && userTimezone.content) || {};
  return defaultUserTimezone;
}
function getReferenceValue(woRow, fieldName, refField = NAME) {
  let refFieldName = fieldName;
  if (fieldName.endsWith("__c")) {
    refFieldName = fieldName.replace("__c", "__r");
  } else if (fieldName.endsWith(ID)) {
    refFieldName = fieldName.replace(ID, "");
  }
  const refObj = woRow[refFieldName] || woRow[fieldName];
  return (refObj && refObj[refField]) || "--";
}

function calculateValues(data = {}, expression = {}, userTimezone) {
  const ret = {};
  const woFields = getWOFields() || {};
  const { target = [] } = expression;
  const { defaultTZ } = userTimezone || {};
  target.map(apiName => {
    let fieldValue = data[apiName];
    const fieldDesc = woFields[apiName];
    if (fieldDesc) {
      const { display, fieldType, refField = NAME } = fieldDesc;
      switch (fieldType) {
        case PICKLIST:
          const listOfValues = JSON.parse(refField) || {};
          fieldValue = listOfValues[fieldValue] || fieldValue;
          break;
        case REFERENCE:
          fieldValue = getReferenceValue(data, apiName, refField) || "--";
          break;
        case DATE_FIELD_TYPE:
          fieldValue =
            (fieldValue &&
              moment(fieldValue, moment.ISO_8601).format(
                getUserTimeSettings("dateFormat")
              )) ||
            "--";
          break;
        case DATETIME_FIELD_TYPE:
          fieldValue =
            (fieldValue &&
              moment(fieldValue, moment.ISO_8601)
                .tz(defaultTZ)
                .format(getUserTimeSettings("dateTimeFormat"))) ||
            "--";
          break;
        default:
          break;
      }
      ret[apiName] = { display, fieldValue };
    }
    return undefined;
  });
  return ret;
}

function constructExpressionFromLine(line) {
  const op = line.operator;
  const ret = constructors[op](line);
  return ret;
}

function formatAdvancedExpression(ae, len) {
  if (!ae) {
    ae = "1";
    for (let i = 1; i < len; i++) {
      ae += ` AND ${i + 1}`;
    }
  }

  for (let i = len; i > 0; i--) {
    ae = ae.replace(new RegExp(`${i}`, "gi"), `@${i}@`);
  }

  ae = ae.replace(new RegExp("AND", "gi"), "&&");
  ae = ae.replace(new RegExp("OR", "gi"), "||");
  return ae;
}
