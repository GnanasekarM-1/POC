import React from "react";
import PropTypes from "prop-types";
import StatusBar from "./StatusBar";

const PageFooterView = props => {
  const { data = {}, msgType, message, type } = props;
  const { error } = data;
  return (
    <StatusBar
      actionType={type}
      type={msgType}
      message={message}
      error={error}
    />
  );
};

PageFooterView.propTypes = {
  data: PropTypes.shape({}).isRequired,
  message: PropTypes.string.isRequired,
  msgType: PropTypes.string.isRequired
};

export default PageFooterView;
