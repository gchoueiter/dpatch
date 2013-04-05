      function createMarker(marker_type, len, x, y){
        $clone_node=cloneMarker(marker_type, len, x, y);
        $clone_node.bind('mouseup', function(event){
                var result = getMapPos(map);
                var x_abs = parseFloat($(this).css('left'));
                var y_abs  = parseFloat($(this).css('top'));
                var scale = Math.pow(2, map.getZoom());
                $(this).data('x', (x_abs - $('#map_canvas').position().left + result.x_px)/ scale );
                $(this).data('y', (y_abs - $('#map_canvas').position().top + result.y_px)/ scale );
		changeMarkerColor($(this).data('idx'));
        });
      }
      function createMarker_pano2(marker_type, len, x, y){
        $clone_node=cloneMarker(marker_type, len, x, y);
        var panoData = loadPanoData(map2, 2);
        result = computeAngle_Pano($('#map_canvas2'), x, y, panoData.f, panoData.heading, panoData.pitch);

        $clone_node.data('heading', result.heading);
        $clone_node.data('pitch', result.pitch);
        content = '';
        content += '<br> heading: ' + result.heading + '<br> pitch: ' + result.pitch;
        $('#output').html(content);
        $clone_node.bind('mouseup', function(event){
                // compute heading and pitch
                var panoData = loadPanoData(map2, 2);
                x = event.clientX-10+$('#body').scrollLeft();
                y = event.clientY-10+$('#body').scrollTop();
                result = computeAngle_Pano($('#map_canvas2'), x, y, panoData.f, panoData.heading, panoData.pitch);
                $(this).data('heading', result.heading);
                $(this).data('pitch', result.pitch);
		changeMarkerColor($(this).data('idx'));

                content = '<br> heading: ' + result.heading + '<br> pitch: ' + result.pitch;
                $('#output').html(content);
        });
      }
      function changeMarkerColor(i){
	for (j=0; j<map.marker_len; j++){
		if (j == i)
			$('#marker_'+j).children().children().css('fill', 'green');
		else
			$('#marker_'+j).children().children().css('fill', 'red');
	}
	for (j=0; j<map2.marker_len; j++){
		if (j == i)
			$('#marker2_'+j).children().children().css('fill', 'green');
		else
			$('#marker2_'+j).children().children().css('fill', 'red');
	}
	for (j=0; j<map3.marker_len; j++){
		if (j == i)
			$('#marker3_'+j).children().children().css('fill', 'green');
		else
			$('#marker3_'+j).children().children().css('fill', 'red');
	}
	
      }
      function createMarker_pano3(marker_type, len, x, y){
        $clone_node=cloneMarker(marker_type, len, x, y);
        var panoData = loadPanoData(map3, 3);
        result = computeAngle_Pano($('#map_canvas3'), x, y, panoData.f, panoData.heading, panoData.pitch);

        $clone_node.data('heading', result.heading);
        $clone_node.data('pitch', result.pitch);
        content = '';
        content += '<br> heading: ' + result.heading + '<br> pitch: ' + result.pitch;
        $('#output').html(content);
        $clone_node.bind('mouseup', function(event){
                // compute heading and pitch
                var panoData = loadPanoData(map3,3);
                x = event.clientX-10+$('#body').scrollLeft();
                y = event.clientY-10+$('#body').scrollTop();
                result = computeAngle_Pano($('#map_canvas3'), x, y, panoData.f, panoData.heading, panoData.pitch);
                $(this).data('heading', result.heading);
                $(this).data('pitch', result.pitch);
		changeMarkerColor($(this).data('idx'));

                content = '<br> heading: ' + result.heading + '<br> pitch: ' + result.pitch;
                $('#output').html(content);
        });
      }

      function cloneMarker(marker_type, len, x, y){
        $clone_node=$("#marker_template").clone();
        $clone_node.attr('id', marker_type + len);
        $clone_node.css('top',y);
        $clone_node.css('left',x);
	$clone_node.data('idx', len);
        $clone_node.css('visibility','visible');
        $clone_node.appendTo("body");
        $clone_node.draggable();
        $clone_node.css('position','absolute');
        return $clone_node;
      }
