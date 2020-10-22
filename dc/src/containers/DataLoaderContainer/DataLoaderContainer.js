import React, { Component } from "react";
import { connect } from "react-redux";
import { bindActionCreators } from "redux";
import PropTypes from "prop-types";
import { flatMap } from "lodash";

import { getAppMetaData } from "actions/MetaDataAction";
import { applyUserSettings } from "actions/UserSettingAction";
import { HTTP_OK, SERVER_ERROR } from "constants/ServiceConstants";
import {
  KEY_METADATA,
  KEY_WORKORDER_DATA,
  KEY_VIEW_DATA,
  KEY_TECHNICIAN_DATA,
  KEY_EVENTS_DATA
} from "constants/ActionConstants";
import {
  LFSettings,
  LWO,
  LTech,
  LTeam,
  LUISettings,
  LEvent
} from "constants/AppConstants";

import AppDataLoader from "components/AppDataLoader";

const mapStateToProps = state => ({ ...state });

const mapDispatchToProps = dispatch => ({
  actions: bindActionCreators(
    {
      applyUserSettings,
      getAppMetaData
    },
    dispatch
  )
});

class DataLoaderContainer extends Component {
  constructor(props) {
    super(props);
    this.state = {
      loaders: [
        {
          active: true,
          haltOnError: false,
          key: KEY_VIEW_DATA,
          name:
            window.configData && window.configData.LUISettings
              ? window.configData.LUISettings
              : LUISettings
        },
        {
          active: true,
          haltOnError: false,
          key: KEY_TECHNICIAN_DATA,
          name:
            window.configData && window.configData.LTeam
              ? window.configData.LTeam
              : LTeam
        },
        {
          active: true,
          haltOnError: false,
          key: KEY_TECHNICIAN_DATA,
          name:
            window.configData && window.configData.LTech
              ? window.configData.LTech
              : LTech
        },
        {
          active: true,
          haltOnError: false,
          key: KEY_EVENTS_DATA,
          name:
            window.configData && window.configData.LEvent
              ? window.configData.LEvent
              : LEvent
        },
        {
          active: true,
          haltOnError: false,
          key: KEY_METADATA,
          name:
            window.configData && window.configData.LFSettings
              ? window.configData.LFSettings
              : LFSettings
        },
        {
          active: true,
          haltOnError: false,
          key: KEY_WORKORDER_DATA,
          name:
            window.configData && window.configData.LWO
              ? window.configData.LWO
              : LWO
        }
      ],
      initDone: false
    };
    this.userSettingApplied = false;
  }

  componentDidMount() {
    const { loaders } = this.state;
    this.setState(state => ({
      ...state,
      activeTasks: loaders.filter(loader => loader.active === true).length
    }));
    const { actions } = this.props;
    actions.getAppMetaData();
  }

  componentWillReceiveProps(props) {
    this.updateLoaderStatus(props);
  }

  updateLoaderStatus = newProps => {
    // Compute progress update of inital tasks
    let activeTasks = 0;
    let netProgress = 0;
    let loadComplete = false;
    const { initDone, loaders } = this.state;
    loaders.forEach((loader, index) => {
      const { active, key } = loader;
      if (active) {
        activeTasks += 1;
        const tasks = newProps[key];
        const progress = this.getTaskProgress(tasks);
        const { completed } = progress;
        loaders[index].progress = progress;
        netProgress += completed;
        loadComplete = netProgress >= activeTasks * 100;
      }
    });
    this.setState({ loaders });

    // Notify Once inital tasks are done.
    if (!initDone && loadComplete) {
      const { actions, onLoadComplete } = this.props;
      const haltErrors = this.getHaltErrors();
      if (!haltErrors.length) {
        if (onLoadComplete) {
          setTimeout(() => onLoadComplete(), 400);
        }
        if (!this.userSettingApplied) {
          setTimeout(() => actions.applyUserSettings(), 400);
          this.userSettingApplied = !this.userSettingApplied;
        }
      }
      this.setState({ haltErrors, initDone: true });
    }
  };

  getHaltErrors = () => {
    const haltErrors = [];
    const { loaders } = this.state;
    loaders.forEach(loader => {
      const { key, haltOnError, progress } = loader;
      if (haltOnError) {
        const { errorTasks } = progress;
        if (errorTasks.length) {
          const [errorTask] = errorTasks;
          const { status } = errorTask;
          const { error } = status;
          haltErrors.push(error);
        }
      }
    });
    return haltErrors;
  };

  getTaskProgress = tasks => {
    const progress = {};
    if (tasks && tasks instanceof Object) {
      const names = Object.keys(tasks);
      const httpTasks = names.filter(name => tasks[name].status !== undefined);
      if (httpTasks.length) {
        const completedTasks = httpTasks.filter(httpTask => {
          const task = tasks[httpTask];
          const { status } = task;
          const { code } = status;
          return code === HTTP_OK;
        });
        const errorTasks = httpTasks.filter(httpTask => {
          const task = tasks[httpTask];
          const { status } = task;
          const { code } = status;
          return code === SERVER_ERROR;
        });
        progress.completed = Math.round(
          ((completedTasks.length + errorTasks.length) / httpTasks.length) * 100
        );
        progress.completedTasks = completedTasks;
        progress.errorTasks = flatMap(
          errorTasks,
          errorTask => tasks[errorTask]
        );
      }
    }
    return progress;
  };

  clearHaltErrors = () => {
    const { haltErrors } = this.state;
    const [haltError] = haltErrors;
    const { errorCode, message } = haltError || {};
    this.setState({ haltErrors: [] });
    throw new Error(errorCode ? `${errorCode}: ${message}` : `${message}`);
  };

  render() {
    const { haltErrors, loaders } = this.state;
    return (
      <AppDataLoader
        loaders={loaders}
        haltErrors={haltErrors}
        onClose={this.clearHaltErrors}
      />
    );
  }
}

DataLoaderContainer.propTypes = {
  actions: PropTypes.shape().isRequired
};

export default connect(
  mapStateToProps,
  mapDispatchToProps
)(DataLoaderContainer);
