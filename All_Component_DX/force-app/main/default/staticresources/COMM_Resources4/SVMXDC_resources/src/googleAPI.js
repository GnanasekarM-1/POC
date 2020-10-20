

var loadScript = function(url,location){
    

    var script = document.createElement('script');
    script.src = url;

    location.appendChild(script);
};

loadScript('https://maps.google.com/maps/api/js?sensor=false&libraries=drawing,geometry&client=gme-servicemaxinc', document.head);
//loadScript('https://google-maps-utility-library-v3.googlecode.com/svn/trunk/markerclusterer/src/markerclusterer.js', document.head);
