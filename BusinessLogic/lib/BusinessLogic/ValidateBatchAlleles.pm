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

package BusinessLogic::ValidateBatchAlleles;
use BusinessLogic::ParseFasta;
use BusinessLogic::ValidateAllele;

use 5.014002;
use strict;
use warnings;

use Readonly;

require Exporter;

our @ISA = qw(Exporter);

# Items to export into callers namespace by default. Note: do not export
# names by default without a very good reason. Use EXPORT_OK instead.
# Do not simply export all your public functions/methods/constants.

# This allows declaration	use BusinessLogic::ValidateBatchAlleles':all';
# If you do not need this, moving things directly into @EXPORT or @EXPORT_OK
# will save memory.
our %EXPORT_TAGS = ( 'all' => [ qw(

) ] );

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

our @EXPORT = qw(
	_validate_batch_alleles
	_validate_batch_alleles_input
	_validate_batch_alleles_parse
);

our $VERSION = '0.01';

Readonly my $FALSE => 0;
Readonly my $TRUE => 1;

Readonly my $INVALID_CONST => "IS_INVALID";
Readonly my $VALID_CONST => "IS_VALID";

Readonly my $ERROR_LOCI_MISMATCH => 1000;
Readonly my $ERROR_BATCH_ALLELE_HEADER => 1013;
Readonly my $ERROR_DUPLICATE_TYPE_INPUT => 1022;
Readonly my $ERROR_DUPLICATE_SEQ_INPUT => 1025;

Readonly my $ERROR_NOT_FASTA_FORMAT => 5000;



sub new
{

	my $class = shift;
	my $self = {};
	bless $self, $class;
	return $self;

}

#to do: need to reevaluate this function and remove it if no longer being used
sub _validate_batch_alleles
{

	my ($self, $allele_list) = @_;

	my $invalid_code = $INVALID_CONST;
	my $is_valid = $TRUE;
	my $result;
	my $obj = BusinessLogic::ValidateAllele->new();

	if($allele_list and @$allele_list)
	{

		foreach my $allele (@$allele_list)
		{

			my $validate_result = $obj->_validate_allele($allele->{loci_name}, $allele->{allele_type}, $allele->{sequence});

			if($validate_result ne $VALID_CONST)
			{

				$is_valid = $FALSE;
				$invalid_code = $validate_result;

			}

		}

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

		$result = $invalid_code;

	}

	return $result;

}

sub _validate_batch_alleles_input
{

	my ($self, $input, $loci_name) = @_;

	#keys are the allele type and the value is the error code for the allele
	my %error_codes;
	my %allele_seq_map;
	my %allele_type_map;

	my $obj = BusinessLogic::ParseFasta->new();
	my ($is_valid, $allele_list, $invalid_allele_list) = $obj->_parse_fasta($input, $loci_name);

	if($allele_list and @$allele_list)
	{

		foreach my $allele (@$allele_list)
		{

			my $allele_seq = $allele->{sequence};
			my $allele_type = $allele->{allele_type};

			if(exists $allele_seq_map{$allele_seq})
			{

				$allele_seq_map{$allele_seq}{counter} += 1;

			}
			else
			{

				$allele_seq_map{$allele_seq} = {counter => 1, type => $allele_type};

			}
			if(exists $allele_type_map{$allele_type})
			{

				$allele_type_map{$allele_type} = $allele_type_map{$allele_type} + 1;

			}
			else
			{

				#initialize counter for this particular allele type to 1
				$allele_type_map{$allele_type} = 1;

			}

			$obj = BusinessLogic::ValidateAllele->new();

			#validate the allele against alleles stored in the database
			#(check if a submit will result in a duplicate type or sequence in the database)
			my $validate_result = $obj->_validate_allele($allele->{loci_name}, $allele->{allele_type}, $allele->{sequence});

			if($validate_result ne $VALID_CONST)
			{

				my $error_code = $validate_result;
				$error_codes{$allele_type} = $error_code;

			}

		}

	}

	#validate that all allele types in input are unique (in ValidateAllele.pm we check
	#for duplicates against allele types stored in the database only)
	my @allele_seq_exists_in_db;
	my @allele_type_seq_not_unique;
	my @allele_type_not_unique;

	foreach my $key (keys %allele_seq_map)
	{

		my $type = $allele_seq_map{$key}{type};

		if($allele_seq_map{$key}{counter} > 1)
		{

			push @allele_type_seq_not_unique, $type;

		}

	}

	if(@allele_type_seq_not_unique)
	{

		for my $item (@allele_type_seq_not_unique)
		{

			$error_codes{$item} = $ERROR_DUPLICATE_SEQ_INPUT;

		}

	}

	#add error codes for duplicate types after adding error codes for duplicate
	#sequences so that the user is prompted of a duplicate type first
	foreach my $key (keys %allele_type_map)
	{

		if($allele_type_map{$key} > 1)
		{

			push @allele_type_not_unique, $key;

		}

	}

	if(@allele_type_not_unique)
	{

		for my $item (@allele_type_not_unique)
		{

			$error_codes{$item} = $ERROR_DUPLICATE_TYPE_INPUT;

		}

	}

	if($invalid_allele_list and @$invalid_allele_list)
	{

		for my $item (@$invalid_allele_list)
		{

			$error_codes{$item->{loci_name}} = $ERROR_LOCI_MISMATCH;

		}

	}

	return \%error_codes;

}

#make sure that the input/file can be properly parsed
sub _validate_batch_alleles_parse
{

	my ($self, $input, $loci_name) = @_;

	#my $is_valid;
	my $result;

	my $obj = BusinessLogic::ParseFasta->new();
	my ($is_valid,$allele_list, $invalid_allele_list, $invalid_header) = $obj->_parse_fasta($input, $loci_name);
	#my $allele_list = $obj->_parse_fasta($input, $loci_name);

	if($allele_list and @$allele_list)
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
	elsif($invalid_header)
	{

		$result = $ERROR_BATCH_ALLELE_HEADER;

	}
	elsif($invalid_allele_list and @$invalid_allele_list)
	{

		$result = "$ERROR_LOCI_MISMATCH";

	}
	else
	{

		$result = $ERROR_NOT_FASTA_FORMAT;

	}

	return $result;

}

1;
__END__
