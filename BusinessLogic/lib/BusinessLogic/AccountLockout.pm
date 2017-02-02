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

package BusinessLogic::AccountLockout;
use DateTime;

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

# This allows declaration	use BusinessLogic::AddAllele':all';
# If you do not need this, moving things directly into @EXPORT or @EXPORT_OK
# will save memory.
our %EXPORT_TAGS = ( 'all' => [ qw(

) ] );

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

our @EXPORT = qw(
	_check_account_unlock
	_check_lockout_status
	_check_user_failed_attempts
	_check_user_first_failed_attempt_timestamp
	_increment_failed_attempts
	_reset_user_lockout_info
	_set_user_first_failed_attempt_timestamp
	_set_user_lockout_status
 );

our $VERSION = '0.01';


Readonly my $FALSE => 0;
Readonly my $TRUE => 1;

Readonly my $LOCKED_OUT_STATUS => 1;
Readonly my $MAX_ATTEMPT_TIME => 5;
Readonly my $MAX_ATTEMPTS => 10;
Readonly my $MIN_TIME_TO_UNLOCK => 60;

sub new
{

	my $class = shift;
	my $self = {
		_dao => DAL::DaoAuth->new(),
	};
	bless $self, $class;
	return $self;

}


sub _check_account_unlock
{
	my ($self, $username) = @_;

	my $result = $FALSE;

	my $user_lockout_timestamp = $self->{_dao}->get_user_lockout_timestamp($username);

	my $time;
	my $dur;

	if($user_lockout_timestamp)
	{
		$time = DateTime->now(time_zone=>'local');

		$dur = $time->subtract_datetime($user_lockout_timestamp);

		if( (($dur->years() != 0) or ($dur->months() != 0) or ($dur->days() != 0) or ($dur->hours() != 0)) or ($dur->minutes() > $MIN_TIME_TO_UNLOCK))
		{

			$result = $TRUE;

		}
	}

	return $result;

}

sub _check_lockout_status
{

	my ($self, $username) = @_;

	my $result = $FALSE;

	my $lockout_status = $self->{_dao}->get_lockout_status($username);

	if($lockout_status == $LOCKED_OUT_STATUS)
	{
		$result = $TRUE;
	}

	return $result;

}

sub _check_user_failed_attempts
{

	my ($self, $username) = @_;

	my $result = $FALSE;

	my $user_failed_attempts_count = $self->{_dao}->get_user_failed_attempts($username);

	if($user_failed_attempts_count > $MAX_ATTEMPTS)
	{
		$result = $TRUE;
	}

	return $result;

}

sub _check_user_first_failed_attempt_timestamp
{

	my ($self, $username) = @_;

	my $result = $FALSE;

	my $user_first_failed_attempt_timestamp = $self->{_dao}->get_user_first_failed_attempt_timestamp($username);

	my $time = DateTime->now(time_zone=>'local');

	if($user_first_failed_attempt_timestamp)
	{
		my $dur = $time->subtract_datetime($user_first_failed_attempt_timestamp);


		if( (($dur->years() != 0) or ($dur->months() != 0) or ($dur->days() != 0) or ($dur->hours() != 0)) or ($dur->minutes() > $MAX_ATTEMPT_TIME))
		{

			$result = $TRUE;

		}

	}

	return $result;

}

sub _increment_failed_attempts
{

	my ($self, $username) = @_;

	my $attempt_add_value = 1;
	my $result = $TRUE;

	my $attempt_count = $self->{_dao}->get_user_failed_attempts($username);

	if($attempt_count == 0)
	{
		$self->_set_user_first_failed_attempt_timestamp($username);
	}
	elsif($attempt_count >= $MAX_ATTEMPTS)
	{
		$self->_set_user_lockout_status($username);
		$result= $FALSE;
	}

	if($result)
	{
		$result = $self->{_dao}->increment_failed_attempts($username, $attempt_count + $attempt_add_value);
	}

	return $result;

}


sub _reset_user_lockout_info
{

	my ($self, $username) = @_;

	my $lockout_status = 0;
	my $failed_attempts_count = 0;
	my $first_failed_attempt_timestamp = undef;
	my $lockout_timestamp = undef;

	my $result = $self->{_dao}->reset_user_lockout_info($username, $lockout_status, $failed_attempts_count, $first_failed_attempt_timestamp, $lockout_timestamp);

	return $result;

}

sub _set_user_first_failed_attempt_timestamp
{

	my ($self, $username) = @_;

	my $current_timestamp = DateTime->now(time_zone=>'local');

	my $result = $self->{_dao}->set_user_first_failed_attempt_timestamp($username, $current_timestamp);

	return $result;
}

sub _set_user_lockout_status
{

	my ($self, $username) = @_;

	my $current_timestamp;

	if(not $self->{_dao}->get_user_lockout_timestamp($username))
	{
		$current_timestamp = DateTime->now(time_zone=>'local');
	}

	my $result = $self->{_dao}->set_user_lockout_status($username, $LOCKED_OUT_STATUS, $current_timestamp);

	return $result;

}

1;
__END__
