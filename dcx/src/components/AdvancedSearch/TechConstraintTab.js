import React, { Component } from "react";
import { PropTypes } from "prop-types";
import {
  Button,
  ButtonGroup,
  Checkbox,
  DataGridWithSelection,
  DuelingPicklist,
  Grid,
  GridRow,
  GridItem,
  Icon,
  Radio
} from "@svmx/ui-components-lightning";
import { orderBy, cloneDeep } from "lodash";
import {
  DEFAULT_SORT_ORDER,
  PREFERRED_TECH_ENABLED,
  PREFERRED_TECH_LIST
} from "constants/AppConstants";
import {
  TAG390,
  TAG402,
  TAG451,
  TAG452,
  TAG455,
  TAG481
} from "constants/DisplayTagConstants";
import { getDisplayValue } from "utils/DCUtils";

const NAME = "name";
const MANDATORY = "Mandatory";
const PREFERRED = "Preferred";
const PROHIBITED = "Prohibited";

class TechConstraintTab extends Component {
  constructor(props) {
    super(props);
    const { atsPrefTech } = this.props;
    const { search: isChecked } = atsPrefTech;
    this.state = {
      isChecked: JSON.parse(isChecked),
      sourceItems: [],
      targetRows: {},
      targetValues: [],
      technicianMap: {}
    };
  }

  componentWillMount() {
    let sourceItems = [];
    const targetValues = [];
    const technicianMap = {};
    const prefferedTechMap = {};
    const { lstCandidatePrefTechId = [], technicians } = this.props;
    lstCandidatePrefTechId.map(prefTechnician => {
      const { key, value } = prefTechnician;
      if (technicians[key]) {
        targetValues.push(key);
        prefferedTechMap[key] = value;
      }
      return undefined;
    });
    Object.values(technicians).map(technician => {
      const { technician_O: techObject } = technician;
      const { Id, Name } = techObject;
      const value = prefferedTechMap[Id] || PREFERRED;
      const obj = {
        id: Id,
        name: Name,
        value
      };
      technicianMap[Id] = obj;
      return undefined;
    });

    const targetRows = {};
    const { isChecked } = this.state;
    const { updateATSState } = this.props;
    sourceItems = orderBy(
      Object.values(technicianMap),
      [NAME],
      [DEFAULT_SORT_ORDER]
    );
    if (updateATSState) {
      Object.keys(prefferedTechMap).map(prefTechnician => {
        targetRows[prefTechnician] = cloneDeep(technicianMap[prefTechnician]);
      });
      updateATSState({
        [PREFERRED_TECH_ENABLED]: isChecked,
        [PREFERRED_TECH_LIST]: Object.values(targetRows)
      });
    }
    this.setState({
      sourceItems,
      targetRows,
      targetValues,
      technicianMap
    });
  }

  handleIncludeInSearch = data => {
    const { isChecked } = data;
    const { updateATSState } = this.props;
    if (updateATSState) {
      const changed = { adv_atsPrefTech: { search: isChecked } };
      setTimeout(
        () => updateATSState({ changed, [PREFERRED_TECH_ENABLED]: isChecked }),
        0
      );
    }
    this.setState({ isChecked });
  };

  handleTargetValuesChange = ({ targetValues }) => {
    const { updateATSState } = this.props;
    const { targetRows, technicianMap } = this.state;
    const newTargetRows = {};
    if (updateATSState) {
      targetValues.map(targetValue => {
        let targetObject = targetRows[targetValue];
        if (!targetObject) {
          targetObject = cloneDeep(technicianMap[targetValue]);
          targetObject.value = PREFERRED;
        }
        newTargetRows[targetValue] = targetObject;
        return undefined;
      });
      updateATSState({ [PREFERRED_TECH_LIST]: Object.values(newTargetRows) });
    }
    this.setState({ targetRows: newTargetRows, targetValues });
  };

  removeAll = () => {
    const { updateATSState } = this.props;
    if (updateATSState) {
      updateATSState({ [PREFERRED_TECH_LIST]: [] });
    }
    this.setState({ targetRows: {}, targetValues: [] });
  };

  handleCheckedChange = (row, value) => {
    const { original } = row;
    const { targetRows, targetValues } = this.state;
    const { id } = original;
    const record = targetRows[id];
    if (record) {
      record.value = value;
    }
    this.setState({ targetRows, targetValues });
  };

  getTechnicianColumns = () => [
    { accessor: "name", Header: getDisplayValue(TAG402) },
    {
      accessor: "mandatory",
      Cell: row => {
        const { original } = row;
        const { id } = original;
        const { targetRows } = this.state;
        const record = targetRows[id];
        const value = (record && record.value) || PREFERRED;
        return (
          <Radio
            name={id}
            value={value}
            isChecked={value === MANDATORY}
            onCheckedChange={() => this.handleCheckedChange(row, MANDATORY)}
          />
        );
      },
      className: "DataGridWithSelection__input-cell",
      Header: getDisplayValue(TAG455),
      headerClassName: "DataGridWithSelection__select-all",
      resizable: false,
      sortable: false,
      width: 160
    },
    {
      accessor: "preferred",
      Cell: row => {
        const { original } = row;
        const { id } = original;
        const { targetRows } = this.state;
        const record = targetRows[id];
        const value = (record && record.value) || PREFERRED;
        return (
          <Radio
            name={id}
            value={value}
            isChecked={value === PREFERRED}
            onCheckedChange={() => this.handleCheckedChange(row, PREFERRED)}
          />
        );
      },
      className: "DataGridWithSelection__input-cell",
      Header: getDisplayValue(TAG451),
      headerClassName: "DataGridWithSelection__select-all",
      resizable: false,
      sortable: false,
      width: 160
    },
    {
      accessor: "prohibited",
      Cell: row => {
        const { original } = row;
        const { id } = original;
        const { targetRows } = this.state;
        const record = targetRows[id];
        const value = (record && record.value) || PREFERRED;
        return (
          <Radio
            name={id}
            value={value}
            isChecked={value === PROHIBITED}
            onCheckedChange={() => this.handleCheckedChange(row, PROHIBITED)}
          />
        );
      },
      className: "DataGridWithSelection__input-cell",
      Header: getDisplayValue(TAG452),
      headerClassName: "DataGridWithSelection__select-all",
      resizable: false,
      sortable: false,
      width: 160
    }
  ];

  render() {
    const { isChecked, sourceItems, targetValues } = this.state;
    return (
      <Grid className="AdvancedSearch__Grid" isVertical>
        <GridRow className="AdvancedSearch__Grid-title">
          <GridItem noFlex>
            <Checkbox
              isChecked={isChecked}
              onCheckedChange={event => this.handleIncludeInSearch(event)}
              name={getDisplayValue(TAG390)}
            >
              {getDisplayValue(TAG390)}
            </Checkbox>
          </GridItem>
          <GridItem />
          <GridItem noFlex>
            <ButtonGroup>
              <Button
                isDisabled={!targetValues.length}
                type="neutral"
                onClick={() => this.removeAll()}
              >
                <Icon icon="delete" align="left" size="x-small" />
                {getDisplayValue(TAG481)}
              </Button>
            </ButtonGroup>
          </GridItem>
        </GridRow>
        <GridRow>
          <GridItem>
            <DuelingPicklist
              allowOrdering={false}
              hasSourceFilter
              itemDisplayKey="name"
              itemValueKey="id"
              name="tech-constraint-dueling-picklist"
              onTargetValuesChange={this.handleTargetValuesChange}
              selectMode="multi"
              sourceItems={sourceItems}
              // sourceLabel={getDisplayValue(TAG482)}
              targetValues={targetValues}
              // targetLabel={getDisplayValue(TAG402)}
              targetNodeCustom={
                <DataGridWithSelection
                  className="-bordered"
                  columns={this.getTechnicianColumns()}
                  showPagination={false}
                  sortable
                />
              }
            />
          </GridItem>
        </GridRow>
      </Grid>
    );
  }
}

TechConstraintTab.propTypes = {
  atsPrefTech: PropTypes.shape({}).isRequired,
  lstCandidatePrefTechId: PropTypes.arrayOf(PropTypes.Object),
  technicians: PropTypes.arrayOf(PropTypes.Object),
  updateATSState: PropTypes.func.isRequired,
  updateUserSetting: PropTypes.func.isRequired
};

TechConstraintTab.defaultProps = {
  lstCandidatePrefTechId: [],
  technicians: []
};

export default TechConstraintTab;
