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

package NGSTAR::Controller::Admin;
use Moose;
use namespace::autoclean;
use NGSTAR::Form::CreateAccountForm;
use NGSTAR::Form::EditAccountForm;

use Catalyst qw( ConfigLoader );
use Session::Token;
use DateTime;

BEGIN { extends 'Catalyst::Controller'; }
use Readonly;
=head1 NAME

NGSTAR::Controller::Admin - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index

=cut

Readonly my $TRANSLATION_LANG => "fr";
Readonly my $DEFAULT_LANG => "en";

Readonly my $FALSE => 0;
Readonly my $TRUE => 1;

Readonly my $INVALID_CONST => "IS_INVALID";
Readonly my $VALID_CONST => "IS_VALID";

Readonly my $NOTIFICATION_OFF => 0;
Readonly my $NOTIFICATION_ON => 1;

Readonly my $ERROR_NO_USERS => 4026;


Readonly my $ADMIN_TOOLS_PAGE_TITLE => "browser.title.admin.tools";
Readonly my $USER_ACCTS_PAGE_TITLE => "shared.manage.user.accounts.text";
Readonly my $CREATE_ACCT_PAGE_TITLE => "browser.title.create.user";
Readonly my $EDIT_ACCT_PAGE_TITLE => "shared.edit.user.account.text";

Readonly my $ERROR_404_PAGE_TITLE => "shared.404.page.not.found.text";
Readonly my $ERROR_LOGIN_REQ_PAGE_TITLE => "shared.access.denied.text

";
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

				if($c->session->{password_is_expired} and $c->session->{password_is_expired} == 1)
				{
					$c->res->redirect($c->uri_for($c->controller('Account')->action_for('change_account_password')));
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

		if($c->user_exists() and $c->check_any_user_role('admin'))
		{

			$c->stash(template => 'admin/SettingsMenu.tt2', page_title => $ADMIN_TOOLS_PAGE_TITLE);

		}
		else
		{

			$c->stash(template => 'error/access_denied_admin.tt2', page_title => $ERROR_LOGIN_REQ_PAGE_TITLE);

		}
	}
	else
	{

		$c->stash(template => 'error/error_404.tt2', page_title => $ERROR_404_PAGE_TITLE);

	}

}

sub create_account :Local
{

	my ($self, $c) = @_;

	if($c->stash->{'login_allow'} eq "true")
	{
		if($c->user_exists() and $c->check_any_user_role('admin'))
		{

			my $result;

			my $curr_lang = $c->session->{lang};
			my $lh = NGSTAR::I18N::i_default->new;

			if($c->session->{lang})
			{

				if($c->session->{lang} eq $TRANSLATION_LANG)
				{
					 $lh = NGSTAR::I18N::fr->new;
				}

			}

			 my $form = NGSTAR::Form::CreateAccountForm->new(
				 language_handle => $lh,
				 field_list => [
						 'role' => {
							 do_label => 1,
							 type => 'Select',
							 label => 'shared.account.access.level.text',
							 label_class => 'col-sm-2',
							 element_wrapper_class => 'col-sm-10',
							 required => 1,
							 options => [{value => 'none', label => $c->loc('shared.none.text')},
										 {value => 'admin', label => $c->loc('shared.admin.text')},
										 {value => 'user', label => $c->loc('shared.curator.text') }],
							 element_attr => { class => 'input-full' },
							 default => 'none'
						 },
					 ],
				 ctx => $c,
			);

			$form->process(update_field_list => {
				first_name => {messages => {required => $c->loc('shared.enter.first.name.msg')}},
				last_name => {messages => {required => $c->loc('shared.enter.last.name.msg')}},
				ins_name => {messages => {required => $c->loc('shared.enter.ins.name.msg')}},
				ins_city => {messages => {required => $c->loc('shared.enter.ins.city.msg')}},
				ins_country => {messages => {required => $c->loc('shared.enter.ins.country.msg')}},
				username => {messages => {required => $c->loc('shared.enter.username.msg')}},
				email_address => {messages => {required => $c->loc('shared.enter.email.address.msg')}},
				password_new_user => {messages => {required => $c->loc('shared.enter.password.msg')}},
				validate_password => {messages => {required => $c->loc('shared.enter.password.msg')}},
				csrf => {default => $c->session->{csrf_token} },
			 });

			 $c->stash(template => 'admin/CreateAccountForm.tt2', form => $form, page_title => $CREATE_ACCT_PAGE_TITLE);

			 $form->process(params => $c->request->params);
			 return unless $form->validated;

			 my $fname = $c->request->params->{first_name};
			 my $lname = $c->request->params->{last_name};
			 my $ins_name = $c->request->params->{ins_name};
			 my $ins_city = $c->request->params->{ins_city};
			 my $ins_country = $c->request->params->{ins_country};


			 my $username = $c->request->params->{username};
			 my $password = $c->request->params->{password_new_user};
			 my $email_address = $c->request->params->{email_address};
			 my $confirm_password = $c->request->params->{validate_password};
			 my $role = $c->request->params->{role};
			 my $csrf_form_submitted = $c->request->params->{csrf};

			 if($csrf_form_submitted and $csrf_form_submitted eq $c->session->{csrf_token})
			 {

				my $time_stamp = DateTime->new(
					year       => 1900,
					month      => 01,
					day        => 01,
					hour       => 00,
					minute     => 00,
					second     => 00,
				);


				 my $obj = $c->model('AddNewUser');
				 my $validation_result = $obj->_insert_new_user($fname,$lname,$ins_name,$ins_city,$ins_country,$username,$password,$email_address,$confirm_password, $role, $time_stamp);

				 if($validation_result eq $VALID_CONST)
				 {
					 $c->session->{csrf_token} = Session::Token->new(length => 128)->get;

					 $c->flash(account_created_notification => $NOTIFICATION_ON, username => $username);
					 $c->response->redirect($c->uri_for($self->action_for('view_users')));

				 }
				 else
				 {

					 $result = $validation_result;

					 my $err_msg = $c->loc($ERROR_BASE_STRING.$result);
					 $c->stash(error_id => $result, error_code => $err_msg);

				 }

			 }
			 else
			 {

				 $c->response->redirect($c->uri_for($self->action_for('create_account')));

			 }

		}
		else
		{

			$c->stash(template => 'error/access_denied_admin.tt2', page_title => $ERROR_LOGIN_REQ_PAGE_TITLE);

		}

	}
	else
	{

		$c->stash(template => 'error/error_404.tt2', page_title => $ERROR_404_PAGE_TITLE);

	}

}


sub delete_user :Local
{

	my ($self, $c, $username) = @_;

	if($c->stash->{'login_allow'} eq "true")
	{

		if($c->user_exists() and $c->check_any_user_role('admin'))
		{
			my $obj = $c->model('UpdateUserInformation');
			my $user_id = $c->user->get('id');
			my $result = $obj->_delete_account($username, $user_id);

			my $err_msg;

			if($result != $TRUE)
			{

				$err_msg = $c->loc($ERROR_BASE_STRING.$result);

				$c->flash(error_id => $result, error_code => $err_msg);
				$c->response->redirect($c->uri_for($self->action_for('view_users')));

			}
			else
			{

				$c->flash(acct_deleted_notification=> $NOTIFICATION_ON, user => $username);
				$c->response->redirect($c->uri_for($self->action_for('view_users')));

			}
		}
		else
		{

			$c->stash(template => 'error/access_denied_admin.tt2', page_title => $ERROR_LOGIN_REQ_PAGE_TITLE);

		}

	}
	else
	{

		$c->stash(template => 'error/error_404.tt2', page_title => $ERROR_404_PAGE_TITLE);

	}

}

sub deactivate_user :Local
{

	my ($self, $c, $username) = @_;

	if($c->stash->{'login_allow'} eq "true")
	{

		if($c->user_exists() and $c->check_any_user_role('admin'))
		{

			my $obj = $c->model('UpdateUserInformation');
			my $user_id = $c->user->get('id');
			my $result = $obj->_deactivate_account($username, $user_id);
			my $err_msg;

			if($result != $TRUE)
			{

				$err_msg = $c->loc($ERROR_BASE_STRING.$result);

				$c->flash(error_id => $result, error_code => $err_msg);
				$c->response->redirect($c->uri_for($self->action_for('view_users')));

			}
			else
			{

				$c->flash(acct_deactivated_notification=> $NOTIFICATION_ON, user => $username);
				$c->response->redirect($c->uri_for($self->action_for('view_users')));

			}

		}
		else
		{

			$c->stash(template => 'error/access_denied_admin.tt2', page_title => $ERROR_LOGIN_REQ_PAGE_TITLE);

		}

	}
	else
	{

		$c->stash(template => 'error/error_404.tt2', page_title => $ERROR_404_PAGE_TITLE);

	}

}

sub edit_user :Local
{

	my ($self, $c, $username) = @_;

	if($c->stash->{'login_allow'} eq "true")
	{

		if($c->user_exists() and $c->check_any_user_role('admin'))
		{

			my $obj = $c->model('GetUserInfo');
			my $result = $obj->_get_user_details_by_username($username);
			my $err_msg;

			if(@$result)
			{

				my $current_email_address = $result->[0]->{email_address};

				my $role = $obj->_get_user_role($username);

				my $acct_status = $result->[0]->{active};

				if($acct_status == 0)
				{
					$acct_status = $c->loc('inactive.text');
				}
				else
				{
					$acct_status = $c->loc('active.text');
				}

				my $curr_lang = $c->session->{lang};
				my $lh = NGSTAR::I18N::i_default->new;

				if($c->session->{lang})
				{

					if($c->session->{lang} eq $TRANSLATION_LANG)
					{
						$lh = NGSTAR::I18N::fr->new;
					}

				}


				my $form = NGSTAR::Form::EditAccountForm->new(
					language_handle => $lh,
					field_list => [
						'username' => {
							do_label => 1,
							type => 'Text',
							label => 'shared.account.username.text',
							label_class => 'col-sm-2',
							element_wrapper_class => 'col-sm-10',
							default => $username,
							element_attr => { class => 'input-full' },
							disabled => 1,
						},
						'role' => {
							do_label => 1,
							type => 'Select',
							label => 'shared.account.access.level.text',
							label_class => 'col-sm-2',
							element_wrapper_class => 'col-sm-10',
							required => 1,
							options => [{value => '0', label => $c->loc('shared.none.text')},
										{value => '2', label => $c->loc('shared.admin.text')},
										{value => '1', label => $c->loc('shared.curator.text')}],
							element_attr => { class => 'input-full' },
							default => $role
						},
						'email_address' => {
							do_label => 1,
							type => 'Text',
							label => 'shared.account.email.text',
							label_class => 'col-sm-2',
							element_wrapper_class => 'col-sm-10',
							required => 1,
							element_attr => { class => 'input-full' },
							default => $result->[0]->{email_address}
						},
						'first_name' => {
							do_label => 1,
							type => 'Text',
							label => 'shared.account.first.name.text',
							label_class => 'col-sm-2',
							element_wrapper_class => 'col-sm-10',
							required => 1,
							maxlength => 20,
							default => $result->[0]->{first_name},
						},
						'last_name' => {
							do_label => 1,
							type => 'Text',
							label => 'shared.account.last.name.text',
							label_class => 'col-sm-2',
							element_wrapper_class => 'col-sm-10',
							required => 1,
							maxlength => 20,
							element_attr => { class => 'input-full' },
							default => $result->[0]->{last_name},
						},
						'ins_name' => {
							do_label => 1,
							type => 'Text',
							label => 'shared.account.ins.name.text',
							label_class => 'col-sm-2',
							element_wrapper_class => 'col-sm-10',
							required => 1,
							maxlength => 20,
							element_attr => { class => 'input-full' },
							default => $result->[0]->{institution_name},
						},
						'ins_city' => {
							do_label => 1,
							type => 'Text',
							label => 'shared.account.ins.city.text',
							label_class => 'col-sm-2',
							element_wrapper_class => 'col-sm-10',
							required => 1,
							maxlength => 20,
							element_attr => { class => 'input-full' },
							default => $result->[0]->{institution_city},
						},
						'ins_country' => {
							do_label => 1,
							type => 'Text',
							label => 'shared.account.ins.country.text',
							label_class => 'col-sm-2',
							element_wrapper_class => 'col-sm-10',
							element_attr => { class => 'input-full' },
							default => $result->[0]->{institution_country},
						},
						'is_active' => {
							do_label => 1,
							label => 'account.status.text',
							label_class => 'col-sm-2',
							element_wrapper_class => 'col-sm-10',
							element_attr => { class => 'input-full', readonly => 'readonly' },
							default => $acct_status,
							disabled => 1,
						},
					],
					ctx => $c,
				);

				$c->stash(template => 'admin/EditAccountForm.tt2', form => $form, page_title => $EDIT_ACCT_PAGE_TITLE);

				$form->process(update_field_list => {
					first_name => {messages => {required => $c->loc('shared.enter.first.name.msg')}},
					last_name => {messages => {required => $c->loc('shared.enter.last.name.msg')}},
					ins_name => {messages => {required => $c->loc('shared.enter.ins.name.msg')}},
					ins_city => {messages => {required => $c->loc('shared.enter.ins.city.msg')}},
					ins_country => {messages => {required => $c->loc('shared.enter.ins.country.msg')}},
					email_address => {messages => {required => $c->loc('shared.enter.email.address.msg')}},
					csrf => {default => $c->session->{csrf_token} },
				});

				$form->process(params => $c->request->params);
				return unless $form->validated;


				$role = $c->request->params->{role};
				my $email_address = $c->request->params->{email_address};
				my $first_name = $c->request->params->{first_name};
				my $last_name = $c->request->params->{last_name};

				my $ins_name = $c->request->params->{ins_name};
				my $ins_city = $c->request->params->{ins_city};
				my $ins_country = $c->request->params->{ins_country};
				my $csrf_form_submitted = $c->request->params->{csrf};

				if($csrf_form_submitted and $csrf_form_submitted eq $c->session->{csrf_token})
				{

					$obj = $c->model('GetUserInfo');
					my $user_id = $obj->_get_user_id_by_username($username);

					$obj = $c->model('ValidateEditUserAccount');
					$result =$obj->_validate_edited_user_details($first_name, $last_name, $email_address, $ins_name, $ins_city, $ins_country);

					if($result == $TRUE)
					{

						$obj = $c->model('UpdateUserInformation');
						$result = $obj->_admin_update_user($role, $current_email_address, $email_address,$user_id, $first_name, $last_name, $ins_name, $ins_city, $ins_country);

						if($result == $TRUE)
						{

							$c->session->{csrf_token} = Session::Token->new(length => 128)->get;

							$c->flash(successfully_updated_notification => $NOTIFICATION_ON, user => $username);
							$c->response->redirect($c->uri_for($self->action_for('view_users')));

						}
						else
						{

							$err_msg = $c->loc($ERROR_BASE_STRING.$result);

							$c->stash(error_id => $result, error_code => $err_msg);

						}
					}
					else
					{

						$err_msg = $c->loc($ERROR_BASE_STRING.$result);
						$c->stash(error_id => $result, error_code => $err_msg);

					}

				}
				else
				{

					$c->response->redirect($c->uri_for($self->action_for('edit_user'), $username));

				}

			}
			else
			{

				$err_msg = $c->loc($ERROR_BASE_STRING.$result);

				$c->stash(error_id => $result, error_code => $err_msg);

			}
		}
		else
		{

			$c->stash(template => 'error/access_denied_admin.tt2', page_title => $ERROR_LOGIN_REQ_PAGE_TITLE);

		}

	}
	else
	{

		$c->stash(template => 'error/error_404.tt2', page_title => $ERROR_404_PAGE_TITLE);

	}

}

sub reactivate_user :Local
{

	my ($self, $c, $username) = @_;

	if($c->stash->{'login_allow'} eq "true")
	{

		if($c->user_exists() and $c->check_any_user_role('admin'))
		{

			my $obj = $c->model('UpdateUserInformation');
			my $user_id = $c->user->get('id');
			my $result = $obj->_reactivate_account($username, $user_id);
			my $err_msg;

			if($result != $TRUE)
			{

				$err_msg = $c->loc($ERROR_BASE_STRING.$result);

				$c->flash(error_id => $result, error_code => $err_msg);
				$c->response->redirect($c->uri_for($self->action_for('view_users')));

			}
			else
			{

				$c->flash(acct_reactivated_notification=> $NOTIFICATION_ON, user => $username);
				$c->response->redirect($c->uri_for($self->action_for('view_users')));

			}

		}
		else
		{

			$c->stash(template => 'error/access_denied_admin.tt2', page_title => $ERROR_LOGIN_REQ_PAGE_TITLE);

		}

	}
	else
	{

		$c->stash(template => 'error/error_404.tt2', page_title => $ERROR_404_PAGE_TITLE);

	}

}

sub view_users :Local
{

	my ($self, $c) = @_;

	if($c->stash->{'login_allow'} eq "true")
	{

		if($c->user_exists() and $c->check_any_user_role('admin'))
		{

			my $obj = $c->model('GetUserInfo');
			my $user_list = $obj->_get_all_users();
			my $user_id = $c->user->get('id');

			if(defined $user_list)
			{
				$c->stash(template => 'admin/ViewUsers.tt2', userlist => $user_list, logged_on_user_id => $user_id, , page_title => $USER_ACCTS_PAGE_TITLE)
			}
			else
			{
				my $err_msg = $c->loc($ERROR_BASE_STRING.$ERROR_NO_USERS);
				$c->stash(error_id => $ERROR_NO_USERS, error_code => $err_msg);
			}

		}
		else
		{

			$c->stash(template => 'error/access_denied_admin.tt2', page_title => $ERROR_LOGIN_REQ_PAGE_TITLE);

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
