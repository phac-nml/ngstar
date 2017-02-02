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

package BusinessLogic::AddNewUser;
use BusinessLogic::ValidateNewUser;

use 5.014002;

use strict;
use warnings;

use Bio::Perl;
use Readonly;

use DAL::DaoAuth;
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
	_insert_new_user
);

our $VERSION = '0.01';

Readonly my $INVALID_CONST => "IS_INVALID";
Readonly my $VALID_CONST => "IS_VALID";

sub new
{

	my $class = shift;
	my $self = {
		_daoauth => DAL::DaoAuth->new(),
	};
	bless $self, $class;
	return $self;

}

sub _insert_new_user
{

	my ($self, $fname,$lname,$ins_name,$ins_city,$ins_country,$username,$password,$email_address,$confirm_password, $role, $time_stamp) = @_;

	my $result = $VALID_CONST;

	my $obj = BusinessLogic::ValidateNewUser->new();
	my $validation_result = $obj->_validate_new_user($fname, $lname, $ins_name, $ins_city, $ins_country, $username, $password, $confirm_password, $email_address);

	if($validation_result eq $VALID_CONST)
	{
	if(lc($role) eq lc("curator"))
	{
		$role = "user";
	}

		my $value = $self->{_daoauth}->insert_new_user($fname, $lname, $ins_name, $ins_city, $ins_country, $username, $password, $email_address, $role, $time_stamp);

		if(not defined $value)
		{

			$result = $INVALID_CONST;

		}

	}
	else
	{

		$result = $validation_result

	}

	return $result;
}

1;
__END__
