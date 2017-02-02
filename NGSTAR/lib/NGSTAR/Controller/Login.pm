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

package NGSTAR::Controller::Login;
use Moose;
use namespace::autoclean;
use NGSTAR::Form::SignInForm;

use Catalyst qw( ConfigLoader );


BEGIN { extends 'Catalyst::Controller'; }

use Session::Token;
use Readonly;
=head1 NAME

NGSTAR::Controller::Login - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index
	Args() required as subroutine works with or without an error_msg argument
=cut

Readonly my $AUTH_SUCCESS => "AUTH_SUCCESS";
Readonly my $AUTH_ERROR => "AUTH_ERROR";
Readonly my $INACTIVE_ERROR => "INACTIVE_ERROR";

Readonly my $ACCOUNT_LOCKED_ERROR => "ACCOUNT_LOCKED_ERROR";


Readonly my $TRANSLATION_LANG => "fr";
Readonly my $DEFAULT_LANG => "en";

Readonly my $SIGN_IN_PAGE_TITLE => "shared.signin.text";
Readonly my $ERROR_404_PAGE_TITLE => "shared.404.page.not.found.text";

Readonly my $FALSE => 0;
Readonly my $TRUE => 1;

sub begin : Private
{

	my ( $self, $c ) = @_;

	if($c->request->referer and (index($c->request->referer, NGSTAR->config->{ngstar_base_url}) == -1))
	{

		$c->res->redirect($c->uri_for($c->controller('Welcome')->action_for('home')));

	}
	else
	{

		my @path_tokens;

		if($c->request->referer)
		{
			@path_tokens = split("/",$c->request->referer);
		}

		my $login_token_count = 0;

		foreach my $token ( @path_tokens )
		{
			if($token eq "login")
			{
				$login_token_count = $login_token_count + 1;
			}
		}

		if($login_token_count == 0)
		{
			$c->session->{referer} = $c->request->referer;
		}


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

sub index :Path :Args()
{

	my ( $self, $c, $error_msg ) = @_;

	$c->log->debug('*** INSIDE LOGIN index METHOD ***');


	if($c->stash->{'login_allow'} eq "true")
	{

		my $msg = $AUTH_SUCCESS;

		my $curr_lang = $c->session->{lang};
		my $lh = NGSTAR::I18N::i_default->new;

		if($c->session->{lang})
		{
			if($c->session->{lang} eq $TRANSLATION_LANG)
			{
				$lh = NGSTAR::I18N::fr->new;
			}
		}
		my $form = NGSTAR::Form::SignInForm->new(language_handle => $lh,ctx => $c);

		$form->process(update_field_list => {
			username => {messages => {required => $c->loc('shared.enter.user.identifier.msg')}},
			password => {messages => {required => $c->loc('shared.enter.password.msg')}},
			csrf => {default => $c->session->{csrf_token} },
		});

		$c->stash(template => 'login/SignIn.tt2', form => $form, error_msg => $error_msg, page_title => $SIGN_IN_PAGE_TITLE);

		$form->process(params => $c->request->params);
		return unless $form->validated;


		my $username = $c->request->params->{username};
		my $password = $c->request->params->{password};
		my $csrf_form_submitted = $c->request->params->{csrf};

		if($csrf_form_submitted and $csrf_form_submitted eq $c->session->{csrf_token})
		{

			my $obj;
			my $result;

			$obj = $c->model('GetUserInfo');
			my $username_exists = $obj->_check_username_exists($username);
			my $email_exists = $obj->_check_email_exists($username);


			if($username_exists or $email_exists)
			{

				$obj = $c->model('AccountLockout');

				if ($c->authenticate(
					{
						password => $password,
						'dbix_class' =>
							{	#will look for a username/password match or a email/password match
								searchargs =>
								[
									{ -or => [ username => $username,
											   email_address => $username],
									  -and => [active => 1,
												 lockout_status => 0]

									}
								]
							}
					}))
				{

					$obj = $c->model('GetUserInfo');
					my $password_is_expired = $obj->_check_password_expiry($username);

					$obj = $c->model('AccountLockout');

					#reset lockout info: failed attempt count, first failed attempt timestamp, lockout status, lockout timestamp
					#reset lockout info if x amount of time has passed since lockout
					#or
					#reset lockout info if min time to lockout user has been reached and user doesn't have lockout status (hasn't reached x amount of tries in y amount of time)
					$c->session->{csrf_token} = Session::Token->new(length => 128)->get;

					$obj->_reset_user_lockout_info($username);

					if($password_is_expired)
					{
						$c->session->{password_is_expired} = 1;
						$c->res->redirect($c->uri_for($c->controller('Account')->action_for('change_account_password')));
						$c->detach();
					}
					elsif($c->session->{referer})
					{
						$c->res->redirect($c->session->{referer});
						$c->detach();
					}
					else
					{
						$c->res->redirect($c->uri_for($c->controller('Allele')->action_for('form')));
						$c->detach();
					}

				}
				elsif($obj->_check_account_unlock($username) == $TRUE and ($c->authenticate(
					{
						password => $password,
						'dbix_class' =>
							{	#will look for a username/password match or a email/password match
								searchargs =>
								[
									{ -or => [ username => $username,
											   email_address => $username],
									  -and => [active => 1,
												  lockout_status => 1]

									}
								]
							}
					})))
				{

					$obj = $c->model('GetUserInfo');
					my $password_is_expired = $obj->_check_password_expiry($username);

					$obj = $c->model('AccountLockout');

					$c->session->{csrf_token} = Session::Token->new(length => 128)->get;

					$result =  $obj->_reset_user_lockout_info($username);

					if($result == $TRUE)
					{

						if($password_is_expired)
						{
							$c->session->{password_is_expired} = 1;
							$c->res->redirect($c->uri_for($c->controller('Account')->action_for('change_account_password')));
							$c->detach();
						}
						elsif($c->session->{referer})
						{
							$c->res->redirect($c->session->{referer});
							$c->detach();
						}
						else
						{
							$c->res->redirect($c->uri_for($c->controller('Allele')->action_for('form')));
							$c->detach();
						}

					}

				}
				else
				{

					$msg = $AUTH_ERROR; #default error (invalid credentials)

					my $min_time_reached = $obj->_check_user_first_failed_attempt_timestamp($username);

					#reset lockout info: failed attempt count, first failed attempt timestamp, lockout status, lockout timestamp
					#reset lockout info if x amount of time has passed since lockout
					#or
					#reset lockout info if min time to lockout user has been reached and user doesn't have lockout status (hasn't reached x amount of tries in y amount of time)

					if(($obj->_check_account_unlock($username) == $TRUE) or ($min_time_reached and $obj->_check_lockout_status($username) == $FALSE))
					{

						$obj->_reset_user_lockout_info($username);

					}

					$result =  $obj->_increment_failed_attempts($username);

					if($result)
					{

						my $max_attempts_reached = $obj->_check_user_failed_attempts($username);

						if(($max_attempts_reached and $min_time_reached) or ($max_attempts_reached))
						{

							$msg = $ACCOUNT_LOCKED_ERROR; #account locked error

						}

						$c->response->redirect($c->uri_for($self->action_for('index'), $msg));

					}
					else
					{

						$msg = $ACCOUNT_LOCKED_ERROR; #account locked error

						$c->response->redirect($c->uri_for($self->action_for('index'), $msg));

					}

				}

			}
			else
			{

				$msg = $AUTH_ERROR; #default error (invalid credentials)

				$c->response->redirect($c->uri_for($self->action_for('index'), $msg));

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

Irish Medina

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
