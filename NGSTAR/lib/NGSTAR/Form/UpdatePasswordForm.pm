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

package NGSTAR::Form::UpdatePasswordForm;

use HTML::FormHandler::Moose;
use namespace::autoclean;
extends 'HTML::FormHandler';
with 'HTML::FormHandler::Widget::Theme::Bootstrap3';

has 'ctx' => ( is => 'rw', weak_ref => 1, clearer => 'clear_ctx' );

has_field 'new_password' => (
	do_label => 1,
	type => 'Password',
	label => 'shared.account.password.text',
	tags => { label_after => \&get_password_instructions_popover },
	label_class => 'col-sm-2',
	element_wrapper_class => 'col-sm-10',
	required => 1,
	maxlength => 15,
	element_attr => {class => 'input-full', autocomplete=>"off" },
	validate_method => \&check_password
);

has_field 'confirm_new_password' => (
	do_label => 1,
	type => 'Password',
	label => 'confirm.password.text',
	label_class => 'col-sm-2',
	element_wrapper_class => 'col-sm-10',
	cols => 60,
	required => 1,
	maxlength => 15,
	element_attr => { class => 'input-full', autocomplete=>"off" },
	validate_method => \&check_password
);

has_field 'csrf' => (
	do_label => 0,
	type => 'Hidden',
);

sub check_password
{

	my ($self) = @_;

	unless($self->value =~ /^(?=.{6,20}$)(?=.*?[A-Z])(?=.*?[a-z])(?=.*?\d)(?=.*[\.\-_!])(?!.*\s+)/)
	{

		$self->add_error('shared.check.password.error.msg');

	}

}

sub get_password_instructions_popover
{

	my ($self) = shift;

	return '&nbsp;<span id="username" class="glyphicon glyphicon-info-sign"
		 rel="popover"
		 data-placement="right"
		 tabindex="0"
		 data-html="true"
		 data-content="'.$self->_localize('update.password.popover.info').'">
	 </span>';

}

1;
