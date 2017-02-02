**Running Unit Tests**

Make sure that you have the following modules from cpan:

	Test::Class
	Test::More

To run unit tests, you must open each file under **ng-star/BusinessLogic/lib/BusinessLogic/**
If you open up each file on an editor you will see the **$TESTING** variable near the beginning of the code:

	my $TESTING = 0;

You must set this variable to **true** for the tests to run properly:

	my $TESTING = 1;

Then, you must install the BusinessLogic module again by changing directory to **ng-star/BusinessLogic** and typing the commands:

	make
	make install 

Run the tests by changing directory to **ng-star/BusinessLogic/t** and running:

	prove test.t

When you are finished running the unit tests, you must change **$TESTING** to **false** again and you must **make** and **make install** the BusinessLogic module again.
