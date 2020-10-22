import React, { Component } from "react";
import {
  Button,
  Container,
  Label,
  Modal,
  ModalHeader,
  ModalContent,
  ModalFooter,
  Textarea
} from "@svmx/ui-components-lightning";
import PropTypes from "prop-types";
import { connect } from "react-redux";
import { bindActionCreators } from "redux";
import { orderBy } from "lodash";
import { DISPLAY } from "constants/AppConstants";
import { getDisplayValue } from "utils/DCUtils";
import { TAG066, TAG076, TAG388 } from "constants/DisplayTagConstants";
import AdvSearchContainer from "components/AdvancedSearch";
import { technicianActions } from "actions/TechnicianAction";
import { updateUserSettings } from "actions/UserSettingAction";
import {
  API_DATA_LOADED,
  KEY_ADV_TECH_SEARCH,
  KEY_WO_MATCH_SKILLS,
  API_INVOKED,
  API_ERRORED
} from "constants/ActionConstants";
import LoadIndicator from "./LoadIndicator";

import "./AdvTechSearchModal.scss";
import ErrorModalDialog from "../../PageFooter/ErrorModalDialog";

const mapStateToProps = ({
  metaData,
  gridState,
  schedulerState,
  technicianData,
  userSettings
}) => {
  const { advTechSearch, technicians, woMatchSkills } = technicianData;
  const { data } = technicians;
  const {
    techSkills,
    technicianFields,
    userTimezone,
    workOrderFields
  } = metaData;
  const { row: selectedWO, view } = gridState;

  const { content: techContent } = technicianFields;
  const { content: woFields } = workOrderFields;
  const techFields = orderBy(Object.values(techContent), [DISPLAY]);
  const woFieldList = orderBy(Object.values(woFields), [DISPLAY]);
  const { activeView } = schedulerState;
  const {
    adv_atsSkills: atsSkills,
    adv_atsPrefTech: atsPrefTech,
    adv_atsExpertise: atsExpertise,
    adv_atsEligibility: atsEligibility,
    wo_woCol: woCol
  } = userSettings;

  return {
    activeView,
    advTechSearch,
    atsEligibility,
    atsExpertise,
    atsPrefTech,
    atsSkills,
    selectedWO,
    techFields,
    technicians: (data && data.technicians) || [],
    techniciansIds: (data && data.techniciansIds) || [],
    techSkills: (techSkills && techSkills.content) || undefined,
    userTimezone,
    view,
    woCol,
    woFieldList,
    woFields,
    woMatchSkills
  };
};

const mapDispatchToProps = dispatch => ({
  ...bindActionCreators(
    { ...technicianActions(), updateUserSettings },
    dispatch
  )
});

class AdvTechSearchModal extends Component {
  constructor(props) {
    super(props);
    this.state = {
      matchSkillLoaded: false,
      searchRequested: false
    };
    this.atsData = {};
  }

  componentDidMount() {
    const { getWOMatchTechSkills, selectedWO } = this.props;
    const { Id } = selectedWO;
    getWOMatchTechSkills(Id);
  }

  componentWillReceiveProps(nextProps) {
    const { isOpen } = this.props;
    const { advTechSearch, woMatchSkills } = nextProps;
    if (woMatchSkills) {
      const { data, status = {} } = woMatchSkills;
      const { api, code, message } = status;
      this.setState({ matchSkillLoaded: data && api === API_DATA_LOADED });
      this.setState({
        showAlert: api === API_ERRORED ? { errorCode: code, message } : false
      });
    }
    if (advTechSearch) {
      const { data, status = {} } = advTechSearch;
      const { api, code, message } = status;
      this.setState({ searchRequested: !data && api === API_INVOKED });
      this.setState({
        showAlert: api === API_ERRORED ? { errorCode: code, message } : false
      });
      if (data && isOpen) {
        isOpen(false);
      }
    }
  }

  componentWillUnmount() {
    const { advTechSearch, removeATSResults, woMatchSkills } = this.props;
    if (woMatchSkills || (advTechSearch && removeATSResults)) {
      removeATSResults([KEY_WO_MATCH_SKILLS, KEY_ADV_TECH_SEARCH]);
    }
  }

  techMatchSkillLoaded = matchSkillLoaded => {
    this.setState({
      matchSkillLoaded
    });
  };

  updateATSState = update => {
    const { changed } = update;
    const { updateUserSettings } = this.props;
    if (changed && updateUserSettings) {
      updateUserSettings(changed);
      delete update.changed;
    }
    this.atsData = { ...this.atsData, ...update };
  };

  apply = () => {
    const { performATS } = this.props;
    if (performATS) {
      performATS(this.atsData);
      this.setState({ searchRequested: true });
    }
  };

  isDataLoading = () => {
    const { matchSkillLoaded, searchRequested } = this.state;
    return matchSkillLoaded ? searchRequested : !matchSkillLoaded;
  };

  handleOnClose = () => {
    const { isOpen } = this.props;
    const { matchSkillLoaded } = this.state;
    if (!matchSkillLoaded) {
      isOpen(false);
    }
    this.setState({ showAlert: false });
  };

  render() {
    const { open, isOpen, selectedWO } = this.props;
    const { showAlert } = this.state;
    return (
      <div>
        <Modal
          className="AdvTechSearchModal"
          size="large"
          isOpen={open}
          onClose={() => isOpen(false)}
        >
          <ModalHeader title={getDisplayValue(TAG388)} />
          <ModalContent className="AdvTechSearchModal__Content">
            {this.isDataLoading() && <LoadIndicator />}
            {!this.isDataLoading() && (
              <AdvSearchContainer
                {...this.props}
                selectedWO={selectedWO}
                updateATSState={this.updateATSState}
              />
            )}
          </ModalContent>
          <ModalFooter>
            <Button
              type="brand"
              label={getDisplayValue(TAG066)}
              onClick={() => isOpen(false)}
            />
            <Button
              isDisabled={this.isDataLoading()}
              type="brand"
              label={getDisplayValue(TAG076)}
              onClick={this.apply}
            />
          </ModalFooter>
        </Modal>
        {showAlert && (
          <ErrorModalDialog
            close={this.handleOnClose}
            error={showAlert}
            open={showAlert}
          />
        )}
      </div>
    );
  }
}

AdvTechSearchModal.propTypes = {
  apply: PropTypes.func.isRequired,
  isOpen: PropTypes.func.isRequired,
  open: PropTypes.bool.isRequired,
  selectedWO: PropTypes.shape({}).isRequired,
  updateUserSettings: PropTypes.func.isRequired
};

export default connect(mapStateToProps, mapDispatchToProps)(AdvTechSearchModal);
