window.onunload = function(){};
$('#loci_to_view_option').val('');

$('#loci_to_view_option').change(function()
{
	 	if($('#loci_to_view_option').val() != "")
		{

			$('#view_loci_alleles').append('<input type="hidden" name="option" value="view"></input>');
			$('#view_loci_alleles').submit();
			//test comment
		}
});
