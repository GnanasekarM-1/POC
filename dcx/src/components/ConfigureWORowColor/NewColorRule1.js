import React, { Component } from "react";
import {
  Label,
  Input,
  InputWrapper,
  ColorPicker,
  Grid,
  GridRow,
  GridItem,
  Toggle
} from "@svmx/ui-components-lightning";
import { PropTypes } from "prop-types";
import { WO_EXP_TYPE, EVENT_EXP_TYPE } from "constants/AppConstants";
import { cloneDeep, isEmpty, isEqual, flatMap } from "lodash";
import { convertUint2Hex, getDisplayValue } from "utils/DCUtils";
import {
  TAG072,
  TAG169,
  TAG168,
  TAG073,
  TAG486
} from "constants/DisplayTagConstants";
import createEmptyRule from "utils/EmptyRuleUtils";

import {
  validateDateOperands,
  validateEmptyRuleName,
  validateExpression
} from "utils/RuleValidatorUtil";
import ActivityModalService from "components/Modals/ActivityModal/ActivityModalService";
import ConfTechViewService from "components/Modals/ConfTechViewModal/ConfTechViewService";
import "./ConfigureWORowColor.scss";
import RuleExpressionRow from "./RuleExpressionRow";

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

class NewColorRule1 extends Component {
  constructor(props) {
    super(props);
    const { formRef, rule } = props;
    const clonedRule = cloneDeep(rule);
    this.state = {
      color: clonedRule.color,
      expression: clonedRule.expression,
      localRule: clonedRule,
      name: clonedRule.name,
      operand: clonedRule.operand,
      status: clonedRule.status
    };
    formRef(this.handleSuccessFormSumbit);
  }

  getEmptyRow = () => {
    const { sourceItems, ruleType } = this.props;
    const [sourceItem] = sourceItems || [];
    const { key, value } = sourceItem || {};
    return createEmptyRule(ruleType, value || key);
  };

  handleAddExpression = () => {
    const { operand } = this.state;
    const emptyRow = this.getEmptyRow();
    const { operand: emptyRowOperand } = emptyRow;
    let modifiedRules = null;
    // To check if this is a Grid Rule or Event Rule
    if (!Number.isNaN(ActivityModalService.getActiveRuleIndex())) {
      modifiedRules = ActivityModalService.getModifiedColorRules();
    } else if (!Number.isNaN(ConfTechViewService.getActiveRuleIndex())) {
      const modifiedUserSettings = ConfTechViewService.getmodifiedUserSettings();
      modifiedRules = modifiedUserSettings.tech_techRules;
    }
    const modifiedOpernad = (modifiedRules && modifiedRules.operand) || null;

    const expressionRows = modifiedOpernad
      ? [...modifiedOpernad]
      : [...operand];
    expressionRows.push(...emptyRowOperand);

    this.setState(
      { operand: expressionRows },
      this.setModifiedRules(expressionRows)
    );
  };

  handleExpressionRowDeletion = index => {
    const { operand } = this.state;
    let modifiedRules = null;
    // To check if this is a Grid Rule or Event Rule
    if (!Number.isNaN(ActivityModalService.getActiveRuleIndex())) {
      modifiedRules = ActivityModalService.getModifiedColorRules();
    } else if (!Number.isNaN(ConfTechViewService.getActiveRuleIndex())) {
      const modifiedUserSettings = ConfTechViewService.getmodifiedUserSettings();
      modifiedRules = modifiedUserSettings.tech_techRules;
    }
    const modifiedOpernad = (modifiedRules && modifiedRules.operand) || null;

    const woRules = cloneDeep(modifiedOpernad || operand);
    woRules.splice(index, 1);
    this.setState({ operand: woRules }, this.setModifiedRules(woRules));
  };

  componentWillReceiveProps = nextProps => {
    const { rule } = nextProps;
    const clonedRule = cloneDeep(rule);
    this.setState({
      color: clonedRule.color,
      expression: clonedRule.expression,
      localRule: clonedRule,
      name: clonedRule.name,
      operand: clonedRule.operand,
      status: clonedRule.status
    });
  };

  handleSuccessFormSumbit = values => {
    const {
      onCustomValidationError,
      onSubmitSuccess,
      sourceItems,
      woRules
    } = this.props;

    let isRuleEqual = false;
    let activeRuleIndex;
    // To check if this is a Grid Rule or Event Rule
    if (!Number.isNaN(ActivityModalService.getActiveRuleIndex())) {
      activeRuleIndex = ActivityModalService.getActiveRuleIndex();
    } else if (!Number.isNaN(ConfTechViewService.getActiveRuleIndex())) {
      activeRuleIndex = ConfTechViewService.getActiveRuleIndex();
    }

    const activeRule = values;

    if (activeRuleIndex !== -1) {
      isRuleEqual = isEqual(values, woRules[activeRuleIndex]);
    }

    if (!isRuleEqual) {
      let errors = {};

      const { expression, operand } = activeRule;

      flatMap(operand, item => {
        const selectedObj = sourceItems.find(sourceItem => {
          const { property } = item;
          const { key, value, type } = sourceItem;
          return type === EVENT_EXP_TYPE
            ? key === property || value === property
            : value === property;
        });
        if (!selectedObj) return;
        const { display, fieldType, key } = selectedObj;
        item.fieldType = fieldType;
        if (display && display.startsWith("Event.")) {
          item.property = key;
          item.type = EVENT_EXP_TYPE;
        } else {
          item.type = WO_EXP_TYPE;
        }
      });

      let errorMsg = validateEmptyRuleName(activeRule, "TAG179");
      if (errorMsg) {
        errors.name = errorMsg;
      }

      errorMsg = validateDateOperands(activeRule, "TAG299");
      if (errorMsg) {
        errors = { ...errors, ...errorMsg };
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

  handleRuleValueChange = data => {
    const { name, value } = data;
    this.setState({ [name]: value }, this.setModifiedRules);
  };

  handleColorChange = data => {
    const { value } = data;
    this.setState({ color: value }, this.setModifiedRules);
  };

  handleOperandModified = operand => {
    if (!Number.isNaN(ActivityModalService.getActiveRuleIndex())) {
      ActivityModalService.setModifiedOperands(operand);
    } else if (!Number.isNaN(ConfTechViewService.getActiveRuleIndex())) {
      ConfTechViewService.setModifiedOperands(operand);
    }
    this.setModifiedRules(operand);
  };

  setModifiedRules = modifiedOperands => {
    const { onRulesModified } = this.props;
    const { color, expression, localRule, name, operand, status } = this.state;
    if (
      !modifiedOperands &&
      !Number.isNaN(ActivityModalService.getActiveRuleIndex()) &&
      ActivityModalService.getModifiedOperands()
    ) {
      modifiedOperands = ActivityModalService.getModifiedOperands();
    } else if (
      !modifiedOperands &&
      !Number.isNaN(ConfTechViewService.getActiveRuleIndex()) &&
      ConfTechViewService.getModifiedOperands()
    ) {
      modifiedOperands = ConfTechViewService.getModifiedOperands();
    }

    localRule.color = color;
    localRule.expression = expression;
    localRule.name = name;
    localRule.operand = modifiedOperands || operand;
    localRule.status = status;
    onRulesModified(localRule);
  };

  render() {
    const { forceUpdate, sourceItems } = this.props;
    const { color, expression, name, operand, status } = this.state;

    return (
      <Grid className="NewColorRule__Wrapper" isVertical>
        <GridRow>
          <GridItem noFlex>
            <Label isRequired>{getDisplayValue(TAG072)}</Label>
          </GridItem>
        </GridRow>
        <GridRow cols={6}>
          <GridItem className="NewColorRule__RuleName" cols={4} noFlex>
            <InputWrapper>
              <Input
                name="name"
                value={name}
                onValueChange={this.handleRuleValueChange}
              />
            </InputWrapper>
          </GridItem>
          <GridItem cols={1} noFlex>
            <ColorPicker
              name="color"
              value={convertUint2Hex(color)}
              onValueChange={this.handleColorChange}
            />
          </GridItem>
          <GridItem cols={2} noFlex>
            <Toggle
              name="status"
              positiveValue="TAG168"
              negativeValue="TAG169"
              positiveLabel={getDisplayValue(TAG168)}
              negativeLabel={getDisplayValue(TAG169)}
              value={status}
              onValueChange={this.handleRuleValueChange}
            />
          </GridItem>
        </GridRow>
        <GridRow>
          <GridItem>
            <Label>{getDisplayValue(TAG073)}</Label>
          </GridItem>
        </GridRow>
        <GridRow>
          <GridItem>
            <div className="NewColorRule__ruleExpression">
              <ul className="NewColorRule__items">
                <Grid isVertical>
                  <RuleExpressionRow
                    forceUpdate={forceUpdate}
                    operand={operand}
                    sourceItems={sourceItems}
                    onDeleteRow={this.handleExpressionRowDeletion}
                    onOperandModified={this.handleOperandModified}
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
              + {getDisplayValue(TAG486)}
            </Label>
          </GridItem>
        </GridRow>
        <GridRow>
          <GridItem>
            <InputWrapper>
              <Input
                name="expression"
                value={expression}
                onValueChange={this.handleRuleValueChange}
              />
            </InputWrapper>
          </GridItem>
        </GridRow>
      </Grid>
    );
  }
}

NewColorRule1.propTypes = propTypes;
NewColorRule1.defaultProps = defaultProps;

export default NewColorRule1;
