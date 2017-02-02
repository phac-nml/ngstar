$(document).ready(function(){

	var $lang_code ="";

	if($curr_lang == "fr")
	{
		$lang_code="fr";
	}

	$( "#datepicker" ).datetimepicker({

			format: 'yyyy-mm-dd',minView: 'month', autoclose: true, startDate : new Date('1950-01-01') ,endDate : new Date(), language: $lang_code

		}).on('change', function ()
		{

			/* If a date greater than today's date or less than 1950-01-01
			  is entered the date is removed from the datepicker input box */

			var start_date = new Date('1950-01-01');
			var start_year = start_date.getFullYear();

			var curr_date= new Date();
			var curr_year = curr_date.getFullYear();
			var curr_month = curr_date.getMonth() + 1;
			var curr_day = curr_date.getDate();

			var tokens = $("#datepicker").val().split("-");
			var entered_year = tokens[0];
			var entered_month = tokens[1];
			var entered_day = tokens[2];


			if(entered_year >= curr_year)
			{

				if(entered_year > curr_year)
				{
					document.getElementById("datepicker").value = '';
				}
				else
				{

					if(entered_year == curr_year)
					{

						if(entered_month > curr_month)
						{

							document.getElementById("datepicker").value = '';
						}
						else
						{
							if(entered_month == curr_month)
							{

								if(entered_day > curr_day)
								{
									document.getElementById("datepicker").value = '';
								}
							}

						}

					}
				}

			}
			else
			{

				if(entered_year <= start_year)
				{
					document.getElementById("datepicker").value = '';
				}

			}

		});

});
