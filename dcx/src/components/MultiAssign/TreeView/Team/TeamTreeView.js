import React, { useState, useEffect } from "react";
import PropTypes from "prop-types";
import { Tree } from "@svmx/ui-components-lightning";
import { NAME, TEAM_API_REF } from "constants/AppConstants";
import { getFieldValue, setFieldValue, getUserSetting } from "utils/DCUtils";
import { sortTeamTerrirtoyBySequence } from "utils/SchedulerUtils";
import { TECH_TEAM_SEQUENCE } from "constants/UserSettingConstants";
import { orderBy } from "lodash";
import { getDisplayValue } from "utils/DCUtils";
import { TAG457 } from "constants/DisplayTagConstants";

const TeamTreeView = props => {
  const {
    teamIds = [],
    teamView = [],
    technicians = [],
    onSelection,
    showSearchTree,
    leafSelectionOnly,
    onSelectedValues = [],
    onExpandedValues = []
  } = props;

  const buildTree = () => {
    if (showSearchTree) {
      return sortTeamTerrirtoyBySequence(
        teamView,
        getUserSetting(TECH_TEAM_SEQUENCE, [])
      );
    }

    const teamNameIdMap = {};
    const teamIdTechMap = {};
    const ignoredTechnicians = [];

    technicians.map(technician => {
      const { technician_O: techObj } = technician;
      const teamRefObj = getFieldValue(techObj, TEAM_API_REF);
      const { Id, Name } = teamRefObj;
      const found = teamIds.includes(Id);
      if (found) {
        if (!teamNameIdMap[Id]) {
          teamNameIdMap[Id] = Name;
        }
        let techArray = teamIdTechMap[Id];
        if (!techArray) {
          teamIdTechMap[Id] = techArray = [];
        }
        setFieldValue(techObj, "icon", "user");
        setFieldValue(techObj, "icon_category", "utility");
        techArray.push(techObj);
      } else {
        ignoredTechnicians.push(technician);
      }
      return undefined;
    });

    const rootNodes = [];
    Object.keys(teamIdTechMap).map(teamId => {
      const Name = teamNameIdMap[teamId];
      const children = orderBy(teamIdTechMap[teamId], [NAME]);
      const team = {
        children,
        Id: teamId,
        Name
      };
      rootNodes.push(team);
      return undefined;
    });
    return sortTeamTerrirtoyBySequence(
      rootNodes,
      getUserSetting(TECH_TEAM_SEQUENCE, [])
    );
  };

  const onBranchToggle = (event, node) => {
    // const { isOpen, value } = node;
    // if (isOpen && !leafSelectionOnly) {
    //   onSelection(teamIdTechMap[value]);
    // }
  };

  const onBranchClick = (event, node) => {
    const { value } = node;
    if (!leafSelectionOnly) {
      // onSelection(teamIdTechMap[value]);
      const branchNodes = tree.filter(node => node.Id === value);
      if (branchNodes.length) {
        const [branchNode] = branchNodes;
        let { children } = branchNode;
        onSelection(children || []);
      }
    }
    return false;
  };

  const onLeafSelect = (event, node) => {
    const { data } = node;
    const { item } = data;
    onSelection([item]);
  };

  const [tree, setTree] = useState(buildTree());

  return (
    <Tree
      data={tree}
      displayKey="Name"
      valueKey="Id"
      childrenKey="children"
      iconKey="icon"
      iconCategoryKey="icon_category"
      isFilterable={!showSearchTree}
      onBranchClick={onBranchClick}
      onBranchToggle={onBranchToggle}
      onLeafSelect={onLeafSelect}
      selectedValues={onSelectedValues}
      expandedValues={onExpandedValues}
      filterProps={{
        minChar: 3,
        placeholder: getDisplayValue(TAG457),
        waitTime: 300
      }}
    />
  );
};

TeamTreeView.defaultProps = {
  leafSelectionOnly: false,
  onExpandedValues: [],
  onSelectedValues: []
};

TeamTreeView.propTypes = {
  leafSelectionOnly: PropTypes.bool,
  onExpandedValues: PropTypes.arrayOf(String),
  onSelectedValues: PropTypes.arrayOf(String),
  onSelection: PropTypes.func.isRequired,
  teamIds: PropTypes.arrayOf(String).isRequired,
  technicians: PropTypes.shape({}).isRequired
};

export default TeamTreeView;
