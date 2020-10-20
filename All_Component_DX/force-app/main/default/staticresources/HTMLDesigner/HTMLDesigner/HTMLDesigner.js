
(function() {
	
	var allScripts = [ "./jsTree/_lib/jquery.js", "./jsTree/_lib/jquery.hotkeys.js", "./jsTree/jquery.jstree.js","./ckeditor/ckeditor.js","./HTMLDesignerUtils.js"];
	var codebase = null;
	for(var j = 0; j < allScripts.length; j++){
		//debugger;
		codebase = allScripts[j];
		if(__htmlDesignerCodeBase !== undefined && __htmlDesignerCodeBase !== null){
			codebase = __htmlDesignerCodeBase + "/" + codebase;
		}
		
		document.write('<script type="text/javascript" src="'+ codebase+ '"></script>');
	}
    
    var allCSS = ["./css/HTMLDesignerStyle.css"];
    for(j = 0; j < allCSS.length; j++){
    	var cssToLoad = allCSS[j];
    	document.write("<link rel='stylesheet' type='text/css' href='" +cssToLoad +"'>");
    }		
	
	var HtmlDesigner = function(){ };
	var treeData = [];
	
	HtmlDesigner.prototype.initialize = function(){}
    
    HtmlDesigner.prototype.afterInitialize = function(){
    	$('.cke_skin_kama .cke_wrapper').removeClass();
    }	
    //This method sets data in to CKEditor
    HtmlDesigner.prototype.setHTMLDesignerEditorData = function(param){
    	CKEDITOR.instances.ckeditor.setData(param.data);
    }
    //This method clears content of CkEditor
    HtmlDesigner.prototype.clearHTMLDesignerEditorData = function(param){
    	CKEDITOR.instances.ckeditor.setData('');
    }
    //This method gets data from CKEditor
    HtmlDesigner.prototype.getHTMLDesignerEditorData = function(){
    	return CKEDITOR.instances.ckeditor.getData();
    }
    //This method clears expression input text
    HtmlDesigner.prototype.clearHTMLDesignerExpression = function(){
    	$("#expression").attr("value",'');
    	$("#expressionLabel").attr("value",'');
		$("#expressionFilter").attr("value",'');
    }
	  //This method quick find by input text
    HtmlDesigner.prototype.searchHTMLDesignerExpression = function(){      
    	var searchText=$("#expressionFilter").val();    	
    	$("#objectTree").jstree("search",searchText);
    }
	
    //This method hide HTMLDesigner
    HtmlDesigner.prototype.hideHTMLDesigner = function(){
    	 $("#htmlDesigner").hide();    
    }
    
    HtmlDesigner.prototype.showHTMLDesigner = function(){
    	 $("#htmlDesigner").show();    
    }
       
    //This method brings object tree loaded
    HtmlDesigner.prototype.loadTree = function() {
    	$("#expressionFilter").attr("value",'');
    	$(function () {
    			$("#expression").attr("class","ckeditor");
			    
			    $("#objectTree").jstree({ 
			        "themes" : {
			            "theme" : "classic",
			            "dots" : true,
			            "icons" : true
			        },
			        "json_data" : {
			            "data" : treeData 
			            
			        },
					  "search" : { 
                 "case_insensitive": true,
                 "show_only_matches" : true
                   },  
			        "plugins" : [ "json_data", "ui", "crrm","themes","search"]
			    })
			    .bind("select_node.jstree", function (e, data) { 
			       //debugger;
			       var path = data.inst.get_path(); 
			       var strPath = data.rslt.obj.data("path");
				   var fldType = data.rslt.obj.data("fldType");
			       $("#expressionLabel").attr("value",'');
			       $("#expression").attr("value",'');
			       if(strPath !== undefined && strPath.length > 0){
			       		var label = strPath.replace("$D","$M");
						if(fldType === "picklist" || fldType === "multipicklist"){
							strPath += '.label';
						}
			       		strPath = '{{'+strPath+'}}';
			       		$("#expression").attr("value",strPath);
			       		if(strPath.indexOf('$D') !== -1 ){
			       			label += '.label';
				       		label = '{{'+label+'}}';
				       		$("#expressionLabel").attr("value",label);
			       		}
			       	}	
			      	$("#expression").focus().select();
			    });
			    $("#objectTree").bind("contextmenu", function(e) {
					return false;
				});
		});
    }
    
    //This function construcs object tree.
    HtmlDesigner.prototype.__construcTreeData = function(masterobject, data){
    	masterobject.children = [];
    	var obj = {};
    	obj.fields = [];
    	for(var item in data){
			if(item === 'objLabel'){
				masterobject.data = data[item];
				obj.objLabel = data[item];
			}else if(item === 'objAPIName'){	
				masterobject.metadata = { "id" : data[item] };
				if(data['path'] !== undefined)
					masterobject.metadata.path = data['path'];
				obj.objAPIName = data[item];
			}
			else if(item === 'fields'){
				var inputfields = [];
				var children = [];
				inputfields = data[item];
				for(var j = 0;j<inputfields.length;j++){
					var fieldObj = {};
					var fldObj = {};
					//debugger;
					fieldObj.data = inputfields[j]['fieldLabel'];
					fldObj.fieldLabel = inputfields[j]['fieldLabel'];
					fieldObj.metadata = { "id" : inputfields[j]['fieldAPIName'] , "path" : inputfields[j]['path'], "fldType" : inputfields[j]['fieldType'].toString().toLowerCase()};
					fldObj.fieldAPIName = inputfields[j]['fieldAPIName'];
					obj.fields.push(fldObj);
					
					if(inputfields[j]['fieldType'].toString().toLowerCase() === 'reference'){
						fieldObj.children = [];
						this.__construcTreeData(fieldObj, inputfields[j]);
					}
					children.push(fieldObj);
				}
				masterobject.children = children;					
			}
		}
	};
    //This function construcs object tree. 
    HtmlDesigner.prototype.lodaMetaData = function(params) {
    	treeData = [];
    	var objects = params.objects, i, l = objects.length;
    	for(i = 0; i < l; i++){
    		var obj = {};
    		this.__construcTreeData(obj, objects[i]);
    		treeData.push(obj);
    	}
    	HtmlDesigner.prototype.loadTree();
	};
    
    //This Function parse Content Body of Template and retuen SOQL
    HtmlDesigner.prototype.parseContent = function (params, callback) {
    	
      	this.__utilInst = new HtmlDesignerUtils();
    	this.__utilInst.initialize(params,this,function(results){
    		callback(results);
    	});
    };
   
	HtmlDesigner.prototype.describeObjects = function(objectsInfo, callback, context){
		
		describeObject(objectsInfo, function(results){
			callback.call(context, results);
		});
    };  
    HtmlDesigner.prototype.addCustomFieldInTabelDialog = function(params) {
    	CKEDITOR.on( 'dialogDefinition', function( ev ) {
			var dialogName = ev.data.name;
	    	var dialogDefinition = ev.data.definition;
	
		    if ( dialogName == 'table' )
		    {    
		        var infoTab = dialogDefinition.getContents('info');
		        infoTab.get('selHeaders')['default'] = 'row';
		        
		        var exsistingContoles  = infoTab.elements[2].children;
				var newControles = new Array();
				newControles.push({
					type: 'text',
					label: 'Data',
					id: 'customField',
					setup : function( type, element ) {
				    	this.setValue( element.getAttribute( 'id' ) );
				    },
				    commit : function( type, element ) {
				    	if ( this.getValue() || this.isChanged() )
				        	element.setAttribute( 'svmx-data', this.getValue() );
				        
				    }});
				
				for(var i = 0;i<exsistingContoles.length;i++){
					newControles.push(exsistingContoles[i]);
				}
				infoTab.elements[2].children = newControles;
	
	    	}
	    	if ( dialogName == 'image' )
			{
				// Get a reference to the "Link Info" tab.
				var infoTab = dialogDefinition.getContents( 'info' );
	 
				// Set the default value for the URL field.
				var urlField = infoTab.get( 'txtUrl' );
				urlField['default'] = '.';
			}
		});
    }
    
   	window.HtmlDesigner = HtmlDesigner;
})();

// end of file

