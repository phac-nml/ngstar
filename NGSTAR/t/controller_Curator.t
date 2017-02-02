use strict;
use warnings;
use Test::More;


use Catalyst::Test 'NGSTAR';
use NGSTAR::Controller::Curator;

ok( request('/curator')->is_success, 'Request should succeed' );
done_testing();
