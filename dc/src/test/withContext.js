import { mount, shallow } from "enzyme";
import { MemoryRouter } from "react-router-dom";
import { shape } from "prop-types";

// Instantiate router context
const router = {
  history: new MemoryRouter().history,
  route: {
    location: {},
    match: {}
  }
};

const createContext = () => ({
  childContextTypes: {
    router: shape({})
  },
  context: { router }
});

export function mountWithContext(node) {
  return mount(node, createContext());
}

export function shallowWithContext(node) {
  return shallow(node, createContext());
}
