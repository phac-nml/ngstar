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

package NGSTAR::Form::EditProfileForm;

use HTML::FormHandler::Moose;
use namespace::autoclean;
extends 'HTML::FormHandler';
with 'HTML::FormHandler::Widget::Theme::Bootstrap3';

has 'ctx' => ( is => 'rw', weak_ref => 1, clearer => 'clear_ctx' );

has_field 'sequence_type' => (
	do_label => 1,
	type => 'Text',
	label => 'shared.profile.type.text',
	label_class => 'col-sm-2',
	element_wrapper_class => 'col-sm-10',
	required => 1,
	maxlength => 3,
	element_attr => { class => 'input-full' },
	validate_method => \&check_type
);

has_field 'allele_type0' => (
	do_label => 1,
	type => 'Text',
	label => 'penA',
	label_class => 'col-sm-2',
	element_wrapper_class => 'col-sm-10',
	required => 1,
	maxlength => 7,
	element_attr => { class => 'input-full' },
	validate_method => \&check_type
);

has_field 'allele_type1' => (
	do_label => 1,
	type => 'Text',
	label => 'mtrR',
	label_class => 'col-sm-2',
	element_wrapper_class => 'col-sm-10',
	required => 1,
	maxlength => 3,
	element_attr => { class => 'input-full' },
	validate_method => \&check_type
);

has_field 'allele_type2' => (
	do_label => 1,
	type => 'Text',
	label => 'porB',
	label_class => 'col-sm-2',
	element_wrapper_class => 'col-sm-10',
	required => 1,
	maxlength => 3,
	element_attr => { class => 'input-full' },
	validate_method => \&check_type
);

has_field 'allele_type3' => (
	do_label => 1,
	type => 'Text',
	label => 'ponA',
	label_class => 'col-sm-2',
	element_wrapper_class => 'col-sm-10',
	required => 1,
	maxlength => 3,
	element_attr => { class => 'input-full' },
	validate_method => \&check_type
);

has_field 'allele_type4' => (
	do_label => 1,
	type => 'Text',
	label => 'gyrA',
	label_class => 'col-sm-2',
	element_wrapper_class => 'col-sm-10',
	required => 1,
	maxlength => 3,
	element_attr => { class => 'input-full' },
	validate_method => \&check_type
);

has_field 'allele_type5' => (
	do_label => 1,
	type => 'Text',
	label => 'parC',
	label_class => 'col-sm-2',
	element_wrapper_class => 'col-sm-10',
	required => 1,
	maxlength => 3,
	element_attr => { class => 'input-full' },
	validate_method => \&check_type
);

has_field 'allele_type6' => (
	do_label => 1,
	type => 'Text',
	label => '23S',
	label_class => 'col-sm-2',
	element_wrapper_class => 'col-sm-10',
	required => 1,
	maxlength => 3,
	element_attr => { class => 'input-full' },
	validate_method => \&check_type
);

has_field 'amr_markers' => (
	do_label => 1,
	type => 'TextArea',
	label => 'shared.amr.markers.text',
	label_class => 'col-sm-2',
	element_wrapper_class => 'col-sm-10',
	rows => 2,
	cols => 60,
	required => 0,
	element_attr => { class => 'input-full' },
	validate_method => \&check_amr_markers
);

has_field 'country' => (
	do_label => 1,
	type => 'Text',
	label => 'shared.country.text',
	label_class => 'col-sm-2',
	element_wrapper_class => 'col-sm-10',
	required => 0,
	maxlength => 45,
	element_attr => { class => 'input-full'},
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
	element_attr => { class => 'input-full'},
	validate_method => \&check_collection_date
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
	element_attr => {class => 'input-full' },
	validate_method => \&check_epi_data
);

has_field 'curator_comment' => (
	do_label => 1,
	type => 'TextArea',
	label => 'shared.curator.comments.text',
	label_class => 'col-sm-2',
	element_wrapper_class => 'col-sm-10',
	rows => 12,
	cols => 60,
	required => 0,
	maxlength => 1000,
	element_attr => {class => 'input-full' },
	validate_method => \&check_curator_comment
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

sub check_amr_markers
{

	my ($self) = @_;

	unless($self->value =~ /^[\w\t\n\s\.\-,:;\/]+$/)
	{

		$self->add_error('shared.check.seq.error.msg');

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

sub check_country
{

	my ($self) = @_;

	unless($self->value =~ /^[a-zA-Z\s\-]+$/)
	{

		$self->add_error('shared.check.country.error.msg');

	}

}

sub check_curator_comment
{

	my ($self) = @_;

	unless($self->value =~ /^[\w\s\.\-_\,\:\;\/]+$/)
	{

		$self->add_error('shared.check.curator.comment.error.msg');

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

sub check_type
{

	my ($self) = @_;

	unless($self->value =~ /^[0-9]\d*(\.\d{0,3})?$/)
	{

		$self->add_error('shared.check.type.val.error.msg');

	}
	else
	{

		if(($self->value < 0) or ($self->value > 999))
		{

			$self->add_error('ui.check.val.range.error');

		}

	}

}

__PACKAGE__->meta->make_immutable;

1;
