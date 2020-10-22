import React from "react";
import {
  Grid,
  GridRow,
  GridItem,
  Spinner
} from "@svmx/ui-components-lightning";

const LoadIndicator = () => (
  <Grid isVertical>
    <GridRow>
      <GridItem>
        <Spinner size="large" />
      </GridItem>
    </GridRow>
  </Grid>
);
export default LoadIndicator;
