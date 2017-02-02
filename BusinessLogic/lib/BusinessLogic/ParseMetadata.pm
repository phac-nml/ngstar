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

package BusinessLogic::ParseMetadata;

use 5.014002;
use strict;
use warnings;

use Readonly;

require Exporter;

our @ISA = qw(Exporter);

# Items to export into callers namespace by default. Note: do not export
# names by default without a very good reason. Use EXPORT_OK instead.
# Do not simply export all your public functions/methods/constants.

# This allows declaration	use BusinessLogic::ParseMetadata':all';
# If you do not need this, moving things directly into @EXPORT or @EXPORT_OK
# will save memory.
our %EXPORT_TAGS = ( 'all' => [ qw(

) ] );

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

our @EXPORT = qw(
	_parse_metadata_lines
);

our $VERSION = '0.01';

Readonly my $FALSE => 0;
Readonly my $TRUE => 1;

Readonly my $INVALID_CONST => "IS_INVALID";
Readonly my $VALID_CONST => "IS_VALID";

sub new
{

	my $class = shift;
	my $self = {};
	bless $self, $class;
	return $self;

}

sub _parse_metadata_lines
{

	my ($self, $input) = @_;

	my $is_valid = $TRUE;
	my $result;
	my $validate_result = $self->_validate($input);

	if($validate_result)
	{

		my @temp = split('\n',$input);

		#if @temp is <= 1 then either the file only includes a header line
		#or all data is on 1 line.
		if(scalar @temp > 1)
		{

			$result = \@temp;

		}
		else
		{

			$result = $FALSE;

		}

	}
	else
	{

		$result = $FALSE;

	}

	return $result;

}

sub _validate
{

	my ($self, $input) = @_;

	my $is_valid = $TRUE;

	if($input !~ /^[(<)|(>)|(=)|(\:)|(+)|(A-Z)|(0-9)|(\.)|(\-)|(_)|(\,)|(\n)|(\r)|(\s)|(\t)|(\;)|(\/)]+$/i)
	{

		$is_valid = $FALSE;

	}

	return $is_valid;

}

1;
__END__
