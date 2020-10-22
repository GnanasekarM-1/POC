import React, { Component } from "react";
import {
  ColorPicker,
  Grid,
  GridItem,
  GridRow,
  Label
} from "@svmx/ui-components-lightning";
import { convertUint2Hex, getDisplayValue } from "utils/DCUtils";
import { HOVER_COLOR, SELECTION_COLOR } from "constants/AppConstants";

import "./ConfigureWORowColor.scss";

class ColorHighlight extends Component {
  constructor(props) {
    super(props);
    this.state = {
      hoveredColor: convertUint2Hex(props.hoverColor),
      selectedColor: convertUint2Hex(props.selectionColor)
    };
  }

  handleColorChange = (data, name) => {
    const { value } = data;
    const { hoveredColor, selectedColor } = this.state;
    const { onHighlightChange } = this.props;
    switch (name) {
      case HOVER_COLOR:
        this.setState(
          { hoveredColor: value },
          onHighlightChange(value, selectedColor)
        );
        break;
      case SELECTION_COLOR:
        this.setState(
          { selectedColor: value },
          onHighlightChange(hoveredColor, value)
        );
        break;

      default:
        break;
    }
  };

  render() {
    const { hoveredColor, selectedColor } = this.state;
    return (
      <Grid className="ColorHighlight slds-gutters" isVertical>
        <GridRow>
          <GridItem noFlex>
            <ColorPicker
              name="hoveredColor"
              value={hoveredColor}
              onValueChange={data => this.handleColorChange(data, HOVER_COLOR)}
            />
          </GridItem>
          <GridItem noFlex>
            <Label>
              {getDisplayValue("TAG272")} - this color is used to highlight the
              borders of the row when the mouse hovers over it
            </Label>
          </GridItem>
        </GridRow>
        <GridRow style={{ paddingTop: "0.25em" }}>
          <GridItem noFlex>
            <ColorPicker
              name="selectedColor"
              value={selectedColor}
              onValueChange={data =>
                this.handleColorChange(data, SELECTION_COLOR)
              }
            />
          </GridItem>
          <GridItem noFlex>
            <Label>
              {getDisplayValue("TAG273")} - this color is used to highlight the
              row when it is selected
            </Label>
          </GridItem>
        </GridRow>
      </Grid>
    );
  }
}

export default ColorHighlight;
