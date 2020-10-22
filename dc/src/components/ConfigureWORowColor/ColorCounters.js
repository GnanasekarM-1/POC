import React, { Component } from "react";
import PropTypes from "prop-types";
import {
  ColorPicker,
  Grid,
  GridItem,
  GridRow,
  PicklistFactory
} from "@svmx/ui-components-lightning";
import {
  NONE,
  VIEW_PICKLIST_1,
  VIEW_PICKLIST_2,
  VIEW_PICKLIST_3
} from "constants/AppConstants";
import { convertUint2Hex } from "utils/DCUtils";
import { isView } from "utils/ViewUtils";
import { groupBy, compact, cloneDeep } from "lodash";
import "./ConfigureWORowColor.scss";

const propTypes = {
  onViewCounterChange: PropTypes.func.isRequired,
  picklistItems: PropTypes.arrayOf({}),
  views: PropTypes.shape({})
};

const defaultProps = {
  picklistItems: [],
  views: []
};

class ColorCounters extends Component {
  constructor(props) {
    super(props);
    const viewsCounter = Object.values(this.getConfigurableViews());
    this.state = {
      targetView1: [this.checkAvailability(viewsCounter[0].id)],
      targetView2: [this.checkAvailability(viewsCounter[1].id)],
      targetView3: [this.checkAvailability(viewsCounter[2].id)],
      view1Color: convertUint2Hex(viewsCounter[0].color),
      view2Color: convertUint2Hex(viewsCounter[1].color),
      view3Color: convertUint2Hex(viewsCounter[2].color),
      viewsCounter
    };
  }

  checkAvailability = target => {
    const { picklistItems } = this.props;
    const listViews = picklistItems.filter(view => isView(view));

    const viewAvailbale = listViews.filter(view => view.Key === target);

    if (viewAvailbale.length) {
      return viewAvailbale[0].Value;
    }

    return NONE;
  };

  getSelectedViewId = selectedView => {
    const { picklistItems } = this.props;
    const viewAndQueue = picklistItems;
    const listViews = viewAndQueue.filter(view => view.Value === selectedView);
    if (listViews.length) {
      const [currentView] = listViews;
      const viewId = currentView.Key;
      return viewId;
    }
    return null;
  };

  getConfigurableViews = () => {
    const EMPTY_COUNTERS = {
      view1: { color: "#FF3300", id: null, name: NONE },
      view2: { color: "#FF9501", id: null, name: NONE },
      view3: { color: "#0070D2", id: null, name: NONE }
    };
    const { views, picklistItems } = this.props;
    if (!views || !views.length) {
      if (picklistItems && picklistItems.length) {
        const counterGrp = groupBy(
          compact(
            picklistItems.map(picklistItem => {
              const { Key, Value } = picklistItem;
              if (Value === "Unresourced") {
                return { id: Key, sequence: "view1", Value };
              }
              if (Value === "Scheduling violations") {
                return { id: Key, sequence: "view2", Value };
              }
              if (Value === "In Jeopardy") {
                return { id: Key, sequence: "view3", Value };
              }
              return undefined;
            })
          ),
          counter => counter.sequence
        );
        Object.keys(counterGrp).map(index => {
          const [defaultView] = counterGrp[index];
          const { id, sequence, Value } = defaultView;
          const configView = EMPTY_COUNTERS[sequence];
          configView.id = id;
          configView.name = Value;
          return undefined;
        });
        return EMPTY_COUNTERS;
      }
      return EMPTY_COUNTERS;
    }
    return views;
  };

  handlePicklistChange = (data, name) => {
    const { selectedValues } = data;
    const [selectedValue] = selectedValues;
    const NAME = "name";

    switch (name) {
      case VIEW_PICKLIST_1:
        this.setState({ targetView1: selectedValues });
        this.updateViewCounter(selectedValue, 0, NAME);
        break;
      case VIEW_PICKLIST_2:
        this.setState({ targetView2: selectedValues });
        this.updateViewCounter(selectedValue, 1, NAME);
        break;
      case VIEW_PICKLIST_3:
        this.setState({ targetView3: selectedValues });
        this.updateViewCounter(selectedValue, 2, NAME);
        break;

      default:
        break;
    }
  };

  handleColorChange = (data, name) => {
    const { value } = data;
    const COLOR = "color";
    switch (name) {
      case VIEW_PICKLIST_1:
        this.setState({ view1Color: value });
        this.updateViewCounter(value, 0, COLOR);
        break;
      case VIEW_PICKLIST_2:
        this.setState({ view2Color: value });
        this.updateViewCounter(value, 1, COLOR);
        break;
      case VIEW_PICKLIST_3:
        this.setState({ view3Color: value });
        this.updateViewCounter(value, 2, COLOR);
        break;

      default:
        break;
    }
  };

  updateViewCounter = (value, index, type) => {
    const { onViewCounterChange } = this.props;
    const { viewsCounter } = this.state;
    const modifiedCounter = cloneDeep(viewsCounter);
    if (modifiedCounter[index]) {
      const counterValue = modifiedCounter[index];
      counterValue[`${type}`] = value;

      if (type === "name") {
        const id = "id";
        counterValue[`${id}`] = this.getSelectedViewId(value);
      }
    }

    this.setState({ viewsCounter: modifiedCounter });
    onViewCounterChange(modifiedCounter);
  };

  render() {
    const { picklistItems } = this.props;
    const {
      targetView1,
      targetView2,
      targetView3,
      view1Color,
      view2Color,
      view3Color
    } = this.state;

    const viewAndQueue = picklistItems;
    const listViews = viewAndQueue.filter(view => isView(view));
    const noneObj = {};
    noneObj.Value = NONE;
    listViews.unshift(noneObj);
    return (
      <Grid isVertical>
        <GridRow>
          <GridItem noFlex>
            <span className="ColorCounters__items">1</span>
          </GridItem>
          <GridItem noFlex>
            <ColorPicker
              value={view1Color}
              onValueChange={data =>
                this.handleColorChange(data, VIEW_PICKLIST_1)
              }
            />
          </GridItem>
          <GridItem noFlex>
            <PicklistFactory
              className="ColorCounters__picklist"
              defaultText="Select a Filter"
              items={listViews}
              name={VIEW_PICKLIST_1}
              itemValueKey="Value"
              itemDisplayKey="Value"
              onSelectedChange={data =>
                this.handlePicklistChange(data, VIEW_PICKLIST_1)
              }
              selectedValues={targetView1}
            />
          </GridItem>
        </GridRow>
        <GridRow>
          <GridItem noFlex>
            <span className="ColorCounters__items">2</span>
          </GridItem>
          <GridItem noFlex>
            <ColorPicker
              value={view2Color}
              onValueChange={data =>
                this.handleColorChange(data, VIEW_PICKLIST_2)
              }
            />
          </GridItem>
          <GridItem noFlex>
            <PicklistFactory
              className="ColorCounters__picklist"
              defaultText="Select a Filter"
              items={listViews}
              name={VIEW_PICKLIST_2}
              itemValueKey="Value"
              itemDisplayKey="Value"
              onSelectedChange={data =>
                this.handlePicklistChange(data, VIEW_PICKLIST_2)
              }
              selectedValues={targetView2}
            />
          </GridItem>
        </GridRow>
        <GridRow>
          <GridItem noFlex>
            <span className="ColorCounters__items">3</span>
          </GridItem>
          <GridItem noFlex>
            <ColorPicker
              value={view3Color}
              onValueChange={data =>
                this.handleColorChange(data, VIEW_PICKLIST_3)
              }
            />
          </GridItem>
          <GridItem noFlex>
            <PicklistFactory
              className="ColorCounters__picklist"
              defaultText="Select a Filter"
              items={listViews}
              name={VIEW_PICKLIST_3}
              itemValueKey="Value"
              itemDisplayKey="Value"
              onSelectedChange={data =>
                this.handlePicklistChange(data, VIEW_PICKLIST_3)
              }
              selectedValues={targetView3}
            />
          </GridItem>
        </GridRow>
      </Grid>
    );
  }
}

ColorCounters.propTypes = propTypes;
ColorCounters.defaultProps = defaultProps;

export default ColorCounters;
