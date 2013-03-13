// Populate the set of patches. Currently uses dummy source
// TODO: update with real patches
// patches is an m x n array
// cluster is a 1D list of row,col indices (into patches)

var baseurl = "http://graphics.cs.cmu.edu/projects/whatMakesParis/result/alldiscpatchimg[]/";
index1 = 41;
indexn = 56;
row_width = 4;
num_rows = (indexn - index1 + 1) / row_width;

patches = []
cluster_patches = [];

var curr_img = index1;
for (var i = 0; i < num_rows; i++) {
    row = []
    for (var j = 0; j < row_width; j++) {
        if (curr_img <= indexn) {
            row.push(baseurl + curr_img + '.jpg');
            curr_img++;
        }
    }
    patches.push(row);
}

$(document).ready(function() {
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

    $("#submit").click(function () {
        rs = []
        for (var i = 0; i < cluster_patches.length; i++) { rs.push('(' + cluster_patches[i] + ')'); }
        $("#result").text(rs); 
    });
});

function addToCluster(obj) {
    var coords = $(obj).attr('id').split(',');
    var i = parseInt(coords[1]), j = parseInt(coords[2]);

    $(document.getElementById('gallery,'+i+','+j)).css('visibility','hidden');
    cluster_patches.push([i,j]);
    
    reflow();

    return false;
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

    return false;
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
    /*
    for (var index = 0; index < cluster_patches.length; index++) {
        i = cluster_patches[index][0], j = cluster_patches[index][1];

        cluster.append('<li id="cluster,' + i + ',' + j + '" class="image-patch">'
            + '<img src="' + patches[i][j] + '" width="80" height="80" /> </li>');
    }
*/
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
        $("#submit").css('visibility', 'visible');
    } else {
        $("#submit").css('visibility', 'hidden');        
    }
}

function reflowCluster(startingIndex) {
    cluster_patch_coords = [];
    $.each(cluster_patches, function(coord, index) {
        if (startingIndex != -1 && index > startingIndex) {
            cluster_patches[coord]--;
        }
        cluster_patch_coords[cluster_patches[coord]] = coord;
    });

    cluster_rows = cluster_count / row_width;
    cluster_cols = cluster_count % row_width;
    for (var i = 0; i < cluster_rows; i++) {
        cluster_row = $('#clusterrow' + i).empty();
        for (var j = 0; j < cluster_cols; j++) {
            gallery_coords = cluster_patch_coords[i*row_width + j].split(',');
            ci = gallery_coords[0];
            cj = gallery_coords[1];
            cluster_row.append('<li id="cluster,'+ci+','+cj+'" class="image-patch"><img src="' + patches[ci][cj] + '" width="80" height="80" /> </li>');
            
            $(document.getElementById('cluster,'+ci+','+cj)).click(function() {
                var id = $(this).attr('id');
                coords = id.split(',');
                removeFromCluster(parseInt(coords[1]), parseInt(coords[2]));
            });

            $('#cluster img').mouseenter(function() {
                $(this).addClass('patch-hover');
            }).mouseleave(function() {
                $(this).removeClass('patch-hover');
            });
        }
    }
}