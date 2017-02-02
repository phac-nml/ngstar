use strict;
use warnings;
use Test::More;


use Catalyst::Test 'NGSTAR';
use NGSTAR::Controller::Scheme;

ok( request('/scheme')->is_success, 'Request should succeed' );
done_testing();
