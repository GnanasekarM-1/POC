import React, { useState } from "react";
import PropTypes from "prop-types";
import {
  Button,
  Container,
  Label,
  Modal,
  ModalContent,
  ModalHeader,
  ModalFooter,
  Textarea
} from "@svmx/ui-components-lightning";
import { getDisplayValue } from "utils/DCUtils";
import { TAG069, TAG183, TAG188, TAG374 } from "constants/DisplayTagConstants";

const ErrorModalDialog = props => {
  const { close, error = {}, open, exitOnClose } = props;
  const { message, errorCode } = error;

  const handleClick = () => {
    close();
    if (exitOnClose) {
      // @grant        window.close
      window.close();
    }
  };

  return (
    <Modal isOpen={open} onClose={() => handleClick()} zIndex={9003}>
      <ModalHeader title={getDisplayValue(TAG183)} />
      <ModalContent className="slds-p-around--small">
        <Container>
          {errorCode && (
            <div>
              <Label>
                <b>{`${getDisplayValue(TAG188)} : `}</b>
                {isNaN(errorCode) ? errorCode : `HTTP ${errorCode}`}
              </Label>
            </div>
          )}
          <div>
            <Label>
              <b>{getDisplayValue(TAG374)}</b>
            </Label>
          </div>
          <Textarea name="ErrorDetails" value={message} />
        </Container>
      </ModalContent>
      <ModalFooter style={{ display: "flex", justifyContent: "space-around" }}>
        <Button
          type="brand"
          label={getDisplayValue(TAG069)}
          onClick={() => handleClick()}
        />
      </ModalFooter>
    </Modal>
  );
};

ErrorModalDialog.propTypes = {
  close: PropTypes.func.isRequired,
  error: PropTypes.string.isRequired,
  open: PropTypes.bool.isRequired,
  exitOnClose: PropTypes.bool
};

export default ErrorModalDialog;
