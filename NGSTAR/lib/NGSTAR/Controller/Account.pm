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

package NGSTAR::Controller::Account;
use NGSTAR::Form::UpdateEmailForm;
use NGSTAR::Form::UpdatePasswordForm;
use NGSTAR::Form::UpdateUsernameForm;
use Moose;
use namespace::autoclean;

use Catalyst qw( ConfigLoader );
BEGIN { extends 'Catalyst::Controller'; }

use Session::Token;

=head1 NAME

NGSTAR::Controller::Account - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index

=cut

use Readonly;

Readonly my $TRANSLATION_LANG => "fr";
Readonly my $DEFAULT_LANG => "en";

Readonly my $PASSWORD_SUCCESSFULLY_UPDATED => "PASSWORD_SUCCESSFULLY_UPDATED";

Readonly my $USERNAME_SUCCESSFULLY_UPDATED => "USERNAME_SUCCESSFULLY_UPDATED";
Readonly my $EMAIL_SUCCESSFULLY_UPDATED => "EMAIL_SUCCESSFULLY_UPDATED";

Readonly my $INVALID_CONST => "IS_INVALID";
Readonly my $VALID_CONST => "IS_VALID";

Readonly my $ERROR_PASSWORDS_DO_NOT_MATCH => 4011;
Readonly my $ERROR_PASSWORD_UPDATE_UNSUCCESSFUL => 4012;
Readonly my $ERROR_CURRENT_USERNAME => 4013;
Readonly my $ERROR_CURRENT_EMAIL_ADDRESS => 4014;
Readonly my $ERROR_SAME_PASSWORD => 4015;
Readonly my $ERROR_USERNAMES_DO_NOT_MATCH => 4019;
Readonly my $ERROR_EMAILS_DO_NOT_MATCH => 4020;

Readonly my $ACCOUNT_SETTINGS_PAGE_TITLE => "shared.account.settings.text";
Readonly my $UPDATE_EMAIL_PAGE_TITLE => "browser.title.update.email";
Readonly my $UPDATE_PASSWORD_PAGE_TITLE => "browser.title.update.password";
Readonly my $UPDATE_USERNAME_PAGE_TITLE => "browser.title.update.username";

Readonly my $ERROR_404_PAGE_TITLE => "shared.404.page.not.found.text";
Readonly my $ERROR_LOGIN_REQ_PAGE_TITLE => "shared.access.denied.text";

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

sub settings :Local
{

	my ($self, $c) = @_;

	$c->log->debug('*** INSIDE settings METHOD ***');

	if($c->stash->{'login_allow'} eq "true")
	{

		if($c->session->{password_is_expired} and $c->session->{password_is_expired} == 1)
		{

			$c->res->redirect($c->uri_for($c->controller('Account')->action_for('change_account_password')));

		}
		else
		{

			#if a curator is signed in
			if($c->user_exists() and $c->check_any_user_role(qw/ user admin /))
			{
				$c->stash(template => 'account/AccountSettings.tt2', page_title => $ACCOUNT_SETTINGS_PAGE_TITLE);
			}
			else
			{

				$c->stash(template => 'error/access_denied_user.tt2', page_title => $ERROR_LOGIN_REQ_PAGE_TITLE);

			}

		}

	}
	else
	{

		$c->stash(template => 'error/error_404.tt2', page_title => $ERROR_404_PAGE_TITLE);

	}
}

sub change_account_email :Local
{

	my ($self, $c) = @_;

	$c->log->debug('*** INSIDE change_account_email METHOD ***');

	if($c->stash->{'login_allow'} eq "true")
	{

		if($c->session->{password_is_expired} and $c->session->{password_is_expired} == 1)
		{

			$c->res->redirect($c->uri_for($c->controller('Account')->action_for('change_account_password')));

		}
		elsif($c->user_exists() and $c->check_any_user_role(qw/ user admin /))
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


			my $form = NGSTAR::Form::UpdateEmailForm->new(language_handle => $lh, ctx => $c);

			$form->process(update_field_list => {
				new_email => {messages => {required => $c->loc('shared.enter.email.address.msg')}},
				confirm_new_email => {messages => {required => $c->loc('shared.enter.email.address.msg')}},
				csrf => {default => $c->session->{csrf_token} },
			});

			$c->stash(template => 'account/UpdateEmail.tt2', form => $form, page_title => $UPDATE_EMAIL_PAGE_TITLE);

			$form->process(params => $c->request->params);
			return unless $form->validated;

			my $user_id = $c->user->get('id');
			my $email_address = $c->request->params->{new_email};
			my $confirm_email_address = $c->request->params->{confirm_new_email};
			my $csrf_form_submitted = $c->request->params->{csrf};

			my $err_msg;
			my $obj;


			if($email_address eq $confirm_email_address)
			{
				if($csrf_form_submitted and $csrf_form_submitted eq $c->session->{csrf_token})
				{

					$obj = $c->model('GetUserInfo');
					my $curr_email_address = $obj->_get_current_email_address_by_user_id($user_id);

					if($curr_email_address eq $email_address)
					{

						$err_msg = $c->loc($ERROR_BASE_STRING.$ERROR_CURRENT_EMAIL_ADDRESS);
						$c->stash(error_id => $ERROR_CURRENT_EMAIL_ADDRESS, error_code => $err_msg);

					}
					else
					{

						$c->session->{csrf_token} = Session::Token->new(length => 128)->get;

						$obj = $c->model('UpdateUserInformation');
						my $result = $obj->_update_email_by_user_id($email_address, $user_id);

						if($result eq $VALID_CONST)
						{

							$c->stash(msg => $EMAIL_SUCCESSFULLY_UPDATED);

						}
						else
						{


							$err_msg = $c->loc($ERROR_BASE_STRING.$result);
							$c->stash(error_id => $result, error_code => $err_msg);

						}

					}

				}
				else
				{
					$c->response->redirect($c->uri_for($self->action_for('change_account_email')));
				}

			}
			else
			{

				$err_msg = $c->loc($ERROR_BASE_STRING.$ERROR_EMAILS_DO_NOT_MATCH);
				$c->stash(error_id => $ERROR_EMAILS_DO_NOT_MATCH, error_code => $err_msg);

			}
		}
		else
		{

			$c->stash(template => 'error/access_denied_user.tt2', page_title => $ERROR_LOGIN_REQ_PAGE_TITLE);

		}

	}
	else
	{

		$c->stash(template => 'error/error_404.tt2', page_title => $ERROR_404_PAGE_TITLE);

	}

}


sub change_account_password :Local
{

	my ($self, $c) = @_;

	$c->log->debug('*** INSIDE change_account_password METHOD ***');

	if($c->stash->{'login_allow'} eq "true")
	{

		if($c->user_exists() and $c->check_any_user_role(qw/ user admin /))
		{

			my $account_services_email_address = $c->config->{account_services_email};

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
				new_password => {messages => {required => $c->loc('shared.enter.password.msg')}},
				confirm_new_password => { messages => {required => $c->loc('shared.enter.password.msg')}},
				csrf => {default => $c->session->{csrf_token} },
			});

			$c->stash(template => 'account/UpdatePassword.tt2', form => $form, page_title => $UPDATE_PASSWORD_PAGE_TITLE);

			$form->process(params => $c->request->params);
			return unless $form->validated;

			my $user_id = $c->user->get('id');
			my $password = $c->request->params->{new_password};
			my $confirm_password = $c->request->params->{confirm_new_password};
			my $csrf_form_submitted = $c->request->params->{csrf};
			my $obj;
			my $err_msg;


			if($password eq $confirm_password)
			{

				if($csrf_form_submitted and $csrf_form_submitted eq $c->session->{csrf_token})
				{

					$obj = $c->model('GetUserInfo');
					my $username = $obj->_get_current_username_by_user_id($user_id);

					my $password_exists = $obj->_check_password_history($password, $username);

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
						my $result = $obj->_update_password($password, $user_id);

						if($result)
						{

							$c->session->{password_is_expired} = 0;

							my $user = $obj->_get_user_to_update_by_id($user_id);

							if(defined $user)
							{

								if($c->config->{account_services_email_enabled})
								{
									$c->model('Email')->send(
									from => $account_services_email_address,
									to => $user->email_address,
									subject => $c->loc('shared.password.updated.email.subj'),
									plaintext => $c->loc('shared.password.updated.email.body')
									);
								}
								$c->stash(msg => $PASSWORD_SUCCESSFULLY_UPDATED);
							}
							else
							{

								$err_msg = $c->loc($ERROR_BASE_STRING.$ERROR_PASSWORD_UPDATE_UNSUCCESSFUL);
								$c->stash(error_id => $ERROR_PASSWORD_UPDATE_UNSUCCESSFUL, error_code => $err_msg);

							}

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

					$c->response->redirect($c->uri_for($self->action_for('change_account_password')));

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

			$c->stash(template => 'error/access_denied_user.tt2', page_title => $ERROR_LOGIN_REQ_PAGE_TITLE);

		}

	}
	else
	{

		$c->stash(template => 'error/error_404.tt2', page_title => $ERROR_404_PAGE_TITLE);

	}

}

sub change_account_username :Local
{

	my ($self, $c) = @_;

	$c->log->debug('*** INSIDE change_account_username METHOD ***');

	if($c->stash->{'login_allow'} eq "true")
	{

		if($c->session->{password_is_expired} and $c->session->{password_is_expired} == 1)
		{

			$c->res->redirect($c->uri_for($c->controller('Account')->action_for('change_account_password')));

		}
		elsif($c->user_exists() and $c->check_any_user_role(qw/ user admin /))
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


			my $form = NGSTAR::Form::UpdateUsernameForm->new(language_handle => $lh, ctx => $c);

			$form->process(update_field_list => {
				new_username => {messages => {required => $c->loc('shared.enter.username.msg')}},
				confirm_new_username => {messages => {required => $c->loc('shared.enter.username.msg')}},
				csrf => {default => $c->session->{csrf_token} },

			});

			$c->stash(template => 'account/UpdateUsername.tt2', form => $form, page_title => $UPDATE_USERNAME_PAGE_TITLE);

			$form->process(params => $c->request->params);
			return unless $form->validated;

			my $user_id = $c->user->get('id');
			my $username = $c->request->params->{new_username};
			my $confirm_username = $c->request->params->{confirm_new_username};
			my $csrf_form_submitted = $c->request->params->{csrf};
			my $obj;
			my $err_msg;


			if($username eq $confirm_username)
			{

				if($csrf_form_submitted and $csrf_form_submitted eq $c->session->{csrf_token})
				{

					$c->session->{csrf_token} = Session::Token->new(length => 128)->get;

					$obj = $c->model('GetUserInfo');
					my $curr_username = $obj->_get_current_username_by_user_id($user_id);

					if($curr_username eq $username)
					{

						$err_msg = $c->loc($ERROR_BASE_STRING.$ERROR_CURRENT_USERNAME);
						$c->stash(error_id => $ERROR_CURRENT_USERNAME, error_code => $err_msg);

					}
					else
					{

						$obj = $c->model('UpdateUserInformation');
						my $result = $obj->_update_username_by_user_id($username, $user_id);

						if($result eq $VALID_CONST)
						{

							$c->stash(msg => $USERNAME_SUCCESSFULLY_UPDATED);

						}
						else
						{

							$err_msg = $c->loc($ERROR_BASE_STRING.$result);
							$c->stash(error_id => $result, error_code => $err_msg);

						}

					}

				}
				else
				{

					$c->response->redirect($c->uri_for($self->action_for('change_account_username')));

				}

			}
			else
			{

				$err_msg = $c->loc($ERROR_BASE_STRING.$ERROR_USERNAMES_DO_NOT_MATCH);
				$c->stash(error_id => $ERROR_USERNAMES_DO_NOT_MATCH, error_code => $err_msg);

			}
		}
		else
		{

			$c->stash(template => 'error/access_denied_user.tt2', page_title => $ERROR_LOGIN_REQ_PAGE_TITLE);

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
