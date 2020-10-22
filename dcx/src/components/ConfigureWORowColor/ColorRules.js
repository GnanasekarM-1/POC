import React, { Component } from "react";
import { PropTypes } from "prop-types";
import { pullAllBy, isEqual } from "lodash";
import {
  Badge,
  DataGrid,
  Icon,
  Label,
  Grid,
  GridRow,
  GridItem
} from "@svmx/ui-components-lightning";
import { convertUint2Hex, getDisplayValue } from "utils/DCUtils";
import {
  TAG072,
  TAG075,
  TAG188,
  TAG191,
  TAG387
} from "constants/DisplayTagConstants";
import { EVENT_EXP_TYPE } from "constants/AppConstants";
import ActivityModalService from "components/Modals/ActivityModal/ActivityModalService";
import ConfTechViewService from "components/Modals/ConfTechViewModal/ConfTechViewService";
import createEmptyRule from "utils/EmptyRuleUtils";
import NewColorRule from "./NewColorRule1";
import "./ConfigureWORowColor.scss";

const propTypes = {
  colorRules: PropTypes.arrayOf(PropTypes.object),
  onConfigurationChange: PropTypes.func,
  ruleType: PropTypes.string,
  sourceItems: PropTypes.arrayOf(PropTypes.object)
};

const defaultProps = {
  colorRules: [],
  onConfigurationChange: () => {},
  ruleType: "WO Rule",
  sourceItems: []
};

class ColorRules extends Component {
  constructor(props) {
    super(props);
    const { sourceItems } = props;
    const [sourceItem] = sourceItems || [];
    const { key, value } = sourceItem || {};
    this.state = {
      colorRules: props.colorRules,
      forceUpdate: false,
      rowSelected: -1,
      rule: createEmptyRule(props.ruleType, value || key)
    };
  }

  componentDidMount = () => {
    const { colorRules = [], getDeleteRef, sourceItems = [] } = this.props;
    getDeleteRef(this.deleteGridRow);

    const pickListMetaMap = {};
    const eventFieldMetaMap = {};
    sourceItems.map(sourceItem => {
      const { key, value, type } = sourceItem;
      if (type !== EVENT_EXP_TYPE) {
        pickListMetaMap[value] = sourceItem;
      } else {
        eventFieldMetaMap[key] = sourceItem;
      }
      return undefined;
    });

    colorRules.map(colorRule => {
      const { operand = [] } = colorRule;
      const deleteExpn = [];
      operand.map(expn => {
        const { property } = expn;
        if (!pickListMetaMap[property] && !eventFieldMetaMap[property]) {
          deleteExpn.push(expn);
        }
        return undefined;
      });
      // Delete all the experssions with deleted field Names.
      if (deleteExpn.length) {
        pullAllBy(operand, deleteExpn, "property");
      }
      return undefined;
    });
  };

  shouldComponentUpdate(nextProps, nextState) {
    const { forceUpdate, rowSelected } = this.state;
    const { colorRules: colorRulesProps } = nextProps;
    const {
      colorRules: colorRulesState,
      forceUpdate: forceUpdateNextState,
      rowSelected: rowSelectedNextState
    } = nextState;
    return (
      !isEqual(rowSelected, rowSelectedNextState) ||
      !isEqual(colorRulesState, colorRulesProps) ||
      !isEqual(forceUpdate, forceUpdateNextState)
    );
  }

  handleAddRule = () => {
    const { rowSelected } = this.state;
    const { ruleType, onConfigurationChange, sourceItems } = this.props;
    const [sourceItem] = sourceItems || [];
    const { key, value } = sourceItem || {};
    const newRule = createEmptyRule(ruleType, value || key);
    this.setState({ rowSelected: -1, rule: newRule });
    if (rowSelected === -1) {
      this.setState({ forceUpdate: true }, () => {
        this.setState({ forceUpdate: false });
      });
    }
    if (!Number.isNaN(ActivityModalService.getActiveRuleIndex())) {
      ActivityModalService.setModifiedOperands(null);
    } else if (!Number.isNaN(ConfTechViewService.getActiveRuleIndex())) {
      ConfTechViewService.setModifiedOperands(null);
    }
    onConfigurationChange(null, -1);
  };

  onGridRowClick = rowInfo => {
    const { onConfigurationChange } = this.props;
    this.setState(
      {
        rowSelected: rowInfo.index,
        rule: rowInfo.original
      },
      onConfigurationChange(null, rowInfo.index)
    );

    if (!Number.isNaN(ActivityModalService.getActiveRuleIndex())) {
      ActivityModalService.setModifiedOperands(null);
    } else if (!Number.isNaN(ConfTechViewService.getActiveRuleIndex())) {
      ConfTechViewService.setModifiedOperands(null);
    }
  };

  deleteGridRow = row => {
    const { colorRules } = this.state;
    const { onConfigurationChange } = this.props;
    const { index } = row;
    const rules = [...colorRules];
    rules.splice(index, 1);
    this.setState({ colorRules: rules }, onConfigurationChange(rules, -1));
    // To check if this is Grid Rules or Event Rules
    if (!Number.isNaN(ActivityModalService.getActiveRuleIndex())) {
      ActivityModalService.setRulesAfterDeletion(rules);
    } else if (!Number.isNaN(ConfTechViewService.getActiveRuleIndex())) {
      ConfTechViewService.setRulesAfterDeletion(rules);
    }
    this.handleAddRule();
  };

  showDeleteConfirmation = (e, row) => {
    const { deleteConfirmation } = this.props;
    deleteConfirmation(row);
    e.stopPropagation();
  };

  handleModifiedRules = modifiedRules => {
    const { onConfigurationChange } = this.props;
    const { rowSelected } = this.state;
    onConfigurationChange(modifiedRules, rowSelected);
  };

  componentWillReceiveProps = ({ colorRules }) => {
    this.setState({ colorRules });
  };

  render() {
    const { rule, rowSelected, colorRules, forceUpdate } = this.state;
    const {
      formRef,
      onCustomValidationError,
      onSubmitSuccess,
      ruleType,
      sourceItems
    } = this.props;

    const columns = [
      { accessor: "name", Header: getDisplayValue(TAG072), width: 200 },
      {
        accessor: "status",
        className: "ColorRules__grid-column",
        Cell: row => <span>{getDisplayValue(row.original.status)}</span>,
        Header: getDisplayValue(TAG188),
        headerStyle: {
          justifyContent: "space-around"
        },
        style: {
          textAlign: "center"
        },
        width: 100
      },
      {
        accessor: "color",
        className: "ColorRules__grid-column",
        Cell: row => (
          <Badge
            allowMinWidth
            hasTooltip={false}
            icon="record"
            iconColor={convertUint2Hex(row.original.color)}
            iconSize="small"
            type="lightest"
          />
        ),
        Header: getDisplayValue(TAG075),
        headerStyle: {
          justifyContent: "space-around"
        },
        style: {
          textAlign: "center"
        },
        width: 100
      },
      {
        accessor: "",
        className: "ColorRules__grid-column",
        Cell: row => (
          <Icon
            className="ColorRules__deleteIcon"
            icon="delete"
            align="center"
            size="x-small"
            onClick={e => this.showDeleteConfirmation(e, row)}
          />
        ),
        Header: getDisplayValue(TAG191),
        headerStyle: {
          textAlign: "center"
        },
        sortable: false,
        style: {
          textAlign: "center"
        }
      }
    ];

    const gridData = colorRules;

    return (
      <Grid isVertical>
        <GridRow>
          <GridItem className="ColorRules__DataGrid" noFlex>
            <GridRow isVertical>
              <GridItem noFlex>
                <DataGrid
                  className="ColorRules__grid"
                  columns={columns}
                  data={gridData}
                  hasColumnBorder
                  hasRowBorder={false}
                  showPagination={false}
                  resizable
                  sortable
                  getTrProps={(state, rowInfo) => ({
                    className:
                      rowInfo && rowInfo.index === rowSelected
                        ? "ColorRules__grid--selected"
                        : "",
                    onClick: () => {
                      this.onGridRowClick(rowInfo);
                    }
                  })}
                />
              </GridItem>
            </GridRow>
            <GridRow>
              <GridItem noFlex>
                <Label
                  className="ColorRules__addRule"
                  onClick={this.handleAddRule}
                >
                  + {getDisplayValue(TAG387)}
                </Label>
              </GridItem>
            </GridRow>
          </GridItem>
          <GridItem className="ColorRules__Form" noFlex>
            <NewColorRule
              className="ColorRules__newColorRule"
              formRef={formRef}
              forceUpdate={forceUpdate}
              rule={rule}
              woRules={colorRules}
              ruleType={ruleType}
              sourceItems={sourceItems}
              onRulesModified={this.handleModifiedRules}
              onCustomValidationError={onCustomValidationError}
              onSubmitSuccess={onSubmitSuccess}
            />
          </GridItem>
        </GridRow>
      </Grid>
    );
  }
}

ColorRules.propTypes = propTypes;
ColorRules.defaultProps = defaultProps;

export default ColorRules;
