import React, { Component } from "react";
import PropTypes from "prop-types";
import {
  GridRow,
  GridItem,
  Label,
  Button,
  Icon,
  ButtonGroup
} from "@svmx/ui-components-lightning";
import AdvTechSearchModal from "components/Modals/AdvTechSearchModal";
import { TAG379, TAG381, TAG412 } from "constants/DisplayTagConstants";
import { FALSE } from "constants/AppConstants";
import { DCON001_SET067, getSettingValue } from "constants/AppSettings";
import { ADV_TECH_SEARCH_NO_WORKORDER_SELECTION } from "constants/ActionConstants";
import { getDisplayValue } from "utils/DCUtils";

import "./SchedulerToolbar.scss";

class AdvancedSearch extends Component {
  constructor(props) {
    super(props);
    this.state = {
      open: false
    };
  }

  isOpen = open => {
    this.setState({ open });
  };

  openATSDialog = () => {
    const { selectedWO, updateAppStatus } = this.props;
    if (!selectedWO && updateAppStatus) {
      updateAppStatus(ADV_TECH_SEARCH_NO_WORKORDER_SELECTION);
      return;
    }
    this.setState({ open: true });
  };

  render() {
    const { open } = this.state;
    const { applyATS, loading, selectedWO } = this.props;
    const enableATS = JSON.parse(
      getSettingValue(DCON001_SET067, FALSE).toLowerCase()
    );
    return enableATS ? (
      <GridItem noFlex className="SchedulerToolbar__Group">
        <GridRow>
          <GridItem noFlex className="SchedulerToolbar__SubGroup">
            <Label>{getDisplayValue(TAG412)}</Label>
          </GridItem>
        </GridRow>
        <GridRow>
          <GridItem className="SchedulerToolbar__SubGroup">
            <ButtonGroup>
              <Button
                type="icon-border-filled"
                size="medium"
                title={getDisplayValue(TAG381)}
                onClick={() => applyATS()}
                isDisabled={loading}
              >
                <Icon
                  category="svmx"
                  icon="advanced_technician_search"
                  size="x-small"
                />
              </Button>
              <Button
                type="icon-border-filled"
                onClick={() => this.openATSDialog()}
                title={getDisplayValue(TAG379)}
                size="medium"
                isDisabled={loading}
              >
                <Icon icon="rating" size="x-small" />
              </Button>
            </ButtonGroup>
          </GridItem>
        </GridRow>
        {open && (
          <AdvTechSearchModal
            open={open}
            isOpen={this.isOpen}
            selectedWO={selectedWO}
          />
        )}
      </GridItem>
    ) : (
      <GridItem noFlex />
    );
  }
}

AdvancedSearch.propTypes = {
  loading: PropTypes.bool,
  applyATS: PropTypes.func.isRequired,
  selectedWO: PropTypes.shape({}).isRequired,
  updateAppStatus: PropTypes.func.isRequired
};

export default AdvancedSearch;
