import React, { Component } from "react";
import {
  DuelingPicklist,
  GridRow,
  GridItem
} from "@svmx/ui-components-lightning";
import { getDisplayValue } from "utils/DCUtils";
import { isEqual } from "lodash";
import "./ConfTechView.scss";

class ConfTechColumn extends Component {
  state = {};

  constructor(props) {
    super(props);
    const { sourceItems, targetValues } = props;
    this.state = { sourceItems, targetValues };
  }

  shouldComponentUpdate(nextProps, nextState) {
    const { targetValues } = nextState;
    const { targetValues: targetValuesState } = this.state;
    return !isEqual(targetValuesState, targetValues);
  }

  handleTargetValuesChange = ({ targetValues }) => {
    const { onColumnChange } = this.props;
    this.setState({ targetValues });
    onColumnChange(targetValues);
  };

  render() {
    const { sourceItems, targetValues } = this.state;

    return (
      <GridRow cols={6}>
        <GridItem cols={4}>
          <DuelingPicklist
            allowOrdering
            hasSourceFilter
            selectMode="multi"
            sourceItems={sourceItems}
            sourceLabel={getDisplayValue("TAG060")}
            targetLabel={getDisplayValue("TAG061")}
            targetValues={targetValues}
            onTargetValuesChange={this.handleTargetValuesChange}
            size="large"
          />
        </GridItem>
      </GridRow>
    );
  }
}

export default ConfTechColumn;
