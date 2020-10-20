/*
 * MapHandle gives access to all map related activities
 */

var MapHandle = MapHandle || {};

(function(){
	
	Array.prototype.foreach = function(fn)
	{
		for(var x = 0;x < this.length;x++)
			fn(this[x]);
	};
	
	Array.prototype.some = function(fn)
	{
		var result = false;
		
		/*for(var x = 0;x < this.length;x++)
		{
			result = fn(this[x]);
			
			if(result)
				break;
		}*/
		
		return result;
	};
	
	//Function to open a record in new window from the map info window
	window.openRecord = function (Id)
									 {
										 var url = document.location.protocol + "//" + document.location.host + "/" + Id + "?isdtp=mn";
										  window.open(encodeURI(url),"_blank","width=800,height=600,resizable=1,status=0,scrollbars=1");
										  
									 };
		  /**
		   * Reference to google map
		   */
		  var mapInstance,
		  
		  /**
		   * Reference to the div in which map is rendered
		   */
	      mapParentDiv,
		  
		  /**
		   * token to clear interval
		   */
		  token,
		  
		  /**
		   * Reference to geocoder for resolving lat lng
		   */
		  geocoder,
		  
		  /**
		   * Reference to DirectionsDisplay class used to plot route
		   */
		  directionsDisplay,
		  
		  /**
		   * Reference to service used to get path for the route between source and destination
		   */
		  directionsService,
		  
		  /**
		   * Flag that indicates whether the map is initialized or not
		   */
		  initialized = false,
		  
		  /**
		   * Set of default user defined information used to initialize map
		   * {defaultLat:num,defaultLng:num,defaultZoomLevel:num,mapWidth:num,techIcon:str,teamIcon:str,woIcon:str,tags:Object} 
		   */
		  defaultConfig,
		  
		  /**
		   * Bounds are used to show plotted info correctly. Its initialized before plotting anything
		   */
		  bounds,
		  
		  /**
		   * Reference to parent DC window when map is opened in separate popup
		   */
		  dcWindow,
		  
		  /**
		   * Reference to a common infoWindow used to display hover info for map markers
		   */
		  infoWindow,
		  
		  /**
		   * Used to store the map type when switching between inline and popup view
		   */
		  selectedMapTypeId,
		  
		  /**
		   * Used to store the map zoom level when switching between inline and popup view
		   */
		  zoomLevel,
		  
		  /**
		   * Data for technician for whom the route is plotted
		   * {technician:{},
	 	   *   currentDateInMilliSeconds:0,
		   *   eventsForWorkOrders:[],
		  * pastOverNightStayEvent:[]
		  * futureOverNightStayEvent:[],
		   *   ganttStartDateInMilliSeconds:0,
		   *   ganttEndDateInMilliSeconds:0,
		   *   currentTimeMarkerInMillis:0}
		   */
		  routeData = {},
		  
		  totalRoutesPlotted = 0,
		  
		  lastPlottedRoute = null,
		  
		  suppressEventsDateField = false,
		  
		  /**
		   * Counter to keep track of how many markers are pending for lat lng resolution from address
		   */
		  latLngLookupCounter = 0,
          
		  /**
		   * This stack maintains the references to callBacks that need to be executed after the lat lngs for markers are resolved
		   */
          callBackStack = [],
          
          /**
           * Has search info for technicians {technicians:Array,selectedWO:Object}
           */
          searchTechData,
          
          /**
           * Array having references to all the markers plotted for tech search
           */
          searchTechMarkers,
          
          /**
           * Has search info for teams {teams:Array,selectedWO:Object}
           */
          searchTeamData,
          
           /**
           * Array having references to all the markers plotted for team search
           */
          searchTeamMarkers,
          
          /**
           * List of team/tech/wo objects {Name,type} having incalid location info
           */
          invalidMarkers = [],
          
          /**
           * Array of the colors used to plot technician route
           */
          //techRouteColors = ["DA70D6","149DC9","00FF00","8B008B","FF1493","00BFF3","A0522D","FFFF00","BC8F8F",
          							   // "48D1CC","800000","DC143C","696969","7B68EE","00FF7F"],
          
          techRouteColors = 
			["#1B7DBC" , "#C53922" , "#02AF5B" , "#D75500" , "#923BB0" , "#2B3D51" ,
			 "#EB8000" , "#7E8C8D" , "#2595DF" , "#ED4C32" , "#01A185" , "#F79F00"],					    
         
           home_marker_background_colors = 
			["#1B7DBC" , "#C53922" , "#02AF5B" , "#D75500" , "#923BB0" , "#2B3D51" ,
			 "#EB8000" , "#7E8C8D" , "#2595DF" , "#ED4C32" , "#01A185" , "#F79F00"],
			 
			current_marker_background_colors = 
			["#1B7DBC" , "#C53922" , "#7E8C8D" , "#D75500" , "#923BB0" , "#2B3D51" ,
			 "#7E8C8D" , "#7E8CED" , "#2595DF" , "#ED4C32" , "#01A185" , "#F79F00"],
			 
			 
			 //tech current marker path			 
			 current_marker = 'M-20,0a20,20 0 1,0 40,0a20,20 0 1,0 -40,0 M-5,20 L0,35 L5,20 Z',
			 
			 //tech home marker path			
			 home_marker ='M-14,-8 L14,-8 L14,8 L-14,8  M0,-20 L14,-8 Z M0,-20 L-14,-8 L14,-8',
			 
			  over_night_marker ='M11.7756487,4 C7.14289509,6.52840598 4,11.443911 4,17.0934786 C4,25.326123 10.673877,32 18.9065214,32 C24.556089,32 29.471594,28.8571049 32,24.2243513 C29.8818288,25.3803785 27.4522062,26.0373914 24.86913,26.0373914 C16.6364856,26.0373914 9.96260858,19.3635144 9.96260858,11.13087 C9.96260858,8.54779378 10.6196215,6.11817116 11.7756505,3.99999902 Z',
						
			circle_radius=0,
			radius_mode=true,					
			plot_mode=false,
			plot_circle_radius=0,
			reset_mode=false,								    
          
          /**
           * Map for which color is used for which technician when plotting route
           * sfid -> color
           */
          techColorMap = {},
          
          /**
           * Reference to traffic layer displayed on map
           */
          trafficLayer,
          
          /**
           * Reference to div displaying Traffic control (button)
           */
          trafficLayerDiv,
          
          /**
           * Div that displays the Radio btns for home/current location
           */
           locationBaseDiv,

          /**
           * Array of controls added to toolBar for performing route related actions
           */
          routeActionMenuItems,
          
		  /**
		   * Currently selected lat-lng to be ued by "Plot near by"
		   */
		  plotNearByLatLng = null,
		  
		  plotNearByMarkers = [],
		  
		  plotCircle = null,
		  
		  plotCenterMarker = null,
		  
		  plotRouteCounter = 0,
		  
          /**
           * Array of controls added to toolBar for performing search related actions
           */
          radiusActionMenuItems,
          
          /**
           * Toolbar to hold the route navigation,Plot nearby and Clear map controls
           */
          toolBar,
          
          /**
           * Toolbar to hold the radius mode controls
           */
          radiusActionBar,
          
          /**
           * Literals used in this file
           */
          Literals = {PREVIOUS : "prev", NEXT : "next", TECHNICIAN : "Tech", TEAM : "Team", WORKORDER : "WO",
                           BALLOON_URL : "https://chart.googleapis.com/chart?chst=d_map_pin_letter&chld=",                           
						   PLOT_CENTER_ICON : "https://www.google.com/mapfiles/arrow.png"},
						   
						  // WORKORDER_ICON :  window.getResourcePath() + "resources/themes/images/svmx-dc-map/custom/womap-pin.png",
          
          /**
           * Map for Team/Tech/WO record and their lat lng
           * sfid -> LatLng object
           */
           latLngMap = {},
           
           /**
            * Map of salesforce date fromat (key) and Ext date format (value)
            * Courtesy - UIFW
            */
           dateFormatMap = {"DD/MM/YYYY" : "d/m/Y", "DD.MM.YYYY" : "d.m.Y", "DD-MM-YYYY" : "d-m-Y",
						 "MM/DD/YYYY" : "m/d/Y", "MM.DD.YYYY" : "m.d.Y", "MM-DD-YYYY" : "m-d-Y",
						 "YYYY/MM/DD" : "Y/m/d", "YYYY.MM.DD" : "Y.m.d", "YYYY-MM-DD" : "Y-m-d",
						 "YYYY. MM. DD" : "Y.m.d", "DD.MM.YYYY." : "d.m.Y"},
						 
		   /**
		    * Progress indicator
		    */
		   loaderMask,
           
           /**
            * Reference to Circle object used for radius mode
            */
			radiusModeCircle,
			
			tempTechData,
			
			tempTechList,
			
			tempSelectedWO;
    /**
     * Self terminate if DC is closed
     */
    function checkParentWindow()
    {
        if(dcWindow.closed == true)
        {
            clearTimeout(token);
            alert(defaultConfig.tags["TAG365"]);
            window.close();
        }
        else
        {
        	token = setTimeout(checkParentWindow,1000);
        }
    }
    
	/*
	 * Call this function when loading map in a separate window.Currently its called from bootstrap.js when map
	 * is opened in a separate window
	 */
	function setDCContextAndRenderMap()
	{
		if(!window.opener)
			return;
        
        dcWindow = window.opener;
        
        var defaultData = dcWindow.MapHandle.getDefaultMapConfig();

        var context = dcWindow.MapHandle.getCurrentContext();
        
        if(context)
        {
	        if(context.selectedMapTypeId)
	        	selectedMapTypeId = context.selectedMapTypeId;
	        
	        if(context.zoomLevel)
	            	zoomLevel = context.zoomLevel;   
	        
	        if(!zoomLevel)
	           zoomLevel = 	0;
	        
	        if(context.routeData)
	        	routeData = context.routeData;
	        
	        totalRoutesPlotted = context.totalRoutesPlotted;
	        
	        if(context.lastPlottedRoute)
	        	lastPlottedRoute = context.lastPlottedRoute;
	        
	        if(context.searchTeamData)
	        	searchTeamData = context.searchTeamData;
	        	
	        if(context.searchTechData)
	        	searchTechData = context.searchTechData;
	        
	        if(context.techColorMap)
	        	techColorMap = context.techColorMap;
	        
	        if(context.latLngMap)
	        	latLngMap = context.latLngMap;
	    } 
	            
        setLayoutForStandAloneMap();
         
        renderMap(defaultData,Ext.getDom("map"));
        
        
        
		// set the map center when window is resized
		var mc = Ext.getCmp("mapContainer");
		mc.on("afterlayout",function(e){		   
			var center = mapInstance.getCenter();
			google.maps.event.trigger(mapInstance, 'resize');
			mapInstance.setCenter(center);				
			//var evt = document.createEvent('UIEvents');
            //evt.initUIEvent('resize', true, false,window,0);
            //window.dispatchEvent(evt);					
		},{});
		// end map center
		
        if(context && context.showTrafficOverlay == true && trafficLayer)
        {
        	setTrafficLayerVisibility.call(trafficLayerDiv);
        }
        
        //setTimeout() is used because in chrome, even though map is loaded, its not displayed sometimes
        setTimeout(function(){
        	redraw();
        	//For stand alone map, create menubar after the map is loaded. This prevents the inappropriate hover style for Plot nearby and Clear Map buttons
        	//Need to find out why is this happening for stand alone map (may be there is a conflict between Ext css and Google map css)
        	createMenuBar();
        	createRadiusActionBar();
        	createLocationBaseBar();
        	
        	if(context.selectedLocationBase)        		
        		Ext.getCmp(context.selectedLocationBase).checked =true

        	if(context)
        		loadDCContext(context);
        },1000);
        
        checkParentWindow();
        
       //Pass the current context to parent DC window and enable inline map
        window.onbeforeunload = function(event)
    	{
    		var context = getCurrentContext();
    		//Create JSON string and persist it to dcWindow
    		//This is done because there is a run time error for IE8 as the data from closed child window is not accessible in parent window directly.
    		//Since the data is passed from dcWindow, when serialising, use Ext from parent window for it to happen correctly. This is done to handle IE8 issue
    		//where array passed from dcWindow was treated as array like object when serialising which resulted in incorrect behavior when switching context
    		//of map from inline to popup view
    		dcWindow.DCHandle.mapPopupContext = context ? dcWindow.Ext.JSON.encode(context) : null;
    		dcWindow.DCHandle.cMW();
    	};
	}
	
	// the views panel class
	function DCViewsPanel(){
		
		var objects = null, tabc = null, optp = null, config = null, currentInfoWindow = null;
		var optionsbarHeight = 80, radius = null, recCount = null, plotButton = null, mapElement = null;
		var nearByMarkersMap = {};
		
		// create the root ui
		var ui = Ext.create("Ext.Panel", 
			{ id : "svmx_map_dcviews_panel", height : 290, width : "100%",
				listeners : {resize : function( cmp, width, height, oldWidth, oldHeight, eOpts ){
					if(tabc) tabc.setHeight(height - (optionsbarHeight+20));
				}}
			});
			
		function render(c, options){
		
			config = c || {}; config.tags = config.tags || {};
			
			objects = [	{name : "workorder", title : config.tags["TAG092"], items : config.viewListForWO}, 
						{name : "account", title : config.tags["TAG329"], items : config.viewListForAccount}, 
						{name : "location", title : config.tags["TAG330"], items : config.viewListForLocation}];

			var i = 0, l = objects.length, obj, grids = [];

			for(i = 0; i < l; i++){
				obj = objects[i];

				// data store
				obj.dataStore = Ext.create('Ext.data.Store', {
	    			fields:['value', "value1"],
	    			data:{items:obj.items},
	    			proxy: {type: 'memory', reader: { type: 'json', root: 'items'}}
				});

				// grid
				obj.grid = Ext.create('Ext.grid.Panel', {
	    			title: obj.title, autoScroll : true, dataObject : obj,
	    			selModel: Ext.create('Ext.selection.CheckboxModel',{checkOnly : true, 
						listeners : {select : function( cmp, record, index, eOpts ){ selectView(record); }, 
									 deselect : function( cmp, record, index, eOpts ){ unselectView(record); }
						}
					}),
	    			store: obj.dataStore,
	    			columns: [{ text: "<B>" +config.tags["TAG331"] + "</B>",  dataIndex: 'value', flex : 1 }],
	    			height: "100%"
				});

				grids.push(obj.grid);
			}

			// tab container
			tabc = Ext.create("Ext.tab.Panel", {id: 'tabpanel', items : grids});

			// toolbar
			plotButton = Ext.create("Ext.Button", {text : config.tags["TAG334"], cls: 'x-grey-btn',id:'PlotButtonId', handler : function(){ getViewDataToPlotInternal(); }});
			toolb = Ext.create("Ext.Toolbar", {dock : "bottom", height : 33,
				items : ["->", plotButton, 
						 {text : config.tags["TAG333"], cls: 'x-grey-btn', handler : function(){ clearMap(); }}, "->"]});

			// options bar. maxValue set for radius to fix #10568
			/*radius = Ext.create("Ext.form.field.Number", {minValue : 1, maxValue : 999, value : config.defaultRadius, width : 140, margin : "0 5 0 0",
						labelWidth : 80, fieldLabel: config.tags["TAG017"] + "(" + config.mapUnitText + ")",
						maxText : defaultConfig.tags["TAG371"] + " {0}"});*/
			radius = Ext.create("Ext.form.field.ComboBox",{
						        	queryMode: 'local',
						        	store : new Ext.data.Store({
						        			fields : ["value"],
									        data: [{value:25},{value:50},{value:75},{value:100}]  // data is local
									    }),
									valueField: 'value',
    								displayField: 'value',
    								width : 140,
    								margin : "0 5 0 0",
    								maskRe : /[0-9]/,
    								value: config.defaultRadius,
    								listConfig : {minWidth : 50,style : {marginLeft:"0px"}},
    								labelWidth : 80, 
    								fieldLabel: config.tags["TAG017"] + "(" + config.mapUnitText + ")",
    								listeners : {
    								         change : plotNearByRadiusModeStepperHandler,
    								         expand : function(comp){radiusComboExpandHandler(comp);}}
						        });
			recCount = Ext.create("Ext.form.field.Number", {minValue : 1, maxValue : 100, value : config.defaultRecordCount, width : 150, margin : "0 0 0 5",
						labelWidth : 90, fieldLabel: config.tags["TAG332"], listeners : {render : overrideSalesforceTDStyle},
						maxText : defaultConfig.tags["TAG371"] + " {0}"});
			
			//In vf page, salesforce css is misaligning the recCount <td> if the field label wraps due to text length.
			//To fix that following function is used
			function overrideSalesforceTDStyle(comp)
			{
				if(comp)
				{
					comp.bodyEl.dom.style.verticalAlign = "middle";
				}
			}
			
			var optp = Ext.create("Ext.Panel", {frame : true, dock : "bottom", height : optionsbarHeight, 
				//defaults : {columnWidth: 0.5, margin : "2 2 2 2"},
				items : [radius, recCount], layout : {type:"hbox",pack:"center",align:"middle"}, dockedItems: [toolb]});
			// end options bar			
			ui.addDocked(optp);
			ui.add(tabc);
		}

		function plotNearByRadiusModeStepperHandler(comp,value)
		{		    
			var radius = parseInt(comp.value);
    	
	    	if(isNaN(radius))
	    	{
	    		radius = parseInt(value);
	    	}
	    	plot_mode=true;
	    	if(!isNaN(radius))
	    	{
	    		if(radius <= 2000)
	    			getViewDataToPlotInternal();
	    		else
	    		{
	    			//Fix for issue #10987 and related issue 11495
	    			comp.setValue(2000);
	    			
	    			getViewDataToPlotInternal();
	    		}
	    	}
		}
		
		function selectView(record){
			var markers = getMarkersForRecord(record);
			if(markers){
				for(var i = 0; i < markers.length; i++){
					markers[i].setMap(mapInstance);
				}
			}
		}
		
		function unselectView(record){
			var markers = getMarkersForRecord(record);
			if(markers){
				for(var i = 0; i < markers.length; i++){
					markers[i].setMap(null);
				}
			}
		}
		
		function getMarkersForRecord(record){
			var viewId = record.get("value1");	
			var ret = nearByMarkersMap[viewId];
			return ret;
		}
		
		var requestedViewCount = 0;
		function getViewDataToPlotInternal(){				
			if(!radius.isValid() || !recCount.isValid()||reset_mode)
				return;			
			
			var r = radius.getValue();				
			plot_mode=true;			
			var c = recCount.getValue();
			
			if(!r)
			{
				r = config.defaultRadius;//Fix for issue #10569. If the value is blank, populate default value
				reset_mode=true;
				radius.setValue(r);	
				reset_mode=false;
							
			}
						
			if(!c)
			{
				c = config.defaultRecordCount;//Fix for issue #10569. If the value is blank, populate default value
				recCount.setValue(c);
			}
			
			var selectedItems = getSelectedViews();
			
			var latlng = getLatLngForPlotNearBy();
			
			var ll = new google.maps.LatLng(latlng.lat, latlng.lng);
			drawPlotCenter(ll);
			drawCircle(ll);
			
			var lat = latlng.lat, lng = latlng.lng;			
			//if(!r || !c || !selectedItems || selectedItems.length == 0) {
				//TODO: a message?
			//	return;
			//}
			if(!c || !selectedItems || selectedItems.length == 0) {
				//TODO: a message?
				return;
			}			
			// Clear map
			clearPlot(true);
			
			// disable plot button
			plotButton.setDisabled(true);
			showBusyCursor(true);
			
			var items = {}, si;
			requestedViewCount = selectedItems.length;
			for(var i = 0; i < requestedViewCount; i++){
				si = selectedItems[i];
				si.item.data.objectName = si.name;
				items[si.name] = items[si.name] || [];
				items[si.name].push(si.item.data);
			}
			
			var request = null;
			for(var inRequest in items){
				request = {
					radius : r, mapUnit : config.mapUnit, selectedItems : items[inRequest], numOfRecs : c,
					apiName : config.apiNames[inRequest],
					lat : lat, lng : lng
				};               
				getViewDataToPlot(request);
			}			
		}
		
		function getLatLngForPlotNearBy(){
			var lat = 0.0, lng = 0.0;
			if (plotNearByLatLng == null) {
				
				//// There is no better way to get map center from pixel coordinates!
				var overlay = new google.maps.OverlayView(), coordinates = null;
				overlay.draw = function() {};
				overlay.setMap(mapInstance);
				
				try {
					var s = mapElement.style;
					function val(str) { str = str || "0px"; return parseInt(str.substring(0, str.length - 1)); };
					var x = (val(s.width) / 2);
					var y = (val(s.height) / 2);
					coordinates = overlay.getProjection().fromContainerPixelToLatLng(new google.maps.Point(x, y));
					lat = coordinates.lat();
					lng = coordinates.lng();
					plotNearByLatLng = coordinates;
				}catch(e){}
				
				overlay.setMap(null);
				//// end
				
			}else{
				lat = plotNearByLatLng.lat();
				lng = plotNearByLatLng.lng();
			}
			return {lat : lat, lng : lng};
		}
		
		function getViewDataToPlotHandler(result){
			plot(result);
			requestedViewCount--;
			if(requestedViewCount == 0){
				// enable the button back
				plotButton.setDisabled(false);
				showBusyCursor(false);
				
				if(plotNearByLatLng)
				{
					var bounds = mapInstance.getBounds();
					
					//Fix for issue #10700. Set center only when nothing else is plotted
					if(!bounds.contains(plotNearByLatLng) && totalRoutesPlotted == 0 && 
					  !searchTechData && !searchTeamData)
					{
						//Allow map to get initialized first
						setTimeout(function(){mapInstance.setCenter(plotNearByLatLng);},500);
					}
				}
			}
		}
		
		//Added to fix issue #12896 where plot map button was disabled and misunderstood as not functioning
		function showBusyCursor(value/*boolean*/)
		{
			if(!loaderMask)
			{
				loaderMask = new Ext.LoadMask(Ext.getCmp("mapContainer"), {useMsg:false});
				
				loaderMask.on("show",function(){
						var maskDiv = Ext.query(".x-mask")[0];
						
						if(maskDiv)
							maskDiv.style.cursor = "progress";
					},loaderMask,{single:true})
			}
			
			if(value)
				loaderMask.show();
			else
				loaderMask.hide();
			
			//Ext.getCmp("mapContainer").setLoading(" ");
		}
		
		function plot(data){
			var items = data.items || [], i, l = items.length, item = null, latLng = null;
			var markerIcon = getIconForSelectedObject(data.context);
			
			nearByMarkersMap[data.context.value1] = [];
			
			for(i = 0; i < l; i++){
				item = items[i];
				item.Id = item.id;
				item.hoverInfo = item.hoverInfo || "";
				item.hoverInfo = item.hoverInfo.replace(new RegExp("\\n", 'g'), "<br/>");
				item.hoverInfo = "<div style='text-align:left;'>" + item.hoverInfo + "</div>";
					
				latLng = new google.maps.LatLng(item.lat, item.lng);
				marker = createMarker(latLng, "", markerIcon);
				marker.info = item;
				addMarker(marker);
				plotNearByMarkers.push(marker);	
				
				nearByMarkersMap[data.context.value1].push(marker);
				
				google.maps.event.addListener(marker, 'mouseover', showInfo);
			}
		}
		
		function getIconForSelectedObject(context){
			var selectObject = context.objectName, ret = "";
			if(selectObject == 'workorder'){
				ret = config.woIcon;
				//ret = Literals.BALLOON_URL;
			}else if(selectObject == 'location'){
				ret = config.locIcon;
			}else{
				// account
				ret = config.accIcon;
			}
			return ret;	
		}
		
		function clearPlot(excludeCirle){
			currentInfoWindow = null;
			nearByMarkersMap = {};			
			clearMarkers();
			
			if (!excludeCirle) {			
				clearCircle();
				clearPlotCenter();
				
				//if plot circle is cleared, also clear the selected views
				clearSelectedViews();
				
				// reset the radius value
				reset_mode=true;
				radius.setValue(config.defaultRadius);
				reset_mode=false;
				circle_radius=config.defaultRadius;
				
				// reset No. of records
				recCount.setValue(config.defaultRecordCount);
			}
		}
		
		function getSelectedViews(){
			var ret = [], i = 0, l = 0, name = null, selection = null;
			
			tabc.items.each(function(tab, index, length){
				name = tab.dataObject.name;
				selection = tab.getSelectionModel().getSelection() || [];
				l = selection.length;
				
				for(i = 0; i < l; i++){
					ret.push({name : name, item : selection[i]});
				}
			});
			
			return ret;	
		}
		
		function clearSelectedViews(){
			tabc.items.each(function(tab, index, length){
				tab.getSelectionModel().deselectAll(true);
			}); 
		}
		
		function clearMarkers(){
			var i, l = plotNearByMarkers.length;
			for(i = 0; i < l; i++){
				plotNearByMarkers[i].setMap(null);
			}
			
			plotNearByMarkers = [];	
		}
		
		function clearPlotCenter(){
			if(plotCenterMarker) plotCenterMarker.setMap(null);
			
			plotNearByLatLng = null;
			plotCenterMarker = null;
		}
		
		function clearCircle(){			
			if(plotCircle)
			{
			 plotCircle.remove(); 
			 plotCircle.setMap(null);			 			
			}			
			plotCircle = null;			
		}
		
		function mapRendered(mapEl){
			mapElement = mapEl;
			getLatLngForPlotNearBy();
			
			google.maps.event.addListener(mapInstance, 'click', function(event) {
	            
	            //Commented to fix #10541
				//if(!isVisible()) return;

				drawPlotCenter(event.latLng);
	        });	      
		}
		
		function drawPlotCenter(latLng){		
			clearPlotCenter();
			
			////var r = radius.getValue() || config.defaultRadius, orginalRadius = r;
			
			//Fix for issue #10568
			//if(orginalRadius > radius.maxValue)
			//{
				//orginalRadius = radius.maxValue;
			//}
			
			plotNearByLatLng = latLng;
				
			// create plot center marker;
			var image = {
				url: Literals.PLOT_CENTER_ICON,
				origin: new google.maps.Point(0, 0),
				anchor: new google.maps.Point(13, 30) // image size is 39x34.
			};

			plotCenterMarker = createMarker(plotNearByLatLng, config.tags["TAG335"], image);
			addMarker(plotCenterMarker);
			
			// create info
			var info = "<div style='text-align:left;'>"
						+ "<B>" + config.tags["TAG335"] + "</B><br/><br/>"
						+ "<B>" + config.tags["TAG336"] + "</B>: " +  plotNearByLatLng.lat() + "<br/>"
						+ "<B>" + config.tags["TAG337"] + "</B>: " + plotNearByLatLng.lng() + "<br/>"
						+ "<B>" + config.tags["TAG017"] + "</B>: " + plot_circle_radius + "&nbsp;" + config.mapUnitText 
					+ "</div>";
			
			var infowindow = new google.maps.InfoWindow({ content: info, pixelOffset : new google.maps.Size(0,-15) });
			
			//mouseover used to fix issue #10659. Since we are not using mouseout, there should be no problem
			google.maps.event.addListener(plotCenterMarker, 'mouseover', function() {
				infowindow.open(mapInstance,plotCenterMarker);
			});
		}
		
		function drawCircle(latLng){
			clearCircle();
			
			var r = radius.getValue() || 1, orginalRadius = r;
			//var r =	circle_radius;
			plot_circle_radius=r;
			// radius in map is in meters. Converts in to KM.
			////r = r * 1.0 * 1000;
			
						
			// convert to miles if necessary
			//if(config.mapUnit == "miles"){
			//	r = r * 1.60934;	
			//}			
				
			var circleConfig = { strokeColor: '#FF0000', strokeOpacity: 0.8, strokeWeight: 2,
  				fillColor: '#FF0000', fillOpacity: 0.35, map: mapInstance,
  				center: latLng, radius: r
			}; 
			
			//plotCircle = new google.maps.Circle(circleConfig);		
			//CustomCircleOverlay(circlMapInstance, latLng, circleRadius, strokeColor, strokeWidth, strokeOpacity, fillColor, fillOpacity, numofPoints)
			plotCircle= new CustomCircleOverlay(mapInstance, latLng, plot_circle_radius,defaultConfig.mapUnitText,"mile","#FF0000", 2, 0.8, '#FF0000', 0.35);	
			
			//Fix for issue #10909
			google.maps.event.addListener(plotCircle, 'click', function(event) {			  
			    drawPlotCenter(event.latLng);
			});

		}
		
		function getUI(){
			return ui;
		}
		
		function hide(){
			ui.hide();
			//redraw map for the tiles to refresh properly. Sometimes the tiles are blank when tab panel is hidden
			try
			{
				redraw();
			}
			catch(e){}//Silently continue if map is not initialized yet
		}

		function show(){
			ui.show();
		}

		function toggle(){
			if(isVisible())
			{
				hide();
				//redraw map for the tiles to refresh properly. Sometimes the tiles are blank when
				//visibility is toggled to false
				redraw();
			}
			else show();
		}

		function isVisible(){
			return ui.isVisible();
		}
		
		function getRadiusValue()
		{
			if(!radius)
				return NaN;
			
			return radius.getValue();			
		}
		
		function getRecCountValue()
		{		
			if(!recCount)
				return NaN;
			
			return recCount.getValue();
		}
		
		function selectedViews()
		{
			var views = getSelectedViews();
			
			for (var i=0; i < views.length; i++)
			{
			  var item = views[i];
			  item.viewIndex = item.item.index;
			  delete item.item;//When passing data from popup map to inline map, Ext object results in recursion
			};
			
			return views;
		}
		
		function setContext(context/*Object*/)
		{		
			if(!context)
				return;
				
			if(context.hasOwnProperty("selectedViews"))
			{
				markViewsAsSelected(context.selectedViews);
			}
			
			if(context.radiusValue)
			{
			    reset_mode=true;
				radius.setValue(context.radiusValue);
				reset_mode=false;
			}				
			
			if(context.recCountValue)
				recCount.setValue(context.recCountValue);
			
			
			if(context.plotNearByLatLng)
			{
				plotNearByLatLng = new google.maps.LatLng(context.plotNearByLatLng.lat, context.plotNearByLatLng.lng);
				drawPlotCenter(plotNearByLatLng);
			}
			
			if(context.plotViews)
			{
				getViewDataToPlotInternal();
			}
		}
		
		function markViewsAsSelected(views/*Array of {name:objectname,item:record}*/)
		{		
			if(!views)
				return;
			
			var item = null, i = 0;
			var map = {};
			
			for (i=0; i < views.length; i++)
			{
			  item = views[i];
			  
			  if(!map.hasOwnProperty(item.name))
			  	map[item.name] = [];
			  
			  map[item.name].push(item.viewIndex);
			}
			
			tabc.items.each(function(tab, index, length){
				var name = tab.dataObject.name;
				
				if(map.hasOwnProperty(name))
				{
					var indices = map[name];
					
					tab.getSelectionModel().deselectAll();
					
					for(i = 0; i < indices.length; i++)
					{
						if(tab.rendered)
							tab.getSelectionModel().select(indices[i],true);
						else
						{
							tabc.setActiveTab(tab);
							tab.getSelectionModel().select(indices[i],true);
						}
					}
				}
				
			});
			
			tabc.setActiveTab(0);
		}
		
		this.getUI = getUI;
		this.show = show;
		this.hide = hide;
		this.toggle = toggle;
		this.render = render;
		this.getViewDataToPlotHandler = getViewDataToPlotHandler;
		this.mapRendered = mapRendered;
		this.clearPlot = clearPlot;
		this.selectedViews = selectedViews;
		this.getRadiusValue = getRadiusValue;
		this.getRecCountValue = getRecCountValue;
		this.setContext = setContext;
	} 

	var dcViews = null;
	DCViewsPanel.getInstance = function(){
		if(!dcViews){
			dcViews = new DCViewsPanel();
		}
		return dcViews;	
	};
	
	function getViewDataToPlot(request){
		var handle = getDCHandle();
		handle.getViewDataToPlot(request);
	}
	
	function getViewDataToPlotHandler(result){
		dcViews.getViewDataToPlotHandler(result);
	}
	
	/**
	 * When map is opened in separate popup window, a container with border layout is created
	 */
	function setLayoutForStandAloneMap()
	{	   
		var innerHeight = window.innerHeight || document.documentElement.clientHeight || document.body.clientheight;
		
		// maps 
		var map = 	Ext.create("Ext.Panel",{
						id : "map",
						flex : 1,
						height : "100%"
					});

		// views
		dcViews = DCViewsPanel.getInstance();
		dcViews.hide(); // initially

		// container to layout maps + dcViews
		var mapc = Ext.create("Ext.Panel",{
						layout : {type:"vbox",align:"stretch"},
						items : [dcViews.getUI(), map],
						frame : false,
						flex : 1
					});
					        
		var parentContainer = Ext.create("Ext.Panel",{
												id : "mapContainer",
												layout : {type:"vbox",align:"stretch"},
												items : [mapc],	
												frame : false,											
												flex : 1,
												height : innerHeight,
												renderTo : Ext.getDom("DCMap")
											});				  							
		
		
		Ext.EventManager.onWindowResize(function()
		{
			innerHeight = window.innerHeight || document.documentElement.clientHeight || document.body.clientheight;
			parentContainer.height = innerHeight;
			parentContainer.doComponentLayout();
			parentContainer.doLayout();	
			//relayoutmap();
			
			
			//When window is resized, redraw map for the tiles to refresh properly
			redraw();			
		});		
	}
	
	/**
	 * defaultData : {defaultLat:num,defaultLng:num,defaultZoomLevel:num,mapWidth:num,techIcon:str,teamIcon:str,woIcon:str,tags:Object,userDateFormat:str}
	 */
	function renderMap(defaultData,parentElement/*dom element*/)
	{	
		if(initialized)
			return;
		
		defaultConfig = defaultData;
		
		dcViews.render(defaultConfig);
		
		var mapOptions = getMapOptions();
		
		if(parentElement)
		{
			mapParentDiv = parentElement;			
	        mapInstance = new google.maps.Map(parentElement,mapOptions);	        
	        initialized = true;	        
	        
	        
	        //Check for compatibility with IE8 when setting styles
	        trafficLayerDiv = getTrafficOverlayDiv();
	        
	        mapInstance.controls[google.maps.ControlPosition.RIGHT_TOP].push(trafficLayerDiv);
	        
	        google.maps.event.addDomListener(trafficLayerDiv, 'click', setTrafficLayerVisibility);
	        
	        if(!trafficLayer)
	        	trafficLayer = new google.maps.TrafficLayer();
	        	
	        //Initialize the tooltip manager
	        Ext.tip.QuickTipManager.init(false,{
			    style : {textAlign : "center"},
			    minWidth : 75
			});
	        
	        if(!dcWindow)//For inline map create menubar as soon as the map is rendered
	        {
	        	createMenuBar();
	        	createRadiusActionBar();
	        	createLocationBaseBar();
	        }
		}
		
		//Create required instances for plotting route
		directionsService = new google.maps.DirectionsService();
        directionsDisplay = new google.maps.DirectionsRenderer();
        directionsDisplay.setOptions({suppressMarkers:true,suppressPolylines:true});
        directionsDisplay.setMap(mapInstance);       
       
		
		// notify the views panel
		dcViews.mapRendered(parentElement);
		return mapInstance;		
	}
	
	function loadDefaultMapConfig()
	{
		if(mapInstance)
		{
			var mapOptions = getMapOptions();
			        
			mapInstance.setOptions(mapOptions);
		}
	}
	
	function getMapOptions()
	{
		var defaultData = defaultConfig;
		var mapTypeId = google.maps.MapTypeId.ROADMAP;
		var zoom = defaultData.defaultZoomLevel;
		
		if(selectedMapTypeId)
			mapTypeId = selectedMapTypeId;
		
		if(zoomLevel)
			zoom = zoomLevel;
		
		var mapOptions = {
		          center : new google.maps.LatLng(defaultData.defaultLat, defaultData.defaultLng),
		          zoom : zoom,
		          mapTypeId : mapTypeId,
		          mapTypeControlOptions : {position : google.maps.ControlPosition.RIGHT_TOP,
		          										  style : google.maps.MapTypeControlStyle.HORIZONTAL_BAR},
		          panControl : false,
		          streetViewControl : false,
		          zoomControlOptions : {position : google.maps.ControlPosition.LEFT_TOP,
		          									 style : google.maps.ZoomControlStyle.SMALL}
		        };
		
		 return mapOptions;
	}
	
	function getTrafficOverlayDiv()
	{
		var trafficOverlayDiv = document.createElement("div");
		var style = trafficOverlayDiv.style;
		
		//style.width = "75px";
		style.overflow = "hidden";
		style.textAlign = "center";
		
		try
		{
			style.border = "1px solid rgba(0, 0, 0, 0.15)";
		}
		catch(e)//For IE8
		{
			style.border = "#666 1px solid";
		}
		
		style.fontFamily = 'Roboto,Arial,sans-serif';
		style.fontSize = '11px';
		style.boxShadow = "0px 1px 4px -1px rgba(0, 0, 0, 0.3)";
		style.padding = "1px 6px";
		style.backgroundColor = "rgb(255, 255, 255)";
		style.MozUserSelect = "none";
		style.cursor = "pointer";
		style.backgroundClip = "padding-box";
		style.margin = "0px 5px 0px 0px";
		trafficOverlayDiv.innerHTML = defaultConfig.tags["TAG369"];
		
		return trafficOverlayDiv;
	}
	
	function setTrafficLayerVisibility()
	{
		if(!trafficLayer.getMap())
		{
			trafficLayer.setMap(mapInstance);
			this.style.backgroundColor = "#E8E8E8";
		}
		else
		{
			trafficLayer.setMap(null);
			this.style.backgroundColor = "#FFFFFF";
		}
	}
	
	function redraw()
	{	 
		google.maps.event.trigger(mapInstance, 'resize');
		mapInstance.setZoom(mapInstance.getZoom());
		
		//relayoutmap();
	}
	
	 function relayoutmap()
   {    
      var innerHeight = window.innerHeight || document.documentElement.clientHeight || document.body.clientheight;      
      if(innerHeight)
        {
        var newheight=innerHeight+35;			
	    document.getElementById("panel-1009").style.top =0+"px";			
	    document.getElementById("panel-1009").style.height =newheight+"px";			
	    document.getElementById("panel-1009-innerCt").style.height = newheight + "px";
	    document.getElementById("panel-1009-body").style.height = newheight + "px";			
	    document.getElementById("map").style.height = newheight + "px";		
	    }
   }
	
	function loadDCContext(context/*Contextual data to be loaded*/)
	{
		if(selectedMapTypeId)
		{
			var mapOptions = {mapTypeId : selectedMapTypeId, zoom : zoomLevel};
			
			mapInstance.setOptions(mapOptions);
		}
		
		if(totalRoutesPlotted > 0)
		{
			drawRouteForDay(/*no day means day of the first route*/);
		}
		
		if(searchTeamData)
		{
			drawSearchedTeams(searchTeamData.teams,searchTeamData.selectedWO);
		}
		
		if(searchTechData)
		{
			//var radiusComp = Ext.getCmp("radiusComp");
			
			//if(radiusComp)
				//radiusComp.setValue(context.selectedRadius);
			circle_radius=context.selectedRadius;
			////alert("radius_mode2:"+radius_mode);
			radius_mode=context.isRadiusModeOn;
			
			drawSearchedTechnicians(searchTechData.technicians,searchTechData.selectedWO);
			
			//var radiusChk = Ext.getCmp("radiusChk");	
			
			//if(radiusChk)
				//radiusChk.setValue(context.isRadiusModeOn);
		}
		
		Ext.getCmp("tabpanel").setActiveTab(context.isTabModeIndex);
		
		//plotnearby
		if(dcWindow || dcViews.getUI().hidden)//Second condition added to fix issue #11952
		{
			dcViews.getUI().on("afterlayout",function()
			{
				dcViews.setContext(context.plotnearby);
			},this,{single:true,delay:100});
			
			//No matter its visible or not, make it visible for the context to be set correctly in popup map
			//Use case : When views are plotted and the tab panel is toggled to false. Then when setting the current inline context to
			//popup map results in error as the tab panel is not created and we are trying to set the views
			dcViews.show();
		}
		else
			dcViews.setContext(context.plotnearby);
		
		if(context.plotnearby.active == true)
			dcViews.show();
		else
			dcViews.hide();
	}
	
	function setDefaultMapConfig(config)
	{
		if(config && config.hasOwnProperty("defaultLat") && config.hasOwnProperty("defaultLng"))
		{
			defaultConfig = config;
			return true;
		}
		
		return false;
	}
	
	function getDefaultMapConfig()
	{
		return defaultConfig;
	}

	function createMarkerWithLabel1(latLng/*LatLng*/,title/*LatLng*/,icon/*String*/,address/*String*/,subject/*String*/,icontype/*String*/,markercolor/*String*/,FirstName/*String*/,LastName/*String*/,SmallPhotoUrl/*String*/,scale/*Boolean*/,type/*String - Tech/Team/WO*/)
	{	
		var image = icon;
		if (typeof(image) == 'string') {
			image = {
				url: icon
			};
		}
	    		
		var marker = new google.maps.Marker({
    			position : latLng,
    			title : "",
    			icon : window.getResourcePath() + "resources/themes/images/svmx-dc-map/custom/crescent_dark_28.png",
    			address : address,
    			anchorPoint : new google.maps.Point(0,0)
    		});
    		
    		marker.icon = {				
						path: over_night_marker, 
						fillColor: markercolor,
						fillOpacity: 1,
						scale: 1,
						strokeColor: 'black',
						 anchor: new google.maps.Point(20,33),
						strokeWeight: 1,
					  };
	    		      marker.scale = .3;
	    		      
    		
    		marker.Name = title;
    		marker.type = 'Overnight';
    		marker.address= address;
    		marker.subject= subject;
    		return marker;
	}
	
	
	function createMarkerWithLabel(latLng/*LatLng*/,title/*LatLng*/,icon/*String*/,address/*String*/,icontype/*String*/,markercolor/*String*/,FirstName/*String*/,LastName/*String*/,SmallPhotoUrl/*String*/,scale/*Boolean*/,type/*String - Tech/Team/WO*/)
	{	
		var image = icon;
		if (typeof(image) == 'string') {
			image = {
				url: icon
			};
		}
		   	
    var firstName=FirstName;
    var lastName=LastName; 
    var IconType=icontype;  
    var MarkerColor=markercolor;    
    
	var str = '';
	var arr=[];
	
	 if(firstName) 
	  {  
	   str=String(firstName).substring(0, 1);	   
	  }
	  if(lastName)
	  {
		 if((lastName)&&(firstName)) 
		  { 
		   str=String(firstName).substring(0, 1)+String(lastName).substring(0, 1);
		  }
		  else
		  {
		  str=String(lastName).substring(0, 1);
		  }
	  }
	
	arr=title.split(" ");	
	if(arr.length>0)
	{
	 if(!firstName) 
	  {      	
	  str=String(arr[0]).substring(0, 1)
	  }
	  
	}
	if(arr.length>1)
	{
	 if(!lastName) 
	  {      	
	   str=String(arr[0]).substring(0, 1)+String(arr[1]).substring(0, 1);
	  }
	}	
		if (icon ==="http://files.servicemax.com/images/MapTechnicianHome.svg")
		{
		//str = title.substring(0, 1);
		}
		
		else if (icon ==="http://files.servicemax.com/images/MapTechnicianCurrent.svg")
		{
		//str = title.substring(0, 1);
		}
		var marker = new google.maps.Marker({
    			position : latLng,
    			title : "",
    		label : {
    		text:str,
    		color:'#FFFFFF'},
    		//labelContent :"ABCD",
    			icon : image,
    			//Set address as well. Its not a property of MarkerOptions but can be used if latLng not available
    			address : address,
    			//Shadow wont work in v3.14
    			//shadow : icon,
    			anchorPoint : new google.maps.Point(0,0)
    		});
    		if(scale === true)
    		{
	    		var iconObj = {};
	    		iconObj.url = icon;
	    		//Do not scale as it creates problem when using svg
	    		//iconObj.scaledSize = new google.maps.Size(25,25);
	    			    		
	    		marker.icon = iconObj;
	    		if (IconType ==="Home")
	    		//if(Ext.getCmp("home_loc").checked == true)
	    		{	    		
			    		marker.icon = {				
						path: home_marker, 
						fillColor: MarkerColor,
						fillOpacity: 1,
						scale: 1,
						strokeColor: 'black',
						strokeWeight: 0,
						anchorPoint : new google.maps.Point(0,0)
					  };
	    		      marker.scale = .3;
	    		}
	    		if (IconType ==="Current")
	    		//if(Ext.getCmp("current_loc").checked == true)
	    		{
			    		marker.icon = {				
						path: current_marker, 
						fillColor: MarkerColor,
						fillOpacity: 1,
						scale: 0.6,
						strokeColor: 'black',
						strokeWeight: 0,
						anchor: new google.maps.Point(0,0) 
					  };
			    		marker.scale = .3;			    		
	    		}	    		
    		}
    		
    		marker.Name = title;
    		marker.type = type;
    		marker.FirstName=FirstName;
    		marker.LastName=LastName;
    		marker.SmallPhotoUrl=SmallPhotoUrl;
    		marker.initial=str;
    		return marker;
	}
	
	
	function createMarker(latLng/*LatLng*/,title/*LatLng*/,icon/*String*/,address/*String*/,scale/*Boolean*/,type/*String - Tech/Team/WO*/)
	{
		var image = icon;
		if (typeof(image) == 'string') {
			image = {
				url: icon
			};
		}		
		var marker = new google.maps.Marker({
    			position : latLng,
    			title : "",
    			icon : image,
    			//Set address as well. Its not a property of MarkerOptions but can be used if latLng not available
    			address : address,
    			//Shadow wont work in v3.14
    			//shadow : icon,
    			anchorPoint : new google.maps.Point(0,0)    			
    		}); 
    		
    	      		
    		if(scale === true)
    		{
	    		var iconObj = {};
	    		iconObj.url = icon;
	    		//Do not scale as it creates problem when using svg
	    		//iconObj.scaledSize = new google.maps.Size(25,25);
	    		
	    		marker.icon = iconObj;
    		}
    		
    		marker.Name = title;
    		marker.type = type;
    		return marker;
	}
	
	function createWorkOrderMarker(latLng/*LatLng*/,title/*LatLng*/,icon/*String*/,address/*String*/,count/*String*/,scale/*Boolean*/,type/*String - Tech/Team/WO*/)
	{
		var image = icon;
		if (typeof(image) == 'string') {
			image = {
				url: icon
			};
		}		
		var marker = new google.maps.Marker({
    			position : latLng,
    			title : "",    			
    		label : {
    		text:String(count),
    		color:'#000000'},
    			icon : image,
    			//Set address as well. Its not a property of MarkerOptions but can be used if latLng not available
    			address : address,
    			//Shadow wont work in v3.14
    			//shadow : icon,
    			anchorPoint : new google.maps.Point(0,0)    			
    		}); 
    		
    	      		
    		if(scale === true)
    		{
	    		var iconObj = {};
	    		iconObj.url = icon;
	    		//Do not scale as it creates problem when using svg
	    		//iconObj.scaledSize = new google.maps.Size(25,25);
	    		
	    		marker.icon = iconObj;
    		}
    		
    		marker.Name = title;
    		marker.type = type;
    		return marker;
	}
	/**
	 * If position is there for the marker, its added to the map.
	 * If its not there and address is there then first the lat lng is resolved
	 * and then the marker is added to the map
	 */
	function addMarker(marker/*Marker*/)
	{
		if(!marker)
			return false;
		
		var added = false;
		
		if(marker.position)
		{
			marker.setMap(mapInstance);
			
			if(bounds)
				bounds.extend(marker.position);
			
			added = true;
		}
		else if(latLngMap.hasOwnProperty(marker.info.Id))
		{
			var location = latLngMap[marker.info.Id];
			marker.position = new google.maps.LatLng(location.lat,location.lng);
			marker.setMap(mapInstance);
			
			//Populate in respective details object as well
   			marker.info.lat = location.lat;
   			marker.info.lng = location.lng;
			
			if(bounds)
				bounds.extend(marker.position);
			
			added = true;
		}
		else if(marker.address)
		{
			lookupLatLng(marker);
		}
		else//Report error
		{
			//Add Id field to open the record from salesforce. Currently its implemented for Workorder in DC error message
			//When route is plotted and WO related to event doesnot have location info, take the Id from WOId field
			var Id = marker.info.hasOwnProperty("WOId") ? marker.info.WOId : marker.info.Id;
			invalidMarkers.push({Name:marker.Name,type:marker.type,Id:Id});
			added = true;
		}
		
		return added;
	}
	
	function createPolyline(polyLineOptions/*PolylineOptions*/)
	{
		return new google.maps.Polyline(polyLineOptions);
	}
	
	function addPolyline(polyline/*Polyline*/)
	{
		if(!polyline)
			return;
			
		polyline.setMap(mapInstance);
	}
	
	function clearRoute()
	{
		var i = null, routeMarkers = null, routePolylines = null, rd = null;
		for (i in routeData) {
			rd = routeData[i]; routeMarkers = rd.routeMarkers || []; routePolylines = rd.routePolylines || [];
			if (routeMarkers) {
				routeMarkers.foreach(function(item){
					item.setMap(null);
				});
			}
			
			if (routePolylines) {
				routePolylines.foreach(function(item){
					item.setMap(null);
				});
			}
			
		}
		//if (techHomeMarkerDest)
		//{
		//techHomeMarkerDest.setMap(null);
	//	}
		
		
		var tmp = routeData;
		routeData = {};
		lastPlottedRoute = null;
		totalRoutesPlotted = 0;
		
		locationBaseBarVisible(false);
		return tmp;
	}
	
	function clearRouteForTech(Id/*String*/)
	{		
		if(!Id || !routeData.hasOwnProperty(Id))
			return;
		
		var routeMarkers = null, routePolylines = null, rd = routeData[Id];
		routeMarkers = rd.routeMarkers || []; routePolylines = rd.routePolylines || [];
		if (routeMarkers) {
			routeMarkers.foreach(function(item){
				item.setMap(null);
			});
		}
		
		if (routePolylines) {
			routePolylines.foreach(function(item){
				item.setMap(null);
			});
		}
	}
	
	function clearSearchTeamMarkers()
	{
		if(searchTeamMarkers)
    	{
    		searchTeamMarkers.foreach(function(item){
    			item.setMap(null);
    		});
    		
    		searchTeamMarkers = null;
    	}
    	
    	searchTeamData = null;
	}
	
	function clearSearchTechMarkers()
	{	
		if(searchTechMarkers)
    	{
    		searchTechMarkers.foreach(function(item){
    			item.setMap(null);
    		});
    		
    		searchTechMarkers = null;
    	}
    	
    	searchTechData = null;
	}
	
	function clearRadiusModeCircle(resetStepper/*Boolean*/)
	{	    
		if(radiusModeCircle)
			{
			 radiusModeCircle.remove(); 
			 radiusModeCircle.setMap(null);			
			}			
			radiusModeCircle = null;
			
		if(resetStepper == true)
		{
		circle_radius=defaultConfig.defaultRadius;
		}
		////circle_radius=defaultConfig.defaultRadius;
	}
	
	function hideTrafficLayer()
	{
		if(trafficLayer)
		{
			trafficLayer.setMap(null);
			trafficLayerDiv.style.backgroundColor = "#FFFFFF";
		}
	}
	
	function routeActionMenuItemsVisible(visible/*Boolean*/)
    {
    	if(!routeActionMenuItems)
    		return;
    	
    	routeActionMenuItems.foreach(function(item)
    	{
    		item.setVisible(visible);
    	});
    }
    
    function routeActionMenuItemsEnabled(enabled/*Boolean*/)
    {
    	if(!routeActionMenuItems)
    		return;
    	
    	routeActionMenuItems.foreach(function(item)
    	{
    		if(item.xtype == "datefield" || item.xtype == "button")
    			item.setDisabled(!enabled);
    	});
    }
	
	function clearMap()
	{
		clearRoute();		
		clearSearchTechMarkers();
		clearSearchTeamMarkers();
		clearRadiusModeCircle(true);
		hideTrafficLayer();
		routeActionMenuItemsVisible(false);
		radiusModeControlsVisible(false);
		locationBaseBarVisible(false,true);
		invalidMarkers = [];
		dcViews.clearPlot();
		tempTechData = null;
		tempTechList = null;
		tempSelectedWO = null;	
		if(dcWindow)
		{
			dcWindow.MapHandle.a();//Clear inline map as well
		}		
		radius_mode=true;	
	}
	
	function clearMapBtnClick()
	{
		clearMap();
		tempTechData = null;
		tempTechList = null;
		tempSelectedWO = null;
		if(dcWindow)
		{
			dcWindow.MapHandle.a();//Clear inline map as well
		}		
		radius_mode=true;				
	}
	
	function popoutMap()
	{
		if(window.DCHandle)//If its inline map, this will be true
		{
			var handle = window.DCHandle;
			handle.popoutMap();
		}
	}
	
	function drawRouteForDay(day/*String - prev/next*/)
	{
		if(totalRoutesPlotted == 0)
			return;
		
		var rd = lastPlottedRoute.routeData;
			
		var currentDay = new Date(rd.currentDateInMilliSeconds);
		var ganttStartDate = new Date(rd.ganttStartDateInMilliSeconds);
		var ganttEndDate = new Date(rd.ganttEndDateInMilliSeconds);
		var newDay = new Date(currentDay.getTime());
		
		if(day == Literals.PREVIOUS)
			newDay.setDate(currentDay.getDate() - 1);
		else if(day == Literals.NEXT)
			newDay.setDate(currentDay.getDate() + 1);
		
		//Consider just the date as we are just concerned with day and not time
		newDay.setHours(0);
		newDay.setMinutes(0);
		newDay.setSeconds(0);
		newDay.setMilliseconds(0);
		
		//If newDay is out of current selected date range, then return
		if(newDay.getTime() > ganttEndDate.getTime() || newDay.getTime() < ganttStartDate.getTime())
			return;
		
		drawRouteForSelectedDate(newDay);
	}
	
	function drawRouteForSelectedDate(date/*Date*/)
	{
		if(!date || !Ext.isDate(date))
			return;
		
		//Consider just the date as we are just concerned with day and not time
		date.setHours(0);
		date.setMinutes(0);
		date.setSeconds(0);
		date.setMilliseconds(0);
		
		var handle = getDCHandle();
		
		if(handle)
		{
			// clear the currently plotted route
			var allRouteData = clearRoute(), data = null, i = null;
			
			plotRouteCounter = 0;
			routeActionMenuItemsEnabled(false);
			//start plotting all the routes
			for (i in allRouteData) {
				data = {
					currentDateInMilliSeconds: date.getTime(),
					Id: allRouteData[i].routeData.technician.Id
				};
				
				plotRouteCounter++;
				handle.drawTechRouteForDay(data);
			}
		}
	}

	function createLocationBaseBar()
	{
		if(locationBaseDiv)
			return;

		locationBaseDiv = document.createElement("div");
		var style = locationBaseDiv.style;
		style.height = "21px";
  		style.overflow = "hidden";
  		style.fontSize = '12px';
  		style.boxShadow = "0px 1px 4px -1px rgba(0, 0, 0, 0.3)";
  		style.backgroundColor = "rgb(255, 255, 255)";
  		style.paddingTop = "2px";
  		style.paddingLeft = "2px";
  		style.fontFamily = 'Roboto,Arial,sans-serif';
		style.fontSize = "11px";
		style.display = "none";

	  	var homeRadio = document.createElement("input");
		homeRadio.type = "radio";
		homeRadio.id = "home_loc";
		homeRadio.value = "home_loc";
		homeRadio.checked= 'true';
		homeRadio.name = 'base';
		locationBaseDiv.appendChild(homeRadio);
	 	
	  	var homeText = document.createElement("B");
		var homeTextNode = document.createTextNode(defaultConfig.tags["TAG470"]);
		homeText.style.paddingLeft = '2px';
		homeText.style.paddingRight= '5px';
		homeText.style.fontSize= '12px';
		homeText.appendChild(homeTextNode);
	  	locationBaseDiv.appendChild(homeText);
	 	  
	  	var currentRadio = document.createElement("input");
		currentRadio.type = "radio";
		currentRadio.id = "current_loc";
		currentRadio.value = "current_loc";
		currentRadio.name = 'base';
		
		if(defaultConfig.locationBase == "current")
		{
			homeRadio.checked= 'false';
			currentRadio.checked= 'true';
		}
		
		locationBaseDiv.appendChild(currentRadio);
	 	
	  	var currentText = document.createElement("B");
		var currentTextNode = document.createTextNode(defaultConfig.tags["TAG471"]);
		currentText.style.paddingLeft = '2px';
		currentText.style.paddingRight= '5px';
		currentText.style.fontSize= '12px';
	  	currentText.appendChild(currentTextNode);
	  	locationBaseDiv.appendChild(currentText);
	 	  
	  	var bothRadio = document.createElement("input");
		bothRadio.type = "radio";
		bothRadio.id = "both_loc";
		bothRadio.value = "both_loc";
		bothRadio.name = 'base';
		
		if(defaultConfig.locationBase == "both")
		{
			homeRadio.checked= 'false';
			currentRadio.checked= 'false';
			bothRadio.checked= 'false';
		}
		
		locationBaseDiv.appendChild(bothRadio);
	 	
	  	var bothText = document.createElement("B");
		var bothTextNode = document.createTextNode(defaultConfig.tags["TAG472"]);
		bothText.style.paddingLeft = '2px';
		bothText.style.paddingRight= '5px';
		bothText.style.fontSize= '12px';
	  	bothText.appendChild(bothTextNode);
	  	locationBaseDiv.appendChild(bothText);
	
	  	// Setup click-event listener
	  	google.maps.event.addDomListener(homeRadio, 'click', function() {
			document.getElementById("current_loc").checked = false; 
			document.getElementById("both_loc").checked = false; 
			drawTechnicianRoute(tempTechData);
			drawSearchedTechnicians(tempTechList,tempSelectedWO);
			//config.mapPlotPreference = "Home";
			locationBaseRadioClick();
	  	});
	  
	  	google.maps.event.addDomListener(currentRadio, 'click', function() {
	  		document.getElementById("both_loc").checked = false; 
			document.getElementById("home_loc").checked = false; 
			drawTechnicianRoute(tempTechData);
			drawSearchedTechnicians(tempTechList,tempSelectedWO);
			//config.mapPlotPreference = "Current";
			locationBaseRadioClick();
	  	});
	  
	  	google.maps.event.addDomListener(bothRadio, 'click', function() {
			document.getElementById("current_loc").checked = false; 
			document.getElementById("home_loc").checked = false; 
			drawTechnicianRoute(tempTechData);
			drawSearchedTechnicians(tempTechList,tempSelectedWO);
			//config.mapPlotPreference = "Both";
			locationBaseRadioClick();
	  	});

	  	////mapInstance.controls[google.maps.ControlPosition.TOP_LEFT].push(locationBaseDiv);
	} 
	
	function locationBaseRadioClick()
    {  
     	var handle = getDCHandle();
     	handle.locationBaseRadioClick();
    }  
	
	function locationBaseBarVisible(value,reset)
	{	
		if(!locationBaseDiv)
			return;
        
		locationBaseDiv.style.display = value ? "block" : "none";
		
		//Redraw because the map layout does not get refreshed and the zoom in btn overlaps the bar
		if(value)
			redraw();
		
		if(reset == true)//Take default value fron UI Setting
		{		    
			if(defaultConfig.locationBase == "home")
			{
				Ext.getCmp("home_loc").checked = true;
			}
			else if(defaultConfig.locationBase == "current")
			{
				Ext.getCmp("current_loc").checked= true;
			}
			else if(defaultConfig.locationBase == "both")
			{
				Ext.getCmp("both_loc").checked = true;
			}
		}
	}
	
	function getSelectedLocationBase()
	{
		var radioId = "";

		if(Ext.getCmp("home_loc").checked ==true)
		{
		radioId ="home_loc";
		}
		if(Ext.getCmp("current_loc").checked ==true)
		{
		radioId ="current_loc";
		}
		if(Ext.getCmp("both_loc").checked ==true)
		{
		radioId ="both_loc";
		}
		
		return radioId;
	}
	
	function getSelectedTab()
	{
		var tabId = "";
					
        var activeTab = Ext.getCmp("tabpanel").getActiveTab();
        var activeTabIndex = Ext.getCmp("tabpanel").items.indexOf(activeTab);       
		tabId=activeTabIndex;
		
		return tabId;
	}
	
	function CustomPlotControl(controlDiv, mapInstance)
	{
		  
	  	var homeRadio = document.createElement("input");
		homeRadio.type = "radio";
		homeRadio.id = "home_plotLoc";
		homeRadio.value = "no";
		homeRadio.checked= 'true';
		homeRadio.title = 'Home';
		controlDiv.appendChild(homeRadio);
		 	
		var homeText = document.createElement("B");
   		var homeTextNode = document.createTextNode(defaultConfig.tags["TAG470"]);
   		homeText.style.paddingLeft = '2px';
		homeText.style.paddingRight= '5px';
		homeText.style.fontSize= '12px';
    	homeText.appendChild(homeTextNode);
		controlDiv.appendChild(homeText);
		 	  
		var currentRadio = document.createElement("input");
  		currentRadio.type = "radio";
   		currentRadio.id = "current_plotLoc";
   		currentRadio.value = "no";
   		currentRadio.title = 'Current';
   		controlDiv.appendChild(currentRadio);
		 	
		var currentText = document.createElement("B");
   		var currentTextNode = document.createTextNode(defaultConfig.tags["TAG471"]);
   		currentText.style.paddingLeft = '2px';
		currentText.style.paddingRight= '5px';
		currentText.style.fontSize= '12px';
    	currentText.appendChild(currentTextNode);
		controlDiv.appendChild(currentText);
			  
		var bothRadio = document.createElement("input");
  		bothRadio.type = "radio";
   		bothRadio.id = "both_plotLoc";
   		bothRadio.value = "no";
   		bothRadio.title = 'Both';
   		controlDiv.appendChild(bothRadio);
		 	
		var bothText = document.createElement("B");
   		var bothTextNode = document.createTextNode(defaultConfig.tags["TAG472"]);
   		bothText.style.paddingLeft = '2px';
		bothText.style.paddingRight= '5px';
		bothText.style.fontSize= '12px';
    	bothText.appendChild(bothTextNode);
		controlDiv.appendChild(bothText);
		
		// Setup click-event listener
		google.maps.event.addDomListener(homeRadio, 'click', function() {
				document.getElementById("current_plotLoc").checked = false; 
				document.getElementById("both_plotLoc").checked = false; 
				drawSearchedTechnicians(tempTechList,tempSelectedWO);
				//config.mapPlotPreference = "Home";
		});
		  
		google.maps.event.addDomListener(currentRadio, 'click', function() {
		  		document.getElementById("both_plotLoc").checked = false; 
				document.getElementById("home_plotLoc").checked = false; 
				drawSearchedTechnicians(tempTechList,tempSelectedWO);
				//config.mapPlotPreference = "Current";
		});
		  
		google.maps.event.addDomListener(bothRadio, 'click', function() {
				document.getElementById("current_plotLoc").checked = false; 
				document.getElementById("home_plotLoc").checked = false; 
				drawSearchedTechnicians(tempTechList,tempSelectedWO);
				//config.mapPlotPreference = "Both";
		});
	} 
	
	
	/**
     * Draw technician route on map.
	 * data - {technician:{},
 	 *     	  currentDateInMilliSeconds:0,
     *        eventsForWorkOrders:[],
    * futureOverNightStayEvent:[],
    *pastOverNightStayEvent:[],
     *        ganttStartDateInMilliSeconds:0,
     *        ganttEndDateInMilliSeconds:0,
     *        currentTimeMarkerInMillis:0,
     *        viewAllEventsForToday:boolean,
     *        currentDateInUserFormat:string}
     */
     function createOvernightStayMarker(data/*Team/Tech/WO details with lat,lng and address*/,markercolor/*String*/,scale/*Boolean*/,type/*Team/Tech/WO*/)
	{
		var lat,lng,position,marker;
		
		if(data.lat !=="undefined")
    		lat = Number(data.lat);
    	
    	if(data.lng !=="undefined")
    		lng = Number(data.lng);
    	
    	if(data.lat !== 'undefined' && data.lng !== 'undefined' )
    		position = new google.maps.LatLng(lat, lng);
    		
    		
    		
    		
    		
    	
    	var icon = defaultConfig.techIcon;
    	var MarkerColor=markercolor;    	
    	
    	if(type == Literals.TEAM)
    		icon = defaultConfig.teamIcon;
    	else if(type == Literals.WORKORDER)
    		icon = Literals.BALLOON_URL;        	
    	var address = data.address;
    	var subject = data.subject;
    	
    	//For technician with current location, don't display address as data.address has value for home address
    	if(type == Literals.TECHNICIAN)
    		address = "";
    	
    	marker = createMarkerWithLabel1(position,data.Name,icon,address,subject,"Current",MarkerColor,data.FirstName,data.LastName,data.SmallPhotoUrl,scale,'Overnight');
		
		return marker;
	}
	
	function showInfoForTemp()
    {
    var info = "<div style='text-align:left;'>"
						+ "<B>" + config.tags["TAG335"] + "</B><br/><br/>"
						+ "<B>" + config.tags["TAG336"] + "</B>: " +  plotNearByLatLng.lat() + "<br/>"
						+ "<B>" + config.tags["TAG337"] + "</B>: " + plotNearByLatLng.lng() + "<br/>"
						+ "<B>" + config.tags["TAG017"] + "</B>: " + plot_circle_radius + "&nbsp;" + config.mapUnitText 
					+ "</div>";
			
			var infowindow = new google.maps.InfoWindow({ content: info, pixelOffset : new google.maps.Size(0,-15) });
			
			//mouseover used to fix issue #10659. Since we are not using mouseout, there should be no problem
			google.maps.event.addListener(plotCenterMarker, 'mouseover', function() {
				infowindow.open(mapInstance,plotCenterMarker);
			});
    }
	
	function drawTechnicianRoute(data)
    {    
    //clearMarkers();
    	if(!data || !data.technician)
    		return;	    
	   
	    locationBaseBarVisible(true);

	    tempTechData = data;
	     		
    	var lat,lng,position,title,techMarker,techHomeMarker,technician,eventsForWorkOrders,woMarker,futureOverNightStayEvent,pastOverNightStayEvent,techHomeMarkerDest,destTechHomeMarker;
    	var wayPoints = [],currentDate,currentTimeMarker,callLater = false,eventInProgress;
    	var skippedEvents = [],added = true,viewAllEventsForToday;
    	
    	var _routeData = data;
    	
    	technician = _routeData.technician;   
    	 pastOverNightStayEvent = _routeData.pastOverNightStayEvent;
    	 futureOverNightStayEvent = _routeData.futureOverNightStayEvent;
    		
    	eventsForWorkOrders = _routeData.eventsForWorkOrders;//These event are for currentDate
    	currentDate = new Date(_routeData.currentDateInMilliSeconds);
    	currentTimeMarker = new Date(_routeData.currentTimeMarkerInMillis);
    	viewAllEventsForToday = _routeData.viewAllEventsForToday;
    	
   		bounds = new google.maps.LatLngBounds();   		
   				
    	var MarkerColor = getTechColorForRoute(technician.Id);
    	  	
    	techMarker = createCurrentMarker(technician,MarkerColor,true,Literals.TECHNICIAN);	
    	if (pastOverNightStayEvent.length > 0)
    	{
    	
    		techHomeMarker = createOvernightStayMarker(pastOverNightStayEvent[0],MarkerColor,true,Literals.TECHNICIAN);	 
    		//techMarker.address = pastOverNightStayEvent[0].subject +/n+pastOverNightStayEvent[0].location;
    		techHomeMarker.info = technician; 
    	}
    	else
    	{
    		techHomeMarker = createHomeMarkerFrom(technician,MarkerColor,true,Literals.TECHNICIAN);	   
    		techHomeMarker.info = technician; 
    		
	    }
    	
    	techMarker.info = technician;
    	
    	
    	//if(document.getElementById("current_loc").checked == true || document.getElementById("both_loc").checked == true){ 
    	//	added = addMarker(techMarker);	
  	    //}
  	    
  	   // if(document.getElementById("home_loc").checked == true || document.getElementById("both_loc").checked == true){ 
    	//	added = addMarker(techHomeMarker);
    	//}
    	if(Ext.getCmp("current_loc").checked == true || Ext.getCmp("both_loc").checked == true){ 
    		added = addMarker(techMarker);	
  	    }
  	    
  	    if(Ext.getCmp("home_loc").checked == true || Ext.getCmp("both_loc").checked == true){ 
    		added = addMarker(techHomeMarker);
    	}
    	
    	
    	if(!added)
    		callLater = true;
    	
    	google.maps.event.addListener(techMarker, 'mouseover', showInfo);
    	google.maps.event.addListener(techHomeMarker, 'mouseover', showInfo);
    	
    	
    	
		 
    	var routeMarkers = [];
    	
    	routeMarkers.push(techMarker);
    	
    	//If route for a tech is plotted consecutively from DC, clear the previous data that is plotted on map before
    	//overwriting the info in routeData. If this is not done then Clear Map button does not clear everything
    	//Fix for #10496 and related #10497
    	clearRouteForTech(_routeData.technician.Id);
    	
		var rd = {routeMarkers : routeMarkers, routeData : _routeData};
		routeData[_routeData.technician.Id] = rd;

		totalRoutesPlotted = 0;
		for(var routeIndex in routeData){ ++totalRoutesPlotted; }
		lastPlottedRoute = rd;
		
		//if(document.getElementById("home_loc").checked == true || document.getElementById("both_loc").checked == true){ 
    	//var source = techHomeMarker;
    	//var destination = techHomeMarker;
    	//}
    	
    	//if(document.getElementById("current_loc").checked == true){ 
    	//var source = techMarker;
    	//var destination = techMarker;
    	//}
    	if(Ext.getCmp("home_loc").checked == true || Ext.getCmp("both_loc").checked == true){
    	var source = techHomeMarker;
    	var destination;
    	if (futureOverNightStayEvent.length > 0)
    	{
    	var obj = {lat:12.2958104, lng:76.63938050000002, address:", Lingsugur, Karnataka, 584122, India"};
    	
    		 techHomeMarkerDest = createOvernightStayMarker(futureOverNightStayEvent[0],MarkerColor,true,Literals.TECHNICIAN);
    		 destination = techHomeMarkerDest;
    		  techHomeMarkerDest.info = technician; 
    		 added = addMarker(techHomeMarkerDest);
    		// routeMarkers.push(techHomeMarkerDest);
    		  
    		  google.maps.event.addListener(techHomeMarkerDest, 'mouseover', showInfo);
    	  
    		// google.maps.event.addListener(techHomeMarkerDest, 'mouseover', showInfoForTemp);
    		// techHomeMarkerDest.address = futureOverNightStayEvent[0].subject +','+futureOverNightStayEvent[0].locatiom
    		 
    	}
    	 else
    	 {
    	  destTechHomeMarker = createHomeMarkerFrom(technician,MarkerColor,true,Literals.TECHNICIAN);	   
    		 destination = destTechHomeMarker;
    		  destTechHomeMarker.info = technician;
    		  added = addMarker(destTechHomeMarker);
    		// routeMarkers.push(destTechHomeMarker);
    		  
    		      	  google.maps.event.addListener(destTechHomeMarker, 'mouseover', showInfo);
    		  
    		
    		
    		// destTechHomeMarker.address = futureOverNightStayEvent[0].subject +','+futureOverNightStayEvent[0].locatiom
    	}
    	}
    	
    	if(Ext.getCmp("current_loc").checked == true){ 
    	var source = techMarker;
    	var destination = techMarker;
    	}
    		
    	if(eventsForWorkOrders)
    	{
    		var eventsForPlotting = [];
    	
    		Array.prototype.foreach.call(eventsForWorkOrders,function(item)
    		{
    			if(isCurrentDateEvent(item,currentDate,currentTimeMarker,viewAllEventsForToday))
    			{
    				eventsForPlotting.push(item);
    			}
    			else
    			{
    				skippedEvents.push(item);
    			}
    			
    			//For event object, there is no Id property. Make sure its there for proper persistence in latLngMap 
    			item.Id = item.id;
    			
    			if(item.startTime.time < currentTimeMarker.getTime() && item.endTime.time > currentTimeMarker.getTime())
    				eventInProgress = item;
    		});
    		
    		if(!eventInProgress && skippedEvents.length > 0)
    		{
    			var mostRecentEvent = skippedEvents[skippedEvents.length-1];
    			var endDate = new Date(mostRecentEvent.endTime.time);
    			
    			//If most recent event and current time marker is on same day and that day is current day,
    			//then only start with most recent event
    			if(endDate.toDateString() == currentTimeMarker.toDateString() && 
    			   endDate.toDateString() == currentDate.toDateString() && viewAllEventsForToday == false)
    			{
    				eventsForPlotting.unshift(mostRecentEvent);
    			
    				//Set the source to null as we have a most recent event to be plotted as source
    				if(Ext.getCmp("current_loc").checked == true){ 
    				source = null;
    				}
    			}
    		}
    		else if(eventInProgress)//If its a past event but still in progress, start with it
    		{
    		if(Ext.getCmp("current_loc").checked == true){ 
    		
    		source = null;
    		}
    		}
    			
    		
    		added = true;
    		
    		for (var i = 0,j = 1; i < eventsForPlotting.length; i++)
    		{
    			lat = undefined;
    			lng = undefined;
    			position = null;
    			
    			var evt = eventsForPlotting[i];
    			
    			if(evt.lat)
		    		lat = Number(evt.lat);
		    	
		    	if(evt.lng)
		    		lng = Number(evt.lng);
		    	
		    	if(lat != undefined && lng != undefined)
		    		position = new google.maps.LatLng(lat, lng);
		    	
		    	var markerColor = getTechColorForRoute(technician.Id);
		    	if(markerColor)
		    	{
		    	markerColor=markerColor.substring(1, markerColor.length)
		    	}			    	    	
		    	//This is chart api url to generate numbered markers
		    	var iconUrl = Literals.BALLOON_URL + (j++) + "|" + markerColor + "|000000";
		    	//var iconUrl = Literals.BALLOON_URL;
		    		
		    	//woMarker = createWorkOrderMarker(position,evt.Name,iconUrl,evt.address,(j++),false,Literals.WORKORDER);//routeData.woIcon
		    	woMarker = createMarker(position,evt.Name,iconUrl,evt.address,false,Literals.WORKORDER);//routeData.woIcon
		    	woMarker.info = evt;
		    	
		    	added = addMarker(woMarker);
		    	
		    	//Added second condition to fix reopened issue #9773. For one scenario the original fix was not working.
		    	//If there are 2 events to be plotted. 1st one does not have location info and second one has only address info,
		    	//callLater was not set to true even if the lookup to address was required.
		    	//It was set to true only if last event had address.Hence route was not plotted
		    	if(!added || (!woMarker.position && woMarker.address != ""))
		    		callLater = true;
		    	
		    	google.maps.event.addListener(woMarker, 'mouseover', showInfo);
		    	
		    	routeMarkers.push(woMarker);
		    	
		    	var wp = {location : position ? position : evt.address};
		    	wayPoints.push(wp);
		    	
		    	//If marker does not have lat lng info, then update way point with the same after lat lng lookup
		    	woMarker.wayPoint = wp;
    		}
    	}
    	
    	//Add the home location after the waypoints have beed added
    	routeMarkers.push(techHomeMarker);
    	if(Ext.getCmp("home_loc").checked == true || Ext.getCmp("both_loc").checked == true){
    	if (futureOverNightStayEvent.length > 0)
    	{
			routeMarkers.push(techHomeMarkerDest);
		}
		else
		{
			routeMarkers.push(destTechHomeMarker);
		}
		}
		
    	
    	
    	//If source is null then set it. This will be null when most recent wo event is to be plotted for current day
    	if(source == null)
    	{
    		if(wayPoints.length > 0)
    		{
    			//Remove the first event location from wayPoints as that will be the source
	    		wayPoints.shift();
	    		//0th entry will be tech marker. So take the value at 1 as source
	    		source = routeMarkers[1];
    		}
    	}
		
    	if(!callLater)
    	{
    		plotRoute(rd, source, destination, wayPoints);
    		displayErrorInDC();
    	}
    	else
    	{
			(function(rd, source, destination, wayPoints){
	    		var callAfterLatLngLookup = function()
	    		{
	    			plotRoute(rd, source, destination, wayPoints);
	    			displayErrorInDC();
	    		};
	    		
	    		callBackStack.push({callBackFor : "drawTechnicianRoute", callBack : callAfterLatLngLookup});
			})(rd, source, destination, wayPoints);
    	}
    	
    	//Apply bounds only if techMarker has valid position
    	if(callLater == false)
    	{ 
    	  if(techHomeMarker.position != undefined)  	
    	 {
    		if(bounds.contains(techHomeMarker.position))
    		{    		
        		mapInstance.setCenter(bounds.getCenter());
    			//mapInstance.fitBounds(bounds);
    		}
    	  }
    	  
    	   if(techMarker.position != undefined)  	
    	 {
    		if(bounds.contains(techMarker.position))
    		{    		
        		mapInstance.setCenter(bounds.getCenter());
    			//mapInstance.fitBounds(bounds);
    		}
    	 }
    	}    	

    	updateToolbarWIthRouteInfo();
    }
	
    function plotRoute(rd, source/*Marker*/,destination/*Marker*/,wayPoints/*Array*/)
    {   
    	if(!source && !destination && !wayPoints)
    		return;
    	
    	var srcLocation = source.position ? source.position : source.address;
    	var destLocation = destination.position ? destination.position : destination.address;  
    	
    	//This for loop is added to fix issue #9773. Skip the waypoints not having the location
    	for(var i = 0;i < wayPoints.length;i++)
    	{
    		var pt = wayPoints[i];
    		
    		if(!pt.location)
    		{
    			wayPoints.splice(i,1);
    			i--;
    		}
    	}
    	
    	var request = {
			origin:srcLocation,
			destination:destLocation,
			travelMode: google.maps.TravelMode.DRIVING,
			waypoints: wayPoints
		};
		
		directionsService.route(request,function(result,status){		
			if(status == google.maps.DirectionsStatus.OK)
			{
				var route = result.routes[0];
				var legs = route.legs;
				var polylines = [];
				
				for (var i = 0; i < legs.length; i++)
				{
					var leg = legs[i];
					var steps = leg.steps;
					var polylineOptions = {};
					var color = "#24A2C1";
					
					//Destination, when plotting route is always tech marker
					if(destination.info)
						//color = "#" + getTechColorForRoute(destination.info.Id);						
						color = getTechColorForRoute(destination.info.Id);										
					
					//Generate random color
					polylineOptions.strokeColor = color;//"#24A2C1"; //+ Number((Math.random() * 0xFFFFFF).toFixed(0)).toString(16);
					polylineOptions.path = [];
					polylineOptions.strokeOpacity = 1.0;
    				polylineOptions.strokeWeight = 4;
					
					for (var j = 0; j < steps.length; j++)
					{
						var step = steps[j];
						
						var path = step.path;
						polylineOptions.path = polylineOptions.path.concat(path);
					}
					
					var polyline = createPolyline(polylineOptions);
					addPolyline(polyline);
					polylines.push(polyline);
				}
				
				rd.routePolylines = polylines;
				
				if(wayPoints.length > 0 || srcLocation != destLocation)
				{
					//Though we have suppressed markers and ploylines, this applies the bounds
					directionsDisplay.setDirections(result);
				}
				else//If there are no wayPoints, set the center to technician location
				{
					var bnds = route.bounds;
					//mapInstance.fitBounds(bnds);
					//mapInstance.setCenter(destLocation);
				}
			}
			else if(status == google.maps.DirectionsStatus.NOT_FOUND)
			{
				//At least one of the origin, destination, or waypoints could not be geocoded
				//Commented the following line as the error displayed when geocoding is overwritten by following error
				//displayErrorInDC("TAG366");
			}
			else if(status == google.maps.DirectionsStatus.ZERO_RESULTS)//On failure
			{
				//No route could be found between the origin and destination.
				displayErrorInDC("TAG367");
				mapInstance.setCenter(destLocation);
			}
			else if(status == google.maps.DirectionsStatus.UNKNOWN_ERROR)
			{
				//A directions request could not be processed due to a server error. The request may succeed if you try again
				displayErrorInDC("TAG368");
			}
			
			//Enable date navigation buttons only after all routes have been plotted. Fix for issue #10924
			plotRouteCounter--;
			routeActionMenuItemsEnabled(plotRouteCounter <= 0);
		});
    }
    
    function updateToolbarWIthRouteInfo()
    {
    	if(totalRoutesPlotted == 0)
    		return;
    	
		//TODO:
		var _routeData = lastPlottedRoute.routeData;
		
    	var techTxt = Ext.getCmp("techTxt");
    	
    	if(techTxt.isHidden())//If items are hidden, make them visible
    	{
    		routeActionMenuItemsVisible(true);
    	}
    	
    	techTxt.setText(defaultConfig.tags["TAG116"] + " " + _routeData.technician.Name);
    	//techTxt.setFieldLabel(defaultConfig.tags["TAG116"] + " " + _routeData.technician.Name);
    	
    	var tbDom = toolBar.getEl().dom;
    	
    	//Uncomment following two lines to display tech name in tooltip
    	Ext.tip.QuickTipManager.unregister("techTxt");
    	Ext.tip.QuickTipManager.register({target : "techTxt", text : _routeData.technician.Name});
    	
    	//Fix for issue #10494. If the name doesnot have space and has more than 15 chars then wrap
    	if(_routeData.technician.Name.search(" ") == -1 && _routeData.technician.Name.length > 15)
    		techTxt.getEl().dom.style.wordBreak = "break-all";
    	else
    		techTxt.getEl().dom.style.wordBreak = "initial";//reset the style
    	
    	//Feedback from Boniface - If text is long, then only display a scrollbar
    	//TODO : Optimize to auto-adjust the label width if there is ample space    	
    	if(tbDom.scrollWidth > tbDom.offsetWidth)//If there is h-scroll bar
    	{
    		techTxt.getEl().dom.style.width = "140px";
    		techTxt.getEl().dom.style.whiteSpace = "normal";
    		toolBar.doComponentLayout();
    	}
    	
    	//var currentDate = new Date(routeData.currentDateInMilliSeconds);
    	var dateTxt = Ext.getCmp("dateTxt");
    	
    	dateTxt.setMinValue(new Date(_routeData.ganttStartDateInMilliSeconds));
    	dateTxt.setMaxValue(new Date(_routeData.ganttEndDateInMilliSeconds));
    	
		//suppress events on set value
		suppressEventsDateField = true;
		
    	dateTxt.setValue(_routeData.currentDateInUserFormat);
		suppressEventsDateField = false;
    }
    
    function createMenuBar()
    {
    	if(toolBar)
    		return;
    		    		
    	var toolBarConfig = {
							border : "0",																																								
							items : [
								      {
									   xtype:"button",
            						   height:'30',
									   scope : this,
									   id:  'mapPin',
									   text :'Plot',
									   style:'color:#333333!important;background-color:transparent!important',
									   tooltip : defaultConfig.tags["TAG370"],
									   iconCls: Ext.baseCSSPrefix + 'tbar-page-prev1',
									   cls : 'my-btn',
									   handler : function(){DCViewsPanel.getInstance().toggle();}
								      },
								      {								       
								       text:'Search Radius',								      
								       height:30,
								       arrowCls: '',
								       //cls:'x-grey-btn',
								       style:'color:#333333!important;background-color:transparent!important',
								       cls:'my-btn',
								       //iconCls:'mySearchButtonClass',
								       //overCls:'mySearchButtonClass_over',  
    		  						   //icon:  window.getResourcePath() + "resources/themes/images/svmx-dc-map/custom/Radius-White.png",  // <-- icon    		  						  
    		  						   icon:  window.getResourcePath() + "resources/themes/images/svmx-dc-map/custom/Radius.png",  // <-- icon    		  						  
    		  						   handler: function() {
                                                //alert("The button was clicked");
                                                },
            						     menu: {
            						          scope : this,
            						          xtype:'menu',             						
            						          id:'RadiusMenuId', 
        							          plain:true,
        							          cls:'dispatch-map-search-radius-menu',     
        							          items: [
            							                 //these will render as dropdown menu items when the arrow is clicked:            							               
			             								{text: "5 "+defaultConfig.mapUnitText,value:5,handler: onItemClick},
			           									{text: "10 "+defaultConfig.mapUnitText,value:10,handler: onItemClick},
			            								{text: "15 "+defaultConfig.mapUnitText,value:15,handler: onItemClick},
			            								{text: "20 "+defaultConfig.mapUnitText,value:20,handler: onItemClick},
			            								{text: "25 "+defaultConfig.mapUnitText,value:25,handler: onItemClick},
			        								    {text: "30 "+defaultConfig.mapUnitText,value:30,handler: onItemClick},
			     								        {text: "40 "+defaultConfig.mapUnitText,value:40,handler: onItemClick},
			            								{text: "50 "+defaultConfig.mapUnitText,value:50,handler: onItemClick},
            								            {text: 'Enter Value',hideOnClick: false,menu: 
            								                 { 
            								                    plain:true,
            								                    cls:'my-menu',                   								                    
					                  							items: [
					                  							        { text: 'Search Radius',disabled: 'true',style : {color:'#333333!important'}},	
					                  							        { xtype: 'container',layout: 'hbox',
					                  							          items: [
					                  							                   {xtype: 'textfield',id:'entervalue1',maskRe : /[0-9]/,maxLength : 4,enforceMaxLength : true,width:90,height:25,fieldStyle:"text-align:right;"},
					                  							                   {xtype: 'button',text: 'OK',width:50,height:25,margin: '0 2 5 8',cls:'x-grey-btn',listeners:{click: function(){OnSearchRadiusEnter();}}}
					                  							                 ]}
					                  							        ]
               					                              }
          					                             },
          					                             {text: 'No Limit',value:0,handler: onItemClick}
					            					     ], 
					            					    // listeners: { click:ploteRadiusOnMap }
        							}
        						}																
							]
						};
    										
    	//Whether its inline or stand alone map, the name for the panel in which map is rendered is same
		var mapContainer = Ext.getCmp("mapContainer");
		//mapContainer.body.setStyle('background','none');	
		
		//Ext.getCmp('entervalue1').setValue(defaultConfig.defaultRadius);
		if(circle_radius==0)
		{
		circle_radius=defaultConfig.defaultRadius;
		}
				
    	if(!dcWindow)//for inline map
    	{
    		toolBarConfig.overflowX = "auto",    		
    		toolBar = Ext.create("Ext.toolbar.Toolbar",toolBarConfig);
    	}
    	else//for stand alone map
    	{
	    	toolBar = Ext.create("Ext.toolbar.Toolbar",toolBarConfig);
    	}
    	    	
    	mapContainer.add(toolBar);   
    	   	
   		mapContainer.move(1,0);//Render at the top
   		
   			   	
    	if(!routeActionMenuItems)
    		routeActionMenuItems = [];
    	
    	//Add a separator
    	/*routeActionMenuItems.push(toolBar.add({
    		xtype : "tbseparator",
    		hidden : true
    	}));*/
    	
    	routeActionMenuItems.push(toolBar.add({
    		xtype: 'label',
            text: 'Show',
            id:'showlabelid',
            hidden : true
    	}));  	
    	
    	config = {
		        	xtype : "radiogroup",//label to display current day for which route is displayed
		        	hidden : true,
		        	id:'radiobutton',
		        	width: 250,
		        	 items: [		        	                             
                            {
                                xtype: 'radiofield',
                                boxLabel: defaultConfig.tags["TAG471"],
                                name: 'framework',
                                id:'current_loc',
                                checked: defaultConfig.locationBase == "current"?true:false,
                                inputValue: defaultConfig.tags["TAG471"],
                            
                            },
                             {
                                xtype: 'radiofield',
                                boxLabel: defaultConfig.tags["TAG470"],
                                name: 'framework',
                                id:'home_loc',
                                checked: defaultConfig.locationBase == "home"?true:false,
                                inputValue: defaultConfig.tags["TAG470"],
                             
                            },
                            {
                                xtype: 'radiofield',
                                boxLabel:defaultConfig.tags["TAG472"],
                                name: 'framework',
                                id:'both_loc',
                                checked: defaultConfig.locationBase == "both"?true:false,
                                inputValue:defaultConfig.tags["TAG472"],
                               
                            }
                        ],
                        
                        listeners: {
                        change: function(radiogroup, radio) {
                        	
                        if(radio.inputValue==defaultConfig.tags["TAG470"]){
                        	Ext.getCmp("home_loc").checked = true;
							Ext.getCmp("current_loc").checked = false;
							Ext.getCmp("both_loc").checked = false;
                        }
                        else if (radio.inputValue==defaultConfig.tags["TAG471"]){
                        	Ext.getCmp("home_loc").checked = false;
							Ext.getCmp("current_loc").checked = true;
							Ext.getCmp("both_loc").checked = false;
                        }
                         else if(radio.inputValue==defaultConfig.tags["TAG472"]){
                        	Ext.getCmp("home_loc").checked = false;
							Ext.getCmp("current_loc").checked = false;
							Ext.getCmp("both_loc").checked = true;
                        }
                          drawTechnicianRoute(tempTechData);
			              drawSearchedTechnicians(tempTechList,tempSelectedWO);
			              //config.mapPlotPreference = "Both";
			              locationBaseRadioClick();
                        }
                        }
                        
		       };
    	routeActionMenuItems.push(toolBar.add(config));
    	console.log(config)
    	
    	//radius =Ext.getCmp("RadiusMenuId")
    	
    	var config = {
			    		xtype : "tbtext",//Label to display tech name when plotting route
			        	id : "techTxt",
			        	text : "",
			        	margin : "0 3 0 2",
			        	hidden : true,
			        	maxHeight : 33//Fix for issue #9185. Fix the max height
			     };
			      /*{
			       		xtype : "displayfield",//Label to display tech name when plotting route
			        	id : "techTxt",
			        	value : "",
			        	//margin : "0 3 0 2",
			        	hidden : true,
			        	labelSeparator : "",
			        	labelWidth : 120
			       };*/
					        
    	routeActionMenuItems.push(toolBar.add(config));
    	
    	routeActionMenuItems.push(toolBar.add({
    		xtype : "tbseparator",
    		hidden : true
    	}));
    	
    	config = {
		        	scope : this,//Default control thats added to toolbar is button. This button is used to navigate to previous day
		            iconCls: Ext.baseCSSPrefix + 'tbar-page-prev',
		            handler : function(){drawRouteForDay(Literals.PREVIOUS);},
		            hidden : true
		       };
		
		routeActionMenuItems.push(toolBar.add(config));
		
		config = {
		        	xtype : "datefield",//label to display current day for which route is displayed
		        	id : "dateTxt",
		        	text : "",
		        	width : 104,
		        	format : dateFormatMap[defaultConfig.userDateFormat],//"d/m/Y",
		        	showIcon: false,
		        	fieldStyle : {fontSize : "16px",fontFamily:"OpenSans"},
		        	listeners : {change : onRouteDateChange},
		        	hidden : true,
		        	invalidText : defaultConfig.tags["TAG372"] + " {0} " + defaultConfig.tags["TAG373"] + " " + defaultConfig.userDateFormat
		       };
				      
		routeActionMenuItems.push(toolBar.add(config));
		
		config = {
		        	scope : this,//Button to navigate to next day
		            iconCls: Ext.baseCSSPrefix + 'tbar-page-next',
		            handler : function(){drawRouteForDay(Literals.NEXT);},
		            hidden : true
		       };
				      
		routeActionMenuItems.push(toolBar.add(config));
		
		routeActionMenuItems.push(toolBar.add({
    		xtype : "tbseparator",
    		hidden : true
    	}));    
    	
    	toolBar.add("->");//Add this to place button at right
			//Add popout button for inline map
			
    		toolBar.add(
    		            {
									xtype:"button",
            						height:'30',
									scope : this,
									id:  'mapRefresh',
									tooltip : defaultConfig.tags["TAG333"],//Clear Map
									handler : clearMapBtnClick,
									//iconCls : 'map-refresh', ui: 'icon-btn'
									style:'color:#333333!important;background-color:transparent!important',
									iconCls: Ext.baseCSSPrefix + 'tbar-page-prev2',
									cls : 'my-btn',
									text:'Reset'
								      });			
    			
		if(!dcWindow)
		{
			//toolBar.add("->");//Add this to place button at right
			//Add popout button for inline map
			
    		toolBar.add(    		            
    		            {
							scope : this,
							id:  'mapPopOut',
							tooltip : defaultConfig.tags["TAG475"],//Popout map
							handler : popoutMap,
							iconCls : 'map-popout', ui: 'icon-btn'
						});
		}	
		
    }
    
   function onItemClick(item){  
    
     if(item.value!=0)
	     {
	         circle_radius=item.value;  
	         radius_mode=true;	
		     drawRadiusForSearch(circle_radius);
	     }
	     else
	     {	         
		     if(searchTechData)
		     { 
		       radius_mode=false;
		       radiusModeNoLimitHandler();		      
		     }		    
	     } 
    }
    
     function radiusModeNoLimitHandler()
    { 
    	clearRadiusModeCircle(false);
    	if(searchTechMarkers)
	    	{
	    		searchTechMarkers.foreach(function(item){
	    			if(item.type != Literals.WORKORDER)
	    				item.setMap(mapInstance);
	    		});
	    }
    }
    
    function OnSearchRadiusEnter()
    {      
       var Entervalue=Ext.getCmp('entervalue1');
       if(Entervalue.getValue()!="")
       {
       var enterRadiusValue=Entervalue.getValue();
       if(enterRadiusValue>2000)
       {
       circle_radius=2000;
       }
       else
       {
       circle_radius=Entervalue.getValue();
       }
       Entervalue.setValue(''); 
       //var button= Ext.getCmp('PlotButtonId');   
	   //button.fireHandler(); 
	   drawRadiusForSearch(circle_radius); 
       }  
       var menu=Ext.getCmp('RadiusMenuId');        
       menu.hide();
       
       // circle_radius = Ext.getCmp('entervalue1').getValue(); Ext.getCmp('entervalue1').setValue('');Ext.getCmp('Menuid').hide();  
    }
    
    function onRouteDateChange(dateField,newValue,oldValue)
    {
    	if(!dateField.isValid() || suppressEventsDateField)
    		return;
    	
    	//console.log("newValue -> " + newValue.toString() +" "+ "oldValue -> "+ oldValue.toString());
    	if(!Ext.isDate(newValue))
    		return;
    	
		var rd = lastPlottedRoute;
    	var currentDay = new Date(rd.currentDateInMilliSeconds);
    	
    	//Change event is fired initially when the datefield is made visible after plotting the route. No action if the route is already plotted for selected date
    	if(currentDay.toDateString() == newValue.toDateString())
    		return;
    		
    	drawRouteForSelectedDate(newValue);
    }
    
    function createRadiusActionBar()
    {
    	if(radiusActionBar)
    		return;
    		
    	var toolBarConfig = {
							hidden : true,
							border : "1 0 1 0",
							height : 30,
						    items: [
						        {
						        	xtype: 'checkboxfield',
						            id: 'radiusChk',
						            boxLabel: defaultConfig.tags["TAG316"],//Radius mode
						            boxLabelCls : "x-toolbar-text",//To render text same as toolbar text
						            fieldBodyCls : "",//Done to center align
						            checked : true,
						            margin : "0 0 0 4",
						            handler : function(chkBox){radiusModeChkBoxHandler(chkBox);}
						        },
						        {
						        	xtype : "tbtext",
						        	id : "radiusTxt",
						        	text : defaultConfig.tags["TAG017"] //Radius
						        },
						        /*{
						        	xtype : "numberfield",
						        	id : "radiusComp",
						        	value: defaultConfig.defaultRadius,
								    minValue: 1,
								    maxValue: 50,
								    width : 60,
								    listeners : {change : function(stepper,value){radiusModeStepperHandler(stepper,value);}}
						        },*/
						        {
						        	id : "radiusComp",
						        	xtype : "combo",
						        	queryMode: 'local',
						        	store : new Ext.data.Store({
						        			fields : ["value"],
									        data: [{value:25},{value:50},{value:75},{value:100}]  // data is local
									    }),
									valueField: 'value',
    								displayField: 'value',
    								width : 60,
    								maskRe : /[0-9]/,
    								value: defaultConfig.defaultRadius,
    								listConfig : {minWidth : 50,style : {marginLeft:"0px"}},
    								listeners : {/*select : function(comp,value){radiusModeStepperHandler(comp,value);},*/
    								         change : function(comp,value){radiusModeStepperHandler(comp,value);},
    								         expand : function(comp){radiusComboExpandHandler(comp);}}
						        },
						        {
						        	xtype : "tbtext",
						        	id : "unitTxt",
						        	text : defaultConfig.mapUnitText //miles/km
						        }
						    ]
				        };
		
		//Whether its inline or stand alone map, the name for the panel in which map is rendered is same
		var mapContainer = Ext.getCmp("mapContainer");
		
    	if(!dcWindow)//for inline map
    	{
    		radiusActionBar = Ext.create("Ext.toolbar.Toolbar",toolBarConfig);
    		mapContainer.add(radiusActionBar);
    	
	    	mapContainer.move(2,1);//Render at the top
	    	
	    	radiusActionMenuItems = radiusActionBar.items.items;
    	}
    	else//for stand alone map use same toolBar
    	{
	    	//radiusActionBar = Ext.create("Ext.toolbar.Toolbar",toolBarConfig);
    		
    		if(!radiusActionMenuItems)
    			radiusActionMenuItems = [];
    		
    		//Add a separator
	    	radiusActionMenuItems.push(toolBar.add({
	    		xtype : "tbseparator",
	    		hidden : true
	    	}));
	    	
    		toolBarConfig.items.foreach(function(item)
    		{
    			item.hidden = true;
    			radiusActionMenuItems.push(toolBar.add(item));
    		});
    	}
    }
    
    function radiusModeControlsVisible(visible/*Boolean*/)
    {
    	if(visible == true || visible == false)
    	{
    		if(!dcWindow)//Inline map
    		{
    			//radiusActionBar.setVisible(visible);
    		}
    		else
    		{
    			radiusActionMenuItems.foreach(function(item)
    			{
    				//item.setVisible(visible);
    			});
    		}
    		
    		if(visible == true)
    		{
    			//var checkBox = Ext.getCmp("radiusChk");//If checkbox is not selected, toggle
    			//checkBox.setValue(true);
    			
    			routeActionMenuItems.foreach(function(item)
    	        {
	    	        if(item.id=="radiobutton"||item.id=="showlabelid")
	    	        {
	    		     item.setVisible(visible);
	    		    }
    	        });
    		}
    	}
    }
    
    function radiusModeChkBoxHandler(chkBox/*reference to Checkbox*/)
    {
    	if(!radiusActionMenuItems || !chkBox)
    		return;
    	
    	radiusActionMenuItems.forEach(function(item)
    	{
    		if(item.xtype != "checkboxfield")
    		{
    			item.setVisible(chkBox.checked);
    		}
    	});
    	
    	if(chkBox.checked == false)
    	{
    		clearRadiusModeCircle(false);
    		
    		if(searchTechMarkers)
	    	{
	    		searchTechMarkers.foreach(function(item){
	    			if(item.type != Literals.WORKORDER)
	    				item.setMap(mapInstance);
	    		});
	    	}
    	}
    	else
    	{
    		var stepper = Ext.getCmp("radiusComp");
    		
    		if(stepper)
    			drawRadiusForSearch(stepper.getValue());
    	}
    }
    
    function radiusModeStepperHandler(comp/*reference to Combobox*/,value/*num/string*/)
    {
    	if(!comp)
    		return;
    	
    	if((comp.value && isNaN(comp.value)) || (value && isNaN(value)))
    	{
    		comp.markInvalid("Please enter a valid number");
    		return;
    	}
    	else
    	{
    		comp.clearInvalid();
    	}
    	
    	var radius = parseInt(comp.value);
    	
    	if(isNaN(radius))
    	{
    		radius = parseInt(value);
    	}
    	
    	if(!isNaN(radius))
    	{
    		if(radius <= 2000)
    			drawRadiusForSearch(radius);
    		else
    		{
    			//Fix for issue #10987 and related issue 11495
    			comp.setValue(2000);
    			
    			drawRadiusForSearch(2000);
    		}
    	}
    }
    
    function drawRadiusForSearch(radius/*int*/)
    {    
    	//if(parseInt(radius) === NaN || !searchTechData)
    		//return;    	  
    	 	
    	if(!searchTechData)
    		return;	
    	
    	var wo = searchTechData.selectedWO;
    	
    	clearRadiusModeCircle();
    	
    	var markers = searchTechMarkers;
    	
    	if(markers)
    	{
    		markers.foreach(function(item){
    			if(item.type != Literals.WORKORDER)
    				item.setMap(null);
    		});
    	}
    	
    	// convert to km if in miles
		//if(defaultConfig.mapUnit == "miles"){
		//	radius = radius * 1.60934;	
		//}
		
		//Convert to meters as radius in map is in meters.
		//radius = radius * 1.0 * 1000;
			
		var circleConfig = { strokeColor: '#6EA6E5', strokeOpacity: 0.5, strokeWeight: 2,
			fillColor: '#6EA6E5', fillOpacity: 0.15, map: mapInstance,
			center: new google.maps.LatLng(wo.lat,wo.lng), radius: radius
		};
		var current_radius;
		if(plot_mode)
		{	
		current_radius=radius;	
		}
		else
		{
		current_radius=circle_radius;
		}
		
		var ll = new google.maps.LatLng(wo.lat,wo.lng);
		//radiusModeCircle = new google.maps.Circle(circleConfig);		
		radiusModeCircle= new CustomCircleOverlay(mapInstance, ll, current_radius,defaultConfig.mapUnitText,"mile","#6EA6E5", 1, 1, '#6EA6E5', 0.35);	
		
		if(defaultConfig.mapUnit == "miles"){
			radius = radius * 1.60934;	
		}
		
		//Convert to meters as radius in map is in meters.
		radius = radius * 1.0 * 1000;
		if(markers)
    	{
    		markers.foreach(function(item)
    		{
    			if(item.type != Literals.WORKORDER && isInRange(item,wo,radius))
    				item.setMap(mapInstance);
    		});
    	}
    }
    
    function isInRange(marker,wo,radius/*in meters*/)
    {    
        if(!marker || !wo)
            return;
            
        var markerLatlng = marker.getPosition();
        var woLatlng = new google.maps.LatLng(wo.lat,wo.lng);
        
        //distance in meters
        // fix for defect 037569
        if (typeof(markerLatlng) != "undefined")
        {
            var distance = google.maps.geometry.spherical.computeDistanceBetween(markerLatlng,woLatlng);
        }
        
        return distance <= radius;
    }
    
    function radiusComboExpandHandler(comp)
    {
    	if(!comp)
    		return;
    		
    	if(!comp.isValid())
    	{
    		comp.collapse();
    		return false;
    	}
    }
    
    function lookupLatLng(marker)
    {
    	if(!geocoder)
    		geocoder = new google.maps.Geocoder();
    		
    	var request = {
    		address : marker.address
    	};
    	
    	geocoder.geocode(request, function(results,status)
    	{
    		if(status == google.maps.GeocoderStatus.OK)
    		{
    			var location = results[0].geometry.location;
    			marker.position = location;
    			
    			//Store the lat lng info in Object because passing back info to dcWindow will be straight forward than passing complex objects 
    			latLngMap[marker.info.Id] = {lat : location.lat(), lng : location.lng()};
    			
    			//Populate in respective details object as well
    			marker.info.lat = location.lat();
    			marker.info.lng = location.lng();
    			
    			//if this marker is a way point, then update the way point info
    			//wayPoint is set in drawTechnicianRoute()
    			if(marker.wayPoint)
    				marker.wayPoint.location = location;
    			
    			latLngLookupCounter--;
    			
    			addToMapAfterLatLngLookup(marker);
    		}
    		//indicates that the geocode was successful but returned no results. This may occur if the geocoder was passed a non-existent address
    		else if(status == google.maps.GeocoderStatus.ZERO_RESULTS)
    		{
    			latLngLookupCounter--;
    			
    			if(marker.info.WOId)//If when resolving address for a WO related event (when plotting route), also send Id to DC for the user to open the WO
    				invalidMarkers.push({Name:marker.Name,type:marker.type,Id:marker.info.WOId});
    			else
    				invalidMarkers.push({Name:marker.Name,type:marker.type});
    		}
    		//indicates that you are over your quota
    		else if(status == google.maps.GeocoderStatus.OVER_QUERY_LIMIT)
			{
				latLngLookupCounter--;
				console.log("You are over your quota");
				displayErrorInDC("Too many Google Geocoding API requests per second");
			}
    		//indicates that your request was denied, generally because of lack of a sensor parameter
    		else if(status == google.maps.GeocoderStatus.REQUEST_DENIED)
			{
				latLngLookupCounter--;
				console.log("Request denied due to lack of a sensor parameter");
			}
    		else if(status == google.maps.GeocoderStatus.UNKNOWN_ERROR)
			{
				latLngLookupCounter--;
				//A request could not be processed due to a server error. The request may succeed if you try again
				console.log("A request could not be processed due to a server error. The request may succeed if you try again");
			}
    		
    		if(latLngLookupCounter == 0)
			{
				//The stack was introduced to fix issue #9995. This issue occurs when plotting route and search results in succession
				//when the map is switched form inline to popup and vice-versa. This issue occurred because callAfterLatLngLookup was
				//not executed if value of latLngLookupCounter was not zero due to operations performed in succession
				if(callBackStack && callBackStack.length > 0)
				{
					while(callBackStack.length != 0)
					{
						var callBackInfo = callBackStack.pop();
						callBackInfo.callBack();
					}
				}
			}
    	});
    	
    	latLngLookupCounter++;
    }
    
    function addToMapAfterLatLngLookup(marker/*Marker*/)
    {
    	if(marker && marker.position)
    	{
    		marker.setMap(mapInstance);
    		
    		if(bounds)
    		{
	    		bounds.extend(marker.position);
	        	mapInstance.setCenter(bounds.getCenter());
    		}
    	}
    }
    
    /**
     * Handles the logic to plot events for 3 use cases:
     * 1) When the selected/current Date is not today
     * 2) When the selected/current Date is not today but the current Date and current time marker are the same day
     * 3) When the selected/current Date is today (same as current marker)
     */
    function isCurrentDateEvent(evt/*Obj with event details*/,currentDate/*Date*/,currentTimeMarker/*Date*/,viewAllEventsForToday/*boolean*/)
    {
    	var result = true;
    	
    	if(!evt && !currentDate)
    		return result;
    		
    	var evtStartDate = new Date(evt.startTime.time);
    	var evtEndDate = new Date(evt.endTime.time);
    	
    	//compare the day first.
    	if(evtStartDate.toDateString() != currentDate.toDateString())
    	{
    		//result = false;//Commented this as it was skipping an event in progress i.e event spanning yesterday, today and tomorrow
    	}
    	
    	//Dont plot the event if its today and event is before current time marker and the UI setting viewAllEventsForToday is false
    	if(isDateToday(currentDate) && evtEndDate.getTime() < currentTimeMarker.getTime() && viewAllEventsForToday == false)
    		result = false;
    	//Dont plot if the current day is not today (but the currentDate and currentTimeMarker are same day) and
    	//event falls behind the currentTimeMarker
    	else if(!isDateToday(currentDate) && currentDate.toDateString() == currentTimeMarker.toDateString() &&
    				evtEndDate.getTime() < currentTimeMarker.getTime() && viewAllEventsForToday == false)
    		result = false;
    	
    	//if the event started yesterday or before and is ongoing, consider it for plotting if the current date is not today.
    	if(!isDateToday(currentDate) && evtStartDate.toDateString() != currentDate.toDateString() && (evtEndDate.toDateString() == currentDate.toDateString() || 
    	   evtEndDate.getTime() > currentDate.getTime()))
    		result = true;
    		
    	return result;
    }   

		function is_image_valid(src) {
		// Create new offscreen image to test
		var image_new = new Image();
		image_new.src = src;		
		// Get accurate measurements from that.
		if ((image_new.width>0)&&(image_new.height>0)){
		    return true;
		} else {
		    return false;
		}
		}
    
    //Here the scope is respective marker. So this keyword refers to marker instance
    function showInfo()
    {
    	//If already open for this marker then return
    	if(infoWindow && infoWindow.anchor === this)
    		return;
    	
    	var hoverInfo = this.info.hoverInfo;//Be it team, tech or WO marker, this property will be there   
    	
    	var validImage=false; 	
    	
    	
    	if(!hoverInfo)
    		hoverInfo = this.address; 
    		
    	if (this.type==='Overnight')
    	{
    	if (this.address === undefined)
    	{
    	hoverInfo = this.subject
    	
    	}
    	else
    	{
    	hoverInfo = this.subject+' , '+this.address;
    	}
    	} 
    		
        var firstName=this.FirstName;
    	var lastName=this.LastName;  
    	var smallPhotoUrl=this.SmallPhotoUrl;
    	var initial=this.initial; 
    	var imagestring;
    	if(smallPhotoUrl)
    	{    	 	
    	validImage=is_image_valid(smallPhotoUrl);    	
	    if(validImage)
	    {    
    	imagestring='<img src='+smallPhotoUrl+' alt='+initial+' class="circular-image" style="vertical-align:middle">';    	
    	}
    	else
    	{
    	smallPhotoUrl=window.getResourcePath() + "resources/themes/images/svmx-dc-map/custom/Technician25.png";    	
    	imagestring='<img src='+smallPhotoUrl+' alt='+initial+' class="circular-image" style="vertical-align:middle">';
    	}
    	}
    	else
    	{
    	smallPhotoUrl=window.getResourcePath() + "resources/themes/images/svmx-dc-map/custom/Technician25.png";
    	imagestring='<img src='+smallPhotoUrl+' alt='+initial+' class="circular-image" style="vertical-align:middle">';
    	} 
    	
    	var type=this.type;    	
    	if(type=="WO"||type=="Team" || this.type==='Overnight')
    	{
    	imagestring="";   	
    	}    	
    	if (this.type==='Overnight')
    	{
    	this.Name = 'Overnight Stay Event';
    	}
    
    	var infoIconUrl = window.getResourcePath() + "resources/themes/images/svmx-dc-map/custom/info_icon.png";
    	
    		
    	
    	//If WOId is there then use it to open workorder else open the respective team or technician record
    	var recordId = this.info.WOId ? this.info.WOId : this.info.Id;
    	var callBack = "openRecord('" + recordId +"')";
    	//to break down a really long word, styles were added to <p> tag to avoid text getting clipped
    	//Fix for issue #9976
    	var contentString;
    		if (this.type==='Overnight')
    	{
    	
    	 contentString = '<div id="content" style="width:230px;line-height:1.35;overflow:hidden;text-align:left;margin:0px;">' +
    	                                    imagestring +
	 										'<b>' + this.Name + '</b><p style="word-break: break-all;margin-right:17px">' + /*this.address*/hoverInfo +
	 								   		'</p>' +
	 								   		
	 									'</div>';	
	 	} 	
	 		else
	 		{
	 		 contentString = '<div id="content" style="width:230px;line-height:1.35;overflow:hidden;text-align:left;margin:0px;">' +
    	                                    imagestring +
	 										'<b>' + this.Name + '</b><p style="word-break: break-all;margin-right:17px">' + /*this.address*/hoverInfo +
	 								   		'</p>' +
	 								   		'<img src="'+infoIconUrl+
	 								   			   '" style="position:absolute;top:0px;right:22px;height:15px;width:15px;cursor:pointer' +
	 								   			   '" onclick="' + callBack +
	 								   			   '"/>' +
	 									'</div>';	
	 		}								
	 									
		//var boxText = document.createElement("div");
		//boxText.style.cssText = "border: 1px solid white; margin-top: 0px; margin-left: 6px; background: white; padding: 5px;";
		//boxText.innerHTML =contentString;

		/*var myOptions = {
			 content: boxText
			,disableAutoPan: false
			,maxWidth: 0
			,pixelOffset: new google.maps.Size(10,-45)
			,zIndex: null
			,boxStyle: { 
			  background:"url('http://www.geocodezip.com/images/tipbox90pad.gif') no-repeat"
			  ,opacity: 1
			  ,width: "150px",              			  
			 }
			,closeBoxMargin: "2px 2px 2px 2px"
			,closeBoxURL: "http://www.google.com/intl/en_us/mapfiles/close.gif"
			,infoBoxClearance: new google.maps.Size(1, 1)
			,isHidden: false
			,pane: "floatPane"
			,enableEventPropagation: false
		};*/
	 	
	 	if(!infoWindow)
	 	{
		 	infoWindow = new google.maps.InfoWindow({
			      pixelOffset : new google.maps.Size(0,-15)
			 });
			// infoWindow = new InfoBox(myOptions);
	 	}
		
	 	infoWindow.open(mapInstance,this);
 		infoWindow.setContent(contentString);
		
		google.maps.event.addListener(infoWindow, 'closeclick', function(){
			infoWindow.setContent("");// = null;
			infoWindow.close();
		});
    }
    
    function isDateToday(date)
    {
    	return date.toDateString() == new Date().toDateString();
    }
    
	function resetMapToDefaultConfig()
	{
		if(mapInstance)
		{
			clearMap();
			
			//Clear any garbage values used when switching context between inline and popup view of map
			selectedMapTypeId = null;
			zoomLevel = null;
			radius_mode=true;
			loadDefaultMapConfig();
			
			bounds = null;
		}
	}
	
	/**
	 * This function returns the current state of the map (i.e. what all is plotted on map)
	 * return - {routeData,searchData}
	 */
	function getCurrentContext()
	{
		if(!mapInstance)
			return null;
			
		var context = new Object();
		context.selectedMapTypeId = mapInstance.getMapTypeId();
		context.zoomLevel = mapInstance.getZoom();			
		context.routeData = {};
		
		for (var i in routeData) {
			var rd = routeData[i];
			//Just serialize routeData. Serialization of routePloylines results in recursion when using JSON.encode().
			//This happens as google uses circular referencing (object having reference to itself)
			context.routeData[i] = {routeData : rd.routeData};
		}
		
		context.totalRoutesPlotted = totalRoutesPlotted;
		
		if(lastPlottedRoute)
		{
			context.lastPlottedRoute = {};
			context.lastPlottedRoute.routeData = lastPlottedRoute.routeData;
		}
		
		context.searchTeamData = searchTeamData;
		context.searchTechData = searchTechData;
		context.techColorMap = techColorMap;		
		context.latLngMap = latLngMap;
		context.showTrafficOverlay = false;		
		if(searchTechData)
		{
			//var radiusChk = Ext.getCmp("radiusChk");
			
			//if(radiusChk)
			//{
				//context.isRadiusModeOn = radiusChk.getValue();
				////alert("radius_mode:"+radius_mode);
				context.isRadiusModeOn = radius_mode;
				context.selectedRadius = circle_radius;
				//context.selectedRadius = defaultConfig.defaultRadius;
					
				
				//if(!isNaN(circle_radius))
				//	context.selectedRadius = circle_radius;
				
				//var radiusComp = Ext.getCmp("radiusComp");
				//var radius = parseInt(radiusComp.getValue());
				//if(!isNaN(radius))
					//context.selectedRadius = radius;
			//}
		}
		
		//Plot nearby
		context.plotnearby = {};
		context.plotnearby.active = dcViews.getUI().isVisible();
		context.plotnearby.radiusValue = dcViews.getRadiusValue();
		context.plotnearby.recCountValue = dcViews.getRecCountValue();
		
		var selectedViews = dcViews.selectedViews();
		
		if(selectedViews.length > 0)
		{
			context.plotnearby.selectedViews = selectedViews;
		}
		
		if(plotNearByLatLng)
		{
			context.plotnearby.plotNearByLatLng = {lat : plotNearByLatLng.lat(), lng : plotNearByLatLng.lng()};
		}
		
		context.plotnearby.plotViews = false;
		
		if(plotCircle)//If plot circle is drawn it means selected views are plotted
		{
			context.plotnearby.plotViews = true;
		}
		
		if(trafficLayer && trafficLayer.getMap() != null)
			context.showTrafficOverlay = true;
		
		context.selectedLocationBase = getSelectedLocationBase();	
		
		context.isTabModeIndex = getSelectedTab();	
			
		return context;
	}
	
	/**
	 * This function loads and applies the context from popup map
	 * context - {routeData,searchData}
	 */
	function loadContextFromPopupMap(context)
	{
		if(!context)
			return;
		
		if(context.selectedMapTypeId)
			selectedMapTypeId = context.selectedMapTypeId;
			        
		if(context.zoomLevel)
			zoomLevel = context.zoomLevel;
						
		if(!zoomLevel)
	           zoomLevel = 	0;
		
		if(context.routeData)
        {
        	//Before overwriting the existing data, clear it from map as well as we wont have references to clear them afterwards
        	//Use case : If route is plotted in inline map and then the context is switched to popup map, then the markers in inline map
        	//will remain as they are. After closing the popup map, the data from there is used to plot route in inline map. Now we need to
        	//clear whatever data was there on map before the popup map was opened
        	clearRoute();
        	routeData = context.routeData;
        }
        
        totalRoutesPlotted = context.totalRoutesPlotted;
        
        if(context.lastPlottedRoute)
        	lastPlottedRoute = context.lastPlottedRoute;
        
        if(context.searchData)
        	searchData = context.searchData;
        
        if(context.searchTeamData)
        	searchTeamData = context.searchTeamData;
        
        if(context.searchTechData)
        	searchTechData = context.searchTechData;
        
        if(context.techColorMap)
        	techColorMap = context.techColorMap;
        
        if(context.latLngMap)
        	latLngMap = context.latLngMap;
        	
        if(trafficLayer)
        {
	        if(context.showTrafficOverlay == true && trafficLayer.getMap() == null)
	        {
	        	setTrafficLayerVisibility.call(trafficLayerDiv);
	        }
	        else if(context.showTrafficOverlay == false)
	        {
	        	hideTrafficLayer();
	        }
        }
        
        if(context.selectedLocationBase)
        {   
        	var radioComp = Ext.getCmp(context.selectedLocationBase);
        	radioComp.setValue(true);        	
        }
        
        	
        
        loadDCContext(context);
	}
	
	/**
     * Plot the search results for team search
     * teams - array of teams
     * selectedWO - workorder details if search is performed for a selected workorder
     */
	function drawSearchedTeams(teams/*Array*/,selectedWO/*workorder details*/)
	{
		//Fix for issue #10674. Allow the wo to be plotted if no team found
		if((!teams || !teams.length) && !selectedWO)
			return;
		
		var callLater = false,added = true;
		
		clearSearchTeamMarkers();
		
		searchTeamData = {teams : teams, selectedWO : selectedWO};
		
		if(!searchTeamMarkers)
			searchTeamMarkers = [];
		
		if(selectedWO)
		{		    
	    	woMarker = createMarkerFrom(selectedWO,false,Literals.WORKORDER);
	    	woMarker.info = selectedWO;
	    	
	    	added = addMarker(woMarker);
	    	
	    	if(!added)
	    		callLater = true;
	    		
	    	google.maps.event.addListener(woMarker, 'mouseover', showInfo);
	    	
	    	searchTeamMarkers.push(woMarker);
		}
			
		for (var i = 0; i < teams.length; i++)
		{
			var team = teams[i];
			
	    	teamMarker = createMarkerFrom(team,false,Literals.TEAM);
	    	teamMarker.info = team;
	    	
	    	added = addMarker(teamMarker);
		    	
	    	if(!added)
	    		callLater = true;
		    		
	    	google.maps.event.addListener(teamMarker, 'mouseover', showInfo);
	    	
	    	//Persist the markers
	    	searchTeamMarkers.push(teamMarker);
		}
		
		var firstTeam = null;
		
		if(!callLater)
		{
			firstTeam = getFirstMarkerWithValidLatLng(searchTeamMarkers);
			
			if(firstTeam)//Pan to first team having valid lat lng
				mapInstance.panTo(firstTeam.position);
				
			displayErrorInDC();
		}
		else
		{
			var callAfterLatLngLookup = function()
			{
				firstTeam = getFirstMarkerWithValidLatLng(searchTeamMarkers);
			
				if(firstTeam)//Pan to first team having valid lat lng
					mapInstance.panTo(firstTeam.position);
				
				displayErrorInDC();
			};
			
			callBackStack.push({callBackFor : "drawSearchedTeams", callBack : callAfterLatLngLookup});
		}
	}
	
	/**
     * Plot the search results for technician search
     * technicians - array of technicians
     * selectedWO - workorder details if search is performed for a selected workorder
     */
	function drawSearchedTechnicians(technicians/*Array*/,selectedWO/*workorder details*/)
	{		    
		//Fix for issue #10674. Allow the wo to be plotted if no technician found
		if((!technicians || !technicians.length) && !selectedWO)
			return;		
		
		plot_mode=false;
		//if(!tempTechList && !tempSelectedWO){
	    tempTechList = technicians;
	    tempSelectedWO = selectedWO;

	    locationBaseBarVisible(true);
	    //var centerPlotControlDiv = document.createElement('div');
 		//var myPlotCustomControl = CustomPlotControl(centerPlotControlDiv, mapInstance);

  		//centerPlotControlDiv.index = 1;
 		//mapInstance.controls[google.maps.ControlPosition.TOP_LEFT].push(centerPlotControlDiv);
	    //}
		
		var lat,lng,position,techMarker,techHomeMarker,woMarker;
		var callLater = false,added = true;
				
		clearSearchTechMarkers();
			
		searchTechData = {technicians : technicians, selectedWO : selectedWO};
				
		if(!searchTechMarkers)
			searchTechMarkers = [];
		
		if(selectedWO)
		{		    
	    	woMarker = createMarkerFrom(selectedWO,false,Literals.WORKORDER);
	    	woMarker.info = selectedWO;
	    	
	    	added = addMarker(woMarker);
	    	
	    	if(!added)
	    		callLater = true;
	    		
	    	google.maps.event.addListener(woMarker, 'mouseover', showInfo);
	    	
	    	searchTechMarkers.push(woMarker);
		}	
					
		for (var i = 0; i < technicians.length; i++)
		{
			var technician = technicians[i];
			
			var MarkerColor = getTechColorForRoute(technician.Id);
			
	    	techMarker = createCurrentMarker(technician,MarkerColor,true,Literals.TECHNICIAN);
	    	techMarker.info = technician;
	    	
	    	techHomeMarker = createHomeMarkerFrom(technician,MarkerColor,true,Literals.TECHNICIAN);
	    	techHomeMarker.info = technician;
	    	
	    	//if(document.getElementById("current_loc").checked == true){ 
	    	//	added = addMarker(techMarker);
	    	//}
	    	
	    	//if(document.getElementById("home_loc").checked == true){ 
	    	//	added = addMarker(techHomeMarker);
		    //}	
		    
		   // if(document.getElementById("both_loc").checked == true){
		    //	added = addMarker(techHomeMarker);
		    //	added = addMarker(techMarker);
		    //}
		    if(Ext.getCmp("current_loc").checked == true){ 
	    		added = addMarker(techMarker);
	    	}
	    	
	    	if(Ext.getCmp("home_loc").checked == true){ 
	    		added = addMarker(techHomeMarker);
		    }	
		    
		    if(Ext.getCmp("both_loc").checked == true){
		    	added = addMarker(techHomeMarker);
		    	added = addMarker(techMarker);
		    }
		    		    
	    	if(!added)
	    		callLater = true;
	    	
	    	google.maps.event.addListener(techMarker, 'mouseover', showInfo);
	    	google.maps.event.addListener(techHomeMarker, 'mouseover', showInfo);
	    	 
	    	//Persist the markers
	    	//if(document.getElementById("home_loc").checked == true){ 
	    	//	searchTechMarkers.push(techHomeMarker);
	    	//}
	    	
	    	//if(document.getElementById("current_loc").checked == true){ 
	    	//	searchTechMarkers.push(techMarker);
	    	//}
	    	
	    	//if(document.getElementById("both_loc").checked == true){
	    	//	searchTechMarkers.push(techMarker);
	    	//	searchTechMarkers.push(techHomeMarker);
	    	//}
	    	
	    	if(Ext.getCmp("home_loc").checked == true){ 
	    		searchTechMarkers.push(techHomeMarker);
		    }
		    	    	
	    	if(Ext.getCmp("current_loc").checked == true){ 
	    		searchTechMarkers.push(techMarker);
	    	}
		    
		    if(Ext.getCmp("both_loc").checked == true){
		    	searchTechMarkers.push(techHomeMarker);
		    	searchTechMarkers.push(techMarker);
		    }		    
		}
		
		var firstTech = null;
		//var radiusComp = Ext.getCmp("radiusComp");
				 			
		if(!callLater)
		{
			firstTech = getFirstMarkerWithValidLatLng(searchTechMarkers);
			
			if(firstTech)//Pan to first tech having valid lat lng
				mapInstance.panTo(firstTech.position);
			
			//If a workorder is selected and has a valid location, then only radius mode is applicable
			if(selectedWO && invalidMarkers && invalidMarkers.indexOf(woMarker) == -1)
			{
				radiusModeControlsVisible(true);
				//drawRadiusForSearch(radiusComp.getValue());
				if(radius_mode)
				{				
				 drawRadiusForSearch(circle_radius);
				}
				else
				{
				 radiusModeNoLimitHandler();
				}
			}
				
			displayErrorInDC();
		}
		else
		{
			var callAfterLatLngLookup = function()
			{
				firstTech = getFirstMarkerWithValidLatLng(searchTechMarkers);
			
				if(firstTech)//Pan to first tech having valid lat lng
					mapInstance.panTo(firstTech.position);
				
				//If a workorder is selected and has a valid location, then only radius mode is applicable
				if(selectedWO && invalidMarkers && invalidMarkers.indexOf(woMarker) == -1)
				{
					radiusModeControlsVisible(true);
					//drawRadiusForSearch(radiusComp.getValue());
					if(radius_mode)
					{				
					 drawRadiusForSearch(circle_radius);
					}
					else
					{
					 radiusModeNoLimitHandler();
					}
				}
					
				displayErrorInDC();
			};
			
			callBackStack.push({callBackFor : "drawSearchedTechnicians", callBack : callAfterLatLngLookup});
		}
	}
	
	function getSelectedDateForRoute()
	{
		var dateInMilliseconds = 0;
		
		if(totalRoutesPlotted != 0)
		{
			var dateTxt = Ext.getCmp("dateTxt");
			
			if(dateTxt && dateTxt.isVisible() && dateTxt.isValid())
			{
				var date = dateTxt.getValue();
				
				if(date && Ext.isDate(date))
				{
					dateInMilliseconds = date.getTime();
				}
			}
		}
		
		return dateInMilliseconds;
	}
	
	function createMarkerFrom(data/*Team/Tech/WO details with lat,lng and address*/,scale/*Boolean*/,type/*Team/Tech/WO*/)
	{
		var lat,lng,position,marker;
		
		if(data.lat)
    		lat = Number(data.lat);
    	
    	if(data.lng)
    		lng = Number(data.lng);
    	
    	if(lat != undefined && lng != undefined)
    		position = new google.maps.LatLng(lat, lng);
    	
    	var icon = defaultConfig.techIcon;
    	
    	if(type == Literals.TEAM)
    		icon = defaultConfig.teamIcon;
    	else if(type == Literals.WORKORDER)
    		icon = defaultConfig.woIcon; 	
    	var address = data.address;    	
    	//For technician with current location, don't display address as data.address has value for home address
    	if(type == Literals.TECHNICIAN)
    		address = "";
    	
    	marker = createMarker(position,data.Name,icon,address,scale,type);
		
		return marker;
	}
	
	function createCurrentMarker(data/*Team/Tech/WO details with lat,lng and address*/,markercolor/*String*/,scale/*Boolean*/,type/*Team/Tech/WO*/)
	{
		var lat,lng,position,marker;
		
		if(data.lat)
    		lat = Number(data.lat);
    	
    	if(data.lng)
    		lng = Number(data.lng);
    	
    	if(lat != undefined && lng != undefined)
    		position = new google.maps.LatLng(lat, lng);
    	
    	var icon = defaultConfig.techIcon;
    	var MarkerColor=markercolor;    	
    	
    	if(type == Literals.TEAM)
    		icon = defaultConfig.teamIcon;
    	else if(type == Literals.WORKORDER)
    		icon = Literals.BALLOON_URL;        	
    	var address = data.address;
    	
    	//For technician with current location, don't display address as data.address has value for home address
    	if(type == Literals.TECHNICIAN)
    		address = "";
    	
    	marker = createMarkerWithLabel(position,data.Name,icon,address,"Current",MarkerColor,data.FirstName,data.LastName,data.SmallPhotoUrl,scale,type);
		
		return marker;
	}
	
	
	function createHomeMarkerFrom(data/*Team/Tech/WO details with lat,lng and address*/,markercolor/*String*/,scale/*Boolean*/,type/*Team/Tech/WO*/)
	{
		var lat,lng,position,marker;
		
		if(data.homeLat)
    		lat = Number(data.homeLat);
    	
    	if(data.homeLng)
    		lng = Number(data.homeLng);
    	
    	if(lat != undefined && lng != undefined)
    		position = new google.maps.LatLng(lat, lng);
    	
    	var icon = defaultConfig.techHomeIcon;
    	var MarkerColor=markercolor;    	
    	
    	marker = createMarkerWithLabel(position,data.Name,icon,data.homeAddress,"Home",MarkerColor,data.FirstName,data.LastName,data.SmallPhotoUrl,scale,type);
		
		return marker;
	}
	
	function getFirstMarkerWithValidLatLng(markers/*Array*/)
	{
		if(!markers || markers.length == 0)
			return;
		
		var marker = null;
		
		for (var i = 0; i < markers.length; i++) 
		{
		    var result = false;
		    if(markers[i].position)
		    {
		    	result = true;
				marker = markers[i];
				
				return marker;
		    }
		}
		
		/*markers.some(function(item)
		{
			var result = false;
			
			if(item.position)
			{
				result = true;
				marker = item;
			}
			
			return result;
		});*/
		
		return marker;
	}
	
	function getTechColorForRoute(Id/*String*/)
	{
		var color = "";
		
		//Initialize color counter
		if(!getTechColorForRoute.hasOwnProperty("colorCounter"))
			getTechColorForRoute.colorCounter = 0;
		
		if(techColorMap[Id])
		{
			color = techColorMap[Id];
		}
		else
		{
			color = techRouteColors[getTechColorForRoute.colorCounter++];			
			techColorMap[Id] = color;
			
			if(getTechColorForRoute.colorCounter == techRouteColors.length)
				getTechColorForRoute.colorCounter = 0;
		}
		
		return color;
	}
	
	function getLocationBase()
	{
		var value = "";		
		
		if(Ext.getCmp("home_loc").checked)
		{
			value = "home";
		}
		else if(Ext.getCmp("current_loc").checked)
		{
			value = "current";
		}
		else if(Ext.getCmp("both_loc").checked)
		{
			value = "both";
		}
		
		if(value)
			defaultConfig.locationBase = value;
			
		return value;
	}
	
	function displayErrorInDC(message/*String*/)
	{	
		var errorInfo = {};
		errorInfo.invalidMarkers = invalidMarkers.length == 0 ? null : invalidMarkers;
		
		if(message)
			errorInfo.message = message;
		
		var handle = getDCHandle();
		
		if(handle)
		{
			//Error is not displayed when called from popup view. There is Array prototype conflict between windows (DC and popup view).
			//So when passing the array to swf, its passed as an object and not an array
			//To resolve that create an instance of Array from dcWindow and pass that
			if(dcWindow && errorInfo.invalidMarkers)
			{
				var dcWinArr = new dcWindow.Array();
				
				errorInfo.invalidMarkers.foreach(function(item)
				{
					dcWinArr.push(item);
				});
				
				errorInfo.invalidMarkers = dcWinArr;
			}					
			handle.displayErrorInDC(errorInfo);
			invalidMarkers = [];
		}
	}

	function getDCHandle()
	{
		var handle = null;
		
		if(window.DCHandle)//If its inline map, this will be true
		{
			handle = window.DCHandle;
		}
		else if(dcWindow)//If its popup map, this will be true
		{
			handle = dcWindow.DCHandle;
		}
		
		return handle;
	}
	function CustomCircleOverlay(circlMapInstance, latLng, circleRadius,mapUnit,mapValue, strokeColor, strokeWidth, strokeOpacity, fillColor, fillOpacity, numofPoints) {
	this.map = circlMapInstance;		
	this.setMap(circlMapInstance);	
	this.latLng = latLng;
	this.radius = circleRadius;
	this.strokeColor = strokeColor;
	this.strokeWidth = strokeWidth;
	this.strokeOpacity = strokeOpacity;
	this.fillColor = fillColor;
	this.fillOpacity = fillOpacity;
	this.div_ = null;	
	this.mapUnit=mapUnit;
	this.mapValue=mapValue;

	
	// Set resolution of polygon
	if (typeof(numofPoints) == 'undefined') {
		this.numPoints = 45;
	} else {
		this.numPoints = numofPoints;
	}
}

// Inherit from GOverlay
CustomCircleOverlay.prototype = new google.maps.OverlayView();

// Reset overlay
CustomCircleOverlay.prototype.clear = function() {
	if(this.polygon != null && this.map != null) {
		this.polygon.setMap(null);
	}
}

// Calculate all the points of the circle and draw them
CustomCircleOverlay.prototype.draw = function(force) {
	var d2r = Math.PI / 180;
	customcircleLatLngs = new Array();	
    var anglevalue=0;
    	
	// Convert statute miles into degrees latitude
	var customcircleLat;	
	if(this.mapUnit==this.mapValue)
	{
	customcircleLat = this.radius * 0.014483;
	}
	else
	{
	customcircleLat = this.radius * 0.621371192 * 0.014483; 
	}
	var customcircleLng = customcircleLat / Math.cos(this.latLng.lat() * d2r);
			
	// Create polygon points (extra point to close polygon)
	for (var i = 0; i < this.numPoints + 1; i++) { 	   
		// Convert degrees to radians
		var circletheta = Math.PI * (i / (this.numPoints / 2));         		
		var vertexLat = this.latLng.lat() + (customcircleLat * Math.sin(circletheta)); 
		var vertexLng = this.latLng.lng() + (customcircleLng * Math.cos(circletheta));
		var vertextLatLng = new google.maps.LatLng(vertexLat, vertexLng);		
		customcircleLatLngs.push(vertextLatLng); 		
		
		//get the center points
        var centerpoint = this.getProjection().fromLatLngToDivPixel(this.latLng);	
        //get the projection points	
		var point = this.getProjection().fromLatLngToDivPixel(vertextLatLng);		
		//find the angle using the center point and projection point
		var p0 = {x: centerpoint.x, y: centerpoint.y - Math.sqrt(Math.abs(point.x - centerpoint.x) * Math.abs(point.x - centerpoint.x)
            + Math.abs(point.y - point.y) * Math.abs(point.y - point.y))};           
        var anglevalueforeachpoint= (2 * Math.atan2(point.y - p0.y, point.x - p0.x)) * 180 / Math.PI;
        
        //Round the angle value
        var anglestr = anglevalueforeachpoint.toFixed(0);        		
        if ((anglestr >=-200)&& (anglestr <= 0))		 
		 {	
		    //this angle is the projection of text in a circle		
            anglevalue=i;			
		 }
	}
	this.clear();
	this.polygon = new google.maps.Polygon({	
		paths: [customcircleLatLngs], 		
		strokeColor: this.strokeColor, 
		strokeWeight: this.strokeWidth, 
		strokeOpacity: this.strokeOpacity, 
		fillColor: this.fillColor, 
		fillOpacity: this.fillOpacity
	});
	this.polygon.setMap(this.map);
	
	var self=this;
	google.maps.event.addDomListener(this.polygon, "click", function(event) {					
			google.maps.event.trigger(self, "click",event);			
		});
	
	    
	var div = this.div;
	if (!div) {
	
		div = this.div = document.createElement('div');
		
		div.className = 'marker';	
		
		div.style.position = 'absolute';		
		div.style.background =this.fillColor;	
        //div.style.borderRadius = "25px";     
		
		var span = this.span_ = document.createElement('span');
        span.style.cssText = 'color:#ffffff;fontSize:9px';
        div.appendChild(span);		
		this.span_.innerHTML = this.radius+" "+this.mapUnit;
		var panes = this.getPanes();
		panes.overlayImage.appendChild(div);
	}	
	var point = this.getProjection().fromLatLngToDivPixel(customcircleLatLngs[anglevalue]);	
	if (point) {
		div.style.left = (point.x-10) + 'px';
		div.style.top = (point.y-5) + 'px';
		//div.style.left = (point.x - 30) + 'px';
	}
}

//Remove circle with text method
CustomCircleOverlay.prototype.remove = function() {
	if (this.div) {
		this.div.parentNode.removeChild(this.div);
		this.div = null;
	}	
	this.clear();
};

CustomCircleOverlay.prototype.getPosition = function() {
	return this.latlng;	
};


// Remove circle method
//CustomCircleOverlay.prototype.remove = function() {   
//	this.clear();
//}


CustomCircleOverlay.prototype.containsLatLng = function(latLng) {
	if(this.polygon.containsLatLng) {
		return this.polygon.containsLatLng(latLng);
	}
}

// Set radius of circle
CustomCircleOverlay.prototype.setRadius = function(radius) {
	this.radius = radius;
}

// Set center of circle
CustomCircleOverlay.prototype.setLatLng = function(latLng) {
	this.latLng = latLng;
}

	MapHandle.setDCContextAndRenderMap = setDCContextAndRenderMap;
	MapHandle.renderMap = renderMap;
	MapHandle.setDefaultMapConfig = setDefaultMapConfig;
	MapHandle.getDefaultMapConfig = getDefaultMapConfig;
	MapHandle.drawTechnicianRoute = drawTechnicianRoute;
	MapHandle.getCurrentContext = getCurrentContext;
	MapHandle.resetMapToDefaultConfig = resetMapToDefaultConfig;
	MapHandle.loadContextFromPopupMap = loadContextFromPopupMap;
	MapHandle.drawSearchedTeams = drawSearchedTeams;
	MapHandle.drawSearchedTechnicians = drawSearchedTechnicians;
	MapHandle.clearRoute = clearRoute;
	MapHandle.a = clearMap;
	MapHandle.getSelectedDateForRoute = getSelectedDateForRoute;
	MapHandle.getViewDataToPlotHandler = getViewDataToPlotHandler;
	MapHandle.getLocationBase = getLocationBase;
	MapHandle.locationBaseRadioClick = locationBaseRadioClick;
	window.DCViewsPanel = DCViewsPanel;
})();
