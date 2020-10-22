import React from "react";
import {
  GridRow,
  GridItem,
  Label,
  Container
} from "@svmx/ui-components-lightning";
import PropTypes from "prop-types";
import { TAG383, TAG384, TAG385 } from "constants/DisplayTagConstants";
import { getDisplayValue } from "utils/DCUtils";
import TechnicianRule from "./TechnicianRule";

const TechRulesGrid = props => {
  const {
    removeRow,
    pickListValueChange,
    techFields,
    techRules,
    woFields
  } = props;

  const woFieldMap = {};
  const techFieldMap = {};
  woFields.map(woField => {
    const { value } = woField;
    woFieldMap[value] = woField;
  });
  techFields.map(woField => {
    const { apiName } = woField;
    techFieldMap[apiName] = woField;
  });

  return (
    <Container className="AdvancedSearch__Grid-content">
      <GridRow cols={11} className="AdvancedSearch__Grid-tableHeader">
        <GridItem cols={3}>
          <Label>{getDisplayValue(TAG383)}</Label>
        </GridItem>
        <GridItem />
        <GridItem cols={3}>
          <Label>{getDisplayValue(TAG384)}</Label>
        </GridItem>
        <GridItem />
        <GridItem cols={4}>
          <Label>{getDisplayValue(TAG385)}</Label>
        </GridItem>
        <GridItem />
      </GridRow>
      <Container className="AdvancedSearch__Grid-tableContent">
        {techRules.map((techRule, index) => (
          <TechnicianRule
            index={index}
            techRule={techRule}
            techFields={techFieldMap}
            woFields={woFieldMap}
            onPickListValueChange={pickListValueChange}
            onDeleteRow={removeRow}
          />
        ))}
      </Container>
    </Container>
  );
};

TechRulesGrid.propTypes = {
  pickListValueChange: PropTypes.func.isRequired,
  removeRow: PropTypes.func.isRequired,
  techFields: PropTypes.arrayOf(PropTypes.Object),
  techRules: PropTypes.arrayOf(PropTypes.Object),
  woFields: PropTypes.arrayOf(PropTypes.Object)
};

TechRulesGrid.defaultProps = {
  techFields: [],
  techRules: [],
  woFields: []
};

export default TechRulesGrid;
