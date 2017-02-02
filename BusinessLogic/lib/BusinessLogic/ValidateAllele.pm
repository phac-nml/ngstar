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

package BusinessLogic::ValidateAllele;
use BusinessLogic::GetSequenceTypeInfo;
use BusinessLogic::GetIntegerType;

use 5.014002;
use strict;
use warnings;

use Bio::Perl;
use Readonly;

use DAL::Dao;
use DAL::DaoStub;

require Exporter;

our @ISA = qw(Exporter);

# Items to export into callers namespace by default. Note: do not export
# names by default without a very good reason. Use EXPORT_OK instead.
# Do not simply export all your public functions/methods/constants.

# This allows declaration	use BusinessLogic::ValidateAllele':all';
# If you do not need this, moving things directly into @EXPORT or @EXPORT_OK
# will save memory.
our %EXPORT_TAGS = ( 'all' => [ qw(

) ] );

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

our @EXPORT = qw(
	_validate_allele
	_validate_allele_basic
);

our $VERSION = '0.01';

Readonly my $FALSE => 0;
Readonly my $TRUE => 1;

Readonly my $INVALID_CONST => "IS_INVALID";
Readonly my $VALID_CONST => "IS_VALID";

Readonly my $ERROR_DUPLICATE_SEQ => 1002;
Readonly my $ERROR_DUPLICATE_TYPE => 1003;
Readonly my $ERROR_IN_PROFILE => 2000;
Readonly my $ERROR_INVALID_TYPE => 1004;
Readonly my $ERROR_INVALID_LOCI_NAME => 1005;

Readonly my $ERROR_PENA_SEQ => 1006;
Readonly my $ERROR_MTRR_SEQ => 1007;
Readonly my $ERROR_PORB_SEQ => 1008;
Readonly my $ERROR_PONA_SEQ => 1009;
Readonly my $ERROR_GYRA_SEQ => 1010;
Readonly my $ERROR_PARC_SEQ => 1011;
Readonly my $ERROR_23S_SEQ => 1012;

#this offset allows curators to also include sequences with primers at the ends
Readonly my $OFFSET => 50;

sub new
{

	my $class = shift;
	my $self;
	$self = {
		_dao => DAL::Dao->new(),
	};
	bless $self, $class;
	return $self;

}

#a basic validate allele that checks loci_name and allele_type only
sub _validate_allele_basic
{

	my ($self, $loci_name, $allele_type) = @_;

	Readonly my $ALL_PARAMS => 3;       #pass all 3 parameters
	my $is_valid = $TRUE;
	my $result;
	my $value;

	if(not $loci_name)
	{

		$is_valid = $FALSE;

	}

	if($is_valid)
	{

		my $validate_result = $self->_check_loci_name($loci_name);

		if(not $validate_result)
		{

			$is_valid = $FALSE;

		}

	}

	if(@_ == $ALL_PARAMS)
	{

		$value = $self->_check_allele_type($allele_type,$loci_name);

		if($value ne $VALID_CONST)
		{

			$is_valid = $FALSE;

		}

	}

	if($is_valid)
	{

		$result = $VALID_CONST;

	}
	else
	{

		$result = $INVALID_CONST;

	}

	return $result;

}

#validate alleles for add and edit
sub _validate_allele
{

	my ($self, $loci_name_new, $allele_type_new, $allele_sequence, $loci_name_prev, $allele_type_prev) = @_;

	Readonly my $ADD_ALLELE_MODE => 4;  #4 parameters passed for validating allele to add
	Readonly my $EDIT_ALLELE_MODE => 6; #6 parameters passed for validating allele to edit
	my $count;
	my $has_sequence = $FALSE;
	my $has_type_duplicate = $FALSE;
	my $found_name_new = $FALSE;
	my $found_name_prev = $FALSE;
	my $in_profile = $FALSE;
	my $invalid_type = $FALSE;
	my $invalid_loci_name = $FALSE;
	my $invalid_sequence = $FALSE;
	my $is_valid = $TRUE;
	my $result;
	my $value;
	my $seq_error;

	if((@_ == $EDIT_ALLELE_MODE) or (@_ == $ADD_ALLELE_MODE))
	{

		my $loci_name_list = $self->{_dao}->get_all_loci_names();

		if($loci_name_list and @$loci_name_list)
		{

			foreach my $name (@$loci_name_list)
			{

				if(lc($loci_name_new) eq lc($name))
				{

					$found_name_new = $TRUE;

				}

				if(@_ == $EDIT_ALLELE_MODE)
				{

					if(lc($loci_name_prev) eq lc($name))
					{

						$found_name_prev = $TRUE;

					}

				}

			}

			if(@_ == $EDIT_ALLELE_MODE)
			{

				if(($found_name_new == $FALSE) or ($found_name_prev == $FALSE))
				{

					$is_valid = $FALSE;

				}

			}

			if(@_ == $ADD_ALLELE_MODE)
			{

				if($found_name_new == $FALSE)
				{

					$is_valid = $FALSE;

				}

			}

		}
		else
		{

			$is_valid = $FALSE;

		}

		if($is_valid)
		{

			$value = $self->_check_allele_type($allele_type_new,$loci_name_new);

			if($value ne $VALID_CONST)
			{

				$is_valid = $FALSE;
				$invalid_type = $TRUE;

			}
			if(@_ == $EDIT_ALLELE_MODE)
			{

				$value = $self->_check_allele_type($allele_type_prev,$loci_name_prev);

				if($value ne $VALID_CONST)
				{

					$is_valid = $FALSE;
					$invalid_type = $TRUE;

				}

			}

		}
		if($is_valid)
		{

			my $test_allele = $TRUE;

			if(@_ == $EDIT_ALLELE_MODE)
			{

				if(($allele_type_prev == $allele_type_new) and (lc($loci_name_prev) eq lc($loci_name_new)))
				{

					$test_allele = $FALSE;

				}

			}

			if($test_allele)
			{

				#make sure that an allele that is the same loci with this allele type doesn't already exist
				$count = $self->{_dao}->get_loci_allele_count($loci_name_new);

				if($count > 0)
				{

					my $allele= $self->{_dao}->get_allele($loci_name_new, $allele_type_new);

					if(defined $allele)
					{

						$is_valid = $FALSE;
						$has_type_duplicate = $TRUE;

					}

				}

			}

		}

		#must check that the allele (with its state before edit) is not present in an ST profile, if it is,
		#then prompt the user that they must delete any ST profiles that contain the edited allele
		#simply editing the current ST profiles will result in a circular dependency

		#we only perform this check if the user either changed the loci and/or the allele type, not if they
		#changed the sequence only
		my $validate_result;

		if(@_ == $EDIT_ALLELE_MODE)
		{

			$validate_result = $self->_check_st_profiles($loci_name_prev, $allele_type_prev, $loci_name_new, $allele_type_new);

		}

		if(@_ == $ADD_ALLELE_MODE)
		{

			$validate_result = $self->_check_st_profiles($loci_name_new, $allele_type_new);

		}

		if($validate_result eq $ERROR_IN_PROFILE)
		{

			$is_valid = $FALSE;
			$in_profile = $TRUE;

		}

		if($validate_result eq $INVALID_CONST)
		{

			$is_valid = $FALSE;

		}

		if($is_valid)
		{

			$validate_result = $self->_check_sequence($loci_name_new, $allele_sequence);

			if(not $validate_result)
			{

				$is_valid = $FALSE;
				$invalid_sequence = $TRUE;
				my $name_list = $self->{_dao}->get_all_loci_names();

				if($name_list and @$name_list)
				{

					my $loci_exists = $FALSE;

					foreach my $loci_from_list (@$name_list)
					{

						if($loci_name_new eq $loci_from_list)
						{

							$loci_exists = $TRUE;
						}

					}

					if($loci_exists)
					{
			#starts with this error code which is 1006
						my $error_code = $ERROR_PENA_SEQ;

						foreach my $loci_from_list (@$name_list)
						{
							if(lc($loci_from_list) eq lc($loci_name_new))
							{
								$seq_error = $error_code;
							}
							$error_code++;
						}

					}
					else
					{

						$is_valid=$FALSE;
						$invalid_loci_name = $TRUE;

					}

				}
				else
				{

					$is_valid=$FALSE;

				}

			}

		}

		if($is_valid)
		{

			$validate_result = $self->_check_loci_name($loci_name_new);

			if(not $validate_result)
			{

				$is_valid = $FALSE;
				$invalid_loci_name = $TRUE;

			}

		}

		my $loci_id;

		if($is_valid)
		{

			$loci_id = $self->{_dao}->get_loci_id($loci_name_new);

			if(not defined $loci_id)
			{

				$is_valid = $FALSE;

			}

		}

		if($is_valid)
		{

			my $sequence_list;

			if(@_ == $EDIT_ALLELE_MODE)
			{

				if(lc($loci_name_prev) eq lc($loci_name_new))
				{

					$sequence_list = $self->{_dao}->get_sequences($allele_type_prev, $loci_id);

				}
				else
				{

					$sequence_list = $self->{_dao}->get_all_sequences($loci_id);

				}

			}

			if(@_ == $ADD_ALLELE_MODE)
			{

				$sequence_list = $self->{_dao}->get_all_sequences($loci_id);

			}
			if($sequence_list)
			{

				#don't check the else case because we don't want an error if the sequence list is initially empty
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

							$is_valid = $FALSE;
							$has_sequence = $TRUE;

						}
					}

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

	if($is_valid)
	{

		$result = $VALID_CONST;

	}
	elsif($has_type_duplicate)
	{

		$result = $ERROR_DUPLICATE_TYPE;

	}
	elsif($has_sequence)
	{

		$result = $ERROR_DUPLICATE_SEQ;

	}
	elsif($in_profile)
	{

		$result = $ERROR_IN_PROFILE;

	}
	elsif($invalid_type)
	{

		$result = $ERROR_INVALID_TYPE;

	}
	elsif($invalid_loci_name)
	{

		$result = $ERROR_INVALID_LOCI_NAME;

	}
	elsif($invalid_sequence)
	{

		$result = $seq_error;

	}
	else
	{

		$result = $INVALID_CONST;

	}

	return $result;

}

sub _check_allele_type
{

	my ($self, $allele_type, $loci_name) = @_;

	my $obj = BusinessLogic::GetIntegerType->new();
	my $loci_int_type_set = $obj->_get_loci_with_integer_type();

	my $is_valid = $TRUE;
	my $result;

	if($allele_type =~ /^[0-9]\d*(\.\d{0,3})?$/ and (not exists $loci_int_type_set->{$loci_name}))
	{

		if(($allele_type < 0) or ($allele_type > 999))
		{

			$is_valid = $FALSE;

		}

	}
	elsif($allele_type =~ /^[0-9]+$/ and (%$loci_int_type_set) and (exists $loci_int_type_set->{$loci_name}))
	{

		if(($allele_type < 0) or ($allele_type > 999))
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

		$result = $VALID_CONST;

	}
	else
	{

		$result = $INVALID_CONST;

	}

}

sub _check_loci_name
{

	my ($self, $loci_name) = @_;

	my $is_valid = $TRUE;
	my $name_list = $self->{_dao}->get_all_loci_names();

	if($name_list and @$name_list)
	{

		my $is_found = $FALSE;

		foreach my $name (@$name_list)
		{

			if(lc($loci_name) eq lc($name))
			{

				$is_found = $TRUE;

			}

		}

		if(not $is_found)
		{

			$is_valid = $FALSE;

		}

	}
	else
	{

		$is_valid = $FALSE;

	}

	return $is_valid;

}

sub _check_sequence
{

	my ($self, $loci_name, $allele_sequence) = @_;

	my $is_valid = $TRUE;
	my $loci_exists = $FALSE;
	my $name_list;
	my $result;
	my $length_result;

	if($allele_sequence =~ /\A[ATCG]+\z/i)
	{

		$name_list = $self->{_dao}->get_all_loci_names();

		if($name_list and @$name_list)
		{

			$loci_exists = $FALSE;

			foreach my $loci_name_from_list (@$name_list)
			{

				if($loci_name eq $loci_name_from_list)
				{

					$loci_exists = $TRUE;

				}

			}

			if($loci_exists)
			{

				my %loci_name_map;

				for(my $i = 0; $i < scalar @$name_list; $i++)
				{

					#Loci names are the keys and the corresponding values are the allele lengths stored in the database
					$loci_name_map{lc($name_list->[$i])} = $self->{_dao}->get_allele_length($name_list->[$i]);

				}

				my $loci_length = $loci_name_map{lc($loci_name)};
				my $sequence_length = length($allele_sequence);

				if(($sequence_length < ($loci_length - $OFFSET)) or ($sequence_length > ($loci_length + $OFFSET)))
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

	return $is_valid;

}

sub _check_st_profiles
{

	my ($self, $loci_name_prev, $allele_type_prev, $loci_name_new, $allele_type_new) = @_;

	Readonly my $EDIT_ALLELE_MODE => 5; #pass 5 parameters when validating an allele to edit
	my $continue = $TRUE;
	my $in_profile = $FALSE;
	my $is_valid = $TRUE;
	my $result;

	if(@_ == $EDIT_ALLELE_MODE)
	{

		if(not((lc($loci_name_new) ne lc($loci_name_prev)) or ($allele_type_new != $allele_type_prev)))
		{

			$continue = $FALSE;

		}

	}

	if($continue)
	{

		my $obj = BusinessLogic::GetSequenceTypeInfo->new();
		my $num_profiles = $obj->_get_profile_list_length();

		#make sure that we have profiles in the database in the first place
		if($num_profiles > 0)
		{

			my $st_profile_list = $obj->_get_profile_list();

			if(not $st_profile_list)
			{

				$is_valid = $FALSE;

			}
			else
			{

				foreach my $profile (@$st_profile_list)
				{

					if($profile->{$loci_name_prev} == $allele_type_prev)
					{

						$is_valid = $FALSE;
						$in_profile = $TRUE;

					}

				}

			}

		}

	}
	if($is_valid)
	{

		$result = $VALID_CONST;

	}
	elsif($in_profile)
	{

		$result = $ERROR_IN_PROFILE;

	}
	else
	{

		$result = $INVALID_CONST;

	}

	return $result;

}

1;
__END__
