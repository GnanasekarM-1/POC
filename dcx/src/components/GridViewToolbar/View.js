import React, { Component } from "react";
import PropTypes from "prop-types";
import {
  Label,
  Checkbox,
  Icon,
  Input,
  InputWrapper,
  Menu,
  MenuItem,
  Picklist,
  Grid,
  GridRow,
  GridItem
} from "@svmx/ui-components-lightning";
import { intersectionWith } from "lodash";
import { FIELD_VALUE_VIEW, FIELD_WO_VIEW_TYPE } from "constants/AppConstants";
import { isView, getViewSortedByField } from "utils/ViewUtils";
import { TAG327, TAG456 } from "constants/DisplayTagConstants";
import { getDisplayValue } from "utils/DCUtils";
import Counter from "./Counter";

import "./GridViewToolbar.scss";

class View extends Component {
  constructor(props) {
    super(props);
    const { defaultView, view } = props;
    const { Key: viewId } = view;
    this.isQueueOver = false;
    this.state = {
      isChecked: defaultView === viewId,
      targetArray: [viewId]
    };
  }

  componentWillReceiveProps = nextProps => {
    const { defaultView, view, views } = nextProps;
    const { Key: viewId } = view;
    if (viewId) {
      const [defView] = views;
      const found = views.filter(v => v.Key === viewId);
      this.setState({
        isChecked: defaultView === viewId,
        targetArray: found.length ? [viewId] : [defView.Key]
      });
    }
  };

  triggerViewChanged = id => {
    const { viewSelectionChanged, views } = this.props;
    const found = views.filter(view => {
      const { Key: viewId } = view;
      return viewId === id;
    });
    if (found.length) {
      const [view] = found;
      viewSelectionChanged(view);
    }
  };

  handleTargetChange = ({ selectedValues, value }) => {
    this.setState({ targetArray: selectedValues });
    setTimeout(() => this.triggerViewChanged(value), 0);
  };

  handleCheckedChange = ({ isChecked }) => {
    this.setState({ isChecked });
    const { defaultViewChanged, view } = this.props;
    const { Key: viewId } = view;
    defaultViewChanged(isChecked ? viewId : "");
  };

  getMenuItem = items => {
    let queueOver = false;
    const children = items.map(item => {
      if (item.woViewType === FIELD_VALUE_VIEW && !queueOver) {
        queueOver = true;
        return (
          <MenuItem className="slds-has-divider--top-space" value={item.Key}>
            {item.Value}
          </MenuItem>
        );
      }
      return <MenuItem value={item.Key}>{item.Value}</MenuItem>;
    });
    return <Menu>{children}</Menu>;
  };

  render() {
    const { isChecked, targetArray } = this.state;
    const { counters = [], loading, viewCount, view, views = [] } = this.props;

    const visibleCounters = intersectionWith(
      counters,
      views,
      (a, b) => a.id === b.Key
    );
    const items = getViewSortedByField(views, FIELD_WO_VIEW_TYPE);
    return (
      <Grid isVertical className="View__Wrapper">
        <GridRow className="GridViewToolbar__GridRow-label">
          <div className="GridViewToolbar__GridItem">
            <Label className="View__label">{getDisplayValue(TAG456)}</Label>
          </div>
          <div className="GridViewToolbar__GridItem">
            <Counter
              counters={visibleCounters}
              viewCount={viewCount}
              views={views}
            />
          </div>
        </GridRow>
        <GridRow className="GridViewToolbar__GridRow-input">
          <GridItem className="GridViewToolbar__GridItem">
            <Picklist
              defaultText="Select a View"
              isDisabled={loading}
              name="picklist-single"
              onSelectedChange={e => this.handleTargetChange(e)}
              selectedValues={targetArray}
              size="medium"
            >
              <InputWrapper>
                <Input name="picklist-single" isComboBox />
                <Icon icon="down" size="x-small" />
              </InputWrapper>
              {this.getMenuItem(items)}
            </Picklist>
          </GridItem>
          <GridItem className="GridViewToolbar__GridItem" padded>
            {isView(view) && (
              <Checkbox
                isDisabled={loading}
                isChecked={isChecked}
                onCheckedChange={this.handleCheckedChange}
                name="Default View"
              >
                {getDisplayValue(TAG327)}
              </Checkbox>
            )}
          </GridItem>
        </GridRow>
      </Grid>
    );
  }
}

View.propTypes = {
  counters: PropTypes.arrayOf(PropTypes.shape({})).isRequired,
  defaultView: PropTypes.string.isRequired,
  defaultViewChanged: PropTypes.func.isRequired,
  loading: PropTypes.bool,
  view: PropTypes.shape({}).isRequired,
  viewCount: PropTypes.shape({}).isRequired,
  views: PropTypes.arrayOf(PropTypes.shape({})).isRequired,
  viewSelectionChanged: PropTypes.func.isRequired
};

export default View;
