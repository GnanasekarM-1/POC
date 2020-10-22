import React, { Component } from "react";
import { PropTypes } from "prop-types";
import {
  DuelingPicklist,
  Grid,
  GridRow,
  GridItem
} from "@svmx/ui-components-lightning";
import { getDisplayValue } from "utils/DCUtils";
import "./TeamAndTechnicianSearch.scss";

const propTypes = {
  sourceItems: PropTypes.arrayOf(PropTypes.object),
  targetValues: PropTypes.arrayOf(PropTypes.string)
};

const defaultProps = {
  sourceItems: [],
  targetValues: []
};

class WorkOrderSearch extends Component {
  constructor(props) {
    super(props);
    const { sourceItems, targetValues } = props;
    this.state = { sourceItems, targetValues };
  }

  handleTargetValuesChange = ({ targetValues }) => {
    const { onSearchFieldUpdate } = this.props;
    this.setState({ targetValues });
    const selectedFields = targetValues.flatMap(val => {
      const obj = {};
      obj.name = val;
      obj.width = 0;
      return obj;
    });
    onSearchFieldUpdate(selectedFields, "wo");
  };

  render() {
    const { targetValues, sourceItems } = this.state;
    return (
      <Grid isVertical>
        <GridRow>
          <GridItem>{getDisplayValue("TAG146")}</GridItem>
        </GridRow>
        <GridRow className="WorkOrderSearch__duelingPicklist">
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
      </Grid>
    );
  }
}

WorkOrderSearch.propTypes = propTypes;
WorkOrderSearch.defaultProps = defaultProps;

export default WorkOrderSearch;
