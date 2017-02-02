package NGSTAR::Model::BatchSequenceTypeQuery;
use strict;
use warnings;
use base 'Catalyst::Model::Adaptor';

__PACKAGE__->config(
	class       => 'BusinessLogic::BatchSequenceTypeQuery',
	constructor => 'new',
);

1;
