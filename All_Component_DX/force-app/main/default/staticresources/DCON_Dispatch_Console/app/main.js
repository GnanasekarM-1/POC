/*
 * DCHandle provides handle to load DispatchConsole.swf and Map
 */

var DCHandle = DCHandle || {};

(function(){
	var dcViews = null;
	var mapInstance,
		  initialized = false,
	      defaultMapConfig,
		  mapWindow,
	      token,
	      defaultDimensions;
	
	/**
	 * This function adds DC to vf page
	 */
	function initialize(config)
	{
		if(initialized)
			return;
		
		var innerHeight = window.innerHeight || document.documentElement.clientHeight || document.body.clientheight;
		
		var dc = Ext.create("Ext.Panel",{
							id : "dcContainer",
							flex : 3,
							height : "100%",
							region : "center",
							minWidth : 919//minWidth set to fix issue #9621
						});
						
		var parentContainer = Ext.create("Ext.Panel",{
												id : "parentContainer",
												layout : "border",
												items : [dc],
												frame : false,
												flex : 1,
												height : innerHeight,
												renderTo : Ext.getDom("DC"),
												defaults:{
													collapsible:false,
													split:true
												}
											});
											
		renderSWF(config);
		
		Ext.EventManager.onWindowResize(function()
		{
			innerHeight = window.innerHeight || document.documentElement.clientHeight || document.body.clientheight;
			parentContainer.height = innerHeight;
			parentContainer.doComponentLayout();
			parentContainer.doLayout();
		});
		
		initialized = true;
	}
	
	/**
	 * This function is called when UI setting to display map is false/off but GBL005 setting is true
	 */
	function setDefaultMapConfig(config)
	{
		var valid = MapHandle.setDefaultMapConfig(config);
		
		if(valid == true)
			defaultMapConfig = config;
	}
	
	/**
	 * Initializes map with default config
	 * config - {defaultLat:num,defaultLng:num,defaultZoomLevel:num,mapWidth:num,techIcon:str,teamIcon:str,woIcon:str,tags:Object,userDateFormat:str}
	 */
	function initializeMap(config)
	{
		var parentContainer = Ext.getCmp("parentContainer");
		
		if(!parentContainer)
			return;
		
		if(Ext.getCmp("mapContainer") && mapInstance)
			return;
		
		// views
		dcViews = DCViewsPanel.getInstance();
		dcViews.hide(); // initially
		
		var mapDiv = Ext.create("Ext.container.Container",{
								 id : "mapDiv",
								 flex : 1
							 });
		
		//Listener added to fix issue #10501
		parentContainer.on("afterlayout",function()
		{
			var swf = getSWFReference();
			if(swf)
				swf.reloadDefaultCalendarDuration();
		},this,{single:true,delay:500});//Adding delay as the event is not fired when we want
		
		// container to layout maps + dcViews
		var mapc = Ext.create("Ext.Panel",{
						layout : {type:"vbox", align:"stretch"},
						items : [dcViews.getUI(), mapDiv],
						frame : false,
						flex : 1
					});
					
		var panelConfig = {
				id : "mapContainer",
				flex : 1,
				height : "100%",
				region : "east",
				layout : {type:"vbox",align:"stretch"},
				items : [mapc]
			};
		
		//If user had saved the map dimension, use it. Just setting the map width will automatically resize swf.
		//So no need to set size for it
		if(config.mapWidth)
		{
			delete panelConfig.flex;
			
			panelConfig.width = config.mapWidth;
		}
		
		var mapPanel = Ext.create("Ext.Panel",panelConfig);
		
		parentContainer.add(mapPanel);
		
		renderMap(config);
		
		defaultMapConfig = config;
		
		//Once map is added, add the resize event listener to update the dimensions for DC and Map in user settings
		var dc = Ext.getCmp("dcContainer");
		dc.on("afterlayout",onDCResize,this);
		
        
        var loadfirst=0;
        var loadfirstcheck=0;                
        google.maps.event.addListener(mapInstance, 'idle', function(e){
           if(loadfirstcheck==1)
           {                         
           loadfirst=1;  
           }
           loadfirstcheck=1;                     
         });
        
        google.maps.event.addListener(mapInstance, 'mouseout', function(e){
            var latlon = mapInstance.getCenter();
            var mapzoom = mapInstance.getZoom();
            var app = getSWFReference();
        
            if(app)
            {
                var data = {};
                data.lat = latlon.lat();
                data.lng = latlon.lng();
                data.zoom = mapzoom;
                if(loadfirst==1)
                {
                 app.autoSaveMap(data);
                 loadfirst=0;
                }
            }
        });
	}
	
	function onDCResize(e)
	{
		var dc = Ext.getCmp("dcContainer");
		var map = Ext.getCmp("mapContainer");
		
		var childrenWidth = {};
		
		//Third condition is added to fix issue #11629. No need to update dimensions when popup out map is closed
		if(map && map.hidden == false && !mapWindow)
		{
			childrenWidth.dcWidth = dc.getWidth();
			childrenWidth.mapWidth = map.getWidth();
			
			var app = getSWFReference();
		
			if(app)
			{
				app.updateDCDimensions(childrenWidth);
			}
		}
		
		//When swf is resized, trigger the resize event on the map for the tiles to refresh properly
		var center = mapInstance.getCenter();
		google.maps.event.trigger(mapInstance, 'resize');
		mapInstance.setCenter(center); 
	}
	
	function renderSWF(config)
    {
        var swfVersionStr = "10.0.0";
        var xiSwfUrlStr = "playerProductInstall.swf";
        
        var params = {};
        params.quality = "high";
        params.bgcolor = "#869ca7";
        params.allowscriptaccess = "sameDomain";
        params.allowfullscreen = "true";
        
        var attributes = {};
        attributes.id = "DispatchConsole";
        attributes.name = "DispatchConsole";
        attributes.align = "left";
        swfobject.embedSWF(
            config.url, "dcContainer-body",
            "100%", "100%",
            swfVersionStr, xiSwfUrlStr,
            config.flashvars, params, attributes);
		swfobject.createCSS("#dcContainer-body", "display:block;text-align:left;");
	}
	
	/*
	 * config has defaultLat,defaultLng and defaultZoomLevel properties as of now
	 */
	function renderMap(config)
	{
		var parentElement = document.getElementById("mapDiv");//document.getElementById("mapContainer");
		mapInstance = MapHandle.renderMap(config,parentElement);
	}
	
	function setMapVisibility(visible)
	{
		var mapContainer = Ext.getCmp("mapContainer");
		
		if(!mapContainer)
			return;
			
		if(visible === true)
		{
			//When inline map is hidden and the popup map is reset, the default location is displayed at origin(north west) of the inline map
			//To avoid this, take center before the map is made visible and set it again if the popout map was reset
			var center = mapInstance.getCenter(); 
			var defaultCenter = new google.maps.LatLng(defaultMapConfig.defaultLat,defaultMapConfig.defaultLng);
			
			mapContainer.show();
			
			if(center.equals(defaultCenter))
				mapInstance.setCenter(center);
		}
		else
			mapContainer.hide();
	}
	
	function openMapWindow(url)
	{
		if(mapWindow)
			return;
		
		setMapVisibility(false);
		
		mapWindow = window.open(url,"_blank","width=800,height=600,resizable=1,status=0,scrollbars=1");
		
		var winCheck = function()
		{
			if(mapWindow && mapWindow.closed == true)
			{
				enableMapInDCWindow(null);
			}
			//Call winCheck() till mapWindow.MapHandle is created
			else if(mapWindow && !mapWindow.MapHandle)
			{
				setTimeout(winCheck,100,null);
			}
		};
		
		//Fix for #10979. If mapWindow is closed even before MapHandle is loaded, enable inline map
		//For indepth explanation, read defect resolution note
		setTimeout(winCheck,100,null);
	}
	
	/**
	 * Once the popup for map is closed, enable inline map. This is called from map.js of popup map window
	 * This function is called when onbeforeunload event is fired when user either closes/refreshes the window.
	 * So to make sure the mapWindow is closed,
	 * setTimeOut() is used
	 */
	function checkMapWindow()
    {
        if(mapWindow && mapWindow.closed == true)
        {
            clearTimeout(token);
            var context = DCHandle.mapPopupContext ? Ext.JSON.decode(DCHandle.mapPopupContext) : null;
            enableMapInDCWindow(context);
        }
        else if(mapWindow)//We wan it to be called only when map is opened in separate popup and is not closed yet
        {
        	token = setTimeout(function(){checkMapWindow();},1000);
        }
    }
	
    function enableMapInDCWindow(context)
    {
    	var app = getSWFReference();
    	var visible;
    	
    	if(app)
	    	visible = app.enableMap();
	    
	    if(visible == true)
	    {
	    	setMapVisibility(true);
	    	
	    	//Adding delay to execute the function after layout is complete.
	    	Ext.callback(function()
	    	{
	    		if(app)//Added to fix issue #11142
	    			app.restoreEndDateForGantt();
	    	},null,null,200);
	    }
	    		   //Only load context if the map is enabled inline (ui setting to show map is on/true)
	    if(context && visible == true)
	    	MapHandle.loadContextFromPopupMap(context);
	    
	    mapWindow = null;
    }
    
    function getSWFReference()
    {
    	var app = (navigator.appName.indexOf ("Microsoft") !=-1) ? document.getElementById('DispatchConsole') : document['DispatchConsole'];
	    return app;
    }
    
    /**
     * Map can either instantiated inline or in popup 
     */
    function isMapInstantiated()
    {
    	var result = false;
    	var mapContainer = Ext.getCmp("mapContainer");
		
    	if(mapContainer || mapWindow)
    		result = true;
    	
    	return result;
    }
    
    /**
     * Get MapHandle of inline or popup map, whichever is applicable
     */
    function getMapHandle()
    {
    	var handle = null;
    	var mapContainer = Ext.getCmp("mapContainer");
		
		/*if(!mapContainer)//Since map itself is not created, return null
			return handle;*/
		
		if(mapContainer && mapContainer.isVisible())//If map is inline with DC, then draw on that
		{
			handle = MapHandle;
		}
		else if(mapWindow)//If map is in separate popup, draw on that
		{
			handle = mapWindow.MapHandle;
		}
		
		return handle;
    }
    
    /**
     * Draw technician route on map.
	 * routeData - {technician:{},
	 *        			   currentDateInMilliSeconds:0,
	 *                    eventsForWorkOrders:[],
	 *                    ganttStartDateInMilliSeconds:0,
	 *                    ganttEndDateInMilliSeconds:0,
	 *                    currentTimeMarkerInMillis:0,
	 *                    viewAllEventsForToday:boolean,
	 *                    currentDateInUserFormat:string}
     */
    function drawTechnicianRoute(routeData)
    {
		if(!isMapInstantiated())//Since map itself is not created, dont do anything
			return;
		
		var handle = getMapHandle();
		
		if(handle)
			handle.drawTechnicianRoute(routeData);
    }
    
    /**
     * This is called from MapHandle when user navigates between days to see tech route for a particular day
     * data - {currentDateInMilliSeconds : Number}
     */
    function drawTechRouteForDay(data)
    {
		var app = getSWFReference();
		
		if(app)
			app.drawTechRouteForDay(data);
    }
    
    /**
     * Plot the search results for team search on inline or popup map
     * teams - array of teams
     * selectedWO - workorder details if search is performed for a selected workorder
     */
    function drawSearchedTeams(teams/*Array*/,selectedWO/*workorder details*/)
    {
		if(!isMapInstantiated())//Since map itself is not created, dont do anything
			return;
		
		var handle = getMapHandle();
		
		if(handle)
			handle.drawSearchedTeams(teams,selectedWO);
    }
    
    /**
     * Plot the search results for technician search on inline or popup map
     * technicians - array of technicians
     * selectedWO - workorder details if search is performed for a selected workorder
     */
    function drawSearchedTechnicians(technicians/*Array*/,selectedWO/*workorder details*/)
    {
		if(!isMapInstantiated())//Since map itself is not created, dont do anything
			return;
		
		var handle = getMapHandle();
		
		if(handle)
			handle.drawSearchedTechnicians(technicians,selectedWO);
    }
    
    function clearRoute()
    {
		if(!isMapInstantiated())//Since map itself is not created, dont do anything
			return;
		
		var handle = getMapHandle();
		
		if(handle)
			handle.clearRoute();
    }
    
    function resetMap()
    {
		if(!isMapInstantiated())//Since map itself is not created, dont do anything
			return;
		
		MapHandle.resetMapToDefaultConfig();
		
		if(mapWindow)//If map is in separate popup
		{
			mapWindow.MapHandle.resetMapToDefaultConfig();
		}
    }
    
    function getSelectedDateForRoute()
    {
		if(!isMapInstantiated())//Since map itself is not created, dont do anything
			return;
		
		var handle = getMapHandle();
		var date = 0;
		
		if(handle)
			date = handle.getSelectedDateForRoute();
		
		return date;
    }
    
	function getViewDataToPlot(request){
		
		// when passing data from child window to parent window Array becomes Object! (Firefox)
		if(!(request.selectedItems instanceof Array)){
			var tmp = [];
			for(var i = 0; i < request.selectedItems.length; i++){
				tmp[i] = request.selectedItems[i];
			}
			
			request.selectedItems = tmp;
		}

		var app = getSWFReference();
		app.getViewDataToPlot(request);
	}
	
	function getViewDataToPlotHandler(result){
		var handle = getMapHandle();
		handle.getViewDataToPlotHandler(result);
	}
	
	function popoutMap()
	{
		var app = getSWFReference();
		
		if(app)
			app.openMapWindow();
	}
	
	function getLocationBase()
	{
		var handle = getMapHandle();
		return handle.getLocationBase();
	}
	
	function locationBaseRadioClick()
    {
        var app = getSWFReference();
        if(app)
            app.autoSaveLocationBase();            
    }
	
    function displayErrorInDC(errorInfo)
	{
		if(!errorInfo)
			return;
			
		var app = getSWFReference();
		//Too much recursion error when encoding
		//var toStr = Ext.JSON.encode(errorInfo);
		app.showErrorInDC(errorInfo);
	}
	
	DCHandle.initialize = initialize;
	DCHandle.initializeMap = initializeMap;
	DCHandle.setDefaultMapConfig = setDefaultMapConfig;
	DCHandle.setMapVisibility = setMapVisibility;
	DCHandle.openMapWindow = openMapWindow;
	DCHandle.drawTechnicianRoute = drawTechnicianRoute;
	DCHandle.drawTechRouteForDay = drawTechRouteForDay;
	DCHandle.resetMap = resetMap;
	DCHandle.clearRoute = clearRoute;
	DCHandle.drawSearchedTeams = drawSearchedTeams;
	DCHandle.drawSearchedTechnicians = drawSearchedTechnicians;
	DCHandle.displayErrorInDC = displayErrorInDC;
	DCHandle.cMW = checkMapWindow;
	DCHandle.getViewDataToPlot = getViewDataToPlot;
	DCHandle.getViewDataToPlotHandler = getViewDataToPlotHandler;
	DCHandle.getSelectedDateForRoute = getSelectedDateForRoute;
	DCHandle.popoutMap = popoutMap;
	DCHandle.getLocationBase = getLocationBase;
	DCHandle.locationBaseRadioClick = locationBaseRadioClick;
})();