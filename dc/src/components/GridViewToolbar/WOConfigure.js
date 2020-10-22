/* eslint-disable no-unused-vars */
import React from "react";
import {
  Button,
  Icon,
  GridRow,
  GridItem,
  Label,
  Grid
} from "@svmx/ui-components-lightning";
import PropTypes from "prop-types";
import ReloadData from "components/WOReload";
import { getDisplayValue } from "utils/DCUtils";
import { FALSE } from "constants/AppConstants";
import { DCON001_SET012, getSettingValue } from "constants/AppSettings";
import { TAG003, TAG004, TAG313 } from "constants/DisplayTagConstants";
import "./GridViewToolbar.scss";

const WOConfigure = props => {
  const {
    autorefresh,
    handleClick,
    loading,
    isUserSettingDirty,
    refreshtime,
    saveUserSettings,
    view,
    viewSelectionChanged
  } = props;

  const reloadView = () => {
    viewSelectionChanged(view, true);
  };

  const allowColorCoding = JSON.parse(
    getSettingValue(DCON001_SET012, FALSE).toLowerCase()
  );

  return (
    <Grid isVertical>
      <GridRow>
        <GridItem>
          <Label id="Status_Label">{getDisplayValue(TAG313)}</Label>
        </GridItem>
      </GridRow>
      <GridRow className="GridViewToolbar__WOConfigure">
        <GridItem
          className={autorefresh ? "GridViewToolbar__WOConfigure-timer" : ""}
        >
          {autorefresh && (
            <ReloadData
              autorefresh={autorefresh}
              loading={loading}
              refreshtime={refreshtime}
              view={view}
              viewSelectionChanged={viewSelectionChanged}
            />
          )}
        </GridItem>
        <GridItem className="GridViewToolbar__WOConfigure-action">
          <Button
            isDisabled={loading}
            type="icon-border"
            size="medium"
            title={getDisplayValue(TAG004)}
            onClick={() => reloadView()}
          >
            <Icon icon="change_record_type" />
          </Button>
        </GridItem>
        {allowColorCoding ? (
          <GridItem className="GridViewToolbar__WOConfigure-action">
            <Button
              isDisabled={loading}
              type="icon-border"
              size="medium"
              title={getDisplayValue(TAG003)}
              onClick={() => handleClick("activity")}
            >
              <Icon icon="choice" />
            </Button>
          </GridItem>
        ) : (
          <GridItem noFlex />
        )}
        <GridItem className="GridViewToolbar__WOConfigure-action">
          <Button
            isDisabled={loading}
            type="icon-border"
            size="medium"
            title={getDisplayValue("TAG077")}
            onClick={() => handleClick("setting")}
          >
            <Icon icon="settings" />
          </Button>
        </GridItem>
      </GridRow>
    </Grid>
  );
};

WOConfigure.propTypes = {
  autorefresh: PropTypes.bool.isRequired,
  handleClick: PropTypes.func.isRequired,
  loading: PropTypes.bool,
  isUserSettingDirty: PropTypes.bool.isRequired,
  refreshtime: PropTypes.number.isRequired,
  saveUserSettings: PropTypes.func.isRequired,
  view: PropTypes.shape({}).isRequired,
  viewSelectionChanged: PropTypes.func.isRequired
};

export default WOConfigure;
