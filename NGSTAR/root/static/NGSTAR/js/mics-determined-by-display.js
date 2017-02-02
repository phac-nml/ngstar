$(document).ready(function(){

    var $mics_determination = $("input[name='mics_determined_by_option']:checked").val();


    if ($mics_determination == 'E-Test' || $mics_determination == 'Agar Dilution') {
        $('.mics_div').show();
        $('.disc_div').hide();
    }
    else if($mics_determination == 'Disc Diffusion') {
        $('.mics_div').hide();
        $('.disc_div').show();
    }
    else {
            $('.mics_div').hide();
            $('.disc_div').hide();
    }


    $("input[name='mics_determined_by_option']").click(function() {

        var $mics_determinations = $(this).val();

        if ($mics_determinations == 'E-Test' || $mics_determinations == 'Agar Dilution') {
            $('.mics_div').show();
            $('.disc_div').hide();
        }
        else if($mics_determinations == 'Disc Diffusion') {
            $('.mics_div').hide();
            $('.disc_div').show();
        }
        else {
                $('.mics_div').hide();
                $('.disc_div').hide();
        }

    });

});
