<!-- The "$assignment_id" variable needs to contain the user's assignment ID (given when they accept the HIT) in order for the user to be allowed to submit this HIT successfully -->

<?php $assignment_id = $_REQUEST['assignmentId']?>

<form id="mturk_form" method="POST" action="http://www.mturk.com/mturk/externalSubmit">
	<input type="hidden" id="assignmentId" name="assignmentId" value="<?php echo $assignment_id ?>">
	<input id="submitButton" type="submit" name="Submit" value="Complete HIT">
</form>