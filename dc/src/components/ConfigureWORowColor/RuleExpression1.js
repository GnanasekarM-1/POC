import React, { Component } from "react";
import {
  Button,
  FormFields,
  GridItem,
  GridRow,
  Input,
  Icon,
  Label,
  PicklistFactory,
  InputWrapper
} from "@svmx/ui-components-lightning";
import { PropTypes } from "prop-types";
import { EVENT_EXP_TYPE, WO_EXP_TYPE } from "constants/AppConstants";
import { cloneDeep, isEqual } from "lodash";
import { getDisplayValue } from "utils/DCUtils";
import {
  TAG249,
  TAG248,
  TAG250,
  TAG289,
  TAG290,
  TAG291,
  TAG292,
  TAG293,
  TAG294,
  TAG295,
  TAG296
} from "constants/DisplayTagConstants";
import "./ConfigureWORowColor.scss";

const propTypes = {
  onDeleteRow: PropTypes.func,
  rowIndex: PropTypes.string,
  rowItem: PropTypes.objectOf(PropTypes.object),
  rowKey: PropTypes.string.isRequired,
  setModifiedOperand: PropTypes.func,
  sourceItems: PropTypes.arrayOf(PropTypes.object)
};

const defaultProps = {
  onDeleteRow: () => {},
  rowIndex: 1,
  rowItem: { compare: "", property: "", value: "" },
  setModifiedOperand: () => {},
  sourceItems: []
};

class RuleExpression1 extends Component {
  constructor(props) {
    super(props);
    const { rowItem } = props;
    const { compare, property, type, value } = rowItem;
    this.state = {
      value,
      compare,
      property: type === EVENT_EXP_TYPE ? this.getEventProperty() : property,
      propsState: props,
      isInputDisabled: this.isInputDisabled(compare)
    };
  }

  getEventProperty = () => {
    const { sourceItems = [], rowItem = {} } = this.props;
    const { property } = rowItem;
    let eventProperty = property;
    const eventField = sourceItems.find(sourceItem => {
      const { type, key } = sourceItem;
      return type === EVENT_EXP_TYPE && key === property;
    });
    if (eventField) {
      const { value } = eventField;
      eventProperty = value;
    }
    return eventProperty;
  };

  isInputDisabled = compare => compare === "null" || compare === "!null";

  handleCompareChange = ({ value }) => {
    const isDisabled = this.isInputDisabled(value);
    this.setState({
      isInputDisabled: isDisabled
    });
  };

  handleDeletion = () => {
    const { onDeleteRow, rowIndex } = this.props;
    onDeleteRow(rowIndex - 1);
  };

  handleValueChange = ({ value }) => {
    this.setState({ value }, this.setModifiedOperand);
  };

  hanldePicklistChange = (data, name) => {
    const { display, selectedValues } = data;

    if (name === "compare") {
      const isDisabled = this.isInputDisabled(selectedValues[0]);

      if (isDisabled) {
        const obj = { value: "" };
        this.handleValueChange(obj);
      }
      this.setState({
        isInputDisabled: isDisabled
      });
    }

    this.setState({ display, [name]: selectedValues[0] }, () =>
      this.setModifiedOperand(name)
    );
  };

  setModifiedOperand = name => {
    const { setModifiedOperand, sourceItems, rowIndex, rowItem } = this.props;
    const { compare, display, property, value } = this.state;

    const modifiedRowItem = cloneDeep(rowItem);
    modifiedRowItem.compare = compare;
    if (name === "property") {
      const selectedObj = sourceItems.find(o => o.value === property);
      modifiedRowItem.type =
        display && display.startsWith("Event.") ? EVENT_EXP_TYPE : WO_EXP_TYPE;
      modifiedRowItem.fieldType = selectedObj && selectedObj.fieldType;
    }

    modifiedRowItem.value = value;
    modifiedRowItem.property = property;
    setModifiedOperand(modifiedRowItem, rowIndex - 1);
  };

  render() {
    const { rowIndex, sourceItems } = this.props;

    const { compare, isInputDisabled, property, value } = this.state;

    const COMPARE_PICKLIST_ITEMS = [
      { compare: "matches", Key: 1, name: getDisplayValue(TAG249) },
      { compare: "!matches", Key: 2, name: getDisplayValue(TAG289) },
      { compare: "less", Key: 3, name: getDisplayValue(TAG248) },
      { compare: "le", Key: 4, name: getDisplayValue(TAG291) },
      { compare: "greater", Key: 5, name: getDisplayValue(TAG250) },
      { compare: "ge", Key: 6, name: getDisplayValue(TAG290) },
      { compare: "sw", Key: 7, name: getDisplayValue(TAG292) },
      { compare: "con", Key: 8, name: getDisplayValue(TAG293) },
      { compare: "!con", Key: 9, name: getDisplayValue(TAG294) },
      { compare: "null", Key: 10, name: getDisplayValue(TAG295) },
      { compare: "!null", Key: 11, name: getDisplayValue(TAG296) }
    ];
    return (
      <GridRow>
        <GridItem className="RuleExpression__items" noFlex>
          <Label>{rowIndex}</Label>
        </GridItem>
        <GridItem className="RuleExpression__items" noFlex>
          <PicklistFactory
            className="RuleExpression__item"
            defaultText="Select a Filter"
            items={sourceItems}
            name="property"
            hasMenuFilter
            itemValueKey="value"
            itemDisplayKey="display"
            // itemSecondaryKey="value"
            size="small"
            onSelectedChange={data =>
              this.hanldePicklistChange(data, "property")
            }
            selectedValues={[property]}
          />
        </GridItem>
        <GridItem className="RuleExpression__items" noFlex>
          <PicklistFactory
            defaultText="Select a Filter"
            items={COMPARE_PICKLIST_ITEMS}
            name="compare"
            hasMenuFilter
            itemValueKey="compare"
            itemDisplayKey="name"
            size="small"
            onSelectedChange={data =>
              this.hanldePicklistChange(data, "compare")
            }
            selectedValues={[compare]}
          />
        </GridItem>
        <GridItem className="RuleExpression__items" noFlex>
          <InputWrapper isDisabled={isInputDisabled}>
            <Input value={value} onValueChange={this.handleValueChange} />
          </InputWrapper>
        </GridItem>
        <GridItem className="RuleExpression__items" noFlex>
          <Button
            type="icon-bare"
            size="small"
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

RuleExpression1.propTypes = propTypes;
RuleExpression1.defaultProps = defaultProps;

export default RuleExpression1;
