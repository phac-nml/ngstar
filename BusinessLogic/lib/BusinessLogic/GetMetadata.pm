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

package BusinessLogic::GetMetadata;

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

# This allows declaration	use BusinessLogic::GetMetadata':all';
# If you do not need this, moving things directly into @EXPORT or @EXPORT_OK
# will save memory.
our %EXPORT_TAGS = ( 'all' => [ qw(

) ] );

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

our @EXPORT = qw(
	_get_all_isolate_classifications
	_get_allele_metadata
	_get_metadata
	_get_metadata_classifications
	_get_metadata_interpretations
	_get_metadata_mics
	_get_mic_antimicrobial_names
	_get_profile_metadata
);

our $VERSION = '0.01';

Readonly my $MODE_ALLELE_METADATA => 3;
Readonly my $MODE_PROFILE_METADATA => 2;

Readonly my $FALSE => 0;
Readonly my $TRUE => 1;

Readonly my $INVALID_VAL => 0;

Readonly my $INVALID_CONST => "IS_INVALID";
Readonly my $VALID_CONST => "IS_VALID";

Readonly my $NUM_ANTIBIOTICS => 8;

sub new
{

	my $class = shift;
	my $self = {
		_dao => DAL::Dao->new(),
	};
	bless $self, $class;
	return $self;

}

sub _get_all_isolate_classifications
{

	my ($self) = @_;

	my $result;
	my $classification_list = $self->{_dao}->get_all_isolate_classifications();

	if($classification_list and @$classification_list)
	{

		my @sorted_list = @$classification_list;

		@sorted_list = sort {lc($a->{classification_code}) cmp lc($b->{classification_code})} @sorted_list;
		$result = \@sorted_list;

	}
	else
	{

		$result = $INVALID_VAL;

	}

	return $result;

}

sub _get_allele_metadata
{

	my ($self, $loci_name, $localized_header) = @_;

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

		$obj = BusinessLogic::GetAlleleInfo->new();
		my $allele_list = $obj->_get_loci_alleles($loci_name);

		if($allele_list and @$allele_list)
		{

			#my $allele_type_format;
			my $allele_type;

		$string .= $localized_header;



			foreach my $allele (@$allele_list)
			{

				if((%$loci_int_type_set) and (exists $loci_int_type_set->{$loci_name}))
				{

					$allele_type = int($allele->{allele_type});

				}
				else
				{

					$allele_type = $allele->{allele_type};

				}

				my $metadata = $self->{_dao}->get_metadata($allele->{metadata_id});
				my $classifications = $self->_get_metadata_classifications($allele_type, $loci_name);
				my $interpretations = $self->_get_metadata_interpretations($allele_type, $loci_name);
				my $mics = $self->_get_metadata_mics($allele_type, $loci_name);

				$string .=  $allele_type."\t".$metadata->{amr_markers}."\t".$metadata->{collection_date}."\t".$metadata->{country};


				if($metadata->{patient_age} == 0)
				{

					$string .= "\t";

				}
				else
				{

					$string .= "\t".$metadata->{patient_age}

				}

				$string .= "\t".$metadata->{patient_gender}."\t".$metadata->{beta_lactamase}."\t";

				if(@$classifications)
				{

					my $size = scalar @$classifications;
					my $count = 0;

					foreach my $classification (@$classifications)
					{

						if($count == ($size - 1))
						{

							$string .= $classification->{classification_code}."\t";

						}
						elsif($count < $size)
						{

							$string .= $classification->{classification_code}."/";

						}

						$count++;

					}

				}
				else
				{

					$string .= "\t";

				}

				$string .=  $metadata->{mics_determined_by}."\t";

				if($metadata->{mics_determined_by} eq (""))
				{

					for(my $i = 0; $i<$NUM_ANTIBIOTICS; $i++)
					{

						$string .= "\t";

					}
				}
				elsif($metadata->{mics_determined_by} eq ("Disc Diffusion"))
				{

					foreach my $interpretation (@$interpretations)
					{

						$string .= $interpretation->{interpretation_value}."\t";

					}

				}
				else
				{

					foreach my $mic (@$mics)
					{

						if($mic->{mic_comparator} eq "le")
						{

							$string .= "<=".$mic->{mic_value}."\t";

						}
						elsif($mic->{mic_comparator} eq "ge")
						{

							$string .= ">=".$mic->{mic_value}."\t";

						}
						elsif($mic->{mic_comparator} eq "lt")
						{

							$string .= "<".$mic->{mic_value}."\t";

						}
						elsif($mic->{mic_comparator} eq "gt")
						{

							$string .= ">".$mic->{mic_value}."\t";

						}
						else
						{

							$string .= $mic->{mic_value}."\t";

						}

					}

				}

				$string .=  $metadata->{epi_data}."\t".$metadata->{curator_comment};
				#$string .= $metadata->{country};
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

sub _get_metadata
{

	my ($self, $type, $loci_name) = @_;

	my $is_valid = $TRUE;
	my $result;
	my $metadata;
	my $metadata_id;

	if(@_ == $MODE_ALLELE_METADATA)
	{

		$metadata_id = $self->_get_metadata_id($type, $loci_name);

	}
	elsif(@_ == $MODE_PROFILE_METADATA)
	{

		$metadata_id = $self->_get_metadata_id($type);

	}
	else
	{

		$is_valid = $FALSE;

	}
	if($metadata_id)
	{

		$metadata = $self->{_dao}->get_metadata($metadata_id);

		if(not $metadata)
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

		$result = $metadata;

	}
	else
	{

		$result = $INVALID_VAL;

	}

	return $result;

}

sub _get_metadata_id
{

	my ($self, $type, $loci_name) = @_;

	my $is_valid = $TRUE;
	my $result;
	my $metadata_id;

	if(@_ == $MODE_ALLELE_METADATA)
	{

		my $allele = $self->{_dao}->get_allele($loci_name, $type);

		if($allele)
		{

			$metadata_id = $allele->metadata_id;

		}
		else
		{

			$is_valid = $FALSE;

		}

	}
	elsif(@_ == $MODE_PROFILE_METADATA)
	{

		my $sequence_type = $self->{_dao}->get_sequence_type($type);

		if($sequence_type)
		{

			$metadata_id = $sequence_type->metadata_id;

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

		$result = $metadata_id;

	}
	else
	{

		$result = $INVALID_VAL;

	}

	return $result;

}

sub _get_metadata_classifications
{

	my ($self, $type, $loci_name) = @_;

	my $is_valid = $TRUE;
	my $result;
	my $metadata_id;
	my $classification_list;

	if(@_ == $MODE_ALLELE_METADATA)
	{

		$metadata_id = $self->_get_metadata_id($type, $loci_name);

	}
	elsif(@_ == $MODE_PROFILE_METADATA)
	{

		$metadata_id = $self->_get_metadata_id($type);

	}
	else
	{

		$is_valid = $FALSE;

	}

	if($metadata_id)
	{

		$classification_list = $self->{_dao}->get_metadata_classifications($metadata_id);

		if(not $classification_list)
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

		$result = $classification_list;

	}
	else
	{

		$result = $INVALID_VAL;

	}

	return $result;

}

sub _get_metadata_interpretations
{

	my ($self, $type, $loci_name) = @_;

	my $is_valid = $TRUE;
	my $result;
	my $metadata_id;
	my $interpretation_list;

	if(@_ == $MODE_ALLELE_METADATA)
	{

		$metadata_id = $self->_get_metadata_id($type, $loci_name);

	}
	else
	{

		$is_valid = $FALSE;

	}
	if($metadata_id)
	{

		$interpretation_list = $self->{_dao}->get_metadata_interpretations($metadata_id);

		if(not $interpretation_list)
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

		$result = $interpretation_list;

	}
	else
	{

		$result = $INVALID_VAL;

	}

	return $result;

}

sub _get_metadata_mics
{

	my ($self, $type, $loci_name) = @_;

	my $is_valid = $TRUE;
	my $result;
	my $metadata_id;
	my $mic_list;

	if(@_ == $MODE_ALLELE_METADATA)
	{

		$metadata_id = $self->_get_metadata_id($type, $loci_name);

	}
	elsif(@_ == $MODE_PROFILE_METADATA)
	{

		$metadata_id = $self->_get_metadata_id($type);

	}
	else
	{

		$is_valid = $FALSE;

	}

	if($metadata_id)
	{

		$mic_list = $self->{_dao}->get_metadata_mics($metadata_id);

		if(not $mic_list)
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

		$result = $mic_list;

	}
	else
	{

		$result = $INVALID_VAL;

	}

	return $result;

}

sub _get_mic_antimicrobial_names
{

	my ($self) = @_;

	my $result;
	my $name_list = $self->{_dao}->get_mic_antimicrobial_names();

	if($name_list and @$name_list)
	{

		my @sorted_list = @$name_list;

		@sorted_list = sort {lc($a) cmp lc($b)} @sorted_list;
		$result = \@sorted_list;

	}
	else
	{

		$result = $INVALID_VAL;

	}

	return $result;

}

sub _get_profile_metadata
{

	my ($self, $localized_header) = @_;

	my $is_valid = $TRUE;
	my $result;
	my $string = "";
	my $name;

	if($is_valid)
	{

		my $obj = BusinessLogic::GetSequenceTypeInfo->new();
		my $profile_list = $self->{_dao}->get_all_sequence_types();

		if($profile_list and @$profile_list)
		{

			$string .= $localized_header;

			foreach my $profile (@$profile_list)
			{

				my $metadata = $self->{_dao}->get_metadata($profile->{metadata_id});
				my $classifications = $self->_get_metadata_classifications($profile->{seq_type_value});
				my $mics = $self->_get_metadata_mics($profile->{seq_type_value});

				$string .=  $profile->{seq_type_value}."\t".$metadata->{amr_markers}."\t".$metadata->{collection_date}."\t".$metadata->{country};

				if($metadata->{patient_age} == 0)
				{

					$string .= "\t";

				}
				else
				{

					$string .= "\t".$metadata->{patient_age};

				}

				$string .= "\t".$metadata->{patient_gender}."\t".$metadata->{beta_lactamase}."\t";

				if(@$classifications)
				{

					my $size = scalar @$classifications;
					my $count = 0;

					foreach my $classification (@$classifications)
					{

						if($count == ($size - 1))
						{

							$string .= $classification->{classification_code}."\t";

						}
						elsif($count < $size)
						{

							$string .= $classification->{classification_code}."/";

						}

						$count++;

					}

				}
				else
				{

					$string .= "\t";

				}

				foreach my $mic (@$mics)
				{

					if($mic->{mic_comparator} eq "le")
					{

						$string .= "<=".$mic->{mic_value}."\t";

					}
					elsif($mic->{mic_comparator} eq "ge")
					{

						$string .= ">=".$mic->{mic_value}."\t";

					}
					elsif($mic->{mic_comparator} eq "lt")
					{

						$string .= "<".$mic->{mic_value}."\t";

					}
					elsif($mic->{mic_comparator} eq "gt")
					{

						$string .= ">".$mic->{mic_value}."\t";

					}
					else
					{

						$string .= $mic->{mic_value}."\t";

					}

				}

				$string .=  $metadata->{epi_data}."\t".$metadata->{curator_comment};
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

1;
__END__
