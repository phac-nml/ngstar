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

package BusinessLogic::ValidateForgotPasswordInfo;
use DateTime;

use 5.014002;
use strict;
use warnings;

use Readonly;

require Exporter;

our @ISA = qw(Exporter);

# Items to export into callers namespace by default. Note: do not export
# names by default without a very good reason. Use EXPORT_OK instead.
# Do not simply export all your public functions/methods/constants.

# This allows declaration	use BusinessLogic::ValidateEmailForm':all';
# If you do not need this, moving things directly into @EXPORT or @EXPORT_OK
# will save memory.
our %EXPORT_TAGS = ( 'all' => [ qw(

) ] );

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

our @EXPORT = qw(
	_get_user_id_by_email
	_validate_email_address
	_validate_reset_token
	_validate_username
);

our $VERSION = '0.01';


Readonly my $FALSE => 0;
Readonly my $TRUE => 1;

Readonly my $INVALID_CONST => "IS_INVALID";
Readonly my $VALID_CONST => "IS_VALID";

Readonly my $ERROR_INVALID_EMAIL_ADDRESS => 4000;
Readonly my $ERROR_TOKEN_NOT_EXIST => 4002;
Readonly my $ERROR_TOKEN_EXPIRED => 4003;
Readonly my $ERROR_INVALID_TOKEN => 4004;
Readonly my $ERROR_INVALID_USERNAME => 4005;
Readonly my $ERROR_USERNAME_IN_USE => 4006;
Readonly my $ERROR_NO_EMAIL_ADDRESS => 4007;
Readonly my $ERROR_NO_TOKEN => 4008;

Readonly my $NO_RESULT => -9999;


sub new
{

	my $class = shift;
	my $self = {
		_dao => DAL::DaoAuth->new(),
	};
	bless $self, $class;
	return $self;

}

sub _cleanup_expired_tokens
{

	my ($self) = @_;

	my $token_list;
	my @tokens_to_delete;
	my $timestamp;
	my $time;
	my $dur;

	#cleanup all expired tokens
	$token_list = $self->{_dao}->get_all_tokens();

	foreach my $token_row (@$token_list)
	{

		$timestamp = $token_row->{timestamp};
		$time = DateTime->now;
		$dur = $time->subtract_datetime($timestamp);

		#token valid for one hour
		if($dur->years() != 0 or $dur->months() != 0 or $dur->days() != 0 or $dur->hours() != 0)
		{

			push @tokens_to_delete,{user_id => $token_row->{user_id}};

		}

	}#foreach

	if(@tokens_to_delete)
	{

		$self->{_dao}->cleanup_expired_tokens(\@tokens_to_delete);

	}

}

sub _get_user_id_by_email
{

	my ($self, $email_address) = @_;
	my $result;
	my $validation_result = $self->_validate_email_address($email_address);

	if($validation_result)
	{

		my $user_id = $self->{_dao}->get_user_id_by_email($email_address);


		if($user_id)
		{

			$result = $user_id;

		}
		else
		{

			$result = $NO_RESULT;

		}

	}
	else
	{

		$result = $NO_RESULT;

	}

	return $result;

}

sub _validate_email_address
{

	my ($self, $to_email_address) = @_;

	my $is_valid = $TRUE;
	my $invalid_code = $INVALID_CONST;
	my $result;
	my $email_exists;

	if($to_email_address)
	{

		if($to_email_address !~ /^(\w|\-|\_|\.)+\@((\w|\-|\_)+\.)+[a-zA-Z]{2,}$/)
		{

			$is_valid = $FALSE;
			$invalid_code = $ERROR_INVALID_EMAIL_ADDRESS;

		}

	}

	if($is_valid)
	{

		$email_exists = $self->{_dao}->check_email_exists($to_email_address);

	}

	if(not $email_exists)
	{

		$result = $FALSE;

	}
	else
	{

		$result = $TRUE;

	}

	return $result;

}

sub _validate_reset_token
{

	my ($self, $to_email_address, $token) = @_;

	my $is_valid = $TRUE;
	my $invalid_code = $INVALID_CONST;
	my $result;
	my $token_exists;

	if($to_email_address)
	{

		if($to_email_address !~ /^(\w|\-|\_|\.)+\@((\w|\-|\_)+\.)+[a-zA-Z]{2,}$/)
		{

			$is_valid = $FALSE;
			$invalid_code = $ERROR_INVALID_EMAIL_ADDRESS;

		}

	}
	else
	{

		$is_valid=$FALSE;
		$invalid_code = $ERROR_NO_EMAIL_ADDRESS;

	}

	if($is_valid)
	{

		if($token)
		{

			if($token !~ /^[(A-Z)|(0-9)]+$/i)
			{

				$is_valid = $FALSE;
				$invalid_code = $ERROR_INVALID_TOKEN;

			}

		}
		else
		{

			$is_valid = $FALSE;
			$invalid_code = $ERROR_NO_TOKEN;

		}

	}

	if($is_valid)
	{

		$token_exists = $self->{_dao}->check_reset_token_exists($to_email_address);

		if($token_exists)
		{

			my $timestamp = $self->{_dao}->get_stored_timestamp($to_email_address);
			my $time = DateTime->now;
			my $dur = $time->subtract_datetime($timestamp);

			#token valid for one hour
			if($dur->years() != 0 or $dur->months() != 0 or $dur->days() != 0 or $dur->hours() != 0)
			{

				$is_valid = $FALSE;
				$invalid_code = $ERROR_TOKEN_EXPIRED;

			}

			$self->_cleanup_expired_tokens();

		}
		else
		{

			$is_valid = $FALSE;
			$invalid_code = $ERROR_TOKEN_NOT_EXIST;

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

sub _validate_username
{

	my ($self, $username) = @_;

	my $is_valid = $TRUE;
	my $invalid_code = $INVALID_CONST;
	my $result;
	my $username_exists;

	if($username)
	{

		if($username !~ /^[(A-Z)|(0-9)|(\.)|(\-)|(_)]+$/i)
		{

			$is_valid = $FALSE;
			$invalid_code = $ERROR_INVALID_USERNAME;

		}

	}

	if($is_valid)
	{

		$username_exists = $self->{_dao}->check_username_exists($username);

	}

	if($is_valid)
	{

		if(not $username_exists)
		{

			$result = $VALID_CONST;

		}
		else
		{

			$result = $ERROR_USERNAME_IN_USE;

		}

	}
	else
	{

		$result = $invalid_code

	}

	return $result;

}

1;

__END__
