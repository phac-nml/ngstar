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

package BusinessLogic::GetAlleleInfo;
use BusinessLogic::ValidateAllele;
use BusinessLogic::GetIntegerType;

use 5.014002;
use strict;
use warnings;

use Bio::Seq;
use Bio::SeqIO;
use Bio::SearchIO;

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
	_get_all_allele_count
	_get_all_allele_length
	_get_all_loci_names
	_get_allele_details
	_get_allele_length
	_get_allele_list
	_get_loci_allele_list_length
	_get_loci_alleles
	_get_loci_alleles_format
	_get_loci_name_count
	_get_non_existant_alleles
	_get_type_by_sequence
	_get_wild_type_allele_by_loci
);

our $VERSION = '0.01';

Readonly my $FALSE => 0;
Readonly my $TRUE => 1;

Readonly my $INVALID_VAL => 0;

Readonly my $INVALID_CONST => "IS_INVALID";
Readonly my $VALID_CONST => "IS_VALID";

Readonly my $ERROR_NONEXISTANT_ALLELE => 1001;
Readonly my $ERROR_CODE_NO_LOCIS => 1018;

sub new
{

	my $class = shift;
	my $self = {
		_dao => DAL::Dao->new(),
	};
	bless $self, $class;
	return $self;

}

sub _get_all_allele_count
{

	my ($self) = @_;

	my $count = $self->{_dao}->get_all_allele_count();

	return $count;
}

sub _get_all_allele_length
{

	my ($self) = @_;

	my $result;
	my $length_list = $self->{_dao}->get_all_allele_length();

	if($length_list and @$length_list)
	{

		$result = $length_list;

	}
	else
	{

		$result = $INVALID_VAL;

	}

	return $result;

}

sub _get_all_loci_names
{

	my ($self) = @_;

	my $result;
	my $loci_name_list = $self->{_dao}->get_all_loci_names();

	if($loci_name_list and @$loci_name_list)
	{

		my @sorted_list = @$loci_name_list;
		$result = \@sorted_list;

	}
	else
	{

		$result = $ERROR_CODE_NO_LOCIS;

	}

	return $result;

}

sub _get_allele_details
{

	my ($self, $loci_name, $allele_type) = @_;

	my $is_valid = $TRUE;
	my $result;
	my $allele;

	my $obj = BusinessLogic::ValidateAllele->new();
	my $validate_result = $obj->_validate_allele_basic($loci_name, $allele_type);

	if($validate_result ne $VALID_CONST)
	{

		$is_valid = $FALSE;

	}
	if($is_valid)
	{

		$allele = $self->{_dao}->get_allele($loci_name, $allele_type);

		if(not $allele)
		{

			$is_valid = $FALSE;

		}

	}
	if($is_valid)
	{

		$result = $allele;

	}
	else
	{

		$result = $INVALID_VAL;

	}

	return $result;

}

sub _get_allele_length
{

	my ($self, $loci_name) = @_;

	my $length;
	my $is_valid = $TRUE;
	my $result;

	my $obj = BusinessLogic::ValidateAllele->new();
	my $validate_result = $obj->_validate_allele_basic($loci_name);

	if($validate_result eq $VALID_CONST)
	{

		$length = $self->{_dao}->get_allele_length($loci_name);

		if(not $length)
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

		$result = $length;

	}
	else
	{

		$result = $INVALID_VAL;

	}

	return $result;

}

sub _get_allele_list
{

	my ($self) = @_;

	my $result;
	my $allele_list = $self->{_dao}->get_allele_list();

	if($allele_list and @$allele_list)
	{

		my @sorted_list = @$allele_list;
		@sorted_list = sort {(($a->{allele_type}) <=> ($b->{allele_type})) || (lc($a->{loci_name}) cmp lc($b->{loci_name}))} @sorted_list;
		$result = \@sorted_list;

	}
	else
	{

		$result = $INVALID_VAL;

	}

	return $result;

}

sub _get_loci_allele_list_length
{

	my ($self, $loci_name) = @_;

	my $is_valid = $TRUE;
	my $length;
	my $result;

	my $obj = BusinessLogic::ValidateAllele->new();
	my $validate_result = $obj->_validate_allele_basic($loci_name);

	if($validate_result eq $VALID_CONST)
	{

		$length = $self->{_dao}->get_loci_allele_count($loci_name);

	}
	else
	{

		$is_valid = $FALSE;

	}
	if($is_valid)
	{

		$result = $length;

	}
	else
	{

		$result = 0;

	}

	return $result;

}

sub _get_loci_alleles
{

	my ($self, $loci_name) = @_;

	my $is_valid = $TRUE;
	my $result;
	my @sorted_list;

	my $obj = BusinessLogic::ValidateAllele->new();
	my $validate_result = $obj->_validate_allele_basic($loci_name);

	if($validate_result eq $VALID_CONST)
	{

		my $allele_list = $self->{_dao}->get_loci_alleles($loci_name);

		if($allele_list and @$allele_list)
		{

			@sorted_list = @$allele_list;
			 @sorted_list = sort {($a->{allele_type}) <=> ($b->{allele_type})} @sorted_list;

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
	if($is_valid)
	{

		$result = \@sorted_list;

	}
	else
	{

		$result = $INVALID_VAL;

	}

	return $result;

}

sub _get_loci_alleles_format
{

	my ($self, $loci_name) = @_;

	my $is_valid = $TRUE;
	my $result;
	my $string = "";
	my $name;

	my $obj = BusinessLogic::ValidateAllele->new();
	my $validate_result = $obj->_validate_allele_basic($loci_name);

	$obj = BusinessLogic::GetIntegerType->new();
	my $loci_int_type_set = $obj->_get_loci_with_integer_type();

	if($validate_result eq $VALID_CONST)
	{

		my $allele_list = $self->_get_loci_alleles($loci_name);

		if($allele_list and @$allele_list)
		{

			my @sorted_list = @$allele_list;
			@sorted_list = sort {($a->{allele_type}) <=> ($b->{allele_type})} @sorted_list;
			my $allele_type_format;

			foreach my $allele (@sorted_list)
			{

				$name = $allele->{loci_name};
				$allele_type_format =	$allele->{allele_type};

				if((%$loci_int_type_set) and (exists $loci_int_type_set->{$name}))
				{

					$allele_type_format = int($allele->{allele_type});

				}

				$string .= ">" . $allele->{loci_name} . $allele_type_format;
				$string .= "\n";
				$string .= uc($allele->{allele_sequence});
				$string .= "\n";

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

sub _get_loci_name_count
{

	my ($self) = @_;

	my $count = $self->{_dao}->get_loci_name_count();

	return $count;

}

sub _get_non_existant_alleles
{

	my ($self, $profile_map) = @_;

	my $loci_names;
	my @non_existant_alleles;
	my $validate_result;

	$loci_names = $self->{_dao}->get_all_loci_names();

	my $obj = BusinessLogic::ValidateSequenceTypeProfile->new();

	foreach my $name (@$loci_names)
	{

		$validate_result = $obj->_check_profile_map($profile_map, $name);

		if($validate_result eq $ERROR_NONEXISTANT_ALLELE)
		{

			push @non_existant_alleles, {loci_name => $name,
						 allele_type => $profile_map->{$name}};

		}

	}

	return \@non_existant_alleles;

}

sub _get_type_by_sequence
{

	my ($self, $loci_name, $allele_sequence) = @_;

	my $loci_id = $self->{_dao}->get_loci_id($loci_name);
	my $sequence_list = $self->{_dao}->get_all_sequences($loci_id);

	my $seq_found;
	my $seq_with_type = -1;
	my $type_found = 0;

	if(@$sequence_list)
	{

		#check that we don't add an equivalent sequence (either its identical, reverse-complement, reverse only, or complement only) more than once
		foreach my $seq (@$sequence_list)
		{

			my $seq_obj = Bio::Seq->new(-seq => $seq);
			my $reverse_complement = $seq_obj->revcom;                  #the reverse complement of the sequence
			my $reverse = scalar reverse($seq);                         #the reverse only
			my $complement = scalar reverse($reverse_complement->seq);  #the complement only (take the complement of the reverse complement)

			if((lc($allele_sequence) eq lc($seq)) or
			(lc($allele_sequence) eq lc($reverse_complement->seq)) or
			(lc($allele_sequence) eq lc($reverse)) or
			(lc($allele_sequence) eq lc($complement)))
			{

				$seq_found = $allele_sequence;

			}

		}

	}

	#$seq_with_type = $self->{_dao}->get_allele_type($loci_name,$seq_found);

	($seq_with_type,$type_found) = $self->{_dao}->get_allele_type($loci_name,$seq_found);

	return ($seq_with_type, $type_found);

}

sub _get_wild_type_allele_by_loci_id
{

	my ($self, $loci_name) = @_;

	my $result = $self->{_dao}->get_wild_type_allele_by_loci_id($loci_name);

	return $result;

}


1;
__END__
