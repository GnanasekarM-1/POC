import React, { Component } from "react";
import {
  Grid,
  GridRow,
  GridItem,
  Label,
  Input,
  InputWrapper,
  PicklistFactory,
  Checkbox,
  ColorPicker,
  Radio,
  RadioGroup
} from "@svmx/ui-components-lightning";
import { DCON005_SET006, getSettingValue } from "constants/AppSettings";
import {
  REFRESH,
  DATE_UNCHANGE,
  END_TIME_CHANGE,
  END_TIME_CHANGE_WITH_DRIVE,
  SHOW_MARKER,
  HIGHLIGHT_TECH_COLOR,
  MARKER_COLOR
} from "constants/AppConstants";
import { convertUint2Hex, getDisplayValue } from "utils/DCUtils";
import { isEqual } from "lodash";
import { TAG212, TAG213 } from "constants/DisplayTagConstants";
import "./ConfTechView.scss";

class ConfTechCalendar extends Component {
  constructor(props) {
    super(props);

    const {
      autoCalculateEndDate,
      autoSyncServiceDuration,
      condition,
      dataTipOnClick,
      eventRowColor,
      noOfDays,
      refreshEventsOnChange,
      retainDateOnShowRoute,
      showTimeIndicator,
      timeIndicatorColor,
      toolTipShowDelay,
      toolTipHideDelay
    } = props;

    this.state = {
      beforeAfter: [condition],
      highlightTechColor: convertUint2Hex(eventRowColor),
      isDateUnChanged: retainDateOnShowRoute,
      isEndTimeChng: autoCalculateEndDate,
      isEndTimeChngWithDrive: autoSyncServiceDuration,
      isRefresh: refreshEventsOnChange,
      isShowMarker: showTimeIndicator,
      markerColor: convertUint2Hex(timeIndicatorColor),
      radioValue:
        dataTipOnClick === true || dataTipOnClick === "true"
          ? "onClick"
          : "onHover",
      startDateValue: noOfDays,
      toolTipHideDelayTime: toolTipHideDelay,
      toolTipShowDelayTime: toolTipShowDelay
    };
  }

  shouldComponentUpdate(nextProps, nextState) {
    return !isEqual(this.state, nextState);
  }

  handleRadioChange = ({ value }) => {
    this.setState({ radioValue: value });
    let val = false;
    if (value === "onClick") {
      val = true;
    } else {
      val = false;
    }
    this.callParent(val, "tech_dataTipOnClick");
  };

  handleInputChange = ({ value }) => {
    this.setState({ startDateValue: value });
    this.callParent(value === "" ? "0" : value, "tech_noOfDays");
  };

  hanldePicklistChange = ({ selectedValues }) => {
    this.setState({ beforeAfter: selectedValues });
    this.callParent(selectedValues[0], "tech_condition");
  };

  handleColorChange = (data, name) => {
    const { value } = data;
    if (name === HIGHLIGHT_TECH_COLOR) {
      this.setState({ highlightTechColor: value });
      this.callParent(value, "tech_eventRowColor");
    } else if (name === MARKER_COLOR) {
      this.setState({ markerColor: value });
      this.callParent(value, "tech_timeIndicatorColor");
    }
  };

  handleCheckedChange = data => {
    const { name, isChecked } = data;
    switch (name) {
      case REFRESH:
        this.setState({ isRefresh: isChecked });
        this.callParent(isChecked, "tech_refreshEventsOnChange");
        break;
      case DATE_UNCHANGE:
        this.setState({ isDateUnChanged: isChecked });
        this.callParent(isChecked, "tech_retainDateOnShowRoute");
        break;
      case END_TIME_CHANGE:
        this.setState({ isEndTimeChng: isChecked });
        this.callParent(isChecked, "tech_autoCalculateEndDate");
        break;
      case END_TIME_CHANGE_WITH_DRIVE:
        this.setState({ isEndTimeChngWithDrive: isChecked });
        this.callParent(isChecked, "tech_autoSyncServiceDuration");
        break;
      case SHOW_MARKER:
        this.setState({ isShowMarker: isChecked });
        this.callParent(isChecked, "tech_showTimeIndicator");
        break;
      default:
        break;
    }
  };

  handleBlur = (e, name) => {
    if (e.target.value.trim() === "") {
      this.setState({ [name]: 0 });
    }
  };

  handleHoverTimeValueChange = data => {
    let { name, value } = data;

    if (value < 0) {
      value = 0;
    }

    if (value >= 0 || value === "") {
      this.setState({ [name]: value });
    }

    switch (name) {
      case "Show Delay":
        this.setState({ toolTipShowDelayTime: value });
        this.callParent(value, "tech_toolTipShowDelay");
        break;
      case "Hide Delay":
        this.setState({ toolTipHideDelayTime: value });
        this.callParent(value, "tech_toolTipHideDelay");
        break;

      default:
        break;
    }
  };

  callParent = (value, prop) => {
    const { onValueChange } = this.props;
    onValueChange(value, prop);
  };

  render() {
    const {
      beforeAfter,
      isDateUnChanged,
      isEndTimeChng,
      isEndTimeChngWithDrive,
      isRefresh,
      isShowMarker,
      radioValue,
      startDateValue,
      toolTipShowDelayTime,
      toolTipHideDelayTime,
      highlightTechColor,
      markerColor
    } = this.state;
    const times = [
      { display: getDisplayValue(TAG212), value: "before" },
      { display: getDisplayValue(TAG213), value: "after" }
    ];
    return (
      <Grid isVertical>
        <GridRow className="ConfTechCalendar_gridRow">
          <GridItem noFlex>
            <div className="ConfTechCalendar_text">
              {getDisplayValue("TAG210")}
            </div>
          </GridItem>
          <GridItem noFlex>
            <InputWrapper
              className="ConfTechCalendar_startDate"
              size="xx-small"
            >
              <Input
                value={startDateValue}
                onValueChange={this.handleInputChange}
                type="number"
                min="0"
              />
            </InputWrapper>
          </GridItem>
          <GridItem className="ConfTechCalendar_gridItem" noFlex>
            <div className="ConfTechCalendar_text">
              {getDisplayValue("TAG211")}
            </div>
          </GridItem>
          <GridItem noFlex>
            <PicklistFactory
              className="ConfTechCalendar_startDate"
              items={times}
              itemValueKey="value"
              itemDisplayKey="display"
              selectedValues={beforeAfter}
              onSelectedChange={this.hanldePicklistChange}
              size="xx-small"
            />
          </GridItem>
          <GridItem className="ConfTechCalendar_gridItem" noFlex>
            <p className="ConfTechCalendar_text">{getDisplayValue("TAG214")}</p>
          </GridItem>
        </GridRow>
        <GridRow className="ConfTechCalendar_gridRow">
          <GridItem>
            <Checkbox
              name="Refresh"
              isChecked={
                typeof isRefresh === "boolean"
                  ? isRefresh
                  : isRefresh !== "false"
              }
              onCheckedChange={this.handleCheckedChange}
            >
              {getDisplayValue("TAG215")}
            </Checkbox>
          </GridItem>
        </GridRow>
        <GridRow className="ConfTechCalendar_gridRow">
          <GridItem>
            <Checkbox
              name="DateUnChange"
              isDisabled
              isChecked={
                typeof isDateUnChanged === "boolean"
                  ? isDateUnChanged
                  : isDateUnChanged !== "false"
              }
              onCheckedChange={this.handleCheckedChange}
            >
              {getDisplayValue("TAG216")}
            </Checkbox>
          </GridItem>
        </GridRow>
        <GridRow className="ConfTechCalendar_gridRow">
          <GridItem>
            <Checkbox
              name="EndTimeChange"
              isChecked={
                typeof isEndTimeChng === "boolean"
                  ? isEndTimeChng
                  : isEndTimeChng !== "false"
              }
              onCheckedChange={this.handleCheckedChange}
            >
              {getSettingValue(DCON005_SET006) === "Enabled"
                ? getDisplayValue("EVENTSTAG145")
                : getDisplayValue("TAG236")}
            </Checkbox>
          </GridItem>
        </GridRow>
        <GridRow className="ConfTechCalendar_gridRow">
          <GridItem>
            <Checkbox
              name="EndTimeChangeWithDrive"
              isChecked={
                typeof isEndTimeChngWithDrive === "boolean"
                  ? isEndTimeChngWithDrive
                  : isEndTimeChngWithDrive !== "false"
              }
              onCheckedChange={this.handleCheckedChange}
            >
              {getSettingValue(DCON005_SET006) === "Enabled"
                ? getDisplayValue("EVENTSTAG146")
                : getDisplayValue("TAG375")}
            </Checkbox>
          </GridItem>
        </GridRow>
        <GridRow className="ConfTechCalendar_gridRow">
          <GridItem noFlex>
            <ColorPicker
              className="ConfTechCalendar_color-picker"
              name="HighlightTechColor"
              value={highlightTechColor}
              onValueChange={data =>
                this.handleColorChange(data, HIGHLIGHT_TECH_COLOR)
              }
            />
          </GridItem>
          <GridItem className="ConfTechCalendar_gridItem" noFlex>
            {getDisplayValue("TAG274")}
          </GridItem>
        </GridRow>
        <GridRow className="ConfTechCalendar_gridRow">
          <GridItem noFlex>
            <Checkbox
              name="ShowMarker"
              isChecked={
                typeof isShowMarker === "boolean"
                  ? isShowMarker
                  : isShowMarker !== "false"
              }
              onCheckedChange={this.handleCheckedChange}
            >
              {getDisplayValue("TAG345")}
            </Checkbox>
          </GridItem>
          <GridItem noFlex>
            <ColorPicker
              className="ConfTechCalendar_color-picker"
              name="MarkerColor"
              value={markerColor}
              onValueChange={data => this.handleColorChange(data, MARKER_COLOR)}
            />
          </GridItem>
        </GridRow>
        <GridRow className="ConfTechCalendar_gridRow">
          <GridItem>
            <RadioGroup
              value={radioValue}
              name="clickOrHover"
              onValueChange={this.handleRadioChange}
            >
              <Radio value="onHover">
                {getDisplayValue("TAG276")}
                <InputWrapper
                  className="ConfTechCalendar__input"
                  isDisabled={radioValue !== "onHover"}
                  name="Show Delay"
                  onBlur={event =>
                    this.handleBlur(event, "toolTipShowDelayTime")
                  }
                  size="xx-small"
                  inputValue={toolTipShowDelayTime}
                  inputOnValueChange={this.handleHoverTimeValueChange}
                >
                  <Input type="number" min="0" />
                </InputWrapper>
                {getDisplayValue("TAG277")} {getDisplayValue("TAG288")}
                <InputWrapper
                  className="ConfTechCalendar__input"
                  isDisabled={radioValue !== "onHover"}
                  name="Hide Delay"
                  onBlur={event =>
                    this.handleBlur(event, "toolTipHideDelayTime")
                  }
                  size="xx-small"
                  inputValue={toolTipHideDelayTime}
                  inputOnValueChange={this.handleHoverTimeValueChange}
                >
                  <Input type="number" min="0" />
                </InputWrapper>
                {getDisplayValue("TAG277")}
              </Radio>
              <Radio value="onClick">{getDisplayValue("TAG275")}</Radio>
            </RadioGroup>
          </GridItem>
        </GridRow>
      </Grid>
    );
  }
}

export default ConfTechCalendar;
