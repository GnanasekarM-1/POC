import React from "react";
import PropTypes from "prop-types";
import {
  Button,
  DateInput,
  Dropdown,
  Icon,
  Label,
  Menu,
  MenuItem,
  Radio,
  RadioGroup,
  Picklist,
  InputWrapper,
  Input
} from "@svmx/ui-components-lightning";
import {
  MAP_CUSTOM_EVENT_SHOW_FULL_SCREEN,
  MAP_CUSTOM_EVENT_SHOW_LOCATION_BAR,
  SEARCH_RADIUS_MENU_ITEM,
  MAP_TECH_HOME,
  MAP_TECH_CURRENT,
  MAP_TECH_BOTH,
  MAP_TECH_DAILY_ROUTE
} from "constants/MapConstants";
import {
  TAG470,
  TAG471,
  TAG472,
  TAG495,
  TAG496,
  TAG370,
  TAG159,
  TAG504,
  TAG475,
  TAG333
} from "constants/DisplayTagConstants";
import { getDisplayValue } from "utils/DCUtils";
import * as moment from "moment";
import "./MapPlotView.scss";

import { getUserTimeSettings } from "utils/DateAndTimeUtils";

const defaultProps = {
  shouldShowPortalWindowButton: false
};

const propTypes = {
  mapUnit: PropTypes.string.isRequired,
  onMapContainerReset: PropTypes.func.isRequired,
  onPlotView: PropTypes.func.isRequired,
  handleSearchRadius: PropTypes.func.isRequired,
  handleSearchRadiusItem: PropTypes.func.isRequired,
  onShowSearchRadiusButton: PropTypes.bool.isRequired,
  onRadioValueChange: PropTypes.func.isRequired,
  onSearchRadiusEnterValue: PropTypes.func.isRequired,
  onShowLocationBaseBar: PropTypes.bool.isRequired,
  onShowLocationBaseBarWithDate: PropTypes.bool.isRequired,
  radioValue: PropTypes.string.isRequired,
  shouldShowPortalWindowButton: PropTypes.bool.isRequired
};

const handleFullScreen = () => {
  const event = new CustomEvent(MAP_CUSTOM_EVENT_SHOW_FULL_SCREEN, {
    detail: true
  });
  window.dispatchEvent(event);
};

const Toolbar = ({
  mapUnit,
  onMapContainerReset,
  onPlotView,
  handleSearchRadius,
  handleSearchRadiusItem,
  onRadioValueChange,
  onSearchRadiusEnterValue,
  onShowLocationBaseBar,
  onShowLocationBaseBarWithDate,
  onPreviousDate,
  onNextDate,
  radioValue,
  shouldShowPortalWindowButton,
  onLocationBarMinDate,
  onLocationBarMaxDate,
  onLocationBaseBarSelectedDate,
  technicianName,
  onShowSearchRadiusButton,
  onRouteDateValueChange
}) => {
  const maxDate = moment().add(1, "years");
  const minDate = moment().subtract(1, "years");
  return (
    <div id="toolbarDivId" className="PlotView_toolbar">
      <div className="PlotView_toolbar_InnerHeader">
        <Button
          className="PlotView__toolBar_buttons"
          type="neutral-gray"
          size="small"
          onClick={onPlotView}
          title={getDisplayValue(TAG370)}
        >
          <Icon icon="pin" align="left" size="x-small" />
          {getDisplayValue(TAG495, "Plot")}
        </Button>
        <Button
          className="PlotView__toolBar_buttons"
          type="neutral-gray"
          size="small"
          onClick={handleSearchRadius}
          title={getDisplayValue(TAG496)}
        >
          <Icon category="utility" icon="choice" align="left" size="x-small" />
          {getDisplayValue(TAG496, "Search Radius")}
        </Button>
        {onShowLocationBaseBar && (
          <RadioGroup
            className="RadioButton_toolbar"
            value={radioValue}
            onValueChange={onRadioValueChange}
          >
            <Radio className="RadioButton_toolbar" value={MAP_TECH_CURRENT}>
              {getDisplayValue(TAG471, MAP_TECH_CURRENT)}
            </Radio>
            <Radio className="RadioButton_toolbar" value={MAP_TECH_HOME}>
              {getDisplayValue(TAG470, MAP_TECH_HOME)}
            </Radio>
            <Radio className="RadioButton_toolbar" value={MAP_TECH_BOTH}>
              {getDisplayValue(TAG472, MAP_TECH_BOTH)}
            </Radio>
          </RadioGroup>
        )}
        {onShowLocationBaseBarWithDate && (
          <Label
            className="PlotView__toolBar_labels"
            title={technicianName}
          >{`${getDisplayValue(
            "TAG116",
            MAP_TECH_DAILY_ROUTE
          )}${" "}${technicianName}`}</Label>
        )}
        {onShowLocationBaseBarWithDate && (
          <Icon className="PlotView__toolBar_icons" icon="threedots_vertical" />
        )}
        {onShowLocationBaseBarWithDate && (
          <Button type="icon-bare" size="small" onClick={onPreviousDate}>
            <Icon
              className="PlotView__toolBar_icons"
              icon="chevronleft"
              size="x-small"
            />
          </Button>
        )}
        {onShowLocationBaseBarWithDate && (
          <DateInput
            className="PlotView_dateInputModified"
            name="dateEnd"
            maxDate={onLocationBarMaxDate}
            minDate={onLocationBarMinDate}
            value={onLocationBaseBarSelectedDate}
            dateFormat={getUserTimeSettings("dateFormat")}
            onValueChange={onRouteDateValueChange}
          />
        )}
        {onShowLocationBaseBarWithDate && (
          <Button type="icon-bare" size="small" onClick={onNextDate}>
            <Icon
              className="PlotView__toolBar_icons"
              icon="chevronright"
              size="x-small"
            />
          </Button>
        )}
        {onShowLocationBaseBarWithDate && (
          <Icon className="PlotView__toolBar_icons" icon="threedots_vertical" />
        )}
        <Button
          className="PlotView__toolBar_buttons"
          type="neutral-gray"
          size="small"
          onClick={onMapContainerReset}
          title={getDisplayValue(TAG333)}
        >
          <Icon icon="refresh" align="left" size="x-small" />
          {getDisplayValue(TAG159)}
        </Button>
        {shouldShowPortalWindowButton && (
          <Button
            className="PlotView__toolBar_buttons"
            type="neutral-gray"
            size="small"
            onClick={handleFullScreen}
            title={getDisplayValue(TAG475)}
          >
            <Icon icon="new_window" align="left" size="x-small" />
          </Button>
        )}
        {onShowSearchRadiusButton && (
          <Menu
            className="PlotView__toolBar_SearchRadius_Menu"
            onItemClick={handleSearchRadiusItem}
          >
            {SEARCH_RADIUS_MENU_ITEM.map(dist => (
              <MenuItem key={dist} value={dist}>
                {dist}
                {` ${mapUnit}`}
              </MenuItem>
            ))}
            <MenuItem key="enterValue" value="Enter Value">
              <Button
                type="neutral-gray"
                size="small"
                onClick={onSearchRadiusEnterValue}
              >
                {getDisplayValue(TAG504)}
              </Button>
            </MenuItem>
            <MenuItem key="No Limit" value="No Limit">
              {getDisplayValue("TAG505")}
            </MenuItem>
          </Menu>
        )}
      </div>
    </div>
  );
};

Toolbar.defaultPropTypes = defaultProps;
Toolbar.propTypes = propTypes;

export default Toolbar;
