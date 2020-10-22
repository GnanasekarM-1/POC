import React, { Component } from "react";
import PropTypes from "prop-types";
import {
  Label,
  Input,
  Search,
  PicklistFactory,
  Grid,
  GridRow,
  GridItem
} from "@svmx/ui-components-lightning";
import { debounce, isEqual } from "lodash";
import moment from "moment-timezone";
import { isView } from "utils/ViewUtils";
import { getGridColumns, normalizeColumnName } from "utils/GridUtils";
import {
  WARNING_TYPE,
  DEFAULT_SORT_BY,
  TIME_FIELD_TYPE,
  DATE_FIELD_TYPE,
  DATETIME_FIELD_TYPE
} from "constants/AppConstants";
import {
  TAG293,
  TAG457,
  EVENTSTAG128,
  EVENTSTAG134
} from "constants/DisplayTagConstants";
import { getDisplayValue } from "utils/DCUtils";
import { getUserTimeSettings } from "utils/DateAndTimeUtils";
import {
  YODA_DATE_FORMAT,
  TIME_FORMAT_24H,
  YODA_DATE_TIME_24_HR_FORMAT
} from "constants/DateTimeConstants";
import { INPUT_TEXT_ERROR } from "constants/ActionConstants";

import "./GridViewToolbar.scss";

class Filter extends Component {
  constructor(props) {
    super(props);
    let defaultSelection = DEFAULT_SORT_BY;
    const { userSettings, woFieldObj, view } = this.props;
    const { wo_filterColumn: filterColumn, wo_woCol: woCol } = userSettings;

    const sourceItems = getGridColumns(
      view,
      isView(view) ? undefined : woCol,
      woFieldObj
    );
    const colName = normalizeColumnName(filterColumn);
    const found = sourceItems.filter(
      sourceItem => sourceItem.accessor === colName
    );
    if (found.length) {
      const [sourceItem] = found;
      const { accessor } = sourceItem;
      defaultSelection = accessor;
    }
    this.state = {
      sourceItems,
      targetArray: [defaultSelection],
      text: ""
    };
  }

  componentWillReceiveProps(newProps) {
    const { clearFilter, filterDetail, userSettings, view } = this.props;
    const { Key: viewId } = view;
    const { wo_filterColumn: filterColumn, wo_woCol: woCol } = userSettings;
    if (
      newProps.view &&
      (viewId !== newProps.view.Key ||
        !isEqual(filterColumn, newProps.userSettings.wo_filterColumn) ||
        !isEqual(woCol, newProps.userSettings.wo_woCol))
    ) {
      this.resetSelection(
        newProps.view,
        newProps.userSettings,
        isEqual(woCol, newProps.userSettings.wo_woCol) &&
          viewId === newProps.view.Key
      );
    }
    const { value } = filterDetail || {};
    const { value: newValue, projectView, id } = newProps.filterDetail || {};

    if (newValue && !isEqual(value, newValue)) {
      const { sourceItems } = this.state;
      const { accessor } = sourceItems[0];
      this.setState({
        id,
        targetArray: [accessor],
        text: newValue,
        filterEvents: projectView,
        projectView
      });
      this.applyFilter();
      clearFilter();
    }
  }

  applyFilter = () => {
    const { filterColumnChanged } = this.props;
    const { sourceItems, targetArray } = this.state;
    const [nameColumn] = sourceItems;
    const { accessor } = nameColumn;
    if (!isEqual(targetArray, [accessor])) {
      filterColumnChanged(accessor);
    }
  };

  handleTargetChange = ({ selectedValues }) => {
    this.setState({ targetArray: selectedValues });
    const { filterColumnChanged } = this.props;
    const [filter] = selectedValues;
    setTimeout(() => filterColumnChanged(filter), 0);
  };

  handleInputChange = ({ value }) => {
    this.setState({
      text: value
    });

    if (!this.debouncedFn) {
      this.debouncedFn = debounce(this.triggerFilterTextChanged, 800);
    }
    this.debouncedFn();
  };

  triggerFilterTextChanged = () => {
    const {
      filterTextChanged,
      updateAppStatus,
      userTimezone,
      view,
      woFieldObj
    } = this.props;
    const { type } = view;
    if (type === "WO") {
      // In case of single WO launch, Filter Text change no effect.
      return;
    }
    const { targetArray, text, filterEvents, projectView, id } = this.state;
    const [filterColumn] = targetArray;
    const fieldDesc = woFieldObj[filterColumn];
    let searchText = text;
    if (searchText && fieldDesc) {
      const { defaultTZ } = userTimezone || {};
      const { fieldType } = fieldDesc;
      switch (fieldType) {
        case TIME_FIELD_TYPE:
          searchText = moment(searchText, getUserTimeSettings("timeFormat"));
          if (!searchText.isValid()) {
            updateAppStatus(INPUT_TEXT_ERROR, EVENTSTAG128, WARNING_TYPE);
            return;
          }
          searchText = moment.tz(
            searchText.format(moment.HTML5_FMT.TIME),
            defaultTZ
          );
          searchText = `${searchText
            .clone()
            .tz("GMT")
            .format(TIME_FORMAT_24H)}`;
          break;
        case DATE_FIELD_TYPE:
          searchText = moment(searchText, getUserTimeSettings("dateFormat"));
          if (!searchText.isValid()) {
            updateAppStatus(INPUT_TEXT_ERROR, EVENTSTAG134, WARNING_TYPE);
            return;
          }
          searchText = moment.tz(
            searchText.format(moment.HTML5_FMT.DATE),
            defaultTZ
          );
          searchText = `${searchText
            .clone()
            .tz("GMT")
            .format(YODA_DATE_FORMAT)}`;
          break;
        case DATETIME_FIELD_TYPE:
          searchText = moment(
            searchText,
            getUserTimeSettings("dateTimeFormat")
          );

          if (!searchText.isValid()) {
            updateAppStatus(INPUT_TEXT_ERROR, EVENTSTAG134, WARNING_TYPE);
            return;
          }
          searchText = moment.tz(
            searchText.format(moment.HTML5_FMT.DATETIME_LOCAL_SECONDS),
            defaultTZ
          );
          searchText = `${searchText
            .clone()
            .tz("GMT")
            .format(YODA_DATE_TIME_24_HR_FORMAT)}Z`;
          break;
      }
    }
    if (filterTextChanged) {
      filterTextChanged(
        targetArray[0],
        searchText,
        filterEvents,
        projectView,
        id
      );
    }
    if (filterEvents) {
      this.setState({ filterEvents: false, projectView: false, id: null });
    }
  };

  resetSelection = (view, userSettings, clearText) => {
    const { text } = this.state;
    let defaultSelection = DEFAULT_SORT_BY;
    const { userSettings: uSettings, woFieldObj } = this.props;
    const { wo_filterColumn: filterColumn, wo_woCol: woCol } =
      userSettings || uSettings;

    const sourceItems = getGridColumns(
      view,
      isView(view) ? undefined : woCol,
      woFieldObj
    );
    const colName = normalizeColumnName(filterColumn);
    const found = sourceItems.filter(
      sourceItem => sourceItem.accessor === colName
    );
    if (found.length) {
      const [sourceItem] = found;
      const { accessor } = sourceItem;
      defaultSelection = accessor;
    }
    this.setState({
      sourceItems,
      targetArray: [defaultSelection],
      text: clearText ? "" : text
    });
  };

  render() {
    const { loading } = this.props;
    const { sourceItems, targetArray, text } = this.state;
    return (
      <Grid isVertical className="Filter__Wrapper">
        <GridRow className="GridViewToolbar__GridRow-label">
          <GridItem className="GridViewToolbar__GridItem">
            <Label>{getDisplayValue(TAG457)}</Label>
          </GridItem>
        </GridRow>
        <GridRow className="GridViewToolbar__GridRow-input">
          <GridItem className="GridViewToolbar__GridItem Filter_picklist-container">
            <PicklistFactory
              defaultText="Select a Filter"
              isDisabled={loading}
              items={sourceItems}
              name="picklist-single"
              onSelectedChange={this.handleTargetChange}
              selectedValues={targetArray}
              itemValueKey="accessor"
              itemDisplayKey="Header"
              size="small"
            />
          </GridItem>
          <GridItem className="GridViewToolbar__GridItem" padded>
            <Label>{getDisplayValue(TAG293)}</Label>
          </GridItem>
          <GridItem
            noFlex
            className="GridViewToolbar__GridItem GridViewToolbar__GridItem-search"
          >
            <Search
              name="gridFilter"
              // isDisabled={loading}
              onValueChange={this.handleInputChange}
              // placeholder={getDisplayValue(TAG353)}
              value={text}
            />
          </GridItem>
          <GridItem padded />
        </GridRow>
      </Grid>
    );
  }
}

const propTypes = {
  filterColumnChanged: PropTypes.func.isRequired,
  filterTextChanged: PropTypes.func.isRequired,
  loading: PropTypes.bool,
  userSettings: PropTypes.shape({}).isRequired,
  view: PropTypes.shape({}).isRequired,
  woFieldObj: PropTypes.shape({}).isRequired,
  filterDetail: PropTypes.shape({})
};

const defaultProps = {
  loading: false
};

Filter.propTypes = propTypes;
Filter.defaultProps = defaultProps;

export default Filter;
