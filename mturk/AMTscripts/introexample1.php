<!-- 
	
This page presents information about the experiment that will be visible to all Turkers.  You can think of it as a recruitment poster, although it should have more details than that - preferably an example of what the participant will actually be asked to do.  Turkers use this page to evaluate whether or not they want to accept the HIT, and in some HITs they actually see the exact task (not just an example) they will be asked to do.
	
There are two ways to make this page work - the first is to pass the worker ID and assignment ID to your website when they click on the link.  You can use that later to verify their submitted HIT and grant them a bonus.

The second is to direct them to a URL that hands them a unique identifier that they put into the form they submit to AMT, which comes back to you in the [yourtask].results file.

-->

<!-- Version 1a -->
To do this HIT, you will need to follow this link to <a href="http://www.myuniversity.edu/labwebpage/experiment/index.php?turk=<?php echo $turker_id?>&assignmentid=<?php echo $assignment_id?>">our research site</a>.

<!-- Version 1b -->
To do this HIT, you will need to log in to <a href="http://www.myuniversity.edu/labwebpage/experiment/">our research site</a>.
After logging in on that site, you will be given a passcode to cut and paste into this form.

<!-- Versions 1a & 1b -->
Once there, you will blah blah blah, and look at images like this one: <img src="fermicode.jpg">.

After reviewing your work, we will approve your HIT and pay you a bonus for all your wonderful work.

If you have any questions contact the researchers at someemail [at] myuniversity [dot] edu.

<form id="mturk_form" method="POST" action="http://www.mturk.com/mturk/externalSubmit">
	<!-- Next line is for Version 1b only -->
	<input type="text" id="userpwd" name="userpwd" maxlength=12>
	<input type="hidden" id="assignmentId" name="assignmentId" value="<?php echo $assignment_id ?>">
	<input id="submitButton" type="submit" name="Begin" value="Begin" 
	<?php 
		if ($_REQUEST['workerId'] == "") {
			echo 'onclick="alert(\'Please accept this HIT before continuing.\'); return false;"';
		}
	?> 
	>
</form>