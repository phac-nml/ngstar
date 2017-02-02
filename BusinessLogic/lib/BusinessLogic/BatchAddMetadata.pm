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

package BusinessLogic::BatchAddMetadata;
use BusinessLogic::ParseMetadata;
use BusinessLogic::ValidateBatchMetadata;

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

# This allows declaration	use BusinessLogic::BatchAddMetadata':all';
# If you do not need this, moving things directly into @EXPORT or @EXPORT_OK
# will save memory.
our %EXPORT_TAGS = ( 'all' => [ qw(

) ] );

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

our @EXPORT = qw(
	_batch_add_metadata
	_batch_add_profile_metadata
);

our $VERSION = '0.01';

Readonly my $TESTING => 0;

#The number of metadata fields - 1 to get the number of tabs
Readonly my $METADATA_FIELDS => 18;
Readonly my $PROFILE_METADATA_FIELDS => 17;

Readonly my $FALSE => 0;
Readonly my $TRUE => 1;

Readonly my $INVALID_CONST => "IS_INVALID";
Readonly my $VALID_CONST => "IS_VALID";

Readonly my $ERROR_INCORRECT_NUM_METADATA_FIELDS => 3003;

Readonly my $ERROR_NOT_TAB_FORMAT => 5001;

sub new
{

	my $class = shift;
	my $self = {
		_dao => DAL::Dao->new(),
	};
	bless $self, $class;
	return $self;

}

sub _batch_add_metadata
{

	my ($self, $input, $input_loci_name) = @_;

	my $invalid_code = $INVALID_CONST;
	my $is_valid = $TRUE;
	my $result;

	my $obj = BusinessLogic::ParseMetadata->new();
	my $metadata_list = $obj->_parse_metadata_lines($input);

	if(not $metadata_list)
	{

		$is_valid = $FALSE;
		$invalid_code = $ERROR_NOT_TAB_FORMAT;

	}
	else
	{

		$obj = BusinessLogic::GetMetadata->new();
		my $antimicrobial_name_list = $obj->_get_mic_antimicrobial_names();

		my $header_line = $TRUE;
		$obj = BusinessLogic::AddBatchMetadata->new();
		my @tokens;

		foreach my $curr_metadata (@$metadata_list)
		{

			if(not $header_line)
			{

				my $num_fields = $curr_metadata =~ tr/\t//;

				if($num_fields == $METADATA_FIELDS)
				{

					@tokens = split('\t',$curr_metadata);

					my $loci_name = $input_loci_name ;
					my $allele_type = $tokens[0];
					my $amr_markers = $tokens[1];
					my $collection_date = $tokens[2];
					my $country = $tokens[3];
					my $patient_age = $tokens[4];
					my $patient_gender = $tokens[5];
					my $beta_lactamase = $tokens[6];
					my $classification_code = $tokens[7];
					my $mics_determined_by = $tokens[8];
					my %mic_map;
					my %interpretation_map;

					if($patient_age eq "")
					{

						$patient_age = 0;

					}

					if($mics_determined_by eq "E-Test" or $mics_determined_by eq "Agar Dilution")
					{

						my $index = 9;

						foreach my $name (@$antimicrobial_name_list)
						{

							if($tokens[$index] =~ /^[(0-9)|(\.)]+$/)
							{

								$mic_map{$name}{mic_comparator} = "=";
								$mic_map{$name}{mic_value} = $tokens[$index];

							}
							else
							{

								if($tokens[$index] =~ /^>[(0-9)|(\.)]+$/)
								{

									$mic_map{$name}{mic_comparator} = "gt";
									$tokens[$index] =~ s/[^(0-9)|(\.)]//g;

									if($tokens[$index])
									{

										$mic_map{$name}{mic_value} = $tokens[$index];

									}
									else
									{

										$mic_map{$name}{mic_value} = 0;

									}

								}
								elsif($tokens[$index] =~ /^<[(0-9)|(\.)]+$/)
								{

									$mic_map{$name}{mic_comparator} = "lt";
									$tokens[$index] =~ s/[^(0-9)|(\.)]//g;

									if($tokens[$index])
									{

										$mic_map{$name}{mic_value} = $tokens[$index];

									}
									else
									{

										$mic_map{$name}{mic_value} = 0;

									}

								}
								else
								{

									my @comparator_tokens = split('=',$tokens[$index]);

									if($comparator_tokens[0] eq "<")
									{

										$mic_map{$name}{mic_comparator} = "le";

									}
									elsif($comparator_tokens[0] eq ">")
									{

										$mic_map{$name}{mic_comparator} = "ge";

									}
									else
									{

										$mic_map{$name}{mic_comparator} = "=";

									}

									if($comparator_tokens[1] =~ /^[(0-9)|(\.)]+$/)
									{

										$mic_map{$name}{mic_value} = $comparator_tokens[1];

									}
									else
									{

										$mic_map{$name}{mic_value} = 0;

									}

								}

							}

							$index++;

						}

					}
					elsif($mics_determined_by eq "Disc Diffusion")
					{

						my $index = 9;

						foreach my $name (@$antimicrobial_name_list)
						{

							if($tokens[$index] ne "")
							{

								$interpretation_map{$name}{interpretation_value} = $tokens[$index];

							}
							else
							{

								$interpretation_map{$name}{interpretation_value} = "Unknown";

							}

							$index++;

						}

					}
					else
					{

						%mic_map = ();
						%interpretation_map = ();

					}

					my $epi_data = $tokens[17];
					my $curator_comment = $tokens[18];

					if($curator_comment)
					{
						if(length $curator_comment < 2)
						{
							$curator_comment = "";
						}
					}

					my $add_metadata_result = $obj->_add_batch_metadata($loci_name, $allele_type, $country, $patient_age, $patient_gender, $epi_data, $curator_comment, $beta_lactamase, $classification_code, $collection_date, $mics_determined_by, \%mic_map, \%interpretation_map, $amr_markers);

					if($add_metadata_result ne $VALID_CONST)
					{

						$is_valid = $FALSE;
						$invalid_code = $add_metadata_result;

					}

				}
				else
				{

					$is_valid = $FALSE;
					$invalid_code = $ERROR_INCORRECT_NUM_METADATA_FIELDS;

				}

			}

			$header_line = $FALSE;

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


sub _batch_add_profile_metadata
{

	my ($self, $input) = @_;

	my $invalid_code = $INVALID_CONST;
	my $is_valid = $TRUE;
	my $result;

	my $obj = BusinessLogic::ParseMetadata->new();
	my $metadata_list = $obj->_parse_metadata_lines($input);

	if(not $metadata_list)
	{

		$is_valid = $FALSE;
		$invalid_code = $ERROR_NOT_TAB_FORMAT;

	}
	else
	{

		$obj = BusinessLogic::GetMetadata->new();
		my $antimicrobial_name_list = $obj->_get_mic_antimicrobial_names();

		my $header_line = $TRUE;
		$obj = BusinessLogic::AddBatchMetadata->new();
		my @tokens;

		foreach my $curr_metadata (@$metadata_list)
		{

			if(not $header_line)
			{

				my $num_fields = $curr_metadata =~ tr/\t//;

				if($num_fields == $PROFILE_METADATA_FIELDS)
				{

					@tokens = split('\t',$curr_metadata);
					my $sequence_type = $tokens[0];
					my $amr_markers = $tokens[1];
					my $collection_date = $tokens[2];
					my $country = $tokens[3];
					my $patient_age = $tokens[4];
					my $patient_gender = $tokens[5];
					my $beta_lactamase = $tokens[6];
					my $classification_code = $tokens[7];
					my %mic_map;
					my $index = 8;


					if($patient_age eq "")
					{

						$patient_age = 0;

					}

					foreach my $name (@$antimicrobial_name_list)
					{

						if($tokens[$index] =~ /^[(0-9)|(\.)]+$/)
						{

							$mic_map{$name}{mic_comparator} = "=";
							$mic_map{$name}{mic_value} = $tokens[$index];

						}
						else
						{

							if($tokens[$index] =~ /^>[(0-9)|(\.)]+$/)
							{

								$mic_map{$name}{mic_comparator} = "gt";
								$tokens[$index] =~ s/[^(0-9)|(\.)]//g;

								if($tokens[$index])
								{

									$mic_map{$name}{mic_value} = $tokens[$index];

								}
								else
								{

									$mic_map{$name}{mic_value} = 0;

								}

							}
							elsif($tokens[$index] =~ /^<[(0-9)|(\.)]+$/)
							{

								$mic_map{$name}{mic_comparator} = "lt";
								$tokens[$index] =~ s/[^(0-9)|(\.)]//g;

								if($tokens[$index])
								{

									$mic_map{$name}{mic_value} = $tokens[$index];

								}
								else
								{

									$mic_map{$name}{mic_value} = 0;

								}

							}
							else
							{

								my @comparator_tokens = split('=',$tokens[$index]);

								if($comparator_tokens[0] eq "<")
								{

									$mic_map{$name}{mic_comparator} = "le";

								}
								elsif($comparator_tokens[0] eq ">")
								{

									$mic_map{$name}{mic_comparator} = "ge";

								}
								else
								{

									$mic_map{$name}{mic_comparator} = "=";

								}

								if($comparator_tokens[1] =~ /^[(0-9)|(\.)]+$/)
								{

									$mic_map{$name}{mic_value} = $comparator_tokens[1];

								}
								else
								{

									$mic_map{$name}{mic_value} = 0;

								}

							}

						}

						$index++;

					}

					my $epi_data = $tokens[16];
					my $curator_comment = $tokens[17];


					if(length $curator_comment < 2)
					{
						$curator_comment = "";
					}

					my $add_metadata_result = $obj->_add_batch_profile_metadata($sequence_type, $country, $patient_age, $patient_gender, $epi_data, $curator_comment, $beta_lactamase, $classification_code, $collection_date, \%mic_map, $amr_markers);

					if($add_metadata_result ne $VALID_CONST)
					{

						$is_valid = $FALSE;
						$invalid_code = $add_metadata_result;

					}

				}
				else
				{

					$is_valid = $FALSE;
					$invalid_code = $ERROR_INCORRECT_NUM_METADATA_FIELDS;

				}

			}

			$header_line = $FALSE;
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
