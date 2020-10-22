import { compose, applyMiddleware } from "redux";
import createSagaMiddleware from "redux-saga";
import { createLogger } from "redux-logger";
import { newRelicMiddleware } from "./newRelicMiddleware";

let composeEnhancers = compose;
const sagaMiddleware = createSagaMiddleware();

if (
  typeof __DEV__ !== "undefined" &&
  typeof __TEST__ === "undefined" &&
  global.__REDUX_DEVTOOLS_EXTENSION_COMPOSE__
) {
  composeEnhancers = global.__REDUX_DEVTOOLS_EXTENSION_COMPOSE__;
}

const reduxLogger = createLogger({
  // ...options
});

const middlewares = [newRelicMiddleware, sagaMiddleware, reduxLogger];

function makeEnhancers() {
  return composeEnhancers(applyMiddleware(...middlewares));
}

export { makeEnhancers, middlewares, sagaMiddleware };
