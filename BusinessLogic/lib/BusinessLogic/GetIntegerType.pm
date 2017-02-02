# =============================================================================

# Copyright Government of Canada 2014-2017

# Written by: Sukhdeep Sidhu Irish Medina, Public Health Agency of Canada,
#    National Microbiology Laboratory

# Funded by the Genomics Research and Development Initiative

# Licensed under the Apache License, Version 2.0 (the "License"); you may not use
# this file except in compliance with the License. You may obtain a copy of the
# License at:

# http://www.apache.org/licenses/LICENSE-2.0

# Unless required by applicable law or agreed to in writing, software distributed
# under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
# CONDITIONS OF ANY KIND, either express or implied. See the License for the
# specific language governing permissions and limitations under the License.

# =============================================================================

package BusinessLogic::GetIntegerType;


use 5.014002;

use strict;
use warnings;

use Bio::Perl;
use Readonly;

use DAL::Dao;
use DAL::DaoStub;

require Exporter;

our @ISA = qw(Exporter);

# Items to export into callers namespace by default. Note: do not export
# names by default without a very good reason. Use EXPORT_OK instead.
# Do not simply export all your public functions/methods/constants.

# This allows declaration	use BusinessLogic::AddAllele':all';
# If you do not need this, moving things directly into @EXPORT or @EXPORT_OK
# will save memory.
our %EXPORT_TAGS = ( 'all' => [ qw(

) ] );

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

our @EXPORT = qw(
	_get_loci_with_integer_type
);

our $VERSION = '0.01';

Readonly my $INVALID_CONST => "IS_INVALID";
Readonly my $VALID_CONST => "IS_VALID";

sub new
{

	my $class = shift;
	my $self = {
		_dao => DAL::Dao->new(),
	};
	bless $self, $class;
	return $self;

}

sub _get_loci_with_integer_type
{

	my ($self) = @_;

	my %loci_int_type_set;
	my $loci_list = $self->{_dao}->get_all_loci();

	foreach my $loci (@$loci_list)
	{

		if($loci->{is_allele_type_int})
		{

			$loci_int_type_set{$loci->{loci_name}} = undef;

		}

	}

	return \%loci_int_type_set;

}

1;
__END__
