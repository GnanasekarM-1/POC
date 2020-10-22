/* eslint-disable prefer-destructuring */
/**
 * This is used to serve the react build to support salesforce development
 * Enter the consumerKey and consumerSecret from connected app salesforce
 * Please use callback url http://localhost:3000/oauth/callback while creating connected app
 */

/* eslint import/no-extraneous-dependencies: ["error", {"peerDependencies": true}] */

require("dotenv").config({ path: ".env.development" });
const express = require("express");
const oauth2 = require("salesforce-oauth2");
const globalRequest = require("request");
const bodyParser = require("body-parser");

const env = process.env;
const serverPort = env.REACT_APP_SFDC_PROXY_SERVER_PORT;
const reactPort = env.REACT_APP_REACT_SERVER_PORT;
const localReactServer = `http://localhost:${reactPort}`;
const SFORCE_QUERY_OPTIONS = "sforce-query-options";

//const isSfdcProductionOrg = true;
const isSfdcProductionOrg = false;

const sfdcLoginUrl = isSfdcProductionOrg
  ? "https://login.salesforce.com"
  : "https://test.salesforce.com";

function getCallbackUrl(port) {
  return `http://localhost:${port}/oauth/callback`;
}

const vars = {
  callbackUrl: getCallbackUrl(serverPort),
  consumerKey: isSfdcProductionOrg
    ? env.REACT_APP_CONSUMER_KEY_PRODUCTION
    : env.REACT_APP_CONSUMER_KEY_SANDBOX,
  consumerSecret: isSfdcProductionOrg
    ? env.REACT_APP_CONSUMER_SECRET_PRODUCTION
    : env.REACT_APP_CONSUMER_SECRET_SANDBOX,
  serverPort,
  staticUrl: `${__dirname}/../../build`
};

function setServerPort(port) {
  vars.serverPort = port;
  vars.callbackUrl = getCallbackUrl(port);
  return true;
}

function appRoot(request, response) {
  const uri = oauth2.getAuthorizationUrl({
    base_url: sfdcLoginUrl,
    client_id: vars.consumerKey,
    redirect_uri: vars.callbackUrl,
    scope: "api"
  });
  return response.redirect(uri);
}

function getRequestURI(req) {
  let uri = req.param("url");
  Object.keys(req.query).map(pName => {
    if (pName !== "url") {
      uri = `${uri}&${pName}=${req.param(pName)}`;
    }
    return undefined;
  });
  return uri;
}

function requestHeaders(req) {
  const accessToken = global.accessToken;
  const authorization = `Bearer ${accessToken}`;
  // const authorization = `Bearer 00D5B000000E7N4!AQ8AQIJZQJu266PeF0K1T7YqCGzNGPkKvwlNtyoA_H566jCZaNYWHJ10QJPmowz.l26URwARlub7l6RsDRe.LDOuVLojqpE5`;
  const sfQueryOptions = req.headers[SFORCE_QUERY_OPTIONS];
  const headers = {
    Authorization: authorization
  };
  if (sfQueryOptions) {
    headers[SFORCE_QUERY_OPTIONS] = sfQueryOptions;
  }
  console.log(`Authorization : ${authorization}`);
  return headers;
}

function appGet(req, res) {
  const instanceUrl = global.instanceUrl;
  //const instanceUrl = "https://cs64.salesforce.com";
  const uri = instanceUrl + getRequestURI(req);
  console.log(`GET ${uri}`);

  function handleResponse(err, response, body) {
    res.send(body);
  }

  return globalRequest(
    {
      base_url: sfdcLoginUrl,
      headers: requestHeaders(req),
      url: uri
    },
    handleResponse
  );
}

function appPost(req, res) {
  const instanceUrl = global.instanceUrl;
  //const instanceUrl = "https://cs64.salesforce.com";
  const uri = instanceUrl + getRequestURI(req);
  console.log(`POST ${uri}`);

  function handleResponse(err, response, body) {
    res.send(body);
  }

  return globalRequest(
    {
      base_url: sfdcLoginUrl,
      body: req.body,
      headers: requestHeaders(req),
      json: true,
      url: uri
    },
    handleResponse
  );
}

function appOauthCallback(req, resp, error, payload) {
  global.instanceUrl = payload.instance_url;
  global.accessToken = payload.access_token;
  return resp.redirect(`${localReactServer}/index.html`); // default react router route. as this is a
}

function appOauth(req, resp) {
  const authorizationCode = req.param("code");
  oauth2.authenticate(
    {
      base_url: sfdcLoginUrl,
      client_id: vars.consumerKey,
      client_secret: vars.consumerSecret,
      code: authorizationCode,
      redirect_uri: vars.callbackUrl
    },
    appOauthCallback.bind(this, req, resp)
  );
}

function setOriginHeaders(req, res, next) {
  // Website you wish to allow to connect
  res.setHeader("Access-Control-Allow-Origin", localReactServer);

  // Request methods you wish to allow
  res.setHeader(
    "Access-Control-Allow-Methods",
    "GET, POST, OPTIONS, PUT, PATCH, DELETE"
  );

  // Request headers you wish to allow
  res.setHeader(
    "Access-Control-Allow-Headers",
    "X-Requested-With, content-type, sforce-query-options"
  );

  // Set to true if you need the website to include cookies in the requests sent
  // to the API (e.g. in case you use sessions)
  res.setHeader("Access-Control-Allow-Credentials", true);

  // Pass to next layer of middleware
  next();
}

// setup the express server using the above functions.
const app = express();

// setup the export for the file
const actions = {
  appGet,
  appOauth,
  appPost,
  appRoot,
  getCallbackUrl,
  setOriginHeaders,
  setServerPort
};

// configure the express server.
// Local Proxy calls should not fail because of express's default limits when the payload is more.
app.use(bodyParser.json({ limit: "50mb" })); // support json encoded bodies
app.use(
  bodyParser.urlencoded({
    extended: true,
    limit: "50mb",
    parameterLimit: 50 * 1024
  })
); // support encoded bodies
app.use(setOriginHeaders);
app.get("/", actions.appRoot);
app.use(express.static(vars.staticUrl));
app.get("/get", actions.appGet);
app.get("/oauth/callback", actions.appOauth);
app.post("/post", actions.appPost);
app.post("/oauth/callback", actions.appOauth);

// export everything as an object
module.exports = {
  actions,
  app,
  appOauthCallback,
  getCallbackUrl,
  vars
};
