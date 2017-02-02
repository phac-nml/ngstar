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

package NGSTAR::Controller::ResetPassword;
use Moose;
use namespace::autoclean;
use NGSTAR::Form::ResetPasswordForm;
use NGSTAR::Form::UpdatePasswordForm;

use Catalyst qw( ConfigLoader );

BEGIN { extends 'Catalyst::Controller'; }

use Session::Token;


=head1 NAME

NGSTAR::Controller::ResetPassword - Catalyst Controller

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

Readonly my $PASSWORD_SUCCESSFULLY_UPDATED => "PASSWORD_SUCCESSFULLY_UPDATED";

Readonly my $ERROR_PASSWORDS_DO_NOT_MATCH => 4011;
Readonly my $ERROR_PASSWORD_UPDATE_UNSUCCESSFUL => 4012;
Readonly my $INVALID_TOKEN_OR_EMAIL => 4016;
Readonly my $ERROR_PASSWORD_FORMAT => 4017;
Readonly my $INVALID_USER_ID => 4022;

Readonly my $NO_USER_ID => -9999;

Readonly my $ERROR_BASE_STRING => "modal.confirm.error.";



Readonly my $CHANGE_PASSWORD_PAGE_TITLE => "shared.change.password.text";
Readonly my $RESET_PASSWORD_PAGE_TITLE => "shared.reset.password.text";
Readonly my $ERROR_404_PAGE_TITLE => "shared.404.page.not.found.text";

Readonly my $ERROR_SAME_PASSWORD => 4015;





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

				if(not $c->session->{csrf_token})
				{
					$c->session->{csrf_token} = Session::Token->new(length => 128)->get;
				}

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

	$c->log->debug('*** INSIDE RESETPASSWORD index METHOD ***');

	if($c->stash->{'login_allow'} eq "true")
	{

		my $curr_lang = $c->session->{lang};
		my $lh = NGSTAR::I18N::i_default->new;

		if($c->session->{lang})
		{
			if($c->session->{lang} eq $TRANSLATION_LANG)
			{
				$lh = NGSTAR::I18N::fr->new;
			}
		}

		my $form = NGSTAR::Form::ResetPasswordForm->new(language_handle => $lh, ctx => $c);

		$form->process(update_field_list => {
			email_address => {messages => {required => $c->loc('shared.enter.email.address.msg')}},
			reset_token => {messages => {required => $c->loc('enter.reset.token.msg')}},
			csrf => {default => $c->session->{csrf_token} },
		});

		$c->stash(template => 'forgot_password/ResetPassword.tt2', form => $form, page_title => $RESET_PASSWORD_PAGE_TITLE);

		$form->process(params => $c->request->params);
		return unless $form->validated;

		my $email_address = $c->request->params->{email_address};
		my $reset_token = $c->request->params->{reset_token};
		my $csrf_form_submitted = $c->request->params->{csrf};

		if($csrf_form_submitted and $csrf_form_submitted eq $c->session->{csrf_token})
		{

			my $obj = $c->model('ValidateForgotPasswordInfo');
			my $validation_result = $obj->_validate_reset_token($email_address, $reset_token);
			my $err_msg;

			if($validation_result eq $VALID_CONST)
			{

				my $user_id = $obj->_get_user_id_by_email($email_address);

				if($user_id != $NO_USER_ID)
				{

					if($c->authenticate({token=>$reset_token, user_id=>$user_id},"tokens"))
					{

						$c->session->{csrf_token} = Session::Token->new(length => 128)->get;

						$c->response->redirect($c->uri_for($self->action_for('update_user_password'), $reset_token, $email_address));

					}
					else
					{

						$err_msg = $c->loc($ERROR_BASE_STRING.$INVALID_TOKEN_OR_EMAIL);
						$c->stash(error_id => $INVALID_TOKEN_OR_EMAIL, error_code => $err_msg);

					}

				}
				else
				{

					$err_msg = $c->loc($ERROR_BASE_STRING.$INVALID_USER_ID);
					$c->stash(error_id => $INVALID_USER_ID, error_code => $err_msg);

				}

			}
			else
			{

				$err_msg = $c->loc($ERROR_BASE_STRING.$validation_result);
				$c->stash(error_id => $validation_result, error_code => $err_msg);

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

sub update_user_password :Local
{

	my ( $self, $c, $reset_token, $email_address ) = @_;

	if($c->stash->{'login_allow'} eq "true")
	{

		my $account_services_email_address = $c->config->{account_services_email};

		if(defined $reset_token && defined $email_address)
		{

			my $msg;
			my $obj;

			my $curr_lang = $c->session->{lang};
			my $lh = NGSTAR::I18N::i_default->new;

			if($c->session->{lang})
			{
				if($c->session->{lang} eq $TRANSLATION_LANG)
				{
					$lh = NGSTAR::I18N::fr->new;
				}
			}

			my $form = NGSTAR::Form::UpdatePasswordForm->new(language_handle => $lh, ctx => $c);

			$form->process(update_field_list => {
				csrf => {default => $c->session->{csrf_token} },
			});

			$c->stash(template => 'account/UpdatePassword.tt2', form => $form, page_title => $CHANGE_PASSWORD_PAGE_TITLE);

			$form->process(params => $c->request->params);
			return unless $form->validated;

			my $new_password = $c->request->params->{new_password};
			my $confirm_new_password = $c->request->params->{confirm_new_password};
			my $csrf_form_submitted = $c->request->params->{csrf};
			my $err_msg;

			if($new_password =~ /^(?=.{6,20}$)(?=.*?[A-Z])(?=.*?[a-z])(?=.*?\d)(?=.*[\.\-_!])(?!.*\s+)/
				and $confirm_new_password =~ /^(?=.{6,20}$)(?=.*?[A-Z])(?=.*?[a-z])(?=.*?\d)(?=.*[\.\-_!])(?!.*\s+)/)
			{

				if($new_password eq $confirm_new_password)
				{

					if($csrf_form_submitted and $csrf_form_submitted eq $c->session->{csrf_token})
					{

						$obj = $c->model('GetUserInfo');

						my $user_id = $obj->_get_user_id_by_email($email_address);

						my $username = $obj->_get_current_username_by_user_id($user_id);

						my $password_exists = $obj->_check_password_history($new_password, $username);

						#checks if password is the current password and if it is,
						#it asks the user to choose a different password
						if ($password_exists)
						{

							$err_msg = $c->loc($ERROR_BASE_STRING.$ERROR_SAME_PASSWORD);
							$c->stash(error_id => $ERROR_SAME_PASSWORD, error_code => $err_msg);

						}
						else
						{

							$c->session->{csrf_token} = Session::Token->new(length => 128)->get;

							$obj = $c->model('UpdateUserInformation');

							my $result = $obj->_update_password($new_password, $email_address);

							if($result)
							{

								$c->model('Email')->send(
								from => $account_services_email_address,
								to => $email_address,
								subject => $c->loc('shared.password.updated.email.subj'),
								plaintext => $c->loc('shared.password.updated.email.body')
								);

								$msg = $PASSWORD_SUCCESSFULLY_UPDATED;
								$c->res->redirect($c->uri_for($c->controller('Login')->action_for('index'), $msg));

							}
							else
							{
								$err_msg = $c->loc($ERROR_BASE_STRING.$ERROR_PASSWORD_UPDATE_UNSUCCESSFUL);
								$c->stash(error_id => $ERROR_PASSWORD_UPDATE_UNSUCCESSFUL, error_code => $err_msg);


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

					$err_msg = $c->loc($ERROR_BASE_STRING.$ERROR_PASSWORDS_DO_NOT_MATCH);
					$c->stash(error_id => $ERROR_PASSWORDS_DO_NOT_MATCH, error_code => $err_msg);

				}

			}
			else
			{

				$err_msg = $c->loc($ERROR_BASE_STRING.$ERROR_PASSWORD_FORMAT);
				$c->stash(error_id => $ERROR_PASSWORD_FORMAT, error_code => $err_msg);

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
