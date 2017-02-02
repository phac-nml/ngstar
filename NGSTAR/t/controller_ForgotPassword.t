use strict;
use warnings;
use Test::More;


use Catalyst::Test 'NGSTAR';
use NGSTAR::Controller::ForgotPassword;

ok( request('/forgotpassword')->is_success, 'Request should succeed' );
done_testing();
