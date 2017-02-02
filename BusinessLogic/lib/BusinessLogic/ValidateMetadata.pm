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

package BusinessLogic::ValidateMetadata;

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

# This allows declaration	use BusinessLogic::ValidateMetadata':all';
# If you do not need this, moving things directly into @EXPORT or @EXPORT_OK
# will save memory.
our %EXPORT_TAGS = ( 'all' => [ qw(

) ] );

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

our @EXPORT = qw(
	_validate_batch_metadata
	_validate_batch_profile_metadata
	_validate_metadata
	_validate_profile_metadata
);

our $VERSION = '0.01';

Readonly my $TESTING => 0;

Readonly my $FALSE => 0;
Readonly my $TRUE => 1;

Readonly my $INVALID_CONST => "IS_INVALID";
Readonly my $VALID_CONST => "IS_VALID";

Readonly my $MIN_PATIENT_AGE => 0;
Readonly my $MAX_PATIENT_AGE => 100;

Readonly my $PATIENT_GENDER_FEMALE => 'F';
Readonly my $PATIENT_GENDER_MALE => 'M';
Readonly my $PATIENT_GENDER_UNKNOWN => 'U';

Readonly my $PATIENT_GENDER_FEMALE_FULL => 'Female';
Readonly my $PATIENT_GENDER_MALE_FULL => 'Male';
Readonly my $PATIENT_GENDER_UNKNOWN_FULL => 'Unknown';

Readonly my $BETA_LACTAMASE_NEGATIVE => "Negative";
Readonly my $BETA_LACTAMASE_POSITIVE => "Positive";
Readonly my $BETA_LACTAMASE_UNKNOWN => "Unknown";

Readonly my $MIC_COMPARATOR_EQUALS => "=";
Readonly my $MIC_COMPARATOR_LESS_THAN_OR_EQUALS => "le";
Readonly my $MIC_COMPARATOR_GREATER_THAN_OR_EQUALS => "ge";
Readonly my $MIC_COMPARATOR_LESS_THAN => "lt";
Readonly my $MIC_COMPARATOR_GREATER_THAN => "gt";

Readonly my $INTERPRETATION_INTERMEDIATE => "Intermediate";
Readonly my $INTERPRETATION_RESISTANT => "Resistant";
Readonly my $INTERPRETATION_SUSCEPTIBLE => "Susceptible";
Readonly my $INTERPRETATION_UNKNOWN => "Unknown";


Readonly my $ERROR_INVALID_COLLECTION_DATE => 3000;
Readonly my $ERROR_INVALID_CLASSIFICATION_CODE => 3004;
Readonly my $ERROR_INVALID_COUNTRY => 3005;
Readonly my $ERROR_INVALID_CITY => 3006;
Readonly my $ERROR_INVALID_PATIENT_AGE => 3007;
Readonly my $ERROR_INVALID_PATIENT_GENDER => 3008;
Readonly my $ERROR_INVALID_EPI_DATA => 3009;
Readonly my $ERROR_INVALID_COMMENT => 3010;
Readonly my $ERROR_INVALID_BETA_LACTAMASE => 3011;
Readonly my $ERROR_INVALID_MIC_COMPARATOR=> 3012;
Readonly my $ERROR_INVALID_MIC_VALUE => 3013;
Readonly my $ERROR_INVALID_MICS_DETERMINED_BY => 3014;
Readonly my $ERROR_INVALID_INTERPRETATION => 3015;
Readonly my $ERROR_INVALID_AMR_MARKER_STRING => 3016;

Readonly my $OPTION_EMPTY => "";
Readonly my $OPTION_ETEST => "E-Test";
Readonly my $OPTION_AGAR_DILUTION => "Agar Dilution";
Readonly my $OPTION_DISC_DIFFUSION => "Disc Diffusion";



sub new
{

	my $class = shift;
	my $self = {
		_dao => DAL::Dao->new(),
	};
	bless $self, $class;
	return $self;

}

sub _validate_metadata
{

	my ($self, $country, $patient_age, $patient_gender, $epi_data, $comment, $beta_lactamase, $classification_code, $mic_map, $mics_determined_by, $collection_date, $interpretation_map, $amr_marker_string) = @_;

	my $is_valid = $TRUE;
	my $invalid_code = $INVALID_CONST;
	my $result;

	#for now, all metadata values are optional for the user
	if($country)
	{

		if($country !~ /^[A-Z\s\-]+$/i)
		{

			$is_valid = $FALSE;
			$invalid_code = $ERROR_INVALID_COUNTRY;

		}

	}
	if($patient_age)
	{

		if(($patient_age !~ /^[0-9]+$/i) or
			($patient_age <= $MIN_PATIENT_AGE) or
			($patient_age >= $MAX_PATIENT_AGE))
		{

			$is_valid = $FALSE;
			$invalid_code = $ERROR_INVALID_PATIENT_AGE;

		}

	}
	if($patient_gender)
	{

		if(($patient_gender ne $PATIENT_GENDER_FEMALE) and
			($patient_gender ne $PATIENT_GENDER_MALE) and
			($patient_gender ne $PATIENT_GENDER_UNKNOWN) and
			($patient_gender ne $PATIENT_GENDER_FEMALE_FULL) and
			($patient_gender ne $PATIENT_GENDER_MALE_FULL) and
			($patient_gender ne $PATIENT_GENDER_UNKNOWN_FULL))
		{

			$is_valid = $FALSE;
			$invalid_code = $ERROR_INVALID_PATIENT_GENDER;

		}

	}

	if($collection_date)
	{

		if($collection_date !~ /^\d{4}-\d\d-\d\d$/)
		{

			$is_valid = $FALSE;
			$invalid_code = $ERROR_INVALID_COLLECTION_DATE;

		}

	}

	if($epi_data)
	{

		if($epi_data !~ /^[\w\s\.\-,:;\/]+$/)
		{

			$is_valid = $FALSE;
			$invalid_code = $ERROR_INVALID_EPI_DATA;

		}

	}

	if($comment)
	{

		if($comment !~ /^[\w\s\.\-,:;\/]+$/)
		{

			$is_valid=$FALSE;
			$invalid_code = $ERROR_INVALID_COMMENT;

		}

	}

	if($beta_lactamase)
	{

		if(($beta_lactamase ne $BETA_LACTAMASE_UNKNOWN) and
			($beta_lactamase ne $BETA_LACTAMASE_POSITIVE) and
			($beta_lactamase ne $BETA_LACTAMASE_NEGATIVE))
		{

			$is_valid = $FALSE;
			$invalid_code = $ERROR_INVALID_BETA_LACTAMASE;

		}

	}

	if($amr_marker_string)
	{

		if($amr_marker_string !~ /^[\w\t\n\s\.\-,:;\/]+$/)
		{

			$is_valid = $FALSE;
			$invalid_code = $ERROR_INVALID_AMR_MARKER_STRING;

		}

	}

	if($classification_code)
	{
		my @classification_codes = split("/",$classification_code);

		if(scalar @classification_codes > 0)
		{

			if($classification_code and ($classification_code ne "Unknown"))
			{

				my $classification_list = $self->{_dao}->get_all_isolate_classifications();

				if($classification_list and @$classification_list)
				{

					my $is_found = $FALSE;

					foreach my $item (@$classification_list)
					{

						foreach my $classification_code_token (@classification_codes)
						{

							if(lc($classification_code_token) eq lc($item->{classification_code}))
							{

								$is_found = $TRUE;

							}

						}

					}

					if(not $is_found)
					{

						$is_valid = $FALSE;
						$invalid_code = $ERROR_INVALID_CLASSIFICATION_CODE;

					}

				}
				else
				{

					$is_valid = $FALSE;

				}

			}

		}
	}
	if($mics_determined_by)
	{

		if($mics_determined_by !~ /^[A-Z\s\-]+$/i)
		{

			$is_valid=$FALSE;
			$invalid_code = $ERROR_INVALID_MICS_DETERMINED_BY;

		}

		if($is_valid)
		{

			if(($mics_determined_by ne $OPTION_ETEST) and
				($mics_determined_by ne $OPTION_AGAR_DILUTION) and
				($mics_determined_by ne $OPTION_DISC_DIFFUSION) and
				($mics_determined_by ne $OPTION_EMPTY))
			{

				$is_valid=$FALSE;
				$invalid_code = $ERROR_INVALID_MICS_DETERMINED_BY;

			}

		}

	}

	if($mics_determined_by and $is_valid)
	{

		if($mics_determined_by ne $OPTION_EMPTY)
		{

			if(keys %$interpretation_map > 0)
			{

				my $antimicrobial_name_list = $self->{_dao}->get_mic_antimicrobial_names();

				if($antimicrobial_name_list and @$antimicrobial_name_list)
				{

					foreach my $name (@$antimicrobial_name_list)
					{

						my $interpretation_value = $interpretation_map->{$name}{interpretation_value};

						if(($interpretation_value ne $INTERPRETATION_INTERMEDIATE) and
							  ($interpretation_value ne $INTERPRETATION_RESISTANT) and
							  ($interpretation_value ne $INTERPRETATION_SUSCEPTIBLE) and
							  ($interpretation_value ne $INTERPRETATION_UNKNOWN))
						{

								print "INTERPRETATION VALUE IS: ".$interpretation_value."\n";
								$is_valid = $FALSE;
								$invalid_code = $ERROR_INVALID_INTERPRETATION;

						}

					}

				}

			}
			elsif(keys %$mic_map > 0)
			{

				my $antimicrobial_name_list = $self->{_dao}->get_mic_antimicrobial_names();

				if($antimicrobial_name_list and @$antimicrobial_name_list)
				{

					foreach my $name (@$antimicrobial_name_list)
					{

						my $mic_comparator = $mic_map->{$name}{mic_comparator};
						my $mic_value = $mic_map->{$name}{mic_value};

						if($mic_comparator)
						{

							if (($mic_comparator ne $MIC_COMPARATOR_EQUALS) and
								($mic_comparator ne $MIC_COMPARATOR_LESS_THAN_OR_EQUALS) and
								($mic_comparator ne $MIC_COMPARATOR_GREATER_THAN_OR_EQUALS) and
								($mic_comparator ne $MIC_COMPARATOR_GREATER_THAN) and
								($mic_comparator ne $MIC_COMPARATOR_LESS_THAN))
							{

								$is_valid = $FALSE;
								$invalid_code = $ERROR_INVALID_MIC_COMPARATOR;

							}

						}
						else
						{

							$is_valid = $FALSE;
							$invalid_code = $ERROR_INVALID_MIC_COMPARATOR;

						}

						#don't return error on mic_value not defined because the user has the option to not add an MIC value
						if($mic_value)
						{

							if(($mic_value !~ /^\d+$/) and ($mic_value !~ /^\d*\.\d+$/))
							{

								$is_valid = $FALSE;
								$invalid_code = $ERROR_INVALID_MIC_VALUE;

							}

						}

					}

				}
				else
				{

					$is_valid = $FALSE;

				}
			}

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

sub _validate_profile_metadata
{

	my ($self, $country, $patient_age, $patient_gender, $epi_data, $comment, $beta_lactamase, $classification_code, $mic_map, $collection_date) = @_;

	my $is_valid = $TRUE;
	my $invalid_code = $INVALID_CONST;
	my $result;

	#for now, all metadata values are optional for the user
	if($country)
	{

		if($country !~ /^[A-Z\s\-]+$/i)
		{

			$is_valid = $FALSE;
			$invalid_code = $ERROR_INVALID_COUNTRY;

		}

	}

	if($patient_age)
	{

		if(($patient_age !~ /^[0-9]+$/i) or
			($patient_age <= $MIN_PATIENT_AGE) or
			($patient_age >= $MAX_PATIENT_AGE))
		{

			$is_valid = $FALSE;
			$invalid_code = $ERROR_INVALID_PATIENT_AGE;

		}

	}
	if($patient_gender)
	{

		if(($patient_gender ne $PATIENT_GENDER_FEMALE) and
			($patient_gender ne $PATIENT_GENDER_MALE) and
			($patient_gender ne $PATIENT_GENDER_UNKNOWN) and
			($patient_gender ne $PATIENT_GENDER_FEMALE_FULL) and
			($patient_gender ne $PATIENT_GENDER_MALE_FULL) and
			($patient_gender ne $PATIENT_GENDER_UNKNOWN_FULL))
		{

			$is_valid = $FALSE;
			$invalid_code = $ERROR_INVALID_PATIENT_GENDER;

		}

	}

	if($collection_date)
	{

		if($collection_date !~ /^\d{4}-\d\d-\d\d$/)
		{

			$is_valid = $FALSE;
			$invalid_code = $ERROR_INVALID_COLLECTION_DATE;

		}

	}

	if($epi_data)
	{

		if($epi_data !~ /^[\w\s\.\-,:;\/]+$/)
		{

			$is_valid = $FALSE;
			$invalid_code = $ERROR_INVALID_EPI_DATA;

		}

	}

	if($comment)
	{

		if($comment !~ /^[\w\s\.\-,:;\/]+$/)
		{

			$is_valid=$FALSE;
			$invalid_code = $ERROR_INVALID_COMMENT;

		}

	}

	if($beta_lactamase)
	{

		if(($beta_lactamase ne $BETA_LACTAMASE_UNKNOWN) and
			($beta_lactamase ne $BETA_LACTAMASE_POSITIVE) and
			($beta_lactamase ne $BETA_LACTAMASE_NEGATIVE))
		{

			$is_valid = $FALSE;
			$invalid_code = $ERROR_INVALID_BETA_LACTAMASE;

		}

	}

	if($classification_code)
	{
		my @classification_codes = split("/",$classification_code);

		if(scalar @classification_codes > 0)
		{

			if($classification_code and ($classification_code ne "Unknown"))
			{

				my $classification_list = $self->{_dao}->get_all_isolate_classifications();

				if($classification_list and @$classification_list)
				{

					my $is_found = $FALSE;

					foreach my $item (@$classification_list)
					{

						foreach my $classification_code_token (@classification_codes)
						{

							if(lc($classification_code_token) eq lc($item->{classification_code}))
							{

								$is_found = $TRUE;

							}

						}

					}

					if(not $is_found)
					{

						$is_valid = $FALSE;
						$invalid_code = $ERROR_INVALID_CLASSIFICATION_CODE;

					}

				}
				else
				{

					$is_valid = $FALSE;

				}

			}

		}
	}


	if(keys %$mic_map > 0)
	{

		my $antimicrobial_name_list = $self->{_dao}->get_mic_antimicrobial_names();

		if($antimicrobial_name_list and @$antimicrobial_name_list)
		{

			foreach my $name (@$antimicrobial_name_list)
			{

				my $mic_comparator = $mic_map->{$name}{mic_comparator};
				my $mic_value = $mic_map->{$name}{mic_value};

				if($mic_comparator)
				{

					if (($mic_comparator ne $MIC_COMPARATOR_EQUALS) and
						($mic_comparator ne $MIC_COMPARATOR_LESS_THAN_OR_EQUALS) and
						($mic_comparator ne $MIC_COMPARATOR_GREATER_THAN_OR_EQUALS) and
						($mic_comparator ne $MIC_COMPARATOR_GREATER_THAN) and
						($mic_comparator ne $MIC_COMPARATOR_LESS_THAN))
					{

						$is_valid = $FALSE;
						$invalid_code = $ERROR_INVALID_MIC_COMPARATOR;

					}

				}
				else
				{

					$is_valid = $FALSE;
					$invalid_code = $ERROR_INVALID_MIC_COMPARATOR;

				}

				#don't return error on mic_value not defined because the user has the option to not add an MIC value
				if($mic_value)
				{

					if(($mic_value !~ /^\d+$/) and ($mic_value !~ /^\d*\.\d+$/))
					{

						$is_valid = $FALSE;
						$invalid_code = $ERROR_INVALID_MIC_VALUE;

					}

				}

			}

		}
		else
		{

			$is_valid = $FALSE;

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

#Validates values entered and if they are not valid the
#referenced variable is set to an empty string
sub _validate_batch_metadata
{

	my ($self, $country, $patient_age, $patient_gender, $epi_data, $curator_comment, $beta_lactamase, $classification_code, $mic_map, $mics_determined_by, $collection_date, $interpretation_map) = @_;

	my $is_valid = $TRUE;
	my $invalid_code = $INVALID_CONST;
	my $result;

	if(${$country})
	{

		if(${$country} !~ /^[A-Z\s\-]+$/i)
		{

			${$country} = "";

		}

	}

	if(${$patient_age})
	{

		if((${$patient_age} !~ /^[0-9]+$/i) or
		(${$patient_age} <= $MIN_PATIENT_AGE) or
		(${$patient_age} >= $MAX_PATIENT_AGE))
		{

			${$patient_age} = 0;

		}

	}
	else
	{

		${$patient_age} = 0;

	}

	if(${$patient_gender})
	{

		if((${$patient_gender} ne $PATIENT_GENDER_FEMALE) and
			(${$patient_gender} ne $PATIENT_GENDER_MALE) and
			(${$patient_gender} ne $PATIENT_GENDER_UNKNOWN) and
			(${$patient_gender} ne $PATIENT_GENDER_FEMALE_FULL) and
			(${$patient_gender} ne $PATIENT_GENDER_MALE_FULL) and
			(${$patient_gender} ne $PATIENT_GENDER_UNKNOWN_FULL))
		{

			${$patient_gender} = "U";

		}

	}

	if(${$collection_date})
	{

		if(${$collection_date} !~ /^\d{4}-\d\d-\d\d$/)
		{

			${$collection_date} = undef;

		}

	}
	else
	{
		${$collection_date} = undef;
	}

	if(${$epi_data})
	{

		if(${$epi_data} !~ /^[\w\s\.\-,:;\/]+$/)
		{

			${$epi_data} = "";

		}

	}

	if(${$curator_comment})
	{

		if(${$curator_comment} !~ /^[\w\s\.\-,:;\/]+$/)
		{

			${$curator_comment} = "";

		}

	}

	if(${$beta_lactamase})
	{

		if((${$beta_lactamase} ne $BETA_LACTAMASE_UNKNOWN) and
			(${$beta_lactamase} ne $BETA_LACTAMASE_POSITIVE) and
			(${$beta_lactamase} ne $BETA_LACTAMASE_NEGATIVE))
		{

			${$beta_lactamase} = "";

		}

	}

	if(${$classification_code} and ${$classification_code} ne "")
	{
		my @classification_codes = split("/",${$classification_code});

		if(scalar @classification_codes > 0)
		{

			my $classification_list = $self->{_dao}->get_all_isolate_classifications();

			if($classification_list and @$classification_list)
			{
				my $is_found = $FALSE;
				my $classification_codes_valid="";

				foreach my $item (@$classification_list)
				{

					foreach my $classification_code_token (@classification_codes)
					{

						if(lc($classification_code_token) eq lc($item->{classification_code}))
						{

							$classification_codes_valid = $classification_codes_valid.$classification_code_token."/";

						}

					}

				}

				if(length $classification_codes_valid)
				{

					${$classification_code} = $classification_codes_valid;

				}
				else
				{

					${$classification_code} = "";

				}

			}
			else
			{

				${$classification_code} = "";

			}

		}

	}

	if(${$mics_determined_by})
	{

		if(${$mics_determined_by} !~ /^[A-Z\s\-]+$/i)
		{

			${$mics_determined_by} = "";

		}
		if($is_valid)
		{

		   if((${$mics_determined_by} ne $OPTION_ETEST) and
				 (${$mics_determined_by} ne $OPTION_AGAR_DILUTION) and
				 (${$mics_determined_by} ne $OPTION_DISC_DIFFUSION) and
				 (${$mics_determined_by} ne $OPTION_EMPTY))
			{

				${$mics_determined_by} = "";

			}

		}

	}

	if(${$mics_determined_by} ne $OPTION_EMPTY)
	{

		if(${$mics_determined_by} eq $OPTION_DISC_DIFFUSION )
		{

			my $antimicrobial_name_list = $self->{_dao}->get_mic_antimicrobial_names();

			if($antimicrobial_name_list and @$antimicrobial_name_list)
			{

				foreach my $name (@$antimicrobial_name_list)
				{

					my $interpretation_value = ${$interpretation_map}->{$name}{interpretation_value};

					if(($interpretation_value ne $INTERPRETATION_INTERMEDIATE) and
						  ($interpretation_value ne $INTERPRETATION_RESISTANT) and
						  ($interpretation_value ne $INTERPRETATION_SUSCEPTIBLE) and
						  ($interpretation_value ne $INTERPRETATION_UNKNOWN))
					{

					   ${$interpretation_map}->{$name}{interpretation_value} = "";

					}
				}

			}

		}
		else
		{

			my $antimicrobial_name_list = $self->{_dao}->get_mic_antimicrobial_names();

			if($antimicrobial_name_list and @$antimicrobial_name_list)
			{

				foreach my $name (@$antimicrobial_name_list)
				{

					my $mic_comparator = ${$mic_map}->{$name}{mic_comparator};
					my $mic_value = ${$mic_map}->{$name}{mic_value};

					if($mic_comparator)
					{

						if (($mic_comparator ne $MIC_COMPARATOR_EQUALS) and
							($mic_comparator ne $MIC_COMPARATOR_LESS_THAN_OR_EQUALS) and
							($mic_comparator ne $MIC_COMPARATOR_GREATER_THAN_OR_EQUALS) and
							($mic_comparator ne $MIC_COMPARATOR_GREATER_THAN) and
							($mic_comparator ne $MIC_COMPARATOR_LESS_THAN))
						{

							${$mic_map}->{$name}{mic_comparator} = "=";
							${$mic_map}->{$name}{mic_value} = 0;

						}

					}
					else
					{

						${$mic_map}->{$name}{mic_comparator} = "=";
						${$mic_map}->{$name}{mic_value} = 0;

					}

				}

			}

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

#Validates values entered and if they are not valid the
#referenced variable is set to an empty string
sub _validate_batch_profile_metadata
{

	my ($self, $country, $patient_age, $patient_gender, $epi_data, $curator_comment, $beta_lactamase, $classification_code, $mic_map, $collection_date) = @_;

	my $is_valid = $TRUE;
	my $invalid_code = $INVALID_CONST;
	my $result;

	if(${$country})
	{

		if(${$country} !~ /^[A-Z\s\-]+$/i)
		{

			${$country} = "";

		}

	}

	if(${$patient_age})
	{

		if((${$patient_age} !~ /^[0-9]+$/i) or
			(${$patient_age} <= $MIN_PATIENT_AGE) or
			(${$patient_age} >= $MAX_PATIENT_AGE))
		{

			${$patient_age} = 0;

		}

	}
	else
	{

		${$patient_age} = 0;

	}

	if(${$patient_gender})
	{

		if((${$patient_gender} ne $PATIENT_GENDER_FEMALE) and
			(${$patient_gender} ne $PATIENT_GENDER_MALE) and
			(${$patient_gender} ne $PATIENT_GENDER_UNKNOWN) and
			(${$patient_gender} ne $PATIENT_GENDER_FEMALE_FULL) and
			(${$patient_gender} ne $PATIENT_GENDER_MALE_FULL) and
			(${$patient_gender} ne $PATIENT_GENDER_UNKNOWN_FULL))
		{

			${$patient_gender} = "U";

		}

	}

	if(${$collection_date})
	{

		if(${$collection_date} !~ /^\d{4}-\d\d-\d\d$/)
		{

			${$collection_date} = undef;

		}

	}
	else
	{
		${$collection_date} = undef;
	}

	if(${$epi_data})
	{

		if(${$epi_data} !~ /^[\w\s\.\-,:;\/]+$/)
		{

			${$epi_data} = "";

		}

	}

	if(${$curator_comment})
	{

		if(${$curator_comment} !~ /^[\w\s\.\-,:;\/]+$/)
		{

			${$curator_comment} = "";

		}

	}

	if(${$beta_lactamase})
	{

		if((${$beta_lactamase} ne $BETA_LACTAMASE_UNKNOWN) and
			(${$beta_lactamase} ne $BETA_LACTAMASE_POSITIVE) and
			(${$beta_lactamase} ne $BETA_LACTAMASE_NEGATIVE))
		{

			${$beta_lactamase} = "";

		}

	}
	if(${$classification_code})
	{

		my @classification_codes = split("/",${$classification_code});

		if(scalar @classification_codes > 0)
		{

			my $classification_list = $self->{_dao}->get_all_isolate_classifications();

			if($classification_list and @$classification_list)
			{

				my $is_found = $FALSE;
				my $classification_codes_valid="";

				foreach my $item (@$classification_list)
				{

					foreach my $classification_code_token (@classification_codes)
					{

						if(lc($classification_code_token) eq lc($item->{classification_code}))
						{

							$classification_codes_valid = $classification_codes_valid.$classification_code_token."/";

						}

					}

				}

				if(length $classification_codes_valid)
				{

					${$classification_code} = $classification_codes_valid;

				}
				else
				{

					${$classification_code} = "";

				}

			}
			else
			{

				${$classification_code} = "";

			}

		}

	}

	my $antimicrobial_name_list = $self->{_dao}->get_mic_antimicrobial_names();

	if($antimicrobial_name_list and @$antimicrobial_name_list)
	{

		foreach my $name (@$antimicrobial_name_list)
		{

			my $mic_comparator = ${$mic_map}->{$name}{mic_comparator};
			my $mic_value = ${$mic_map}->{$name}{mic_value};

			if($mic_comparator)
			{

				if (($mic_comparator ne $MIC_COMPARATOR_EQUALS) and
					($mic_comparator ne $MIC_COMPARATOR_LESS_THAN_OR_EQUALS) and
					($mic_comparator ne $MIC_COMPARATOR_GREATER_THAN_OR_EQUALS) and
					($mic_comparator ne $MIC_COMPARATOR_GREATER_THAN) and
					($mic_comparator ne $MIC_COMPARATOR_LESS_THAN))
				{

					${$mic_map}->{$name}{mic_comparator} = "=";
					${$mic_map}->{$name}{mic_value} = 0;

				}

			}
			else
			{

				${$mic_map}->{$name}{mic_comparator} = "=";
				${$mic_map}->{$name}{mic_value} = 0;

			}


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
