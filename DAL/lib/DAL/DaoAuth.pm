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

package DAL::DaoAuth;

use 5.014002;
use strict;
use warnings;

use Catalyst qw( ConfigLoader );

use lib NGSTAR->config->{dal_databaseobjects_path};
use NGSTAR_Auth::Schema;

use Readonly;

require Exporter;

our @ISA = qw(Exporter);

# Items to export into callers namespace by default. Note: do not export
# names by default without a very good reason. Use EXPORT_OK instead.
# Do not simply export all your public functions/methods/constants.

# This allows declaration	use DAL::Dao ':all';
# If you do not need this, moving things directly into @EXPORT or @EXPORT_OK
# will save memory.
our %EXPORT_TAGS = ( 'all' => [ qw(

) ] );

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

our @EXPORT = qw(
	activate_account
	check_account_status
	check_email_exists
	check_username_exists
	check_reset_token_exists
	cleanup_expired_tokens
	deactivate_account
	delete_account
	delete_reset_token
	get_all_tokens
	get_all_users
	get_current_email_address_by_user_id
	get_current_username_by_email_address
	get_current_username_by_user_id
	get_email_address_match_count
	get_stored_timestamp
	get_user_details_by_username
	get_user_email_by_username
	get_user_by_id
	get_user_id_by_email
	get_user_id_by_username
	get_user_role
	get_user_token_exists_by_email_address
	get_username_match_count
	get_user_token_exists_by_username
	insert_new_user
	insert_reset_token_by_email_address
	insert_reset_token_by_username
	update_reset_token_by_email_address
	update_reset_token_by_username
	update_user_password
	update_username_by_user_id
	update_user_fname_lname_by_user_id
	update_user_institution_info_by_user_id
	update_user_email_by_user_id
	update_role_by_user_id


	get_lockout_status
	get_user_failed_attempts
	get_user_lockout_timestamp
	get_user_first_failed_attempt_timestamp
	increment_failed_attempts
	reset_user_lockout_info
	set_user_first_failed_attempt_timestamp
	set_user_lockout_status

	get_last_date_password_change_by_email_address
	get_last_date_password_change_by_username

	check_password_history
	get_password_history_id_by_username
	update_password_history
	get_user_password_history_count
);

our $VERSION = '0.01';

Readonly my $FALSE => 0;
Readonly my $TRUE => 1;

Readonly my $INVALID_VAL => 0;
Readonly my $VALID_VAL => 1;

Readonly my $NO_USER_ID => -9999;

Readonly my $INVALID_CONST => "IS_INVALID";
Readonly my $VALID_CONST => "IS_VALID";

Readonly my $ACTIVE_STATUS => 1;
Readonly my $INACTIVE_STATUS => 0;

Readonly my $MAX_USER_PASSWORDS_STORED => 10;

sub new
{

	my ($class) = @_;

	my $dsn = NGSTAR->config->{dsn_auth_string};
	my $db_user = NGSTAR->config->{auth_db_user};
	my $db_password = NGSTAR->config->{auth_db_password};

	my $self = {
		_schema => NGSTAR_Auth::Schema->connect($dsn, $db_user, $db_password),
	};
	bless $self, $class;
	return $self;

}

sub check_account_status
{

	my ($self,$username) = @_;

	my $acct_status = $self->{_schema}->resultset('User')->single({
			username => $username
	})->is_active;

	return $acct_status;

}

sub activate_account
{

	my ($self,$username) = @_;

	my $user = $self->{_schema}->resultset('User')->single({username => $username});

	$user->active($ACTIVE_STATUS);
	$user->update;

	return $TRUE;

}

sub deactivate_account
{

	my ($self,$username) = @_;

	my $user = $self->{_schema}->resultset('User')->single({username => $username});

	$user->active($INACTIVE_STATUS);
	$user->update;

	return $TRUE;

}

sub delete_account
{

	my ($self,$username) = @_;

	my $user;

	my $user_id = $self->get_user_id_by_username($username);
	$self->{_schema}->resultset('UserPasswordHistory')->search({user_id => $user_id})->delete;

	#delete associated password history info
	$self->{_schema}->resultset('PasswordHistory')->search({username => $username})->delete;

	#delete password_reset_requests
	$user = $self->{_schema}->resultset('PasswordResetRequest')->single({user_id => $user_id});

	if($user)
	{
		$user->delete;
	}

	#delete account
	$user = $self->{_schema}->resultset('User')->single({username => $username});
	$user->delete;

	#delete associated lockout info
	$user = $self->{_schema}->resultset('TblLockout')->single({username => $username});
	$user->delete;


	return $TRUE;

}


sub check_email_exists
{

	my ($self,$to_email_address) = @_;

	my $result = $FALSE;

	my $result_set = $self->{_schema}->resultset('User')->search(
		{
			email_address => $to_email_address
		},
		{
			columns => [qw/ email_address /]
		}
	);

	my $count = $result_set->count;

	if($count > 0)
	{

		$result = $TRUE;

	}

	return $result;

}

sub check_reset_token_exists
{

	my ($self,$email_address) = @_;

	my $result = $FALSE;
	my $email_exists;

	$email_exists = $self->check_email_exists($email_address);

	if($email_exists)
	{

		my $user_id = $self->{_schema}->resultset('User')->single({
				email_address => $email_address
		})->id;

		my $result_set = $self->{_schema}->resultset('PasswordResetRequest')->search(
			{
				user_id => $user_id
			});

		my $count = $result_set->count;

		if($count > 0)
		{
			$result = $TRUE;
		}

	}

	return $result;

}

sub check_username_exists
{

	my ($self,$username) = @_;

	my $result = $FALSE;

	my $result_set = $self->{_schema}->resultset('User')->search(
		{
			username => $username
		},
		{
			columns => [qw/ username /]
		}
	);

	my $count = $result_set->count;

	if($count > 0)
	{

		$result = $TRUE;

	}

	return $result;

}

sub cleanup_expired_tokens
{

	my($self, $user_id_list) = @_;

	my $result = $TRUE;
	my $result_set = $self->{_schema}->resultset('PasswordResetRequest');

	foreach my $user_id(@$user_id_list)
	{

		$result_set->search({
			user_id => $user_id->{user_id}
		})->delete;

	}

	return $result;

}

sub delete_reset_token
{

	my($self, $user_id) = @_;

	my $result;

	my $user = $self->{_schema}->resultset('PasswordResetRequest')->search({
		user_id => $user_id
	})->delete;

	if($user)
	{

		$result = $TRUE;

	}
	else
	{

		$result = $FALSE;

	}

	return $result;

}

sub get_all_tokens
{

	my ($self) = @_;

	my @token_list;
	my $result_set = $self->{_schema}->resultset('PasswordResetRequest');

	while (my $token = $result_set->next)
	{

		push @token_list, {user_id => $token->user_id,
						   timestamp => $token->timestamp};

	}

	return \@token_list;

}

sub get_all_users
{

	my ($self) = @_;

	my @user_list;
	my $result_set = $self->{_schema}->resultset('User')->search(
	{
	},
	{
		join      => 'user_roles',
		'+select' => ['user_roles.role_id'],
		'+as'     => ['user_role_id'],
	}
	);

	while (my $user = $result_set->next)
	{

		push @user_list, {user_id => $user->id,
		user_name => $user->username,
		email_address => $user->email_address,
		first_name => $user->first_name,
		last_name => $user->last_name,
		is_active => $user->active,
		user_role_id => $user->get_column('user_role_id')};

	}

	return \@user_list;

}

sub get_current_email_address_by_user_id
{

	my ($self, $user_id) = @_;

	my $result;

	my $email_address = $self->{_schema}->resultset('User')->single({
			id => $user_id
	})->email_address;

	if($email_address)
	{

		$result = $email_address;

	}
	else
	{

		$result = undef;

	}

	return $result;

}

sub get_current_username_by_email_address
{

	my ($self, $email_address) = @_;

	my $result;

	my $username = $self->{_schema}->resultset('User')->single({
			email_address => $email_address
	})->username;

	if($username)
	{

		$result = $username;

	}
	else
	{

		$result = undef;

	}

	return $result;

}


sub get_current_username_by_user_id
{

	my ($self, $user_id) = @_;

	my $result;

	my $username = $self->{_schema}->resultset('User')->single({
			id => $user_id
	})->username;

	if($username)
	{

		$result = $username;

	}
	else
	{

		$result = undef;

	}

	return $result;

}

sub get_stored_timestamp
{

	my ($self, $email_address) = @_;

	my $user_id = $self->{_schema}->resultset('User')->single(
		{email_address => $email_address}
	)->id;

	my $timestamp = $self->{_schema}->resultset('PasswordResetRequest')->single({
			user_id => $user_id
	})->timestamp;

	return $timestamp

}

sub get_email_address_match_count
{

	my ($self, $email_address) = @_;

	  my $result_set = $self->{_schema}->resultset('User')->search(
		{
			email_address => $email_address
		},
		{
			columns => [qw/ email_address /]
		}
	);

	my $count = $result_set->count;

	return $count;

}

sub get_user_by_id
{

	my ($self, $user_id) = @_;

	my $result;

	my $user = $self->{_schema}->resultset('User')->single({id => $user_id});

	if($user)
	{

		$result = $user;

	}
	else
	{

		$result = undef;

	}

	return $result;

}

sub get_user_details_by_username
{

	my ($self, $username) = @_;

	my @user_details;

	my $result_set = $self->{_schema}->resultset('User')->search(
	{
		username => $username
	}
	);

	while(my $user_details = $result_set->next)
	{

		push @user_details,
		{
			user_id => $user_details->id,
			email_address => $user_details->email_address,
			first_name => $user_details->first_name,
			last_name => $user_details->last_name,
			active => $user_details->active,
			institution_name => $user_details->institution_name,
			institution_city => $user_details->institution_city,
			institution_country => $user_details->institution_country,
		};
	}

	return \@user_details;

}

sub get_user_email_by_username
{

	my ($self, $username) = @_;

	my $result;

	my $user_email = $self->{_schema}->resultset('User')->single(
		{username => $username}
	)->email_address;

	if($user_email)
	{

		$result = $user_email;

	}
	else
	{

		$result = $INVALID_CONST;

	}

	return $result;

}

sub get_user_id_by_email
{

	my ($self, $email_address) = @_;

	my $result;

	my $user_id = $self->{_schema}->resultset('User')->single(
		{email_address => $email_address}
	)->id;

	if($user_id)
	{

		$result = $user_id;

	}
	else
	{

		$result = $NO_USER_ID;

	}

	return $result;

}

sub get_user_id_by_username
{

	my ($self, $username) = @_;

	my $result;

	my $user_id = $self->{_schema}->resultset('User')->single(
		{username => $username}
	)->id;

	if($user_id)
	{

		$result = $user_id;

	}
	else
	{

		$result = $NO_USER_ID;

	}

	return $result;


}

sub get_user_role
{

	my ($self, $username) = @_;

	my $user_id = $self->{_schema}->resultset('User')->single(
		{username => $username}
	)->id;

	my $role_id = $self->{_schema}->resultset('UserRole')->single(
		{user_id => $user_id}
	)->role_id;


	return $role_id;


}

sub get_user_token_exists_by_email_address
{

	my ($self,$email_address) = @_;

	my $exists;

	my $user_id = $self->{_schema}->resultset('User')->single(
		{email_address => $email_address}
	)->id;

	  my $result_set = $self->{_schema}->resultset('PasswordResetRequest')->search(
		{
			user_id => $user_id
		},
		{
			columns => [qw/ user_id /]
		}
	);

	my $count = $result_set->count;

	if($count > 0)
	{

		$exists = $TRUE;

	}
	else
	{

		$exists = $FALSE;

	}

	return $exists

}

sub get_username_match_count
{

	my ($self, $username) = @_;

	my $result_set = $self->{_schema}->resultset('User')->search(
		{
			username => $username
		},
		{
			columns => [qw/ username /]
		}
	);

	my $count = $result_set->count;

	return $count;

}

sub get_user_token_exists_by_username
{

	my ($self,$username) = @_;

	my $exists;

	my $user_id = $self->{_schema}->resultset('User')->single(
		{username => $username}
	)->id;

	  my $result_set = $self->{_schema}->resultset('PasswordResetRequest')->search(
		{
			user_id => $user_id
		},
		{
			columns => [qw/ user_id /]
		}
	);

	my $count = $result_set->count;

	if($count > 0)
	{

		$exists = $TRUE;

	}
	else
	{

		$exists = $FALSE;

	}

	return $exists

}

sub insert_new_user_lockout_info
{
	my ($self, $username, $fail_attempt_count, $first_failed_attempt_timestamp, $lockout_timestamp) = @_;

	my $result = $self->{_schema}->resultset('TblLockout')->create({
		username => $username,
		failed_attempt_count => $fail_attempt_count,
		first_failed_attempt_timestamp => $first_failed_attempt_timestamp,
		lockout_timestamp => $lockout_timestamp
	});

}

sub insert_user_password_history_info
{

	my ($self, $username, $password, $time_stamp) = @_;


	my $result = $self->{_schema}->resultset('PasswordHistory')->create({
		username => $username,
		used_password => $password,
		password_timestamp => $time_stamp
	});

	my $user_id = $self->get_user_id_by_username($username);
	my $password_history_id = $self->get_password_history_id_by_username($username,$password);

	$result = $self->{_schema}->resultset('UserPasswordHistory')->create({
		user_id => $user_id,
		password_history_id => $password_history_id
	});

}


sub insert_new_user
{

	my ($self, $fname, $lname, $ins_name, $ins_city, $ins_country, $username,$password,$email_address,$role, $time_stamp) = @_;

	my $result=$FALSE;

	my %roles = (
		admin => 2,
		user => 1,
		none => 0
	);

	my $lockout_info = $self->insert_new_user_lockout_info($username,0,'','');
	my $lockout_id = $lockout_info->lockout_id;

	if(exists $roles{$role})
	{

	my $guard = $self->{_schema}->txn_scope_guard;
	my $role_id = $self->{_schema}->resultset('Role')->single({role => $role})->id;

	my $user;

	if($role eq "none")
	{
		$user = $self->{_schema}->resultset('User')->create({
			username => $username,
			password => $password,
			email_address => $email_address,
			first_name => $fname,
			last_name => $lname,
			institution_name => $ins_name,
			institution_city => $ins_city,
			institution_country => $ins_country,
			active => 0,
			lockout_status =>0,
			lockout_id => $lockout_id,
			time_since_password_change => $time_stamp
		});

	}
	else
	{
		$user = $self->{_schema}->resultset('User')->create({
			username => $username,
			password => $password,
			email_address => $email_address,
			first_name => $fname,
			last_name => $lname,
			institution_name => $ins_name,
			institution_city => $ins_city,
			institution_country => $ins_country,
			active => 1,
			lockout_status =>0,
			lockout_id => $lockout_id,
			time_since_password_change => $time_stamp
		});
	}

	my $user_role = $self->{_schema}->resultset('UserRole')->create({
		user_id => $user->id,
		role_id => $role_id
	});

	my $password_history_info = $self->insert_user_password_history_info($username,$password, $time_stamp);


	$guard->commit;
	$result = $TRUE;

	}

	return $result;

}

sub insert_reset_token_by_email_address
{

	my($self, $to_email_address, $reset_token, $time_stamp) = @_;

	my $result;
	my $guard = $self->{_schema}->txn_scope_guard;
	my $user;

	my $user_id = $self->{_schema}->resultset('User')->single({
			email_address => $to_email_address
	})->id;

	my $result_set = $self->{_schema}->resultset('PasswordResetRequest')->single(
		{
			user_id => $user_id
		}
	);

	$user = $self->{_schema}->resultset('PasswordResetRequest')->create({
		token => $reset_token,
		timestamp => $time_stamp,
		user_id => $user_id
	});

	$guard->commit;

	return $TRUE;

}

sub insert_reset_token_by_username
{

	my($self, $username, $reset_token, $time_stamp) = @_;

	my $result;
	my $guard = $self->{_schema}->txn_scope_guard;
	my $user;

	my $user_id = $self->{_schema}->resultset('User')->single({
			username => $username
	})->id;

	my $result_set = $self->{_schema}->resultset('PasswordResetRequest')->single(
		{
			user_id => $user_id
		}
	);

	$user = $self->{_schema}->resultset('PasswordResetRequest')->create({
		token => $reset_token,
		timestamp => $time_stamp,
		user_id => $user_id
	});

	$guard->commit;

	return $TRUE;

}

sub update_reset_token_by_email_address
{

	my($self, $to_email_address, $reset_token, $time_stamp) = @_;

	my $result;
	my $guard = $self->{_schema}->txn_scope_guard;

	my $user_id = $self->{_schema}->resultset('User')->single({
			email_address => $to_email_address
	})->id;

	my $result_set = $self->{_schema}->resultset('PasswordResetRequest')->single(
		{
			user_id => $user_id
		}
	);

	$result_set->token($reset_token);
	$result_set->timestamp($time_stamp);
	$result_set->update;

	$guard->commit;

	return $TRUE;
}

sub update_reset_token_by_username
{

	my($self, $username, $reset_token, $time_stamp) = @_;

	my $result;
	my $guard = $self->{_schema}->txn_scope_guard;
	my $user;

	my $user_id = $self->{_schema}->resultset('User')->single({
			username => $username
	})->id;

	my $result_set = $self->{_schema}->resultset('PasswordResetRequest')->single(
		{
			user_id => $user_id
		}
	);

	$result_set->token($reset_token);
	$result_set->timestamp($time_stamp);
	$result_set->update;

	$guard->commit;

	return $TRUE;

}

sub update_user_password
{

	my ($self,$username, $new_password, $time_stamp) = @_;
	my $result = $FALSE;
	my $user_password_to_update = $self->{_schema}->resultset('User')->single({username => $username});

	if($user_password_to_update)
	{

		$user_password_to_update->password($new_password);
		$user_password_to_update->time_since_password_change($time_stamp);
		$user_password_to_update->update;

		$result = $TRUE;

	}
	if($result)
	{

		my $user_id = $user_password_to_update->id;
		$self->delete_reset_token($user_id);

		my $user_password_history_count = $self->get_user_password_history_count($username);

		if($user_password_history_count >= $MAX_USER_PASSWORDS_STORED)
		{

			$self->update_password_history($username,$new_password,$time_stamp);

		}
		else
		{

			my $username = $user_password_to_update->username;
			$self->insert_user_password_history_info($username, $new_password, $time_stamp);

		}

	}

	return $result;

}


sub update_user_email_by_user_id
{

	my ($self,$new_email, $user_id) = @_;

	my $result = $FALSE;

	my $user_email_to_update = $self->{_schema}->resultset('User')->single({id => $user_id});

	if($user_email_to_update)
	{

		$user_email_to_update->email_address($new_email);
		$user_email_to_update->update;

		$result = $TRUE;

	}

	return $result;

}

sub update_user_fname_lname_by_user_id
{

	my ($self,$first_name, $last_name, $user_id) = @_;

	my $result = $FALSE;

	my $user_name_to_update = $self->{_schema}->resultset('User')->single({id => $user_id});

	if($user_name_to_update)
	{

		$user_name_to_update->first_name($first_name);
		$user_name_to_update->last_name($last_name);
		$user_name_to_update->update;

		$result = $TRUE;

	}

	return $result;

}

sub update_user_institution_info_by_user_id
{
	my ($self,$ins_name, $ins_city, $ins_country, $user_id) = @_;

	my $result = $FALSE;

	my $user_ins_info_to_update = $self->{_schema}->resultset('User')->single({id => $user_id});

	if($user_ins_info_to_update)
	{

		$user_ins_info_to_update->institution_name($ins_name);
		$user_ins_info_to_update->institution_city($ins_city);
		$user_ins_info_to_update->institution_country($ins_country);
		$user_ins_info_to_update->update;

		$result = $TRUE;

	}

	return $result;

}


sub update_username_by_user_id
{

	my ($self,$new_username, $user_id) = @_;

	my $result = $FALSE;

	my $username_to_update = $self->{_schema}->resultset('User')->single({id => $user_id});

	if($username_to_update)
	{

		$username_to_update->username($new_username);
		$username_to_update->update;

		$result = $TRUE;

	}

	return $result;

}

sub update_role_by_user_id
{

	my ($self, $new_role, $user_id) = @_;

	my $result = $FALSE;

	my $user_role_to_update = $self->{_schema}->resultset('UserRole')->single({user_id => $user_id});

	if($user_role_to_update)
	{

		$user_role_to_update->role_id($new_role);
		$user_role_to_update->update;

		$result = $TRUE;

	}

	return $result;


}


sub get_lockout_status
{
	my ($self, $username) = @_;

	my $lockout_status = $self->{_schema}->resultset('User')->single({
			username => $username
	})->lockout_status;

	return $lockout_status;
}

sub get_user_failed_attempts
{
	my ($self, $username) = @_;

	my $failed_attempt_count = $self->{_schema}->resultset('TblLockout')->single({
			username => $username
	})->failed_attempt_count;

	return $failed_attempt_count;
}

sub get_user_first_failed_attempt_timestamp
{
	my ($self, $username) = @_;

	my $timestamp = $self->{_schema}->resultset('TblLockout')->single({
			username => $username
	})->first_failed_attempt_timestamp;

	return $timestamp;
}

sub get_user_lockout_timestamp
{
	my ($self, $username) = @_;

	my $timestamp = $self->{_schema}->resultset('TblLockout')->single({
			username => $username
	})->lockout_timestamp;

	return $timestamp;
}

sub increment_failed_attempts
{

	my ($self, $username, $failed_attempt_count) = @_;

	my $result = $FALSE;

	my $user_failed_attempts_to_update = $self->{_schema}->resultset('TblLockout')->single({username => $username});

	if($user_failed_attempts_to_update)
	{

		$user_failed_attempts_to_update->failed_attempt_count($failed_attempt_count);
		$user_failed_attempts_to_update->update;

		$result = $TRUE;

	}

	return $result;
}

sub reset_user_lockout_info
{
	my ($self, $username, $lockout_status, $failed_attempts_count, $first_failed_attempt_timestamp, $lockout_timestamp) = @_;

	my $result = $FALSE;

	my $user_lockout_info_reset = $self->{_schema}->resultset('TblLockout')->single({username => $username});

	if($user_lockout_info_reset)
	{

		$user_lockout_info_reset->failed_attempt_count($failed_attempts_count);
		$user_lockout_info_reset->first_failed_attempt_timestamp($first_failed_attempt_timestamp);
		$user_lockout_info_reset->lockout_timestamp($lockout_timestamp);
		$user_lockout_info_reset->update;

		$user_lockout_info_reset = $self->{_schema}->resultset('User')->single({username => $username});
		$user_lockout_info_reset->lockout_status($lockout_status);
		$user_lockout_info_reset->update;

		$result = $TRUE;

	}

	return $result;
}

sub set_user_first_failed_attempt_timestamp
{
	my ($self, $username, $current_timestamp) = @_;

	my $result = $FALSE;

	my $user_timestamp_to_update = $self->{_schema}->resultset('TblLockout')->single({username => $username});

	if($user_timestamp_to_update)
	{

		$user_timestamp_to_update->first_failed_attempt_timestamp($current_timestamp);
		$user_timestamp_to_update->update;

		$result = $TRUE;

	}

	return $result;
}

sub set_user_lockout_status
{
	my ($self, $username, $status_code, $timestamp) = @_;

	my $result = $FALSE;

	my $user_lockout_status_to_update = $self->{_schema}->resultset('User')->single({username => $username});

	if($user_lockout_status_to_update)
	{

		$user_lockout_status_to_update->lockout_status($status_code);
		$user_lockout_status_to_update->update;

		if($timestamp)
		{
			$user_lockout_status_to_update = $self->{_schema}->resultset('TblLockout')->single({username => $username});
			$user_lockout_status_to_update->lockout_timestamp($timestamp);
			$user_lockout_status_to_update->update;

		}

		$result = $TRUE;

	}

	return $result;
}

sub get_last_date_password_change_by_email_address
{
	my ($self, $user_identifier) = @_;

	my $timestamp_last_change = $self->{_schema}->resultset('User')->single({
			email_address => $user_identifier
	})->time_since_password_change;

	return $timestamp_last_change;

}

sub get_last_date_password_change_by_username
{
	my ($self, $user_identifier) = @_;

	my $timestamp_last_change = $self->{_schema}->resultset('User')->single({
			username => $user_identifier
	})->time_since_password_change;

	return $timestamp_last_change;

}

sub check_password_history
{

	my ($self, $password, $username) = @_;

	my $password_is_used = $FALSE;


	my $result_set = $self->{_schema}->resultset('PasswordHistory')->search(
		{
			username => $username
		});

		while (my $user = $result_set->next)
		{
			if($user->check_password($password))
			{
				$password_is_used = $TRUE;
			}
		}

		return $password_is_used;
}

sub get_password_history_id_by_username
{
	my ($self, $username, $password) = @_;

	my $result_set = $self->{_schema}->resultset('PasswordHistory')->search(
		{
			username => $username
		});

	my $password_history_match;

	while (my $user = $result_set->next)
	{
		if($user->check_password($password))
		{
			$password_history_match = $user;
			last;
		}
	}

	my $password_history_id = $password_history_match->password_history_id;

	return $password_history_id;
}


sub get_user_password_history_count
{
	my ($self, $username) = @_;

	my $result_set = $self->{_schema}->resultset('PasswordHistory')->search(
		{
			username => $username
		},
		{
			columns => [qw/ username /]
		}
	);

	my $count = $result_set->count;

	return $count;
}

sub update_password_history
{
	my ($self, $username, $new_password, $time_stamp) = @_;

	my $result_set = $self->{_schema}->resultset('PasswordHistory')->search(
		{
			username => $username
		}
	);

	my $password_timestamp_column = $result_set->get_column('password_timestamp');

	my $min_password_timestamp = $password_timestamp_column->min;

	$result_set = $self->{_schema}->resultset('PasswordHistory')->single({password_timestamp => $min_password_timestamp});

	$result_set->used_password($new_password);
	$result_set->password_timestamp($time_stamp);
	$result_set->update;

}



1;
__END__
# Below is stub documentation for your module. You'd better edit it!

=head1 NAME

DAL::Dao - Perl extension for blah blah blah

=head1 SYNOPSIS

  use DAL::Dao;
  blah blah blah

=head1 DESCRIPTION

Stub documentation for DAL::Dao, created by h2xs. It looks like the
author of the extension was negligent enough to leave the stub
unedited.

Blah blah blah.

=head2 EXPORT

None by default.



=head1 SEE ALSO

Mention other useful documentation such as the documentation of
related modules or operating system documentation (such as man pages
in UNIX), or any relevant external documentation such as RFCs or
standards.

If you have a mailing list set up for your module, mention it here.

If you have a web site set up for your module, mention it here.

=head1 AUTHOR

Irish Medina, E<lt>irish_m@E<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2014 by Deep Sidhu

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.14.2 or,
at your option, any later version of Perl 5 you may have available.


=cut
