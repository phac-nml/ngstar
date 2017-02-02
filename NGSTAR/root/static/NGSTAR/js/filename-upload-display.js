function openFileOption()
{
	document.getElementById("file1").click();
}


//batch add alleles
$('input[name="my_file"]').change(function(){
	var fileName = $(this).val();
	appendToDiv(fileName);
});

//batch add metadata
$('input[name="my_csv"]').change(function(){
	var fileName = $(this).val();
	appendToDiv(fileName);
});

//batch add profiles
$('input[name="profiles"]').change(function(){
	var fileName = $(this).val();
	appendToDiv(fileName);
});

//batch add profiles
$('input[name="batch_metadata_file"]').change(function(){
	var fileName = $(this).val();
	appendToDiv(fileName);
});

//trace file
$('input[name="trace_file"]').change(function(){
	var fileName = $(this).val();
	appendToDiv(fileName);
});

//multifasta query file
$('input[name="multi_fasta_query"]').change(function(){
	var fileName = $(this).val();
	appendToDiv(fileName);
});

//batch profile query
$('input[name="batch_profile_query_file"]').change(function(){
	var fileName = $(this).val();
	appendToDiv(fileName);
});

//batch allele query
$('input[name="batch_fasta_query"]').change(function(){
	var fileName = $(this).val();
	appendToDiv(fileName);
});


function appendToDiv(fileName)
{
	var file_name = fileName.match(/[^\/\\]+$/);

	$('.uploadedFile').html("<strong>"+file_name+"</strong>");
}
