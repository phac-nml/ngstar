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

package BusinessLogic::UpdateUserInformation;

use 5.014002;

use strict;
use warnings;

use Bio::Perl;
use Readonly;
use DateTime;
use DAL::Dao;
use DAL::DaoStub;

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

	_deactivate_account
	_delete_account
	_get_user_to_update_by_id
	_reactivate_account
	_update_password
	_update_user_fname_lname_by_user_id
	_update_user_role_by_user_id
);

our $VERSION = '0.01';

Readonly my $INVALID_CONST => 0;
Readonly my $VALID_CONST => 1;

Readonly my $INVALID => "IS_INVALID";
Readonly my $VALID => "IS_VALID";

Readonly my $ERROR_EMAIL_ADDRESS_IN_USE => 4001;
Readonly my $ERROR_USER_NOT_EXIST => 4023;
Readonly my $ERROR_CANNOT_DELETE_ACCOUNT => 4024;
Readonly my $ERROR_CANNOT_DEACTIVATE_ACCOUNT => 4025;

Readonly my $FALSE => 0;
Readonly my $TRUE => 1;


sub new
{

	my $class = shift;
	my $self = {
		_dao => DAL::DaoAuth->new(),
	};
	bless $self, $class;
	return $self;

}


sub _deactivate_account
{
	my ($self, $username, $user_id) = @_;

	my $user = $self->{_dao}->check_username_exists($username);
	my $result;
	my $check_user;

	if($user)
	{

		$check_user = $self->{_dao}->get_user_by_id($user_id);

		if(lc($check_user->username) eq lc($username))
		{
			$result = $ERROR_CANNOT_DEACTIVATE_ACCOUNT;
		}
		else
		{
			$result = $self->{_dao}->deactivate_account($username);
		}

	}
	else
	{

		$result = $ERROR_USER_NOT_EXIST;

	}

	return $result;

}

sub _delete_account
{
	my ($self, $username,$user_id) = @_;

	my $user = $self->{_dao}->check_username_exists($username);
	my $result;
	my $check_user;

	if($user)
	{

		$check_user = $self->{_dao}->get_user_by_id($user_id);

		if(lc($check_user->username) eq lc($username))
		{
			$result = $ERROR_CANNOT_DELETE_ACCOUNT;
		}
		else
		{
			$result = $self->{_dao}->delete_account($username);
		}

	}
	else
	{

		$result = $ERROR_USER_NOT_EXIST;

	}

	return $result;

}

sub _get_user_to_update_by_id
{

	my ($self, $user_id) = @_;

	my $result;
	my $user = $self->{_dao}->get_user_by_id($user_id);

	if(defined $user)
	{

		$result = $user;

	}
	else
	{

		$result = undef;

	}

	return $result;

}

sub _reactivate_account
{
	my ($self, $username) = @_;

	my $user = $self->{_dao}->check_username_exists($username);
	my $result;

	if($user)
	{

		$result = $self->{_dao}->activate_account($username);

	}
	else
	{

		$result = $ERROR_USER_NOT_EXIST;

	}

	return $result;

}


sub _update_password
{

	my ($self, $new_password, $user_identifier) = @_;

	my $result;
	my $time_stamp = DateTime->now;

	my $username;

	if($user_identifier =~ /^[0-9]+$/i)
	{
		$username = $self->{_dao}->get_current_username_by_user_id($user_identifier);
	}
	else
	{
		$username = $self->{_dao}->get_current_username_by_email_address($user_identifier);
	}


	my $validation_result = $self->{_dao}->update_user_password($username, $new_password, $time_stamp);

	if($validation_result)
	{

		$result = $VALID_CONST;

	}
	else
	{

		$result = $validation_result;

	}

	return $result;

}



sub _update_email_by_user_id
{

	my ($self, $new_email, $user_id) = @_;

	my $result;
	my $time_stamp = DateTime->now;

	my $obj = BusinessLogic::ValidateForgotPasswordInfo->new();
	my $validation_result = $obj->_validate_email_address($new_email);

	if(not $validation_result)
	{

		$self->{_dao}->update_user_email_by_user_id($new_email, $user_id, $time_stamp);
		$result = $VALID;

	}
	else
	{

		$result = $ERROR_EMAIL_ADDRESS_IN_USE;

	}

	return $result;

}

sub _update_username_by_user_id
{

	my ($self, $new_username, $user_id) = @_;

	my $result;

	my $obj = BusinessLogic::ValidateForgotPasswordInfo->new();
	my $validation_result = $obj->_validate_username($new_username);

	if($validation_result eq $VALID)
	{

		$self->{_dao}->update_username_by_user_id($new_username, $user_id);
		$result = $VALID;

	}
	else
	{

		$result = $validation_result;

	}

	return $result;

}

sub _update_user_role_by_user_id
{

	my ($self, $new_role, $user_id) = @_;
	my $result;

	$result = $self->{_dao}->update_role_by_user_id($new_role, $user_id);

	return $result;

}

sub _update_user_fname_lname_by_user_id
{

	my ($self, $first_name, $last_name, $user_id) = @_;
	my $result;

	$result = $self->{_dao}->update_user_fname_lname_by_user_id($first_name, $last_name, $user_id);

	return $result;

}

sub _update_user_institution_info_by_user_id
{

	my ($self, $ins_name, $ins_city, $ins_country, $user_id) = @_;
	my $result;

	$result = $self->{_dao}->update_user_institution_info_by_user_id($ins_name, $ins_city, $ins_country, $user_id);

	return $result;

}

sub _admin_update_user
{

	my ($self, $role, $current_email_address, $email_address, $user_id, $first_name, $last_name, $ins_name, $ins_city, $ins_country) = @_;

	my $result = $VALID;

	if(lc($email_address) ne lc($current_email_address))
	{
		$result = $self->_update_email_by_user_id($email_address, $user_id);
	}

	if($result eq $VALID)
	{

	  $result = $self->_update_user_fname_lname_by_user_id($first_name, $last_name, $user_id);

	}

	if($result == $VALID_CONST)
	{

	  $result = $self->_update_user_institution_info_by_user_id($ins_name, $ins_city, $ins_country, $user_id);

	}

	if($result == $VALID_CONST)
	{

		$result = $self->_update_user_role_by_user_id($role, $user_id);

	}




	return $result;

}

1;
__END__
