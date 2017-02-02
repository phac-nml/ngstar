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

package BusinessLogic::GetSequenceTypeInfo;

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

# This allows declaration	use BusinessLogic::GetSequenceTypeInfo':all';
# If you do not need this, moving things directly into @EXPORT or @EXPORT_OK
# will save memory.
our %EXPORT_TAGS = ( 'all' => [ qw(

) ] );

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

our @EXPORT = qw(
	_get_profile
	_get_all_profiles_format
	_get_all_sequence_types
	_get_profile_list
	_get_profile_list_length
	_get_last_ngstar_type
);

our $VERSION = '0.01';

Readonly my $TESTING => 0;

Readonly my $FALSE => 0;
Readonly my $TRUE => 1;

Readonly my $INVALID_VAL => 0;

sub new
{

	my $class = shift;
	my $self;

	if($TESTING)
	{

		$self = {
			_dao_stub => DAL::DaoStub->new(),
		};

	}
	else
	{

		$self = {
			_dao => DAL::Dao->new(),
		};

	}

	bless $self, $class;
	return $self;

}

sub _get_profile
{

	my ($self, $sequence_type) = @_;

	my $id = $self->{_dao}->get_sequence_type_id($sequence_type);
	my $profile = $self->{_dao}->get_profile($id);

	return $profile;

}

sub _get_profile_list
{

	my ($self) = @_;

	my $result;
	my $sequence_type_list = $self->{_dao}->get_all_sequence_types();

	if($sequence_type_list and @$sequence_type_list)
	{

		$result = $self->_get_all_profiles($sequence_type_list);

	}

	return $result;

}

sub _get_all_sequence_types
{

	my($self) = @_;

	my $sequence_type_list = $self->{_dao}->get_all_sequence_types();

	return $sequence_type_list;
}

sub _get_all_profiles
{

	my ($self, $sequence_type_list) = @_;

	my $result;
	my @st_profile_list;

	foreach my $st (@$sequence_type_list)
	{

		my $profile_info = $self->{_dao}->get_profile($st->{seq_type_id});

		if($profile_info and %$profile_info)
		{

			$profile_info->{type} = $st->{seq_type_value};
			push @st_profile_list, $profile_info;

		}
		else
		{

			return $INVALID_VAL;

		}

	}

	if(@st_profile_list)
	{

		@st_profile_list = sort {$a->{type} <=> $b->{type}} @st_profile_list;
		$result = \@st_profile_list;

	}
	else
	{

		$result = $INVALID_VAL;

	}

	return $result;

}

sub _get_all_profiles_format
{

	my ($self, $format_option) = @_;

	Readonly my $FORMAT_CODE_COMMA => "C";
	Readonly my $FORMAT_CODE_TAB => "T";

	my $is_valid = $TRUE;
	my $result;
	my $string = "";

	my %format_code_map = (
		$FORMAT_CODE_COMMA => ",",
		$FORMAT_CODE_TAB => "\t"
	);

	my $delimiter = $format_code_map{$format_option};

	if(not defined $delimiter)
	{

		$delimiter = "\t";

	}

	my $st_profile_list = $self->_get_profile_list();

	if(not $st_profile_list)
	{

		$is_valid = $FALSE;

	}
	else
	{

		my $obj = BusinessLogic::GetIntegerType->new();

		my $loci_int_type_set = $obj->_get_loci_with_integer_type();

		my $loci_name_list = $self->{_dao}->get_all_loci_names();
		my $profile_types_format;

		if($loci_name_list and @$loci_name_list)
		{

			foreach my $profile (@$st_profile_list)
			{

				$string .= $profile->{type};

				foreach my $name (@$loci_name_list)
				{

					$profile_types_format = $profile->{$name};

					if((%$loci_int_type_set) and (exists $loci_int_type_set->{$name}))
					{
						$profile_types_format = int($profile->{$name});

					}

					$string .= $delimiter;
					$string .= $profile_types_format;

				}

				$string .= "\n";

			}

		}
		else
		{

			$is_valid = $FALSE;

		}

	}
	if($is_valid)
	{

		$result = $string;

	}
	else
	{

		$result = $INVALID_VAL;

	}

	return $result;

}

sub _get_profile_list_length
{

	my ($self) = @_;

	my $length = $self->{_dao}->get_sequence_type_count();

	return $length;

}

sub _get_last_ngstar_type
{
	my ($self) = @_;

	my $length = $self->{_dao}->get_last_ngstar_type();

	return $length;
}

1;
__END__
