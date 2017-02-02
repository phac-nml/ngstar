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

package BusinessLogic::GetAlleleType;
use Catalyst qw( ConfigLoader );

use 5.014002;
use strict;
use warnings;

use Bio::Seq;
use Bio::SeqIO;
use Bio::SearchIO;

use Readonly;

use String::Random;

use DAL::Dao;
use DAL::DaoStub;

require Exporter;

our @ISA = qw(Exporter);

# Items to export into callers namespace by default. Note: do not export
# names by default without a very good reason. Use EXPORT_OK instead.
# Do not simply export all your public functions/methods/constants.

# This allows declaration	use BusinessLogic::GetAlleleType':all';
# If you do not need this, moving things directly into @EXPORT or @EXPORT_OK
# will save memory.
our %EXPORT_TAGS = ( 'all' => [ qw(

) ] );

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

our @EXPORT = qw(
	_get_allele_types
	_setup_data
	_cleanup_data
);

our $VERSION = '0.01';

my $TESTING;

Readonly my $FALSE => 0;
Readonly my $TRUE => 1;

Readonly my $INVALID_VAL => 0;

Readonly my $MAX_TOP_HITS => 1;
Readonly my $PERCENT_IDENTITY_CUTOFF => 90; #90% percent identity
Readonly my $PERCENT_IDENTITY_FULL => 100;  #100% percent identity

my $rand = new String::Random;
my $rand_str;

my $dir;
my $query_file;
my $db_file;
my $db_name;
my $blast_file;

sub new
{

	my $class = shift;
	my $self = {
		_dao => undef
	};
	bless $self, $class;
	return $self;

}

#still working on properly setting up dependency injection
sub _setup_data
{

	my ($self, $path) = @_;

	my $data_path = NGSTAR->config->{businesslogic_data_path};
	my $data_stub_path = NGSTAR->config->{businesslogic_data_stub_path};

	#setup a new random string for each time we make a call to get_allele_types
	$rand_str = $rand->randregex('\w{8}');

	if($path eq "BusinessLogic/data")
	{

		$TESTING = $FALSE;
		$self->{_dao} = DAL::Dao->new();
		$dir = $data_path;
		$query_file = "query_" . $rand_str . ".fasta";
		$db_file = "allele_db_" . $rand_str . ".fasta";
		$db_name = "allele_DB_" . $rand_str;
		$blast_file = "blast_results_" . $rand_str . ".txt";

	}
	if($path eq "BusinessLogic/data_stub")
	{

		$TESTING = $TRUE;
		$self->{_dao} = DAL::DaoStub->new();
		$dir = $data_stub_path;
		$query_file = "stub_query.fasta";
		$db_file = "stub_db.fasta";
		$db_name = "stub_DB";
		$blast_file = "stub_blast_results.txt";

	}

}

sub _cleanup_data
{

	my ($self, $path) = @_;

	my $data_path = NGSTAR->config->{businesslogic_data_path};

	if($path eq "BusinessLogic/data")
	{

		$dir = $data_path;
		$query_file = $dir . "query_" . $rand_str . ".fasta";
		$db_file = $dir . "allele_db_" . $rand_str . ".fasta";
		$db_name = $dir . "allele_DB_" . $rand_str;
		$blast_file = $dir . "blast_results_" . $rand_str . ".txt";

		unlink($query_file);
		unlink($db_file);
		unlink($blast_file);

		#clean up blast database files
		my $blastdb_nhr = $db_name . ".nhr";
		my $blastdb_nin = $db_name . ".nin";
		my $blastdb_nsq = $db_name . ".nsq";

		unlink($blastdb_nhr);
		unlink($blastdb_nin);
		unlink($blastdb_nsq);

	}

}

#sequence map is a hash table of the allele query inputted by the user with keys as the loci name and values as the query sequence
sub _get_allele_types
{

	my ($self, $sequence_map, $is_multi_query) = @_;

	my $result = $self->_validate($sequence_map, $is_multi_query);

	return $result;

}

sub _validate
{
	my ($self, $sequence_map, $is_multi_query) = @_;

	my $is_valid = $TRUE;
	my $length_result;
	my $name_list;
	my $result;

	my $size = scalar keys %$sequence_map;

	if($TESTING)
	{

		$name_list = $self->{_dao}->get_all_loci_names($size);

	}
	else
	{

		$name_list = $self->{_dao}->get_all_loci_names();

	}
	if($name_list and @$name_list)
	{

		my %loci_length_map;

		for (my $i = 0; $i < scalar @$name_list; $i ++)
		{

			$loci_length_map{$name_list->[$i]} = 0;

		}

		if((defined $sequence_map) and (%$sequence_map))
		{

			if($TESTING)
			{

				$length_result = $self->{_dao}->get_all_allele_length($sequence_map, \%loci_length_map);

			}
			else
			{

				$length_result = $self->{_dao}->get_all_allele_length(\%loci_length_map);

			}

			if($length_result)
			{


				foreach my $name (@$name_list)
				{

					if( (not $sequence_map->{$name} or $sequence_map->{$name} eq "") or ((exists $sequence_map->{$name}) and ($sequence_map->{$name})))
					{

						if(($sequence_map->{$name} and $sequence_map->{$name} ne "") and $sequence_map->{$name} !~ /^[ATCG]+$/i)
						{

							$is_valid = $FALSE;

						}

					}
					else
					{

						$is_valid = $FALSE;

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

	}
	else
	{

		$is_valid = $FALSE;

	}
	if(not $is_valid)
	{

		$result = $INVALID_VAL;

	}
	else
	{

		$result = $self->_query_type($sequence_map, $is_multi_query);

	}

	return $result;

}

sub _sort_query_results
{

	my ($self, $query_results, $is_multi_query) = @_;

	#default sorting algorithm in perl is mergesort, so the running time here is O(nlogn)
	#but this is a small array and some elements may have values (loci_id) that are the same. Also, BLAST returns results that are almost sorted (due to the order we BLAST in)
	#so we really want a sorting algorithm that is simple (not recursive which results in less overhead) and a sorting algorithm that is also stable and adaptive (since
	#the unsorted array is almost sorted). A good candidate for small arrays that may have values that are the same and are almost sorted is insertion sort.
	#but we can't specify insertion sort in the sort pragma. Typically, insertion sort is often used as the recursive base case for more complex
	#sorting algorithms with large overhead (like quicksort or mergesort).
	#most mergesort implementations are a stable sort, meaning that the order of elements with the same value is preserved (which is why
	#if loci_id and percent identities are identical, results happen to get ordered in decreasing allele type order because this is the order of the BLAST results

	#we sort according to the order of the loci in tbl_Loci, which is loci_id, in ascending order
	#we also sort according to the percent_identity for Submitted Sequence Match, in descending order
	my @sorted_results;

	if(not $is_multi_query)
	{
		@sorted_results = sort {($a->{loci_id} <=> $b->{loci_id}) || ($b->{percent_identity} <=> $a->{percent_identity})} @$query_results;
	}
	else
	{
		@sorted_results = sort {($a->{sample_number} <=> $b->{sample_number}) || ($a->{loci_id} <=> $b->{loci_id}) ||  ($b->{percent_identity} <=> $a->{percent_identity})} @$query_results;
	}

	return \@sorted_results;

}

sub _query_exact_match
{

	my ($self, $loci_name, $sequence, $query_results, $loci_not_exact_match, $is_multi_query) = @_;

	my @tokens = split /_/, $loci_name;

	my $name = $tokens[0];


	my $loci_id = $self->{_dao}->get_loci_id($name);
	my $allele_type;
	my $type_found = -1;
	my $sample_number = -1;

	if($is_multi_query)
	{
		$sample_number = $tokens[1];
	}

	($allele_type, $type_found) = $self->{_dao}->get_allele_type($name, $sequence);

	#if we find an exact match with this sequence using a sql select statement
	if($allele_type)
	{

		my $sequence_length = length($sequence);

		#return a full match
		push @$query_results, {name => $name,
							type => $allele_type,
							type_num => $allele_type,
							hsp_num_identical => $sequence_length,
							hsp_total_length => $sequence_length,
							full_subject_length => $sequence_length,
							percent_identity => $PERCENT_IDENTITY_FULL,
							full_gene_ratio => $PERCENT_IDENTITY_FULL,
							full_match => $TRUE,
							error_msg => "OK",
							loci_id => $loci_id,
							sample_number => $sample_number};

	}
	#otherwise, put loci names of the sequences without exact matches in a list in which we will have to perform a BLAST on
	else
	{

		if(defined $sequence and length $sequence)
		{

			push @$loci_not_exact_match, $loci_name;

		}

	}

}

sub _query_type
{

	my ($self, $sequence_map, $is_multi_query) = @_;

	my @query_results;
	my @loci_not_exact_match;

	if($TESTING)
	{

		my $size = scalar keys %$sequence_map;
		my $all_loci_names = $self->{_dao}->get_all_loci_names($size);
		@loci_not_exact_match = @$all_loci_names;

	}
	else
	{

		my $sequence;

		foreach my $name (keys %$sequence_map)
		{

			$sequence = $sequence_map->{$name};

			$self->_query_exact_match($name, $sequence, \@query_results, \@loci_not_exact_match, $is_multi_query);

		}

	}

	#perform a BLAST query on sequences that a we did not find exact matches for
	if(@loci_not_exact_match)
	{
		my $allele_list;
		my @loci_names_not_exact_match;

		if($is_multi_query)
		{

			my @tokens;
			my $counter = 0;

			foreach my $temp_loci(@loci_not_exact_match)
			{
				@tokens = split /_/, $temp_loci;

				$loci_names_not_exact_match[$counter] = $tokens[0];

				$counter++;

			}

			$allele_list = $self->{_dao}->get_all_alleles_by_loci(\@loci_names_not_exact_match);

		}
		else
		{
			$allele_list = $self->{_dao}->get_all_alleles_by_loci(\@loci_not_exact_match);
		}


		if($allele_list and @$allele_list)
		{

			my $seqio_obj;

			if(not $TESTING)
			{

				#create the database file
				#width is set to its maximum value so that sequences are written in a single line
				$seqio_obj = Bio::SeqIO->new(-file => ">".$dir.$db_file, -format => "fasta", -width => 32766);

				foreach my $allele (@$allele_list)
				{

					my $loci = $self->{_dao}->get_loci($allele->{loci_id});
					if(not defined $loci)
					{

						return $INVALID_VAL;

					}

					my $seqstr = $allele->{allele_sequence};
					my $id = $loci->loci_name.$allele->{allele_type};

					my $seqobj = Bio::Seq->new(-seq => $seqstr, -id => $id);
					$seqio_obj->write_seq($seqobj);

				}

				$seqio_obj->close();

			}

			my $blast_cmd = "makeblastdb -in ".$dir.$db_file." -out ".$dir.$db_name." -dbtype nucl";
			my $no_output_cmd = " > /dev/null 2>&1";
			system($blast_cmd.$no_output_cmd);

			#create query file that contains the multiple sequences to query
			$seqio_obj = Bio::SeqIO->new(-file => ">".$dir.$query_file, -format => "fasta");

			foreach my $key (@loci_not_exact_match)
			{

				my $seqstr = $sequence_map->{$key};
				my $seqobj = Bio::Seq->new(-seq => $seqstr);
				$seqio_obj->write_seq($seqobj);

			}

			$seqio_obj->close();

			#run the blast query
			$blast_cmd = "blastn -query ".$dir.$query_file." -db ".$dir.$db_name." -out ".$dir.$blast_file;
			system($blast_cmd.$no_output_cmd);

			my $parse = Bio::SearchIO->new(-file => $dir.$blast_file);

			if($is_multi_query)
			{
				foreach my $not_exact_match_loci (@loci_names_not_exact_match)
				{
					$self->_search_allele_type($parse, \@loci_names_not_exact_match, \@query_results, $is_multi_query,  \@loci_not_exact_match);
				}
			}
			else
			{
				$self->_search_allele_type($parse, \@loci_not_exact_match, \@query_results);
			}

		}
		#this means that the allele database is empty so we will return "Not Found" results for the remaining loci
		else
		{

			for (my $i = 0; $i < scalar @loci_not_exact_match; $i ++)
			{

				my $loci_name = $loci_names_not_exact_match[$i];
				my $loci_id = $self->{_dao}->get_loci_id($loci_name);

				push @query_results, {name => $loci_name,
									type => "Not found",
									type_num => -1,
									hsp_num_identical => -1,
									hsp_total_length => -1,
									full_subject_length => -1,
									percent_identity => -1,
									full_gene_ratio => -1,
									full_match => -1,
									error_msg => "Not found",
									loci_id => $loci_id};

			}

		}

	}

	my $sorted_results = $self->_sort_query_results(\@query_results, $is_multi_query);

	return $sorted_results;

}

sub _search_allele_type
{

	my ($self, $parse, $name_list, $query_results, $is_multi_query, $unmodified_name_list) = @_;

	my $counter = 0;

	#consult the blast interpretation documentation in the Documentation folder if unsure about the difference between results, hits and hsps in blast output
	#go through each result (ex. result 1 has all hits for penA, result 2 has all hits for mtrR, result 3 has all hits for porB)
	while(my $result = $parse->next_result)
	{

		my $loci_id;
		my $loci_name;
		my $full_match_found = $FALSE;
		my $partial_match_found = $FALSE;
		my $top_hsp_counter = 1;
		my $partial_match_count = 0;
		my $sample_number = -1;
		#go through all hits for a particular loci (ex. for result 1, will have hits for penA0.000, penA1.001, penA1.003)
		#hits are iterated based on percent identity in decreasing order
		while((my $hit = $result->next_hit) and (not $full_match_found) and ($top_hsp_counter <= $MAX_TOP_HITS))
		{

			my ($loci_name, $parsed_type) = ($hit->name =~ /^(.*[A-Z])([0-9]{1,3}(\.[0-9]{3})?)$/g );

			if($is_multi_query)
			{
				my @tokens;

				@tokens = split /_/, $unmodified_name_list->[$counter];
				if(lc($loci_name) eq lc($tokens[0]))
				{
					$sample_number = $tokens[1];
				}


			}

			$loci_id = $self->{_dao}->get_loci_id($loci_name);

			#the loci name must match the loci name in the labels
			#there will never be any sequences for a loci that is not
			#in the name_list because of how we define the BLAST database above
			if(lc($loci_name) eq lc($name_list->[$counter]))
			{
				#each hit usually only has one hsp (ex. hit for penA0.000 has hsp with identity=100%, hit for penA1.001 has hsp with identity=99%)
				#if there are multiple hsps, it will all with identity >= 90
				while(my $hsp = $hit->next_hsp)
				{

					#number of identical positions within the hsp and is the numerator in the Identities portion of the BLAST output
					my $hsp_num_identical = $hsp->num_identical();
					#the full length of the alignment and is the denominator in the Identities portion of the BLAST output
					my $hsp_total_length = $hsp->length('total');
					#the full length of the subject sequence
					my $full_subject_length = $hsp->subject->seqlength();
					#percent identity is $hsp_num_identical/$hsp_total_length
					my $percent_identity = $hsp->percent_identity;

					my $full_gene_ratio = 0;
					if($percent_identity >= $PERCENT_IDENTITY_CUTOFF)
					{

						if($hsp_total_length > 0 and $full_subject_length > 0)
						{

							#hsp_total_length > full_subject_length if there are any insertions in the query sequence
							#set full_gene_ratio to percent identity if hsp_total_length > full_subject_length because
							#we want to return a partial match if there is an insertion in the query sequence
							#we are setting the denominator of the ratio to the length of the subject query that has been
							#extended since its been aligned with a query sequence with an insertion
							if($hsp_total_length > $full_subject_length)
							{

								$full_gene_ratio = $percent_identity;

							}
							else
							{

								$full_gene_ratio = ($hsp_num_identical/$full_subject_length) * 100;

							}

						}
						else
						{

							#can't divide by zero
							return $INVALID_VAL;

						}

						#got a partial match since percent_identity >= 90%
						$partial_match_found = $TRUE;

						#check if we get a full gene match (get a full match with a sequence in the database)
						my $is_full = $FALSE;
						if($full_gene_ratio >= $PERCENT_IDENTITY_FULL)
						{

							$is_full = $TRUE;
							$full_match_found = $TRUE;

						}

						#get the allele type
						my ($parsed_loci_name, $type) = ($hit->name =~ /^(.*[A-Z])([0-9]{1,3}(\.[0-9]{3})?)$/g );

						#return a partial match or a full match depending on the value of is_full
						push @$query_results, {name => $loci_name,
											type => $type,
											type_num => $type,
											hsp_num_identical => $hsp_num_identical,
											hsp_total_length => $hsp_total_length,
											full_subject_length => $full_subject_length,
											percent_identity => $percent_identity,
											full_gene_ratio => $full_gene_ratio,
											full_match => $is_full,
											error_msg => "OK",
											loci_id => $loci_id,
											sample_number => $sample_number};
						$top_hsp_counter ++;

					}

				}

			}
		}

		#if could not find at least one partial match, then return not found
		if(not $partial_match_found)
		{

			my @tokens;

			if($is_multi_query)
			{

				@tokens = split /_/, $unmodified_name_list->[$counter];

			}

			$loci_name = $name_list->[$counter];

			if($is_multi_query)
			{
				if(lc($loci_name) eq lc($tokens[0]))
				{
					$sample_number = $tokens[1];

				}
			}

			$loci_id = $self->{_dao}->get_loci_id($loci_name);

			push @$query_results, {name => $loci_name,
								type => "Not found",
								type_num => -1,
								hsp_num_identical => -1,
								hsp_total_length => -1,
								full_subject_length => -1,
								percent_identity => -1,
								full_gene_ratio => -1,
								full_match => -1,
								error_msg => "Not found",
								loci_id => $loci_id,
								sample_number => $sample_number};

		}

		$counter ++;

	}

}

1;
__END__
#Why do I get a "Setting ABSTRACT via file ... failed" error when I remove these comments?
# Below is stub documentation for your module. You'd better edit it!

=head1 NAME

BusinessLogic::GetAlleleType - Perl extension for blah blah blah

=head1 SYNOPSIS

use BusinessLogic::GetAlleleType;
blah blah blah

=head1 DESCRIPTION

Stub documentation for BusinessLogic::GetAlleleType, created by h2xs. It looks like the
author of the extension was negligent enough to leave the stub
unedited.

Blah blah blah.

=head2 EXPORT

None by default.

=head1 SEE ALSO

Mention other useful documentation such as the documentation of
related modules or operating system documentation (such as man pages
in UNIX), or any relevant external documentation such as RFCs or
standards.

If you have a mailing list set up for your module, mention it here.

If you have a web site set up for your module, mention it here.

=head1 AUTHOR

Irish Medina, E<lt>irish_m@E<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2014 by Irish Medina

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.14.2 or,
at your option, any later version of Perl 5 you may have available.


=cut
