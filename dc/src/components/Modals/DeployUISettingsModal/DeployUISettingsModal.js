import React, { Component } from "react";
import { connect } from "react-redux";
import { bindActionCreators } from "redux";
import PropTypes from "prop-types";
import {
  Button,
  Grid,
  GridItem,
  GridRow,
  Modal,
  ModalHeader,
  ModalContent,
  ModalFooter,
  Spinner
} from "@svmx/ui-components-lightning";
import { REQUEST_PASS } from "constants/AppConstants";

import { getDeployUserSettingsRequestPayload } from "utils/DeployUserSettingsUtils";
import { getDisplayValue } from "utils/DCUtils";
import { TAG066, TAG305 } from "constants/DisplayTagConstants";
import {
  getDispatcherListAction,
  postUserSettings
} from "actions/DeployUserSettingsAction";
import DeployUISettingsContainer from "containers/DeployUISettingsContainer";
import "./DeployUISettingsModal.scss";

const mapDispatchToProps = dispatch => ({
  actions: bindActionCreators(
    {
      getDispatcherListAction,
      postUserSettings
    },
    dispatch
  )
});

const mapStateToProps = ({ deployusersettings }) => {
  let dispatcherList = [];
  let teamList = [];
  let status;
  if (deployusersettings) {
    const { status: currentStatus } = deployusersettings;
    if (currentStatus && currentStatus.api === "DISPATCHER_LIST_LOADED") {
      const { dispatcherList: dList, teamList: tList } = deployusersettings;
      dispatcherList = dList;
      teamList = tList;
      status = currentStatus;
    }
  }

  return {
    dispatcherList,
    teamList,
    status
  };
};

let selectedDispatcher = [];
let selectedUserSettings = [];

class DeployUISettingsModal extends Component {
  state = {
    isDispatchrLoaded: false,
    isDispatchrSelected: false
  };

  componentDidMount() {
    const { actions } = this.props;
    actions.getDispatcherListAction();
  }

  componentWillReceiveProps(nextProps) {
    const { status } = nextProps;
    if (status && status.api === "DISPATCHER_LIST_LOADED") {
      this.setState({ isDispatchrLoaded: true });
    }
  }

  handleDeployClick = () => {
    const { actions } = this.props;
    const requestPayload = getDeployUserSettingsRequestPayload(
      selectedDispatcher,
      selectedUserSettings
    );
    const { userids } = requestPayload;
    if (userids.length !== 0) {
      actions.postUserSettings(this.handleDeployClickCompleted, requestPayload);
      this.setState({ isDispatchrLoaded: false });
      selectedDispatcher = [];
    } else {
      this.setState({ isDispatchrSelected: true });
    }
  };

  handleOkClick = () => {
    this.setState({ isDispatchrSelected: false });
  };

  handleDeployClickCompleted = response => {
    const { onClose } = this.props;
    const { success } = response;
    if (success === REQUEST_PASS) {
      onClose();
    } else {
      this.setState({ isDispatchrLoaded: true });
    }
  };

  handleDispatcherSelection = dispatcherList => {
    selectedDispatcher = dispatcherList;
  };

  handleUserSettingSelection = selectedSettings => {
    selectedUserSettings = selectedSettings;
  };

  render() {
    const { onClose, isOpen } = this.props;
    const { isDispatchrLoaded, isDispatchrSelected } = this.state;
    return (
      <div>
        <Modal
          className="DeployUISettingsModal"
          size="large"
          isOpen={isOpen}
          onClose={onClose}
        >
          <ModalHeader title={getDisplayValue(TAG305)} />
          <ModalContent className="DeployUISettingsModal__Content">
            <Grid isVertical>
              <GridItem>
                {!isDispatchrLoaded && <Spinner size="large" />}
                {isDispatchrLoaded && (
                  <DeployUISettingsContainer
                    {...this.props}
                    handleDispatcherSelection={this.handleDispatcherSelection}
                    handleUserSettingSelection={this.handleUserSettingSelection}
                    isDispatchrLoaded={isDispatchrLoaded}
                  />
                )}
              </GridItem>
            </Grid>
          </ModalContent>
          <ModalFooter>
            <Button
              type="neutral"
              label={getDisplayValue(TAG066)}
              onClick={onClose}
            />
            <Button
              type="brand"
              isDisabled={!isDispatchrLoaded}
              label="Deploy"
              onClick={this.handleDeployClick}
            />
          </ModalFooter>
        </Modal>

        <Modal
          size="small"
          isOpen={isDispatchrSelected}
          onClose={this.handleOkClick}
          zIndex={999999}
        >
          <ModalHeader title={getDisplayValue("TAG183")} />
          <ModalContent className="DeployUISettingsModal__console-content">
            {getDisplayValue("TAG309")}
          </ModalContent>
          <ModalFooter>
            <Button
              type="brand"
              label={getDisplayValue("TAG091")}
              onClick={this.handleOkClick}
            />
          </ModalFooter>
        </Modal>
      </div>
    );
  }
}
DeployUISettingsModal.propTypes = {
  isOpen: PropTypes.bool.isRequired,
  onClose: PropTypes.func.isRequired
};
export default connect(
  mapStateToProps,
  mapDispatchToProps
)(DeployUISettingsModal);
