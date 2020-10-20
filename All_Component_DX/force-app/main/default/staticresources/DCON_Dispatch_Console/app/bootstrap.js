(function()
{
	var scripts = document.getElementsByTagName("script");
	var path = "";
	var onlyMap = false;
	var devMode = false;
	var includeChannel = false;
	var loadNewDC = false;
	
	for (var index = 0; index < scripts.length; index++)
	{
		var script = scripts[index];
		var src = script.src;
		
		//Need to make reg exp efficient enough for perfect match
		var match = src.match(/bootstrap\.js/);
		
		if(match)
		{
			path = src.substring(0,match.index);
			//This path can be used in other files to fetch other files from the static resource
			window.getResourcePath = function(){return path;};
			break;
		}
	}
	
	var head = document.getElementsByTagName("head")[0];
	
	//Load Ext css
	/*var link = document.createElement("link");
	link.type = "text/css";
	link.href = path + "ext-all.css";
	link.rel = "stylesheet";
	head.appendChild(link);*/
	
	//BOOTSTRAP_PARAMS should be set before this file is loaded. Currently it can have two paramaters - standAloneMap and dev
	//standAloneMap is set only if map is to be loaded in separate window.
	//dev is set to load full version of js files when in development mode (for debugging)
	//The value of BOOTSTRAP_PARAMS is a comma separated string
	//with other parameters as well
	if(window.BOOTSTRAP_PARAMS !== undefined)
	{
		if(window.BOOTSTRAP_PARAMS.search("standAloneMap") != -1)
		{
			onlyMap = true;
		}
		
		if(window.BOOTSTRAP_PARAMS.search("dev") != -1)
		{
			devMode = true;
		}
		
		if(window.BOOTSTRAP_PARAMS.search("includeChannel") != -1)
		{
			includeChannel = true;
		}
		
		if(window.BOOTSTRAP_PARAMS.search("new") != -1)
		{
			loadNewDC = true;
		}
	}
	
	if(includeChannel)
		mapsUrl += "&channel=DC";
	
	// added new varible in user xml to fix #039656  (no interface to change this variable name in flex - dc user has to change user setting value in user deatils xml)
	//var str = enableGoogleMapApi;
	if (enableGoogleMapApi.toUpperCase() === "TRUE")
	{
	
		//If the google map is allowed, then only load the library. This is a fix for an
		//issue where in China since google map is blocked, DC was not launching

		if(SET071 == "True")
		{
			var mapsUrl = "https://maps.googleapis.com/maps/api/js?client=gme-servicemaxinc&callback=onMapsLoad";
		
			var mapScript = document.createElement("script");
			mapScript.src = mapsUrl;
			mapScript.async = false;
			head.appendChild(mapScript);
		}
	}
	
	var filesToBeLoaded = [];
	var postfix = devMode == false ? "-min.js" : ".js";
	
	if(onlyMap)
	{
		filesToBeLoaded.push("ext-all.js","map" + postfix);
	}
	else
	{
		filesToBeLoaded.push("swfobject.js","ext-all.js","map" + postfix,"main" + postfix);
	}
	
	for (var i = 0; i < filesToBeLoaded.length; i++) 
	{
		var scriptToBeLoaded = filesToBeLoaded[i];
		
		var s = document.createElement("script");
		s.src = (path + scriptToBeLoaded);
		s.async = false;
		head.appendChild(s);
		
		//when both the files are loaded, load DC
		if(!onlyMap && (s.src.match("main" + postfix) || s.src.match("ext-all.js")))
		{
			s.onload = onScriptLoad;
			//IE has following equivalent of onload
			s.onreadystatechange = onScriptLoadIE;
		}
	}
	
	//Load all css
	var mapcss = loadNewDC ? "resources/css/svmx-dc-map-new.css" : "resources/css/svmx-dc-map.css";
	var cssPath = [mapcss, "resources/css/svmx-dc.css"], p = "";
	
	for (i = 0; i < cssPath.length; i++) {
		p = path + cssPath[i];
		var link = document.createElement("link");
		link.type = "text/css";
		link.href = p;
		link.rel = "stylesheet";
		head.appendChild(link);
		//document.write('<link type="text/css" rel="stylesheet" href="' + p + '"></link>');
	}
	
	function onScriptLoad()
	{
		if(window.DCHandle != undefined && window.Ext != undefined)
		{
			Ext.onReady(function()
			{
				//This function is in VF page.
				var config = getDCConfig();
				DCHandle.initialize(config);
			});
		}
	}
	
	function onScriptLoadIE()
	{
		if((this.readyState == "loaded" || this.readyState == "complete") && (window.DCHandle != undefined && window.Ext != undefined))
		{
			Ext.onReady(function()
			{
				//This function is in VF page.
				var config = getDCConfig();
				DCHandle.initialize(config);
				
				//DCHandle.initialize(flashVariablesConfig);
			});
		}
	}
	
})();

window.onMapsLoad = function ()
{
	//In stand alone mode (when map is opened in separate window), directly create the map
	if(window.BOOTSTRAP_PARAMS !== undefined && window.BOOTSTRAP_PARAMS.search("standAloneMap") != -1)
	{
		if(window.MapHandle != undefined && window.Ext != undefined)
		{
			//When Ext is ready then only set the context. This avoids any unwanted rendering behavior
			Ext.onReady(function()
			{
				MapHandle.setDCContextAndRenderMap();
			});
			
			try
			{
				delete window.onMapsLoad;
			}
			catch(e)
			{
				window.onMapsLoad = undefined; //delete keyword doesnt work on window in IE8
			}
		}
		else//In case MapHandle is not available, call later. Sometimes it happens in Chrome
		{
			setTimeout(onMapsLoad,1000);
		}
	}
};