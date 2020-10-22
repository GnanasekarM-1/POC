import { orderBy, cloneDeep, concat, remove } from "lodash";
import { getDisplayValue } from "utils/DCUtils";
import {
  DEFAULT_SORT_ORDER,
  FIELD_VALUE,
  FIELD_VALUE_VIEW,
  KEY,
  VALUE
} from "constants/AppConstants";

export function getViewSortedByField(
  views = [],
  groupBy,
  value = null,
  sortBy = FIELD_VALUE,
  order = DEFAULT_SORT_ORDER
) {
  const clonedViews = cloneDeep(views);
  const regEx = /^TAG[0-9]+$/;
  const eqGrpByArray = groupBy
    ? clonedViews.filter(
        item => item[groupBy] === value || item[groupBy] === "QUEUE"
      )
    : [];
  const defQueueArray = remove(eqGrpByArray, item => {
    const { Value } = item;
    return regEx.test(Value);
  });
  let queue = null;
  if (defQueueArray.length) {
    [queue] = defQueueArray;
    const { Value } = queue;
    queue.Value = getDisplayValue(Value);
  }

  const neqGrpByArray = groupBy
    ? clonedViews.filter(item => item[groupBy] === "VIEW")
    : clonedViews;
  const eqSortedArray = orderBy(eqGrpByArray, [sortBy], [order]);
  if (queue) {
    eqSortedArray.unshift(queue);
  }
  const neqSortedArray = orderBy(neqGrpByArray, [sortBy], [order]);
  return concat(eqSortedArray, neqSortedArray);
}

export function isView(object) {
  return object && object.woViewType === FIELD_VALUE_VIEW;
}

export function getView(views, id) {
  let found = [];
  if (views && views instanceof Array) {
    found = views.filter(view => view.Key === id);
  }
  return found[0];
}

export function getViewColumns(view) {
  let columns;
  const { columnInfo } = view;
  if (columnInfo) {
    columns = columnInfo.split(",");
  }
  return columns;
}

export function createQueryParam(url, payload) {
  let quertParam = `${url}?`;
  payload.map(item => {
    const { key: pName, value: pValue } = item;
    if (Array.isArray(pValue)) {
      quertParam += `${pName}=${pValue.join()}&`;
    } else {
      quertParam += `${pName}=${pValue}&`;
    }
    return undefined;
  });
  return quertParam;
}

export function createPayloadParam(keyValue, Value, createParamArr) {
  if (createParamArr) {
    createParamArr.push({
      [KEY]: keyValue,
      [VALUE]: Value
    });
    return createParamArr;
  }
  const createParam = [];
  createParam.push({
    [KEY]: keyValue,
    [VALUE]: Value
  });
  return createParam;
}
