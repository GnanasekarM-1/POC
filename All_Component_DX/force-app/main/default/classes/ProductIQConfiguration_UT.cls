@isTest
Private class ProductIQConfiguration_UT{

    static testMethod void ProductIQConfiguration_Test(){
		ProductIQConfiguration objPIQ = new ProductIQConfiguration();
		
		SVMXC.ProductIQConfiguration.Action objAction1 = new SVMXC.ProductIQConfiguration.Action();
		SVMXC.ProductIQConfiguration.Action objAction2 = new SVMXC.ProductIQConfiguration.Action('','','',true,'');
		
		SVMXC.ProductIQConfiguration.Expression objExpression1 = new SVMXC.ProductIQConfiguration.Expression();
		SVMXC.ProductIQConfiguration.Expression objExpression2 = new SVMXC.ProductIQConfiguration.Expression('','',new List<SVMXC.ProductIQConfiguration.Expression>());
		SVMXC.ProductIQConfiguration.Expression objExpression3 = new SVMXC.ProductIQConfiguration.Expression('','');
		SVMXC.ProductIQConfiguration.Expression objExpression4 = new SVMXC.ProductIQConfiguration.Expression('','','','');
		SVMXC.ProductIQConfiguration.Expression objExpression5 = new SVMXC.ProductIQConfiguration.Expression('','','','','','','');
		
		SVMXC.ProductIQConfiguration.Filter objFilter1 = new SVMXC.ProductIQConfiguration.Filter();
		SVMXC.ProductIQConfiguration.Filter objFilter2 = new SVMXC.ProductIQConfiguration.Filter('',true,new SVMXC.ProductIQConfiguration.Expression());
		
		SVMXC.ProductIQConfiguration.Profile objProfile1 = new SVMXC.ProductIQConfiguration.Profile();
		SVMXC.ProductIQConfiguration.Profile objProfile2 = new SVMXC.ProductIQConfiguration.Profile('','');
		
		SVMXC.ProductIQConfiguration.Configuration objConfiguration1 = new SVMXC.ProductIQConfiguration.Configuration();
		
		SVMXC.ProductIQConfiguration.IBTemplates objIBTemplates1 = new SVMXC.ProductIQConfiguration.IBTemplates();
		
		SVMXC.ProductIQConfiguration.ProductConfiguration objProductConfiguration1 = new SVMXC.ProductIQConfiguration.ProductConfiguration('','');
		
		SVMXC.ProductIQConfiguration.Product objProduct1 = new SVMXC.ProductIQConfiguration.Product();
		
		SVMXC.ProductIQConfiguration.TemplateDetails objTemplateDetails1 = new SVMXC.ProductIQConfiguration.TemplateDetails();
		
		SVMXC.ProductIQConfiguration.Template objTemplate1 = new SVMXC.ProductIQConfiguration.Template();
		SVMXC.ProductIQConfiguration.Template objTemplate2 = new SVMXC.ProductIQConfiguration.Template('','');

		SVMXC.ProductIQConfiguration.TemplateHeader objTemplateHeader1 = new SVMXC.ProductIQConfiguration.TemplateHeader();
		SVMXC.ProductIQConfiguration.TemplateHeader objTemplateHeader2 = new SVMXC.ProductIQConfiguration.TemplateHeader('','',objTemplate1);

		SVMXC.ProductIQConfiguration.URLParameters objURLParameters1 = new SVMXC.ProductIQConfiguration.URLParameters('','','');
		
		SVMXC.ProductIQConfiguration.Mapping objMapping1 = new SVMXC.ProductIQConfiguration.Mapping();
		
		SVMXC.ProductIQConfiguration.FieldMapping objFieldMapping1 = new SVMXC.ProductIQConfiguration.FieldMapping();
		
		SVMXC.ProductIQConfiguration.CustomActionURL objCustomActionURL1 = new SVMXC.ProductIQConfiguration.CustomActionURL('','','', new List<SVMXC.ProductIQConfiguration.URLParameters>());
		
		SVMXC.ProductIQConfiguration.Field objField1 = new SVMXC.ProductIQConfiguration.Field();
		
		SVMXC.ProductIQConfiguration.DataValidationRuleInfo objDataValidationRuleInfo1 = new SVMXC.ProductIQConfiguration.DataValidationRuleInfo('','','','','','','');
		
		SVMXC.ProductIQConfiguration.DataValidationRule objDataValidationRule1 = new SVMXC.ProductIQConfiguration.DataValidationRule(objDataValidationRuleInfo1, new List<SVMXC.ProductIQConfiguration.Expression>());
		
		
		SVMXC.ProductIQConfiguration.DataValidationRulesWithObjectInfo objDataValidationRulesWithObjectInfo1 = new SVMXC.ProductIQConfiguration.DataValidationRulesWithObjectInfo('Case', new List<SVMXC.ProductIQConfiguration.DataValidationRuleInfo>());
	}
}