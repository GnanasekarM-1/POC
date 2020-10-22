/**
 * Component dependencies.
 * @private
 */

import React from "react";
import ReactDOM from "react-dom";
import PropTypes from "prop-types";

/**
 * The NewWindow class object.
 * @public
 */

class NewWindowPortal extends React.PureComponent {
  /**
   * NewWindow default props.
   */
  static defaultProps = {
    url: "",
    name: "",
    title: "",
    features: { width: "600px", height: "640px" },
    onBlock: null,
    onOpen: null,
    onUnload: null,
    center: "parent",
    copyStyles: true
  };

  /**
   * The NewWindow function constructor.
   * @param {Object} props
   */
  constructor(props) {
    super(props);
    this.container = document.createElement("div");
    this.window = null;
    this.windowCheckerInterval = null;
    this.released = false;
    this.state = {
      mounted: false
    };
  }

  /**
   * Render the NewWindow component.
   */
  render() {
    if (!this.state.mounted) return null;
    return ReactDOM.createPortal(this.props.children, this.container);
  }

  componentDidMount() {
    this.openChild();
    this.setState({ mounted: true });
  }

  /**
   * Create the new window when NewWindow component mount.
   */
  openChild() {
    const { url, title, name, features, onBlock, onOpen, center } = this.props;

    // Prepare position of the new window to be centered against the 'parent' window or 'screen'.
    if (
      typeof center === "string" &&
      (features.width === undefined || features.height === undefined)
    ) {
      console.warn(
        "width and height window features must be present when a center prop is provided"
      );
    } else if (center === "parent") {
      features.left =
        window.top.outerWidth / 2 + window.top.screenX - features.width / 2;
      features.top =
        window.top.outerHeight / 2 + window.top.screenY - features.height / 2;
    } else if (center === "screen") {
      const screenLeft =
        window.screenLeft !== undefined
          ? window.screenLeft
          : window.screen.left;
      const screenTop =
        window.screenTop !== undefined ? window.screenTop : window.screen.top;

      const width = window.innerWidth
        ? window.innerWidth
        : document.documentElement.clientWidth
        ? document.documentElement.clientWidth
        : window.screen.width;
      const height = window.innerHeight
        ? window.innerHeight
        : document.documentElement.clientHeight
        ? document.documentElement.clientHeight
        : window.screen.height;

      features.left = width / 2 - features.width / 2 + screenLeft;
      features.top = height / 2 - features.height / 2 + screenTop;
    }

    // Open a new window.
    this.window = window.open(url, name, toWindowFeatures(features));

    // When a new window use content from a cross-origin there's no way we can attach event
    // to it. Therefore, we need to detect in a interval when the new window was destroyed
    // or was closed.
    this.windowCheckerInterval = setInterval(() => {
      if (!this.window || this.window.closed) {
        this.release();
      }
    }, 50);

    // Check if the new window was succesfully opened.
    if (this.window) {
      this.window.document.title = title;
      this.window.document.write("<html><head></head><body></body></html>");
      this.window.document.body.appendChild(this.container);

      // If specified, copy styles from parent window's document.
      if (this.props.copyStyles) {
        setTimeout(() => copyStyles(document, this.window.document), 0);
      }

      if (typeof onOpen === "function") {
        onOpen(this.window);
      }

      // Release anything bound to this component before the new window unload.
      // this.window.document.head.innerHTML = document.head.innerHTML;
      this.window.document.title = document.title;
      this.window.document.geometry = window.google.maps.geometry;
      this.window.addEventListener("beforeunload", () => this.release());
      const objectTag = document.createElement("object");
      objectTag.setAttribute("type", "image/svg+xml");
      const objectPath =
        window.location.hostname == "localhost"
          ? "/assets//icons/utility-sprite/svg/symbols.svg"
          : "/_slds//icons/utility-sprite/svg/symbols.svg";
      objectTag.setAttribute("data", window.location.origin + objectPath);
      objectTag.style.height = "0px";
      this.window.document.body.appendChild(objectTag);
      const scriptSvg =
        'var allSvgObj = document.querySelector("object").getSVGDocument();\r\ndocument.querySelectorAll("svg use").forEach(element => {\r\n var selectedIcon = element.getAttribute("xlink:href").split("#")[1];\r\n if (selectedIcon !== "none") {\r\n\tvar selectedSvg = allSvgObj.querySelector("#" + selectedIcon);\r\n\tif(selectedSvg) {\r\n\t\tvar viewBoxSize = selectedSvg.getAttribute("viewBox");\r\n\t\telement.parentElement.innerHTML = "<svg xmlns=\'http://www.w3.org/2000/svg\' viewBox=\'"+ viewBoxSize +"\'>" + selectedSvg.innerHTML + "</svg>";\r\n\t}\r\n}\r\n});';
      const scriptToDisableCal =
        'setTimeout(function(){if(document.querySelector(".DateInput input")){document.querySelector(".DateInput input").onclick = function() {setTimeout(function(){document.querySelector(".Datepicker").style.display="none";},0);};}},500);';
      const scriptStr = `setInterval(function(){ ${scriptSvg} ${scriptToDisableCal} }, 500);`;
      const scriptTag = document.createElement("SCRIPT");
      // const scriptStrLink = "document.querySelectorAll(\"link\").forEach(element => {\r\n\tvar elementHref = element.getAttribute(\"href\");\r\n\tconsole.log(elementHref);\r\n\tif(elementHref[0] == \"\/\") {\r\n\t\telement.href = \""+window.location.origin+"\" + elementHref;\r\n\t}\r\n});";
      const scriptBodyClassStr = 'document.body.classList.add("slds-scope");';
      const script = document.createTextNode(scriptStr + scriptBodyClassStr);
      scriptTag.appendChild(script);
      this.window.document.body.appendChild(scriptTag);
    } else {
      // Handle error on opening of new window.
      if (typeof onBlock === "function") {
        onBlock(null);
      } else {
        console.warn("A new window could not be opened. Maybe it was blocked.");
      }
    }
  }

  /**
   * Close the opened window (if any) when NewWindow will unmount.
   */
  componentWillUnmount() {
    if (this.window) {
      this.window.close();
    }
  }

  /**
   * Release the new window and anything that was bound to it.
   */
  release() {
    // This method can be called once.
    if (this.released) {
      return;
    }
    this.released = true;

    // Remove checker interval.
    clearInterval(this.windowCheckerInterval);

    // Call any function bound to the `onUnload` prop.
    const { onUnload } = this.props;

    if (typeof onUnload === "function") {
      onUnload(null);
    }
  }
}

NewWindowPortal.propTypes = {
  children: PropTypes.node,
  url: PropTypes.string,
  name: PropTypes.string,
  title: PropTypes.string,
  features: PropTypes.object,
  onUnload: PropTypes.func,
  onBlock: PropTypes.func,
  onOpen: PropTypes.func,
  center: PropTypes.oneOf(["parent", "screen"]),
  copyStyles: PropTypes.bool
};

/**
 * Utility functions.
 * @private
 */

/**
 * Copy styles from a source document to a target.
 * @param {Object} source
 * @param {Object} target
 * @private
 */

function testCopyStyles(source, target) {
  const compStyles = window.getComputedStyle(source);
  target.head.appendChild(compStyles);
}

function copyStyles(source, target) {
  Array.from(source.styleSheets).forEach(styleSheet => {
    // For <style> elements
    let rules;
    try {
      rules = styleSheet.cssRules;
    } catch (err) {
      console.error(err);
    }
    // if you want to stop copying link elements, styleSheet.ownerNode.tagName != "LINK"
    if (rules) {
      const newStyleEl = source.createElement("style");

      // Write the text of each rule into the body of the style element
      Array.from(styleSheet.cssRules).forEach(cssRule => {
        const { cssText, type } = cssRule;
        let returnText = cssText;
        // Check if the cssRule type is CSSImportRule (3) or CSSFontFaceRule (5) to handle local imports on a about:blank page
        // '/custom.css' turns to 'http://my-site.com/custom.css'
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
        // Stoping overriding datePicker classes to copy to new window
        if (cssText.indexOf("datePicker") == -1) {
          newStyleEl.appendChild(source.createTextNode(returnText));
        }
      });

      target.head.appendChild(newStyleEl);
    } else if (styleSheet.href) {
      // for <link> elements loading CSS from a URL
      const newLinkEl = source.createElement("link");

      newLinkEl.rel = "stylesheet";
      newLinkEl.href = styleSheet.href;
      // newLinkEl.target="_parent";
      target.head.appendChild(newLinkEl);
    }
  });
}

/**
 * Convert features props to window features format (name=value,other=value).
 * @param {Object} obj
 * @return {String}
 * @private
 */

function toWindowFeatures(obj) {
  return Object.keys(obj)
    .reduce((features, name) => {
      const value = obj[name];
      if (typeof value === "boolean") {
        features.push(`${name}=${value ? "yes" : "no"}`);
      } else {
        features.push(`${name}=${value}`);
      }
      return features;
    }, [])
    .join(",");
}

/**
 * Component export.
 * @private
 */

export default NewWindowPortal;
