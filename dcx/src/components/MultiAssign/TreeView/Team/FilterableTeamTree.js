import React, { useState } from "react";
import PropTypes from "prop-types";
import { compact, flatMap } from "lodash";
import { TECH_KEYWORD, TERRITORY_API_NAME } from "constants/AppConstants";
import { getFieldValue, getUserSetting } from "utils/DCUtils";
import { sortTeamTerrirtoyBySequence } from "utils/SchedulerUtils";
import {
  TECH_TEAM_SEQUENCE,
  TECH_SEARCH_KEYWORD,
  TECH_TERRITORY_SEQUENCE
} from "constants/UserSettingConstants";
import FilterableTree from "../FilterableTree";

const FilterableTeamTree = props => {
  const {
    techFields,
    userSettings,
    expandOnSearch,
    leafSelectionOnly,
    onSelection,
    teamView,
    territoryView,
    selectedValues,
    expandedValues,
    searchTechnicians
  } = props;

  const buildTree = () => {
    const sequence = getUserSetting(
      territoryView ? TECH_TERRITORY_SEQUENCE : TECH_TEAM_SEQUENCE,
      []
    );
    return sortTeamTerrirtoyBySequence(territoryView || teamView, sequence);
  };

  const getPlaceHolder = () => {
    const techSearchCfg = getFieldValue(userSettings, TECH_SEARCH_KEYWORD, {});
    const { col: techColumns = [] } = techSearchCfg || {};
    return compact(
      flatMap(techColumns, column => {
        const { name } = column;
        const fieldDesc = techFields[name];
        if (fieldDesc) {
          const { display } = fieldDesc;
          return display;
        }
        return null;
      })
    ).join();
  };

  const onBranchToggle = (event, node) => {
    // const { isOpen, value } = node;
    // if (isOpen && !leafSelectionOnly) {
    //   onSelection(teamIdTechMap[value]);
    // }
  };

  const getAllTechnicians = (treeNode, target) => {
    const { children = [] } = treeNode;
    if (treeNode && treeNode[TERRITORY_API_NAME]) {
      target.push(treeNode);
      return;
    }

    children.map(item => {
      getAllTechnicians(item, target);
      return undefined;
    });
  };

  const getSelectedBranch = (treeNode, target) => {
    const { children = [] } = treeNode;
    if (treeNode && treeNode.Id === target) {
      return treeNode;
    }

    children.forEach(item => {
      const node = getSelectedBranch(item, target);
      if (node) {
        return;
      }
    });
  };

  const onBranchClick = (event, node) => {
    const { value } = node;
    if (!leafSelectionOnly) {
      const rootNode = filter ? filteredTree : defaultTree;
      const branchNodes = rootNode.filter(node => node.Id === value);
      if (branchNodes.length) {
        const [branchNode] = branchNodes;
        let { children } = branchNode;
        // In case of territory, return all the tech from sub territory.
        if (territoryView) {
          children = [];
          getAllTechnicians(branchNode, children);
        }
        onSelection(children || []);
      } else {
        let selectedBranch = null;
        rootNode.forEach(node => {
          const { children } = node;
          const childNodes = children.filter(childNode => !childNode.isTech);
          childNodes.forEach(childNode => {
            selectedBranch = getSelectedBranch(childNode, value);
            if (selectedBranch) {
              return;
            }
          });
          if (selectedBranch) {
            return;
          }
        });
        if (selectedBranch) {
          let children = [];
          getAllTechnicians(selectedBranch, children);
          onSelection(children || []);
        }
      }
    }
    return false;
  };

  const onLeafSelect = (event, node) => {
    const { data } = node;
    const { item } = data;
    const { children = [] } = item;
    onSelection(item.isTech ? [item] : children);
  };

  const onSearchRequest = keyword => {
    if (!keyword) {
      setFiltering(true);
      if (error) {
        setError(null);
      }
      setFilter(null);
      setFilteredTree(null);
      setFiltering(false);
      return;
    }

    const successCb = content => {
      // clear error on success
      if (error) {
        setError(null);
      }

      const { teamView: teamTree, territoryView: territoryTree } = content;
      const resultTree = territoryView ? territoryTree : teamTree;
      const sequence = getUserSetting(
        territoryView ? TECH_TERRITORY_SEQUENCE : TECH_TEAM_SEQUENCE,
        []
      );

      setFilteredTree(sortTeamTerrirtoyBySequence(resultTree, sequence));
      setFilter(keyword);
      setFiltering(false);
    };

    const failureCb = error => {
      setError(error);
      setFiltering(false);
    };

    if (searchTechnicians) {
      setFiltering(true);
      searchTechnicians({
        keyword,
        successCb,
        failureCb,
        findWhat: TECH_KEYWORD
      });
    }
  };

  const [error, setError] = useState(null);
  const [filter, setFilter] = useState(null);

  const [filtering, setFiltering] = useState(false);
  const [filteredTree, setFilteredTree] = useState(null);

  const [defaultTree, setDefaultTree] = useState(buildTree());
  const [placeholder, setPlaceholder] = useState(getPlaceHolder());

  return (
    <FilterableTree
      error={error}
      filtering={filtering}
      placeholder={placeholder}
      onSelection={onSelection}
      onLeafSelect={onLeafSelect}
      onBranchClick={onBranchClick}
      onBranchToggle={onBranchToggle}
      selectedValues={selectedValues}
      expandedValues={expandedValues}
      expandOnSearch={expandOnSearch}
      onSearchRequest={onSearchRequest}
      data={filter ? filteredTree : defaultTree}
    />
  );
};

FilterableTeamTree.defaultProps = {
  filter: null,
  onExpandedValues: [],
  onSelectedValues: [],
  expandOnSearch: false,
  leafSelectionOnly: false
};

FilterableTeamTree.propTypes = {
  filter: PropTypes.string,
  expandOnSearch: PropTypes.bool,
  leafSelectionOnly: PropTypes.bool,
  onSelection: PropTypes.func.isRequired
};

export default FilterableTeamTree;
