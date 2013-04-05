function computeAngle_Pano(obj, x, y, f, heading, pitch){
        // return theta and phi  (yaw and pitch)
        // obj is the mapcanvas
        var u = x - obj.position().left + 10 - obj.width()/2;  // add back the size of marker
        var v = y - obj.position().top + 10 - obj.height()/2;

        var result = Rotate3D_xaxis(u, v, f, pitch);
        result = Rotate3D_yaxis(result.x, result.y, result.z, heading);
        u = result.x;
        v = result.y;
        f = result.z;

        var theta = Math.atan2(u, f);
        var phi = Math.atan(v / Math.sqrt(Math.pow(u,2)+Math.pow(f, 2)) );
        heading = theta*180/Math.PI;
        pitch = -phi*180/Math.PI;
        return {heading: heading, pitch: pitch};
      }
      function computeXY_Pano(obj, theta, phi, pitch, heading, f){
        var u = Math.tan(theta*Math.PI/180) * f;
        var v = Math.tan(-phi*Math.PI/180) * (Math.sqrt(Math.pow(u,2)+Math.pow(f, 2)) );

        var result = Rotate3D_yaxis(u, v, f, -heading);
        result = Rotate3D_xaxis(result.x, result.y, result.z, -pitch);
        u = result.x * f;
        v = result.y * f;
        f = f;

        $('#output').html('u: ' + u + '<br> v: ' + v);

        var x = u + obj.position().left + obj.width()/2 - 10;
        var y = v + obj.position().top + obj.height()/2 - 10;
        return {x:x, y:y};
      }
      function aatan2(theta, f){
        var d = Math.tan(theta);
        var u = 0;
        if (d > 0)
                u = d * f;
        else
                u = Math.tan(theta-Math.PI) * f;
        return u;
      }
      function Rotate3D_xaxis(x, y, z, pitch){  // pitch
        var theta = pitch / 180 * Math.PI;
        var xx = x;
        var yy = y*Math.cos(theta) - z*Math.sin(theta);
        var zz = y*Math.sin(theta) + z*Math.cos(theta);
        x = xx / zz;
        y = yy / zz;
        z = 1;
        return {x:x, y:y, z:z};
      }
      function Rotate3D_yaxis(x, y, z, yaw){   // yaw
        var theta = yaw / 180 * Math.PI;
        var yy = y;
        var xx = x*Math.cos(theta) + z*Math.sin(theta);
        var zz = -x*Math.sin(theta) + z*Math.cos(theta);
        x = xx / zz;
        y = yy / zz;
        z = 1;
        return {x:x, y:y, z:z};
      }
