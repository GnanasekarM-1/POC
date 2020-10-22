import React, { Component } from "react";
import {
  DataGrid,
  Button,
  Container,
  DropdownFactory,
  Icon,
  Modal,
  ModalContent,
  ModalHeader,
  ModalFooter
} from "@svmx/ui-components-lightning";
import { applyWOColorRule } from "utils/ColorUtils";
import {
  getFieldValue,
  getFieldValueFromHtml,
  convertUint2Hex,
  getDisplayValue,
  lightOrDark,
  underScheduleWO
} from "utils/DCUtils";
import { isValidViolationMessage } from "utils/GridUtils";
import { openPopUp } from "utils/MapUtils";
import {
  STATUS_NEW,
  STATUS_QUEUED,
  ASK_USER,
  SHOW_PROJECT_VIEW,
  LIST_WO,
  WORKORDER_TECHNICIAN_API_NAME,
  WO_DISPATCH_STATUS_FIELD,
  MANAGE_MULTIPLE_ASSIGNMENTS,
  SHOW_RECORD,
  UNASSIGN_THIS_WORK_ORDER,
  RANKED_APPOINTMENT_BOOKING,
  VIOLATION_VIEW_WORK_ORDER,
  VIOLATION_VIEW_WORK_ORDER_STATUS,
  WO_VIOLATION_MESSAGE,
  WO_VIOLATION_STATUS,
  WO_UNSCHEDULED_DURATIONS,
  ONUNDERSCHEDULING,
  DO_NOTHING,
  FALSE
} from "constants/AppConstants";
import {
  ALL,
  DCON005_SET006,
  DCON001_SET008,
  SET013,
  getSettingValue,
  SET056,
  SET010,
  ASSIGNED
} from "constants/AppSettings";
import {
  TAG167,
  TAG182,
  TAG069,
  EVENTSTAG002
} from "constants/DisplayTagConstants";
import unScheduledDurationService from "services/UnScheduledDurationService";
import UnderScheduledWOModal from "components/Modals/UnderScheduledWOModal";
import ViolationStatusModal from "components/Modals/ViolationStatusModal";
import { isEqual } from "lodash";
import "./GridView.scss";

let violationStatusMsg = {
  category: "",
  name: "",
  severity: "",
  type: ""
};

class GridView extends Component {
  constructor(props) {
    super(props);
    const { gridState } = props;
    const { row } = gridState;
    this.state = {
      gridInitialized: false,
      isUnAssign: false,
      isUnderScheduledWO: false,
      isViloationScheduledWO: false,
      rowSelected: (row && row.Id) || undefined
    };
  }

  handleGridRowClick = rowInfo => {
    const { original } = rowInfo;
    const { Id } = original;
    this.setState({ rowSelected: Id });
    const { rowSelectionChanged } = this.props;
    setTimeout(() => rowSelectionChanged(original), 0);
  };

  handViolationMenuOption = (wo, menuOptions) => {
    if (wo) {
      if (
        wo[WO_VIOLATION_STATUS] === VIOLATION_VIEW_WORK_ORDER_STATUS &&
        wo[WO_VIOLATION_MESSAGE]
      ) {
        if (wo[WO_VIOLATION_MESSAGE] != "") {
          const isValid = isValidViolationMessage(wo[WO_VIOLATION_MESSAGE]);
          if (isValid.length) {
            violationStatusMsg = isValid;
            const checkMenuOption = menuOptions.filter(
              item => item.value === VIOLATION_VIEW_WORK_ORDER
            );
            if (checkMenuOption.length === 0) {
              menuOptions.push({
                display: getDisplayValue(EVENTSTAG002),
                value: VIOLATION_VIEW_WORK_ORDER
              });
            }
          }
        }
      }
    }
    return menuOptions;
  };

  handleTRProps = (rowInfo, data) => {
    const { rowSelected } = this.state;
    const { rules, selectionColor } = this.props;
    let rowColor = "#ffffff";
    let textColor = "#000";
    let finalRowColor = "#fff";
    let style;
    const autoSelectWorkOrder = JSON.parse(
      getSettingValue(DCON001_SET008, FALSE).toLowerCase()
    );

    rowColor = convertUint2Hex(applyWOColorRule(rowInfo, rules));

    const gridSelectionColor = convertUint2Hex(selectionColor);

    const { original } = rowInfo;
    const { Id } = original;
    finalRowColor = rowColor;

    if (Id === rowSelected) {
      if (data.length === 1 && autoSelectWorkOrder) {
        finalRowColor = gridSelectionColor;
      } else if (data.length > 1) {
        finalRowColor = gridSelectionColor;
      }
    }

    if (lightOrDark(finalRowColor) === "light") {
      textColor = "#000";
    } else {
      textColor = "#fff";
    }

    style = {
      backgroundColor: finalRowColor,
      color: textColor
    };

    return {
      onClick: () => {
        this.handleGridRowClick(rowInfo);
      },

      style
    };
  };

  underScheduleWO = woInfo => {
    if (getSettingValue(DCON005_SET006) === "Enabled") {
      const woData = woInfo || unScheduledDurationService.getWOInfo();
      const settingValue =
        window.sessionStorage.getItem(`${ONUNDERSCHEDULING}`) ||
        getSettingValue(SET013).toLowerCase();
      if (Number(woData[WO_UNSCHEDULED_DURATIONS]) > 0) {
        if (settingValue === ASK_USER.toLowerCase()) {
          this.setState({ isUnderScheduledWO: true });
        } else {
          this.hideUnderScheduledWOModal(settingValue);
        }
      }
    }
  };

  updateWODataInStore = woData => {
    const { data, gridState, updateSingleWOInfo } = this.props;
    const { status } = gridState;

    for (let i = 0; i < data.length; i += 1) {
      if (data[i].Id === woData.Id) {
        if (
          status === ALL ||
          status.includes(woData[WO_DISPATCH_STATUS_FIELD])
        ) {
          const obj = data[i];
          Object.keys(obj).map(key => {
            obj[key] = null;
          });

          Object.assign(data[i], woData);
          break;
        } else {
          data.splice(i, 1);
        }
      }
    }

    updateSingleWOInfo(data);
  };

  getWOInfo = woId => {
    const { fetchWOInfo } = this.props;
    const payload = {
      whatId: woId
    };
    fetchWOInfo(this.updateWODataInStore, payload);
  };

  handleMenuItemClick = (item, rowInfo) => {
    const { value } = item;
    const { openMMADialog, rowSelectionChanged } = this.props;
    const { original } = rowInfo;
    rowSelectionChanged(original);
    switch (value) {
      case MANAGE_MULTIPLE_ASSIGNMENTS:
        openMMADialog(true);
        break;
      case SHOW_RECORD: {
        openPopUp(original.Id);
        break;
      }
      case UNASSIGN_THIS_WORK_ORDER: {
        const technician = getFieldValueFromHtml(
          original,
          WORKORDER_TECHNICIAN_API_NAME,
          null
        );
        const dispatchStatus = getFieldValueFromHtml(
          original,
          WO_DISPATCH_STATUS_FIELD,
          STATUS_NEW
        );
        const isAssigned =
          dispatchStatus.toUpperCase() !== STATUS_NEW && technician;
        const isQueued = dispatchStatus.toUpperCase() === STATUS_QUEUED;
        this.setState({
          displayText: isAssigned || isQueued ? TAG167 : TAG182,
          isUnAssign: true
        });
        break;
      }
      case RANKED_APPOINTMENT_BOOKING: {
        const URL = `apex/WSCH_Provider_ECO_Appointment?id=${original.Id}`;
        openPopUp(URL, true);
        break;
      }
      case VIOLATION_VIEW_WORK_ORDER: {
        this.setState({ isViloationScheduledWO: true });
        break;
      }
      default:
        break;
    }
  };

  handleUnassignConfirmation = value => {
    const { gridState, unAssignWO } = this.props;
    const { row } = gridState;
    if (value === "yes") {
      const wo = {};
      wo.WorkOrderIds = [row.Id];
      unAssignWO(wo, () => this.getWOInfo(row.Id));
    }
    this.setState({ isUnAssign: false });
  };

  customizeWOColumn = ([woColumn], menuOptions) => {
    if (woColumn) {
      woColumn.Cell = props => {
        const { original } = props;
        const { Name } = original;
        const modifiedMenuOptions = this.handViolationMenuOption(
          original,
          menuOptions
        );
        return (
          <div className="GridView__ContextMenu">
            <div>{Name}</div>
            <DropdownFactory
              items={modifiedMenuOptions}
              onItemClick={item => this.handleMenuItemClick(item, props)}
            >
              <Button type="icon">
                <Icon
                  icon="threedots_vertical"
                  className="woGridEllipsis"
                  size="x-small"
                  align="right"
                />
              </Button>
            </DropdownFactory>
          </div>
        );
      };
      woColumn.fixed = "left";
    }
    return woColumn;
  };

  onColumnResize = newResized => {
    const { gridColumnResized } = this.props;
    setTimeout(() => gridColumnResized(newResized));
  };

  hideUnderScheduledWOModal = value => {
    const { filterSingleWO, viewSelectionChanged } = this.props;
    const selectedWO = unScheduledDurationService.getWOInfo();
    const dispatchStatus = selectedWO[WO_DISPATCH_STATUS_FIELD];
    const { Id, Name } = selectedWO;
    if (value === SHOW_PROJECT_VIEW) {
      filterSingleWO(Name, true, Id);
    } else if (value === LIST_WO) {
      filterSingleWO(Name, false, Id);
    } else if (value === DO_NOTHING) {
      const isSET010 = JSON.parse(getSettingValue(SET010, FALSE).toLowerCase());
      const isSET056 = JSON.parse(getSettingValue(SET056, FALSE).toLowerCase());

      if (isSET056) {
        viewSelectionChanged(undefined, true);
      } else if (dispatchStatus && dispatchStatus !== ASSIGNED && isSET010) {
        viewSelectionChanged(undefined, true);
      }
    }
    this.setState({ isUnderScheduledWO: false });
  };

  hideViolationViewModal = () => {
    this.setState({ isViloationScheduledWO: false });
  };

  componentWillReceiveProps(nextProps) {
    const {
      eventCreationCompleted,
      removeUnAssignWO,
      underScheduledEvent
    } = this.props;
    const { gridState, WOUnAssigned, addWOtoGrid } = nextProps;
    const { row, updateWOGridRow, woUnderScheduled } = gridState;

    if (woUnderScheduled) {
      underScheduledEvent(false);
      if (WOUnAssigned) {
        this.underScheduleWO(WOUnAssigned.woInfo);
      } else {
        const editedWoInfo = unScheduledDurationService.getWOInfo();
        this.underScheduleWO(editedWoInfo);
      }
      removeUnAssignWO(null);
    }

    if (updateWOGridRow && updateWOGridRow.value && updateWOGridRow.woObj) {
      const obj = {};
      obj.value = false;
      obj.woObj = null;
      eventCreationCompleted(obj);
    }

    if (addWOtoGrid) {
      const { filterSingleWO } = this.props;
      const { WOId, name } = addWOtoGrid;
      filterSingleWO(name, false, WOId);
    }

    const { rowSelected } = this.state;
    if (row && row.Id !== rowSelected) {
      this.setState({ rowSelected: row.Id });
    }
  }

  render() {
    const {
      columns,
      data,
      menuOptions,
      hoverColor,
      pages,
      gridState,
      pageSelectionChanged,
      sorted,
      sortOrderChanged
    } = this.props;
    const {
      displayText,
      isUnAssign,
      isUnderScheduledWO,
      isViloationScheduledWO
    } = this.state;
    const { page, row } = gridState;
    columns[0] = this.customizeWOColumn(columns, menuOptions);

    const gridProps = {
      className: "GridView",
      columns,
      data,
      hasColumnBorder: true,
      hasFixedColumns: true,
      hasFixedHeader: false,
      hasRowHover: true,
      hasCustomRowColors: true,
      hasRowClick: true,
      isStriped: false,
      manual: true,
      onResizedChange: this.onColumnResize,
      onFetchData: (state, instance) => {
        const { gridInitialized } = this.state;
        if (gridInitialized) {
          // const { sorted: prevSorted } = gridState;
          const { page: nextPage, sorted: prevSorted } = state;
          const { sorted: nextSorted } = instance.state;

          const pageChanged = gridProps.page !== nextPage;
          if (pageChanged) {
            pageSelectionChanged(nextPage);
          }

          const sortChanged = !isEqual(prevSorted[0], nextSorted[0]);
          if (sortChanged) {
            sortOrderChanged(nextSorted[0]);
          }
        }
        if (!gridInitialized) {
          this.setState({ gridInitialized: true });
        }
      },
      page: page || 0,
      pages: parseInt(pages) || 1,
      resizable: true,
      showPageJump: parseInt(pages) > 0,
      showPageSizeOptions: false,
      showPagination: true,
      sortable: true,
      sorted: [sorted]
    };

    const gridHoverColor = convertUint2Hex(hoverColor);
    const cssStyles = gridHoverColor
      ? { "--DataGrid-row-highlight-color": `${gridHoverColor}` }
      : null;

    return (
      <div className="GridView__DataGrid">
        <DataGrid
          className="-highlight DataGrid__list-view"
          {...gridProps}
          getTrProps={(state, rowInfo) => this.handleTRProps(rowInfo, data)}
          style={cssStyles}
        />
        {isUnderScheduledWO && (
          <UnderScheduledWOModal
            isOpen={isUnderScheduledWO}
            onClose={this.hideUnderScheduledWOModal}
          />
        )}
        {isViloationScheduledWO && (
          <ViolationStatusModal
            isOpen={isViloationScheduledWO}
            onClose={this.hideViolationViewModal}
            violationMsg={violationStatusMsg}
          />
        )}
        {isUnAssign && (
          <Modal
            size="small"
            isOpen={isUnAssign}
            onClose={() => this.setState({ isUnAssign: false })}
          >
            <ModalHeader title={getDisplayValue("TAG183")} />
            <ModalContent className="GridView__unAssignContent">
              <Container>
                <span>{getDisplayValue(displayText)}</span>
                {displayText === TAG167 && <span>{` - ${row.Name} ?`}</span>}
              </Container>
            </ModalContent>
            <ModalFooter>
              {displayText === TAG167 && (
                <Button
                  type="brand"
                  label={getDisplayValue("TAG240")}
                  onClick={() => this.handleUnassignConfirmation("yes")}
                />
              )}
              <Button
                type="brand"
                label={
                  displayText === TAG167
                    ? getDisplayValue("TAG241")
                    : getDisplayValue(TAG069)
                }
                onClick={() => this.handleUnassignConfirmation("no")}
              />
            </ModalFooter>
          </Modal>
        )}
      </div>
    );
  }
}

export default GridView;
