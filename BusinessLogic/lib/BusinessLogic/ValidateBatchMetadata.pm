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

package BusinessLogic::ValidateBatchMetadata;
use BusinessLogic::ParseMetadata;
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

# This allows declaration	use BusinessLogic::ValidateBatchMetadata':all';
# If you do not need this, moving things directly into @EXPORT or @EXPORT_OK
# will save memory.
our %EXPORT_TAGS = ( 'all' => [ qw(

) ] );

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

our @EXPORT = qw(
	_validate_batch_metadata_input
	_validate_batch_profile_metadata_input
	_validate_batch_metadata_parse
);

our $VERSION = '0.01';

Readonly my $FALSE => 0;
Readonly my $TRUE => 1;

Readonly my $INVALID_CONST => "IS_INVALID";
Readonly my $VALID_CONST => "IS_VALID";

Readonly my $ERROR_DUPLICATE_TYPE_INPUT => 1022;
Readonly my $ERROR_TYPE_NOT_EXIST => 1023;
Readonly my $ERROR_BATCH_METADATA_NO_ALLELES => 1024;

Readonly my $ERROR_SEQUENCE_TYPE_NOT_EXIST => 2018;
Readonly my $ERROR_DUPLICATE_SEQUENCE_TYPE_INPUT => 2019;
Readonly my $ERROR_BATCH_METADATA_NO_PROFILES => 2020;

Readonly my $ERROR_NOT_TAB_SEPARATED_FORMAT => 5001;


Readonly my $NUM_METADATA_FIELDS => 18;
Readonly my $NUM_PROFILE_METADATA_FIELDS => 17;

Readonly my $ERROR_CODE_DEFAULT => -999;

sub new
{

	my $class = shift;
	my $self = {};
	bless $self, $class;
	return $self;

}

sub _validate_batch_metadata_input
{

	my ($self, $input,$input_loci_name) = @_;

	my %error_codes;
	my %allele_map;
	my %allele_type_map;
	my @allele_type_not_unique;
	my @allele_type_not_exists;
	my @invalid_metadata;
	my @tokens;
	my $loci_name;
	my $allele_type;
	my $header_line = $TRUE;
	my $allele_not_exist;
	my $is_type_int;
	$loci_name = $input_loci_name;

	my $obj = BusinessLogic::ParseMetadata->new();
	my $metadata_list = $obj->_parse_metadata_lines($input);


	$obj = BusinessLogic::GetAlleleInfo->new();
	my $allele_list = $obj->_get_loci_alleles($loci_name);

	$obj = BusinessLogic::GetIntegerType->new();
	my $loci_int_type_set = $obj->_get_loci_with_integer_type();

	if((%$loci_int_type_set) and (exists $loci_int_type_set->{$loci_name}))
	{

		$is_type_int = $TRUE;

	}

	if($allele_list and @$allele_list)
	{

		if($is_type_int)
		{

			foreach my $allele(@$allele_list)
			{

				$allele_map{int($allele->{allele_type})} = undef;

			}

		}
		else
		{

			foreach my $allele(@$allele_list)
			{

				$allele_map{$allele->{allele_type}} = undef;

			}

		}

	}

	if(($metadata_list and @$metadata_list) and ($allele_list and @$allele_list))
	{

		foreach my $metadata (@$metadata_list)
		{

			if(not $header_line)
			{

				my $num_fields = $metadata =~ tr/\t//;
				@tokens = split('\t',$metadata);
				$allele_type = $tokens[0];

				if($num_fields == $NUM_METADATA_FIELDS)
				{

					$allele_not_exist = $TRUE;

					if(exists $allele_map{$allele_type})
					{

						if(exists $allele_type_map{$allele_type})
						{

							$allele_type_map{$allele_type} = $allele_type_map{$allele_type} + 1;

						}
						else
						{

							$allele_type_map{$allele_type} = 1;

						}

						$allele_not_exist = $FALSE;

					}

					if($allele_not_exist)
					{

						$allele_type_map{$allele_type} = 0;

					}

				}
				else
				{

					$allele_type_map{$allele_type} = -1;

				}

			}

			$header_line = $FALSE;

		}

		foreach my $key (keys %allele_type_map)
		{

			if($allele_type_map{$key} > 1)
			{

				push @allele_type_not_unique, $key;

			}

			if($allele_type_map{$key} == 0)
			{

				push @allele_type_not_exists, $key;

			}

			if($allele_type_map{$key} == -1)
			{

				push @invalid_metadata, $key;

			}

		}

		if(@allele_type_not_unique)
		{

			for my $item (@allele_type_not_unique)
			{

				$error_codes{$item} = $ERROR_DUPLICATE_TYPE_INPUT;

			}

		}

		if(@allele_type_not_exists)
		{

			for my $item (@allele_type_not_exists)
			{

				$error_codes{$item} = $ERROR_TYPE_NOT_EXIST;

			}

		}
		if(@invalid_metadata)
		{

			for my $item (@invalid_metadata)
			{

				$error_codes{$item} = $ERROR_NOT_TAB_SEPARATED_FORMAT;

			}

		}

	}
	else
	{

		$error_codes{$loci_name} = $ERROR_BATCH_METADATA_NO_ALLELES;

	}

	return \%error_codes;

}

#make sure that the input/file can be properly parsed
sub _validate_batch_metadata_parse
{

	my ($self, $input) = @_;

	my $is_valid;
	my $result;

	my $obj = BusinessLogic::ParseMetadata->new();
	my $metadata_list = $obj->_parse_metadata_lines($input);

	if($metadata_list and @$metadata_list)
	{

		$is_valid = $TRUE;

	}
	else
	{

		$is_valid = $FALSE;

	}
	if($is_valid)
	{

		$result = $VALID_CONST;

	}
	else
	{

		$result = $ERROR_NOT_TAB_SEPARATED_FORMAT;

	}

	return $result;

}

sub _validate_batch_profile_metadata_input
{

	my($self,$input) = @_;

	my %error_codes;
	my %profile_map;
	my %profile_type_map;
	my @sequence_type_not_unique;
	my @sequence_type_not_exists;
	my @invalid_metadata;
	my @tokens;
	my $header_line = $TRUE;
	my $sequence_type_not_exist;
	my $sequence_type;

	my $obj = BusinessLogic::ParseMetadata->new();
	my $metadata_list = $obj->_parse_metadata_lines($input);

	$obj = BusinessLogic::GetSequenceTypeInfo->new();
	my $profile_list = $obj->_get_all_sequence_types();

	if($profile_list and @$profile_list)
	{

		foreach my $profile(@$profile_list)
		{

			$profile_map{$profile->{seq_type_value}} = undef;

		}

	}

	if(($metadata_list and @$metadata_list) and ($profile_list and @$profile_list))
	{

		foreach my $metadata (@$metadata_list)
		{

			if(not $header_line)
			{

				my $num_fields = $metadata =~ tr/\t//;
				@tokens = split('\t',$metadata);
				$sequence_type = $tokens[0];

				if($num_fields == $NUM_PROFILE_METADATA_FIELDS)
				{

					$sequence_type_not_exist = $TRUE;

					if(exists $profile_map{$sequence_type})
					{

						if(exists $profile_type_map{$sequence_type})
						{

							$profile_map{$sequence_type} = $profile_type_map{$sequence_type} + 1;

						}
						else
						{

							$profile_type_map{$sequence_type} = 1;

						}

						$sequence_type_not_exist = $FALSE;

					}
					if($sequence_type_not_exist)
					{

						$profile_type_map{$sequence_type} = 0;

					}

				}
				else
				{

					$profile_type_map{$sequence_type} = -1;

				}
			}

			$header_line = $FALSE;

		}

		foreach my $key (keys %profile_type_map)
		{

			if($profile_type_map{$key} > 1)
			{

				push @sequence_type_not_unique, $key;

			}

			if($profile_type_map{$key} == 0)
			{

				push @sequence_type_not_exists, $key;

			}

			if($profile_type_map{$key} == -1)
			{

				push @invalid_metadata, $key;

			}

		}

		if(@sequence_type_not_unique)
		{

			for my $item (@sequence_type_not_unique)
			{

				$error_codes{$item} = $ERROR_DUPLICATE_SEQUENCE_TYPE_INPUT;

			}

		}

		if(@sequence_type_not_exists)
		{

			for my $item (@sequence_type_not_exists)
			{

				$error_codes{$item} = $ERROR_SEQUENCE_TYPE_NOT_EXIST;

			}

		}

		if(@invalid_metadata)
		{

			for my $item (@invalid_metadata)
			{

				$error_codes{$item} = $ERROR_NOT_TAB_SEPARATED_FORMAT;

			}

		}

	}
	else
	{

		$error_codes{$ERROR_CODE_DEFAULT} = $ERROR_BATCH_METADATA_NO_PROFILES;

	}

	return \%error_codes;

}

1;
__END__
