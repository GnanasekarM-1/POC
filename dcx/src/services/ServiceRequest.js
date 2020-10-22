import lodash from "lodash";

require("dotenv").config({ path: ".env.development" });

const env = process.env;
const proxyServerUrl = env.REACT_APP_SFDC_PROXY_SERVER_URL || "";
const SFDC_ORG_NAMESAPCE =
  env.REACT_APP_SFDC_ORG_NAMESPACE ||
  (window.configData &&
    window.configData.namespace &&
    decodeURIComponent(window.configData.namespace)) ||
  "SVMXC";
const enableHttpHeaders =
  env.REACT_APP_ENABLE_HTTP_REQUEST_HEADERS === "true" || false;
const AUTHORIZATION = "Authorization";

const apiStartPointConfig = {
  apiVersion: "",
  baseUrl:
    (window.configData &&
      window.configData.baseUrl &&
      decodeURIComponent(window.configData.baseUrl)) ||
    "https://svmxdev-dev-ed.my.salesforce.com/",
  getRequestProxyPrefix:
    proxyServerUrl + (env.REACT_APP_SFDC_GET_REQUEST_PROXY_PREFIX || ""),
  orgNamespace: SFDC_ORG_NAMESAPCE,
  // orgNamespace:'SVMXC',
  postRequestProxyPrefix:
    proxyServerUrl + (env.REACT_APP_SFDC_POST_REQUEST_PROXY_PREFIX || ""),
  urlPrefix: "/services/apexrest/",
  urlSuffix: "/svmx/DCX_ServiceIntf"
};

function buildQueryString(params) {
  if (params && !lodash.isEmpty(params)) {
    const esc = encodeURIComponent;
    return Object.keys(params)
      .map(k => {
        if (!params[k]) {
          return "";
        }
        return `${esc(k)}=${esc(params[k])}`;
      })
      .join("&");
  }
  return "";
}

function buildGetApiUrl(url, params) {
  let query = buildQueryString(params);
  query = query && `?${query}`;
  return `url=${url}${query}`;
}

function buildApiUrl(url, config) {
  if (url) {
    const httpMethod = config && config.method;
    const apiStartUrl = `${apiStartPointConfig.urlPrefix}${apiStartPointConfig.orgNamespace}${apiStartPointConfig.urlSuffix}`;
    const sfAPI = typeof config.sfAPI !== "undefined" && config.sfAPI;
    if (httpMethod === "GET") {
      const apiURL = sfAPI ? `${url}` : `${apiStartUrl}${url}`;
      return `${apiStartPointConfig.getRequestProxyPrefix}?${buildGetApiUrl(
        `${apiURL}`,
        config.params
      )}`;
    }
    if (httpMethod === "POST") {
      return `${apiStartPointConfig.postRequestProxyPrefix}?url=${apiStartUrl}${url}`;
    }
    return "";
  }

  return url;
}
function buildVFpageApiUrl(url, config) {
  if (url) {
    const httpMethod = config && config.method;
    const apiStartUrl = `${apiStartPointConfig.urlPrefix}${apiStartPointConfig.orgNamespace}${apiStartPointConfig.urlSuffix}`;
    const sfAPI = typeof config.sfAPI !== "undefined" && config.sfAPI;
    if (httpMethod === "GET") {
      if (sfAPI) {
        return url;
      }
      console.log(`GET ${apiStartPointConfig.baseUrl}${apiStartUrl}${url}`);
      return apiStartPointConfig.baseUrl + apiStartUrl + url; // TODO: should add query params
    }
    if (httpMethod === "POST") {
      console.log(`POST ${apiStartPointConfig.baseUrl}${apiStartUrl}${url}`);
      return apiStartPointConfig.baseUrl + apiStartUrl + url;
    }
    return "";
  }

  return url;
}

function ServiceRequest(config) {
  const url = (config && config.url) || "";
  let headers = {};
  if (enableHttpHeaders) {
    headers =
      (config && config.headers) ||
      new Headers({
        Accept: "application/json",
        "Accept-Encoding": "gzip, deflate, br",
        "Content-Type": "application/json"
      });
  }
  const requestConfig = {
    ...config,
    headers,
    method: (config && config.method) || "GET"
  };

  if (config && config.method !== "GET" && config.method !== "HEAD") {
    requestConfig.body = JSON.stringify(config.payload);
  }

  let apiUrl = "";
  if (window.configData && window.configData.isVFpage) {
    requestConfig.headers.append(
      AUTHORIZATION,
      `Bearer ${window.configData.sessionId}`
    );
    apiUrl = buildVFpageApiUrl(url, requestConfig);
  } else {
    apiUrl = buildApiUrl(url, requestConfig);
  }
  return new Request(apiUrl, requestConfig);
}

ServiceRequest.apiStartPointConfig = apiStartPointConfig;
export { ServiceRequest as default };
