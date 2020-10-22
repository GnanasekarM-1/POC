import React, { Component } from "react";
import { connect } from "react-redux";
import PropTypes from "prop-types";
import { Button } from "@svmx/ui-components-lightning";
import { getDisplayValue } from "utils/DCUtils";
import { TAG333, TAG334 } from "constants/DisplayTagConstants";
import {
  ACCOUNT_API_NAME,
  DISPLAY_SIZE_SMALL,
  LOCATION_API_NAME,
  TECH_LATITUDE_PROPERTY,
  TECH_LONGITUDE_PROPERTY,
  WORKORDER_API_NAME,
  TYPE_NEUTRAL_GRAY
} from "constants/AppConstants";
import {
  GET_MAP_VIEW_DATA,
  MAP_VIEW_DATA_CLEAR
} from "constants/ActionConstants";
import {
  MAP_ACCOUNT_VIEW,
  MAP_CLEAR_LABEL,
  MAP_CUSTOM_EVENT_PLOT_ON_MAP,
  MAP_ID,
  MAP_LOCATION_VIEW,
  MAP_PLOT_ON_MAP_LABEL,
  MAP_VIEW_LATITUDE,
  MAP_VIEW_LONGITUDE,
  MAP_VIEW_OBJECTNAME,
  MAP_VIEW_RADIUS,
  MAP_VIEW_RECORD_LIMIT,
  MAP_VIEW_VIEW_ID,
  MAP_WORKORDER_VIEW
} from "constants/MapConstants";
import {
  clearMap,
  getPlotNearByLatLng,
  getViewDataToPlotInternal,
  plot
} from "services/MapService";
import {
  getRecordLimit,
  getSelectedRadius,
  getSelectedViewItems
} from "utils/MapUtils";
import { getSettingValue, DCON001_SET005 } from "constants/AppSettings";
import { createPayloadParam } from "utils/ViewUtils";
import "./MapPlotView.scss";

const defaultTypes = {
  workOrderViewList: []
};

const propTypes = {
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

const createMarkerForViewData = (onShowMapSpinner, viewList) => {
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
  onShowMapSpinner(false);
};

class PlotOnMap extends Component {
  /* constructor(props) {
    super(props);
    const me = this;
    me = React.createRef();
  } */

  componentDidMount() {
    const { onPlotOnMapChildRef } = this.props;
    onPlotOnMapChildRef(this);
    // window.addEventListener(MAP_CUSTOM_EVENT_PLOT_ON_MAP, this.handlePlotOnMap, false);
  }

  componentWillUnmount() {
    const { onPlotOnMapChildRef } = this.props;
    onPlotOnMapChildRef(undefined);
    // window.removeEventListener(MAP_CUSTOM_EVENT_PLOT_ON_MAP, this.handlePlotOnMap, false);
  }

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
    }
    if (payLoadDispatchAction.length) {
      onShowMapSpinner(true);
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

  handleClearMap = () => {
    const {
      onActionClearOnMap,
      onClearSelectedViews,
      onRecordsLimitReset,
      onRadiusReset
    } = this.props;
    onActionClearOnMap();
    onClearSelectedViews([
      MAP_ACCOUNT_VIEW,
      MAP_LOCATION_VIEW,
      MAP_WORKORDER_VIEW
    ]);
    clearMap();
    onRecordsLimitReset();
    onRadiusReset();
  };

  createMarkerForViewDataNew = (onShowMapSpinner, viewList) => {
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
    onShowMapSpinner(false);
  };

  render() {
    const {
      accountViewList,
      locationViewList,
      onShowMapSpinner,
      workOrderViewList
    } = this.props;
    if (accountViewList) {
      this.createMarkerForViewDataNew(onShowMapSpinner, accountViewList);
    }
    if (locationViewList) {
      this.createMarkerForViewDataNew(onShowMapSpinner, locationViewList);
    }
    if (workOrderViewList) {
      this.createMarkerForViewDataNew(onShowMapSpinner, workOrderViewList);
    }
    return (
      <div className="PlotView__buttons">
        <Button
          onClick={this.handlePlotOnMap}
          size={DISPLAY_SIZE_SMALL}
          type={TYPE_NEUTRAL_GRAY}
          title={getDisplayValue(TAG334)}
        >
          {getDisplayValue(TAG334, MAP_PLOT_ON_MAP_LABEL)}
        </Button>
        <Button
          onClick={e => {
            this.handleClearMap(e);
          }}
          size={DISPLAY_SIZE_SMALL}
          type={TYPE_NEUTRAL_GRAY}
          title={getDisplayValue(TAG333)}
        >
          {getDisplayValue(TAG333, MAP_CLEAR_LABEL)}
        </Button>
      </div>
    );
  }
}

const mapStateToProps = state => {
  const { viewData } = state;
  const { mapViewData } = viewData;

  if (mapViewData) {
    const { status } = mapViewData;
    const { api } = status;
    if (api === 2) {
      const { content } = mapViewData;
      const { accountViewList, locationViewList, workOrderViewList } = content;
      return {
        accountViewList,
        locationViewList,
        workOrderViewList
      };
    }
  }
  return undefined;
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

PlotOnMap.defaultTypes = defaultTypes;
PlotOnMap.propTypes = propTypes;

export default connect(mapStateToProps, mapDispatchToProps)(PlotOnMap);
