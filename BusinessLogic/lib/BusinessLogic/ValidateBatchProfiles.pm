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

package BusinessLogic::ValidateBatchProfiles;
use BusinessLogic::GetAlleleInfo;
use BusinessLogic::ParseProfiles;
use BusinessLogic::ValidateSequenceTypeProfile;

use 5.014002;
use strict;
use warnings;

use Readonly;

require Exporter;

our @ISA = qw(Exporter);

# Items to export into callers namespace by default. Note: do not export
# names by default without a very good reason. Use EXPORT_OK instead.
# Do not simply export all your public functions/methods/constants.

# This allows declaration	use BusinessLogic::ValidateBatchProfiles':all';
# If you do not need this, moving things directly into @EXPORT or @EXPORT_OK
# will save memory.
our %EXPORT_TAGS = ( 'all' => [ qw(

) ] );

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

our @EXPORT = qw(
	_validate_batch_profiles_parse
	_validate_input
	_batch_parse_profiles
);

our $VERSION = '0.01';

Readonly my $FALSE => 0;
Readonly my $TRUE => 1;

Readonly my $INVALID_CONST => "IS_INVALID";
Readonly my $VALID_CONST => "IS_VALID";

Readonly my $ERROR_INVALID_LOCI_COUNT => 1026;

Readonly my $ERROR_INVALID_FORMAT => 2010;
Readonly my $ERROR_DUPLICATE_PROFILE_INPUT => 2021;
Readonly my $ERROR_DUPLICATE_ST_TYPE_INPUT => 2022;

sub new
{

	my $class = shift;
	my $self = {};
	bless $self, $class;
	return $self;

}

#make sure that the input/file can be properly parsed
sub _validate_batch_profiles_parse
{

	my ($self, $input) = @_;

	my $is_valid;
	my $result;

	my $obj = BusinessLogic::ParseProfiles->new();
	my $profile_map_list = $obj->_parse_profiles($input);

	if($profile_map_list and @$profile_map_list)
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

		$result = $ERROR_INVALID_FORMAT;

	}

	return $result;
}

#remove this later
sub _batch_parse_profiles
{

	my ($self, $input) = @_;

	my $obj = BusinessLogic::ParseProfiles->new();
	my $profile_map_list = $obj->_parse_profiles($input);

	return $profile_map_list;

}

sub _generate_st_list
{

	my ($self, $profile_map_list) = @_;

	my @st_list;

	foreach my $map (@$profile_map_list)
	{

		my $sequence_type = $map->{"st"};
		push @st_list, $sequence_type;

	}

	return \@st_list;

}

sub _remove_st
{

	my ($self, $profile_map_list) = @_;

	foreach my $map (@$profile_map_list)
	{

		#need to remove this entry from the hash because add_sequence_type_profile only accepts a hash that contains allele types only
		delete $map->{"st"};

	}

}

sub _validate_input
{

	my ($self, $string) = @_;

	my %error_codes;
	my $invalid_code = $INVALID_CONST;
	my $is_valid = $TRUE;

	my $obj = BusinessLogic::ParseProfiles->new();
	my $profile_map_list = $obj->_parse_profiles($string);

	my $st_list = $self->_generate_st_list($profile_map_list);
	$self->_remove_st($profile_map_list);

	#check that the profile passes basic validation
	$obj = BusinessLogic::ValidateSequenceTypeProfile->new();
	my $count = 0;

	foreach my $map (@$profile_map_list)
	{

		my $sequence_type = $st_list->[$count];
		my $validate_result = $obj->_validate_profile($sequence_type, $map);

		if($validate_result ne $VALID_CONST)
		{

			$is_valid = $FALSE;
			$error_codes{$sequence_type} = $validate_result;

		}

		$count ++;

	}

	if($is_valid)
	{

		#check that the number of columns is correct for each row
		#(check that the number of types is the correct number for
		#the number of loci that we have for each profile)
		$obj = BusinessLogic::GetAlleleInfo->new();
		my $loci_name_count = $obj->_get_loci_name_count();

		my $count = 0;

		foreach my $map (@$profile_map_list)
		{

			my $sequence_type = $st_list->[$count];
			my $input_count = scalar keys %$map;

			if($input_count != $loci_name_count)
			{

				$is_valid = $FALSE;
				$error_codes{$sequence_type} = $ERROR_INVALID_LOCI_COUNT;

			}

			$count ++;

		}

	}
	if($is_valid)
	{

		#check that all ST types are unique in the input
		my %st_counter;
		foreach my $st (@$st_list)
		{

			if(exists $st_counter{$st})
			{

				$is_valid = $FALSE;
				$error_codes{$st} = $ERROR_DUPLICATE_ST_TYPE_INPUT;

			}
			else
			{

				$st_counter{$st} = $TRUE;

			}

		}

	}
	if($is_valid)
	{

		#check that all ST profiles are unique in the input
		my $loci_name_list = $obj->_get_all_loci_names();
		my @profile_concat_list;
		my %profile_counter;

		#(n^2) running time, not efficient
		my $count = 0;

		foreach my $map (@$profile_map_list)
		{

			my $sequence_type = $st_list->[$count];
			my $profile_concat = "";

			foreach my $name (@$loci_name_list)
			{

				$profile_concat = $profile_concat . $map->{$name};

			}

			push @profile_concat_list, {st => $sequence_type, profile => $profile_concat};
			$count ++;

		}

		#use a dictionary to keep track of each unique profile we have seen
		foreach my $item (@profile_concat_list)
		{

			my $sequence_type = $item->{st};
			my $profile = $item->{profile};

			#if we have seen this profile already its a duplicate
			if(exists $profile_counter{$profile})
			{

				$is_valid = $FALSE;
				$error_codes{$sequence_type} = $ERROR_DUPLICATE_PROFILE_INPUT;

			}
			else
			{

				$profile_counter{$profile} = $TRUE;

			}

		}

	}

	return \%error_codes;

}

1;
__END__
