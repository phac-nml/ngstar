if(typeof $('#batch_allele_err').val() != 'undefined' && $('#batch_allele_err').val() !== "")
{
	var $batch_allele_err_msg = $('#batch_allele_err').val();
	$('#batch-error-modal-body').html("<p>"+$batch_allele_err_msg+"</p>");
	$.magnificPopup.open({
		items: {
			src: $('#batchErrorModal')
		},
		type: 'inline'
	});

}

if(typeof $('#batch_metadata_err').val() != 'undefined' && $('#batch_metadata_err').val() !== "")
{
	var $batch_metadata_err_msg = $('#batch_metadata_err').val();
	$('#batch-error-modal-body').html("<p>"+$batch_metadata_err_msg+"</p>");
	$.magnificPopup.open({
		items: {
			src: $('#batchErrorModal')
		},
		type: 'inline'
	});
}

if(typeof $('#batch_profile_err').val() != 'undefined' && $('#batch_profile_err').val() !== "")
{
	var $batch_profile_err_msg = $('#batch_profile_err').val();
	$('#batch-error-modal-body').html("<p>"+$batch_profile_err_msg+"</p>");
	$.magnificPopup.open({
		items: {
			src: $('#batchErrorModal')
		},
		type: 'inline'
	});
}

if (NGSTAR == null || typeof(NGSTAR) != "object") { var NGSTAR = new Object();}

NGSTAR.deleteAlleleConfirm = function()
{
	var tmp = $('input:radio[name=allele_option]').filter(":checked").val();

	var tokens = tmp.split(":");
	var loci_name = tokens[0];
	var allele_type = tokens[1];

	if($curr_lang == "fr")
	{
		$('#delete-allele-modal-body').html("<p>Êtes-vous sûr(e) de vouloir supprimer cet allèle? Cette action ne peut pas être annulée. <br><br>Nom du locus: "+loci_name+"<br>Type d'allèle: "+allele_type+"</p>");
	}
	else
	{
		$('#delete-allele-modal-body').html("<p>Are you sure you want to delete this allele? This action cannot be undone. <br><br>Loci Name: "+loci_name+"<br>Allele Type: "+allele_type+"</p>");
	}


	$.magnificPopup.open({
		items: {
			src: $('#deleteModal')
		},
		type: 'inline'
	});
}

NGSTAR.deleteAminoAcidProfileConfirm = function()
{
	var $tmp = $('input:radio[name=aa_profile_option]').filter(":checked").val();

	var tokens = $tmp.split(":");
	var onishi_type = tokens[1];


	if($curr_lang == "fr")
	{
		$('#delete-aa-profile-modal-body').html("<p>[Are you sure you want to delete this amino acid profile? This action cannot be undone. <br><br>Onishi Type: "+onishi_type+"]</p>"); //need to get french translation
	}
	else
	{
		$('#delete-aa-profile-modal-body').html("<p>Are you sure you want to delete this amino acid profile? This action cannot be undone. <br><br>Onishi Type: "+onishi_type+"</p>");
	}


	if (typeof onishi_type != 'undefined')
	{
		$.magnificPopup.open({
			items: {
				src: $('#deleteAminoAcidProfileModal')
			},
			type: 'inline'
		});
	}
}

NGSTAR.deleteAminoAcidConfirm = function()
{
	var $aa_info = $('input:radio[name=aa_option]').filter(":checked").val();

	var tokens = $aa_info.split(":");

	var aa_id = tokens[0];
	var aa_char = tokens[1];
	var aa_pos = tokens[2];

	if($curr_lang == "fr")
	{
		$('#delete-aa-modal-body').html("<p>[Are you sure you want to delete this amino acid? This action cannot be undone. <br><br>Amino Acid: "+aa_char+"]<br>Position: "+ aa_pos +"</p>"); //need to get french translation
	}
	else
	{
		$('#delete-aa-modal-body').html("<p>Are you sure you want to delete this amino acid? This action cannot be undone. <br><br>Amino Acid: "+aa_char+"<br>Position: "+ aa_pos +"</p>");
	}


	if (typeof aa_id != 'undefined')
	{
		$.magnificPopup.open({
			items: {
				src: $('#deleteAminoAcidModal')
			},
			type: 'inline'
		});
	}
}


NGSTAR.profileDeleteConfirm = function()
{

	var profile_type = $('input:radio[name=profile_option]').filter(":checked").val();

	if($curr_lang == "fr")
	{
		$('#delete-profile-modal-body').html("<p>Êtes-vous sûr(e) de vouloir supprimer ce profil? Cette action ne peut pas être annulée. <br><br>Type de profil: "+profile_type+"</p>");
	}
	else
	{
		$('#delete-profile-modal-body').html("<p>Are you sure you want to delete this profile? This action cannot be undone. <br><br>Profile Type: "+profile_type+"</p>");
	}

	if (typeof profile_type != 'undefined')
	{
		$.magnificPopup.open({
        	items: {
            	src: $('#deleteProfileModal')
	        },
	        type: 'inline'
	    });
	}

}

NGSTAR.confirmAction = function(base_url, user, msg)
{

	$('#confirm-modal-body').html(msg);

	document.getElementById("confirm-ok").onclick = function(){
		window.location.href = base_url + "/" + user;
	};

	$.magnificPopup.open({
		items: {
			src: $('#confirmModal')
		},
		type: 'inline'
	});


}

NGSTAR.deleteAllele = function(base_url)
{
	var tmp = $('input:radio[name=allele_option]').filter(":checked").val();

	var tokens = tmp.split(":");
	var loci_name = tokens[0];
	var allele_type = tokens[1];
	window.location.href = base_url + "/" + loci_name + "/" + allele_type;

}

NGSTAR.deleteProfile = function(base_url)
{

	var profile_type = $('input:radio[name=profile_option]').filter(":checked").val();

	if (typeof profile_type != 'undefined')
    {
		window.location.href = base_url + "/" + profile_type;
	}


}

NGSTAR.deleteAAProfile = function(base_url)
{

	var tmp = $('input:radio[name=aa_profile_option]').filter(":checked").val();

	var tokens = tmp.split(":");
	var id = tokens[0];

	if (typeof id != 'undefined')
    {
		window.location.href = base_url + "/" + id;
	}


}

NGSTAR.deleteAA = function(base_url)
{

	var $aa_info = $('input:radio[name=aa_option]').filter(":checked").val();
	var tokens = $aa_info.split(":");

	var aa_id = tokens[0];
	var aa_char = tokens[1];
	var aa_pos = tokens[2];

	if (typeof aa_id != 'undefined')
    {
		window.location.href = base_url + "/" + aa_id;
	}


}



function check_name(name)
{
	var $result = false;

	if (name.search(/^[a-zA-Z\s]*$/) !== -1) {
  		$result = true;
	}
	return $result;

}

function check_email_address(email_address)
{
	var $result = false;

	if (email_address.search(/^(\w|\-|\_|\.)+\@((\w|\-|\_)+\.)+[a-zA-Z]{2,}$/) !== -1) {
		$result = true;
	}
	return $result;

}
