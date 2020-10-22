import React from "react";
import PropTypes from "prop-types";
import {
  BuilderHeader,
  BuilderHeaderItem
} from "@svmx/ui-components-lightning";
import { Title } from "constants/AppConstants";

import "./ApplicationError.scss";

const ApplicationError = props => {
  const { error = {}, info } = props;
  const { message, stack } = error;
  const title = `${
    window.configData && window.configData.Title
      ? window.configData.Title
      : Title
  }`;

  return (
    <div className="ApplicationError">
      <BuilderHeader className="page_header_slds-builder-header_container">
        <BuilderHeaderItem category="svmx" icon="logo" title={title} />
      </BuilderHeader>
      <div className="Details">
        <details open>
          <summary>
            <div>
              <b>Unexpected error occured</b>
            </div>
            <div>{message}</div>
          </summary>
          <p>{stack}</p>
        </details>
      </div>
    </div>
  );
};

ApplicationError.propTypes = {
  info: PropTypes.shape({}),
  error: PropTypes.shape({}).isRequired
};

export default ApplicationError;
