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

package BusinessLogic::GetSequenceType;

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

# This allows declaration    use BusinessLogic::GetSequenceType':all';
# If you do not need this, moving things directly into @EXPORT or @EXPORT_OK
# will save memory.
our %EXPORT_TAGS = ( 'all' => [ qw(

) ] );

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

our @EXPORT = qw(
	_get_profile_query
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

sub _get_profile_query
{

	my ($self, $allele_type_map, $match_threshold, $max_results, $is_batch_query, $sequence_type_list, $name_list) = @_;

	$is_batch_query ||= $FALSE;

	my $result = $self->_validate($allele_type_map, $match_threshold, $max_results, $is_batch_query, $sequence_type_list, $name_list);
	return $result;

}

sub _validate
{

	my ($self, $allele_type_map, $match_threshold, $max_results, $is_batch_query, $sequence_type_list, $name_list) = @_;

	my $is_valid = $TRUE;
	my $result;
	my $loci_name_list;

	if(not $is_batch_query)
	{
		if($TESTING)
		{

			$loci_name_list = $self->{_dao_stub}->get_all_loci_names();

		}
		else
		{

			$loci_name_list = $self->{_dao}->get_all_loci_names();

		}

	}
	else{
		$loci_name_list = $name_list
	}



	if($loci_name_list and @$loci_name_list)
	{

		my $num_allele_types = scalar @{$loci_name_list};

		#do some input validation
		if((defined $allele_type_map) and (%$allele_type_map))
		{

			if((scalar keys %$allele_type_map) == $num_allele_types)
			{

				for(my $i = 0; $i < $num_allele_types; $i ++)
				{

					if((not exists $allele_type_map->{$loci_name_list->[$i]}) or (not defined $allele_type_map->{$loci_name_list->[$i]}))
					{

						$is_valid = $FALSE;

					}
					else
					{

						if($allele_type_map->{$loci_name_list->[$i]} !~ /^[0-9]\d*(\.\d{0,3})?$/)
						{
							$is_valid = $FALSE;
						}

					}

				}

			}
			else
			{

				$is_valid = $FALSE;

			}

		}
		else
		{

			$is_valid = $FALSE;

		}

		if($match_threshold =~ /^[0-9]+$/)
		{

			if($match_threshold < 0)
			{

				$is_valid = $FALSE;

			}
		}
		else
		{

			$is_valid = $FALSE;

		}

		if(not $is_batch_query)
		{
			if($TESTING)
			{

				$sequence_type_list = $self->{_dao_stub}->get_all_sequence_types();

			}
			else
			{

				$sequence_type_list = $self->{_dao}->get_all_sequence_types();

			}
		}
		if((not defined $sequence_type_list) or (scalar @{$sequence_type_list} == 0))
		{

			$is_valid = $FALSE;

		}

	}
	else
	{

		$is_valid = $FALSE;

	}

	if($is_valid)
	{

		$result = $self->_process_profile_query($allele_type_map, $match_threshold, $sequence_type_list, $max_results);

	}
	else
	{

		$result = $INVALID_VAL;

	}

	return $result;

}

sub _process_profile_query
{

	my ($self, $allele_type_map, $match_threshold, $sequence_type_list, $max_results) = @_;

	my @st_profile_list;

	my $result_counter = 0;

	#iterate each sequence type
	foreach my $st (@$sequence_type_list)
	{


		  my $allele_list = $self->{_dao}->get_allele_profile($st->{seq_type_id});

		  if($allele_list and @$allele_list)
		  {

			  my %profile_info;
			  my $counter = 0;

			  #for each sequence type, iterate over all of it's alleles
			  foreach my $allele (@$allele_list)
			  {

				  my $loci = $self->{_dao}->get_loci($allele->{loci_id});

				  if(defined $loci)
				  {
					  my $loci_name = $loci->loci_name;

					  if((exists $allele_type_map->{$loci_name}) and (defined $allele_type_map->{$loci_name}))
					  {

						  if($allele_type_map->{$loci_name} == $allele->{allele_type})
						  {

							  $counter ++;

						  }

						  $profile_info{$loci_name} = $allele->{allele_type};

					  }
					  else
					  {

						   return $INVALID_VAL;

					  }

				  }
				  else
				  {

					  return $INVALID_VAL;

				  }

			  }

			  if(($counter > 0) and ($counter >= $match_threshold))
			  {
				  $profile_info{type} = $st->{seq_type_value};
				  $profile_info{counter} = $counter;
				  push @st_profile_list, \%profile_info;

			  }

			  my $loci_count = $self->{_dao}->get_loci_name_count();



			  $counter = 0;

		  }
		  else
		  {

			  return $INVALID_VAL;

		  }

		$result_counter++;
	}

	@st_profile_list = sort {$b->{counter} <=> $a->{counter}} @st_profile_list;


	splice @st_profile_list, $max_results;

	return \@st_profile_list;

}

1;
__END__
