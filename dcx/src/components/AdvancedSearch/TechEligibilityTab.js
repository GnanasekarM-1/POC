import React, { useEffect, useState } from "react";
import {
  Button,
  ButtonGroup,
  Checkbox,
  Grid,
  GridRow,
  GridItem,
  Icon
} from "@svmx/ui-components-lightning";
import PropTypes from "prop-types";
import { cloneDeep } from "lodash";
import { TAG390, TAG481 } from "constants/DisplayTagConstants";
import { LST_ELIGIBILITY, ELIGIBILITY_ENABLED } from "constants/AppConstants";
import { getDisplayValue } from "utils/DCUtils";
import TechRulesGrid from "./TechRulesGrid";
import AddRuleBtn from "./AddRuleBtn";

const TechEligibityTab = props => {
  const createNewRule = () => ({
    operator: "eq",
    techField: "Name",
    value: null,
    WOfield: null
  });

  const { atsEligibility, lstEligibility = [], updateATSState } = props;
  const { search } = atsEligibility;
  const [checked, setChecked] = useState(JSON.parse(search));
  const [techRules, setTechRules] = useState(cloneDeep(lstEligibility));

  useEffect(() => {
    if (updateATSState) {
      updateATSState({
        [ELIGIBILITY_ENABLED]: checked,
        [LST_ELIGIBILITY]: techRules
      });
    }
  });

  const addRule = () => {
    setTechRules(techRules.concat(createNewRule()));
  };

  const deleteRow = index => {
    techRules.splice(index, 1);
    setTechRules([...techRules]);
  };

  const deleteAll = () => {
    setTechRules([]);
  };

  const handleIncludeInSearch = data => {
    const { isChecked } = data;
    if (updateATSState) {
      const changed = { adv_atsEligibility: { search: isChecked } };
      setTimeout(
        () => updateATSState({ changed, [ELIGIBILITY_ENABLED]: isChecked }),
        0
      );
    }
    setChecked(isChecked);
  };

  const pickListValueChange = (event, index, field) => {
    const { value } = event;
    const techRule = techRules[index];
    techRule[field] = value;
    const newRules = [...techRules];
    if (updateATSState) {
      updateATSState({ [LST_ELIGIBILITY]: newRules });
    }
    setTechRules(newRules);
  };

  const { techFields, woFields } = props;
  return (
    <Grid isVertical className="AdvancedSearch__Grid">
      <GridRow className="AdvancedSearch__Grid-title">
        <GridItem noFlex>
          <Checkbox
            isChecked={checked}
            onCheckedChange={event => handleIncludeInSearch(event)}
            name={getDisplayValue(TAG390)}
          >
            {getDisplayValue(TAG390)}
          </Checkbox>
        </GridItem>
        <GridItem />
        <GridItem noFlex>
          <ButtonGroup>
            <Button
              isDisabled={!techRules.length}
              type="neutral"
              onClick={deleteAll}
            >
              <Icon icon="delete" align="left" size="x-small" />
              {getDisplayValue(TAG481)}
            </Button>
            <AddRuleBtn onBtnClick={addRule} />
          </ButtonGroup>
        </GridItem>
      </GridRow>
      <TechRulesGrid
        techRules={techRules}
        techFields={techFields}
        woFields={woFields}
        pickListValueChange={pickListValueChange}
        removeRow={deleteRow}
      />
    </Grid>
  );
};

TechEligibityTab.propTypes = {
  atsEligibility: PropTypes.shape({}).isRequired,
  lstEligibility: PropTypes.arrayOf(PropTypes.Object),
  techFields: PropTypes.arrayOf(PropTypes.Object),
  updateATSState: PropTypes.func.isRequired,
  woFields: PropTypes.arrayOf(PropTypes.Object)
};

TechEligibityTab.defaultProps = {
  lstEligibility: [],
  techFields: [],
  woFields: []
};
export default TechEligibityTab;
