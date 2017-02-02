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

package BusinessLogic::AddScheme;
use BusinessLogic::ValidateAllele;

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

# This allows declaration	use BusinessLogic::AddScheme':all';
# If you do not need this, moving things directly into @EXPORT or @EXPORT_OK
# will save memory.
our %EXPORT_TAGS = ( 'all' => [ qw(

) ] );

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

our @EXPORT = qw(
	_add_scheme
);

our $VERSION = '0.01';

Readonly my $FALSE => 0;
Readonly my $TRUE => 1;

Readonly my $INVALID_CONST => "IS_INVALID";
Readonly my $VALID_CONST => "IS_VALID";

Readonly my $ERROR_DUPLICATE_SCHEME_NAME => "ERROR_DUPLICATE_SCHEME_NAME";

sub new
{

	my $class = shift;
	my $self = {
		_dao => DAL::Dao->new(),
	};
	bless $self, $class;
	return $self;

}

sub _add_scheme
{

	my ($self, $scheme_name) = @_;

	my $result;
	my $validation_result = $self->_validate($scheme_name);

	if($validation_result eq $VALID_CONST)
	{

		my $value = $self->{_dao}->insert_scheme($scheme_name);

		if(not defined $value)
		{

			$result = $INVALID_CONST;

		}
		else
		{

			$result = $VALID_CONST;

		}

	}
	else
	{

		$result = $validation_result;

	}

	return $result;
}

sub _validate
{

	my ($self, $scheme_name) = @_;

	my $invalid_code = $INVALID_CONST;
	my $is_valid = $TRUE;
	my $result;

	if($scheme_name !~ /^[(A-Z)|(_)|(\-)]+$/i)
	{

		$is_valid = $FALSE;

	}

	if($is_valid)
	{

		my $scheme_name_list = $self->{_dao}->get_all_scheme_names();

		foreach my $name (@$scheme_name_list)
		{

			if(lc($scheme_name) eq lc($name))
			{

				$is_valid = $FALSE;
				$invalid_code = $ERROR_DUPLICATE_SCHEME_NAME;

			}

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

1;
__END__
