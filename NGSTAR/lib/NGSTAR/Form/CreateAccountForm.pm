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

package NGSTAR::Form::CreateAccountForm;

use HTML::FormHandler::Moose;
use namespace::autoclean;
extends 'HTML::FormHandler';
with 'HTML::FormHandler::Widget::Theme::Bootstrap3';

has 'ctx' => ( is => 'rw', weak_ref => 1, clearer => 'clear_ctx' );

has_field 'first_name' => (
	do_label => 1,
	type => 'Text',
	label => 'shared.account.first.name.text',
	label_class => 'col-sm-2',
	element_wrapper_class => 'col-sm-10',
	required => 1,
	maxlength => 20,
	element_attr => {class => 'input-full' },
	validate_method => \&check_name
);

has_field 'last_name' => (
	do_label => 1,
	type => 'Text',
	label => 'shared.account.last.name.text',
	label_class => 'col-sm-2',
	element_wrapper_class => 'col-sm-10',
	required => 1,
	maxlength => 20,
	element_attr => {class => 'input-full' },
	validate_method => \&check_name
);

has_field 'ins_name' => (
	do_label => 1,
	type => 'Text',
	label => 'shared.account.ins.name.text',
	label_class => 'col-sm-2',
	element_wrapper_class => 'col-sm-10',
	required => 1,
	maxlength => 20,
	element_attr => {class => 'input-full' },
	validate_method => \&check_name
);

has_field 'ins_country' => (
	do_label => 1,
	type => 'Text',
	label => 'shared.account.ins.country.text',
	label_class => 'col-sm-2',
	element_wrapper_class => 'col-sm-10',
	required => 1,
	maxlength => 20,
	element_attr => {class => 'input-full' },
	validate_method => \&check_location_country
);

has_field 'ins_city' => (
	do_label => 1,
	type => 'Text',
	label => 'shared.account.ins.city.text',
	label_class => 'col-sm-2',
	element_wrapper_class => 'col-sm-10',
	required => 1,
	maxlength => 20,
	element_attr => {class => 'input-full'},
	validate_method => \&check_location_city
);

has_field 'username' => (
	do_label => 1,
	type => 'Text',
	label => 'shared.account.username.text',
	tags => { label_after => \&get_username_popover },
	label_class => 'col-sm-2',
	element_wrapper_class => 'col-sm-10',
	required => 1,
	maxlength => 20,
	element_attr => { class => 'input-full' },
	validate_method => \&check_username
);

has_field 'password_new_user' => (
	do_label => 1,
	type => 'Password',
	label => 'shared.account.password.text',
	tags => { label_after => \&get_password_popover },
	label_class => 'col-sm-2',
	element_wrapper_class => 'col-sm-10',
	required => 1,
	maxlength => 20,
	element_attr => { class => 'input-full', autocomplete=>"off" },
	validate_method => \&check_password
);
has_field 'email_address' => (
	do_label => 1,
	type => 'Text',
	label => 'shared.account.email.text',
	label_class => 'col-sm-2',
	element_wrapper_class => 'col-sm-10',
	required => 1,
	element_attr => {class => 'input-full' },
	validate_method => \&check_email_address
);

has_field 'validate_password' => (
	do_label => 1,
	type => 'Password',
	label => 'account.confirm.password.text',
	label_class => 'col-sm-2',
	element_wrapper_class => 'col-sm-10',
	rows => 15,
	cols => 60,
	required => 1,
	maxlength => 20,
	element_attr => { class => 'input-full', autocomplete=>"off" },
	validate_method => \&check_password
);

has_field 'csrf' => (
	do_label => 0,
	type => 'Hidden',
);


sub check_username
{

	my ($self) = @_;

	unless($self->value =~ /^[\w\s\.\-_]+$/)
	{

		$self->add_error('shared.check.username.error.msg');

	}

}

sub check_password
{

	my ($self) = @_;

	unless($self->value =~ /^(?=.{6,20}$)(?=.*?[A-Z])(?=.*?[a-z])(?=.*?\d)(?=.*[\.\-_!])(?!.*\s+)/)
	{

		$self->add_error('shared.check.password.error.msg');

	}

}

sub check_email_address
{

	my ($self) = @_;

	unless($self->value =~ /^(\w|\-|\_|\.)+\@((\w|\-|\_)+\.)+[a-zA-Z]{2,}$/)
	{

		$self->add_error('shared.check.email.address.error.msg');

	}

}

sub check_location_city
{

	my ($self) = @_;

	unless($self->value =~ /^[a-zA-Z\s\-]+$/)
	{

		$self->add_error('shared.check.city.error.msg');

	}

}

sub check_location_country
{

	my ($self) = @_;

	unless($self->value =~ /^[a-zA-Z\s\-]+$/)
	{

		$self->add_error('shared.check.country.error.msg');

	}

}

sub check_name
{

	my ($self) = @_;

	unless($self->value =~ /^[a-zA-Z\s\'\-]+$/)
	{

		$self->add_error('shared.check.name.error.msg');

	}

}

sub get_username_popover
{

	my ($self) = shift;

	return '&nbsp;<span id="popover-classifications" class="glyphicon glyphicon-info-sign"
			rel="popover"
			tabindex="0"
			data-placement="right"
			data-original-title=""
			data-html="true"
			data-content="'.$self->_localize("create.account.username.instructions.text").'
			">
			</span>';

}

sub get_password_popover
{

	my ($self) = shift;

	return '&nbsp;<span id="popover-classifications" class="glyphicon glyphicon-info-sign"
			rel="popover"
			tabindex="0"
			data-placement="right"
			data-original-title=""
			data-html="true"
			data-content="'.$self->_localize("create.account.password.instructions.text").'
			">
			</span>';

}

1;
