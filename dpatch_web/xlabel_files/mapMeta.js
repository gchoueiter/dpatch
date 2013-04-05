      function getMapOption(lat, lon){
        var mapOptions = {
        center: new google.maps.LatLng(lat, lon),
        zoom: 21,
        scrollwheel: false,
        navigationControl: false,
        zoomControl: false,
        StreetViewcontrol: false,
        MapTypecontrol: false,
        OverviewMapcontrol: false,
        mapTypeId: 'satellite'
        };
	return mapOptions;	
      }
      function getPanoOption(lat, lon){
	var pos = new google.maps.LatLng(lat, lon);
	var panoramaOptions = {
          position: pos,
          scrollwheel: false,
          pov: {
            zoom:1,
            heading: 260.77+90,
            pitch: 0
          }
        };
	return panoramaOptions;
      }

      function getMapPos(obj){
        var nw = new google.maps.LatLng(
            obj.getBounds().getNorthEast().lat(),
            obj.getBounds().getSouthWest().lng()
        );
        projection = obj.getProjection();
        var scale = Math.pow(2, obj.getZoom());
        var x_px = obj.getProjection().fromLatLngToPoint(nw).x * scale;
        var y_px  = obj.getProjection().fromLatLngToPoint(nw).y * scale;
        //return pos;
	return {x:obj.getProjection().fromLatLngToPoint(nw).x, y:obj.getProjection().fromLatLngToPoint(nw).y, x_px:x_px, y_px:y_px};
      }

      function loadPanoData(obj, id){
        var heading = obj.getPov().heading;
        var pitch = obj.getPov().pitch;
        var zoom = obj.getZoom();
        var fov = FOV[zoom];
        var hfov= fov * Math.PI/180;
        var f = $('#map_canvas'+id).width()/(2*Math.tan(hfov/2));  // focal length is just Z
        return {heading: heading, pitch: pitch, zoom: zoom, f: f}
      }
