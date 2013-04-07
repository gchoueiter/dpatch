// Populate the set of patches. Currently uses dummy source
// TODO: update with real patches
// patches is an m x n array
// cluster is a 1D list of row,col indices (into patches)

// Just need to change this so that the get request sets the correct path
//"http://graphics.cs.cmu.edu/projects/whatMakesParis/result/alldiscpatchimg[]/";
var baseurl = "http://cs.brown.edu/~gen/nn_patches/MITinsidecity/cluster_imgs/cluster1/"; 
index1 = 1;
indexn = 23733;
num_patches = 25;
row_width = 5;
num_rows = num_patches / row_width;

patches = []
cluster_patches = [];

var index = 1;
for (var i = 0; i < num_rows; i++) {
    row = []
    for (var j = 0; j < row_width; j++) {
        if (index <= num_patches) {
            // random
            var patch_num = index;//Math.floor(Math.random() * (indexn - index1 + 1)) + index1;
            row.push(baseurl + patch_num + '.jpg');
            index++;
        }
    }
    patches.push(row);
}

$(document).ready(function() {
    $("#cluster").css('min-height', 90 * num_rows + 95).css('min-width', 90 * row_width + 30);
    $("#gallery").css('min-height', 90 * num_rows + 95).css('min-width', 90 * row_width + 30);

    var gallery = $("#gallery-container");
    for (var i = 0; i < patches.length; i++) {
        gallery.append('<ul id="row' + i + '" class="patch-row"> </ul>');
        for (var j = 0; j < patches[i].length; j++) {
            $('#row' + i).append('<li id="gallery,' + i + ','+ j + '" class="image-patch"><img src="' + patches[i][j] + '" width="80" height="80" /> </li>');
        }
    }

    $('.image-patch img').mouseenter(function() {
        $(this).addClass('patch-hover');
    }).mouseleave(function() {
        $(this).removeClass('patch-hover');
    });

    $( ".image-patch").draggable({
        revert: "invalid",
        containment: "document",
        helper: "original",
        distance: 5,
        opacity: .9
    });

    $("#cluster").droppable({
        accept: "#gallery .image-patch",
        activeClass: "ui-state-highlight",
        drop: function( event, ui ) {
            addToCluster( ui.draggable );
        }
    });

    $('.image-patch').click(function() {
        addToCluster(this);
    });

    $("#clear").click(function() {
        $("#result").empty();
        $("#cluster .image-patch").each(function() {
            removeFromCluster(this);
        });
    });
    $("#submit").click(function () {
        $("#result").empty().append("<h4>Result</h4>");
        for (var index = 0; index < cluster_patches.length; index++) {
            var i = cluster_patches[index][0], j = cluster_patches[index][1];
            $("#result").append('<img src="' + patches[i][j] + '" width="50" height="50" style="padding-right: 5px;"/>'); 
        }
    });
});

function addToCluster(obj) {
    var coords = $(obj).attr('id').split(',');
    var i = parseInt(coords[1]), j = parseInt(coords[2]);

    $(document.getElementById('gallery,'+i+','+j)).css('visibility','hidden');
    cluster_patches.push([i,j]);
    
    reflow();
}

function removeFromCluster(obj) {
    var coords = $(obj).attr('id').split(',');
    var i = parseInt(coords[1]), j = parseInt(coords[2]);

    $(document.getElementById('gallery,'+i+','+j)).css('visibility','visible').css('top', 'auto').css('left', 'auto');
    for (var index = 0; index < cluster_patches.length; index++) {
        if (cluster_patches[index][0] == i && cluster_patches[index][1] == j) {
            cluster_patches.splice(index, 1);
        }
    }
    
    reflow();
}

function reflow() {
    var cluster = $('#cluster-container');
    cluster.empty();

    var cluster_rows = cluster_patches.length / row_width;
    var index = 0;
    for (var i = 0; i < cluster_rows; i++) {
        var cluster_row = cluster.append('<ul id="clusterrow' + i + '" class="patch-row"> </ul>');
        for (var j = 0; j < row_width; j++) {
            if (index < cluster_patches.length) {
                var pi = cluster_patches[index][0], pj = cluster_patches[index][1];
                cluster_row.append('<li id="cluster,'+pi+','+pj+'" class="image-patch"><img src="' + patches[pi][pj] + '" width="80" height="80" /> </li>');            
            }
            index++;
        }
    }

    $('#cluster img').mouseenter(function() {
        $(this).addClass('patch-hover');
    }).mouseleave(function() {
        $(this).removeClass('patch-hover');
    });

    $( "#cluster .image-patch").draggable({
        revert: "invalid",
        containment: "document",
        helper: "original",
        distance: 5,
        opacity: .9
    });

    $("#gallery").droppable({
        accept: "#cluster .image-patch",
        activeClass: "ui-state-highlight",
        drop: function( event, ui ) {
            removeFromCluster( ui.draggable );
        }
    });

    $('#cluster .image-patch').click(function() {
        removeFromCluster(this);
    });

    if (cluster_patches.length >= 5) {
        $("#submit").removeAttr('disabled');
    } else {
        $("#submit").attr('disabled', 'disabled');        
    }
}
