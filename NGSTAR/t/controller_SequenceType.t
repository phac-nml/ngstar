use strict;
use warnings;
use Test::More;


use Catalyst::Test 'NGSTAR';
use NGSTAR::Controller::SequenceType;

ok( request('/sequencetype')->is_success, 'Request should succeed' );
done_testing();
