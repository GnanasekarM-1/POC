import React, { useState } from "react";
import PropTypes from "prop-types";
import {
  BuilderHeader,
  BuilderHeaderItem,
  BuilderHeaderNav,
  Button,
  DropdownFactory,
  Icon,
  Modal,
  ModalHeader,
  ModalContent,
  ModalFooter
} from "@svmx/ui-components-lightning";
import DeployUISettingsModal from "components/Modals/DeployUISettingsModal";
import { getDisplayValue } from "utils/DCUtils";
import {
  TAG464,
  TAG232,
  TAG283,
  TAG143,
  TAG304,
  TAG503
} from "constants/DisplayTagConstants";
import {
  RESET_DEFAULT_SETTINGS,
  DEPLOY_SETTINGS,
  LOGGED_IN,
  SUPER_DISPATCHER,
  NONE,
  FALSE
} from "constants/AppConstants";
import {
  ALL,
  getSettingValue,
  DCON001_SET053,
  DCON001_SET065
} from "constants/AppSettings";
import "./PageHeaderView.scss";

const PageHeaderView = props => {
  const [deployOpen, isDeployOpen] = useState(false);
  const [confirmReset, isReset] = useState(false);
  const { isDispatcher, name, onReset, UserName } = props;
  const title = `${getDisplayValue(TAG464)} ${name}`;
  const loggedUser = `${getDisplayValue(TAG283)} ' ${UserName} '`;
  let enableResetUI = false;
  const allowSuperDispacherDeployment = JSON.parse(
    getSettingValue(DCON001_SET053, FALSE).toLowerCase()
  );
  const set065Value = getSettingValue(DCON001_SET065);
  if (set065Value === ALL) {
    enableResetUI = true;
  } else if (set065Value === SUPER_DISPATCHER && isDispatcher) {
    enableResetUI = true;
  } else if (set065Value === NONE) {
    enableResetUI = false;
  }
  const getMenuOptions = () => {
    const menuOptions = [];
    menuOptions.push({ display: loggedUser, value: LOGGED_IN });
    if (enableResetUI) {
      menuOptions.push({
        display: getDisplayValue(TAG232),
        value: RESET_DEFAULT_SETTINGS
      });
    }
    if (isDispatcher && allowSuperDispacherDeployment) {
      menuOptions.push({
        display: getDisplayValue(TAG304),
        value: DEPLOY_SETTINGS
      });
    }
    return menuOptions;
  };

  const handleMenuItemClick = item => {
    const { value } = item;
    switch (value) {
      case RESET_DEFAULT_SETTINGS:
        isReset(true);
        break;
      case DEPLOY_SETTINGS:
        isDeployOpen(true);
        break;
      case LOGGED_IN:
        break;
      default:
        break;
    }
  };

  const handleHide = () => {
    isDeployOpen(false);
    isReset(false);
  };

  const handleResetConfirmation = value => {
    if (value === "yes") {
      onReset();
    }
    handleHide();
  };

  const handleHelp = () => {
    const URL = getDisplayValue(TAG503);
    window.open(
      URL,
      "_blank",
      "width=820,height=600,resizable=1,status=0,scrollbars=1"
    );
  };

  return (
    <div>
      <BuilderHeader className="page_header_slds-builder-header_container">
        <BuilderHeaderItem category="svmx" icon="logo" title={title} />
        <BuilderHeaderNav isUtility>
          <Button
            type="icon-bare"
            className="PageHeaderView__headerNav"
            title={getDisplayValue(TAG143)}
            onClick={() => handleHelp()}
            size="large"
          >
            <Icon icon="help" category="utility" />
          </Button>
          <DropdownFactory
            position="bottomRight"
            items={getMenuOptions()}
            onItemClick={item => handleMenuItemClick(item)}
          >
            <Button
              type="icon-bare"
              className="PageHeaderView__headerNav"
              size="large"
            >
              <Icon icon="user" />
            </Button>
          </DropdownFactory>
        </BuilderHeaderNav>
      </BuilderHeader>
      {deployOpen && (
        <DeployUISettingsModal isOpen={deployOpen} onClose={handleHide} />
      )}
      {confirmReset && (
        <Modal size="small" isOpen={confirmReset} onClose={handleHide}>
          <ModalHeader title={getDisplayValue("TAG183")} />
          <ModalContent className="PageHeaderView__resetConfirmationMsg">
            {getDisplayValue("TAG318")}
          </ModalContent>
          <ModalFooter>
            <Button
              type="brand"
              label={getDisplayValue("TAG240")}
              onClick={() => handleResetConfirmation("yes")}
            />
            <Button
              type="brand"
              label={getDisplayValue("TAG241")}
              onClick={() => handleResetConfirmation("no")}
            />
          </ModalFooter>
        </Modal>
      )}
    </div>
  );
};

PageHeaderView.propTypes = {
  isDispatcher: PropTypes.bool.isRequired,
  name: PropTypes.string.isRequired,
  onReset: PropTypes.func.isRequired,
  UserName: PropTypes.string.isRequired
};

export default PageHeaderView;
