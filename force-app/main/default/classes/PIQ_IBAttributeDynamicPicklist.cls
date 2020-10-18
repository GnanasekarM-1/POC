public class PIQ_IBAttributeDynamicPicklist extends VisualEditor.DynamicPicklist{

    VisualEditor.DesignTimePageContext context;

    public PIQ_IBAttributeDynamicPicklist(VisualEditor.DesignTimePageContext context){
        this.context = context;
    }

    public override VisualEditor.DataRow getDefaultValue(){
        return null;
    }

    public override VisualEditor.DynamicPicklistRows getValues(){

        String pageObjName = context.entityName;
        system.debug(LoggingLevel.DEBUG, 'Loading on object = '+pageObjName );

        string relatedObj = 'SVMXC__Installed_Product__c';

        List<String> validAPINames = new List<String>();
        SObjectType objectType = Schema.getGlobalDescribe().get(pageObjName);
        Map<String, Schema.SObjectField> fieldMap = objectType.getDescribe().fields.getMap();
        for(Schema.SObjectField field : fieldMap.values()){
            Schema.DescribeFieldResult descField = field.getDescribe();
            if(descField.getType() == Schema.DisplayType.Reference){   // If it's a reference fields
                for(Schema.sObjectType eachRef: descField.getReferenceTo()){   
                    if(eachRef.getDescribe().getName() == relatedObj){  //And it refers to 'Installed product', display this field in the picklist
                        validAPINames.add(descField.getName());
                    }
                }
            }
        }
        system.debug(LoggingLevel.WARN,'validAPINames = '+validAPINames);

        VisualEditor.DynamicPickListRows  picklistValues = new VisualEditor.DynamicPickListRows();
        
        for(String eachAPI: validAPINames){
            picklistValues.addRow(new VisualEditor.DataRow(eachAPI, eachAPI));
        }
        
        return picklistValues;
    }
}