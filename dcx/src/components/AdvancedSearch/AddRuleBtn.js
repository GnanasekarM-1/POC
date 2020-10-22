import React from "react";
import { Button, Icon } from "@svmx/ui-components-lightning";
import PropTypes from "prop-types";
import { TAG387 } from "constants/DisplayTagConstants";
import { getDisplayValue } from "utils/DCUtils";

const AddRuleBtn = props => {
  const { onBtnClick } = props;
  return (
    <Button type="neutral" onClick={() => onBtnClick()}>
      <Icon icon="add" align="left" size="x-small" />
      {getDisplayValue(TAG387)}
    </Button>
  );
};

AddRuleBtn.propTypes = {
  onBtnClick: PropTypes.func.isRequired
};

export default AddRuleBtn;
