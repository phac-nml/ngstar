use strict;
use warnings;
use Test::More;


use Catalyst::Test 'NGSTAR';
use NGSTAR::Controller::Account;

ok( request('/account')->is_success, 'Request should succeed' );
done_testing();
