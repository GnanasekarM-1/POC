import React, { Component } from "react";
import { Label, Button, Icon, GridItem } from "@svmx/ui-components-lightning";
import "./SchedulerToolbar.scss";

class NewEvent extends Component {
  state = {};

  render() {
    return (
      <GridItem>
        {/* <Label>
            Events
          </Label>
          <div className="SchedulerToolbar__Item">
            <Button type="icon-bare" size="small">
              <Icon icon="delete" size="x-small" />
            </Button>
            <Button type="icon-bare" size="small">
              <Icon icon="add" size="x-small" />
            </Button>
          </div> */}
      </GridItem>
    );
  }
}

export default NewEvent;
