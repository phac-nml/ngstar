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

package BusinessLogic::ValidateEmailForm;
use BusinessLogic::ValidateAllele;
use BusinessLogic::ValidateMetadata;

use 5.014002;
use strict;
use warnings;

use Readonly;

require Exporter;

our @ISA = qw(Exporter);

# Items to export into callers namespace by default. Note: do not export
# names by default without a very good reason. Use EXPORT_OK instead.
# Do not simply export all your public functions/methods/constants.

# This allows declaration	use BusinessLogic::ValidateEmailForm':all';
# If you do not need this, moving things directly into @EXPORT or @EXPORT_OK
# will save memory.
our %EXPORT_TAGS = ( 'all' => [ qw(

) ] );

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

our @EXPORT = qw(
	_validate_email_form
	_validate_new_profile_email_form
);

our $VERSION = '0.01';

Readonly my $TESTING => 0;

Readonly my $FALSE => 0;
Readonly my $TRUE => 1;

Readonly my $INVALID_CONST => "IS_INVALID";
Readonly my $VALID_CONST => "IS_VALID";

Readonly my $ERROR_INVALID_LOCI_NAME => 1005;
Readonly my $ERROR_INVALID_ALLELE_SEQUENCE => 1017;

Readonly my $ERROR_INVALID_ALLELE_TYPES => 3016;

Readonly my $ERROR_INVALID_EMAIL_ADDRESS => 4000;
Readonly my $ERROR_FNAME_INVALID_CHARACTERS => 4028;
Readonly my $ERROR_LNAME_INVALID_CHARACTERS => 4029;
Readonly my $ERROR_INS_NAME => 4034;
Readonly my $ERROR_INS_CITY => 4035;
Readonly my $ERROR_INS_COUNTRY => 4036;


sub new
{

	my $class = shift;
	my $self = {
		_dao => DAL::Dao->new(),
	};
	bless $self, $class;
	return $self;

}

sub _validate_new_profile_email_form
{

	my ($self, $first_name, $last_name, $email_address, $institution_name, $institution_country, $institution_city, $comments, $allele_types, $country, $patient_age, $patient_gender, $epi_data, $beta_lactamase, $classification_code, $mic_map, $collection_date) = @_;

	my $obj = BusinessLogic::GetAlleleInfo->new();
	my $loci_name_list = $obj->_get_all_loci_names();

	$obj = BusinessLogic::ValidateAllele->new();

	my $invalid_count = 0;
	my $is_valid = $TRUE;
	my $invalid_code = $INVALID_CONST;
	my $result;
	my $validate_result;
	my $count = 0;


	if($first_name !~  /^[A-Z\s\-]+$/i)
	{

		$is_valid = $FALSE;
		$invalid_code = $ERROR_FNAME_INVALID_CHARACTERS;

	}

	if($is_valid)
	{

	  if($last_name !~  /^[A-Z\s\-\']+$/i)
	  {

		  $is_valid = $FALSE;
		  $invalid_code = $ERROR_LNAME_INVALID_CHARACTERS;

	  }

	}

	if($is_valid)
	{

	  if($email_address !~  /^[\w\-\.]+@([\w\-]+\.)+[A-Z]{2,}$/i)
	  {

		$is_valid = $FALSE;
		$invalid_code = $ERROR_INVALID_EMAIL_ADDRESS;

	  }

	}

	if($is_valid)
	{

		if($institution_name !~ /^[A-Z\s\-\']+$/i)
		{

			$is_valid = $FALSE;
			$invalid_code = $ERROR_INS_NAME;
		}

	}

	if($is_valid)
	{

		if($institution_city !~ /^[A-Z\s\-\']+$/i)
		{

			$is_valid = $FALSE;
			$invalid_code = $ERROR_INS_CITY;
		}

	}

	if($is_valid)
	{

		if($institution_country !~ /^[A-Z\s\-\']+$/i)
		{

			$is_valid = $FALSE;
			$invalid_code = $ERROR_INS_COUNTRY;
		}

	}


	if($is_valid)
	{

		foreach my $loci_name (@$loci_name_list)
		{

			$validate_result = $obj->_check_allele_type(@$allele_types[$count], $loci_name);

			if($validate_result eq $INVALID_CONST)
			{

				$is_valid = $FALSE;
				$invalid_code = $ERROR_INVALID_ALLELE_TYPES;

			}

			$count ++;

		}

	}


	if($is_valid)
	{

		$obj = BusinessLogic::ValidateMetadata->new();
		$validate_result = $obj->_validate_profile_metadata($country, $patient_age, $patient_gender, $epi_data, $comments, $beta_lactamase, $classification_code, $mic_map, $collection_date);

		if($validate_result ne $VALID_CONST)
		{

			$is_valid = $FALSE;
			$invalid_code = $validate_result;

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

sub _validate_email_form
{

	my ($self, $first_name, $last_name, $email_address, $institution_name, $institution_country, $institution_city, $comments, $loci_name, $allele_sequence, $country, $patient_age, $patient_gender, $epi_data, $beta_lactamase, $classification_code, $mic_map, $mics_determined_by, $collection_date, $interpretation_map) = @_;

	my $is_valid = $TRUE;
	my $invalid_code = $INVALID_CONST;
	my $result;

	if($first_name !~  /^[A-Z\s\-]+$/i)
	{

		$is_valid = $FALSE;
		$invalid_code = $ERROR_FNAME_INVALID_CHARACTERS;

	}

	if($is_valid)
	{

	  if($last_name !~  /^[A-Z\s\-\']+$/i)
	  {

		  $is_valid = $FALSE;
		  $invalid_code = $ERROR_LNAME_INVALID_CHARACTERS;

	  }

	}

	if($is_valid)
	{

	  if($email_address !~  /^[\w\-\.]+@([\w\-]+\.)+[A-Z]{2,}$/i)
	  {

		$is_valid = $FALSE;
		$invalid_code = $ERROR_INVALID_EMAIL_ADDRESS;

	  }

	}

	if($is_valid)
	{

		if($institution_name !~ /^[A-Z\s\-\']+$/i)
		{

			$is_valid = $FALSE;
			$invalid_code = $ERROR_INS_NAME;
		}

	}

	if($is_valid)
	{

		if($institution_city !~ /^[A-Z\s\-\']+$/i)
		{

			$is_valid = $FALSE;
			$invalid_code = $ERROR_INS_CITY;
		}

	}

	if($is_valid)
	{

		if($institution_country !~ /^[A-Z\s\-\']+$/i)
		{

			$is_valid = $FALSE;
			$invalid_code = $ERROR_INS_COUNTRY;
		}

	}


	my $obj;
	my $validate_result;

	if($is_valid)
	{

		$obj = BusinessLogic::ValidateAllele->new();
		$validate_result = $obj->_check_loci_name($loci_name);

		if(not $validate_result)
		{

			$is_valid = $FALSE;
			$invalid_code = $ERROR_INVALID_LOCI_NAME;

		}

		$validate_result = $obj->_check_sequence($allele_sequence);

		if(not $validate_result)
		{

			$is_valid = $FALSE;
			$invalid_code = $ERROR_INVALID_ALLELE_SEQUENCE;

		}

	}

	if($is_valid)
	{

		$obj = BusinessLogic::ValidateMetadata->new();
		$validate_result = $obj->_validate_metadata($country, $patient_age, $patient_gender, $epi_data, $comments, $beta_lactamase, $classification_code, $mic_map, $mics_determined_by, $collection_date, $interpretation_map);

		if($validate_result ne $VALID_CONST)
		{

			$is_valid = $FALSE;
			$invalid_code = $validate_result;
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
