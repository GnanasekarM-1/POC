import { getDisplayValue } from "utils/DCUtils";
import { CONDITION_NULL, CONDITION_NOT_NULL } from "constants/AppConstants";
import { isEqual, isEmpty, range, uniq } from "lodash";

export function validateArithmeticExpression(totalNumberOfRows, value) {
  const regxToMatch = new RegExp(
    /\(\s*\d+\s*\)|\d+\s(and|or|AND|OR|And|Or)\s\d+/gm
  );
  let copyOfValue = value.trim();
  if (totalNumberOfRows === 1) {
    return copyOfValue === "1";
  }
  let isMatch = true;
  const token = "0";
  while (isMatch) {
    isMatch = regxToMatch.test(copyOfValue);
    copyOfValue = copyOfValue.replace(regxToMatch, 0);
  }
  return copyOfValue === token;
}

export function validateForExistenceOfAllRows(totalNumberOfRows, value) {
  if (totalNumberOfRows > 1) {
    const rangeArray = range(1, totalNumberOfRows + 1).map(String);
    let valueContainingNumberOnly = value
      .replace(/[^0-9]/g, " ")
      .replace(/\s+/g, " ")
      .trim();
    valueContainingNumberOnly = valueContainingNumberOnly.split(" ");
    valueContainingNumberOnly = uniq(valueContainingNumberOnly).sort(
      (a, b) => a - b
    );
    return isEqual(rangeArray, valueContainingNumberOnly);
  }
  return true;
}

export function validateDate(data) {
  let result = true;
  const { compare, fieldType, value } = data;

  if (compare === CONDITION_NULL || compare === CONDITION_NOT_NULL) {
    return result;
  }

  if (
    fieldType.toLowerCase() === "datetime" ||
    fieldType.toLowerCase() === "date"
  ) {
    /**
     * This is a regular expression to validate a date string in MM/DD/YYYY format,
       a date time string in MM/DD/YYYY HH:MM or a date time string in MM/DD/YYYY HH:MM:SS format.
       It can validate date from 1600 to 2199.
     */

    const regExp = new RegExp(
      "^([0]\\d|[1][0-2])/([0-2]\\d|[3][0-1])/([2][01]|[1][6-9])\\d{2}(\\s([0-1]\\d|[2][0-3])(\\:[0-5]\\d){1,2})?$"
    );

    const evt = regExp.test(value);

    if (!evt) {
      result = false;
    }
  }

  return result;
}

export function validateEmptyRuleName(rule, displayTags) {
  if (isEmpty(rule.name)) {
    return getDisplayValue(displayTags);
  }
  return null;
}

export function validateDateOperands(rule, displayTags) {
  const { operand } = rule;
  const errorMessage = getDisplayValue(displayTags);
  const errors = { row: [] };

  for (let i = 0; i < operand.length; i += 1) {
    if (
      operand[i].fieldType.toLowerCase() === "date" ||
      operand[i].fieldType.toLowerCase() === "datetime"
    ) {
      if (!validateDate(operand[i])) {
        errors[`row${i}`] = `row ${i + 1} - ${errorMessage}`;
      }
    }
  }
  if (!errors.row.length) {
    delete errors.row;
  }
  return errors;
}

export function validateExpression(totalNumberOfRows, value, displayTags) {
  const expressionErrorMsg = getDisplayValue(displayTags);
  if (value) {
    const isArithmeticValid = validateArithmeticExpression(
      totalNumberOfRows,
      value
    );
    const isAllRowsExist = validateForExistenceOfAllRows(
      totalNumberOfRows,
      value
    );
    if (!isArithmeticValid || !isAllRowsExist) {
      return expressionErrorMsg;
    }
  }
  return null;
}
