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

package BusinessLogic::AddResetRequest;
use Session::Token;
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
	_insert_reset_token
);

our $VERSION = '0.01';

Readonly my $FALSE => 0;
Readonly my $TRUE => 1;

Readonly my $INVALID_CONST => "IS_INVALID";
Readonly my $VALID_CONST => "IS_VALID";

Readonly my $ERROR_INVALID_EMAIL_ADDRESS => 4000;

sub new
{

	my $class = shift;
	my $self = {
		_dao => DAL::DaoAuth->new(),
	};
	bless $self, $class;
	return $self;

}

sub _insert_reset_token
{

	my ($self, $user_identifier) = @_;

	my $result = $FALSE;
	 my $token = Session::Token->new->get;
	my $time = DateTime->now;
	my $user_has_token;

	if($user_identifier =~ /^(\w|\-|\_|\.)+\@((\w|\-|\_)+\.)+[a-zA-Z]{2,}$/)
	{

		$user_has_token = $self->{_dao}->get_user_token_exists_by_email_address($user_identifier);

		if($user_has_token)
		{

			$result = $self->{_dao}->update_reset_token_by_email_address($user_identifier, $token, $time);

		}
		else
		{

			$result = $self->{_dao}->insert_reset_token_by_email_address($user_identifier, $token, $time);

		}

	}
	else
	{

		$user_has_token = $self->{_dao}->get_user_token_exists_by_username($user_identifier);

		if($user_has_token)
		{

			$result = $self->{_dao}->update_reset_token_by_username($user_identifier, $token, $time);

		}
		else
		{

			$result = $self->{_dao}->insert_reset_token_by_username($user_identifier, $token, $time);

		}

	}

	if(not $result)
	{

		$token = $INVALID_CONST;

	}

	return $token;
}

1;
__END__
