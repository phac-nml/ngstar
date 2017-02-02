if (NGSTAR == null || typeof(NGSTAR) != "object") { var NGSTAR = new Object();}

NGSTAR.load_profile_details = function (base_url) {
    var $profile_id = $('input:radio[name=profile_option]').filter(":checked").val();

    if (typeof $profile_id != 'undefined')
    {
        window.location.href = base_url + "/" + $profile_id;
    }
}

NGSTAR.load_allele_details = function(base_url)
{
    var $allele_info = $('input:radio[name=allele_option]').filter(":checked").val().split(':');
    var $loci_name = $allele_info[0];
    var $allele_type = $allele_info[1];

    window.location.href = base_url + "/" + $loci_name+  "/" + $allele_type;
}

NGSTAR.load_aa_profile_details = function(base_url)
{
    var tmp = $('input:radio[name=aa_profile_option]').filter(":checked").val();
    var tokens = tmp.split(":");
    var $id = tokens[0];

    window.location.href = base_url + "/" + $id;
}

NGSTAR.load_aa_details = function(base_url)
{
    var tmp = $('input:radio[name=aa_option]').filter(":checked").val();
    var tokens = tmp.split(":");
    var $id = tokens[0];

    window.location.href = base_url + "/" + $id;
}
