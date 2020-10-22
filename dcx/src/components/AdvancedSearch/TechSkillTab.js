import React, { Component } from "react";
import { PropTypes } from "prop-types";
import { cloneDeep } from "lodash";
import {
  Checkbox,
  ButtonGroup,
  Button,
  DataGridWithSelection,
  DuelingPicklist,
  Icon,
  InlineEdit,
  Input,
  InputWrapper,
  Grid,
  GridRow,
  GridItem,
  Text
} from "@svmx/ui-components-lightning";
import {
  TAG390,
  TAG400,
  TAG401,
  TAG481,
  TAG499
} from "constants/DisplayTagConstants";
import { getDisplayValue } from "utils/DCUtils";
import { LST_SKILL, SKILLS_ENABLED } from "constants/AppConstants";

class TechSkillTab extends Component {
  constructor(props) {
    super(props);
    const { atsSkills } = this.props;
    const { search: isChecked } = atsSkills;
    this.state = {
      isChecked: JSON.parse(isChecked),
      targetRows: {},
      targetValues: [],
      technicianSkills: {}
    };
    this.skillEditState = {};
  }

  componentWillMount() {
    const targetRows = {};
    const technicianSkills = {};
    const { lstskill = [], techSkills = [], updateATSState } = this.props;
    techSkills.map(techSkill => {
      const { skillId } = techSkill;
      if (!technicianSkills[skillId]) {
        technicianSkills[skillId] = techSkill;
      }
      return undefined;
    });

    // Include only skills that are available list.
    lstskill.map(techSkill => {
      const { skillId } = techSkill;
      if (technicianSkills[skillId]) {
        targetRows[skillId] = cloneDeep(techSkill);
      }
      return undefined;
    });

    const { isChecked } = this.state;
    if (updateATSState) {
      updateATSState({
        [LST_SKILL]: Object.values(targetRows),
        [SKILLS_ENABLED]: isChecked
      });
    }
    this.setState({
      targetRows,
      targetValues: Object.keys(targetRows),
      technicianSkills
    });
  }

  handleCheckedChange = (row, { isChecked }) => {
    const { original } = row;
    const { targetValues, targetRows } = this.state;
    const { skillId } = original;
    const record = targetRows[skillId];
    if (record) {
      record.isSkillMandatory = isChecked;
      // In case of Skill is not mandatory, clear the Skill level
      if (!isChecked) {
        record.skillLevel = null;
      }
    }
    this.setState({ targetRows, targetValues });
  };

  handleTargetValuesChange = ({ targetValues }) => {
    const newTargetRows = {};
    const { updateATSState } = this.props;
    const { targetRows, technicianSkills } = this.state;
    if (updateATSState) {
      targetValues.map(targetValue => {
        let targetObject = targetRows[targetValue];
        if (!targetObject) {
          targetObject = cloneDeep(technicianSkills[targetValue]);
          targetObject.isSkillMandatory = false;
        }
        newTargetRows[targetValue] = targetObject;
        return undefined;
      });
      updateATSState({ [LST_SKILL]: Object.values(newTargetRows) });
    }
    this.setState({ targetRows: newTargetRows, targetValues });
  };

  handleIncludeInSearch = data => {
    const { isChecked } = data;
    const { updateATSState } = this.props;
    if (updateATSState) {
      const changed = { adv_atsSkills: { search: isChecked } };
      setTimeout(
        () => updateATSState({ changed, [SKILLS_ENABLED]: isChecked }),
        0
      );
    }
    this.setState({ isChecked });
  };

  removeAll = () => {
    const { updateATSState } = this.props;
    if (updateATSState) {
      updateATSState({ [LST_SKILL]: [] });
    }
    this.setState({ targetRows: {}, targetValues: [] });
  };

  handleValueChange = ({ value }, row) => {
    const { original } = row;
    const { skillId } = original;
    const { targetRows, targetValues } = this.state;
    const record = targetRows[skillId];
    if (record) {
      record.skillLevel = value.trim() || null;
    }
    if (!this.skillEditState[skillId]) {
      this.skillEditState[skillId] = true;
    }
    this.setState({ targetRows, targetValues });
  };

  handleOnBlur = skillId => {
    const { targetRows, targetValues } = this.state;
    delete this.skillEditState[skillId];
    this.setState({ targetRows, targetValues });
  };

  getSkillColumns = () => [
    { accessor: "skillName", Header: getDisplayValue(TAG499, "Skill Name") },
    {
      accessor: "isSkillMandatory",
      Cell: row => {
        const { original } = row;
        const { skillId } = original;
        const { targetRows } = this.state;
        const record = targetRows[skillId];
        return (
          <Checkbox
            isChecked={record && record.isSkillMandatory}
            name="my-checkbox"
            value="1"
            onCheckedChange={event => this.handleCheckedChange(row, event)}
          />
        );
      },
      width: 150,
      Header: getDisplayValue(TAG400)
    },
    {
      accessor: "skillLevel",
      Cell: row => {
        const { original } = row;
        const { targetRows } = this.state;
        const record = targetRows[original.skillId];
        const { skillId, skillName, skillLevel, isSkillMandatory } =
          record || original;
        return (
          <div>
            {!isSkillMandatory && (
              <InputWrapper size="xx-small">
                <Input
                  name={skillName}
                  inputType="text"
                  isReadOnly
                  value={skillLevel}
                />
              </InputWrapper>
            )}
            {isSkillMandatory && (
              <InlineEdit
                name={skillName}
                isEditing={isSkillMandatory && this.skillEditState[skillId]}
                onValueChange={data => this.handleValueChange(data, row)}
                onBlur={() => this.handleOnBlur(skillId)}
                value={skillLevel}
              >
                <Text>{skillLevel}</Text>
              </InlineEdit>
            )}
          </div>
        );
      },
      width: 200,
      Header: getDisplayValue(TAG401)
    }
  ];

  render() {
    const { isChecked, targetValues, technicianSkills } = this.state;
    const sourceItems = Object.values(technicianSkills);
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
              itemDisplayKey="skillName"
              itemValueKey="skillId"
              name="skill-dueling-picklist"
              onTargetValuesChange={this.handleTargetValuesChange}
              selectMode="multi"
              sourceItems={sourceItems}
              // sourceLabel={getDisplayValue(TAG027)}
              targetValues={targetValues}
              // targetLabel={getDisplayValue(TAG399)}
              targetNodeCustom={
                <DataGridWithSelection
                  className="-bordered"
                  columns={this.getSkillColumns()}
                  showPagination={false}
                  hasRowClick={false}
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

TechSkillTab.propTypes = {
  atsSkills: PropTypes.shape({}).isRequired,
  lstskill: PropTypes.arrayOf(PropTypes.Object),
  techSkills: PropTypes.arrayOf(PropTypes.Object),
  updateATSState: PropTypes.func.isRequired
};

TechSkillTab.defaultProps = {
  lstskill: [],
  techSkills: []
};

export default TechSkillTab;
