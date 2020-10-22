import React, { Component } from "react";
import { connect } from "react-redux";
import PropTypes from "prop-types";
import * as moment from "moment";
import {
  Label,
  Button,
  Icon,
  Input,
  GridItem,
  GridRow,
  ButtonGroup
} from "@svmx/ui-components-lightning";
import { TAG018, TAG019, TAG145, TAG458 } from "constants/DisplayTagConstants";
import {
  getDisplayValue,
  getUserSetting,
  stringToBoolean
} from "utils/DCUtils";
import {
  NAME,
  REFERENCE,
  CONFIGURE_TECH_TEAM_SEARCH,
  SEARCH_NONE,
  SEARCH_TEAM,
  TECH_KEYWORD,
  TEAM_KEYWORD,
  SEARCH_KEYWORD,
  MAP_CONFIG,
  TIME_FIELD_TYPE,
  DATE_FIELD_TYPE,
  DATETIME_FIELD_TYPE,
  BOOLEAN_FIELD_TYPE
} from "constants/AppConstants";
import {
  GET_SEARCH_TECH,
  SEARCH_TEXT_EMPTY,
  UPDATE_GRID_STATE,
  SEARCH_TECH_DATA_CLEAR,
  SEARCH_KEY_MATCH_EMPTY
} from "constants/ActionConstants";
import { isNull } from "lodash";
import {
  TEAM_SEARCH_KEYWORD,
  TECH_SEARCH_KEYWORD
} from "constants/UserSettingConstants";
import { getUserTimeSettings } from "utils/DateAndTimeUtils";
import {
  getSettingValue,
  DCON001_SET003,
  SET014,
  SET015,
  SET016
} from "constants/AppSettings";
import { getReferenceValue } from "utils/GridUtils";
import { createPayloadParam } from "utils/ViewUtils";
import { setSelectedSearch, setSelectedWorkOrder } from "utils/MapUtils";
import { resetMapContainer } from "services/MapService";
import { gridStateChanged } from "actions/GridViewAction";
import "./SchedulerToolbar.scss";

const propTypes = {
  gridActive: PropTypes.bool.isRequired,
  handleSettingClick: PropTypes.func.isRequired,
  onActionSearchTech: PropTypes.func.isRequired,
  onClearSearchTech: PropTypes.func.isRequired,
  onSearchChange: PropTypes.func.isRequired,
  onSearchCriteriaStatusUpdate: PropTypes.func.isRequired,
  onSearchTxtStatusUpdate: PropTypes.func.isRequired,
  selectedWO: PropTypes.shape({}).isRequired,
  userTimezone: PropTypes.shape({}).isRequired
};

function isObject(value) {
  return value && typeof value === "object" && value.constructor === Object;
}

function getFieldName(field) {
  if (isObject(field)) {
    const keys = Object.keys(field);
    const index = keys.indexOf("attributes");
    if (index !== -1) {
      keys.splice(index, 1);
    }
    return keys.sort()[0];
  }
  return field;
}

class SchedulerTechnicianSearch extends Component {
  constructor(props) {
    super(props);
    this.searchKeyword = "";
    this.searchInProgress = false;
    this.showTeamBtn = JSON.parse(getSettingValue(SET014).toLowerCase(), true);
    this.showTechnicianBtn = JSON.parse(
      getSettingValue(SET015).toLowerCase(),
      true
    );
    this.showConfigTechBtn = JSON.parse(
      getSettingValue(SET016).toLowerCase(),
      true
    );
  }

  componentDidMount() {
    const { onSchedulerTechSearchChildRef } = this.props;
    onSchedulerTechSearchChildRef(this);
  }

  componentWillReceiveProps(nextProps) {
    const { selectedWO, gridActive } = nextProps;
    if (selectedWO) {
      if (gridActive && !this.searchInProgress) {
        this.selectedWorkOrder = selectedWO;
        this.handleWorkOrderSearchInfo(selectedWO);
      }
    }
  }

  componentWillUnmount() {
    const { onSchedulerTechSearchChildRef } = this.props;
    onSchedulerTechSearchChildRef(undefined);
  }

  handleWorkOrderSearchInfo = rowInfo => {
    const { userTimezone, woFields } = this.props;
    const { defaultTZ } = userTimezone || {};
    const searchKeyword = getUserSetting(SEARCH_KEYWORD);
    const { col = [] } = searchKeyword || {};
    setSelectedWorkOrder(rowInfo);
    let keywordText = "";
    col.map(item => {
      const { name } = item;
      let keyword = isNull(rowInfo[name]) ? "" : rowInfo[name];
      const fieldDesc = woFields[name];
      if (fieldDesc) {
        const { fieldType, refField = NAME } = fieldDesc;
        switch (fieldType) {
          case BOOLEAN_FIELD_TYPE:
            keyword = keyword !== "" ? keyword.toString() : "";
            break;
          case REFERENCE:
            keyword = getReferenceValue(rowInfo, name, refField);
            break;
          case TIME_FIELD_TYPE:
            keyword =
              keyword &&
              moment(keyword, moment.HTML5_FMT.TIME_MS)
                .tz(defaultTZ)
                .format(getUserTimeSettings("timeFormat"));
            break;
          case DATE_FIELD_TYPE:
            keyword =
              keyword &&
              moment(keyword, moment.ISO_8601)
                .tz(defaultTZ)
                .format(getUserTimeSettings("dateFormat"));
            break;
          case DATETIME_FIELD_TYPE:
            keyword =
              keyword &&
              moment(keyword, moment.ISO_8601)
                .tz(defaultTZ)
                .format(getUserTimeSettings("dateTimeFormat"));
            break;
          default:
            break;
        }
        if (keyword) {
          if (keywordText === "") {
            keywordText = keyword;
          } else {
            keywordText = `${keywordText},${keyword}`;
          }
        }
      }
      return undefined;
    });
    this.handleWorkOrderSearchKeyword(keywordText);
  };

  handleWorkOrderSearchKeyword = keyword => {
    const { onSearchTxtStatusUpdate, snoozeRowSelectionTrigger } = this.props;
    this.searchKeyword = keyword;
    // this.setState({
    // searchKeyword: keyword,
    // });
    let performSearchFor = getSettingValue(DCON001_SET003, SEARCH_NONE);
    if (performSearchFor !== SEARCH_NONE) {
      performSearchFor =
        performSearchFor === SEARCH_TEAM ? TEAM_KEYWORD : TECH_KEYWORD;
      if (keyword.trim() === "") {
        onSearchTxtStatusUpdate();
        snoozeRowSelectionTrigger();
      } else {
        setSelectedSearch(performSearchFor);
        this.doKeywordSearch(performSearchFor);
      }
    }
  };

  doKeywordSearch = findWhat => {
    const {
      onActionSearchTech,
      onClearSearchTech,
      onSearchChange,
      onSearchCriteriaStatusUpdate,
      onSearchTxtStatusUpdate,
      onHandleMapSetting
    } = this.props;
    // const { searchKeyword } = this.state;
    const mapSettings = stringToBoolean(getUserSetting(MAP_CONFIG), false);
    if (this.searchKeyword.trim() === "") {
      onSearchTxtStatusUpdate();
    } else {
      setSelectedSearch(findWhat);
      let keyWordMatch = [];
      let keyWordMatchStr = "";
      let matchCriterium = "";
      if (findWhat === TECH_KEYWORD) {
        const techSearchCriteria = getUserSetting(TECH_SEARCH_KEYWORD);
        const { col, matchcriteria } = techSearchCriteria;
        keyWordMatch = col;
        matchCriterium = matchcriteria;
      } else {
        const teamSearchCriteria = getUserSetting(TEAM_SEARCH_KEYWORD);
        const { col, matchcriteria } = teamSearchCriteria;
        keyWordMatch = col;
        matchCriterium = matchcriteria;
      }
      keyWordMatch.map(item => {
        keyWordMatchStr += `${item.name},`;
        return undefined;
      });
      if (keyWordMatch.length > 0) {
        if (!mapSettings) {
          onHandleMapSetting();
        }
        keyWordMatchStr = keyWordMatchStr.substring(
          0,
          keyWordMatchStr.length - 1
        );
        this.searchInProgress = true;
        const payloadPlotMapData = [];
        createPayloadParam(
          "keyword",
          encodeURIComponent(this.searchKeyword),
          payloadPlotMapData
        );
        createPayloadParam("findWhat", findWhat, payloadPlotMapData);
        createPayloadParam("keywordMatch", keyWordMatchStr, payloadPlotMapData);
        createPayloadParam("searchType", matchCriterium, payloadPlotMapData);
        onSearchChange();
        onClearSearchTech();
        onActionSearchTech(
          payloadPlotMapData,
          findWhat,
          this.handleSearchResult
        );
      } else {
        onSearchCriteriaStatusUpdate();
      }
    }
  };

  handleSearchResult = () => {
    const { onSchedulerReset } = this.props;
    // if (onSchedulerReset) {
    // onSchedulerReset();
    // }
    this.searchInProgress = false;
  };

  handleSearchTxtChange = ({ target }) => {
    const { value } = target;
    this.searchKeyword = value;
    this.searchInProgress = false;
    this.forceUpdate();
    // this.setState({
    // searchKeyword: value,
    // });
  };

  handleSearchTxtReset = () => {
    this.searchKeyword = "";
    this.searchInProgress = false;
    resetMapContainer();
    // this.setState({
    //  searchKeyword: '',
    // });
  };

  render() {
    const { handleSettingClick, loading } = this.props;
    // const { searchKeyword } = this.state;
    return (
      <GridItem className="SchedulerToolbar__Group SchedulerToolbar__Group-techSearch">
        <GridRow>
          <GridItem className="SchedulerToolbar__SubGroup">
            <Label>{getDisplayValue(TAG458)}</Label>
          </GridItem>
        </GridRow>
        <GridRow className="SchedulerToolbar__SubGroup">
          <GridItem className="SchedulerToolbar__Item">
            <Input
              name="my-search"
              placeholder="Search Expressions"
              onChange={e => {
                this.handleSearchTxtChange(e);
              }}
              value={this.searchKeyword}
              size="xx-small"
            />
          </GridItem>
          <GridItem noFlex className="SchedulerToolbar__Item">
            <ButtonGroup>
              {this.showTechnicianBtn && (
                <Button
                  type="icon-border-filled"
                  size="medium"
                  title={getDisplayValue(TAG019)}
                  onClick={() => {
                    this.doKeywordSearch(TECH_KEYWORD);
                  }}
                  isDisabled={loading}
                >
                  <Icon category="svmx" icon="find_technician" size="x-small" />
                </Button>
              )}
              {this.showTeamBtn && (
                <Button
                  type="icon-border-filled"
                  size="medium"
                  title={getDisplayValue(TAG018)}
                  onClick={() => {
                    this.doKeywordSearch(TEAM_KEYWORD);
                  }}
                  isDisabled={loading}
                >
                  <Icon
                    icon="find_service_teams"
                    category="svmx"
                    size="x-small"
                  />
                </Button>
              )}
              {this.showConfigTechBtn && (
                <Button
                  type="icon-border-filled"
                  size="medium"
                  title={getDisplayValue(TAG145)}
                  onClick={() => handleSettingClick(CONFIGURE_TECH_TEAM_SEARCH)}
                  isDisabled={loading}
                >
                  <Icon icon="rating" size="x-small" />
                </Button>
              )}
            </ButtonGroup>
          </GridItem>
        </GridRow>
      </GridItem>
    );
  }
}

const mapDispatchToProps = dispatch => ({
  onActionSearchTech: (item, findWhat, callback) =>
    dispatch({
      callback,
      findWhat,
      payload: item,
      type: GET_SEARCH_TECH
    }),
  onClearSearchTech: () =>
    dispatch({
      type: SEARCH_TECH_DATA_CLEAR
    }),
  onSearchCriteriaStatusUpdate: () => {
    dispatch({
      type: SEARCH_KEY_MATCH_EMPTY
    });
  },
  onSearchTxtStatusUpdate: () => {
    dispatch({
      type: SEARCH_TEXT_EMPTY
    });
  },
  snoozeRowSelectionTrigger: () =>
    dispatch(
      gridStateChanged(
        {
          gridActive: false
        },
        UPDATE_GRID_STATE
      )
    )
});

SchedulerTechnicianSearch.propTypes = propTypes;

export default connect(null, mapDispatchToProps)(SchedulerTechnicianSearch);
