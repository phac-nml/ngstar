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

package BusinessLogic::BatchAddProfile;
use BusinessLogic::ParseProfiles;
use BusinessLogic::AddSequenceTypeProfile;
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

# This allows declaration	use BusinessLogic::BatchAddProfile':all';
# If you do not need this, moving things directly into @EXPORT or @EXPORT_OK
# will save memory.
our %EXPORT_TAGS = ( 'all' => [ qw(

) ] );

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

our @EXPORT = qw(
	_batch_add_profile
);

our $VERSION = '0.01';

Readonly my $FALSE => 0;
Readonly my $TRUE => 1;

Readonly my $INVALID_CONST => "IS_INVALID";
Readonly my $VALID_CONST => "IS_VALID";

sub new
{

	my $class = shift;
	my $self = {};
	bless $self, $class;
	return $self;

}

sub _batch_add_profile
{

	my ($self, $string) = @_;

	my $is_valid = $TRUE;
	my $invalid_code = $INVALID_CONST;
	my $result;

	my $obj = BusinessLogic::ParseProfiles->new();
	my $profile_map_list = $obj->_parse_profiles($string);

	my $st_list = $self->_generate_st_list($profile_map_list);
	$self->_remove_st($profile_map_list);
	my $validate_result = $self->_validate($profile_map_list, $st_list);

	if($validate_result eq $VALID_CONST)
	{

		$obj = BusinessLogic::GetMetadata->new();
		my $antimicrobial_name_list = $obj->_get_mic_antimicrobial_names();
		$obj = BusinessLogic::AddSequenceTypeProfile->new();

		my $country = undef;
		my $patient_age = 0;
		my $collection_date = undef;
		my $patient_gender = 'U';
		my $epi_data = undef;
		my $curator_comment = undef;
		my $beta_lactamase = "Unknown";
		my $classification_code = "Unknown";
		my %mic_map;

		foreach my $name (@$antimicrobial_name_list)
		{

			$mic_map{$name}{mic_operator} = "=";
			$mic_map{$name}{mic_value} = 0;

		}

		my $count = 0;

		foreach my $map (@$profile_map_list)
		{

			my $sequence_type = $st_list->[$count];
			my $add_result = $obj->_add_sequence_type_profile($sequence_type, $map, $country, $patient_age, $collection_date, $patient_gender, $epi_data, $curator_comment, $beta_lactamase, $classification_code, \%mic_map);

			if($add_result ne $VALID_CONST)
			{

				$is_valid = $FALSE;
				$invalid_code = $add_result;

			}

			$count ++;

		}

	}
	else
	{

		$is_valid = $FALSE;
		$invalid_code = $validate_result;

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

sub _validate
{

	my ($self, $profile_map_list, $st_list) = @_;

	my $invalid_code = $INVALID_CONST;
	my $is_valid = $TRUE;
	my $result;
	my $obj = BusinessLogic::ValidateSequenceTypeProfile->new();
	my $count = 0;

	foreach my $map (@$profile_map_list)
	{

		my $sequence_type = $st_list->[$count];
		my $validate_result = $obj->_validate_profile($sequence_type, $map);

		if($validate_result ne $VALID_CONST)
		{

			$is_valid = $FALSE;
			$invalid_code = $validate_result;

		}

		$count ++;

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
