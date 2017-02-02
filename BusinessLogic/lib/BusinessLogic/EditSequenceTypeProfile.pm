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

package BusinessLogic::EditSequenceTypeProfile;
use BusinessLogic::ValidateSequenceTypeProfile;
use BusinessLogic::ValidateMetadata;

use 5.014002;
use strict;
use warnings;

use Bio::Seq;
use Bio::SeqIO;
use Bio::SearchIO;

use Readonly;

use DAL::Dao;

require Exporter;

our @ISA = qw(Exporter);

# Items to export into callers namespace by default. Note: do not export
# names by default without a very good reason. Use EXPORT_OK instead.
# Do not simply export all your public functions/methods/constants.

# This allows declaration	use BusinessLogic::EditSequenceTypeProfile':all';
# If you do not need this, moving things directly into @EXPORT or @EXPORT_OK
# will save memory.
our %EXPORT_TAGS = ( 'all' => [ qw(

) ] );

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

our @EXPORT = qw(
	_edit_profile
);

our $VERSION = '0.01';

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

sub _edit_profile
{

	my ($self, $seq_type_prev, $seq_type_new, $profile_map_prev, $profile_map_new, $country, $patient_age, $collection_date, $patient_gender, $epi_data, $curator_comment, $beta_lactamase, $classification_code, $mic_map, $amr_marker_string) = @_;

	my $invalid_code = $INVALID_CONST;
	my $is_valid = $TRUE;
	my $result;

	my $obj = BusinessLogic::ValidateSequenceTypeProfile->new();
	my $validation_result_profile = $obj->_validate_profile($seq_type_new, $profile_map_new, $seq_type_prev, $profile_map_prev);

	$obj = BusinessLogic::ValidateMetadata->new();
	my $validation_result_metadata = $obj->_validate_metadata($country, $patient_age, $patient_gender, $epi_data, $curator_comment, $beta_lactamase, $classification_code, $mic_map, undef, $collection_date, undef, $amr_marker_string);

	if(($validation_result_profile eq $VALID_CONST) and ($validation_result_metadata eq $VALID_CONST))
	{

		if(not $collection_date)
		{
			$collection_date = undef;
		}

		if(not $patient_age)
		{

			$patient_age = 0;

		}

		my $value = $self->{_dao}->edit_profile_with_metadata($seq_type_prev, $seq_type_new, $profile_map_prev, $profile_map_new, $country, $patient_age, $collection_date, $patient_gender, $epi_data, $curator_comment, $beta_lactamase, $classification_code, $mic_map, $amr_marker_string);

		if(not $value)
		{

			$is_valid = $FALSE;

		}

	}
	else
	{

		$is_valid = $FALSE;

		if($validation_result_profile ne $VALID_CONST)
		{

			$invalid_code = $validation_result_profile;

		}

		if($validation_result_metadata ne $VALID_CONST)
		{

			$invalid_code = $validation_result_metadata;

		}

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
