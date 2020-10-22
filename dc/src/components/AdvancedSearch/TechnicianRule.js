import React from "react";
import {
  Button,
  GridRow,
  GridItem,
  Icon,
  Input,
  InputWrapper,
  PicklistFactory
} from "@svmx/ui-components-lightning";
import { TAG386 } from "constants/DisplayTagConstants";
import PropTypes from "prop-types";
import { getClauses, getDisplayValue } from "utils/DCUtils";
import { isNull } from "util";

const CLAUSE_TYPE = "operator";
const TECH_TYPE = "techField";
const WO_TYPE = "WOfield";
const WO_VALUE = "value";

const TechnicianRule = props => {
  const {
    index,
    onDeleteRow,
    onPickListValueChange,
    techRule,
    techFields,
    woFields
  } = props;
  const { operator, techField, value, WOfield } = techRule;

  const getFilteredWOFields = () => {
    let filteredFields = Object.values(woFields);
    const fieldDesc = woFields[techField];
    if (fieldDesc) {
      const { fieldType } = fieldDesc;
      filteredFields.filter(
        woField => woField.fieldType.toUpperCase() === fieldType.toUpperCase()
      );
    }
    return filteredFields;
  };

  const clauseList = getClauses();
  const filteredPickList = getFilteredWOFields();
  return (
    <GridRow key={index} cols={11}>
      <GridItem cols={3}>
        <PicklistFactory
          // defaultText="Select a Field"
          items={Object.values(techFields)}
          name="techFieldPicklist"
          size="small"
          onSelectedChange={event =>
            onPickListValueChange(event, index, TECH_TYPE)
          }
          selectedValues={techFields[techField] ? [techField] : []}
          itemValueKey="apiName"
          itemDisplayKey="display"
        />
      </GridItem>
      <GridItem />
      <GridItem cols={3}>
        <PicklistFactory
          // defaultText="Select a Clause"
          items={clauseList}
          name="clauseFieldPicklist"
          size="small"
          onSelectedChange={event =>
            onPickListValueChange(event, index, CLAUSE_TYPE)
          }
          selectedValues={isNull(operator) ? [] : [operator]}
          itemValueKey="value"
          itemDisplayKey="display"
        />
      </GridItem>
      <GridItem />
      <GridItem cols={4}>
        {isNull(value) && (
          <GridRow>
            <GridItem>
              <PicklistFactory
                // defaultText="Select a Field"
                items={filteredPickList}
                name="woFieldPicklist"
                size="small"
                onSelectedChange={event =>
                  onPickListValueChange(event, index, WO_TYPE)
                }
                selectedValues={
                  WOfield
                    ? filteredPickList.filter(item => item.value === WOfield)
                        .length
                      ? [WOfield]
                      : []
                    : []
                }
                itemValueKey="value"
                itemDisplayKey="display"
              />
            </GridItem>
            <GridItem className="Grid__item-btn" noFlex>
              <Button
                type="icon-container"
                size="medium"
                onClick={() =>
                  onPickListValueChange({ value: "" }, index, WO_VALUE)
                }
              >
                <Icon icon="edit" size="x-small" />
              </Button>
            </GridItem>
          </GridRow>
        )}
        {!isNull(value) && (
          <GridRow>
            <GridItem>
              <InputWrapper>
                <Input
                  placeholder="Enter Value"
                  name={`WOField-${index}`}
                  value={value}
                  onValueChange={event =>
                    onPickListValueChange(event, index, WO_VALUE)
                  }
                />
              </InputWrapper>
            </GridItem>
            <GridItem className="Grid__item-btn" noFlex>
              <Button
                type="icon-container"
                size="medium"
                onClick={() =>
                  onPickListValueChange({ value: null }, index, WO_VALUE)
                }
              >
                <Icon icon="picklist_type" size="x-small" />
              </Button>
            </GridItem>
          </GridRow>
        )}
      </GridItem>
      <GridItem />
      <GridItem className="Grid__item-btn">
        <Button
          type="icon-bare"
          onClick={() => onDeleteRow(index)}
          size="small"
          alt={getDisplayValue(TAG386)}
        >
          <Icon icon="close" size="small" />
        </Button>
      </GridItem>
    </GridRow>
  );
};

TechnicianRule.propTypes = {
  index: PropTypes.number.isRequired,
  onDeleteRow: PropTypes.func.isRequired,
  onPickListValueChange: PropTypes.func.isRequired,
  techFields: PropTypes.arrayOf(PropTypes.Object),
  techRule: PropTypes.shape({}).isRequired,
  woFields: PropTypes.arrayOf(PropTypes.Object)
};

TechnicianRule.defaultProps = {
  techFields: [],
  woFields: []
};

export default TechnicianRule;
