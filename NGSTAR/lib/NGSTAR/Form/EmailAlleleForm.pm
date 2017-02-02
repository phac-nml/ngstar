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

package NGSTAR::Form::EmailAlleleForm;

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
	element_attr => {  class => 'input-full' },
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
	element_attr => {  class => 'input-full' },
	validate_method => \&check_name
);

has_field 'email_address' => (
	do_label => 1,
	type => 'Text',
	label => 'shared.account.email.text',
	label_class => 'col-sm-2',
	element_wrapper_class => 'col-sm-10',
	required => 1,
	maxlength => 45,
	element_attr => {  class => 'input-full'},
	validate_method => \&check_email_address
);

has_field 'institution_name' => (
	do_label => 1,
	type => 'Text',
	label => 'shared.account.ins.name.text',
	label_class => 'col-sm-2',
	element_wrapper_class => 'col-sm-10',
	required => 1,
	maxlength => 45,
	element_attr => {  class => 'input-full' },
	validate_method => \&check_name
);

has_field 'institution_city' => (
	do_label => 1,
	type => 'Text',
	label => 'shared.account.ins.city.text',
	label_class => 'col-sm-2',
	element_wrapper_class => 'col-sm-10',
	required => 1,
	maxlength => 25,
	element_attr => {  class => 'input-full' },
	validate_method => \&check_city
);

has_field 'institution_country' => (
	do_label => 1,
	type => 'Text',
	label => 'shared.account.ins.country.text',
	label_class => 'col-sm-2',
	element_wrapper_class => 'col-sm-10',
	required => 1,
	maxlength => 25,
	element_attr => {  class => 'input-full' },
	validate_method => \&check_country
);

has_field 'comments' => (
	do_label => 0,
	type => 'TextArea',
	element_wrapper_class => 'col-sm-offset-2 col-sm-10',
	rows => 12,
	cols => 60,
	required => 0,
	maxlength => 1000,
	element_attr => {  class => 'input-full' },
	validate_method => \&check_comments
);

has_field 'allele_sequence' => (
	do_label => 1,
	type => 'TextArea',
	label => 'shared.sequence.text',
	label_class => 'col-sm-2',
	element_wrapper_class => 'col-sm-10',
	rows => 15,
	cols => 60,
	required => 1,
	maxlength => 5000,
	element_attr => {  class => 'input-full' },
	validate_method => \&check_sequence
);

has_field 'collection_date' => (
	do_label => 1,
	type => 'Text',
	label => 'shared.collection.date.text',
	label_class => 'col-sm-2',
	element_wrapper_class => 'col-sm-10',
	required => 0,
	maxlength => 10,
	element_class => ['form-control'],
	id => 'datepicker',
	element_attr => { class => 'input-full' },
	validate_method => \&check_collection_date
);

has_field 'country' => (
	do_label => 1,
	type => 'Text',
	label => 'shared.country.text',
	label_class => 'col-sm-2',
	element_wrapper_class => 'col-sm-10',
	required => 0,
	maxlength => 45,
	element_attr => {  class => 'input-full' },
	validate_method => \&check_country
);

has_field 'patient_age' => (
	do_label => 1,
	type => 'Text',
	label => 'shared.patient.age.text',
	label_class => 'col-sm-2',
	element_wrapper_class => 'col-sm-10',
	required => 0,
	maxlength => 3,
	element_attr => {  class => 'input-full' },
	validate_method => \&check_age
);

has_field 'epi_data' => (
	do_label => 1,
	type => 'TextArea',
	label => 'shared.additional.epi.data.text',
	label_class => 'col-sm-2',
	element_wrapper_class => 'col-sm-10',
	rows => 12,
	cols => 60,
	required => 0,
	maxlength => 1000,
	element_attr => { class => 'input-full' },
	validate_method => \&check_epi_data
);

has_field 'csrf' => (
	do_label => 0,
	type => 'Hidden',
);

sub check_age
{

	my ($self) = @_;

	unless($self->value =~ /^[0-9]+$/ and $self->value > 0 and $self->value < 120)
	{

		$self->add_error('shared.check.age.error.msg');

	}

}

sub check_collection_date
{

	my ($self) = @_;

	unless($self->value =~ /^\d{4}-\d\d-\d\d$/)
	{

		$self->add_error('shared.check.collection.date.error.msg');

	}

}

sub check_comments
{

	my ($self) = @_;

	unless($self->value =~ /^[\w\s\.\-_\,\:\;\/]+$/)
	{

		$self->add_error('shared.check.curator.comment.error.msg');

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

sub check_epi_data
{

	my ($self) = @_;

	unless($self->value =~ /^[\w\s\.\-_\,\:\;\/]+$/)
	{

		$self->add_error('shared.check.epi.data.error.msg');

	}

}

sub check_sequence
{

	my ($self) = @_;

	unless($self->value =~ /\A[ATCG]+\z/i)
	{

		$self->add_error('shared.check.seq.error.msg');

	}

}

sub check_name
{

	my ($self) = @_;

	unless($self->value =~ /^[a-zA-Z\s\-\']+$/)
	{

		$self->add_error('shared.check.name.error.msg');

	}

}

sub check_city
{

	my ($self) = @_;

	unless($self->value =~ /^[a-zA-Z\s\-]+$/)
	{

		$self->add_error('shared.check.city.error.msg');

	}

}

sub check_country
{

	my ($self) = @_;

	unless($self->value =~ /^[a-zA-Z\s\-]+$/)
	{

		$self->add_error('shared.check.country.error.msg');

	}

}

1;
