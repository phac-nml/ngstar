//functions to clear forms

function clearAlleleQueryForm()
{
	document.getElementById("seq0").value = '';
	document.getElementById("seq1").value = '';
	document.getElementById("seq2").value = '';
	document.getElementById("seq3").value = '';
	document.getElementById("seq4").value = '';
	document.getElementById("seq5").value = '';
	document.getElementById("seq6").value = '';

	removeFormErrors();
}

function clearProfileQueryForm()
{
	document.getElementById("allele_type0").value = '';
	document.getElementById("allele_type1").value = '';
	document.getElementById("allele_type2").value = '';
	document.getElementById("allele_type3").value = '';
	document.getElementById("allele_type4").value = '';
	document.getElementById("allele_type5").value = '';
	document.getElementById("allele_type6").value = '';

	removeFormErrors();
}

function clearAddAlleleForm()
{
	document.getElementById("allele_type").value = '';
	document.getElementById("allele_sequence").value = '';
	document.getElementById("country").value = '';
	document.getElementById("patient_age").value = '';
	document.getElementById("epi_data").value = '';
	document.getElementById("curator_comment").value = '';
	document.getElementById("datepicker").value='';

	document.getElementById("Azithromycin").value = '';
	document.getElementById("Cefixime").value = '';
	document.getElementById("Ceftriaxone").value = '';
	document.getElementById("Ciprofloxacin").value = '';
	document.getElementById("Erythromycin").value = '';
	document.getElementById("Penicillin").value = '';
	document.getElementById("Spectinomycin").value = '';
	document.getElementById("Tetracycline").value = '';

	removeFormErrors();
}

function clearAddProfileForm()
{

	document.getElementById("sequence_type").value = '';

	document.getElementById("allele_type0").value = '';
	document.getElementById("allele_type1").value = '';
	document.getElementById("allele_type2").value = '';
	document.getElementById("allele_type3").value = '';
	document.getElementById("allele_type4").value = '';
	document.getElementById("allele_type5").value = '';
	document.getElementById("allele_type6").value = '';

	document.getElementById("country").value = '';
	document.getElementById("patient_age").value = '';
	document.getElementById("epi_data").value = '';
	document.getElementById("curator_comment").value = '';
	document.getElementById("datepicker").value='';


	document.getElementById("Azithromycin").value = '';
	document.getElementById("Cefixime").value = '';
	document.getElementById("Ceftriaxone").value = '';
	document.getElementById("Ciprofloxacin").value = '';
	document.getElementById("Erythromycin").value = '';
	document.getElementById("Penicillin").value = '';
	document.getElementById("Spectinomycin").value = '';
	document.getElementById("Tetracycline").value = '';

	removeFormErrors();
}

function clearBatchAddAlleleForm()
{
	document.getElementById("fasta_sequences").value='';

}

function clearBatchAddMetadataForm()
{
	document.getElementById("csv_metadata").value='';

}

function clearBatchAddProfileMetadataForm()
{
	document.getElementById("batch_metadata").value='';

}

function clearBatchAddProfileForm()
{
	document.getElementById("profiles").value='';
}

function clearEmailAlleleForm()
{
	document.getElementById("first_name").value = '';
	document.getElementById("last_name").value = '';
	document.getElementById("email_address").value = '';
	document.getElementById("institution_name").value = '';
	document.getElementById("institution_city").value = '';
	document.getElementById("institution_country").value = '';
	document.getElementById("allele_sequence").value = '';
	document.getElementById("country").value = '';
	document.getElementById("patient_age").value = '';
	document.getElementById("epi_data").value = '';
	document.getElementById("comments").value = '';
	document.getElementById("datepicker").value='';


	document.getElementById("Azithromycin").value = '';
	document.getElementById("Cefixime").value = '';
	document.getElementById("Ceftriaxone").value = '';
	document.getElementById("Ciprofloxacin").value = '';
	document.getElementById("Erythromycin").value = '';
	document.getElementById("Penicillin").value = '';
	document.getElementById("Spectinomycin").value = '';
	document.getElementById("Tetracycline").value = '';

	removeFormErrors();
}

function clearEmailProfileForm()
{
	document.getElementById("first_name").value = '';
	document.getElementById("last_name").value = '';
	document.getElementById("email_address").value = '';
	document.getElementById("institution_name").value = '';
	document.getElementById("institution_city").value = '';
	document.getElementById("institution_country").value = '';
	document.getElementById("allele_type0").value = '';
	document.getElementById("allele_type1").value = '';
	document.getElementById("allele_type2").value = '';
	document.getElementById("allele_type3").value = '';
	document.getElementById("allele_type4").value = '';
	document.getElementById("allele_type5").value = '';
	document.getElementById("allele_type6").value = '';
	document.getElementById("country").value = '';
	document.getElementById("patient_age").value = '';
	document.getElementById("epi_data").value = '';
	document.getElementById("comments").value = '';
	document.getElementById("datepicker").value='';


	document.getElementById("Azithromycin").value = '';
	document.getElementById("Cefixime").value = '';
	document.getElementById("Ceftriaxone").value = '';
	document.getElementById("Ciprofloxacin").value = '';
	document.getElementById("Erythromycin").value = '';
	document.getElementById("Penicillin").value = '';
	document.getElementById("Spectinomycin").value = '';
	document.getElementById("Tetracycline").value = '';

	removeFormErrors();
}

function clearBatchProfileQueryForm()
{
	document.getElementById("batch_profile_query").value = '';

	removeFormErrors();

}

function clearBatchAlleleQueryForm()
{
	document.getElementById("batch_fasta_sequences").value = '';

	removeFormErrors();

}


function clearAddSchemeForm()
{
	document.getElementById("scheme_name").value='';
}

function removeFormErrors()
{
	$('.form-group').removeClass('has-error has-feedback');
	$('.help-block').remove();
}
