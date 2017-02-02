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

package BusinessLogic::ParseFasta;

use 5.014002;
use strict;
use warnings;

use Bio::SeqIO;
use Readonly;

require Exporter;

our @ISA = qw(Exporter);

# Items to export into callers namespace by default. Note: do not export
# names by default without a very good reason. Use EXPORT_OK instead.
# Do not simply export all your public functions/methods/constants.

# This allows declaration	use BusinessLogic::ParseFasta':all';
# If you do not need this, moving things directly into @EXPORT or @EXPORT_OK
# will save memory.
our %EXPORT_TAGS = ( 'all' => [ qw(

) ] );

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

our @EXPORT = qw(
	_parse_fasta
	_parse_fasta_batch_query_alleles
);

our $VERSION = '0.01';

Readonly my $FALSE => 0;
Readonly my $TRUE => 1;

Readonly my $INVALID_CONST => "IS_INVALID";
Readonly my $VALID_CONST => "IS_VALID";

Readonly my $MULTIPLE_ALLELES_SAME_LOCI => 0;
Readonly my $MULTIPLE_ALLELES_MULTIPLE_LOCI => 1;
Readonly my $SINGLE_ALLELES_MULTIPLE_LOCI => 2;
Readonly my $SINGLE_ALLELE_SINGLE_LOCI => 3;

sub new
{

	my $class = shift;
	my $self = {
		_dao => DAL::Dao->new(),
	};
	bless $self, $class;
	return $self;

}

sub _get_query_state
{

	my ($self, $input) = @_;

	my $state = undef;

	my $loci_name_list = $self->{_dao}->get_all_loci_names();
	my %loci_names = map { $_ => 1 } @$loci_name_list;

	my $validate_result = $self->_validate($input);

	my %loci_counter;
	my $format = "fasta";
	my $seqio_obj;
	my $is_valid = $TRUE;
	my $loci_name_to_test;
	my $invalid_loci_name = $FALSE;
	my $invalid_header = $FALSE;

	if($validate_result)
	{

		my $stringfh;
		open($stringfh, "<", \$input) or die "Could not open fasta string for reading: $!";
		$seqio_obj = Bio::SeqIO->new(-fh => $stringfh, -format => $format);

		#issue: when newlines are not inserted properly it will not parse the file properly (user should be responsible for this)
		#an exception will be thrown if the input is not in proper fasta format
		eval
		{

			my @tokens;
			my $parsed_loci_name;
			my $allele_type;

			while ((my $seq_obj = $seqio_obj->next_seq) and (not $invalid_loci_name) and (not $invalid_header))
			{


				($loci_name_to_test) = ($seq_obj->id =~ /^(.*[A-Za-z])/g);

				if($loci_name_to_test)
				{

					if(exists($loci_names{$loci_name_to_test}))
					{

						if($seq_obj->id =~ /^(.*[A-Za-z])$/)
						{
							($parsed_loci_name) = ($seq_obj->id =~ /^(.*[A-Za-z])$/g );
						}
						elsif($seq_obj->id =~ /^(.*[A-Za-z])(\_)([0-9])+$/)
						{
							@tokens = split /_/, $seq_obj->id;
							$parsed_loci_name = $tokens[0];
						}
						elsif($seq_obj->id =~ /^(.*[A-Za-z])([0-9]{1,3}(\.[0-9]{0,3})?)$/)
						{
							($parsed_loci_name, $allele_type) = ($seq_obj->id =~ /^(.*[A-Za-z])([0-9]{1,3}(\.[0-9]{0,3})?)$/g);
						}
						elsif($seq_obj->id =~ /^(.*[A-Za-z])([0-9]{1,9})$/)
						{
							($parsed_loci_name, $allele_type) = ($seq_obj->id =~ /^(.*[A-Za-z])([0-9]{1,9})$/g);
						}

						if(($parsed_loci_name) and (exists($loci_names{$parsed_loci_name})))
						{
							$loci_counter{$parsed_loci_name}{counter} += 1;
						}

					}
					else
					{
						$invalid_loci_name = $TRUE;
					}

				}
				else
				{
					$invalid_header = $TRUE;

				}

			}

		};

		#handle the exception
		if($@)
		{

			$is_valid = $FALSE;

		}

	}
	else
	{
		$is_valid = $FALSE;
	}

	if((not $invalid_loci_name) and (not $invalid_header))
	{

		my $single_loci_name;

		if(keys %loci_counter == 1)
		{
			#get key name at position 0. Safe to use here since there is only one element in the hash.
			$single_loci_name = (%loci_counter)[0];

			if($loci_counter{$single_loci_name}{counter} > 1)
			{
				$state = $MULTIPLE_ALLELES_SAME_LOCI;
			}
			elsif($loci_counter{$single_loci_name}{counter} == 1)
			{
				$state = $SINGLE_ALLELE_SINGLE_LOCI;
			}

		}
		elsif(keys %loci_counter > 1)
		{

			my @loci_names = keys %loci_counter;
			my $found = $FALSE;

			if(keys %loci_counter > 1)
			{

				foreach my $loci_name (@loci_names)
				{
					if($loci_counter{$loci_name}{counter} > 1)
					{
						$state = $MULTIPLE_ALLELES_MULTIPLE_LOCI;
						$found=$TRUE;
					}

				}

			}
			if(keys %loci_counter > 1 && not $found)
			{
				foreach my $loci_name (@loci_names)
				{
					if($loci_counter{$loci_name}{counter} == 1)
					{
						$state = $SINGLE_ALLELES_MULTIPLE_LOCI;
					}

				}
			}

		}

	}

	return ($state, $invalid_header, $invalid_loci_name);

}

sub _parse_fasta
{

	my ($self, $input, $loci_name) = @_;

	my $is_valid = $TRUE;
	my $invalid_header = $FALSE;
	my $result;
	my @allele_list;
	my @invalid_allele_list;
	my $format = "fasta";
	my $seqio_obj;
	my $validate_result = $self->_validate($input);

	if($validate_result)
	{

		my $stringfh;
		open($stringfh, "<", \$input) or die "Could not open fasta string for reading: $!";
		$seqio_obj = Bio::SeqIO->new(-fh => $stringfh, -format => $format);

		#issue: when newlines are not inserted properly it will not parse the file properly (user should be responsible for this)
		#an exception will be thrown if the input is not in proper fasta format
		eval
		{

			while (my $seq_obj = $seqio_obj->next_seq)
			{

				my $sequence;

				my ($parsed_loci_name, $allele_type) = ($seq_obj->id =~ /^(.*[A-Za-z])([0-9]{1,3}(\.[0-9]{0,3})?)$/g );

				if($parsed_loci_name)
				{

					if(lc($parsed_loci_name) eq lc($loci_name))
					{

						$sequence = $seq_obj->seq;

						push @allele_list, {loci_name => $loci_name,
											allele_type => $allele_type,
											sequence => $sequence};

					}
					else
					{

						$sequence = $seq_obj->seq;

						push @invalid_allele_list, {loci_name => $parsed_loci_name,
											allele_type => $allele_type,
											sequence => $sequence};

					}

				}
				else
				{

					$invalid_header = $TRUE;

				}

			}

		};

		#handle the exception
		if($@)
		{

			$is_valid = $FALSE;

		}

	}
	else
	{

		$is_valid = $FALSE;

	}

	return ($is_valid, \@allele_list, \@invalid_allele_list, $invalid_header);
	#return $result;

}

sub _parse_fasta_batch_query_alleles
{

	my ($self, $input) = @_;

	my $is_valid = $TRUE;
	my $invalid_sample_number = $FALSE;
	my $invalid_sequence = $FALSE;
	my $result;
	my %sequence_map;
	my @invalid_allele_list;
	my $format = "fasta";
	my $seqio_obj;
	my $validate_result = $self->_validate($input);
	my $query_state;
	my $invalid_header;
	my $invalid_loci_name;

	if($validate_result)
	{

		($query_state, $invalid_header, $invalid_loci_name) = $self->_get_query_state($input);

		if(not $invalid_header)
		{
			if(not $invalid_loci_name)
			{

				my $stringfh;
				open($stringfh, "<", \$input) or die "Could not open fasta string for reading: $!";
				$seqio_obj = Bio::SeqIO->new(-fh => $stringfh, -format => $format);

				if($query_state == $SINGLE_ALLELES_MULTIPLE_LOCI or $query_state == $SINGLE_ALLELE_SINGLE_LOCI)
				{
					#issue: when newlines are not inserted properly it will not parse the file properly (user should be responsible for this)
					#an exception will be thrown if the input is not in proper fasta format
					eval
					{

						while (my $seq_obj = $seqio_obj->next_seq)
						{
							my @tokens;
							my $parsed_loci_name;
							my $allele_type;

							my $sequence;

							if($seq_obj->id =~ /^(.*[A-Za-z])$/)
							{
								($parsed_loci_name) = ($seq_obj->id =~ /^(.*[A-Za-z])$/g );
							}
							elsif($seq_obj->id =~ /^(.*[A-Za-z])(\_)([0-9])+$/)
							{
								@tokens = split /_/, $seq_obj->id;
								$parsed_loci_name = $tokens[0];
							}
							elsif($seq_obj->id =~ /^(.*[A-Za-z])([0-9]{1,3}(\.[0-9]{0,3})?)$/)
							{
								($parsed_loci_name,$allele_type) = $seq_obj->id =~ /^(.*[A-Za-z])([0-9]{1,3}(\.[0-9]{0,3})?)$/g;
							}

							if($parsed_loci_name)
							{
									$sequence = $seq_obj->seq;

									if($sequence ne "" and $sequence =~ /^[ATCG]+$/i)
									{
										$sequence_map{$parsed_loci_name} = $sequence;
									}
									else
									{
										$invalid_sequence = $TRUE;
									}

							}
							else
							{
								$invalid_header = $TRUE;
								last;
							}

						}

					};

				}
				elsif($query_state == $MULTIPLE_ALLELES_SAME_LOCI or $query_state == $MULTIPLE_ALLELES_MULTIPLE_LOCI)
				{
					eval
					{

						while (my $seq_obj = $seqio_obj->next_seq)
						{

							my $sequence;
							my @tokens;
							my $parsed_loci_name;
							my $sample_number;

							if($seq_obj->id =~ /^(.*[A-Za-z])([0-9]{1,9})$/)
							{

								($parsed_loci_name, $sample_number) = ($seq_obj->id =~ /^(.*[A-Za-z])([0-9]{1,9})$/g );

							}
							elsif($seq_obj->id =~ /^(.*[A-Za-z])([\_]{1})([0-9]{1,9})+$/)
							{
								@tokens = split /_/, $seq_obj->id;
								$parsed_loci_name = $tokens[0];
								$sample_number = $tokens[1];
							}

							if(($seq_obj->id =~ /^(.*[A-Za-z])([0-9]{1,3}(\.[0-9]{0,3}))$/) or (($parsed_loci_name) and (($sample_number >= 0) and ($sample_number < 1))))
							{
								$invalid_sample_number = $TRUE;
								last;

							}
							elsif($parsed_loci_name && $sample_number >= 1 )
							{

								my $loci_accessor = $parsed_loci_name."_".$sample_number;

								$sequence = $seq_obj->seq;

								if($sequence ne "" and $sequence =~ /^[ATCG]+$/i)
								{
									$sequence_map{$loci_accessor} = $sequence;
								}
								else
								{
									$invalid_sequence = $TRUE;
								}


							}
							else
							{
								$invalid_header = $TRUE;
								last;
							}

						}

					};

				}
				else
				{

					$is_valid=$FALSE;

				}

				#handle the exception
				if($@)
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

	return ($is_valid, \%sequence_map, $query_state, $invalid_sample_number, $invalid_header, $invalid_loci_name, $invalid_sequence);


}

#a more thorough validation should be done in the code that calls parse_fasta
sub _validate
{

	my ($self, $input) = @_;

	my $is_valid = $TRUE;
	$input =~ s/(\s+)//g;   #remove any whitespaces

	if($input !~ /([(>)|(A-Z)|(\_)|(\d)|(\.)]+)/i)
	{

		$is_valid = $FALSE;

	}

	return $is_valid;

}

1;
__END__
