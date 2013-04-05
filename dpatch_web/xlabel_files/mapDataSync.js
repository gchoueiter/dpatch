     function saveToDisk(fileUrl, fileName) {
        // Auto-save file to disk
        var save = document.createElement("a");
        save.href = fileUrl;
        save.target = "_blank";
        save.download = fileName || fileUrl;

        var evt = document.createEvent('MouseEvents');
        evt.initMouseEvent('click', true, true, window, 1, 0, 0, 0, 0, false, false, false, false, 0, null);
        save.dispatchEvent(evt);
        window.URL.revokeObjectURL(save.href)
    }

    function printCanvas() {
    var target = $("#map_canvas");
    html2canvas(target, {
      useCORS: true,
      proxy: "http://query.yahooapis.com/v1/public/yql?q=select%20*%20from%20data.uri%20where%20url%3D%22{{url}}%22&callback={{callback}}&format=json",
      taintTest: true,
      allowTaint: false,
      onrendered: function(canvas) {
      var img = canvas.toDataURL();
      document.body.appendChild(canvas);
  //    window.open(img);
      saveToDisk(img, 'googlemap');
// data is the Base64-encoded image
      }
      });
    }
