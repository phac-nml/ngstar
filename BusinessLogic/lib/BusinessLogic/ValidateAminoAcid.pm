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

package BusinessLogic::ValidateAminoAcid;

use 5.014002;
use strict;
use warnings;

use Readonly;

require Exporter;

our @ISA = qw(Exporter);

# Items to export into callers namespace by default. Note: do not export
# names by default without a very good reason. Use EXPORT_OK instead.
# Do not simply export all your public functions/methods/constants.

# This allows declaration	use BusinessLogic::ValidateBatchProfiles':all';
# If you do not need this, moving things directly into @EXPORT or @EXPORT_OK
# will save memory.
our %EXPORT_TAGS = ( 'all' => [ qw(

) ] );

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

our @EXPORT = qw(
	_validate_amino_acid
	_validate_amino_acid_profile
);

our $VERSION = '0.01';

Readonly my $FALSE => 0;
Readonly my $TRUE => 1;

Readonly my $MOSAIC_YES => "Yes";
Readonly my $MOSAIC_NO => "No";
Readonly my $MOSAIC_SEMI => "Semi";

Readonly my $INVALID_DB_ID => 9000;
Readonly my $INVALID_ONISHI_TYPE => 9001;
Readonly my $INVALID_MOSAIC_VALUE => 9002;
Readonly my $INVALID_AA_PROFILE => 9003;

Readonly my $DUPLICATE_AA_ONISHI_TYPE => 9004;
Readonly my $DUPLICATE_AA_PROFILE => 9005;

Readonly my $INVALID_AMINO_ACID => 9006;
Readonly my $INVALID_AMINO_ACID_POSITION => 9007;
Readonly my $AMINO_ACID_EXISTS => 9008;
Readonly my $AMINO_ACID_POSITION_EXISTS => 9009;

#number of passed variables + 1 for self
Readonly my $ADD_AA_PROFILE_MODE => 4;  #3 parameters passed for validating amino acid profile to add
Readonly my $EDIT_AA_PROFILE_MODE => 7; #5 parameters passed for validating amino acid profile to edit
Readonly my $ADD_AA_MODE => 3; #2 parameters passed for validating amino acid to add
Readonly my $EDIT_AA_MODE => 6; #5 parameters passed for validating amino acid to edit

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

#make sure that the input/file can be properly parsed
sub _validate_amino_acid_profile
{

	my ($self, $onishi_type, $mosaic, $aa_profile, $onishi_type_old, $aa_profile_old, $id) = @_;

	my $is_valid = $TRUE;
	my $error_code;
	my $result;
	my $loci_name = "penA"; #only gene with onishi sequences

	my $onishi_seqs_list = $self->{_dao}->get_onishi_sequences($loci_name);


	if($is_valid)
	{
		if(uc($onishi_type) !~ /^[a-zA-Z\d\s]+$/)
		{
			$is_valid = $FALSE;
			$error_code = $INVALID_ONISHI_TYPE;
		}
	}


	if($is_valid)
	{
		if((lc($mosaic) ne lc($MOSAIC_YES))
		and (lc($mosaic) ne lc($MOSAIC_NO))
		and (lc($mosaic) ne lc($MOSAIC_SEMI)))
		{
			$is_valid = $FALSE;
			$error_code = $INVALID_MOSAIC_VALUE;
		}
	}

	if($is_valid)
	{
		if($is_valid)
		{
			if($aa_profile !~ /^[a-zA-Z\s\.]+$/)
			{
				$is_valid = $FALSE;
				$error_code = $INVALID_AA_PROFILE;
			}
		}
	}

	if(@_ == $ADD_AA_PROFILE_MODE)
	{
		if($is_valid)
		{
			foreach my $curr_onishi_seq(@$onishi_seqs_list)
			{

				if(uc($curr_onishi_seq->{onishi_type}) eq uc($onishi_type))
				{
					$is_valid = $FALSE;
					$error_code = $DUPLICATE_AA_ONISHI_TYPE;
					last;
				}

				if(uc($curr_onishi_seq->{aa_profile}) eq uc($aa_profile))
				{
					$is_valid = $FALSE;
					$error_code = $DUPLICATE_AA_PROFILE;
					last;
				}
			}
		}
	}

	if(@_ == $EDIT_AA_PROFILE_MODE)
	{
		my $max_db_id;

		if($is_valid)
		{
			foreach my $curr_onishi_seq(@$onishi_seqs_list)
			{
				if($curr_onishi_seq->{id})
				{
					$max_db_id = $curr_onishi_seq->{id};
				}

				if(uc($onishi_type) ne uc($onishi_type_old))
				{
					if(uc($curr_onishi_seq->{onishi_type}) eq uc($onishi_type))
					{
						$is_valid = $FALSE;
						$error_code = $DUPLICATE_AA_ONISHI_TYPE;
						last;
					}
				}
				if(uc($aa_profile) ne uc($aa_profile_old))
				{
					if(uc($curr_onishi_seq->{aa_profile}) eq uc($aa_profile))
					{
						$is_valid = $FALSE;
						$error_code = $DUPLICATE_AA_PROFILE;
						last;
					}
				}
			}

			if($is_valid)
			{
				if($id !~ /^[0-9]+$/ or $id > $max_db_id)
				{
					$is_valid = $FALSE;
					$error_code = $INVALID_DB_ID;
				}
			}
		}
	}

	if($is_valid)
	{
		$result = $TRUE;
	}
	else
	{
		$result = $error_code;
	}

	return $result;

}

sub _validate_amino_acid
{
	my ($self, $amino_acid, $amino_acid_position, $amino_acid_old, $amino_acid_position_old, $id) = @_;

	my $error_code;
	my $aa_position_exists = $FALSE;
	my $is_valid = $TRUE;
	my $result;

	my $aa_exists = $self->{_dao}->check_aa_exists(uc($amino_acid), $amino_acid_position);

	if(not $aa_exists)
	{
		$aa_position_exists = $self->{_dao}->check_aa_pos_exists($amino_acid_position);
	}


	if(@_ == $ADD_AA_MODE)
	{

		if((not $aa_exists) and (not $aa_position_exists))
		{
			if($amino_acid !~ /^[a-zA-Z\.]+$/)
			{
				$error_code = $INVALID_AMINO_ACID;
				$is_valid = $FALSE;
			}

			if($is_valid)
			{
				if($amino_acid_position !~ /^[0-9]+$/)
				{
					$error_code = $INVALID_AMINO_ACID_POSITION;
					$is_valid = $FALSE;
				}
			}

		}
		elsif($aa_exists)
		{

			$error_code = $AMINO_ACID_EXISTS;
			$is_valid = $FALSE;

		}
		elsif($aa_position_exists)
		{

			$error_code = $AMINO_ACID_POSITION_EXISTS;
			$is_valid = $FALSE;

		}

	}

	if(@_ == $EDIT_AA_MODE)
	{

		if((lc($amino_acid) ne lc($amino_acid_old)) and ($amino_acid_position != $amino_acid_position_old))
		{

			if((not $aa_exists) and (not $aa_position_exists))
			{

				if($amino_acid !~ /^[a-zA-Z\.]+$/)
				{
					$error_code = $INVALID_AMINO_ACID;
					$is_valid = $FALSE;
				}

				if($is_valid)
				{
					if($amino_acid_position !~ /^[0-9]+$/)
					{
						$error_code = $INVALID_AMINO_ACID_POSITION;
						$is_valid = $FALSE;
					}
				}

			}
			elsif($aa_exists)
			{

				$error_code = $AMINO_ACID_EXISTS;
				$is_valid = $FALSE;

			}
			elsif($aa_position_exists)
			{

				$error_code = $AMINO_ACID_POSITION_EXISTS;
				$is_valid = $FALSE;

			}
		}
	}

	if($is_valid)
	{
		$result = $TRUE;
	}
	else
	{
		$result = $error_code;
	}

	return $result;

}


1;
__END__
