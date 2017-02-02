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

package NGSTAR::Form::EditAminoAcidForm;

use HTML::FormHandler::Moose;
use namespace::autoclean;
extends 'HTML::FormHandler';
with 'HTML::FormHandler::Widget::Theme::Bootstrap3';

has_field 'position' => (
	do_label => 0,
	type => 'Text',
	required => 1,
	maxlength => 30,
	element_attr => { class => 'input-full' },
	validate_method => \&check_position

);

has_field 'amino_acid' => (
	do_label => 0,
	type => 'Text',
	required => 1,
	maxlength => 1,
	element_attr => { class => 'input-full' },
	validate_method => \&check_aa

);


sub check_position
{

	my ($self) = @_;

	unless($self->value =~ /^[0-9]+$/)
	{

		$self->add_error('Please enter a valid position. This field accepts numbers only');

	}

}

sub check_aa
{

	my ($self) = @_;

	unless($self->value =~ /^[a-zA-Z\.]+$/)
	{

		$self->add_error('Please enter a valid amino acid. This field accepts letters and periods only');

	}

}



1;
