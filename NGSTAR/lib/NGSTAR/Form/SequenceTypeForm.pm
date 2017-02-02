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

package NGSTAR::Form::SequenceTypeForm;

use HTML::FormHandler::Moose;
use namespace::autoclean;
extends 'HTML::FormHandler';
with 'HTML::FormHandler::Widget::Theme::Bootstrap3';

has 'ctx' => ( is => 'rw', weak_ref => 1, clearer => 'clear_ctx' );

has_field 'allele_type0' => (
	do_label => 1,
	type => 'Text',
	tags => { label_after => \&get_penA_type_format_popover },
	label => 'penA',
	label_class => 'col-sm-2 required',
	element_wrapper_class => 'col-sm-10',
	required => 1,
	maxlength => 7,
	element_attr => { class => 'input-full' },
	validate_method => \&check_decimal_type
);

has_field 'allele_type1' => (
	do_label => 1,
	type => 'Text',
	label => 'mtrR',
	label_class => 'col-sm-2 required',
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
	label_class => 'col-sm-2 required',
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
	label_class => 'col-sm-2 required',
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
	label_class => 'col-sm-2 required',
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
	label_class => 'col-sm-2 required',
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
	label_class => 'col-sm-2 required',
	element_wrapper_class => 'col-sm-10',
	required => 1,
	maxlength => 3,
	element_attr => { class => 'input-full' },
	validate_method => \&check_type
);

has_field 'csrf' => (
	do_label => 0,
	type => 'Hidden',
);


sub check_type
{

	my ($self) = @_;

	unless($self->value =~ /^[0-9]+$/)
	{

		$self->add_error('shared.check.non.dec.type.val.error.msg');

	}
	else
	{

		if(($self->value < 0) or ($self->value > 999))
		{

			$self->add_error('shared.check.type.range.error.msg');

		}

	}

}

sub check_decimal_type
{

	my ($self) = @_;

	unless($self->value =~ /^(\d{1,3}\.\d{0,3})?$/)
	{

		$self->add_error('shared.check.type.val.error.msg');

	}
	else
	{

		if(($self->value < 0) or ($self->value > 999))
		{

			$self->add_error('shared.check.type.range.error.msg');

		}

	}

}

sub get_penA_type_format_popover
{

	my ($self) = shift;

	return "&nbsp;<span id='popover-classifications' class='glyphicon glyphicon-info-sign'
			rel='popover'
			tabindex='0'
			data-placement='right'
			data-original-title='".$self->_localize("pena.format")."'
			data-html='true'
			data-content='<p> #.### <br>##.### <br>###.### </p>
			'>
			</span>";

}

__PACKAGE__->meta->make_immutable;

1;
