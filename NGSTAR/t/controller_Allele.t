use strict;
use warnings;
use Test::More;


use Catalyst::Test 'NGSTAR';
use NGSTAR::Controller::Allele;

ok( request('/allele')->is_success, 'Request should succeed' );
done_testing();
