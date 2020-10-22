import { createStore } from "redux";
import makeReducer from "reducers";
import { makeEnhancers } from "middleware";

function makeStore(initialState = {}) {
  return createStore(makeReducer(), initialState, makeEnhancers());
}

const initialState = {};

const store = makeStore(initialState);

export default store;
