      function loadMaps(lat, lon){
	removeMarker(map, '');
	removeMarker(map2, 2);
	removeMarker(map3, 3);
// map
        var mapOptions = getMapOption(lat, lon);
        map = new google.maps.Map(document.getElementById("map_canvas"), mapOptions);
        map.marker_len = 0;
        addAerialMapListener(map);
// deal with panoData	
	latlon = new google.maps.LatLng(lat, lon);
	panoClient.getPanoramaByLocation(latlon, 49, setPanoData2);
/*	
// map2
        //var panoramaOptions = getPanoOption(lat, lon);
        var panoramaOptions = getPanoOption(panoData2.location.latlng.hb, panoData2.location.latlng.ib);
        map2 = new google.maps.StreetViewPanorama(document.getElementById("map_canvas2"), panoramaOptions);
        map2.marker_len = 0;
        addPanoMapListener(map2, 2);
*/
// map3
        // get next street view id?
        //var panoramaOptions = getPanoOption(lat, lon);
/*
        var panoramaOptions = getPanoOption(panoData3.location.latlng.hb, panoData3.location.latlng.ib);
        map3 = new google.maps.StreetViewPanorama(document.getElementById("map_canvas3"), panoramaOptions);
        map3.marker_len = 0;
        addPanoMapListener(map3, 3);

        $(document).bind("contextmenu",function(e){
              return false;
       });
*/
      }

function removeMarker(obj, id){
	if (typeof(obj) == ''){
		// do nothing
	}else{
		for (i=0;i<obj.marker_len; i++){
			$('#marker'+id+'_'+i).remove();
		}
	}
}

function setPanoData2(panoData,gstatus) {  
	panoData2 = panoData;
	var panoramaOptions = getPanoOption(panoData.location.latLng.ib, panoData.location.latLng.jb);
        map2 = new google.maps.StreetViewPanorama(document.getElementById("map_canvas2"), panoramaOptions);
        map2.marker_len = 0;
        addPanoMapListener(map2, 2);

	var id = panoData.links[0].pano;
	panoClient.getPanoramaById(id, setPanoData3);
}

function setPanoData3(panoData, gstatus) {
	panoData3 = panoData;
	var panoramaOptions = getPanoOption(panoData3.location.latLng.ib, panoData3.location.latLng.jb);
        map3 = new google.maps.StreetViewPanorama(document.getElementById("map_canvas3"), panoramaOptions);
        map3.marker_len = 0;
        addPanoMapListener(map3, 3);

        $(document).bind("contextmenu",function(e){
              return false;
       });
}
