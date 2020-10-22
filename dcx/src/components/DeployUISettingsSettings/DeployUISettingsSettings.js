import React, { Component } from "react";
import { PropTypes } from "prop-types";
import {
  Button,
  Grid,
  GridRow,
  GridItem,
  Checkbox,
  CheckboxGroup,
  Section
} from "@svmx/ui-components-lightning";
import { getSettingValue, DCON005_SET006 } from "constants/AppSettings";

import {
  TAG001,
  TAG413,
  TAG247,
  TAG414,
  TAG415,
  TAG416,
  DCON001_TAG417,
  TAG418,
  TAG419,
  TAG420,
  TAG421,
  TAG422,
  EVENTSTAG031,
  EVENTSTAG033,
  EVENTSTAG001,
  EVENTSTAG025,
  EVENTSTAG026,
  EVENTSTAG027,
  TAG050,
  TAG424,
  TAG425,
  TAG426,
  TAG427,
  TAG428,
  TAG429,
  TAG430,
  TAG215,
  TAG236,
  TAG274,
  TAG431,
  TAG432,
  TAG275,
  TAG433,
  TAG434,
  TAG435,
  TAG436,
  TAG437,
  EVENTSTAG143,
  TAG438,
  TAG439,
  TAG375,
  TAG343,
  TAG344,
  TAG440,
  TAG392,
  TAG385,
  TAG442,
  TAG443,
  TAG390,
  TAG391,
  TAG393,
  TAG405,
  TAG454,
  TAG444,
  TAG412,
  TAG218,
  TAG085
} from "constants/DisplayTagConstants";
import { getDisplayValue } from "utils/DCUtils";
import "./DeployUISettingsSettings.scss";

const groupValues = {
  one: [
    "1",
    "2",
    "3",
    "4",
    "5",
    "6",
    "7",
    "8",
    "9",
    "10",
    "11",
    "12",
    "13",
    "14",
    "15",
    "16",
    "17"
  ],
  two: [
    "1",
    "2",
    "3",
    "4",
    "5",
    "6",
    "7",
    "8",
    "9",
    "10",
    "11",
    "12",
    "13",
    "14",
    "15",
    "16",
    "17",
    "18",
    "19",
    "20",
    "21",
    "22",
    "23",
    "24"
  ],
  three: ["1", "2", "3"],
  four: ["1", "2", "3", "4"],
  five: ["1"]
};
const propTypes = {
  handleUserSettingSelection: PropTypes.func
};
const defaultProps = {
  handleUserSettingSelection: null
};

class DeployUISettingsSettings extends Component {
  state = {
    isOpen: {
      one: false,
      two: false,
      three: false,
      four: false,
      five: false
    },
    selectedValues: {
      one: [],
      two: [],
      three: [],
      four: [],
      five: []
    }
  };

  handleOpenChange = group => {
    const { isOpen } = this.state;
    const sectionIsOpen = isOpen[group];
    isOpen[group] = !sectionIsOpen;
    this.setState({
      isOpen
    });
  };

  handleSelectedChange = (group, data) => {
    const { selectedValues } = this.state;
    const { handleUserSettingSelection } = this.props;
    selectedValues[group] = data.selectedValues;
    handleUserSettingSelection(selectedValues);
    this.setState({
      selectedValues
    });
  };

  handleSelectAll = group => {
    const { selectedValues } = this.state;
    const { handleUserSettingSelection } = this.props;
    if (selectedValues[group].length === groupValues[group].length) {
      selectedValues[group] = [];
    } else {
      selectedValues[group] = groupValues[group];
    }
    handleUserSettingSelection(selectedValues);
    this.setState({
      selectedValues
    });
  };

  render() {
    const { isOpen, selectedValues } = this.state;
    const isJDMenabled = getSettingValue(DCON005_SET006) === "Enabled";

    return (
      <Grid
        className="DeployUISettingsSettings_container"
        hasGutters
        isVertical
      >
        <GridRow cols={12} hasWrap>
          <GridItem cols={4}>
            <Section
              isOpen={isOpen.one}
              onOpenChange={() => this.handleOpenChange("one")}
              title={getDisplayValue(TAG001)}
              rightAddon={
                <Button
                  label={
                    selectedValues.one.length === groupValues.one.length
                      ? "Unselect All"
                      : "Select All"
                  }
                  style={{ fontSize: "0.8em" }}
                  type={null}
                  onClick={() => this.handleSelectAll("one")}
                />
              }
            >
              {!isJDMenabled && (
                <CheckboxGroup
                  name="one"
                  selectedValues={selectedValues.one}
                  onSelectedChange={data =>
                    this.handleSelectedChange("one", data)
                  }
                >
                  <Checkbox value="1">{getDisplayValue(TAG413)}</Checkbox>
                  <Checkbox value="2">{getDisplayValue(TAG247)}</Checkbox>
                  <Checkbox value="3">{getDisplayValue(TAG414)}</Checkbox>
                  <Checkbox value="4">{getDisplayValue(TAG415)}</Checkbox>
                  <Checkbox value="5">{getDisplayValue(TAG416)}</Checkbox>
                  <Checkbox value="6">
                    {getDisplayValue(DCON001_TAG417)}
                  </Checkbox>
                  <Checkbox value="7">{getDisplayValue(TAG418)}</Checkbox>
                  <Checkbox value="8">{getDisplayValue(TAG419)}</Checkbox>
                  <Checkbox value="9">{getDisplayValue(TAG420)}</Checkbox>
                  <Checkbox value="10">{getDisplayValue(TAG421)}</Checkbox>
                  <Checkbox value="11">{getDisplayValue(TAG422)}</Checkbox>
                  <Checkbox value="12">
                    {getDisplayValue(EVENTSTAG031)}
                  </Checkbox>
                  <Checkbox value="13">
                    {getDisplayValue(EVENTSTAG033)}
                  </Checkbox>
                </CheckboxGroup>
              )}
              {isJDMenabled && (
                <CheckboxGroup
                  name="one"
                  selectedValues={selectedValues.one}
                  onSelectedChange={data =>
                    this.handleSelectedChange("one", data)
                  }
                >
                  <Checkbox value="1">{getDisplayValue(TAG413)}</Checkbox>
                  <Checkbox value="2">{getDisplayValue(TAG247)}</Checkbox>
                  <Checkbox value="3">{getDisplayValue(TAG414)}</Checkbox>
                  <Checkbox value="4">{getDisplayValue(TAG415)}</Checkbox>
                  <Checkbox value="5">{getDisplayValue(TAG416)}</Checkbox>
                  <Checkbox value="6">
                    {getDisplayValue(DCON001_TAG417)}
                  </Checkbox>
                  <Checkbox value="7">{getDisplayValue(TAG418)}</Checkbox>
                  <Checkbox value="8">{getDisplayValue(TAG419)}</Checkbox>
                  <Checkbox value="9">{getDisplayValue(TAG420)}</Checkbox>
                  <Checkbox value="10">{getDisplayValue(TAG421)}</Checkbox>
                  <Checkbox value="11">{getDisplayValue(TAG422)}</Checkbox>
                  <Checkbox value="12">
                    {getDisplayValue(EVENTSTAG031)}
                  </Checkbox>
                  <Checkbox value="13">
                    {getDisplayValue(EVENTSTAG033)}
                  </Checkbox>
                  <Checkbox value="14">
                    {getDisplayValue(EVENTSTAG001)}
                  </Checkbox>
                  <Checkbox value="15">
                    {getDisplayValue(EVENTSTAG025)}
                  </Checkbox>
                  <Checkbox value="16">
                    {getDisplayValue(EVENTSTAG026)}
                  </Checkbox>
                  <Checkbox value="17">
                    {getDisplayValue(EVENTSTAG027)}
                  </Checkbox>
                </CheckboxGroup>
              )}
            </Section>

            <Section
              isOpen={isOpen.four}
              onOpenChange={() => this.handleOpenChange("four")}
              title={getDisplayValue(TAG412)}
              rightAddon={
                <Button
                  label={
                    selectedValues.four.length === groupValues.four.length
                      ? "Unselect All"
                      : "Select All"
                  }
                  style={{ fontSize: "0.8em" }}
                  type={null}
                  onClick={() => this.handleSelectAll("four")}
                />
              }
            >
              <CheckboxGroup
                name="four"
                selectedValues={selectedValues.four}
                onSelectedChange={data =>
                  this.handleSelectedChange("four", data)
                }
                // rightAddon={(
                //   <Button label={(selectedValues.four.length === groupValues.four.length) ? 'Unselect All' : 'Select All'} style={{ fontSize: '0.8em' }} type={null} onClick={() => this.handleSelectAll('four')} />
                // )}
              >
                <Checkbox value="1">{`${getDisplayValue(
                  TAG390
                )} : ${getDisplayValue(TAG391)}`}</Checkbox>
                <Checkbox value="2">{`${getDisplayValue(
                  TAG390
                )} : ${getDisplayValue(TAG393)}`}</Checkbox>
                <Checkbox value="3">{`${getDisplayValue(
                  TAG390
                )} : ${getDisplayValue(TAG405)}`}</Checkbox>
                <Checkbox value="4">{`${getDisplayValue(
                  TAG390
                )} : ${getDisplayValue(TAG454)}`}</Checkbox>
              </CheckboxGroup>
            </Section>
          </GridItem>
          <GridItem cols={4}>
            <Section
              isOpen={isOpen.two}
              onOpenChange={() => this.handleOpenChange("two")}
              title={getDisplayValue(TAG050)}
              rightAddon={
                <Button
                  label={
                    selectedValues.two.length === groupValues.two.length
                      ? "Unselect All"
                      : "Select All"
                  }
                  style={{ fontSize: "0.8em" }}
                  type={null}
                  onClick={() => this.handleSelectAll("two")}
                />
              }
            >
              <CheckboxGroup
                name="two"
                selectedValues={selectedValues.two}
                onSelectedChange={data =>
                  this.handleSelectedChange("two", data)
                }
              >
                <Checkbox value="1">{getDisplayValue(TAG424)}</Checkbox>
                <Checkbox value="2">{getDisplayValue(TAG425)}</Checkbox>
                <Checkbox value="3">{getDisplayValue(TAG426)}</Checkbox>
                <Checkbox value="4">{getDisplayValue(TAG427)}</Checkbox>
                <Checkbox value="5">{getDisplayValue(TAG428)}</Checkbox>
                <Checkbox value="6">{getDisplayValue(TAG429)}</Checkbox>
                <Checkbox value="7">{getDisplayValue(TAG430)}</Checkbox>
                <Checkbox value="8">{getDisplayValue(TAG215)}</Checkbox>
                <Checkbox value="9">{getDisplayValue(TAG236)}</Checkbox>
                <Checkbox value="10">{getDisplayValue(TAG274)}</Checkbox>
                <Checkbox value="11">{getDisplayValue(TAG431)}</Checkbox>
                <Checkbox value="12">{getDisplayValue(TAG432)}</Checkbox>
                <Checkbox value="13">{getDisplayValue(TAG275)}</Checkbox>
                <Checkbox value="14">{getDisplayValue(TAG433)}</Checkbox>
                <Checkbox value="15">{getDisplayValue(TAG434)}</Checkbox>
                <Checkbox value="16">{getDisplayValue(TAG435)}</Checkbox>
                <Checkbox value="17">{getDisplayValue(TAG436)}</Checkbox>
                <Checkbox value="18">{getDisplayValue(TAG437)}</Checkbox>
                <Checkbox value="19">{getDisplayValue(EVENTSTAG143)}</Checkbox>
                <Checkbox value="20">{getDisplayValue(TAG438)}</Checkbox>
                <Checkbox value="21">{getDisplayValue(TAG439)}</Checkbox>
                <Checkbox value="22">{getDisplayValue(TAG375)}</Checkbox>
                <Checkbox value="23">{getDisplayValue(TAG343)}</Checkbox>
                <Checkbox value="24">{getDisplayValue(TAG344)}</Checkbox>
              </CheckboxGroup>
            </Section>

            <Section
              isOpen={isOpen.five}
              onOpenChange={() => this.handleOpenChange("five")}
              title={getDisplayValue(TAG085)}
              rightAddon={
                <Button
                  label={
                    selectedValues.five.length === groupValues.five.length
                      ? "Unselect All"
                      : "Select All"
                  }
                  style={{ fontSize: "0.8em" }}
                  type={null}
                  onClick={() => this.handleSelectAll("five")}
                />
              }
            >
              <CheckboxGroup
                name="five"
                selectedValues={selectedValues.five}
                onSelectedChange={data =>
                  this.handleSelectedChange("five", data)
                }
                // rightAddon={(
                //   <Button label={(selectedValues.five.length === groupValues.five.length) ? 'Unselect All' : 'Select All'} style={{ fontSize: '0.8em' }} type={null} onClick={() => this.handleSelectAll('five')} />
                // )}
              >
                <Checkbox value="1">{getDisplayValue(TAG444)}</Checkbox>
              </CheckboxGroup>
            </Section>
          </GridItem>
          <GridItem cols={4}>
            <Section
              isOpen={isOpen.three}
              onOpenChange={() => this.handleOpenChange("three")}
              title={getDisplayValue(TAG392)}
              rightAddon={
                <Button
                  label={
                    selectedValues.three.length === groupValues.three.length
                      ? "Unselect All"
                      : "Select All"
                  }
                  style={{ fontSize: "0.8em" }}
                  type={null}
                  onClick={() => this.handleSelectAll("three")}
                />
              }
            >
              <CheckboxGroup
                name="three"
                selectedValues={selectedValues.three}
                onSelectedChange={data =>
                  this.handleSelectedChange("three", data)
                }
              >
                <Checkbox value="1">{getDisplayValue(TAG385)}</Checkbox>
                <Checkbox value="2">{getDisplayValue(TAG442)}</Checkbox>
                <Checkbox value="3">{getDisplayValue(TAG443)}</Checkbox>
              </CheckboxGroup>
            </Section>
          </GridItem>
        </GridRow>
      </Grid>
    );
  }
}
DeployUISettingsSettings.defaultProps = defaultProps;
DeployUISettingsSettings.propTypes = propTypes;
export default DeployUISettingsSettings;
