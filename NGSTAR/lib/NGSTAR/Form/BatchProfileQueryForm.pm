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

package NGSTAR::Form::BatchProfileQueryForm;

use HTML::FormHandler::Moose;
use namespace::autoclean;
extends 'HTML::FormHandler';
with 'HTML::FormHandler::Widget::Theme::Bootstrap3';

has 'ctx' => ( is => 'rw', weak_ref => 1, clearer => 'clear_ctx' );

has_field 'batch_profile_query' => (
	do_label => 1,
	type => 'TextArea',
	label => 'enter.profiles.text',
	label_class => 'col-sm-2',
	element_wrapper_class => 'col-sm-10',
	rows => 15,
	cols => 60,
	element_attr => { class => 'input-full' },
	validate_method => \&check_batch_profile_query
);

has_field 'csrf' => (
	do_label => 0,
	type => 'Hidden',
);


sub check_batch_profile_query
{

	my ($self) = @_;

	if($self->value !~ /^[(0-9)|(\.)|(\,)|(\n)|(\r)|(\s)|(\t)]+$/i)
	{

		$self->add_error('batch.profile.query.entry.error.msg');

	}

}

1;
