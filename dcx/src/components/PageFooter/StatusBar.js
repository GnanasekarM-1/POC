import React, { useState } from "react";
import PropTypes from "prop-types";
import { isEmpty } from "lodash";
import {
  Button,
  Icon,
  Spinner,
  Grid,
  GridItem,
  GridRow,
  Label
} from "@svmx/ui-components-lightning";
import { getDisplayValue } from "utils/DCUtils";
import {
  ERROR_TYPE,
  INFO_TYPE,
  WARNING_TYPE,
  PROGRESS_TYPE,
  CLEAR_TYPE,
  INVALID_SESSION_ID
} from "constants/AppConstants";
import { TAG242 } from "constants/DisplayTagConstants";
import ErrorModalDialog from "./ErrorModalDialog";

import "./StatusBar.scss";

const StatusBar = props => {
  let { message } = props;
  const { type, error = {} } = props;
  const { errorCode } = error;

  const [sessionExpired, setSessionExpired] = useState(false);
  const [open, isOpen] = useState(false);

  const regEx = /^EVENTSTAG[0-9]+|^EXCEPTTAG[0-9]+|^TAG[0-9]+$/;
  if (regEx.test(message)) {
    message = getDisplayValue(message);
  }

  const getComponent = () => {
    if (isEmpty(message)) {
      return;
    }
    switch (type) {
      case ERROR_TYPE:
        return (
          <Button type="icon-bare" size="small" onClick={() => isOpen(true)}>
            <Icon icon="error" size="small" textColor="error" />
          </Button>
        );
      case WARNING_TYPE:
        return <Icon icon="warning" size="small" textColor="warning" />;
      case INFO_TYPE:
        return <Icon icon="info" size="small" />;
      case PROGRESS_TYPE:
        return <Spinner size="small" />;
      case CLEAR_TYPE:
        return <Spinner size="small" />;
      default:
        return <div />;
    }
  };

  const getMessage = () => {
    switch (type) {
      case WARNING_TYPE:
        return (
          <Label className="warning">
            <blink>
              <b>{message}</b>
            </blink>
          </Label>
        );
      case INFO_TYPE:
      case ERROR_TYPE:
        return <Label>{message}</Label>;
      case PROGRESS_TYPE:
        return <Label>{message}</Label>;
      case CLEAR_TYPE:
        return <div />;
      default:
        return <div />;
    }
  };

  const onClose = () => {
    isOpen(false);
  };

  if ([INVALID_SESSION_ID].includes(errorCode) && !sessionExpired) {
    setSessionExpired(true);
    isOpen(true);
  }

  const defaultMsg =
    "Salesforce session has expired or invalid. Dispatch console will close now.\n Login to Salesforce and launch Dispatch console again.";
  const errorObject = sessionExpired
    ? { errorCode: 401, message: getDisplayValue(TAG242, defaultMsg) }
    : { ...error };

  return (
    <Grid className="StatusBar">
      <GridRow>
        <GridItem />
        <GridItem align="center" className="StatusBar__content">
          <Label className="StatusBar__loading">{getComponent()}</Label>
          {getMessage()}
        </GridItem>
        <GridItem />
      </GridRow>
      {open && (
        <ErrorModalDialog
          open={open}
          error={errorObject}
          close={onClose}
          exitOnClose={sessionExpired}
        />
      )}
    </Grid>
  );
};

StatusBar.propTypes = {
  error: PropTypes.shape({}).isRequired,
  message: PropTypes.string.isRequired,
  type: PropTypes.string.isRequired
};

export default StatusBar;
