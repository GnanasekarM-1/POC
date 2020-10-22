import React, { Component } from "react";
import PropTypes from "prop-types";
import { convertUint2Hex } from "utils/DCUtils";
import { isView } from "utils/ViewUtils";
import { isEqual } from "lodash";
import { Badge, Tooltip } from "@svmx/ui-components-lightning";
import "./GridViewToolbar.scss";

class Counter extends Component {
  state = { viewcounters: null };

  constructor(props) {
    super(props);
    const { counters } = props;
    const viewcounters = Object.values(counters || {}).filter(
      counter => counter.name.trim() !== "None"
    );
    this.state = { viewcounters };
  }

  shouldComponentUpdate = nextProps => {
    return !isEqual(nextProps, this.props);
  };

  componentWillReceiveProps = nextProps => {
    const { counters } = nextProps;
    const viewcounters = Object.values(counters || {}).filter(
      counter => counter.name.trim() !== "None"
    );
    this.state = { viewcounters };
  };

  checkAvailability = target => {
    const { views } = this.props;
    const listViews = views.filter(view => isView(view));

    const viewAvailbale = listViews.filter(view => view.Key === target);

    if (viewAvailbale.length) {
      return viewAvailbale[0].Value;
    }

    return "";
  };

  render() {
    const { viewCount } = this.props;
    const { viewcounters } = this.state;
    return viewcounters.map(counter => {
      const { id } = counter;
      return (
        <Tooltip
          autoAdjust
          body={<p>{this.checkAvailability(id)}</p>}
          key={Math.random(9999)}
          method="hover"
          popoverContainer=".slds-scope"
          position="top"
          theme="info"
        >
          <Badge
            allowMinWidth
            hasTooltip={false}
            icon="record"
            iconColor={convertUint2Hex(counter.color)}
            iconSize="small"
            type="lightest"
          >
            {parseInt(viewCount[id], 10) >= 0 ? viewCount[id] : ""}
          </Badge>
        </Tooltip>
      );
    });
  }
}
Counter.propTypes = {
  items: PropTypes.arrayOf(PropTypes.object).isRequired
};
export default Counter;
