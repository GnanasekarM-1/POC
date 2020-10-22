import React, { Component } from "react";
import { PropTypes } from "prop-types";
import {
  Modal,
  ModalHeader,
  ModalContent,
  ModalFooter,
  DuelingPicklist,
  Button,
  Checkbox,
  GridRow,
  GridItem,
  Input,
  Label,
  InputWrapper
} from "@svmx/ui-components-lightning";
import {
  MAX_AUTO_REFRESH_DURATION_IN_MINUTES,
  NAME
} from "constants/AppConstants";
import { TAG081, TAG082, TAG246 } from "constants/DisplayTagConstants";
import { isEqual, remove } from "lodash";
import { getDisplayValue } from "utils/DCUtils";
import "./ConfigureQueueModal.scss";

const propTypes = {
  autorefresh: PropTypes.bool,
  autoSaveInterval: PropTypes.number,
  handleDone: PropTypes.func,
  handleHide: PropTypes.func,
  header: PropTypes.string,
  isOpen: PropTypes.bool,
  refreshtime: PropTypes.number,
  sourceItems: PropTypes.arrayOf(PropTypes.oneOfType([PropTypes.shape({})])),
  targetValues: PropTypes.arrayOf(
    PropTypes.oneOfType([PropTypes.string, PropTypes.number])
  )
};

const defaultProps = {
  autorefresh: false,
  autoSaveInterval: 5,
  handleDone: null,
  handleHide: null,
  header: "",
  isOpen: false,
  refreshtime: 7,
  sourceItems: [],
  targetValues: []
};

class ConfigureQueueModal extends Component {
  constructor(props) {
    super(props);
    const { autorefresh, autoSaveInterval, refreshtime, targetValues } = props;
    this.state = {
      autoSaveInterval,
      isChecked: autorefresh,
      orginalItems: [...targetValues],
      refeshInterval: refreshtime,
      targetValues
    };
  }

  componentWillReceiveProps(newProps) {
    const { targetValues } = newProps;
    this.setState({
      orginalItems: [...targetValues]
    });
  }

  handleDoneClicked = () => {
    const { autorefresh, handleHide, refreshtime } = this.props;
    const {
      isChecked,
      orginalItems,
      refeshInterval,
      targetValues
    } = this.state;
    const equal =
      isEqual(orginalItems, targetValues) &&
      JSON.parse(autorefresh) === isChecked &&
      parseInt(refreshtime, 10) === refeshInterval;
    if (!equal) {
      const { handleDone } = this.props;
      setTimeout(() => handleDone(targetValues, isChecked, refeshInterval), 0);
    }
    setTimeout(() => handleHide(), 0);
  };

  handleTargetValuesChange = ({ targetValues }) => {
    const lockedCols = remove(
      targetValues,
      targetValue => targetValue === NAME
    );
    if (lockedCols.length) {
      targetValues.unshift(...lockedCols);
    }
    this.setState({ targetValues });
  };

  handleCheckedChange = data => {
    this.setState({ isChecked: data.isChecked });
  };

  handleValueChange = ({ value }, name) => {
    if (value > 0 || value === "") {
      this.setState({ [name]: value });
    }
  };

  handleBlur = (e, name) => {
    const { refreshtime } = this.props;
    try {
      const value = Math.ceil(e.target.value.trim());
      if (value > MAX_AUTO_REFRESH_DURATION_IN_MINUTES) {
        value = MAX_AUTO_REFRESH_DURATION_IN_MINUTES;
      }
      this.setState({ [name]: value || refreshtime });
    } catch (e) {
      this.setState({ [name]: refreshtime });
    }
  };

  render() {
    const { isOpen, sourceItems, header, handleHide } = this.props;
    const { targetValues, isChecked, refeshInterval } = this.state;
    return (
      <Modal isOpen={isOpen} onClose={handleHide}>
        <ModalHeader title={header} />
        <ModalContent>
          <DuelingPicklist
            className="ConfigureQueueModal_DuelingPicklist"
            allowOrdering
            hasSourceFilter
            selectMode="multi"
            sourceItems={sourceItems}
            sourceLabel={getDisplayValue("TAG060")}
            targetLabel={getDisplayValue("TAG061")}
            targetValues={targetValues}
            onTargetValuesChange={this.handleTargetValuesChange}
          />
        </ModalContent>
        <ModalFooter>
          <GridRow className="ConfigureQueueModal__Footer">
            <GridItem className="ConfigureQueueModal__Footer-reload" noFlex>
              <Checkbox
                isChecked={isChecked}
                name="my-checkbox"
                value="1"
                onCheckedChange={this.handleCheckedChange}
              >
                {getDisplayValue(TAG081)}
              </Checkbox>
            </GridItem>
            <GridItem noFlex>
              <InputWrapper size="xx-small">
                <Input
                  type="number"
                  name="refeshInterval"
                  value={refeshInterval}
                  min={1}
                  max={15}
                  onValueChange={event =>
                    this.handleValueChange(event, "refeshInterval")
                  }
                  disabled={!isChecked}
                  onBlur={event => this.handleBlur(event, "refeshInterval")}
                  size="xx-small"
                />
              </InputWrapper>
            </GridItem>
            <GridItem noFlex>
              <Label>{` ${getDisplayValue(TAG082)}`}</Label>
            </GridItem>
            <GridItem>
              <Button
                type="brand"
                label={getDisplayValue(TAG246)}
                onClick={this.handleDoneClicked}
              />
            </GridItem>
          </GridRow>
        </ModalFooter>
      </Modal>
    );
  }
}

ConfigureQueueModal.propTypes = propTypes;
ConfigureQueueModal.defaultProps = defaultProps;

export default ConfigureQueueModal;
