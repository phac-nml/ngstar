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

package BusinessLogic::BatchAddAllele;
use BusinessLogic::AddAllele;
use BusinessLogic::ParseFasta;
use BusinessLogic::ValidateAllele;
use BusinessLogic::ValidateBatchAlleles;

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

# This allows declaration	use BusinessLogic::BatchAddAllele':all';
# If you do not need this, moving things directly into @EXPORT or @EXPORT_OK
# will save memory.
our %EXPORT_TAGS = ( 'all' => [ qw(

) ] );

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

our @EXPORT = qw(
	_batch_add_allele
);

our $VERSION = '0.01';

Readonly my $TESTING => 0;

Readonly my $FALSE => 0;
Readonly my $TRUE => 1;

Readonly my $INVALID_CONST => "IS_INVALID";
Readonly my $VALID_CONST => "IS_VALID";

Readonly my $ERROR_LOCI_MISMATCH => 1000;

Readonly my $ERROR_NOT_FASTA_FORMAT => 5000;


sub new
{

	my $class = shift;
	my $self = {
		_dao => DAL::Dao->new(),
	};
	bless $self, $class;
	return $self;

}

sub _batch_add_allele
{

	my ($self, $input, $loci_name) = @_;

	my $invalid_code = $INVALID_CONST;
	my $is_valid = $TRUE;
	my $result;

	my $obj = BusinessLogic::ParseFasta->new();
	my ($successful_parse,$allele_list, $invalid_allele_list, $invalid_header) = $obj->_parse_fasta($input, $loci_name);

	if(not $allele_list and not $invalid_allele_list)
	{

		$is_valid = $FALSE;
		$invalid_code = $ERROR_NOT_FASTA_FORMAT;

	}
	elsif(not $allele_list and $invalid_allele_list)
	{

		$is_valid = $FALSE;
		$invalid_code = $ERROR_LOCI_MISMATCH;

	}
	else
	{

		$obj = BusinessLogic::ValidateBatchAlleles->new();
		my $validate_result = $obj->_validate_batch_alleles($allele_list);

		if($validate_result eq $VALID_CONST)
		{

			$obj = BusinessLogic::GetMetadata->new();
			my $antimicrobial_name_list = $obj->_get_mic_antimicrobial_names();
			$obj = BusinessLogic::AddAllele->new();

			#metadata values will be empty default values
			my $country = undef;
			my $patient_age = undef;
			my $patient_gender = 'U';
			my $epi_data = undef;
			my $curator_comment = undef;
			my $beta_lactamase = "Unknown";
			my $classification_code = "Unknown";
			my %mic_map;

			foreach my $name (@$antimicrobial_name_list)
			{

				$mic_map{$name}{mic_comparator} = "=";
				$mic_map{$name}{mic_value} = 0;

			}

			foreach my $allele (@$allele_list)
			{

				my $add_result = $obj->_add_allele($allele->{loci_name}, $allele->{allele_type}, $allele->{sequence}, $country, $patient_age, $patient_gender, $epi_data, $curator_comment, $beta_lactamase, $classification_code, \%mic_map);

				if($add_result ne $VALID_CONST)
				{

					$is_valid = $FALSE;
					$invalid_code = $add_result;

				}

			}

		}
		else
		{

			$is_valid = $FALSE;
			$invalid_code = $validate_result;

		}

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
