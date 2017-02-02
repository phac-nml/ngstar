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

package NGSTAR::Controller::Scheme;
use Moose;
use namespace::autoclean;
use NGSTAR::Form::AddSchemeForm;

use Readonly;

BEGIN { extends 'Catalyst::Controller'; }

=head1 NAME

NGSTAR::Controller::Scheme - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index

=cut

Readonly my $FALSE => 0;
Readonly my $TRUE => 1;

Readonly my $INVALID_CONST => "IS_INVALID";
Readonly my $VALID_CONST => "IS_VALID";

Readonly my $ERROR_CODE_DEFAULT => 0;

sub add_scheme :Local
{

	my ($self, $c) = @_;

	if($c->user_exists() and $c->check_any_user_role(qw/ user admin /))
	{

		my $form = NGSTAR::Form::AddSchemeForm->new;
		$c->stash(template => 'scheme/AddSchemeForm.tt2', form => $form);

		$form->process(params => $c->request->params);
		return unless $form->validated;

		my $scheme_name = $c->request->params->{scheme_name};

		my $has_error = $FALSE;

		if($scheme_name !~ /^[(A-Z)|(_)|(\-)]+$/i)
		{

			$has_error = $TRUE;

		}

		if(not $has_error)
		{

			my $obj = $c->model('AddScheme');
			my $result = $obj->_add_scheme($scheme_name);

			if($result eq $VALID_CONST)
			{

			}
			else
			{

				$c->response->redirect($c->uri_for($self->action_for('error'), $result));

			}

		}
		else
		{

			$c->response->redirect($c->uri_for($self->action_for('error'), $ERROR_CODE_DEFAULT));

		}

	}
	else
	{

		$c->response->status(401);
		$c->response->body("Unauthorized");

	}

}

sub error :Local :Args(1)
{

	my ($self, $c, $error_code) = @_;

	$c->stash(template => 'error/SchemeError.tt2', error_code => $error_code);

}

=encoding utf8

=head1 AUTHOR

Irish Medina

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
