import React from "react";
import { PropTypes } from "prop-types";
import {
  Container,
  GridRow,
  GridItem,
  Label
} from "@svmx/ui-components-lightning";
import { createRow, getGridColumns } from "utils/GridUtils";
import { isView } from "utils/ViewUtils";

const TechWOSummaryTab = props => {
  const { selectedWO, userTimezone, view, woCol, woFields } = props;
  const { content } = userTimezone;
  const { id } = content;
  const defaultColumns = isView(view) ? undefined : woCol;
  const columns = getGridColumns(view, defaultColumns, woFields);
  const row = createRow(selectedWO, columns, woFields, id);
  const data = { ...row };
  delete data.Id;
  return (
    <Container className="AdvancedSearch__Grid-tableContent">
      {columns.map(column => {
        const { accessor, Header } = column;
        const value = data[accessor];
        return (
          <GridRow>
            <GridItem noFlex>
              <Label>
                <b>{`${Header}:`}</b>
              </Label>
            </GridItem>
            <GridItem noFlex>
              <Label>{value}</Label>
            </GridItem>
          </GridRow>
        );
      })}
    </Container>
  );
};

TechWOSummaryTab.propTypes = {
  selectedWO: PropTypes.shape({}).isRequired,
  userTimezone: PropTypes.shape({}).isRequired,
  view: PropTypes.shape({}).isRequired,
  woCol: PropTypes.arrayOf(PropTypes.Object).isRequired,
  woFields: PropTypes.shape({}).isRequired
};

export default TechWOSummaryTab;
