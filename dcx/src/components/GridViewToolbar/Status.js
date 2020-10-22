import React, { Component } from "react";
import PropTypes from "prop-types";
import {
  Label,
  Checkbox,
  Grid,
  GridRow,
  GridItem
} from "@svmx/ui-components-lightning";
import { flatMap } from "lodash";
import {
  ALL,
  ASSIGNED,
  NEW,
  QUEUED,
  getSettingValue,
  DCON001_SET007
} from "constants/AppSettings";
import { TAG086, TAG087, TAG088, TAG188 } from "constants/DisplayTagConstants";
import { getDisplayValue } from "utils/DCUtils";
import "./GridViewToolbar.scss";

class Status extends Component {
  constructor(props) {
    super(props);
    const status = getSettingValue(DCON001_SET007);
    const values = flatMap(status.split(","), val => val.trim());
    const allSelected = values.includes(ALL);
    this.state = {
      isAssignChecked: allSelected || values.includes(ASSIGNED),
      isNewChecked: allSelected || values.includes(NEW),
      isQueueChecked: allSelected || values.includes(QUEUED)
    };
  }

  handleCheckedChange = data => {
    const { isNewChecked, isAssignChecked, isQueueChecked } = this.state;

    const { isChecked, name } = data;
    switch (name) {
      case "New":
        this.setState({ isNewChecked: isChecked });
        break;
      case "Assigned":
        this.setState({ isAssignChecked: isChecked });
        break;
      case "Queued":
        this.setState({ isQueueChecked: isChecked });
        break;
      default:
        break;
    }

    let status = ALL;
    const statusObj = {
      [ASSIGNED]: isAssignChecked,
      [NEW]: isNewChecked,
      [QUEUED]: isQueueChecked
    };
    statusObj[name] = isChecked;

    const statusFilter = Object.keys(statusObj).filter(
      key => statusObj[key] === true
    );
    if (statusFilter.length && statusFilter.length < 3) {
      status = statusFilter.toString();
    }
    const { statusFilterChanged } = this.props;
    setTimeout(() => statusFilterChanged(status), 0);
  };

  render() {
    const { loading } = this.props;
    const { isNewChecked, isAssignChecked, isQueueChecked } = this.state;
    return (
      <Grid isVertical>
        <GridRow className="GridViewToolbar__GridRow-label">
          <GridItem className="GridViewToolbar__GridItem">
            <Label id="Status_Label">{getDisplayValue(TAG188)}</Label>
          </GridItem>
        </GridRow>
        <GridRow className="GridViewToolbar__GridRow-input">
          <GridItem className="GridViewToolbar__GridItem">
            <Checkbox
              isDisabled={loading}
              isChecked={isNewChecked}
              name="New"
              onCheckedChange={this.handleCheckedChange}
            >
              {getDisplayValue(TAG086)}
            </Checkbox>
          </GridItem>
          <GridItem className="GridViewToolbar__GridItem" padded>
            <Checkbox
              isDisabled={loading}
              isChecked={isAssignChecked}
              name="Assigned"
              onCheckedChange={this.handleCheckedChange}
            >
              {getDisplayValue(TAG087)}
            </Checkbox>
          </GridItem>
          <GridItem className="GridViewToolbar__GridItem">
            <Checkbox
              isDisabled={loading}
              isChecked={isQueueChecked}
              name="Queued"
              onCheckedChange={this.handleCheckedChange}
            >
              {getDisplayValue(TAG088)}
            </Checkbox>
          </GridItem>
        </GridRow>
      </Grid>
    );
  }
}

Status.propTypes = {
  loading: PropTypes.bool,
  statusFilterChanged: PropTypes.func.isRequired
};

export default Status;
