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

package BusinessLogic::ValidateSequenceTypeProfile;

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

# This allows declaration	use BusinessLogic::ValidateSequenceTypeProfile':all';
# If you do not need this, moving things directly into @EXPORT or @EXPORT_OK
# will save memory.
our %EXPORT_TAGS = ( 'all' => [ qw(

) ] );

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

our @EXPORT = qw(
	_check_sequence_type
	_validate_profile
);

our $VERSION = '0.01';

Readonly my $TESTING => 0;

Readonly my $FALSE => 0;
Readonly my $TRUE => 1;

Readonly my $INVALID_CONST => "IS_INVALID";
Readonly my $VALID_CONST => "IS_VALID";

Readonly my $ERROR_NONEXISTANT_ALLELE => 1001;
Readonly my $ERROR_INVALID_ALLELE_TYPE => 1014;
Readonly my $ERROR_INVALID_LOCI_COUNT => 1026;

Readonly my $ERROR_DUPLICATE_PROFILE => 2002;
Readonly my $ERROR_DUPLICATE_ST_TYPE => 2003;
Readonly my $ERROR_INVALID_ST_TYPE => 2023;


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

sub _validate_profile
{

	my ($self, $sequence_type_new, $profile_map_new, $sequence_type_prev, $profile_map_prev) = @_;

	Readonly my $ADD_PROFILE_MODE => 3;
	Readonly my $EDIT_PROFILE_MODE => 5;
	my $invalid_code = $INVALID_CONST;
	my $is_duplicate_profile = $TRUE;
	my $is_valid = $TRUE;
	my $result;
	my $value;

	if((@_ == $ADD_PROFILE_MODE) or (@_ == $EDIT_PROFILE_MODE))
	{

		$value = $self->_check_sequence_type($sequence_type_new);

		if($value ne $VALID_CONST)
		{

			$is_valid = $FALSE;
			$invalid_code = $ERROR_INVALID_ST_TYPE;

		}

		if(@_ == $EDIT_PROFILE_MODE)
		{

			$value = $self->_check_sequence_type($sequence_type_prev);

			if($value ne $VALID_CONST)
			{

				$is_valid = $FALSE;
				$invalid_code = $ERROR_INVALID_ST_TYPE;

			}
		}

		if($is_valid)
		{

			my $identical_st = $FALSE;

			if(@_ == $EDIT_PROFILE_MODE)
			{

				if($sequence_type_prev == $sequence_type_new)
				{

					$identical_st = $TRUE;

				}

			}

			if(not $identical_st)
			{

				#Case 1: check that the sequence type value does not already exist (it should not exist)
				$value = $self->{_dao}->get_sequence_type($sequence_type_new);

				if(defined $value)
				{

					$is_valid = $FALSE;
					$invalid_code = $ERROR_DUPLICATE_ST_TYPE;

				}

			}

		}

		if($is_valid)
		{

			my $loci_name_list = $self->{_dao}->get_all_loci_names();

			if($loci_name_list and @$loci_name_list)
			{

				foreach my $name (@$loci_name_list)
				{

					#Case 2: check if the allele with this allele type exists (it must exist)
					$value = $self->_check_profile_map($profile_map_new, $name);

					if($value ne $VALID_CONST)
					{

						$is_valid = $FALSE;
						$invalid_code = $value;

					}

					if(@_ == $EDIT_PROFILE_MODE)
					{

						$value = $self->_check_profile_map($profile_map_prev, $name);

						if($value ne $VALID_CONST)
						{

							$is_valid = $FALSE;
							$invalid_code = $value;

						}

					}

				}

			}
			else
			{

				$is_valid = $FALSE;

			}

		}

		my $validate = $TRUE;

		if($is_valid)
		{

			if(@_ == $EDIT_PROFILE_MODE)
			{

				my $identical_profile = $TRUE;

				foreach my $name (keys %$profile_map_prev)
				{

					if($profile_map_prev->{$name} != $profile_map_new->{$name})
					{

						$identical_profile = $FALSE;

					}

				}

				if($identical_profile)
				{

					$validate = $FALSE;

				}

			}

		}

		if($validate)
		{

			if($is_valid)
			{

				#Case 3: check that this profile (the combination of allele types) does not already exist
				#no need to check if there are no sequence types
				my $count = $self->{_dao}->get_sequence_type_count();

				if($count > 0)
				{

					my $profile_list = $self->{_dao}->get_all_sequence_types();

					if($profile_list and @$profile_list)
					{

						foreach my $st (@$profile_list)
						{

							my $allele_list = $self->{_dao}->get_allele_profile($st->{seq_type_id});

							if($allele_list and @$allele_list)
							{

								foreach my $allele (@$allele_list)
								{

									my $loci = $self->{_dao}->get_loci($allele->{loci_id});

									if(defined $loci)
									{

										my $name = $loci->loci_name;

										if($profile_map_new->{$name} != $allele->{allele_type})
										{

											$is_duplicate_profile = $FALSE;

										}

									}
									else
									{

										$is_valid = $FALSE;

									}

								}

								if($is_duplicate_profile)
								{

									$is_valid = $FALSE;
									$invalid_code = $ERROR_DUPLICATE_PROFILE;

								}

								#must reset this each time
								$is_duplicate_profile = $TRUE;

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

sub _check_sequence_type
{

	my ($self, $sequence_type) = @_;

	my $is_valid = $TRUE;
	my $result;

	if((defined $sequence_type) and ($sequence_type =~ /^[0-9]+$/))
	{

		if(($sequence_type < 0) or ($sequence_type > 999))
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

	return $result;

}

sub _check_profile_map
{

	my ($self, $profile_map, $name) = @_;

	my $invalid_code = $INVALID_CONST;
	my $is_valid = $TRUE;
	my $result;

	if(not exists $profile_map->{$name})
	{

		$is_valid = $FALSE;
		$invalid_code = $ERROR_INVALID_LOCI_COUNT;

	}
	else
	{

		if($profile_map->{$name} =~ /^[0-9]\d*(\.\d{0,3})?$/)
		{

			if(($profile_map->{$name} < 0) or ($profile_map->{$name} > 999))
			{

				$is_valid = $FALSE;
				$invalid_code = $ERROR_INVALID_ALLELE_TYPE;

			}
			else
			{

				my $value = $self->{_dao}->get_allele($name, $profile_map->{$name});

				if(not defined $value)
				{

					$is_valid = $FALSE;
					$invalid_code = $ERROR_NONEXISTANT_ALLELE;

				}

			}

		}
		else
		{

			$is_valid = $FALSE;
			$invalid_code = $ERROR_INVALID_ALLELE_TYPE;

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
