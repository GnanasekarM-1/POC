import React from "react";
import ReactDOM from "react-dom";
import PropTypes from "prop-types";

import MapContainer from "containers/MapContainer/MapContainer";

const defaultProps = {
  parentWindow: window
};

const propTypes = {
  onWindowClose: PropTypes.func.isRequired,
  parentWindow: PropTypes.window
};

export default class MapWindowPortal extends React.PureComponent {
  constructor(props) {
    super(props);
    // STEP 1: create a container <div>
    this.containerEl = document.createElement("div");
    this.externalWindow = null;
    this.externalWindow = window.open(
      "",
      "_blank",
      "location=no",
      "width=800,height=600,resizable=1,status=0,scrollbars=1"
    );
    this.externalWindow.addEventListener("beforeunload", ev => {
      ev.preventDefault();
      return this.handleWindowCloseBeforeUnload();
    });
  }

  componentWillUnmount() {
    this.externalWindow.close();
  }

  copyStyles = (source, target) => {
    Array.from(source.styleSheets).forEach(styleSheet => {
      // For <style> elements
      let rules;
      try {
        rules = styleSheet.cssRules;
      } catch (err) {
        // //console.error(err)
      }
      if (rules) {
        const newStyleEl = source.createElement("style");

        // Write the text of each rule into the body of the style element
        Array.from(styleSheet.cssRules).forEach(cssRule => {
          const { cssText, type } = cssRule;
          let returnText = cssText;
          // Check if the cssRule type is CSSImportRule (3) or CSSFontFaceRule (5)
          // to handle local imports on a about:blank page
          if ([3, 5].includes(type)) {
            returnText = cssText
              .split("url(")
              .map(line => {
                if (line[1] === "/") {
                  return `${line.slice(0, 1)}${
                    window.location.origin
                  }${line.slice(1)}`;
                }
                return line;
              })
              .join("url(");
          }
          newStyleEl.appendChild(source.createTextNode(returnText));
        });

        target.head.appendChild(newStyleEl);
      } else if (styleSheet.href) {
        // for <link> elements loading CSS from a URL
        const newLinkEl = source.createElement("link");

        newLinkEl.rel = "stylesheet";
        newLinkEl.href = styleSheet.href;
        target.head.appendChild(newLinkEl);
      }
    });
  };

  handleWindowCloseBeforeUnload = () => {
    const { onWindowClose } = this.props;
    onWindowClose();
  };

  render() {
    const { parentWindow } = this.props;
    if (!this.containerEl) {
      return null;
    }
    this.externalWindow.id = "NewMapWindow";
    if (this.externalWindow) {
      setTimeout(
        () => this.copyStyles(document, this.externalWindow.document),
        0
      );
    }
    // this.externalWindow.google = parentWindow.google;
    this.externalWindow.document.head.style = parentWindow.document.head.style;
    this.externalWindow.document.body.appendChild(this.containerEl);
    // this.externalWindow.ASSET_ROOT = '/assets';

    return ReactDOM.createPortal(
      <div>
        <MapContainer
          currentWindow={this.externalWindow}
          shouldShowPortalWindowButton={false}
        />
      </div>,
      this.containerEl
    );
  }
}

MapWindowPortal.defaultProps = defaultProps;
MapWindowPortal.propTypes = propTypes;
