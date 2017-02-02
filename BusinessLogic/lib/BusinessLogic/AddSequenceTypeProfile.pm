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

package BusinessLogic::AddSequenceTypeProfile;
use BusinessLogic::ValidateSequenceTypeProfile;

use 5.014002;
use strict;
use warnings;

use Readonly;

use DAL::Dao;

require Exporter;

our @ISA = qw(Exporter);

# Items to export into callers namespace by default. Note: do not export
# names by default without a very good reason. Use EXPORT_OK instead.
# Do not simply export all your public functions/methods/constants.

# This allows declaration	use BusinessLogic::AddSequenceTypeProfile':all';
# If you do not need this, moving things directly into @EXPORT or @EXPORT_OK
# will save memory.
our %EXPORT_TAGS = ( 'all' => [ qw(

) ] );

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

our @EXPORT = qw(
	_add_sequence_type_profile
);

our $VERSION = '0.01';

Readonly my $TESTING => 0;

Readonly my $FALSE => 0;
Readonly my $TRUE => 1;

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

sub _add_sequence_type_profile
{

	my ($self, $sequence_type, $profile_map, $country, $patient_age, $collection_date, $patient_gender, $epi_data, $curator_comment, $beta_lactamase, $classification_code, $mic_map, $amr_marker_string) = @_;

	my $invalid_code = $INVALID_CONST;
	my $is_valid = $TRUE;
	my $result;

	my $obj = BusinessLogic::ValidateSequenceTypeProfile->new();
	my $validation_result = $obj->_validate_profile($sequence_type, $profile_map);

	$obj = BusinessLogic::ValidateMetadata->new();
	my $validation_result_metadata = $obj->_validate_metadata($country, $patient_age, $patient_gender, $epi_data, $curator_comment, $beta_lactamase, $classification_code, $mic_map, undef, $collection_date,undef, $amr_marker_string);


	if(($validation_result eq $VALID_CONST) and ($validation_result_metadata eq $VALID_CONST))
	{
		if(not $collection_date)
		{
			$collection_date = undef;
		}

		if(not $patient_age)
		{

			$patient_age = 0;

		}

		my $value = $self->{_dao}->insert_sequence_type_profile_with_metadata($sequence_type, $profile_map, $country, $patient_age, $collection_date, $patient_gender, $epi_data, $curator_comment, $beta_lactamase, $classification_code, $mic_map, $amr_marker_string);

		if(not defined $value)
		{

			$is_valid = $FALSE;

		}

	}
	else
	{

		$is_valid = $FALSE;
		$invalid_code = $validation_result;

	}
	if($is_valid)
	{

		$result = $VALID_CONST;

	}
	else
	{

		$result = $invalid_code;

	}

	return $result;
}

1;
__END__
