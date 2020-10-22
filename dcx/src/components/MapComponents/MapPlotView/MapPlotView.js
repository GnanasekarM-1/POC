import React, { Component } from "react";
import { connect } from "react-redux";
import PropTypes from "prop-types";
import { flatMap } from "lodash";
import {
  Checkbox,
  Container,
  DataGrid,
  Grid,
  GridRow,
  Input,
  Label,
  PicklistFactory,
  InputWrapper,
  Icon,
  Menu,
  Picklist,
  MenuItem,
  Tab,
  Tabs,
  Button,
  Spinner,
  GridItem
} from "@svmx/ui-components-lightning";
import {
  TAG017,
  TAG092,
  TAG329,
  TAG330,
  TAG331,
  TAG332,
  TAG333,
  TAG334,
  TAG371
} from "constants/DisplayTagConstants";
import {
  MAP_ACCOUNT_LABEL,
  MAP_ACCOUNT_VIEW,
  MAP_CUSTOM_EVENT_PLOT_ON_MAP,
  MAP_ID,
  MAP_LOCATION_LABEL,
  MAP_LOCATION_VIEW,
  MAP_NAME,
  MAP_RECORDS_LABEL,
  MAP_VIEW_HEADER,
  MAP_VIEW_NAME_LABEL,
  MAP_VIEW_PLOT_RADIUS,
  MAP_VIEW_PLOT_RADIUS_DEFAULT,
  MAP_VIEW_RADIUS,
  MAP_VIEW_RECORD_LIMIT_DEFAULT,
  MAP_VIEW_RECORDS_MAX,
  MAP_VIEW_RECORDS_MIN,
  MAP_VIEW_ROW,
  MAP_WORKORDER_LABEL,
  MAP_WORKORDER_VIEW,
  MAP_CLEAR_LABEL,
  MAP_PLOT_ON_MAP_LABEL,
  MAP_VIEW_LATITUDE,
  MAP_VIEW_LONGITUDE,
  MAP_VIEW_OBJECTNAME,
  MAP_VIEW_RECORD_LIMIT,
  MAP_VIEW_VIEW_ID,
  SEARCH_RADIUS_MENU_ITEM
} from "constants/MapConstants";
import {
  ACCOUNT_API_NAME,
  DISPLAY_SIZE_SMALL,
  EVENT_KEY_1,
  EVENT_KEY_2,
  EVENT_KEY_3,
  LOCATION_API_NAME,
  WORKORDER_API_NAME,
  VALUE,
  TECH_LATITUDE_PROPERTY,
  TECH_LONGITUDE_PROPERTY,
  TYPE_NEUTRAL_GRAY
} from "constants/AppConstants";
import { getDisplayValue } from "utils/DCUtils";
import {
  getViewDataToPlotInternal,
  toggleViewSelection,
  clearMap,
  plot,
  getPlotNearByLatLng,
  clearRoute
} from "services/MapService";
import {
  clearViewItems,
  getSelectedRadiusIndex,
  getSelectedTab,
  setSelectedConfigRadius,
  setRecordLimit,
  setSelectedRadius,
  setSelectedTab,
  storeSelectedViewItems,
  getRecordLimit,
  getSelectedRadius,
  getSelectedViewItems,
  setConfigRecordLimit,
  setLastPlotCircleData,
  setLastPlotCircleDataReset,
  resetShowRouteData
} from "utils/MapUtils";
import { getSettingValue, DCON001_SET005, SET059 } from "constants/AppSettings";
import {
  GET_MAP_VIEW_DATA,
  MAP_VIEW_DATA_CLEAR
} from "constants/ActionConstants";
import { createPayloadParam } from "utils/ViewUtils";
import { MAP_CUSTOM_EVENT_SHOW_FULL_SCREEN_SETVALUE } from "constants/MapConstants";
import "./MapPlotView.scss";

const propTypes = {
  account: PropTypes.arrayOf(PropTypes.array).isRequired,
  location: PropTypes.arrayOf(PropTypes.array).isRequired,
  onChildRef: PropTypes.func.isRequired,
  workOrder: PropTypes.arrayOf(PropTypes.array).isRequired,
  accountViewList: PropTypes.arrayOf(PropTypes.array).isRequired,
  locationViewList: PropTypes.arrayOf(PropTypes.array).isRequired,
  onActionClearOnMap: PropTypes.func.isRequired,
  onActionPlotOnMap: PropTypes.func.isRequired,
  onClearSelectedViews: PropTypes.func.isRequired,
  onRadiusReset: PropTypes.func.isRequired,
  onRecordsLimitReset: PropTypes.func.isRequired,
  onShowMapSpinner: PropTypes.func.isRequired,
  workOrderViewList: PropTypes.arrayOf(PropTypes.array).isRequired
};

class PlotView extends Component {
  constructor(props) {
    super(props);
    const { account, location, workOrder } = this.props;
    this.shouldShowMapSpinner = false;
    this.workOrderPlotDone = false;
    this.accountPlotDone = false;
    this.locationPlotDone = false;
    this.state = {
      account,
      location,
      recordLimit: getRecordLimit(),
      selectedRadiusIndex: getSelectedRadiusIndex(),
      radiusSelectedvalue:
        getSelectedRadius() || getSettingValue(DCON001_SET005),
      selectedTab: getSelectedTab(),
      workOrder
      // shouldShowMapSpinner: false,
    };
    // window.addEventListener(
    //  MAP_CUSTOM_EVENT_SHOW_FULL_SCREEN_SETVALUE,
    //  this.handleChildWindowClose,
    // false
    // );
  }

  componentDidMount() {
    const { onChildRef } = this.props;
    onChildRef(this);
  }

  componentWillUnmount() {
    const { onChildRef } = this.props;
    onChildRef(undefined);
  }

  handleChildWindowClose = () => {
    const { radiusSelectedvalue, recordLimit } = this.state;
    let radius = Number(radiusSelectedvalue);
    if (radius >= 2000) {
      radius = 2000;
    } else if (radius <= 0) {
      // radius = MAP_VIEW_PLOT_RADIUS_DEFAULT;
      radius = getSettingValue(DCON001_SET005);
    }
    if (isNaN(radius)) {
      // radius = MAP_VIEW_PLOT_RADIUS_DEFAULT;
      radius = getSettingValue(DCON001_SET005);
    }
    setSelectedRadius(radius);

    setConfigRecordLimit();

    if (recordLimit > 100) {
      recordLimit = getRecordLimit();
    } else if (recordLimit < 1) {
      recordLimit = getRecordLimit();
    }
    setRecordLimit(recordLimit);
  };

  createColumns = (hChecked, onCheckedChange, objName) => {
    const gridColumns = [
      {
        Cell: row => {
          const { original } = row;
          const { checked, value1 } = original;
          return (
            <Checkbox
              isChecked={checked}
              name={objName}
              onCheckedChange={e => {
                onCheckedChange(e, MAP_VIEW_ROW);
              }}
              value={value1}
            />
          );
        },
        Header: (
          <Checkbox
            isChecked={hChecked}
            name={objName}
            onCheckedChange={e => {
              onCheckedChange(e, MAP_VIEW_HEADER);
            }}
          />
        ),
        width: 50
      },
      {
        accessor: VALUE,
        Header: getDisplayValue(TAG331, MAP_VIEW_NAME_LABEL)
      }
    ];
    return gridColumns;
  };

  onConfigSelectedView = (list, apiName) => {
    const checkedArr = [];
    flatMap(list, (listItem, i) => {
      let checked = false;
      if (listItem.length) {
        checked =
          listItem.filter(item => item.checked).length === listItem.length;
      }
      checkedArr.push(checked);
      const selectedView = listItem.filter(item => item.checked);
      if (selectedView.length > 0) {
        storeSelectedViewItems(apiName[i], selectedView);
      }
    });
    return checkedArr;
  };

  handleCheckedChange = (e, type) => {
    const { isChecked, name, value } = e;
    this.setState(state => ({
      [name]: flatMap(state[name], item => {
        if (type === MAP_VIEW_HEADER) {
          toggleViewSelection(item.value1, isChecked);
          item.checked = isChecked;
        } else if (item.value1 === value) {
          toggleViewSelection(value, isChecked);
          item.checked = isChecked;
        }
        return item;
      })
    }));
  };

  handleClearSelectedViews = list => {
    list.map(name => {
      this.setState(state => ({
        [name]: flatMap(state[name], item => {
          item.checked = false;
          return item;
        })
      }));
      return undefined;
    });
  };

  handleRadiusChange = ({ display, value }) => {
    this.setState({
      selectedRadiusIndex: [value],
      radiusSelectedvalue: null
    });
    setSelectedRadius(display);
    getViewDataToPlotInternal(display, true);
    this.handlePlotOnMap();
    // const event = new CustomEvent(MAP_CUSTOM_EVENT_PLOT_ON_MAP, { detail: true });
    // window.dispatchEvent(event);
    // onPlotOnMap();
  };

  handleRadiusTextChange = ({ value }) => {
    // const radius = Number(value);
    /* if (radius >= 2000) {
      radius = 2000;
    } else if (radius <= 0) {
      // radius = MAP_VIEW_PLOT_RADIUS_DEFAULT;
      radius = getSettingValue(DCON001_SET005);
    } */
    this.setState({
      radiusSelectedvalue: value
    });
    // setSelectedRadius(radius);
    // getViewDataToPlotInternal(radius, true);
  };

  handleRadiusTextChangeOnBlur = ({ target }) => {
    const { value } = target;
    let radius = Number(value);
    if (radius >= 2000) {
      radius = 2000;
    } else if (radius <= 0) {
      // radius = MAP_VIEW_PLOT_RADIUS_DEFAULT;
      radius = getSettingValue(DCON001_SET005);
    }
    if (isNaN(radius)) {
      // radius = MAP_VIEW_PLOT_RADIUS_DEFAULT;
      radius = getSettingValue(DCON001_SET005);
    }
    this.setState({
      radiusSelectedvalue: radius
    });
    setSelectedRadius(radius);
    // getViewDataToPlotInternal(radius, true);
  };

  handleRecordLimitChange = ({ target }) => {
    const { value } = target;
    /* if (value > 100) {
      value = 1;
    } else if (value < 0) {
      value = 1;
    } */
    this.setState({
      recordLimit: value
    });
    // setRecordLimit(value);
  };

  handleRecordLimitFocusOut = ({ target }) => {
    let { value } = target;
    setConfigRecordLimit();

    if (value > 100) {
      value = getRecordLimit();
    } else if (value < 1) {
      value = getRecordLimit();
    }
    this.setState({
      recordLimit: value
    });
    setRecordLimit(value);
  };

  handleRecordLimitReset = () => {
    setConfigRecordLimit();
    this.setState({
      recordLimit: getRecordLimit()
    });
  };

  handleRadiusReset = () => {
    setSelectedConfigRadius();
    const selectedConfigRadius = getSelectedRadiusIndex();
    if (selectedConfigRadius) {
      this.setState({
        selectedRadiusIndex: selectedConfigRadius
      });
    }
    this.setState({
      selectedRadiusIndex: null,
      radiusSelectedvalue: getSettingValue(DCON001_SET005)
    });
  };

  handleSelectedTab = ({ tabKey }) => {
    this.setState({
      selectedTab: tabKey
    });
    setSelectedTab(tabKey);
  };

  handleClearMap = () => {
    const {
      onActionClearOnMap,
      onClearSelectedViews,
      onRecordsLimitReset,
      onRadiusReset
    } = this.props;
    this.shouldShowMapSpinner = false;
    this.workOrderPlotDone = false;
    this.accountPlotDone = false;
    this.locationPlotDone = false;
    this.handleRadiusReset();
    this.handleRecordLimitReset();
    clearMap();
    onClearSelectedViews([
      MAP_ACCOUNT_VIEW,
      MAP_LOCATION_VIEW,
      MAP_WORKORDER_VIEW
    ]);
    onActionClearOnMap();
    resetShowRouteData();
    clearRoute();
  };

  createMarkerForViewDataNew = viewList => {
    const { onShowMapSpinner, onActionClearOnMap } = this.props;
    const data = {};
    const { objectName } = viewList;
    data.items = [];

    data.context = {
      objectName
    };
    viewList.map(item => {
      const { sobj, key } = item;
      const lat = sobj[TECH_LATITUDE_PROPERTY];
      const lng = sobj[TECH_LONGITUDE_PROPERTY];
      const id = sobj[MAP_ID];
      let hoverInfo = "";
      item.valueList.map(Valueitem => {
        hoverInfo += `${Valueitem}\n`;
        return undefined;
      });
      data.items.push({
        hoverInfo,
        id,
        lat,
        lng,
        viewId: key
      });
      return undefined;
    });
    // clearMap();
    // const selectedRadius = getSelectedRadius();
    // getViewDataToPlotInternal(selectedRadius, true);
    plot(data);
    setLastPlotCircleData(data);
    if (
      !this.workOrderPlotDone &&
      !this.accountPlotDone &&
      !this.locationPlotDone
    ) {
      this.handleShowMapSpinner(false);
    }
    onActionClearOnMap();
    // onShowMapSpinner(false);
  };

  handlePlotOnMap = () => {
    const { onActionPlotOnMap, onShowMapSpinner } = this.props;
    const workOrderViewSelectedItems =
      getSelectedViewItems(WORKORDER_API_NAME) || [];
    const accountViewSelectedItems =
      getSelectedViewItems(ACCOUNT_API_NAME) || [];
    const locationViewSelectedItems =
      getSelectedViewItems(LOCATION_API_NAME) || [];
    const currentLatLng = getPlotNearByLatLng();
    const selectedRadius =
      getSelectedRadius() || getSettingValue(DCON001_SET005);
    const recordLimit = getRecordLimit();
    let payLoadWorkOrderData;
    let payLoadAccountData;
    let payLoadLocationData;
    const payLoadDispatchAction = [];
    const payLoadDispatchActionApiNames = [];
    getViewDataToPlotInternal(selectedRadius, true);
    setLastPlotCircleDataReset();
    if (workOrderViewSelectedItems.length) {
      payLoadWorkOrderData = this.handleCreatePlotOnMapData(
        workOrderViewSelectedItems[0].MAP_VIEW_OBJECT_NAME,
        currentLatLng.lat,
        currentLatLng.lng,
        selectedRadius,
        recordLimit,
        workOrderViewSelectedItems
      );
      payLoadDispatchAction.push(payLoadWorkOrderData);
      payLoadDispatchActionApiNames.push(
        workOrderViewSelectedItems[0].MAP_VIEW_OBJECT_NAME
      );
      this.workOrderPlotDone = true;
    }
    if (accountViewSelectedItems.length) {
      payLoadAccountData = this.handleCreatePlotOnMapData(
        accountViewSelectedItems[0].MAP_VIEW_OBJECT_NAME,
        currentLatLng.lat,
        currentLatLng.lng,
        selectedRadius,
        recordLimit,
        accountViewSelectedItems
      );
      payLoadDispatchAction.push(payLoadAccountData);
      payLoadDispatchActionApiNames.push(
        accountViewSelectedItems[0].MAP_VIEW_OBJECT_NAME
      );
      this.accountPlotDone = true;
    }
    if (locationViewSelectedItems.length) {
      payLoadLocationData = this.handleCreatePlotOnMapData(
        locationViewSelectedItems[0].MAP_VIEW_OBJECT_NAME,
        currentLatLng.lat,
        currentLatLng.lng,
        selectedRadius,
        recordLimit,
        locationViewSelectedItems
      );
      payLoadDispatchAction.push(payLoadLocationData);
      payLoadDispatchActionApiNames.push(
        locationViewSelectedItems[0].MAP_VIEW_OBJECT_NAME
      );
      this.locationPlotDone = true;
    }
    if (payLoadDispatchAction.length) {
      // onShowMapSpinner(true);
      this.handleShowMapSpinner(true);
      onActionPlotOnMap(payLoadDispatchAction, payLoadDispatchActionApiNames);
    }
  };

  handleCreatePlotOnMapData = (
    apiName,
    lat,
    lng,
    selectedRadius,
    recordLimit,
    viewIds
  ) => {
    const viewItems = this.prepareDataForPlotOnMapViewIds(viewIds);
    const payloadPlotMapData = [];
    createPayloadParam(MAP_VIEW_LATITUDE, lat, payloadPlotMapData);
    createPayloadParam(MAP_VIEW_LONGITUDE, lng, payloadPlotMapData);
    createPayloadParam(MAP_VIEW_RADIUS, selectedRadius, payloadPlotMapData);
    createPayloadParam(MAP_VIEW_RECORD_LIMIT, recordLimit, payloadPlotMapData);
    createPayloadParam(MAP_VIEW_OBJECTNAME, apiName, payloadPlotMapData);
    createPayloadParam(MAP_VIEW_VIEW_ID, viewItems, payloadPlotMapData);
    return payloadPlotMapData;
  };

  prepareDataForPlotOnMapViewIds = viewItems => {
    const payloadViewIds = [];
    viewItems.map(item => {
      payloadViewIds.push(item.KEY);
      return undefined;
    });
    return payloadViewIds;
  };

  handleShowMapSpinner = value => {
    this.shouldShowMapSpinner = value;
    // this.setState({
    //  shouldShowMapSpinner: value,
    // });
  };

  render() {
    const {
      account,
      location,
      recordLimit,
      selectedRadiusIndex,
      selectedTab,
      workOrder,
      radiusSelectedvalue
    } = this.state;
    const {
      accountViewList,
      locationViewList,
      workOrderViewList,
      mapUnit
    } = this.props;
    if (accountViewList) {
      this.accountPlotDone = false;
      this.createMarkerForViewDataNew(accountViewList);
    }
    if (locationViewList) {
      this.locationPlotDone = false;
      this.createMarkerForViewDataNew(locationViewList);
    }
    if (workOrderViewList) {
      this.workOrderPlotDone = false;
      this.createMarkerForViewDataNew(workOrderViewList);
    }
    clearViewItems();
    const checkedArr = this.onConfigSelectedView(
      [workOrder, account, location],
      [WORKORDER_API_NAME, ACCOUNT_API_NAME, LOCATION_API_NAME]
    );
    const [workOrderChck, accountChck, locationChck] = checkedArr;
    return (
      <Container>
        {this.shouldShowMapSpinner && (
          <div className="PlotView__spinner">
            <Spinner />
          </div>
        )}
        <Tabs
          activeKey={selectedTab}
          onSelect={this.handleSelectedTab}
          type="scoped"
          disableOverflow
        >
          <Tab
            eventKey={EVENT_KEY_1}
            title={getDisplayValue(TAG092, MAP_WORKORDER_LABEL)}
          >
            <DataGrid
              className="PlotView__dataGrid"
              columns={this.createColumns(
                workOrderChck,
                this.handleCheckedChange,
                MAP_WORKORDER_VIEW
              )}
              data={workOrder}
              defaultItemsPerPage={
                workOrder && workOrder.length ? workOrder.length : 50
              }
              defaultSorted={[{ desc: false, id: VALUE }]}
              hasColumnBorder={false}
              hasFixedHeader
              hasRowHover
              resizable={false}
              showPagination={false}
            />
          </Tab>
          <Tab
            eventKey={EVENT_KEY_2}
            title={getDisplayValue(TAG329, MAP_ACCOUNT_LABEL)}
          >
            <DataGrid
              className="PlotView__dataGrid"
              columns={this.createColumns(
                accountChck,
                this.handleCheckedChange,
                MAP_ACCOUNT_VIEW
              )}
              data={account}
              defaultItemsPerPage={
                account && account.length ? account.length : 50
              }
              defaultSorted={[{ desc: false, id: VALUE }]}
              hasColumnBorder={false}
              hasFixedHeader
              hasRowHover
              resizable={false}
              showPagination={false}
            />
          </Tab>
          <Tab
            eventKey={EVENT_KEY_3}
            title={getDisplayValue(TAG330, MAP_LOCATION_LABEL)}
          >
            <DataGrid
              className="PlotView__dataGrid"
              columns={this.createColumns(
                locationChck,
                this.handleCheckedChange,
                MAP_LOCATION_VIEW
              )}
              data={location}
              defaultItemsPerPage={
                location && location.length ? location.length : 50
              }
              defaultSorted={[{ desc: false, id: VALUE }]}
              hasColumnBorder={false}
              hasFixedHeader
              hasRowHover
              resizable={false}
              showPagination={false}
            />
          </Tab>
        </Tabs>
        <div className="PlotView__radiusComponent">
          <Grid>
            <GridRow>
              <GridItem noFlex>
                <Label>
                  {getDisplayValue(TAG017, MAP_VIEW_RADIUS)}
                  {`(${mapUnit})`}
                </Label>
              </GridItem>
              <GridItem noFlex>
                <Picklist
                  className="PlotView__radiusPickList"
                  allowInput
                  defaultText=""
                  selectMode="single"
                  onSelectedChange={this.handleRadiusChange}
                  onInputValueChange={this.handleRadiusTextChange}
                  selectedValues={selectedRadiusIndex}
                  size={DISPLAY_SIZE_SMALL}
                >
                  <InputWrapper>
                    <Input
                      isComboBox
                      value={radiusSelectedvalue}
                      onBlur={e => {
                        this.handleRadiusTextChangeOnBlur(e);
                      }}
                    />
                    <Icon icon="down" size="x-small" />
                  </InputWrapper>
                  <Menu>
                    {MAP_VIEW_PLOT_RADIUS.map(dist => (
                      <MenuItem key={dist[MAP_ID]} value={dist[MAP_NAME]}>
                        {dist[MAP_NAME]}
                      </MenuItem>
                    ))}
                  </Menu>
                </Picklist>
              </GridItem>
              <GridItem noFlex>
                <Label>{getDisplayValue(TAG332, MAP_RECORDS_LABEL)}</Label>
              </GridItem>
              <GridItem noFlex>
                <Input
                  className="PlotView__radiusStepper"
                  max={MAP_VIEW_RECORDS_MAX}
                  min={MAP_VIEW_RECORDS_MIN}
                  title={`${getDisplayValue(TAG371)} ${MAP_VIEW_RECORDS_MAX}`}
                  onChange={e => {
                    this.handleRecordLimitChange(e);
                  }}
                  onBlur={e => {
                    this.handleRecordLimitFocusOut(e);
                  }}
                  type="number"
                  value={recordLimit}
                />
              </GridItem>
            </GridRow>
          </Grid>
        </div>
        <div className="PlotView_plot_button_toolbar">
          <Button
            className="PlotView__toolBar_buttons"
            onClick={this.handlePlotOnMap}
            size={DISPLAY_SIZE_SMALL}
            type={TYPE_NEUTRAL_GRAY}
            title={getDisplayValue(TAG334)}
          >
            {getDisplayValue(TAG334, MAP_PLOT_ON_MAP_LABEL)}
          </Button>
          <Button
            className="PlotView__toolBar_buttons"
            onClick={this.handleClearMap}
            size={DISPLAY_SIZE_SMALL}
            type={TYPE_NEUTRAL_GRAY}
            title={getDisplayValue(TAG333, MAP_CLEAR_LABEL)}
          >
            {getDisplayValue(TAG333, MAP_CLEAR_LABEL)}
          </Button>
        </div>
      </Container>
    );
  }
}

PlotView.propTypes = propTypes;

const mapStateToProps = state => {
  const { viewData } = state;
  const { viewDefinition, mapViewData } = viewData;
  const { content } = viewDefinition;
  const { account = [], location = [], workOrder = [] } = content;
  if (mapViewData) {
    const { status } = mapViewData;
    const { api } = status;
    if (api === 2) {
      const { content } = mapViewData;
      const { accountViewList, locationViewList, workOrderViewList } = content;
      return {
        accountViewList,
        locationViewList,
        workOrderViewList,
        account,
        location,
        workOrder
      };
    }
  }
  return {
    account,
    location,
    workOrder
  };
};
const mapDispatchToProps = dispatch => ({
  onActionClearOnMap: () => {
    dispatch({
      type: MAP_VIEW_DATA_CLEAR
    });
  },

  onActionPlotOnMap: (items, apiNameItems) => {
    items.map((item, i) => {
      const objectName = apiNameItems[i];
      dispatch({
        objectName,
        payload: item,
        type: GET_MAP_VIEW_DATA
      });
      return undefined;
    });
  }
});
export default connect(mapStateToProps, mapDispatchToProps)(PlotView);
