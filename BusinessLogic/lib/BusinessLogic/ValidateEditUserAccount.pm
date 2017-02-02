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

package BusinessLogic::ValidateEditUserAccount;


use 5.014002;

use strict;
use warnings;



use DAL::DaoAuth;
use DAL::DaoStub;
use Readonly;

require Exporter;

our @ISA = qw(Exporter);

# Items to export into callers namespace by default. Note: do not export
# names by default without a very good reason. Use EXPORT_OK instead.
# Do not simply export all your public functions/methods/constants.

# This allows declaration	use BusinessLogic::AddAllele':all';
# If you do not need this, moving things directly into @EXPORT or @EXPORT_OK
# will save memory.
our %EXPORT_TAGS = ( 'all' => [ qw(

) ] );

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

our @EXPORT = qw(
  _validate_edited_user_details
);

our $VERSION = '0.01';

Readonly my $INVALID_CONST => "IS_INVALID";
Readonly my $VALID_CONST => "IS_VALID";

Readonly my $FALSE => 0;
Readonly my $TRUE => 1;


Readonly my $ERROR_INVALID_EMAIL_ADDRESS => 4000;
Readonly my $ERROR_FNAME_INVALID_CHARACTERS => 4028;
Readonly my $ERROR_LNAME_INVALID_CHARACTERS => 4029;

Readonly my $ERROR_INS_NAME => 4034;
Readonly my $ERROR_INS_CITY => 4035;
Readonly my $ERROR_INS_COUNTRY => 4036;


sub new
{

	my $class = shift;
	my $self = {
		_daoauth => DAL::DaoAuth->new(),
	};
	bless $self, $class;
	return $self;

}

sub _validate_edited_user_details
{

	my ($self, $first_name, $last_name, $email_address, $ins_name, $ins_city, $ins_country) = @_;

	my $is_valid = $TRUE;
	my $result = $TRUE;


	if($first_name !~  /^[A-Z\s\-]+$/i)
	{

		$is_valid = $FALSE;
		$result = $ERROR_FNAME_INVALID_CHARACTERS;

	}

	if($is_valid)
	{

	  if($last_name !~  /^[A-Z\s\-\']+$/i)
	  {

		  $is_valid = $FALSE;
		  $result = $ERROR_LNAME_INVALID_CHARACTERS;

	  }

	}

	if($is_valid)
	{

	  if($email_address !~  /^(\w|\-|\_|\.)+\@((\w|\-|\_)+\.)+[a-zA-Z]{2,}$/)
	  {

		$is_valid = $FALSE;
		$result = $ERROR_INVALID_EMAIL_ADDRESS;

	  }

	}

	if($is_valid)
	{

		if($ins_name !~ /^[A-Z\s\-\']+$/i)
		{

			$is_valid = $FALSE;
			$result = $ERROR_INS_NAME;
		}

	}

	if($is_valid)
	{

		if($ins_city !~ /^[A-Z\s\-\']+$/i)
		{

			$is_valid = $FALSE;
			$result = $ERROR_INS_CITY;
		}

	}

	if($is_valid)
	{

		if($ins_country !~ /^[A-Z\s\-\']+$/i)
		{

			$is_valid = $FALSE;
			$result = $ERROR_INS_COUNTRY;
		}

	}


	return $result;

}


1;
__END__
