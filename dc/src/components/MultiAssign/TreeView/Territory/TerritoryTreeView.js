import React, { useState } from "react";
import PropTypes from "prop-types";
import { Tree } from "@svmx/ui-components-lightning";
import arrayToTree from "array-to-tree";
import { orderBy } from "lodash";
import {
  NAME,
  PARENT_TERRITORY_API_NAME,
  TERRITORY_API_NAME,
  TERRITORY_API_REF
} from "constants/AppConstants";
import { getFieldValue, setFieldValue, getUserSetting } from "utils/DCUtils";
import { sortTeamTerrirtoyBySequence } from "utils/SchedulerUtils";
import { TECH_TERRITORY_SEQUENCE } from "constants/UserSettingConstants";

const TerritoryTreeView = props => {
  const {
    showSearchTree,
    includeDescendants,
    onSelection,
    leafSelectionOnly,
    territoryView,
    territoryList = [],
    technicians = [],
    onSelectedValues = [],
    onExpandedValues = []
  } = props;

  const buildTree = () => {
    if (showSearchTree) {
      return sortTeamTerrirtoyBySequence(
        territoryView,
        getUserSetting(TECH_TERRITORY_SEQUENCE, [])
      );
    }
    const territoryIdObjMap = {};
    territoryList.map(territory => {
      const { Id } = territory;
      territoryIdObjMap[Id] = territory;
      return undefined;
    });

    const techArray = [];
    technicians.map(technician => {
      const { technician_O: techObj } = technician;
      const teamRefObj = getFieldValue(techObj, `${TERRITORY_API_REF}`);
      if (teamRefObj) {
        const { Id } = teamRefObj;
        const found = territoryIdObjMap[Id];
        if (found) {
          setFieldValue(techObj, "icon", "user");
          setFieldValue(techObj, "icon_category", "utility");
          setFieldValue(techObj, PARENT_TERRITORY_API_NAME, Id);
          techArray.push(techObj);
        }
      }
      return undefined;
    });

    const territoryArray = Object.values(territoryIdObjMap).concat(techArray);
    const result = arrayToTree(orderBy(territoryArray, [NAME]), {
      customID: "Id",
      parentProperty: PARENT_TERRITORY_API_NAME
    });
    return sortTeamTerrirtoyBySequence(
      result,
      getUserSetting(TECH_TERRITORY_SEQUENCE, [])
    );
  };

  const [tree, setTree] = useState(buildTree());
  const [expandedNodeMap, setExpandedNodeMap] = useState({});

  const addRemoveExpandedNode = (treeNode, isOpen) => {
    if (treeNode) {
      if (treeNode[TERRITORY_API_NAME]) {
        return;
      }

      const { children = [], Id } = treeNode;
      if (isOpen) {
        expandedNodeMap[Id] = treeNode;
      } else {
        delete expandedNodeMap[Id];
      }
      children.map(item => {
        addRemoveExpandedNode(item, isOpen);
        return undefined;
      });
    }
  };

  const expandCollapseTreeNode = node => {
    const { isOpen, value } = node;
    addRemoveExpandedNode(
      expandedNodeMap[value] || tree.find(item => item.Id === value),
      isOpen
    );
    setExpandedNodeMap({ ...expandedNodeMap });
  };

  const getAllTechniciansIds = (treeNode, target) => {
    const { children = [] } = treeNode;
    if (treeNode && treeNode[TERRITORY_API_NAME]) {
      target.push(treeNode);
      return;
    }

    children.map(item => {
      getAllTechniciansIds(item, target);
      return undefined;
    });
  };

  const getExpandedTechnicianIds = value => {
    const target = [];
    getAllTechniciansIds(expandedNodeMap[value], target);
    return target;
  };

  const onBranchToggle = (event, node) => {
    expandCollapseTreeNode(node);
  };

  const onBranchClick = (event, node) => {
    const { value } = node;
    expandCollapseTreeNode({ value, isOpen: true });
    if (includeDescendants) {
      const technicianIds = getExpandedTechnicianIds(value);
      if (!leafSelectionOnly) {
        onSelection(technicianIds);
      }
    }
    return false;
  };

  const onLeafSelect = (event, node) => {
    const children = [];
    const { data } = node;
    const { item } = data;
    if (item[TERRITORY_API_NAME]) {
      children.push(item);
    }
    onSelection(children);
  };

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
        placeholder: "Filter",
        waitTime: 300
      }}
    />
  );
};

TerritoryTreeView.defaultProps = {
  showSearchTree: false,
  includeDescendants: false,
  leafSelectionOnly: false,
  onExpandedValues: [],
  onSelectedValues: []
};

TerritoryTreeView.propTypes = {
  showSearchTree: PropTypes.bool,
  includeDescendants: PropTypes.bool,
  leafSelectionOnly: PropTypes.bool,
  onExpandedValues: PropTypes.arrayOf(String),
  onSelectedValues: PropTypes.arrayOf(String),
  onSelection: PropTypes.func.isRequired,
  technicians: PropTypes.shape({}).isRequired,
  territoryList: PropTypes.arrayOf(String).isRequired
};

export default TerritoryTreeView;
