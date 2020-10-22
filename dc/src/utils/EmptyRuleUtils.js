import { NAME, ORG_NAMESPACE } from "constants/AppConstants";

export default function createEmptyRule(ruleType, value) {
  return {
    color: "#E1BEE7",
    expression: "",
    name: "",
    operand: [
      {
        compare: "matches",
        fieldType: "string",
        property: ruleType === "Event Rule" ? value || NAME : NAME,
        type: null,
        value: ""
      }
    ],
    status: "TAG169"
  };
}
