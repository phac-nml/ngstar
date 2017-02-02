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

package NGSTAR::Form::AddSchemeForm;

use HTML::FormHandler::Moose;
use namespace::autoclean;
extends 'HTML::FormHandler';
with 'HTML::FormHandler::Widget::Theme::Bootstrap3';

has 'ctx' => ( is => 'rw', weak_ref => 1, clearer => 'clear_ctx' );

has_field 'scheme_name' => (
	do_label => 0,
	type => 'Text',
	required => 1,
	messages => {required => 'Please enter a scheme name'},
	minlength => 2,
	maxlength => 20,
	validate_method => \&check_name
);

sub check_name
{

	my ($self) = @_;

	unless($self->value =~ /^[(A-Z)|(_)|(\-)]+$/i)
	{

		$self->add_error('Please add a valid scheme name. This field can only contain letters, ( - ) , and ( _ )');
	}

}

1;
