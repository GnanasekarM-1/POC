import React, { Component } from "react";
import {
  ColorPicker,
  Grid,
  GridRow,
  Label,
  GridItem,
  Text
} from "@svmx/ui-components-lightning";
import {
  convertUint2Hex,
  getDisplayValue,
  stringToBoolean
} from "utils/DCUtils";
import { SET072, getSettingValue } from "constants/AppSettings";
import { isEqual } from "lodash";

class ConfTechEventColors extends Component {
  constructor(props) {
    super(props);

    const {
      defaultEventColor,
      defaultWOEventColor,
      driveColor,
      holidayHoursColor,
      overheadColor,
      overNightStayColor,
      relatedEventColor,
      workingHoursColor
    } = props;
    const techWorkingHours = getSettingValue(SET072);
    const showTechColor = stringToBoolean(techWorkingHours);
    this.state = {
      defaultEveColor: defaultEventColor,
      defaultWOEveColor: defaultWOEventColor,
      driveEveColor: driveColor,
      holidayHrColor: holidayHoursColor,
      overhdColor: overheadColor,
      overNightColor: overNightStayColor,
      relatedEveColor: relatedEventColor,
      workingHrColor: workingHoursColor,
      showTechnicianWorkingHours: showTechColor
    };
  }

  shouldComponentUpdate(nextProps, nextState) {
    return !isEqual(this.state, nextState);
  }

  handleColorChange = (data, name) => {
    const { value } = data;
    switch (name) {
      case "driveColor":
        this.setState({ driveEveColor: value });
        this.callParent(value, "tech_driveColor");
        break;
      case "overheadColor":
        this.setState({ overhdColor: value });
        this.callParent(value, "tech_overheadColor");
        break;
      case "defaultWOEventColor":
        this.setState({ defaultWOEveColor: value });
        this.callParent(value, "tech_defaultWOEventColor");
        break;
      case "defaultEventColor":
        this.setState({ defaultEveColor: value });
        this.callParent(value, "tech_defaultEventColor");
        break;
      case "relatedEventColor":
        this.setState({ relatedEveColor: value });
        this.callParent(value, "tech_relatedEventColor");
        break;
      case "overNightStayColor":
        this.setState({ overNightColor: value });
        this.callParent(value, "tech_overNightStayColor");
        break;
      case "workingHoursColor":
        this.setState({ workingHrColor: value });
        this.callParent(value, "tech_workingHoursColor");
        break;
      case "holidayHoursColor":
        this.setState({ holidayHrColor: value });
        this.callParent(value, "tech_holidayHoursColor");
        break;
      default:
        break;
    }
  };

  callParent = (value, prop) => {
    const { onValueChange } = this.props;
    onValueChange(value, prop);
  };

  render() {
    const {
      defaultEveColor,
      defaultWOEveColor,
      driveEveColor,
      holidayHrColor,
      overhdColor,
      overNightColor,
      relatedEveColor,
      workingHrColor,
      showTechnicianWorkingHours
    } = this.state;

    return (
      <Grid className="slds-gutters" isVertical>
        <Text
          className="EventColorRule__header"
          category="heading"
          size="small"
          tag="div"
        >
          {getDisplayValue("TAG062")}
        </Text>
        <GridRow>
          <GridItem>
            <GridRow className="EventColorRule__gridRow">
              <ColorPicker
                value={convertUint2Hex(driveEveColor)}
                onValueChange={data =>
                  this.handleColorChange(data, "driveColor")
                }
              />
              <Label className="EventColorRule__label">
                {getDisplayValue("TAG206")}
              </Label>
            </GridRow>
            <GridRow className="EventColorRule__gridRow">
              <ColorPicker
                value={convertUint2Hex(overhdColor)}
                onValueChange={data =>
                  this.handleColorChange(data, "overheadColor")
                }
              />
              <Label className="EventColorRule__label">
                {getDisplayValue("TAG409")}
              </Label>
            </GridRow>
            <GridRow className="EventColorRule__gridRow">
              <ColorPicker
                value={convertUint2Hex(defaultWOEveColor)}
                onValueChange={data =>
                  this.handleColorChange(data, "defaultWOEventColor")
                }
              />
              <Label className="EventColorRule__label">
                {getDisplayValue("TAG001")}
              </Label>
            </GridRow>
            <GridRow className="EventColorRule__gridRow">
              <ColorPicker
                value={convertUint2Hex(defaultEveColor)}
                onValueChange={data =>
                  this.handleColorChange(data, "defaultEventColor")
                }
              />
              <Label className="EventColorRule__label">
                {getDisplayValue("TAG303")}
              </Label>
            </GridRow>
          </GridItem>
          <GridItem>
            <GridRow className="EventColorRule__gridRow">
              <ColorPicker
                value={convertUint2Hex(relatedEveColor)}
                onValueChange={data =>
                  this.handleColorChange(data, "relatedEventColor")
                }
              />
              <Label className="EventColorRule__label">
                {getDisplayValue("TAG338")}
              </Label>
            </GridRow>
            <GridRow className="EventColorRule__gridRow">
              <ColorPicker
                value={convertUint2Hex(overNightColor)}
                onValueChange={data =>
                  this.handleColorChange(data, "overNightStayColor")
                }
              />
              <Label className="EventColorRule__label">
                {getDisplayValue("EVENTSTAG143")}
              </Label>
            </GridRow>
            {showTechnicianWorkingHours && (
              <GridRow className="EventColorRule__gridRow">
                <ColorPicker
                  value={convertUint2Hex(workingHrColor)}
                  onValueChange={data =>
                    this.handleColorChange(data, "workingHoursColor")
                  }
                />
                <Label className="EventColorRule__label">
                  {getDisplayValue("TAG484")}
                </Label>
              </GridRow>
            )}
            {showTechnicianWorkingHours && (
              <GridRow className="EventColorRule__gridRow">
                <ColorPicker
                  value={convertUint2Hex(holidayHrColor)}
                  onValueChange={data =>
                    this.handleColorChange(data, "holidayHoursColor")
                  }
                />
                <Label className="EventColorRule__label">
                  {getDisplayValue("TAG483")}
                </Label>
              </GridRow>
            )}
          </GridItem>
        </GridRow>
      </Grid>
    );
  }
}

export default ConfTechEventColors;
