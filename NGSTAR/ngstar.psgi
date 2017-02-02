use strict;
use warnings;

use lib '/home/irish_m/ng-star/NGSTAR/lib';
use NGSTAR;

my $app = NGSTAR->apply_default_middlewares(NGSTAR->psgi_app);
$app;

