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

package NGSTAR::Controller::ForgotPassword;
use Moose;
use namespace::autoclean;
use NGSTAR::Form::ForgotPasswordForm;
use Catalyst qw( ConfigLoader );

BEGIN { extends 'Catalyst::Controller'; }

use Session::Token;


=head1 NAME

NGSTAR::Controller::ForgotPassword - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index

=cut

use Readonly;

Readonly my $TRANSLATION_LANG => "fr";
Readonly my $DEFAULT_LANG => "en";

Readonly my $FALSE => 0;
Readonly my $TRUE => 1;

Readonly my $INVALID_CONST => "IS_INVALID";
Readonly my $VALID_CONST => "IS_VALID";

Readonly my $SUCCESS => "SUCCESS";

Readonly my $RESET_TOKEN_EXISTS_FOR_EMAIL => 4021;

Readonly my $FORGOT_PASSWORD_PAGE_TITLE => "shared.forgot.password.text";
Readonly my $ERROR_404_PAGE_TITLE => "shared.404.page.not.found.text";
Readonly my $ERROR_BASE_STRING => "modal.confirm.error.";


sub begin : Private
{

	my ( $self, $c ) = @_;

	if($c->request->referer and (index($c->request->referer, NGSTAR->config->{ngstar_base_url}) == -1))
	{

		$c->res->redirect($c->uri_for($c->controller('Welcome')->action_for('home')));

	}
	else
	{

		if(not $c->req->cookie('ngstar_lang_pref'))
		{
			$c->res->redirect($c->uri_for($c->controller('Welcome')->action_for('language_selection')));

		}
		else
		{

			if(not $c->session->{csrf_token})
			{
				$c->session->{csrf_token} = Session::Token->new(length => 128)->get;
			}

			my $cookie = "";

			if($c->req->cookie('ngstar_eula_acceptance'))
			{
				$cookie = $c->req->cookie('ngstar_eula_acceptance')->value;
			}

			if(not $cookie eq NGSTAR->config->{eula_version})
			{
				$c->res->redirect($c->uri_for($c->controller('Welcome')->action_for('eula')));
			}
			else
			{

				if($c->req->cookie('ngstar_lang_pref'))
				{
					$cookie = $c->req->cookie('ngstar_lang_pref')->value;

					if(length $cookie == 2)
					{
						$c->session->{lang} = $c->req->cookie('ngstar_lang_pref')->value;
					}
					else
					{
						$c->session->{lang} = $DEFAULT_LANG;
					}
				}

				my $locale = $cookie;

				$c->languages( $locale ? [ $locale ] : undef );

				my $allowed_ips = NGSTAR->config->{allowed_ips};

				if ($c->request->address =~ /^($allowed_ips)$/)
				{
					$c->stash(login_allow => "true");
				}
				else
				{
					$c->stash(login_allow => "false");
				}
			}
		}
	}
}

sub default :Path
{

	my ( $self, $c ) = @_;

	#$c->response->body( 'Page not found' );
	#$c->response->status(404);

	$c->stash(template => 'error/error_404.tt2', page_title => $ERROR_404_PAGE_TITLE);

}

sub index :Path :Args(0)
{

	my ( $self, $c ) = @_;

	$c->log->debug('*** INSIDE FORGOTPASSWORD index METHOD ***');

	if($c->stash->{'login_allow'} eq "true")
	{


		my $account_services_email_address = $c->config->{account_services_email};
		my $reset_password_link = $c->config->{reset_password_link};

		my $to_email_address = $INVALID_CONST;

		my $curr_lang = $c->session->{lang};
		my $lh = NGSTAR::I18N::i_default->new;

		if($c->session->{lang})
		{
			if($c->session->{lang} eq $TRANSLATION_LANG)
			{
				$lh = NGSTAR::I18N::fr->new;
			}
		}

		my $form = NGSTAR::Form::ForgotPasswordForm->new(language_handle => $lh, ctx => $c);

		$form->process(update_field_list => {
			user_identifier => {messages => {required => $c->loc('shared.enter.user.identifier.msg')}},
			csrf => {default => $c->session->{csrf_token} },
		});

		$c->stash(template => 'forgot_password/ForgotPassword.tt2', form => $form, page_title => $FORGOT_PASSWORD_PAGE_TITLE);

		$form->process(params => $c->request->params);
		return unless $form->validated;

		my $user_identifier = $c->request->params->{user_identifier};
		my $csrf_form_submitted = $c->request->params->{csrf};
		my $token;
		my $result = $FALSE;

		if($csrf_form_submitted and $csrf_form_submitted eq $c->session->{csrf_token})
		{

			my $obj = $c->model('GetUserInfo');
			my $validation_result = $obj->_check_email_exists($user_identifier);

			if(not $validation_result)
			{

				$validation_result = $obj->_check_username_exists($user_identifier);

			}
			else
			{

				$to_email_address = $user_identifier;

			}

			if($validation_result)
			{

				$c->session->{csrf_token} = Session::Token->new(length => 128)->get;

				$obj = $c->model('AddResetRequest');
				$token = $obj->_insert_reset_token($user_identifier);

				if($token ne $INVALID_CONST)
				{

					if($to_email_address eq $INVALID_CONST)
					{

						$obj = $c->model('GetUserInfo');
						$to_email_address = $obj->_get_user_email_by_username($user_identifier);

					}

					$c->model('Email')->send(
						from => $account_services_email_address,
						to => $to_email_address,
						subject => $c->loc('password.reset.email.subject.text'),
						htmltext => $c->loc("password.reset.email.body.text", $reset_password_link, $token)
					);

					$c->stash(code => $SUCCESS);

				}
				else
				{

					my $err_msg = $c->loc($ERROR_BASE_STRING.$RESET_TOKEN_EXISTS_FOR_EMAIL);
					$c->stash(error_id => $RESET_TOKEN_EXISTS_FOR_EMAIL, error_code => $err_msg);

				}

			}

		}
		else
		{

			$c->response->redirect($c->uri_for($self->action_for('index')));

		}

	}
	else
	{

		$c->stash(template => 'error/error_404.tt2', page_title => $ERROR_404_PAGE_TITLE);

	}

}

=encoding utf8

=head1 AUTHOR

Sukhdeep Sidhu

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
