import React from "react";
import PropTypes from "prop-types";
import { connect } from "react-redux";

import { RESET_USER_SETTINGS } from "constants/ActionConstants";

import PageHeaderView from "components/PageHeader";

const mapStateToProps = ({ gridState, metaData }) => {
  const { row } = gridState || {};
  const { userInfo } = metaData || {};
  const { isDispatcher = false, UserName = "" } = userInfo || {};
  const name = row ? `( ${row.Name} )` : "";
  return {
    isDispatcher,
    name,
    UserName
  };
};

const mapDispatchToProps = dispatch => ({
  onUserSettingsReset: () => dispatch({ type: RESET_USER_SETTINGS })
});

const HeaderContainer = props => {
  const { isDispatcher, name, onUserSettingsReset, UserName } = props;
  return (
    <PageHeaderView
      name={name}
      isDispatcher={isDispatcher}
      UserName={UserName}
      onReset={onUserSettingsReset}
    />
  );
};

HeaderContainer.propTypes = {
  isDispatcher: PropTypes.bool.isRequired,
  name: PropTypes.string.isRequired,
  onUserSettingsReset: PropTypes.func.isRequired,
  UserName: PropTypes.string.isRequired
};

export default connect(mapStateToProps, mapDispatchToProps)(HeaderContainer);
