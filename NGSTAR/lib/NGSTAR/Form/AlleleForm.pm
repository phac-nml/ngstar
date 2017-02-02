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

package NGSTAR::Form::AlleleForm;

use HTML::FormHandler::Moose;
use namespace::autoclean;
extends 'HTML::FormHandler';
with 'HTML::FormHandler::Widget::Theme::Bootstrap3';

has 'ctx' => ( is => 'rw', weak_ref => 1, clearer => 'clear_ctx' );

has_field 'seq0' => (
	do_label => 1,
	label => 'penA',
	label_class => 'col-sm-2',
	element_wrapper_class => 'col-sm-10',
	type => 'TextArea',
	rows => 8,
	cols => 40,
	validate_method => \&check_sequence,
	element_attr => {  class => 'input-full' }

);

has_field 'seq1' => (
	do_label => 1,
	label => 'mtrR',
	label_class => 'col-sm-2',
	element_wrapper_class => 'col-sm-10',
	type => 'TextArea',
	rows => 8,
	cols => 40,
	validate_method => \&check_sequence,
	element_attr => {  class => 'input-full' }
);

has_field 'seq2' => (
	do_label => 1,
	label => 'porB',
	label_class => 'col-sm-2',
	element_wrapper_class => 'col-sm-10',
	type => 'TextArea',
	rows => 8,
	cols => 40,
	validate_method => \&check_sequence,
	element_attr => {  class => 'input-full' }
);

has_field 'seq3' => (
	do_label => 1,
	label => 'ponA',
	label_class => 'col-sm-2',
	element_wrapper_class => 'col-sm-10',
	type => 'TextArea',
	rows => 8,
	cols => 40,
	validate_method => \&check_sequence,
	element_attr => {  class => 'input-full' }
);

has_field 'seq4' => (
	do_label => 1,
	label => 'gyrA',
	label_class => 'col-sm-2',
	element_wrapper_class => 'col-sm-10',
	type => 'TextArea',
	rows => 8,
	cols => 40,
	validate_method => \&check_sequence,
	element_attr => {  class => 'input-full' }
);

has_field 'seq5' => (
	do_label => 1,
	label => 'parC',
	label_class => 'col-sm-2',
	element_wrapper_class => 'col-sm-10',
	type => 'TextArea',
	rows => 8,
	cols => 40,
	validate_method => \&check_sequence,
	element_attr => {  class => 'input-full' }
);

has_field 'seq6' => (
	do_label => 1,
	label => '23S',
	label_class => 'col-sm-2',
	element_wrapper_class => 'col-sm-10',
	type => 'TextArea',
	rows => 10,
	cols => 40,
	validate_method => \&check_sequence,
	element_attr => {  class => 'input-full' }
);

has_field 'csrf' => (
	do_label => 0,
	type => 'Hidden',
);


sub check_sequence
{

	my ($self) = @_;

	unless($self->value =~ /^[(ATCG)|(\n|\r)]+$/i)
	{

		$self->add_error('shared.check.seq.error.msg');

	}

}

__PACKAGE__->meta->make_immutable;

1;
