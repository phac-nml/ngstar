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

package BusinessLogic::EditAllele;
use BusinessLogic::ValidateAllele;
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

# This allows declaration	use BusinessLogic::EditAllele':all';
# If you do not need this, moving things directly into @EXPORT or @EXPORT_OK
# will save memory.
our %EXPORT_TAGS = ( 'all' => [ qw(

) ] );

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

our @EXPORT = qw(
	_edit_allele
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

sub _edit_allele
{

	my ($self, $loci_name_new, $allele_type_new, $sequence, $loci_name_prev, $allele_type_prev, $country, $patient_age, $patient_gender, $epi_data, $curator_comment, $beta_lactamase, $classification_code, $mic_map, $mics_determined_by, $collection_date, $interpretation_map, $amr_marker_string) = @_;

	my $invalid_code = $INVALID_CONST;
	my $is_valid = $TRUE;
	my $result;

	my $obj = BusinessLogic::ValidateAllele->new();
	my $validation_result_allele = $obj->_validate_allele($loci_name_new, $allele_type_new, $sequence, $loci_name_prev, $allele_type_prev);

	$obj = BusinessLogic::ValidateMetadata->new();
	my $validation_result_metadata = $obj->_validate_metadata($country, $patient_age, $patient_gender, $epi_data, $curator_comment, $beta_lactamase, $classification_code, $mic_map, $mics_determined_by,$collection_date, $interpretation_map, $amr_marker_string);

	if(($validation_result_allele eq $VALID_CONST) and ($validation_result_metadata eq $VALID_CONST))
	{

		if(not $collection_date)
		{
			$collection_date = undef;
		}

		if(not $patient_age)
		{

			$patient_age = 0;

		}

		my $value = $self->{_dao}->edit_allele_with_metadata($loci_name_prev, $allele_type_prev, $loci_name_new, $allele_type_new, $sequence, $country, $patient_age, $patient_gender, $epi_data, $curator_comment, $beta_lactamase, $classification_code, $mic_map, $mics_determined_by, $collection_date, $interpretation_map, $amr_marker_string);

		if(not $value)
		{

			$is_valid = $FALSE;

		}

	}
	else
	{

		$is_valid = $FALSE;

		if($validation_result_allele ne $VALID_CONST)
		{

			$invalid_code = $validation_result_allele;

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
