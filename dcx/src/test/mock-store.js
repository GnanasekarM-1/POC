import configureMockStore from "redux-mock-store";
import thunkMiddleware from "redux-thunk";
import promiseMiddleware from "redux-promise";
import { actionLoadingMiddleware } from "store/loading";

const middlewares = [
  actionLoadingMiddleware,
  promiseMiddleware,
  thunkMiddleware
];

const mockStore = configureMockStore(middlewares);
export default mockStore;
