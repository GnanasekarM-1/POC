function buildLatLng(latlng){
	var latlng = {lat: latlng.lat(), lng: latlng.lng()};
	return latlng;
}
function SVMXPolygon(id){
	var objPolygon = {id : id, name : 'Untitled' , latLng : new Array(), fillColor : '#1E90FF', clickable : false};
	return objPolygon;
}
function SVMXCircle(circle){
	var objCircle = {id : circle.id, name : 'Untitled', center : buildLatLng(circle.getCenter()), radius : circle.getRadius(), fillColor : '#1E90FF'};
	return objCircle;
}
function SVMXRectangle(rectangle){
	var objRectangle = {id : rectangle.id, name : 'Untitled', ne : buildLatLng(rectangle.getBounds().getNorthEast()), sw : buildLatLng(rectangle.getBounds().getSouthWest()), fillColor : '#1E90FF'};
	return objRectangle;
}



function clearSelection() {
	if (selectedShape) {
		selectedShape.setEditable(false);
		selectedShape = null;
	}
}

function setSelection(shape) {
	clearSelection();
	selectedShape = shape;
	shape.setEditable(true);
	selectColor(shape.get('fillColor') || shape.get('strokeColor'));
}

function deleteSelectedShape() {
	for(var Zoneid in lstDeleteZone)
	{
			selectedShape = lstDeleteZone[Zoneid];
		if (selectedShape) {
			selectedShape.setMap(null);
			var divCount = document.getElementById("counter_" + selectedShape.id );
			if(divCount)
			divCount.value = '';
			var divName = document.getElementById(selectedShape.id );		
			if (selectedShape.type == google.maps.drawing.OverlayType.POLYGON) {
				polygons = removeShape(selectedShape, polygons);
			}
			if (selectedShape.type == google.maps.drawing.OverlayType.CIRCLE) {
				circles = removeShape(selectedShape, circles);
			}
			if (selectedShape.type == google.maps.drawing.OverlayType.RECTANGLE) {
				rectangles = removeShape(selectedShape, rectangles);
			}
			if(ZonesIDtoDelete != null && ZonesIDtoDelete != '')
				ZonesIDtoDelete = ZonesIDtoDelete + "\;" + selectedShape.id ;
			else
				ZonesIDtoDelete = selectedShape.id ;
			if(ZonesIDtoDelete != null && ZonesIDtoDelete != '')
				ZonesIDtoDelete = ZonesIDtoDelete + "\;" + selectedShape.id ;
			else
				ZonesIDtoDelete = selectedShape.id ;
				
		}
			
		
	}
	updateZoneNametab();
	updateWOCount();
}

function removeShape(selectedShape, availableShapes){
	var tmpShape = new Array;
	for(var i in availableShapes){
		var shape = availableShapes[i];
		if(selectedShape.id != shape.id)
		{
			tmpShape.push(shape);
			
		}
	}
	return tmpShape;
}
function updateShape(selectedShape, availableShapes){
	var tmpShape = new Array;
	for(var i in availableShapes){
		var shape = availableShapes[i];
		if(selectedShape.id != shape.id)
			tmpShape.push(shape);
	}
	tmpShape.push(selectedShape);
	return tmpShape;
}

function selectNextColor(){
	if(selectedColor != null){
		for (var i = 0; i < colors.length; ++i) {
			if(selectedColor == colors[i]){
				if((i+1) < colors.length)
					selectColor(colors[i+1]);
				else
					selectColor(colors[0]);
				break;
			}
		}
	}
	else
		selectColor(colors[0]);
}

function selectColor(color) {
	selectedColor = color;
	/*
	for (var i = 0; i < colors.length; ++i) {
		var currColor = colors[i];
		colorButtons[currColor].style.border = currColor == color ? '2px solid #789' : '2px solid #fff';
	}*/

	// Retrieves the current options from the drawing manager and replaces the
	// stroke or fill color as appropriate.
	var rectangleOptions = drawingManager.get('rectangleOptions');
	rectangleOptions.fillColor = color;
	drawingManager.set('rectangleOptions', rectangleOptions);

	var circleOptions = drawingManager.get('circleOptions');
	circleOptions.fillColor = color;
	drawingManager.set('circleOptions', circleOptions);

	var polygonOptions = drawingManager.get('polygonOptions');
	polygonOptions.fillColor = color;
	drawingManager.set('polygonOptions', polygonOptions);
}

function setSelectedShapeColor(color) {
	if (selectedShape) {
		if (selectedShape.type == google.maps.drawing.OverlayType.POLYLINE) {
			selectedShape.set('strokeColor', color);
		} else {
			selectedShape.set('fillColor', color);
		}
		if (selectedShape.type == google.maps.drawing.OverlayType.POLYGON) {
			updatePolygon(selectedShape, color)
		}
		else if (selectedShape.type == google.maps.drawing.OverlayType.CIRCLE) {
			updateCircle(selectedShape, color)
		}
		else if (selectedShape.type == google.maps.drawing.OverlayType.RECTANGLE) {
			updateRectangle(selectedShape, color)
		}
	}
}

function makeColorButton(color) {
	var button = document.createElement('span');
	button.className = 'color-button';
	button.style.backgroundColor = color;
	google.maps.event.addDomListener(button, 'click', function() {
		selectColor(color);
		setSelectedShapeColor(color);
	});
	return button;
}

function buildColorPalette() {
	var colorPalette = document.getElementById('color-palette');
	for (var i = 0; i < colors.length; ++i) {
		var currColor = colors[i];
		var colorButton = makeColorButton(currColor);
		colorPalette.appendChild(colorButton);
		colorButtons[currColor] = colorButton;
	}
	selectColor(colors[0]);
}

function countMarkers(newShape) {
	var count = 0;
	for (var i = 0; i < markers.length; i++) {
	   var marker = markers[i];
	   var latLng = marker.position;
	   var contains = false;
	   
	   if (newShape.type == google.maps.drawing.OverlayType.POLYGON) {
			contains = google.maps.geometry.poly.containsLocation(latLng, newShape);
	   }
	   if (newShape.type == google.maps.drawing.OverlayType.RECTANGLE) {
			var bounds = newShape.getBounds();
			contains = bounds.contains(latLng);
	   }
	   if (newShape.type == google.maps.drawing.OverlayType.CIRCLE) {
			var bounds = newShape.getBounds();
			contains = bounds.contains(latLng);
	   }
	   
	   if (contains) count++;
	}

	//document.getElementById("count_"+newShape.id ).innerHTML =count ;
	//div.innerText = count;
	//return count;
	var div = document.getElementById("counter_" + newShape.id );
	if(div)
	div.value = count;
	j$("counter_" + newShape.id).text(count);
	//return count;
}
function getUniqueId(){
	uniqueId++;
	return uniqueId;
}
function edtZoneName()
{
	var zoneName = prompt("{!$Label.SORG002_TAG118}","");
}
function convert(str)
{
	if(str != null)
	{
		console.log('Name Before  :'+str);
	  str = str.replace(/&amp;/g, '&');
	  str = str.replace(/&gt;/g, '>');
	  str = str.replace(/&lt;/g, '<');
	  str = str.replace(/&quot;/g, '/"');
	  //str = str.replace("&#039;", '/'');
	  console.log('Name After  :'+str);
	  return str;
	}  
  console.log('  Zone name  '+str);
}
function buildZoneName(zoneName){
	var zoneEdit = document.createElement('td');
	zoneEdit.setAttribute('class', 'zonename');
	//zoneEdit.innerHTML = zoneName;
	zoneEdit.append(buildZoneEdit());
	return zoneEdit;
}

function buildZoneCount(count){
	var zoneEdit = document.createElement('td');
	zoneEdit.setAttribute('class', 'counter');
	zoneEdit.innerHTML = count;
	return zoneEdit;
}

function buildZoneEdit(){
	var zoneEdit = document.createElement('a');
	zoneEdit.setAttribute('href', '#');
	zoneEdit.onclick = function(){edtZoneName()};
	return zoneEdit;
}

/* function addZoneName(shape, shapeData){

	var displayRoot =  j$("#listZones");
	var zone = document.createElement('tr');
	zone.setAttribute('style', 'padding:2px;background-color:' + shape.fillColor + ';border: 1px solid' + changeColor(shape.fillColor, 0.1, 1));
	//zone.innerHTML = '<td class="zonename">' + shape.name +'</td><td class="counter">' + countMarkers(shape) + '</td>';
	zone.append(buildZoneName(shape.name));
	zone.append(buildZoneCount(countMarkers(shape)));
	zone.onmouseover = function() {
			shape.setOptions({strokeColor: changeColor(shape.fillColor, 0.1, 1), strokeOpacity: 1, strokeWeight: 2});
			//zone.innerHTML = '<td class="zonename">' + shape.name +' '+'<div class="editZoneName">Edit</div>'+ '</td><td class="counter">' + countMarkers(shape) + '</td>';
		};
	zone.onmouseout = function() { 
			shape.setOptions({strokeColor: changeColor(shape.fillColor, 0.1, 1), strokeOpacity: 0, strokeWeight: 0});

			//zone.innerHTML = '<td class="zonename">' + shape.name +' '+'<div class="editZoneName">Edit</div>'+ '</td><td class="counter">' + countMarkers(shape) + '</td>';
		};
	zone.onclick = function(){setSelection(shape)};
	zone.ondblclick = function(){a
			var zoneField = document.createElement('input');
			zoneField.setAttribute('type', 'text');
			if(shapeData.name)
			{
				zoneField.setAttribute('value', convert(shapeData.name));
				zoneField.setAttribute('value', convert(shape.name));
			}
			zoneField.onblur = function() {
			
			debugger;shapeData.name = convert(zoneField.value);
			//zone.innerHTML = '<td class="zonename">' + zoneField.value +' '+'<div class="editZoneName">Edit</div>'+  '</td><td class="counter">' + countMarkers(shape) + '</td>';
			};
			if(zone)
			{
				zone.innerHTML = '';
			}
			debugger;
			zone.appendChild(zoneField);
			zoneField.focus();
			zone.onmouseover = function() {shape.setOptions({strokeColor: changeColor(shape.fillColor, 0.1, 1), strokeOpacity: 1, strokeWeight: 2});};
			zone.onmouseout = function() {shape.setOptions({strokeColor: changeColor(shape.fillColor, 0.1, 1), strokeOpacity: 0, strokeWeight: 0});};
			countMarkers(shape);
			
		};
		shapeData.deleteZone = function(){
		zone.setAttribute('style', 'display:none');
	}
	displayRoot.append(zone);
	//j$('.editZoneName').onclick = function(){edtZoneName()};
} */
		

var pad = function(num, totalChars) {
    var pad = '0';
    num = num + '';
    while (num.length < totalChars) {
        num = pad + num;
    }
    return num;
};



// Ratio is between 0 and 1
var changeColor = function(color, ratio, darker) {
    // Trim trailing/leading whitespace
	if(color != null)
    color = color.replace(/^\s*|\s* j$/, '');

    // Expand three-digit hex
    color = color.replace(
        /^#?([a-f0-9])([a-f0-9])([a-f0-9]) j$/i,
        '# j$1 j$1 j$2 j$2 j$3 j$3'
    );

    // Calculate ratio
    var difference = Math.round(ratio * 256) * (darker ? -1 : 1),
        // Determine if input is RGB(A)
        rgb = color.match(new RegExp('^rgba?\\(\\s*' +
            '(\\d|[1-9]\\d|1\\d{2}|2[0-4][0-9]|25[0-5])' +
            '\\s*,\\s*' +
            '(\\d|[1-9]\\d|1\\d{2}|2[0-4][0-9]|25[0-5])' +
            '\\s*,\\s*' +
            '(\\d|[1-9]\\d|1\\d{2}|2[0-4][0-9]|25[0-5])' +
            '(?:\\s*,\\s*' +
            '(0|1|0?\\.\\d+))?' +
            '\\s*\\) j$'
        , 'i')),
        alpha = !!rgb && rgb[4] != null ? rgb[4] : null,

        // Convert hex to decimal
        decimal = !!rgb? [rgb[1], rgb[2], rgb[3]] : color.replace(
            /^#?([a-f0-9][a-f0-9])([a-f0-9][a-f0-9])([a-f0-9][a-f0-9])/i,
            function() {
                return parseInt(arguments[1], 16) + ',' +
                    parseInt(arguments[2], 16) + ',' +
                    parseInt(arguments[3], 16);
            }
        ).split(/,/),
        returnValue;

    // Return RGB(A)
    return !!rgb ?
        'rgb' + (alpha !== null ? 'a' : '') + '(' +
            Math[darker ? 'max' : 'min'](
                parseInt(decimal[0], 10) + difference, darker ? 0 : 255
            ) + ', ' +
            Math[darker ? 'max' : 'min'](
                parseInt(decimal[1], 10) + difference, darker ? 0 : 255
            ) + ', ' +
            Math[darker ? 'max' : 'min'](
                parseInt(decimal[2], 10) + difference, darker ? 0 : 255
            ) +
            (alpha !== null ? ', ' + alpha : '') +
            ')' :
        // Return hex
        [
            '#',
            pad(Math[darker ? 'max' : 'min'](
                parseInt(decimal[0], 10) + difference, darker ? 0 : 255
            ).toString(16), 2),
            pad(Math[darker ? 'max' : 'min'](
                parseInt(decimal[1], 10) + difference, darker ? 0 : 255
            ).toString(16), 2),
            pad(Math[darker ? 'max' : 'min'](
                parseInt(decimal[2], 10) + difference, darker ? 0 : 255
            ).toString(16), 2)
        ].join('');
};

var lighterColor = function(color, ratio) {
    return changeColor(color, ratio, false);
};
var darkerColor = function(color, ratio) {
    return changeColor(color, ratio, true);
};