/*****************************************************************************
*                       Copyright (C) 2018 ServiceMax, Inc
*                               All rights reserved
*
*****************************************************************************/

/**
* The COMM_DynamicDesignAttributes extends VisualEditor.DynamicPickList to 
* create Dynamic picklist values for lightning components
* @author Anchal Sharma
* @since 2018
*/
/*****************************************************************************
*    ID        Name                   Date            Comment
*****************************************************************************
*              Anchal Sharma        15 March 2018        Created.     
*****************************************************************************/

public class SFM_Wizard_DynamicDesignAttributes extends VisualEditor.DynamicPickList {
  /*
     * This method assigns the default value to the design attribute
  */
    
    public override VisualEditor.DataRow getDefaultValue(){
        VisualEditor.DataRow defaultValue = new VisualEditor.DataRow(System.Label.SFW001_TAG005, 'medium');
        return defaultValue;
    }
    
    /*
     * This method assigns picklist value to design attribute defined.
  */
    public override VisualEditor.DynamicPickListRows getValues() {
        VisualEditor.DataRow smallVal = new VisualEditor.DataRow(System.Label.SFW001_TAG004, 'small');
        VisualEditor.DataRow mediumVal = new VisualEditor.DataRow( System.Label.SFW001_TAG005, 'medium');
        VisualEditor.DataRow largeVal = new VisualEditor.DataRow(System.Label.SFW001_TAG006, 'large');
        
        VisualEditor.DynamicPickListRows  myValues = new VisualEditor.DynamicPickListRows();
        myValues.addRow(smallVal);
        myValues.addRow(mediumVal);
        myValues.addRow(largeVal);
        return myValues;
    }
    
}