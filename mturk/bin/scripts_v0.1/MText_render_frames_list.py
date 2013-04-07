#!/usr/bin/python

import sys

base="http://vision-app1.cs.uiuc.edu:8080/frames/";

print "<html>"
print """
<head>
<script src="http://vision-app1.cs.uiuc.edu:8080/code/js/prototype.js"></script>
<style>
table.meta {font-size:10px}
</style>
<script>
function show_image(base,video,image){
	s="<div><img src='"+base+video+"/"+image+".jpg'>";
	adiv_id="attribution_"+video+"_"+image;
	ldiv_id="license_"+video+"_"+image;
	s=s+"<br/><table class='meta'><tr>";
	s=s+"<td>Image by:</td><td><div id='"+adiv_id+"'>(may requre corss-domain js)</div></td>";
	s=s+"<td>Licensed under:</td><td><div id='"+ldiv_id+"'>(may requre corss-domain js)</div></td>";
	s=s+"</tr></table>";
	document.write(s);
	url=base+"metadata/"+video+".attribution";
	var myAjax = new Ajax.Updater(adiv_id, url, {method: 'get'});
	l_url=base+"metadata/"+video+".license";
	var myAjax = new Ajax.Updater(ldiv_id, l_url, {method: 'get'});
}
var myAjax;
function show_attribution(base,video,image){
	adiv_id="attribution_"+video+"_"+image;
	url=base+"metadata/"+video+".attribution";
	myAjax = new Ajax.Updater('abd', url);
}
</script>
</head>
"""
print "<body>"

lines=sys.stdin.readlines();
for f in lines:
	(s,v,i)=f.strip().split("\t")
	print "<script> show_image('%s','%s','%s')</script>" %(base,v,i)
	#id=v+"_"+i;
	#print "<br/>Image by:<iframe height=30 src='%smetadata/%s.attribution'></iframe></div><br/><br/>" % (base,v)

#print "<script> alert(1); </script>"
#for f in lines:
#	(s,v,i)=f.strip().split("\t")
#	print "<script> show_attribution('%s','%s','%s')</script>" %(base,v,i)
print "</body></html>"