use strict;
use warnings;
use Test::More;


use Catalyst::Test 'NGSTAR';
use NGSTAR::Controller::ResetPassword;

ok( request('/resetpassword')->is_success, 'Request should succeed' );
done_testing();
