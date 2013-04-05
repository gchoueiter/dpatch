function addAerialMapListener(map){
	google.maps.event.addListener(map, 'center_changed', function() {
                result = getMapPos(map);
                for (i=0; i<map.marker_len; i++){
                        var m = $('#marker_' + i);
                        var x = m.data('x');
                        var y = m.data('y');
                        var scale = Math.pow(2, map.getZoom());
                        m.css('left', (x-result.x)*scale + $('#map_canvas').position().left  +'px');
                        m.css('top',(y-result.y)*scale + $('#map_canvas').position().top  +'px');
                        var content = 'x: ' +result.x_px*scale +'<br> y: ' + result.y_px*scale;
                        $('#output').html(content)
                }
        });
        $(document).bind("contextmenu",function(e){
              return false;
       });

        google.maps.event.addListener(map, 'heading_changed', function() {
                removeMarker(map, '');
                removeMarker(map2, 2);
                removeMarker(map3, 3);
                map2.setPov({
                        heading: map.heading,
                        pitch:0}
                );
                map3.setPov({
                        heading: map.heading,
                        pitch:0}
                );
        });

}

function addPanoMapListener(pano, id){
        google.maps.event.addListener(pano, 'zoom_changed', function() {
                panoData = loadPanoData(pano, id);
                if ($.isNumeric(panoData.f)){
                for (i=0; i<pano.marker_len; i++){
                        var m = $('#marker'+id+'_'+ i);
                        // compute pixel location
                        var theta = m.data('heading');
                        var phi = m.data('pitch');
                        var result = computeXY_Pano($('#map_canvas'+id), theta, phi, panoData.pitch, panoData.heading, panoData.f);
                        m.css('top', result.y  +'px');
                        m.css('left', result.x +'px');

                        var content = 'heading: ' + pano.getPov().heading + 'pitch: ' + pano.getPov().pitch;
                        content += '<br>heading_point: ' + m.data('heading') + '<br>pitch_point: ' + m.data('pitch');
                }
                $('#output').html(content);
                }
        });

        google.maps.event.addListener(pano, 'pov_changed', function() {
                panoData = loadPanoData(pano, id);
                if ($.isNumeric(panoData.f)){
                for (i=0; i<pano.marker_len; i++){
                        var m = $('#marker'+id+'_'+ i);
                        // compute pixel location
                        var theta = m.data('heading');
                        var phi = m.data('pitch');
                        var result = computeXY_Pano($('#map_canvas'+id), theta, phi, panoData.pitch, panoData.heading, panoData.f);
                        m.css('top', result.y  +'px');
                        m.css('left', result.x +'px');

                        var content = 'heading: ' + pano.getPov().heading + 'pitch: ' + pano.getPov().pitch;
                        content += '<br>heading_point: ' + m.data('heading') + '<br>pitch_point: ' + m.data('pitch');
                        $('#output').html(content);
                }
                }
        });
}
