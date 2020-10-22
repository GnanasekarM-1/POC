import React, { Component } from "react";
import {
  Button,
  FormFields,
  GridItem,
  GridRow,
  Input,
  Icon,
  Label,
  PicklistFactory
} from "@svmx/ui-components-lightning";
import { PropTypes } from "prop-types";
import {
  CLOSE,
  EXPRESSION_PICKLIST,
  PROPERTY_PICKLIST
} from "constants/AppConstants";
import { isEqual } from "lodash";
import "./ConfigureWORowColor.scss";

const { PicklistFactorySingleSelectField, TextField } = FormFields;

const propTypes = {
  onDeleteRow: PropTypes.func,
  rowIndex: PropTypes.string,
  rowItem: PropTypes.objectOf(PropTypes.object),
  rowKey: PropTypes.string.isRequired,
  sourceItems: PropTypes.arrayOf(PropTypes.object)
};

const defaultProps = {
  onDeleteRow: () => {},
  rowIndex: 1,
  rowItem: { compare: "", property: "", value: "" },
  sourceItems: []
};

class RuleExpression extends Component {
  constructor(props) {
    super(props);
    this.state = {
      isInputDisabled: this.isInputDisabled(props.rowItem.compare),
      propsState: props
    };
  }

  isInputDisabled = compare => compare === "null" || compare === "!null";

  handleCompareChange = ({ value }) => {
    const isDisabled = this.isInputDisabled(value);
    this.setState({
      isInputDisabled: isDisabled
    });
  };

  handlePropertyChange = data => {
    // const { value } = data;
    // const { rowKey, sourceItems } = this.props;
    // const { propsState } = this.state;
    // const selectedObj = sourceItems.find((o) => o.value === value);
    // const operandVal = propsState.operand;
    // const indexValue = rowKey.substring(rowKey.lastIndexOf('[') + 1, rowKey.lastIndexOf(']'));
    // operandVal[`${indexValue}`].fieldType = selectedObj.fieldType;
    // this.setState({ propsState });
  };

  handleDeletion = () => {
    const { onDeleteRow, rowIndex } = this.props;
    onDeleteRow(rowIndex - 1);
  };

  render() {
    const { isInputDisabled, propsState } = this.state;
    const { onDeleteRow, rowIndex, rowKey, sourceItems } = this.props;

    const COMPARE_PICKLIST_ITEMS = [
      { compare: "matches", Key: 1, name: "Equals" },
      { compare: "!matches", Key: 2, name: "Not Equal" },
      { compare: "less", Key: 3, name: "Less Than" },
      { compare: "le", Key: 4, name: "Less or Equal" },
      { compare: "greater", Key: 5, name: "Greater Than" },
      { compare: "ge", Key: 6, name: "Greater or Equal" },
      { compare: "sw", Key: 7, name: "Starts With" },
      { compare: "con", Key: 8, name: "Contains" },
      { compare: "!con", Key: 9, name: "Does Not Contains" },
      { compare: "null", Key: 10, name: "Is Null" },
      { compare: "!null", Key: 11, name: "Is Not Null" }
    ];

    return (
      <GridRow>
        <GridItem noFlex>
          <Label>{rowIndex}</Label>
        </GridItem>
        <GridItem noFlex>
          <PicklistFactorySingleSelectField
            className="RuleExpression__item"
            defaultText="Select a Filter"
            items={sourceItems}
            name={`${rowKey}.property`}
            hasMenuFilter
            itemValueKey="value"
            itemDisplayKey="display"
            // itemSecondaryKey="value"
            size="medium"
            onChange={this.handlePropertyChange}
          />
        </GridItem>
        <GridItem noFlex>
          <PicklistFactorySingleSelectField
            defaultText="Select a Filter"
            items={COMPARE_PICKLIST_ITEMS}
            name={`${rowKey}.compare`}
            hasMenuFilter
            itemValueKey="compare"
            itemDisplayKey="name"
            onChange={this.handleCompareChange}
          />
        </GridItem>
        <GridItem noFlex>
          <TextField isDisabled={isInputDisabled} name={`${rowKey}.value`}>
            <Input />
          </TextField>
        </GridItem>
        <GridItem noFlex>
          <Button
            type="icon-bare"
            size="medium"
            isDisabled={rowIndex === 1}
            onClick={this.handleDeletion}
          >
            <Icon icon="close" />
          </Button>
        </GridItem>
      </GridRow>
    );
  }
}

RuleExpression.propTypes = propTypes;
RuleExpression.defaultProps = defaultProps;

export default RuleExpression;
