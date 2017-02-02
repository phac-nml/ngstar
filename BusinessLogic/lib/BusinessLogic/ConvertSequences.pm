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

package BusinessLogic::ConvertSequences;

use 5.014002;
use strict;
use warnings;

use Readonly;

use DAL::Dao;
use DAL::DaoStub;

use Bio::Seq;
use Bio::SeqIO;
use Bio::SearchIO;

require Exporter;

our @ISA = qw(Exporter);

# Items to export into callers namespace by default. Note: do not export
# names by default without a very good reason. Use EXPORT_OK instead.
# Do not simply export all your public functions/methods/constants.

# This allows declaration	use BusinessLogic::AddBatchMetadata':all';
# If you do not need this, moving things directly into @EXPORT or @EXPORT_OK
# will save memory.
our %EXPORT_TAGS = ( 'all' => [ qw(

) ] );

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

our @EXPORT = qw(
	_get_dna_sequences
	_get_onishi_sequences
	_get_protein_sequences
	_get_onishi_seq_list
	_get_loci_with_onishi_type
	_get_amino_acid_by_id
);

our $VERSION = '0.01';

Readonly my $FALSE => 0;
Readonly my $TRUE => 1;

Readonly my $INSERT_AT_575 => 579;
Readonly my $POS_575 => 575;
Readonly my $MOSAIC_NONMOSAIC_POS => 346;

Readonly my $NOT_FOUND => "Not found";

Readonly my $ONISHI_TYPE_LOCI_NAME => "penA";

sub new
{

	my $class = shift;
	my $self = {
		_dao => DAL::Dao->new(),
	};
	bless $self, $class;
	return $self;

}

#returns the length-1 of the shorter of 2 strings
#this gives us the max position to iterate up till
sub _get_max_position_of_seqs
{

	my ($self, $user_sequence, $wild_type_sequence) = @_;

	my $max_pos;

	if(length($wild_type_sequence) < length($user_sequence))
	{
		$max_pos = length($wild_type_sequence) -1;
	}
	else
	{
		$max_pos = length($user_sequence) -1;
	}

	return $max_pos;

}

#Gets the differences between the user sequence and the wild type sequence
#Returns string of differences
#Will work with nucleotide, protein, and dna seqs

sub _get_sequence_differences
{

	my ($self, $user_sequence, $wild_type_sequence) = @_;

	my $differences_in_seqs;

	my $max_seq_pos = $self->_get_max_position_of_seqs($user_sequence, $wild_type_sequence);

	my $pos = 0;

	for(0 .. $max_seq_pos)
	{
		my $char = uc(substr($user_sequence, $_, 1));

		if($char ne uc(substr($wild_type_sequence, $_, 1)))
		{
			$differences_in_seqs .= $char;
		}
		else
		{
			$differences_in_seqs .= ".";
		}
		$pos++;
	}

	# if user supplied sequence is longer than the wild type sequence
	# then copy excess user supplied sequence to differences_in_seqs array



	return $differences_in_seqs;

}

sub _get_dna_sequences
{

	my ($self, $user_sequence, $wild_type_sequence) = @_;

	my $pos = 0;
	my $differences = $self->_get_sequence_differences($user_sequence, $wild_type_sequence);


	return (uc($wild_type_sequence), uc($user_sequence), $differences);

}

sub _get_onishi_sequences
{

	my ($self, $user_sequence,  $loci_name, $allele_type) = @_;

	my $amino_acids = $self->{_dao}->get_amino_acids($loci_name);

	my $amino_acid_pos;
	my $is_mosaic;
	my $is_valid = $FALSE;
	my $probable_type = $FALSE;
	my $onishi_found = $FALSE;

	my $onishi_seq_wt = "";
	my $onishi_seq_us= "";
	my $differences= "";
	my $aapos;                   #amino acid positions retrieved from db
	my $char1;                   #character at position aapos in user protein sequence
	my $char2;                   #character stored in current amino acid object in array retrieved from db
	my $left_changes  = $FALSE;  #changes to onishi string left of position 346
	my $right_changes = $FALSE;  #changes to onishi string left of position 346

	#Convert dna sequences to protein
	my $user_seq_obj = Bio::Seq->new(-seq => $user_sequence,
						 -alphabet => 'dna' );
	$user_sequence = $user_seq_obj->translate;

	#Remove the final character of the protein sequences which is a *(stop codon) that isn't required
	$user_sequence = substr($user_sequence->seq, 0, -1);

	my $max_amino_acid_pos = $self->{_dao}->get_max_amino_acid_position($loci_name);

	if(length $user_sequence > $max_amino_acid_pos)
	{
		$is_valid = $TRUE;

		#check for mosaic
		if(uc(substr($user_sequence, $MOSAIC_NONMOSAIC_POS-1, 3 )) ne "DDT")
		{
			$user_sequence = substr($user_sequence, 0, $MOSAIC_NONMOSAIC_POS-1) . "." . substr($user_sequence, $MOSAIC_NONMOSAIC_POS-1, length $user_sequence);
		}

		#check for 575 insert
		if(uc(substr($user_sequence, $INSERT_AT_575-1, 3 )) ne "VKT")
		{
			$user_sequence = substr($user_sequence, 0, $POS_575-1) . "." . substr($user_sequence, $POS_575-1, length $user_sequence);
		}

		foreach my $amino_acid(@$amino_acids)
		{

			$aapos = $amino_acid->{aa_pos} - 1;
			$char1 = substr($user_sequence, $aapos, 1);
			$char2 = $amino_acid->{aa_char};
			$onishi_seq_wt .= $char2;
			$onishi_seq_us .= $char1;

			if(($char1 and $char2) and  ($char1 ne $char2))
			{
				if($aapos < $MOSAIC_NONMOSAIC_POS-1)
				{
					$left_changes  = $TRUE;
				}
				if($aapos > $MOSAIC_NONMOSAIC_POS-1)
				{
					$right_changes  = $TRUE;
				}
			}

		}

		#changes to left of position 346 and right of position 346
		if(($left_changes == $TRUE and $right_changes == $TRUE))
		{
			$is_mosaic = $TRUE;
		}
		else
		{
			$is_mosaic = $FALSE;
		}

		my $onishi_seqs_list = $self->_get_onishi_seq_list($loci_name);

		#If an allele type was not found in the query then the Onishi type
		#of the amino acid profile will be returned
		foreach my $onishi_seq (@$onishi_seqs_list)
		{
			if((uc($onishi_seq->{aa_profile}) eq uc($onishi_seq_us)) and ($allele_type eq ($NOT_FOUND)))
			{
				$allele_type = $onishi_seq->{onishi_type};
				$probable_type = $TRUE;
				$onishi_found = $TRUE;
				last;
			}
			elsif(uc($onishi_seq->{aa_profile}) eq uc($onishi_seq_us))
			{
				$onishi_found = $TRUE;
				last;
			}
		}

		if((uc($onishi_seq_us) ne uc($onishi_seq_wt)) and (not $onishi_found))
		{
			$allele_type = $NOT_FOUND;
			$probable_type = $FALSE;

		}

		$differences = $self->_get_sequence_differences($onishi_seq_us, $onishi_seq_wt);

	}

	return (uc($onishi_seq_wt), uc($onishi_seq_us), $differences, $is_mosaic, $allele_type, $is_valid, $probable_type);

}

sub _get_protein_sequences
{

	my ($self, $user_sequence, $wild_type_sequence) = @_;

	my @protein_seq_wt;
	my @protein_seq_us;
	my $pos = 0;
	my $differences;

	#Convert dna sequences to protein
	my $user_seq_obj = Bio::Seq->new(-seq => $user_sequence,
						 -alphabet => 'dna' );
	my $user_protein_seq = $user_seq_obj->translate;

	my $wild_type_seq_obj = Bio::Seq->new(-seq => $wild_type_sequence,
						 -alphabet => 'dna' );
	my $wild_type_protein_seq = $wild_type_seq_obj->translate;



	#Get the differences between the user and wildtype protein sequence
	$differences = $self->_get_sequence_differences($user_protein_seq->seq, $wild_type_protein_seq->seq);

	return (uc($wild_type_protein_seq->seq), uc($user_protein_seq->seq), $differences);

}

sub _check_amino_acid_profile
{

	my ($self, $user_sequence) = @_;


	my $amino_acids = $self->{_dao}->get_amino_acids($ONISHI_TYPE_LOCI_NAME);

	#Convert dna sequences to protein
	my $user_seq_obj = Bio::Seq->new(-seq => $user_sequence,
						 -alphabet => 'dna' );
	$user_sequence = $user_seq_obj->translate;

	#Remove the final character of the protein sequences which is a *(stop codon) that isn't required
	$user_sequence = substr($user_sequence->seq, 0, -1);

	my $max_amino_acid_pos = $self->{_dao}->get_max_amino_acid_position($ONISHI_TYPE_LOCI_NAME);
	my $aa_profile_exists = $FALSE;
	my $user_seq_amino_acid_profile = "";

	if(length $user_sequence > $max_amino_acid_pos)
	{

		#check for mosaic
		if(uc(substr($user_sequence, $MOSAIC_NONMOSAIC_POS-1, 3 )) ne "DDT")
		{
			$user_sequence = substr($user_sequence, 0, $MOSAIC_NONMOSAIC_POS-1) . "." . substr($user_sequence, $MOSAIC_NONMOSAIC_POS-1, length $user_sequence);
		}

		#check for 575 insert
		if(uc(substr($user_sequence, $INSERT_AT_575-1, 3 )) ne "VKT")
		{
			$user_sequence = substr($user_sequence, 0, $POS_575-1) . "." . substr($user_sequence, $POS_575-1, length $user_sequence);
		}

		my $aapos;                              #amino acid positions retrieved from db
		my $char;                               #character at position aapos in user protein sequence

		foreach my $amino_acid(@$amino_acids)
		{
			$aapos = $amino_acid->{aa_pos} - 1;
			$char = substr($user_sequence, $aapos, 1);
			$user_seq_amino_acid_profile .= $char;
		}

		$aa_profile_exists = $self->{_dao}->check_amino_acid_profile($user_seq_amino_acid_profile);

	}

	return ($aa_profile_exists, $user_seq_amino_acid_profile);

}


sub _get_onishi_seq_list
{

	my ($self, $loci_name) = @_;

	my $onishi_seqs_list = $self->{_dao}->get_onishi_sequences($loci_name);

	return $onishi_seqs_list;

}

sub _get_onishi_seq_by_id
{

	my ($self, $id) = @_;


	my $result;

	my $onishi_seq_info = $self->{_dao}->get_onishi_seq_by_id($id);

	if(@$onishi_seq_info)
	{
		$result = $onishi_seq_info
	}
	else
	{
		$result = $FALSE;
	}

	return $result;

}

sub _get_loci_with_onishi_type
{

	my ($self) = @_;

	my %onishi_type_set;
	my $loci_list = $self->{_dao}->get_all_loci();

	foreach my $loci (@$loci_list)
	{
		if($loci->{is_onishi_type})
		{

			$onishi_type_set{$loci->{loci_name}} = undef;

		}
	}

	return \%onishi_type_set;

}

sub _get_amino_acids
{
	my ($self, $loci_name) = @_;

	my $aa_list = $self->{_dao}->get_amino_acids($loci_name);

	return $aa_list;

}

sub _get_amino_acid_by_id
{

	my ($self, $id) = @_;


	my $result;

	my $amino_acid_info = $self->{_dao}->get_amino_acid_by_id($id);

	if(@$amino_acid_info)
	{
		$result = $amino_acid_info
	}
	else
	{
		$result = $FALSE;
	}

	return $result;

}

1;
__END__
