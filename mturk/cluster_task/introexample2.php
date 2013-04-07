<!-- 

This page presents information about the experiment that will be visible to all Turkers.  You can think of it as a recruitment poster, although it should have more details than that - preferably an example of what the participant will actually be asked to do.  Turkers use this page to evaluate whether or not they want to accept the HIT, and in some HITs they actually see the exact task (not just an example) they will be asked to do.

To modify this file, simply replace [INSERT PAGE HERE] with the first page of your experiment (e.g., "intro.php")
-->

<form id="amt_contform" method="POST" action="[INSERT PAGE HERE]">
	<input type="hidden" id="turkId" name="turkId" value="<?php echo $_REQUEST['workerId'] ?>">	
	<input type="hidden" id="assignmentId" name="assignmentId" value="<?php echo $_REQUEST['assignmentId']  ?>">
	<input id="submitButton" type="submit" name="Begin" value="Begin" 
	<?php 
		if ($_REQUEST['workerId'] == "") {
			echo 'onclick="alert(\'Please accept this HIT before continuing.\'); return false;"';
		}
	?> 
	>
</form>