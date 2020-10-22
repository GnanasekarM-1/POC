import React, { Component } from "react";
import { PropTypes } from "prop-types";
import {
  DuelingPicklist,
  RadioGroup,
  Radio,
  Grid,
  Label,
  GridRow,
  GridItem
} from "@svmx/ui-components-lightning";
import { flatMap } from "lodash";
import { getDisplayValue } from "utils/DCUtils";
import { TAG047, TAG048, TAG049 } from "constants/DisplayTagConstants";

import "./TeamAndTechnicianSearch.scss";

const propTypes = {
  sourceItems: PropTypes.arrayOf(PropTypes.object),
  targetValues: PropTypes.arrayOf(PropTypes.string)
};

const defaultProps = {
  sourceItems: [],
  targetValues: []
};

class TechnicianSearch extends Component {
  constructor(props) {
    super(props);
    const { matchCriteria, sourceItems, targetValues } = props;
    this.state = { matchCriteria, sourceItems, targetValues };
  }

  handleTargetValuesChange = ({ targetValues }) => {
    const { onSearchFieldUpdate } = this.props;
    const { matchCriteria } = this.state;
    this.setState({ targetValues });
    onSearchFieldUpdate(
      { col: this.createSelectedFieldsObj(targetValues), matchCriteria },
      "tech"
    );
  };

  handleRadioChange = ({ value }) => {
    const { onSearchFieldUpdate } = this.props;
    const { targetValues } = this.state;
    this.setState({ matchCriteria: value });
    onSearchFieldUpdate(
      { col: this.createSelectedFieldsObj(targetValues), matchCriteria: value },
      "tech"
    );
  };

  createSelectedFieldsObj = targetValues => {
    const selectedFields = flatMap(targetValues, val => {
      const obj = {};
      obj.name = val;
      obj.width = 0;
      return obj;
    });
    return selectedFields;
  };

  render() {
    const { matchCriteria, targetValues, sourceItems } = this.state;
    return (
      <Grid isVertical>
        <GridRow>
          <GridItem>{getDisplayValue("TAG148")}</GridItem>
        </GridRow>
        <GridRow className="TechnicianSearch__duelingPicklist">
          <GridItem>
            <DuelingPicklist
              allowOrdering
              hasSourceFilter
              selectMode="multi"
              sourceItems={sourceItems}
              sourceLabel={getDisplayValue("TAG060")}
              targetLabel={getDisplayValue("TAG061")}
              targetValues={targetValues}
              onTargetValuesChange={this.handleTargetValuesChange}
            />
          </GridItem>
        </GridRow>
        <GridRow className="TechnicianSearch__GridRow-radio">
          <GridItem>
            <Label>{getDisplayValue(TAG047)}</Label>
            <RadioGroup
              className="TechnicianSearch__radioButton"
              value={matchCriteria}
              name="TechMatch"
              onValueChange={this.handleRadioChange}
            >
              <Radio className="TechnicianSearch__radioButton" value="all">
                {getDisplayValue(TAG048)}
              </Radio>
              <Radio className="TechnicianSearch__radioButton" value="any">
                {getDisplayValue(TAG049)}
              </Radio>
            </RadioGroup>
          </GridItem>
        </GridRow>
      </Grid>
    );
  }
}

TechnicianSearch.propTypes = propTypes;
TechnicianSearch.defaultProps = defaultProps;

export default TechnicianSearch;
