import React, { Component } from "react";
import { Grid } from "@svmx/ui-components-lightning";

import { cloneDeep, isEqual } from "lodash";
import ActivityModalService from "components/Modals/ActivityModal/ActivityModalService";
import ConfTechViewService from "components/Modals/ConfTechViewModal/ConfTechViewService";
import RuleExpression from "./RuleExpression1";
import "./ConfigureWORowColor.scss";

class RuleExpressionRow extends Component {
  shouldComponentUpdate(nextProps, nextState) {
    const { forceUpdate, operand: operandNext } = nextProps;
    const { operand } = this.props;
    const shouldUpdate = !isEqual(operand, operandNext) || forceUpdate;
    return shouldUpdate;
  }

  setModifiedOperand = (modifiedRow, index) => {
    const { operand: opernadProps, onOperandModified } = this.props;
    let modifiedRules = null;
    // To check if this is a Grid Rule or Event Rule
    if (!Number.isNaN(ActivityModalService.getActiveRuleIndex())) {
      modifiedRules = ActivityModalService.getModifiedColorRules();
    } else if (!Number.isNaN(ConfTechViewService.getActiveRuleIndex())) {
      const modifiedUserSettings = ConfTechViewService.getmodifiedUserSettings();
      modifiedRules = modifiedUserSettings.tech_techRules;
    }
    const modifiedOpernad = (modifiedRules && modifiedRules.operand) || null;

    const operand = cloneDeep(modifiedOpernad || opernadProps);
    operand[index] = modifiedRow;
    onOperandModified(operand);
  };

  render() {
    const { operand } = this.props;

    return (
      <Grid isVertical>
        {operand.map((rowItem, index) => (
          <RuleExpression
            key={Math.random(99999)}
            rowItem={rowItem}
            rowKey={`operand[${index}]`}
            rowIndex={index + 1}
            setModifiedOperand={this.setModifiedOperand}
            {...this.props}
          />
        ))}
      </Grid>
    );
  }
}

export default RuleExpressionRow;
