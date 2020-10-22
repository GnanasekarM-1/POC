/**
 * This is used to serve the react build to support salesforce development
 * Enter the consumerKey and consumerSecret from connected app salesforce
 * Please use callback url http://localhost:3000/oauth/callback while creating connected app
 */
const { app, vars } = require("./app");

function appServerIsListening() {
  console.log(`Listening on port ${vars.serverPort}`);
  return true;
}

const server = app.listen(vars.serverPort, appServerIsListening);

module.exports = { appServerIsListening, server };
