
//HTML Designer Utils method goes here
(function() {
	
	
	var HtmlDesignerUtils = function(){ };
	
	
	HtmlDesignerUtils.prototype.initialize = function (params, parent, callback) {
		
		var describeInfo = params.objDescribeInfo ? params.objDescribeInfo : "";
		var aliasInfo = params.aliasInfo ? params.aliasInfo : "";		
		var template = params.template;		
		this.__callBackMethod = callback;
		this.parent = parent;
		this.__parseTemplate(template, describeInfo);
	}
	    
    window.HtmlDesignerUtils = HtmlDesignerUtils;
		
	HtmlDesignerUtils.prototype.__parseDescribeInfo = function(descirbeInfo){
		
		var parsedDescribeInfo = {};
		var i,l = descirbeInfo.length;
		for(i = 0; i < l; i++){
			
			var parsedFields = {};
			var j,k = descirbeInfo[i].fields.length;
			for(j = 0; j < k ; j++){
				
				parsedFields[descirbeInfo[i].fields[j]["name"]] = descirbeInfo[i].fields[j];
			}
			descirbeInfo[i].parsedFields = parsedFields;
			parsedDescribeInfo[descirbeInfo[i].jsVar] = descirbeInfo[i];			
		}		
		return parsedDescribeInfo;
	}
	
	HtmlDesignerUtils.prototype.__parseTemplate = function(template, describeInfo){
		
		this.__aliasFields = {};		
		this.__describeInfo = this.__parseDescribeInfo(describeInfo);
		this.__allFields = [];
		this.__avoidDupl = {};
		this.__parsedReferenceInfo = {};
		this.__styleImageNames = "";
		this.__signatureUniqueName = {};
		$("#" + "flashContent").append("<div id='" + "document_page" + "'></div>");
		$("#" + "document_page").append(template);
		$("#" + "document_page").hide();
		//processing for svmx-data
		var nodesToProcess = $("[svmx-data]", $("#" + "document_page"));						
		var i = 0, l = nodesToProcess.length;
		for (i = 0; i < l; i++) {
			var node = nodesToProcess[i];
			this.__processNode(node);
		}
		
		//now for inline expressions
		var allInlineNodeTypes = [	{type : "div", 		name: "ILDIV"},
										{type : "strong", 	name: "ILSTRONG"},
										{type : "u", 		name: "ILU"},
										{type : "i", 		name: "ILI"},
										{type : "p", 		name: "ILP"}, 
										{type : "pre", 		name: "ILPRE"},
										{type : "h1", 		name: "ILH"},
										{type : "h2", 		name: "ILH"},
										{type : "h3", 		name: "ILH"},
										{type : "h4", 		name: "ILH"},
										{type : "h5", 		name: "ILH"},
										{type : "h6", 		name: "ILH"},
										{type : "style", 	name: "ILS"},
										{type : "span", 	name: "ILH"},
										{type : "em", 		name: "ILEM"},
										{type : "strike", 	name: "ILSTRIKE"},
										{type : "sub", 		name: "ILSUB"},
										{type : "sup", 		name: "ILSUP"},
										{type : "ol ", 		name: "ILOL"},
										{type : "li", 		name: "ILLI"},
										{type : "ul", 		name: "ILUL"},
										{type : "b", 		name: "ILB"},
										{type : "td", 		name: "ILTD"}], j, k = allInlineNodeTypes.length;
			for(j = 0; j < k; j++){
				nodesToProcess = $(allInlineNodeTypes[j].type, $("#" + "document_page")); l = nodesToProcess.length;
				
				for(i = 0; i < l; i++){
					node = nodesToProcess[i];
					this.__processInlineNodes(node,allInlineNodeTypes[j].type);
				}
		}
		$("#" + "document_page").remove();
		
		var secLvlFlds = this.__getSecondLevelFields();
		if(secLvlFlds){
			
			this.parent.describeObjects(secLvlFlds, function(results){
				this.__parseContent(results);
			}, this);
		}
		else{		
			this.__parseContent();
		}
	}
	
	HtmlDesignerUtils.prototype.__parseContent = function(describeObjectInfo){
		
		//now get the field info
		this.__describeObjectInfo = describeObjectInfo;		
		var allFields = this.__allFields;
		var count = allFields.length;
		for(i = 0; i < count; i++){
			this.__processFieldInfo(allFields[i]);
		}
		//store header images
		this.__aliasFields["SVMX_DOC_Template"] = {"SVMXC__Media_Resources__c" : this.__styleImageNames};
		
		this.__callBackMethod.call(null,this.__aliasFields);
	}
	
	HtmlDesignerUtils.prototype.__getSecondLevelFields = function(){
		
		var fields = this.__allFields;
		var scndlevelRefFields = {};
		var count = fields.length;
		for (i = 0; i < count; i++) {
			var splitString = fields[i].split(".");
			var splitCount = splitString.length;
			if(splitCount >= 4){
				if(splitString[3] && splitString[3].toLowerCase() === "label"){
					continue;
				}
				
				var objFields = this.__describeInfo[splitString[1]].parsedFields[splitString[2]];
				var refInfo = this.__parseReferenceFields(objFields.fields,splitString[3]);
				this.__parsedReferenceInfo[fields[i]] = refInfo;
				if(refInfo.type === 'reference'){
					scndlevelRefFields[refInfo.referenceTo] = refInfo.referenceTo;
				}
			}
		}
		return scndlevelRefFields;
	}
	
	HtmlDesignerUtils.prototype.__processNode = function(node){
		
		var type = $(node)[0].nodeName;
		if(type == "DIV" || type == "TD" || type == "strong" || type == "u" || type == "i" || type == "p" || type == "pre"){
			this.__allFields = this.__allFields.concat(this.__getFieldInfo(node));
		}
		else if(type == "TABLE"){
			this.__allFields = this.__allFields.concat(this.__getTableFieldInfo(node));
		}
		else if(type == "IMG"){
			this.__getImageInfo(node);
		}		
	}
	
	HtmlDesignerUtils.prototype.__processInlineNodes = function(node){
		
		this.__processInlineNodes(node);
	}

	HtmlDesignerUtils.prototype.__getImageInfo = function(node) {
		
		var inlineExpression = $(node).attr("svmx-data");		
		return this.__getImagesFromExpression(inlineExpression);
	}	
	
	HtmlDesignerUtils.prototype.__getFieldInfo = function(node) {
		
		var inlineExpression = $(node).attr("svmx-data");		
		return this.__parseforExpressions(inlineExpression);
	}
	
	HtmlDesignerUtils.prototype.__getFieldsFromExpression = function(expression) {
		
		var str = expression;
		var regex = /^[\da-z._$]+$/i;
		var reqString = '';
		var exprFields = [];
		for(var i = 0;i< str.length;i++){
			if(str.charAt(i) === '$' && str.charAt(i+1) === 'D'){	
				for(var j = i; j < str.length; j++){
					if(!regex.test(str.charAt(j))){
						if(reqString.indexOf(".label") > 0){
							reqString = reqString.substring(0, reqString.indexOf(".label"))
						}
						if(!this.__avoidDupl[reqString]){
							exprFields[exprFields.length] = reqString;
							this.__avoidDupl[reqString] = reqString;					
						}
						reqString = '';
						i = j;
						break;
						
					}
					reqString += str.charAt(j);			
				}
			}
		}
		if(reqString.indexOf(".label") > 0){
			reqString = reqString.substring(0, reqString.indexOf(".label"))
		}
		if(reqString.length > 0 && !this.__avoidDupl[reqString]){
			exprFields[exprFields.length] = reqString;
			this.__avoidDupl[reqString] = reqString;	
		}
		return exprFields;
	}
	
	HtmlDesignerUtils.prototype.__getFieldsFromSNUMBERExpression = function(expression) {
		
		var str = expression;
		var exprFields = [];		
		if(str.indexOf("$F.SNUMBER(") >= 0){
			var str = expression;
		var regex = /^[\da-z._$]+$/i;
		var reqString = '';
		for(var i = 0;i< str.length;i++){
			if(str.charAt(i) === '$' && str.charAt(i+1) === 'D'){	
				for(var j = i; j < str.length; j++){
					if(str.charAt(j) === ',') {
						reqString += ".";
						while(!regex.test(str.charAt(j)) && j < str.length) {
							j = j + 1;
						}
					}else if(!regex.test(str.charAt(j))){
					
						if(!this.__avoidDupl[reqString]){
							exprFields[exprFields.length] = reqString;
							this.__avoidDupl[reqString] = reqString;					
						}
						reqString = '';
						i = j;
						break;						
					}
					reqString += str.charAt(j);			
				}
			}
		}
		if(reqString.length > 0 && !this.__avoidDupl[reqString]){
			exprFields[exprFields.length] = reqString;
			this.__avoidDupl[reqString] = reqString;	
		}		
		}
		return exprFields;	
	}
	
	HtmlDesignerUtils.prototype.__getImagesFromExpression = function(expression) {
		
		var str = expression;
		if(str.indexOf("$F.IMAGE('") >= 0){
			var imageName = str.substring(str.indexOf("$F.IMAGE('") + 10,str.indexOf("')"));
			if(this.__styleImageNames.length > 0) this.__styleImageNames = this.__styleImageNames + ",";
			this.__styleImageNames = this.__styleImageNames + imageName;
		}
		else if(str.indexOf("$F.LOGO(") >= 0){
			if(this.__styleImageNames.length > 0) this.__styleImageNames = this.__styleImageNames + ",";
			this.__styleImageNames = this.__styleImageNames + 'LOGO';
		}		
	}
	
	HtmlDesignerUtils.prototype.__processInlineNodes = function(node,nodeType){
		var children = node.childNodes, i, l = children.length, child, inlineExpression, res;
		for(i = 0; i < l; i++){
			child = children[i];
			if(child.nodeType == 3){
				// text node
				inlineExpression = child.nodeValue;
				this.__allFields = this.__allFields.concat(this.__parseforExpressions(inlineExpression,nodeType));
			}
		}
	}
	
	HtmlDesignerUtils.prototype.__parseforExpressions = function(inlineExpression, nodeType){
				
		var startIndex, endIndex, expression, temp, i;
		var htmlBuffer = [];
		var exprFields = [];			
		if(!inlineExpression) return;		
		i = 0;
		while(true){
			startIndex = inlineExpression.indexOf("{{");
			endIndex = inlineExpression.indexOf("}}");
			
			if(startIndex != -1 && endIndex != -1){
				expression = inlineExpression.substring(startIndex, endIndex + 2);
				    htmlBuffer.push(inlineExpression.substring(0, startIndex) 
								+ "{" + i + "}");
				//temp = inlineExpression.substring(0, startIndex) 
							//	+ "{" + i + "}";
				
				if(endIndex + 2 < inlineExpression.length){
				    htmlBuffer.push(inlineExpression.substring(endIndex + 2));
					////temp += inlineExpression.substring(endIndex + 2);
				}
				temp=htmlBuffer;				
				inlineExpression = temp;
				if(nodeType !== null && nodeType === "style"){ 
					this.__getImagesFromExpression(expression)
				}
				expression = this.__removeSVMXCharacters(expression);
				this.__checkSignatureUniqueName(expression);				
				exprFields = exprFields.concat(this.__getFieldsFromSNUMBERExpression(expression))
				exprFields = exprFields.concat(this.__getFieldsFromExpression(expression))
				i++;				 
			}else{
				//no more expressions
				break;
			}
		}
		return exprFields;
	}
	
	HtmlDesignerUtils.prototype.__checkSignatureUniqueName = function(expr){
		var sigExpr = expr;
		var index = sigExpr.indexOf("$F.SIGNATURE(");
		if (index >= 0) {
			if(sigExpr.indexOf("'",index+14) > 0){			
				var signatureName = sigExpr.substring(index + 14, sigExpr.indexOf("'",index+14));
			}else{
				var signatureName = null;
			}
			
			if(signatureName == null || signatureName.length === 0){
				//error out
				this.__aliasFields.status = "Failure";
				this.__aliasFields.message = "";
				this.__aliasFields.tagNumber = "TAG420";
				this.__callBackMethod.call(null,this.__aliasFields);
			}
			else if(signatureName != null && signatureName.length > 0 && this.__signatureUniqueName[signatureName] === undefined){
				var expr = "[-~!@#$%^&*()+=|/{}:\\[\\]\"';<>,.?\\\\ ]";
				var regexp = new RegExp( ".*" + expr + ".*" , 'gi')
				var isInvalidSignName = regexp.test(signatureName);				
				if(isInvalidSignName){
					this.__aliasFields.status = "Failure";
					this.__aliasFields.message = " " + signatureName;
					this.__aliasFields.tagNumber = "TAG425";
					this.__callBackMethod.call(null,this.__aliasFields);
				}else{
					this.__signatureUniqueName[signatureName] = signatureName;
				}
				
			}
			else{
				//error out
				this.__aliasFields.status = "Failure";
				this.__aliasFields.message = signatureName;
				this.__aliasFields.tagNumber = "TAG419";
				this.__callBackMethod.call(null,this.__aliasFields);
			}
		}
	}
	
	HtmlDesignerUtils.prototype.__getTableFieldInfo = function(node){
		
		var expression = $(node).attr("svmx-data");				
		expression = this.__removeSVMXCharacters(expression);
		var splitString = expression.split(".");
		var count = splitString.length;
		if(count && count > 1){
			this.__aliasExists(splitString[1]);
		}
		var thead = $("thead", $(node));
		var columns = $($(thead[0]).children()[0]).children(), colCount = columns.length, j;		
		var exprFields = [];
		for(j = 0; j < colCount; j++){					
			var cellField = $(columns[j]).attr("svmx-data");			
			if(this.__isExpression(cellField)){
				var fields = this.__parseforExpressions(cellField,"table");
				for(var i = 0; i < fields.length ; i++){
					exprFields[exprFields.length] = fields[i];					
				}
			}else{	
				cellField = this.__removeSVMXCharacters(cellField);
				var reqString = expression + "." + cellField;
				if(reqString.indexOf(".label") > 0){
					reqString = reqString.substring(0, reqString.indexOf(".label"))
				}
				if(!this.__avoidDupl[reqString]){
					exprFields[exprFields.length] = reqString;
					this.__avoidDupl[reqString] = reqString;					
				}
			}
		}
		return exprFields;
	}
	
	HtmlDesignerUtils.prototype.__isExpression = function(expression){
		var isExpression = false;
		if(expression.indexOf("$D") >= 0 || expression.indexOf("$F") >= 0){
			isExpression = true;
		}
		return isExpression;
	}
	
	HtmlDesignerUtils.prototype.__removeSVMXCharacters = function(value){
			return value.substring(2,value.length - 2);
	}
	
	HtmlDesignerUtils.prototype.__processFieldInfo = function(fieldInfo){
		
		//key will be alias and followed by field info		
		//var aliasFields = this.aliasFields;
		var splitString = fieldInfo.split(".");
		var count = splitString.length;
		var params = {"fieldsArray" : splitString,"fieldName" : fieldInfo};
		this.__getFields(params)		
	}
	
	HtmlDesignerUtils.prototype.__getFields = function(params){
		
		var fieldName, aliasName, objectName, fieldname1, fieldname2, fieldname3;
		
		fieldName = params.fieldName;
		aliasName = params.fieldsArray[1] ? params.fieldsArray[1] : "";
		fieldname1 = params.fieldsArray[2] ? params.fieldsArray[2] : "";
		fieldname2 = params.fieldsArray[3] && params.fieldsArray[3].toLowerCase() !== "label" ? params.fieldsArray[3] : "";
		fieldname3 = params.fieldsArray[4] && params.fieldsArray[4].toLowerCase() !== "label" ? params.fieldsArray[4] : "";
		//params.aliasName, objectName, fieldname1, fieldname2, fieldname3
		if(!this.__aliasFields[aliasName]){
			this.__aliasFields[aliasName] = {};
				this.__aliasFields[aliasName].fields = {"Metadata" : []};
				this.__aliasFields[aliasName].soqlQuery = "";
		}
		var SOQLQuery = this.__aliasFields[aliasName].soqlQuery;
		if(!fieldname1 || fieldname1.length === 0){
			return;
		}			
		
		//now get the field info
		this.__aliasExists(aliasName);
		var fields = this.__describeInfo[aliasName].parsedFields[fieldname1];
		
		var currFieldMetadata = {"OBJ" : this.__describeInfo[aliasName].key,"FN" : fieldname1};	
		if(fields && fields.type === 'reference' && fieldname2 && fieldname2.length > 0){
			var refInfo;
			var queryField = fields.relationshipName;
			if (this.__parsedReferenceInfo[fieldName]) {
				refInfo = this.__parsedReferenceInfo[fieldName];
			}
			else {
				refInfo = this.__parseReferenceFields(fields.fields, fieldname2);
			}
			currFieldMetadata["TYP"] = fields.type;
			currFieldMetadata["RLN"] = fields.relationshipName;
			currFieldMetadata["ROBJ"] = fields.referenceTo;
			currFieldMetadata["RFN"] = fieldname2;
			currFieldMetadata["RTYP"] = refInfo.type;
			if(refInfo.type === 'reference' && this.__describeObjectInfo[refInfo.referenceTo] && refInfo.relationshipName){
				queryField = queryField + "." + refInfo.relationshipName + "." + this.__describeObjectInfo[refInfo.referenceTo];
				currFieldMetadata["RLN2"] = refInfo.relationshipName;
				currFieldMetadata["ROBJ2"] = refInfo.referenceTo;
				currFieldMetadata["RFN2"] = this.__describeObjectInfo[refInfo.referenceTo];
				currFieldMetadata["RTYP2"] = "Text";
			}
			else{
				queryField = queryField + "." + fieldname2;
			}
			
			SOQLQuery = SOQLQuery + (SOQLQuery.length > 0 ? ", " : "") + queryField;		
		}
		else if(fields){
			currFieldMetadata["TYP"] = fields.type;
			if(fieldname1.toUpperCase() !== "ID")
				SOQLQuery = SOQLQuery + (SOQLQuery.length > 0 ? ", " : "") + fieldname1;
		}
		
		//TODO:implement for other info also
		var len = this.__aliasFields[aliasName].fields["Metadata"].length
		this.__aliasFields[aliasName].fields["Metadata"][len] = currFieldMetadata;
		this.__aliasFields[aliasName].soqlQuery = SOQLQuery;
	}
	
	HtmlDesignerUtils.prototype.__aliasExists = function(aliasName){
		if(!this.__describeInfo[aliasName]){
			this.__aliasFields.status = "Failure";
			this.__aliasFields.message = aliasName;
			this.__aliasFields.tagNumber = "TAG327";
			this.__callBackMethod.call(null,this.__aliasFields);
		}
	}
	HtmlDesignerUtils.prototype.__parseReferenceFields = function(refFields, fieldName){
		
		var i, l = refFields.length;
		for (i = 0; i < l; i++) {
			
			if(refFields[i].name === fieldName){
				return refFields[i];
			}
		}
	}
    
})();

//End of file

