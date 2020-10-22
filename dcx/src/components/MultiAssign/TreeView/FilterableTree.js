import React, { useState } from "react";
import PropTypes from "prop-types";
import { debounce, flatMap } from "lodash";
import { Tree, Search, Spinner } from "@svmx/ui-components-lightning";

import "./FilterableTree.scss";

const FilterableTree = props => {
  const {
    data,
    error,
    filtering,
    placeholder,
    expandOnSearch,
    onBranchClick,
    onBranchToggle,
    onLeafSelect,
    selectedValues,
    expandedValues,
    onSearchRequest
  } = props;

  const performFilter = keyword => {
    onSearchRequest(keyword);
  };

  const onValueChange = ({ value }) => {
    if (filter !== value && (!value || value.length >= 2)) {
      debouncedFn(value);
      setFilter(value);
    }
  };

  const [filter, setFilter] = useState(null);
  const debouncedFn = debounce(search => performFilter(search), 300);

  return (
    <div className="FilterableTree">
      <Search
        className="Tree__filter--search"
        name="Technician Tree Search"
        value={filter}
        placeholder={placeholder}
        onValueChange={onValueChange}
      />
      {!filtering && (
        <div className="FilterableTree__View">
          {error && (
            <div className="FilterableTree__Error">
              <div>{error.message}</div>
            </div>
          )}
          {!error && (
            <Tree
              className="FilterableTree__View--root"
              data={data}
              displayKey="Name"
              valueKey="Id"
              childrenKey="children"
              iconKey="icon"
              iconCategoryKey="icon_category"
              onBranchClick={onBranchClick}
              onBranchToggle={onBranchToggle}
              onLeafSelect={onLeafSelect}
              selectedValues={selectedValues}
              expandedValues={
                filter
                  ? expandOnSearch
                    ? flatMap(data, node => node.Id)
                    : []
                  : expandedValues || []
              }
            />
          )}
        </div>
      )}
      {filtering && (
        <Spinner className="FilterableTree__Filtering" size="medium" />
      )}
    </div>
  );
};

FilterableTree.defaultProps = {
  filtering: false,
  selectedValues: [],
  expandOnSearch: true
};

FilterableTree.propTypes = {
  onLeafSelect: PropTypes.func,
  onBranchClick: PropTypes.func,
  onBranchToggle: PropTypes.func,
  expandOnSearch: PropTypes.bool,

  filtering: PropTypes.bool,
  selectedValues: PropTypes.arrayOf(String),
  onSearchRequest: PropTypes.func.isRequired
};

export default FilterableTree;
