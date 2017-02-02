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

package BusinessLogic::ValidateNewUser;


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
	_check_email_exists
	_check_username_exists
	_validate_new_user
);

our $VERSION = '0.01';

Readonly my $INVALID_CONST => "IS_INVALID";
Readonly my $VALID_CONST => "IS_VALID";

Readonly my $FALSE => 0;
Readonly my $TRUE => 1;


Readonly my $ERROR_INVALID_EMAIL_ADDRESS => 4000;
Readonly my $ERROR_EMAIL_ADDRESS_EXISTS => 4010;

Readonly my $ERROR_USERNAME_EXISTS => 4009;
Readonly my $ERROR_USERNAME_LENGTH => 4030;
Readonly my $ERROR_USERNAME_INVALID_CHARACTERS => 4005;

Readonly my $ERROR_PASSWORD_LENGTH => 4031;
Readonly my $ERROR_CONFIRM_PASSWORD_LENGTH => 4032;
Readonly my $ERROR_PASSWORD_MATCH => 4011;
Readonly my $ERROR_PASSWORD_INVALID_CHARACTERS => 4017;
Readonly my $ERROR_CONFIRM_PASSWORD_INVALID_CHARACTERS => 4033;

Readonly my $ERROR_FIRST_NAME => 4028;
Readonly my $ERROR_LAST_NAME => 4029;
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

sub _validate_new_user
{

	my ($self, $fname, $lname, $ins_name, $ins_city, $ins_country,$username, $password, $confirm_password, $email_address) = @_;

	my $is_valid = $TRUE;
	my $result =$VALID_CONST;

	if($fname !~ /^[(A-Z)|(\s)|(\-)|(\')]+$/i)
	{
		$is_valid = $FALSE;
		$result = $ERROR_FIRST_NAME;
	}

	if($is_valid)
	{

		if($lname !~ /^[(A-Z)|(\s)|(\-)|(\')]+$/i)
		{

			$is_valid = $FALSE;
			$result = $ERROR_LAST_NAME;
		}

	}

	if($is_valid)
	{

		if($ins_name !~ /^[(A-Z)|(\s)|(\-)|(\')]+$/i)
		{

			$is_valid = $FALSE;
			$result = $ERROR_INS_NAME;
		}

	}

	if($is_valid)
	{

		if($ins_city !~ /^[(A-Z)|(\s)|(\-)]+$/i)
		{

			$is_valid = $FALSE;
			$result = $ERROR_INS_CITY;
		}

	}

	if($is_valid)
	{

		if($ins_country !~ /^[(A-Z)|(\s)|(\-)]+$/i)
		{

			$is_valid = $FALSE;
			$result = $ERROR_INS_COUNTRY;
		}

	}

	if($is_valid)
	{

		if($self->_check_username_exists($username) eq $TRUE)
		{

			$is_valid = $FALSE;
			$result = $ERROR_USERNAME_EXISTS;

		}

	}

	if($is_valid)
	{

		if(length($username) < 5 or length($username) > 20)
		{

			$is_valid = $FALSE;
			$result = $ERROR_USERNAME_LENGTH;

		}

	}

	if($is_valid)
	{

		if($username !~  /^[(A-Z)|(0-9)|(\.)|(\-)|(_)]+$/i)
		{

			$is_valid = $FALSE;
			$result = $ERROR_USERNAME_INVALID_CHARACTERS;

		}

	}

	if($is_valid)
	{

		if(length($password) < 6 or length($password) > 20 )
		{

			$is_valid = $FALSE;
			$result = $ERROR_PASSWORD_LENGTH;

		}
		elsif(length($confirm_password) < 6 or length($confirm_password) > 20)
		{

			$is_valid = $FALSE;
			$result = $ERROR_CONFIRM_PASSWORD_LENGTH;

		}

	}

	if($is_valid)
	{

		if($password ne $confirm_password)
		{

			$is_valid = $FALSE;
			$result = $ERROR_PASSWORD_MATCH;

		}

	}

	if($is_valid)
	{

		if($password !~ /^(?=.{6,20}$)(?=.*?[A-Z])(?=.*?\d)(?=.*[\.\-_!])(?!.*\s+)/)
		{

			$is_valid = $FALSE;
			$result = $ERROR_PASSWORD_INVALID_CHARACTERS;

		}
		elsif($confirm_password !~ /^(?=.{6,20}$)(?=.*?[A-Z])(?=.*?\d)(?=.*[\.\-_!])(?!.*\s+)/)
		{

			$is_valid = $FALSE;
			$result = $ERROR_CONFIRM_PASSWORD_INVALID_CHARACTERS;

		}

	}

	if($is_valid)
	{

		if($self->_check_email_exists($email_address) == $TRUE)
		{

			$is_valid = $FALSE;
			$result = $ERROR_EMAIL_ADDRESS_EXISTS;

		}
		if($is_valid)
		{

			if($email_address !~  /^(\w|\-|\_|\.)+\@((\w|\-|\_)+\.)+[a-zA-Z]{2,}$/)
			{

				$is_valid = $FALSE;
				$result = $ERROR_INVALID_EMAIL_ADDRESS;

			}

		}

	}

	return $result;

}

sub _check_username_exists
{

	my ($self, $username) = @_;

	my $result = $FALSE;
	my $username_match_count = $self->{_daoauth}->get_username_match_count($username);

	if($username_match_count > 0)
	{

		$result = $TRUE;

	}
	else
	{

		$result= $FALSE;

	}

	return $result;

}

sub _check_email_exists
{

	my ($self, $email_address) = @_;

	my $result = $FALSE;
	my $email_address_match_count = $self->{_daoauth}->get_email_address_match_count($email_address);

	if($email_address_match_count > 0)
	{

		$result = $TRUE;

	}
	else
	{

		$result= $FALSE;

	}

	return $result;

}

1;
__END__
