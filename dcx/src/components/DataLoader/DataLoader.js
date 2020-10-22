import React from "react";
import PropTypes from "prop-types";

import "./DataLoader.scss";

const propTypes = {
  loader: PropTypes.shape({})
};

const defaultProps = {
  loader: {}
};

const DataLoader = ({ loader }) => {
  const { progress = {} } = loader;
  const { completed = 0, errorTasks = [] } = progress;
  const indicatorCls =
    errorTasks && errorTasks.length <= 0
      ? "progress-bar green stripes"
      : "progress-bar red stripes";
  const { name } = loader;
  return (
    <div key={loader.name} className="DataLoaderChanged">
      <div className="DataLoader__title">{name}</div>
      <div className="DataLoader__progress">
        <div className={indicatorCls}>
          <span
            style={{
              width: `${completed}%`,
              // display: 'flex',
              flex: "1"
            }}
          >
            {completed}
          </span>
        </div>
      </div>
    </div>
  );
};

DataLoader.defaultProps = defaultProps;
DataLoader.propTypes = propTypes;

export default DataLoader;
