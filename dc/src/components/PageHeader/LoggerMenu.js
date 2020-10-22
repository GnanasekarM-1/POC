import React from "react";
import {
  Dropdown,
  Button,
  Menu,
  MenuItem,
  Icon
} from "@svmx/ui-components-lightning";

const LoggerMenu = () => (
  <Dropdown>
    <Button type="icon-bare" size="small">
      <Icon icon="rows" />
    </Button>
    <Menu className="DropdownStory__menu">
      <MenuItem value="1">Menu Item One</MenuItem>
      <MenuItem value="2" isDisabled>
        Menu Item Two
      </MenuItem>
      <MenuItem value="3">Menu Item Three</MenuItem>
      <MenuItem value="4">Menu Item Four</MenuItem>
    </Menu>
  </Dropdown>
);

export default LoggerMenu;
