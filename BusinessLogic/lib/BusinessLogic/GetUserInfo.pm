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

package BusinessLogic::GetUserInfo;

use 5.014002;
use strict;
use warnings;

use Readonly;
use DateTime;

use DAL::DaoAuth;

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
	_check_email_exists
	_check_username_exists
	_get_all_users
	_get_current_email_address_by_user_id
	_get_current_username_by_user_id
	_get_user_details_by_username
	_get_user_email_by_username
	_get_user_role

	_check_password_expiry
	_check_password_history
	_get_user_id_by_email
);

our $VERSION = '0.01';


Readonly my $FALSE => 0;
Readonly my $TRUE => 1;

Readonly my $INVALID_VAL => 0;

Readonly my $INVALID_CONST => "IS_INVALID";
Readonly my $VALID_CONST => "IS_VALID";

Readonly my $ERROR_NO_USER_DETAILS_FOUND => 4027;

Readonly my $MAX_MONTHS_SINCE_PASSWORD_CHANGE => 3;

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

sub _check_email_exists
{

	my ($self,$email_address) = @_;

	my $result;
	my $email_exists = $self->{_dao}->check_email_exists($email_address);

	return $email_exists;

}

sub _check_username_exists
{

	my ($self,$username) = @_;

	my $result;
	my $username_exists = $self->{_dao}->check_username_exists($username);

	return $username_exists;

}

sub _get_current_username_by_user_id
{

	my ($self,$user_id) = @_;

	my $username = $self->{_dao}->get_current_username_by_user_id($user_id);

	return $username;

}

sub _get_current_email_address_by_user_id
{

	my ($self,$user_id) = @_;

	my $email_address = $self->{_dao}->get_current_email_address_by_user_id($user_id);

	return $email_address;

}

sub _get_user_email_by_username
{

	my ($self, $username) = @_;

	my $result;
	my $email_address = $self->{_dao}->get_user_email_by_username($username);

	if($email_address ne $INVALID_VAL)
	{

		$result = $email_address;

	}
	else
	{

		$result = $INVALID_CONST;

	}

	return $result;

}

sub _get_all_users
{

	my ($self) = @_;

	my $result = $self->{_dao}->get_all_users();

	if($result)
	{

	  my @sorted_result = sort {$a->{user_name} cmp $b->{user_name}} @$result;
	  $result = \@sorted_result;

	}

	return $result;

}


sub _get_user_role
{

	my ($self, $username) = @_;

	my $result = $self->{_dao}->get_user_role($username);

	return $result;

}

sub _get_user_id_by_username
{

	my ($self, $username) = @_;

	my $result = $self->{_dao}->get_user_id_by_username($username);

	return $result;


}

sub _get_user_details_by_username
{

	my ($self, $username) = @_;

	my $result = $self->{_dao}->get_user_details_by_username($username);

	if(not $result)
	{

		$result = $ERROR_NO_USER_DETAILS_FOUND;

	}

	return $result;
}

sub _check_password_expiry
{

	my ($self, $user_identifier) = @_;

	my $result = $FALSE;
	my $time_since_last_password_change;

	if($user_identifier =~ /^(\w|\-|\_|\.)+\@((\w|\-|\_)+\.)+[a-zA-Z]{2,}$/)
	{
		$time_since_last_password_change = $self->{_dao}->get_last_date_password_change_by_email_address($user_identifier);
	}
	else
	{
		$time_since_last_password_change = $self->{_dao}->get_last_date_password_change_by_username($user_identifier);
	}

	my $time = DateTime->now;

	#All user accounts have a time since last password change except for our test accounts
	#For test accounts this will ensure tests don't fail do to an expired password.
	if(not $time_since_last_password_change)
	{
		$time_since_last_password_change = DateTime->now;
	}

	my $dur = $time->subtract_datetime($time_since_last_password_change);

	if(($dur->years() != 0) or ($dur->months() >= $MAX_MONTHS_SINCE_PASSWORD_CHANGE))
	{
		$result = $TRUE;
	}

	return $result;

}

sub _check_password_history
{

	my ($self, $password, $username) = @_;

	my $result =  $self->{_dao}->check_password_history($password, $username);

	return $result

}

sub _get_user_id_by_email
{

	my ($self, $email_address) = @_;
	my $result;

	my $user_id = $self->{_dao}->get_user_id_by_email($email_address);


	if($user_id)
	{

		$result = $user_id;

	}
	else
	{

		$result = $NO_RESULT;

	}

	return $result;

}

1;
__END__
