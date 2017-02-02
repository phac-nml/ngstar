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

package NGSTAR::Controller::Curator;
use Moose;
use namespace::autoclean;
use Readonly;

use NGSTAR::Form::CreateAminoAcidForm;
use NGSTAR::Form::EditAminoAcidForm;

use NGSTAR::Form::CreateAminoAcidProfileForm;
use NGSTAR::Form::EditAminoAcidProfileForm;

use Catalyst qw( ConfigLoader );

BEGIN { extends 'Catalyst::Controller'; }

use Session::Token;

=head1 NAME

NGSTAR::Controller::Curator - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index

=cut

Readonly my $MANAGE_AA_PROFILES_PAGE_TITLE => "shared.manage.amino.acid.profiles.text";
Readonly my $ADD_AA_PROFILE_PAGE_TITLE => "shared.add.amino.acid.profile.text";
Readonly my $EDIT_AA_PROFILE_PAGE_TITLE => "shared.edit.amino.acid.profile.text";
Readonly my $CURATOR_TOOLS_PAGE_TITLE => "curator.tools.text";
Readonly my $ERROR_404_PAGE_TITLE => "shared.404.page.not.found.text";
Readonly my $ERROR_LOGIN_REQ_PAGE_TITLE => "shared.access.denied.text";
Readonly my $MANAGE_AA_PAGE_TITLE => "shared.manage.amino.acids.text";
Readonly my $ADD_AA_PAGE_TITLE => "shared.add.amino.acid.text";
Readonly my $EDIT_AA_PAGE_TITLE => "shared.edit.amino.acid.text";


Readonly my $TRANSLATION_LANG => "fr";
Readonly my $FALSE => 0;
Readonly my $TRUE => 1;

Readonly my $NOTIFICATION_OFF => 0;
Readonly my $NOTIFICATION_ON => 1;

Readonly my $ONISHI_TYPE_LOCI_NAME => "penA";
Readonly my $DEFAULT_LANG => "en";


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

	$c->stash(template => 'error/error_404.tt2', page_title => $ERROR_404_PAGE_TITLE);

}

sub settings :Local
{

	my ($self, $c) = @_;
	$c->log->debug('*** INSIDE settings METHOD ***');

	if($c->stash->{'login_allow'} eq "true")
	{
		if($c->user_exists() and $c->check_any_user_role(qw/ user admin /))
		{
			$c->stash(template => 'curator/SettingsMenu.tt2', page_title => $CURATOR_TOOLS_PAGE_TITLE);
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

sub manage_amino_acids :Local
{
	my ($self, $c) = @_;

	if($c->stash->{'login_allow'} eq "true")
	{
		if($c->user_exists() and $c->check_any_user_role(qw/ user admin /))
		{

			my $obj = $c->model('ConvertSequences');
			my $aa_list =  $obj->_get_amino_acids($ONISHI_TYPE_LOCI_NAME);

			$c->stash(template => 'manage/ListAminoAcids.tt2', page_title => $MANAGE_AA_PAGE_TITLE, aa_list => $aa_list);
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

sub manage_amino_acid_profiles :Local
{
	my ($self, $c) = @_;

	if($c->stash->{'login_allow'} eq "true")
	{
		if($c->user_exists() and $c->check_any_user_role(qw/ user admin /))
		{

			my $obj = $c->model('ConvertSequences');
			my $onishi_seqs_list =  $obj->_get_onishi_seq_list($ONISHI_TYPE_LOCI_NAME);

			$c->stash(template => 'manage/ListAminoAcidProfiles.tt2', page_title => $MANAGE_AA_PROFILES_PAGE_TITLE, onishi_seq_list => $onishi_seqs_list);
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


sub add_amino_acid :Local
{
	my ($self, $c) = @_;

	if($c->stash->{'login_allow'} eq "true")
	{
		if($c->user_exists() and $c->check_any_user_role(qw/ user admin /))
		{

			my $lh = NGSTAR::I18N::i_default->new;
			my $obj;

			if($c->session->{lang})
			{
				if($c->session->{lang} eq $TRANSLATION_LANG)
				{
					$lh = NGSTAR::I18N::fr->new;
				}
			}

			my $form = NGSTAR::Form::CreateAminoAcidForm->new(language_handle => $lh);


			$c->stash(template => 'manage/CreateAminoAcid.tt2', form => $form, page_title => $ADD_AA_PAGE_TITLE);
			$form->process(params => $c->request->params);

			return unless $form->validated;

			my $position = $c->request->params->{position};
			my $amino_acid = $c->request->params->{amino_acid};

			$obj = $c->model('ValidateAminoAcid');
			my $validate_result = $obj->_validate_amino_acid($amino_acid, $position);

			if($validate_result == $TRUE)
			{
				$obj = $c->model('AddAminoAcid');
				$validate_result = $obj->_add_amino_acid($amino_acid, $position);

				if($validate_result)
				{
					$c->flash(add_aa_notification => $NOTIFICATION_ON, aa_char => $amino_acid, aa_pos => $position);
					$c->response->redirect($c->uri_for($self->action_for('manage_amino_acids')));
				}
				else
				{
					my $err_msg = $c->loc('adding.amino.acid.error.text');
					$c->stash(error_id => $validate_result, error_code => $err_msg);
				}
			}
			else
			{
				my $err_msg = $c->loc('validate.amino.acid.'.$validate_result);
				$c->stash(error_id => $validate_result, error_code => $err_msg);
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


sub add_amino_acid_profile :Local
{
	my ($self, $c, $aa_profile) = @_;

	if($c->stash->{'login_allow'} eq "true")
	{
		if($c->user_exists() and $c->check_any_user_role(qw/ user admin /))
		{
			my $obj = $c->model('ConvertSequences');

			my $lh = NGSTAR::I18N::i_default->new;

			if($c->session->{lang})
			{
				if($c->session->{lang} eq $TRANSLATION_LANG)
				{
					$lh = NGSTAR::I18N::fr->new;
				}
			}

			my $form = NGSTAR::Form::CreateAminoAcidProfileForm->new(
				language_handle => $lh,
				field_list => [
						'mosaic' => {
							do_label => 0,
							type => 'Select',
							required => 1,
							options => [{value => 'Yes', label => $c->loc('shared.yes.text')},
										{value => 'No', label => $c->loc('shared.no.text')},
										{value => 'Semi', label => $c->loc('shared.semi.text') }],
							empty_select => '---'.$c->loc('shared.select.text').'---' ,
						},
					],
			);

			$form->process(update_field_list => {
				onishi_type => {messages => {required => $c->loc('enter.amino.acid.profile.onishi.type.text')}},
				mosaic => {messages => {required => $c->loc('select.amino.acid.profile.mosaic.text')}},
				amino_acid_profile => {default => $aa_profile, messages => {required => $c->loc('enter.amino.acid.profile.text')}},
			});

			$c->stash(template => 'manage/CreateAminoAcidProfile.tt2', form => $form, page_title => $ADD_AA_PROFILE_PAGE_TITLE);
			$form->process(params => $c->request->params);

			return unless $form->validated;

			my $onishi_type = $c->request->params->{onishi_type};
			my $mosaic = $c->request->params->{mosaic};
			my $aa_pos = $c->request->params->{amino_acid_profile};

			$obj = $c->model('ValidateAminoAcid');
			my $validate_result = $obj->_validate_amino_acid_profile($onishi_type, $mosaic, $aa_pos);

			if($validate_result == $TRUE)
			{
				$obj = $c->model('AddAminoAcid');
				$validate_result = $obj->_add_amino_acid_profile($onishi_type, $mosaic, $aa_pos);

				if($validate_result)
				{
					$c->flash(add_aa_notification => $NOTIFICATION_ON, onishi_type => $onishi_type);
					$c->response->redirect($c->uri_for($self->action_for('manage_amino_acid_profiles')));
				}
				else
				{
					my $err_msg = $c->loc('adding.amino.acid.profile.error.text');
					$c->stash(error_id => $validate_result, error_code => $err_msg);
				}
			}
			else
			{
				my $err_msg = $c->loc('validate.amino.acid.profile.'.$validate_result);
				$c->stash(error_id => $validate_result, error_code => $err_msg);
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

sub delete_amino_acid_profile :Local
{
	my ($self, $c, $id) = @_;

	if($c->stash->{'login_allow'} eq "true")
	{
		if($c->user_exists() and $c->check_any_user_role(qw/ user admin /))
		{
			my $err_msg;

			if($id =~ /^[0-9]+$/)
			{
				my $obj = $c->model('DeleteAminoAcidProfile');
				my $validate_result = $obj->_delete_amino_acid_profile($id);

				if($validate_result)
				{
					$c->flash(delete_aa_notification => $NOTIFICATION_ON);
					$c->response->redirect($c->uri_for($self->action_for('manage_amino_acid_profiles')));
				}
				else
				{
					my $err_msg = $c->loc('deleting.amino.acid.profile.error.text');
					$c->stash(error_id => $validate_result, error_code => $err_msg);
				}
			}
			else
			{
				my $err_msg = $c->loc('deleting.amino.acid.profile.invalid.id.error.text');
				$c->stash(error_id => 0, error_code => $err_msg);
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


sub edit_amino_acid :Local
{
	my ($self, $c, $id) = @_;

	if($c->stash->{'login_allow'} eq "true")
	{
		if($c->user_exists() and $c->check_any_user_role(qw/ user admin /))
		{
			my $obj = $c->model('ConvertSequences');

			my $lh = NGSTAR::I18N::i_default->new;

			if($c->session->{lang})
			{
				if($c->session->{lang} eq $TRANSLATION_LANG)
				{
					$lh = NGSTAR::I18N::fr->new;
				}
			}

			my $amino_acid = $obj->_get_amino_acid_by_id($id);

			if($amino_acid != $FALSE)
			{

				my $form = NGSTAR::Form::EditAminoAcidForm->new(language_handle => $lh);

				$c->stash(template => 'manage/EditAminoAcid.tt2', form => $form, page_title => $EDIT_AA_PAGE_TITLE, aa_db_id => $amino_acid->[0]->{id});

				my $position_old = $amino_acid->[0]->{aa_pos};
				my $aa_old = $amino_acid->[0]->{aa_char};

				$form->process(update_field_list => {
					position => {default => $position_old},
					amino_acid => {default => $aa_old},
				});

				$form->process(params => $c->request->params);
				return unless $form->validated;

				my $position_new = $c->request->params->{position};
				my $aa_new = $c->request->params->{amino_acid};

				$obj = $c->model('ValidateAminoAcid');

				my $validate_result = $obj->_validate_amino_acid($aa_new, $position_new, $aa_old, $position_old,$amino_acid->[0]->{id});

				if($validate_result == $TRUE)
				{

					$obj = $c->model('EditAminoAcid');
					$validate_result = $obj->_edit_amino_acid($amino_acid->[0]->{id}, $aa_new, $position_new);

					if($validate_result)
					{
						$c->flash(edit_aa_notification => $NOTIFICATION_ON, aa_char => $aa_new, aa_pos => $position_new);
						$c->response->redirect($c->uri_for($self->action_for('manage_amino_acids')));
					}
					else
					{
						my $err_msg = $c->loc('editing.amino.acid.error.text');
						$c->stash(error_id => $validate_result, error_code => $err_msg);
					}

				}
				else
				{
					my $err_msg = $c->loc('validate.amino.acid.'.$validate_result);
					$c->stash(error_id => $validate_result, error_code => $err_msg);
				}

			}
			else
			{
				$c->flash(id_not_found => $NOTIFICATION_ON, id => $id);
				$c->response->redirect($c->uri_for($self->action_for('manage_amino_acids')));
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

sub delete_amino_acid :Local
{
	my ($self, $c, $id) = @_;

	if($c->stash->{'login_allow'} eq "true")
	{
		if($c->user_exists() and $c->check_any_user_role(qw/ user admin /))
		{
			my $err_msg;

			if($id =~ /^[0-9]+$/)
			{
				my $obj = $c->model('ConvertSequences');
				my $amino_acid = $obj->_get_amino_acid_by_id($id);

				$obj = $c->model('DeleteAminoAcid');
				my $validate_result = $obj->_delete_amino_acid($id);


				if($validate_result)
				{
					$c->flash(delete_aa_notification => $NOTIFICATION_ON, aa_char => $amino_acid->[0]->{aa_char}, aa_pos => $amino_acid->[0]->{aa_pos});
					$c->response->redirect($c->uri_for($self->action_for('manage_amino_acids')));
				}
				else
				{
					my $err_msg = $c->loc('deleting.amino.acid.error.text');
					$c->stash(error_id => $validate_result, error_code => $err_msg);
				}
			}
			else
			{
				my $err_msg = $c->loc('deleting.amino.acid.invalid.id.error.text');
				$c->stash(error_id => 0, error_code => $err_msg);
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

sub edit_amino_acid_profile :Local
{
	my ($self, $c, $id) = @_;

	if($c->stash->{'login_allow'} eq "true")
	{
		if($c->user_exists() and $c->check_any_user_role(qw/ user admin /))
		{
			my $obj = $c->model('ConvertSequences');

			my $lh = NGSTAR::I18N::i_default->new;

			if($c->session->{lang})
			{
				if($c->session->{lang} eq $TRANSLATION_LANG)
				{
					$lh = NGSTAR::I18N::fr->new;
				}
			}

			my $amino_acid = $obj->_get_onishi_seq_by_id($id);

			if($amino_acid != $FALSE)
			{
				my $form = NGSTAR::Form::EditAminoAcidProfileForm->new(
					language_handle => $lh,
					field_list => [
							'mosaic' => {
								do_label => 0,
								type => 'Select',
								required => 1,
								options => [{value => 'Yes', label => $c->loc('shared.yes.text')},
											{value => 'No', label => $c->loc('shared.no.text')},
											{value => 'Semi', label => $c->loc('shared.semi.text') }],
								empty_select => '---'.$c->loc('shared.select.text').'---' ,
							},
						],
				);

				$form->process(update_field_list => {
					onishi_type => {messages => {required => $c->loc('enter.amino.acid.profile.onishi.type.text')}},
					mosaic => {messages => {required => $c->loc('select.amino.acid.profile.mosaic.text')}},
					amino_acid_profile => {messages => {required => $c->loc('enter.amino.acid.profile.text')}},
				});

				$c->stash(template => 'manage/EditAminoAcidProfile.tt2', form => $form, page_title => $EDIT_AA_PROFILE_PAGE_TITLE, aa_profile_db_id => $amino_acid->[0]->{id});


				my $onishi_type_old = $amino_acid->[0]->{onishi_type};
				my $stored_mosaic_value = $amino_acid->[0]->{mosaic};
				my $aa_profile_old = $amino_acid->[0]->{aa_profile};

				$form->process(update_field_list => {
					onishi_type => {default => $onishi_type_old},
					mosaic => {default => $stored_mosaic_value},
					amino_acid_profile => {default => $aa_profile_old},
				});


				$form->process(params => $c->request->params);
				return unless $form->validated;


				my $onishi_type_new = $c->request->params->{onishi_type};
				my $mosaic = $c->request->params->{mosaic};
				my $aa_profile_new = $c->request->params->{amino_acid_profile};


				$obj = $c->model('ValidateAminoAcid');
				my $validate_result = $obj->_validate_amino_acid_profile($onishi_type_new, $mosaic, $aa_profile_new, $onishi_type_old, $aa_profile_old, $id);

				if($validate_result == $TRUE)
				{


					$obj = $c->model('EditAminoAcid');
					$validate_result = $obj->_edit_amino_acid_profile($id, $onishi_type_new, $mosaic, $aa_profile_new);

					if($validate_result)
					{
						$c->flash(edit_aa_notification => $NOTIFICATION_ON, onishi_type => $onishi_type_new);
						$c->response->redirect($c->uri_for($self->action_for('manage_amino_acid_profiles')));
					}
					else
					{
						my $err_msg = $c->loc('editing.amino.acid.profile.error.text');
						$c->stash(error_id => $validate_result, error_code => $err_msg);
					}

				}
				else
				{
					my $err_msg = $c->loc('validate.amino.acid.profile.'.$validate_result);
					$c->stash(error_id => $validate_result, error_code => $err_msg);
				}
			}
			else
			{
				$c->flash(id_not_found => $NOTIFICATION_ON, id => $id);
				$c->response->redirect($c->uri_for($self->action_for('manage_amino_acid_profiles')));
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
