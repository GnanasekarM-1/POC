import ServiceRequest from "services/ServiceRequest";
import { TAG130 } from "constants/DisplayTagConstants";
import {
  HTTP_FORBIDDIN,
  HTTP_UNAUTHORIZED,
  INVALID_SESSION_ID,
  ERROR_TYPE
} from "constants/AppConstants";
import { USER_SESSION_EXPIRED } from "constants/ActionConstants";
import { appStatusAction } from "actions/AppStatusAction";
import store from "store";

export default function fetchData(config) {
  return new Promise((resolve, reject) => {
    fetch(ServiceRequest(config), {
      credentials: "same-origin"
    })
      .then(
        response => {
          const { errorCode, message, status, statusText } = response;
          if (
            errorCode === INVALID_SESSION_ID ||
            status === HTTP_UNAUTHORIZED ||
            status === HTTP_FORBIDDIN
          ) {
            var error = new Error(message || statusText);
            error.response = response;
            throw error;
          }
          resolve(response);
        },
        error => {
          console.log("Network Error : " + error);
        }
      )
      .catch(error => {
        console.log("Error : " + error);
        const { message } = error;
        const { configData } = window;
        const { sessionExpired } = configData || {};
        if (!sessionExpired) {
          store.dispatch(
            appStatusAction(USER_SESSION_EXPIRED, message, ERROR_TYPE, {
              error: { message, errorCode: INVALID_SESSION_ID }
            })
          );
          if (!configData) {
            window.configData = {};
          }
          window.configData.sessionExpired = true;
          reject(error);
        }
      });
  });
}
