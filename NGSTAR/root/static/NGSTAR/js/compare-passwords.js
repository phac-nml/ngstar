$(document).ready(function() {

    var password_compare = function(){
        var first_password = $('#password_new_user').val();
        var second_password = $('#validate_password').val();


        if (first_password !== second_password){
            $('#comparison_message span').text('Passwords do not match. Please make sure that your passwords match.');
        }
        else{
            $('#comparison_message span').text('');
        }
    }

    $('#password_new_user').keyup(password_compare);
    $('#validate_password').keyup(password_compare);



    var password_update_compare = function(){
        var first_password = $('#new_password').val();
        var second_password = $('#confirm_new_password').val();

        if (first_password != second_password){
            $('#comparison_message span').text('Passwords do not match. Please make sure that your passwords match.');
        }
        else{
            $('#comparison_message span').text('');
        }
    }

    $('#new_password').keyup(password_update_compare);
    $('#confirm_new_password').keyup(password_update_compare);

});
