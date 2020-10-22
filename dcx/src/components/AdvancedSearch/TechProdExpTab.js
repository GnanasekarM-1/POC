import React, { useEffect, useState } from "react";
import {
  Checkbox,
  Grid,
  GridRow,
  GridItem,
  Textarea,
  Label
} from "@svmx/ui-components-lightning";
import PropTypes from "prop-types";
import {
  PRODUCT_EXPERTISE,
  PRODUCT_EXPERTISE_ENABLED,
  WO_PRODUCT_PROPERTY
} from "constants/AppConstants";
import { TAG323, TAG390 } from "constants/DisplayTagConstants";
import { getDisplayValue } from "utils/DCUtils";

const TechProdExpTab = props => {
  const { atsExpertise, productExpertise, updateATSState, selectedWO } = props;
  const { search } = atsExpertise;
  const [checked, setChecked] = useState(JSON.parse(search));

  useEffect(() => {
    if (updateATSState) {
      updateATSState({
        [PRODUCT_EXPERTISE]: productExpertise,
        [PRODUCT_EXPERTISE_ENABLED]: checked
      });
    }
  });

  const getProductExpertise = workOrder =>
    (workOrder[`${WO_PRODUCT_PROPERTY}`] &&
      workOrder[`${WO_PRODUCT_PROPERTY}`].Name) ||
    "";

  const handleIncludeInSearch = data => {
    const { isChecked } = data;
    if (updateATSState) {
      const changed = { adv_atsExpertise: { search: isChecked } };
      setTimeout(
        () =>
          updateATSState({ changed, [PRODUCT_EXPERTISE_ENABLED]: isChecked }),
        0
      );
    }
    setChecked(isChecked);
  };

  return (
    <Grid className="AdvancedSearch__Grid" isVertical>
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
      </GridRow>
      <GridRow>
        <GridItem noFlex>
          <Label>{getDisplayValue(TAG323)}</Label>
        </GridItem>
      </GridRow>
      <GridRow class="AdvancedSearch__ProdExp">
        <GridItem className="AdvancedSearch__ProdExp">
          <Textarea
            className="AdvancedSearch__ProdExp-textArea"
            value={getProductExpertise(selectedWO)}
            name="productExpertise"
            isReadOnly
          />
        </GridItem>
      </GridRow>
    </Grid>
  );
};

TechProdExpTab.propTypes = {
  atsExpertise: PropTypes.shape({}).isRequired,
  productExpertise: PropTypes.string,
  selectedWO: PropTypes.shape({}).isRequired,
  updateATSState: PropTypes.func.isRequired,
  updateUserSetting: PropTypes.func.isRequired
};

export default TechProdExpTab;
