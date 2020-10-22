import {
  GET_DELTA_WORK_ORDER,
  HTTP_GET,
  HTTP_ACCEPT,
  HTTP_POST,
  APPLICATION_JSON,
  CONTENT_TYPE,
  ACCEPT_ENCODING,
  GZIP_DEFLATE_BR,
  APPLICATION_JSON_UTF8,
  SFORCE_QUERY_OPTIONS,
  BATCH_SIZE,
  PAGINATION_WORK_ORDERS_ENDPOINT,
  WORK_ORDER_ENDPOINT
} from "constants/ServiceConstants";
import { FIELD_VALUE_VIEW } from "constants/AppConstants";
import { isEmpty } from "lodash";
import fetchData from "services/service";
import { getRecordIndex } from "utils/GridUtils";

const WorkOrderService = {};

WorkOrderService.getWorkOrder = woId => {
  const config = {
    method: HTTP_GET,
    url: `${WORK_ORDER_ENDPOINT}?woId=${woId}&isInitial=true`
  };
  return fetchData(config);
};

WorkOrderService.getWorkOrders = (
  filter,
  page,
  nextRecordsUrl,
  sorted,
  status,
  text,
  view,
  batchSize
) => {
  let url = nextRecordsUrl;
  if (Number.isInteger(page)) {
    const pageIndex = getRecordIndex(page, batchSize);
    const index = url.lastIndexOf("-");
    if (index !== -1) {
      url = url.substring(0, index + 1) + pageIndex;
    }
  } else {
    url = `${PAGINATION_WORK_ORDERS_ENDPOINT}`;
    if (view) {
      const { Key: viewId, woViewType } = view;
      url = `${url}?viewId=${viewId}&isQueue=${woViewType !==
        FIELD_VALUE_VIEW}`;
      if (!isEmpty(text)) {
        url = `${url}&searchField=${filter}&searchFieldValue=${text}`;
      }
      const { id, desc = false } = sorted;
      if (!isEmpty(id)) {
        url = `${url}&sortField=${id}&isAscending=${!desc}`;
      }
      url = `${url}&dispatchStatus=${status}`;
    } else {
      url = `${url}?isInitial=true`;
    }
  }

  const config = {
    method: HTTP_GET,
    sfAPI: Number.isInteger(page),
    url
  };

  if (Number.isInteger(page)) {
    // const MAX_PAGE_SIZE = Math.max(getSettingValue(SET073, 200), 200);
    config.headers = new Headers({
      [ACCEPT_ENCODING]: [GZIP_DEFLATE_BR],
      [CONTENT_TYPE]: APPLICATION_JSON_UTF8,
      [HTTP_ACCEPT]: APPLICATION_JSON,
      [SFORCE_QUERY_OPTIONS]: `${BATCH_SIZE}=${batchSize}`
    });
  }
  return fetchData(config);
};

WorkOrderService.getDeltaWorkOrders = payloadData => {
  const config = {
    method: HTTP_POST,
    payload: { workorderIds: payloadData },
    url: GET_DELTA_WORK_ORDER
  };
  return fetchData(config);
};

WorkOrderService.getDeltaWorkOrders = payloadData => {
  const config = {
    method: HTTP_POST,
    payload: { workorderIds: payloadData },
    url: GET_DELTA_WORK_ORDER
  };
  return fetchData(config);
};

export default WorkOrderService;
