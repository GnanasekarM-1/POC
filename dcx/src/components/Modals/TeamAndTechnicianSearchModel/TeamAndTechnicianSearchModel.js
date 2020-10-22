import React, { Component } from "react";
import { PropTypes } from "prop-types";
import {
  Modal,
  ModalHeader,
  ModalContent,
  ModalFooter,
  Button,
  GridItem
} from "@svmx/ui-components-lightning";
import { TAG246 } from "constants/DisplayTagConstants";

import { getDisplayValue } from "utils/DCUtils";

import { isEqual } from "lodash";
import TeamAndTechnicianSearchContainer from "containers/TeamAndTechnicianSearchContainer";

import "./TeamAndTechnicianSearchModel.scss";

const propTypes = {
  handleDone: PropTypes.func,
  handleHide: PropTypes.func,
  header: PropTypes.string,
  isOpen: PropTypes.bool,
  sourceItems: PropTypes.arrayOf(PropTypes.oneOfType([PropTypes.shape({})])),
  targetValues: PropTypes.arrayOf(
    PropTypes.oneOfType([PropTypes.string, PropTypes.number])
  )
};

const defaultProps = {
  handleDone: null,
  handleHide: null,
  header: "",
  isOpen: false,
  sourceItems: [],
  targetValues: []
};

class TeamAndTechnicianModel extends Component {
  constructor(props) {
    super(props);
    const { targetValues } = props;
    this.state = {
      callChildMethod: null,
      isChecked: false,
      orginalItems: [...targetValues],
      targetValues
    };
    // this.techModal = React.createRef();
  }

  componentWillReceiveProps(newProps) {
    const { targetValues } = newProps;
    this.setState({
      orginalItems: [...targetValues]
    });
  }

  handleDoneClicked = () => {
    const { handleHide } = this.props;
    const { callChildMethod } = this.state;
    callChildMethod();
    handleHide();
  };

  handleTargetValuesChange = ({ targetValues }) => {
    this.setState({ targetValues });
  };

  handleCheckedChange = data => {
    this.setState({ isChecked: data.isChecked });
  };

  render() {
    const { isOpen, sourceItems, header, handleHide } = this.props;
    const { targetValues, isChecked } = this.state;
    return (
      <Modal isOpen={isOpen} onClose={handleHide}>
        <ModalHeader title={header} />
        <ModalContent>
          <TeamAndTechnicianSearchContainer
            setCallable={callable =>
              this.setState({ callChildMethod: callable })
            }
          />
        </ModalContent>
        <ModalFooter>
          <GridItem noFlex>
            <Button
              type="brand"
              label={getDisplayValue(TAG246)}
              onClick={() => this.handleDoneClicked()}
            />
          </GridItem>
        </ModalFooter>
      </Modal>
    );
  }
}

TeamAndTechnicianModel.propTypes = propTypes;
TeamAndTechnicianModel.defaultProps = defaultProps;

export default TeamAndTechnicianModel;
