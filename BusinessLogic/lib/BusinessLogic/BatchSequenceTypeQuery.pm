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

package BusinessLogic::BatchSequenceTypeQuery;

use BusinessLogic::GetAlleleInfo;
use BusinessLogic::ParseProfiles;
use BusinessLogic::GetSequenceType;
use BusinessLogic::GetMetadata;
use DateTime;

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

# This allows declaration	use BusinessLogic::GetAlleleInfo':all';
# If you do not need this, moving things directly into @EXPORT or @EXPORT_OK
# will save memory.
our %EXPORT_TAGS = ( 'all' => [ qw(

) ] );

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

our @EXPORT = qw(
	_profile_batch_query
);

our $VERSION = '0.01';

Readonly my $FALSE => 0;
Readonly my $TRUE => 1;

Readonly my $INVALID_VAL => 0;

Readonly my $INVALID_CONST => "IS_INVALID";
Readonly my $VALID_CONST => "IS_VALID";

Readonly my $CSV_FORMAT => ",";
Readonly my $TSV_FORMAT => "\t";

Readonly my $NUM_OF_FIELDS_QUERIED => 8;

sub new
{

	my $class = shift;
	my $self = {
		_dao => DAL::Dao->new(),
	};
	bless $self, $class;
	return $self;

}

sub _profile_batch_query
{
	my ($self, $input) = @_;

	my $obj;
	my $is_valid = $TRUE;
	my $result;

	$obj = BusinessLogic::GetAlleleInfo->new();
	my $name_list = $obj->_get_all_loci_names;

	$obj = BusinessLogic::ParseProfiles->new();
	my $parsed_profile_query_list = $obj->_parse_batch_profile_query($input);
	my @profile_query_results;
	my $sequence_type_list = $self->{_dao}->get_all_sequence_types();


	if($parsed_profile_query_list)
	{
		my $match_threshold = 7;
		my $max_results = 1;
		my @tokens;
		my $query_result;
		my $count;
		my @metadata_list;
		my $metadata;
		my $delimiter;

		foreach my $user_queried_profile(@$parsed_profile_query_list)
		{

			#Checks to see if user has entered csv or tsv data
			@tokens = split ($TSV_FORMAT , $user_queried_profile);
			if(scalar (@tokens) == 1)
			{
				$delimiter = $CSV_FORMAT;
				@tokens = split ($CSV_FORMAT , $user_queried_profile);
			}

			#@tokens = split ($delimiter , $user_queried_profile);

			if(scalar(@tokens) == $NUM_OF_FIELDS_QUERIED)
			{
				$count = 1;
				my %allele_type_map;
				my $curator_comment;

				foreach my $name (@$name_list)
				{
					$tokens[$count] =~ s/(\s+)//g;
					$allele_type_map{$name} = $tokens[$count];
					$count++;
				}

				my $is_batch_query = $TRUE;

				$obj = BusinessLogic::GetSequenceType->new();
				$query_result = $obj->_get_profile_query(\%allele_type_map, $match_threshold, $max_results, $is_batch_query, $sequence_type_list, $name_list);
				my $query_result_count = scalar (@$query_result);
				if($query_result_count < 1)
				{
					push @profile_query_results, {query_id => $tokens[0],
												  penA => $tokens[1],
												  mtrR => $tokens[2],
												  porB => $tokens[3],
												  ponA => $tokens[4],
												  gyrA => $tokens[5],
												  parC => $tokens[6],
												  '23S' => $tokens[7],
												  ngstar_type => "--",
												  curator_comment => "--",
												  found => 0};
				}
				else
				{
					foreach my $profile_queried_result(@$query_result)
					{
						$obj = BusinessLogic::GetMetadata->new();
						$metadata = $obj->_get_metadata($profile_queried_result->{type});
						if($metadata->{curator_comment})
						{
							$curator_comment = $metadata->{curator_comment};
						}
						else
						{
							$curator_comment = "None";
						}

						push @profile_query_results, {query_id => $tokens[0],
													  penA => $tokens[1],
													  mtrR => $tokens[2],
													  porB => $tokens[3],
													  ponA => $tokens[4],
													  gyrA => $tokens[5],
													  parC => $tokens[6],
													  '23S' => $tokens[7],
													  ngstar_type => $profile_queried_result->{type},
													  curator_comment => $curator_comment,
													  found => 1};
					}

				}
			}



		}

	}
	else
	{
		$is_valid = $FALSE;
	}

	if($is_valid)
	{
		$result = \@profile_query_results;
	}
	else
	{
		$result = $FALSE;
	}

	return $result;

}

1;
__END__
