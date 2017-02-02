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

package BusinessLogic::AddBatchMetadata;
use BusinessLogic::ValidateMetadata;

use 5.014002;
use strict;
use warnings;

use Readonly;

use DAL::Dao;
use DAL::DaoStub;

require Exporter;

our @ISA = qw(Exporter);

# Items to export into callers namespace by default. Note: do not export
# names by default without a very good reason. Use EXPORT_OK instead.
# Do not simply export all your public functions/methods/constants.

# This allows declaration	use BusinessLogic::AddBatchMetadata':all';
# If you do not need this, moving things directly into @EXPORT or @EXPORT_OK
# will save memory.
our %EXPORT_TAGS = ( 'all' => [ qw(

) ] );

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

our @EXPORT = qw(
	_add_batch_metadata
	_add_batch_profile_metadata
);

our $VERSION = '0.01';

Readonly my $INVALID_CONST => "IS_INVALID";
Readonly my $VALID_CONST => "IS_VALID";

Readonly my $INVALID => 0;
Readonly my $VALID => 1;


Readonly my $ALLELE_WITH_TYPE_NOT_EXIST => 1021;
Readonly my $SEQUENCE_WITH_TYPE_NOT_EXIST => 2017;

sub new
{

	my $class = shift;
	my $self = {
		_dao => DAL::Dao->new(),
	};
	bless $self, $class;
	return $self;

}

sub _add_batch_metadata
{

	my ($self, $loci_name, $allele_type, $country, $patient_age, $patient_gender, $epi_data, $curator_comment, $beta_lactamase, $classification_code, $collection_date ,$mics_determined_by, $mic_map, $interpretation_map, $amr_markers) = @_;

	my $result;

	my $obj = BusinessLogic::ValidateMetadata->new();
	my $validation_result = $obj->_validate_batch_metadata(\$country, \$patient_age, \$patient_gender, \$epi_data, \$curator_comment, \$beta_lactamase, \$classification_code, \$mic_map, \$mics_determined_by, \$collection_date, \$interpretation_map);

	if($validation_result eq $VALID_CONST)
	{

		my $metadata = $self->{_dao}->insert_batch_metadata($loci_name, $allele_type, $country, $patient_age, $patient_gender, $epi_data, $curator_comment, $beta_lactamase, $classification_code, $collection_date ,$mics_determined_by, $mic_map, $interpretation_map, $amr_markers);

		if($metadata == $INVALID)
		{

			$result = $ALLELE_WITH_TYPE_NOT_EXIST;

		}
		else
		{

			$result = $VALID_CONST;

		}

	}
	else
	{

		$result = $validation_result;

	}

	return $result;
}

sub _add_batch_profile_metadata
{

	my ($self, $sequence_type, $country, $patient_age, $patient_gender, $epi_data, $curator_comment, $beta_lactamase, $classification_code, $collection_date, $mic_map, $amr_markers) = @_;

	my $result;

	my $obj = BusinessLogic::ValidateMetadata->new();
	my $validation_result = $obj->_validate_batch_profile_metadata(\$country, \$patient_age, \$patient_gender, \$epi_data, \$curator_comment, \$beta_lactamase, \$classification_code, \$mic_map, \$collection_date);

	if($validation_result eq $VALID_CONST)
	{

		my $metadata = $self->{_dao}->insert_batch_profile_metadata($sequence_type, $country, $patient_age, $patient_gender, $epi_data, $curator_comment, $beta_lactamase, $classification_code, $collection_date, $mic_map, $amr_markers);

		if($metadata == $INVALID)
		{

			$result = $SEQUENCE_WITH_TYPE_NOT_EXIST;

		}
		else
		{

			$result = $VALID_CONST;

		}

	}
	else
	{

		$result = $validation_result;

	}

	return $result;
}

1;
__END__
