// Jest & Enzyme setup
import { configure } from "enzyme";
import Adapter from "enzyme-adapter-react-16";

// TODO: Remove this `requestAnimationFrame` polyfill once the cra issue is fixed
// https://github.com/facebookincubator/create-react-app/issues/3199
import "./rafPolyfill";

// Configure the enzyme adapter.
configure({ adapter: new Adapter() });

// Fail tests on any warning
// eslint-disable-next-line
console.error = message => {
  throw new Error(message);
};
