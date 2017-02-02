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

package BusinessLogic::ParseProfiles;
use BusinessLogic::GetAlleleInfo;

use 5.014002;
use strict;
use warnings;

use Readonly;

require Exporter;

our @ISA = qw(Exporter);

# Items to export into callers namespace by default. Note: do not export
# names by default without a very good reason. Use EXPORT_OK instead.
# Do not simply export all your public functions/methods/constants.

# This allows declaration	use BusinessLogic::ParseProfiles':all';
# If you do not need this, moving things directly into @EXPORT or @EXPORT_OK
# will save memory.
our %EXPORT_TAGS = ( 'all' => [ qw(

) ] );

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

our @EXPORT = qw(
	_parse_batch_profile_query
	_parse_curator_profile
	_parse_profiles
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

sub _parse_profiles
{

	my ($self, $string) = @_;

	my $new_string = $self->_clean_string($string);
	my $delimiter = ",";
	my $line_delimiter = "\n";
	my @lines = split(/$line_delimiter/, $new_string);
	my @profile_map_list;

	my $obj = BusinessLogic::GetAlleleInfo->new();
	#returns list in alphabetical order
	my $loci_name_list = $obj->_get_all_loci_names();

	foreach my $line (@lines)
	{

		my @profile = split(/$delimiter/, $line);
		my %profile_map;
		my $first = $TRUE;
		my $count = 0;

		foreach my $item (@profile)
		{

			if($first)
			{

				$profile_map{"st"} = $item;
				$first = $FALSE;

			}
			else
			{

				$profile_map{$loci_name_list->[$count]} = $item;
				$count ++;

			}

		}

		push @profile_map_list, \%profile_map;

	}

	return \@profile_map_list;

}

sub _parse_batch_profile_query
{
	my ($self, $input) = @_;

	my $is_valid = $TRUE;
	my $result;
	my $validate_result = $self->_validate_batch_profile_query($input);

	if($validate_result)
	{
		my @temp = split("\n",$input);

		#if @temp is <= 1 then either the file only includes a header line
		#or all data is on 1 line.
		if(scalar @temp > 0)
		{
			$result = \@temp;
		}
		else
		{
			$result = $FALSE;
		}
	}
	else
	{
		$result = $FALSE;
	}
	return $result;
}

sub _parse_curator_profile
{
	my ($self, $input) = @_;

	my $is_valid = $TRUE;
	my $result;

	my $obj = BusinessLogic::GetAlleleInfo->new();

	my $loci_name_count = $obj->_get_loci_name_count();

	my $validate_result = $self->_validate_curator_profile_input($input);
	my @allele_types;

	if($validate_result)
	{
		my @temp = split("\n", $input);

		if(scalar @temp == $loci_name_count)
		{
			@temp = split /[:\s]+/, $input;
			my $count = 0;
			foreach my $item (@temp)
			{
				if($count% 2 == 1)
				{
					push @allele_types, $item;
				}
				$count++;
			}

			$result = \@allele_types;
		}
		else
		{
			$result = $FALSE;
		}
	}
	else
	{
		$result = $FALSE;
	}


	return $result;


}

sub _validate
{

	my ($self, $input) = @_;

	my $is_valid = $TRUE;

	if($input !~ /^[(A-Z)|(0-9)|(\.)|(_)|(\,)|(\n)|(\r)|(\s)|(\t)]+$/i)
	{
		$is_valid = $FALSE;
	}
	return $is_valid;

}

sub _validate_curator_profile_input
{

	my ($self, $input) = @_;

	my $is_valid = $TRUE;

	if($input !~ /^[(A-Z)|(0-9)|(\.)|(\r)|(\n)|(\s)|(:)]+$/i)
	{
		$is_valid = $FALSE;
	}
	return $is_valid;

}

sub _validate_batch_profile_query
{
	my ($self, $input) = @_;
	my $is_valid = $TRUE;
	if($input !~ /^[(0-9)|(\.)|(\,)|(\n)|(\r)|(\s)|(\t)]+$/i)
	{
		$is_valid = $FALSE;
	}
	return $is_valid;
}

sub _clean_string
{

	my ($self, $string) = @_;

	#remove all characters that are not part of this whitelist
	$string =~ s/[^,\d\.\n]//g;

	return $string;

}

1;
__END__
