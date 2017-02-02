use strict;
use warnings;
use Test::More;


use Catalyst::Test 'NGSTAR';
use NGSTAR::Controller::ProjectInfo;

ok( request('/projectinfo')->is_success, 'Request should succeed' );
done_testing();
