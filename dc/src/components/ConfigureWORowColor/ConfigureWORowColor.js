import React, { Component } from "react";
import { Tabs, Tab } from "@svmx/ui-components-lightning";
import { isEqual } from "lodash";
import { getDisplayValue } from "utils/DCUtils";
import { TAG269, TAG270, EVENTSTAG139 } from "constants/DisplayTagConstants";
import ColorHightlight from "./ColorHighlight";
import ColorCounters from "./ColorCounters";
import ColorRules from "./ColorRules";

class ConfigureWORowColor extends Component {
  state = {
    activeKey: this.props.activeKey
  };

  shouldComponentUpdate(nextProps) {
    const { woRules } = this.props;
    const { activeKey } = this.state;
    return (
      !isEqual(woRules, nextProps.woRules) ||
      !isEqual(activeKey, nextProps.activeKey)
    );
  }

  componentWillReceiveProps(nextProps) {
    const { activeKey } = nextProps;
    this.setState({ activeKey });
    if (activeKey !== this.props.activeKey) {
      this.setState({ activeKey });
    }
  }

  handleConfigurationChange = (modifiedColorRules, activeRuleIndex) => {
    const { onRulesModified } = this.props;
    onRulesModified(modifiedColorRules, activeRuleIndex);
  };

  handleHighlightModified = (hoveredColor, selectedColor) => {
    const { onHighlightsModified } = this.props;
    onHighlightsModified(hoveredColor, selectedColor);
  };

  handleViewCounterModified = modifiedViewConter => {
    const { onViewCounterModified } = this.props;
    onViewCounterModified(modifiedViewConter);
  };

  handleChange = tabObj => {
    this.setState({ activeKey: tabObj.tabKey });
  };

  render() {
    const {
      deleteConfirmation,
      formRef,
      getDeleteRef,
      onCustomValidationError,
      onSubmitSuccess,
      sourceItems,
      viewCounter,
      views,
      woRules,
      woHoverColor,
      woSelectionColor
    } = this.props;
    const { activeKey } = this.state;
    return (
      <Tabs type="scoped" activeKey={activeKey} onSelect={this.handleChange}>
        <Tab
          className="ConfigureWORowColor__tab"
          eventKey="1"
          title={getDisplayValue(TAG269)}
        >
          <ColorRules
            deleteConfirmation={deleteConfirmation}
            getDeleteRef={getDeleteRef}
            colorRules={woRules}
            formRef={formRef}
            sourceItems={sourceItems}
            onConfigurationChange={this.handleConfigurationChange}
            onSubmitSuccess={onSubmitSuccess}
            onCustomValidationError={onCustomValidationError}
          />
        </Tab>
        <Tab
          className="ConfigureWORowColor__tab"
          eventKey="2"
          title={getDisplayValue(TAG270)}
        >
          <ColorHightlight
            hoverColor={woHoverColor}
            selectionColor={woSelectionColor}
            onHighlightChange={this.handleHighlightModified}
          />
        </Tab>
        <Tab
          className="ConfigureWORowColor__tab"
          eventKey="3"
          title={getDisplayValue(EVENTSTAG139)}
        >
          <ColorCounters
            views={viewCounter}
            picklistItems={views}
            onViewCounterChange={this.handleViewCounterModified}
          />
        </Tab>
      </Tabs>
    );
  }
}

export default ConfigureWORowColor;
