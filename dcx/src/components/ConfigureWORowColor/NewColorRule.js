import React, { Component } from "react";
import {
  Label,
  Input,
  ColorPicker,
  Form,
  FormFields,
  Grid,
  GridRow,
  GridItem,
  Toggle
} from "@svmx/ui-components-lightning";
import { SubmissionError } from "redux-form";
import { PropTypes } from "prop-types";
import { IntlProvider } from "react-intl";
import {
  CLOSE,
  EXPRESSION_INPUT,
  EXPRESSION_PICKLIST,
  PROPERTY_PICKLIST,
  RULE_EXPRESSIONS
} from "constants/AppConstants";
import { cloneDeep, isEmpty, isEqual, isNull, flatMap } from "lodash";
import { convertUint2Hex, getDisplayValue } from "utils/DCUtils";
import { TAG072 } from "constants/DisplayTagConstants";

import {
  validateDateOperands,
  validateEmptyRuleName,
  validateExpression
} from "utils/RuleValidatorUtil";
import ActivityModalService from "components/Modals/ActivityModal/ActivityModalService";
import "./ConfigureWORowColor.scss";
import RuleExpressionRow from "./RuleExpressionRow";

const { ColorPickerField, TextField, ToggleField } = FormFields;

const propTypes = {
  onSubmitSuccess: PropTypes.func,
  rule: PropTypes.objectOf(PropTypes.object),
  ruleType: PropTypes.string,
  sourceItems: PropTypes.arrayOf(PropTypes.object),
  woRules: PropTypes.arrayOf(PropTypes.object)
};

const defaultProps = {
  onSubmitSuccess: () => {},
  rule: {
    color: "0",
    expression: "",
    name: "",
    operand: [],
    status: ""
  },
  ruleType: PropTypes.string,
  sourceItems: PropTypes.arrayOf(PropTypes.object),
  woRules: []
};

class NewColorRule extends Component {
  constructor(props) {
    super(props);
    const { rule } = props;
    this.state = {
      localRule: rule
    };
  }

  getEmptyRow = () => {
    const { ruleType } = this.props;
    const emptyRow = {
      compare: "matches",
      fieldType: "string",
      property: ruleType === "Event Rule" ? "SVMXDEV__Company__c" : "Name",
      type: null,
      value: ""
    };
    return emptyRow;
  };

  handleAddExpression = () => {
    const { localRule } = this.state;
    const { operand } = localRule;
    const emptyRow = this.getEmptyRow();

    const expressionRows = [...operand];
    expressionRows.push(emptyRow);

    localRule.operand = expressionRows;

    this.setState({ localRule });
  };

  handleExpressionRowDeletion = index => {
    const { localRule } = this.state;
    const newRow = { ...localRule };
    const { operand: woRules } = newRow;
    woRules.splice(index, 1);
    newRow.operand = woRules;
    this.setState({ localRule: newRow });
  };

  componentWillReceiveProps = nextProps => {
    const { rule } = nextProps;
    this.setState({ localRule: rule });
  };

  handleSuccessFormSumbit = values => {
    const {
      onCustomValidationError,
      onSubmitSuccess,
      ruleType,
      sourceItems,
      woRules
    } = this.props;

    let isRuleEqual = false;
    const activeRuleIndex = ActivityModalService.getActiveRuleIndex();
    const activeRule = values;

    if (activeRuleIndex !== -1) {
      isRuleEqual = isEqual(values, woRules[activeRuleIndex]);
    }

    if (!isRuleEqual) {
      let errors = {};
      const { expression, operand } = activeRule;
      flatMap(operand, item => {
        const selectedObj = sourceItems.find(o => o.value === item.property);
        item.fieldType = selectedObj.fieldType;

        if (selectedObj.display.includes("Event.")) {
          item.type = "EVENT";
        } else {
          item.type = "WO";
        }
      });

      let errorMsg = validateDateOperands(activeRule, "TAG299");
      if (errorMsg) {
        errors = errorMsg;
      }

      if (operand.length >= 1) {
        errorMsg = validateExpression(operand.length, expression, "TAG300");
        if (errorMsg) {
          errors.expression = errorMsg;
        }
      }

      if (!isEmpty(errors)) {
        // throw new SubmissionError(errors);
        onCustomValidationError(errors);
      } else {
        onSubmitSuccess(activeRule, activeRuleIndex);
      }
    } else {
      onSubmitSuccess(activeRule, activeRuleIndex);
    }
  };

  handleFailedFormSubmit = errors => {
    console.log("FAILED");
  };

  render() {
    const { sourceItems } = this.props;
    const { localRule } = this.state;

    return (
      <IntlProvider locale="en">
        <Form
          name="NewRuleForm"
          onSubmit={this.handleSuccessFormSumbit}
          onSubmitFail={this.handleFailedFormSubmit}
          initialValues={localRule}
        >
          <Grid isVertical>
            <GridRow>
              <GridItem noFlex>
                <Label isRequired>{getDisplayValue(TAG072)}</Label>
              </GridItem>
            </GridRow>
            <GridRow cols={8}>
              <GridItem cols={8} noFlex>
                <TextField name="name" isRequired>
                  <Input />
                </TextField>
              </GridItem>
              <GridItem cols={1} noFlex>
                <ColorPickerField
                  formatValue={({ value }) => convertUint2Hex(value)}
                  name="color"
                />
              </GridItem>
              <GridItem cols={2} noFlex>
                <ToggleField
                  name="status"
                  positiveValue="TAG168"
                  negativeValue="TAG169"
                  positiveLabel="Active"
                  negativeLabel="Inactive"
                />
              </GridItem>
            </GridRow>
            <GridRow>
              <GridItem>
                <Label>Rule Expression(s)</Label>
              </GridItem>
            </GridRow>
            <GridRow>
              <GridItem>
                <div className="NewColorRule__ruleExpression">
                  <ul className="NewColorRule__items">
                    <Grid isVertical>
                      <RuleExpressionRow
                        operand={localRule.operand}
                        sourceItems={sourceItems}
                        onDeleteRow={this.handleExpressionRowDeletion}
                      />
                    </Grid>
                  </ul>
                </div>
              </GridItem>
            </GridRow>
            <GridRow>
              <GridItem>
                <Label
                  className="RuleExpression__addExpression"
                  onClick={this.handleAddExpression}
                >
                  + Add Expression
                </Label>
              </GridItem>
            </GridRow>
            <GridRow>
              <GridItem>
                <TextField name="expression" label="In Expression">
                  <Input />
                </TextField>
              </GridItem>
            </GridRow>
          </Grid>
        </Form>
      </IntlProvider>
    );
  }
}

NewColorRule.propTypes = propTypes;
NewColorRule.defaultProps = defaultProps;

export default NewColorRule;
