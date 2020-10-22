import React from "react";
import { connect } from "react-redux";
import PageFooterView from "components/PageFooter";

const mapStateToProps = ({ appStatus }) => appStatus;

const FooterContainer = props => <PageFooterView {...props} />;

export default connect(mapStateToProps)(FooterContainer);
