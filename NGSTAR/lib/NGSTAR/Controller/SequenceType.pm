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

package NGSTAR::Controller::SequenceType;
use Moose;
use namespace::autoclean;
use NGSTAR::Form::AddProfileForm;
use NGSTAR::Form::EditProfileForm;
use NGSTAR::Form::SequenceTypeForm;
use NGSTAR::Form::BatchAddProfileForm;
use NGSTAR::Form::BatchAddProfileMetadataForm;
use NGSTAR::Form::BatchProfileQueryForm;
use NGSTAR::Form::EmailProfileForm;
use NGSTAR::Form::CuratorProfileQueryForm;

use Readonly;
use Data::Dumper;

use Data::Dumper;

use HTML::Entities;
use Text::Sprintf::Named qw(named_sprintf);
use Catalyst qw( ConfigLoader );

BEGIN { extends 'Catalyst::Controller'; }

use Session::Token;


=head1 NAME

NGSTAR::Controller::SequenceType - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index

=cut

Readonly my $NUM_SEQUENCES => 7;

Readonly my $TRANSLATION_LANG => "fr";
Readonly my $DEFAULT_LANG => "en";

#file sizes are in bytes
Readonly my $MAX_FILE_SIZE => 1048576;  #1 MB
Readonly my $MIN_FILE_SIZE => 0;

Readonly my $FORMAT_CODE_COMMA => "C";
Readonly my $FORMAT_CODE_TAB => "T";

Readonly my $NOTIFICATION_OFF => 0;
Readonly my $NOTIFICATION_ON => 1;

Readonly my $PROFILE_QUERY_AUTO => "PROFILE_QUERY_AUTO";
Readonly my $PROFILE_QUERY_MANUAL => "PROFILE_QUERY_MANUAL";

Readonly my $FALSE => 0;
Readonly my $TRUE => 1;

Readonly my $INVALID_CONST => "IS_INVALID";
Readonly my $VALID_CONST => "IS_VALID";

Readonly my $PATIENT_GENDER_FEMALE => 'F';
Readonly my $PATIENT_GENDER_MALE => 'M';
Readonly my $PATIENT_GENDER_UNKNOWN => 'U';


Readonly my $ERROR_NONEXISTANT_ALLELE => 1001;
Readonly my $ERROR_INVALID_LOCI_NAME => 1005;
Readonly my $ERROR_INVALID_ALLELE_TYPE => 1014;
Readonly my $ERROR_INVALID_ALLELE_SEQUENCE => 1017;
Readonly my $ERROR_CODE_NO_LOCIS => 1018;
Readonly my $ERROR_NO_ALLELES => 1015;

Readonly my $ERROR_NO_PROFILES => 2005;
Readonly my $ERROR_INVALID_SEQUENCE_TYPE => 2006;
Readonly my $ERROR_CODE_INVALID_PROFILE_FORMAT => 2007;
Readonly my $ERROR_CODE_INVALID_PROFILE_METADATA_FORMAT => 2008;
Readonly my $ERROR_CODE_NO_PROFILES_RETURNED => 2009;
Readonly my $ERROR_CODE_INVALID_SIZE => 2013;
Readonly my $ERROR_CODE_PROFILE_NO_DATA => 2014;
Readonly my $ERROR_CODE_INVALID_QUERY_OPTION => 2015;
Readonly my $ERROR_INVALID_CURATOR_PROFILE_INPUT_FORMAT => 2018;
Readonly my $ERROR_CODE_EMPTY_PROFILES => 2030;
Readonly my $ERROR_CODE_BATCH_PROFILE_QUERY_DATA => 2031;

Readonly my $ERROR_INVALID_ALLELE_TYPES => 3016;

Readonly my $ERROR_INVALID_TAB_INPUT_FORMAT => 5001;
Readonly my $ERROR_INVALID_FILENAME_FORMAT => 5002;
Readonly my $ERROR_INVALID_FILENAME => 5003;
Readonly my $ERROR_CODE_INVALID_OPTION => 5004;
Readonly my $ERROR_CODE_INVALID_DOWNLOAD_FORMAT => 5005;
Readonly my $ERROR_FILE_SIZE_TOO_LARGE => 5006;
Readonly my $ERROR_FILE_SIZE_TOO_SMALL => 5007;
Readonly my $ERROR_INVALID_INPUT_FORMAT => 5008;
Readonly my $ERROR_INVALID_TRACE_FILENAME => 5009;
Readonly my $ERROR_INVALID_CONTENT_TYPE => 5010;



Readonly my $OPTION_DELETE => "delete";
Readonly my $OPTION_DETAILS => "details";
Readonly my $OPTION_DOWNLOAD => "download";
Readonly my $OPTION_EDIT => "edit";
Readonly my $OPTION_VIEW => "view";
Readonly my $OPTION_COMMA_SEPARATED_TEXT => "Comma separated text";
Readonly my $OPTION_TAB_SEPARATED_TEXT => "Tab separated text";
Readonly my $OPTION_DOWNLOAD_PROFILE_METADATA => "download_profile_metadata";

Readonly my $MIC_COMPARATOR_EQUALS => "=";
Readonly my $MIC_COMPARATOR_LESS_THAN_OR_EQUALS => "le";
Readonly my $MIC_COMPARATOR_GREATER_THAN_OR_EQUALS => "ge";
Readonly my $MIC_COMPARATOR_LESS_THAN => "lt";
Readonly my $MIC_COMPARATOR_GREATER_THAN => "gt";

Readonly my $ERROR_BASE_STRING => "modal.confirm.error.";


Readonly my $ADD_ST_PAGE_TITLE => "shared.add.new.profile.text";
Readonly my $EDIT_ST_PAGE_TITLE => "shared.edit.profile.text";
Readonly my $EMAIL_ST_PAGE_TITLE => "shared.email.profile.text";

Readonly my $BATCH_ADD_ST_PAGE_TITLE => "browser.title.batch.add.profiles";
Readonly my $BATCH_ADD_ST_EX_PAGE_TITLE => "shared.batch.add.profiles.example.text";
Readonly my $BATCH_PROFILE_QUERY_PAGE_TITLE => "shared.batch.profile.query.text";
Readonly my $BATCH_PROFILE_QUERY_RESULTS_PAGE_TITLE => "shared.batch.profile.query.results.text";
Readonly my $BATCH_PROFILE_QUERY_EX_PAGE_TITLE => "shared.batch.profile.query.example.text";

Readonly my $BATCH_ADD_ST_METADATA_PAGE_TITLE => "browser.title.batch.add.profile.metadata";
Readonly my $BATCH_ADD_ST_METADATA_EX_PAGE_TITLE => "browser.title.batch.add.profile.metadata.example";

Readonly my $CURATOR_PROFILE_QUERY_PAGE_TITLE => "shared.curator.profile.query.text";

Readonly my $ST_DETAILS_PAGE_TITLE => "shared.ngstar.profile.details.text";
Readonly my $ST_QUERY_PAGE_TITLE => "shared.profile.query.text";
Readonly my $ST_QUERY_RESULT_PAGE_TITLE => "shared.profile.query.results.text";

Readonly my $ST_LIST_PAGE_TITLE => "shared.profile.list.text";

Readonly my $ERROR_404_PAGE_TITLE => "shared.404.page.not.found.text";
Readonly my $ERROR_LOGIN_REQ_PAGE_TITLE => "shared.access.denied.text";


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

sub check_mic
{

	my ($self) = @_;

	unless(($self->value =~ /^[0-9]+$/) or ($self->value =~ /^[0-9]*[\.]{1}[0-9]+$/))
	{

		$self->add_error('shared.mic.val.error.msg');

	}

}

sub show_popover
{
	my($self, $c, $classification_list) = @_;

	my $content = "<p>";
	my $title;
	my $name;

	foreach my $classification(@$classification_list)
	{
		$content .= "<strong>".$classification->{classification_code}."</strong> - ".$c->loc($classification->{classification_name})."<br>";
	}

	$content .= "</p>";

	return '&nbsp;<span id="popover-classifications" class="glyphicon glyphicon-info-sign"
				rel="popover"
				tabindex="0"
				data-placement="right"
				data-original-title=""
				data-html="true"
				data-content="'.$content.'"
			></span>';
}

#Need this function to set flash with allele type string which is needed in add_profile when
#curator is adding a profile via the profile query results page
sub add_profile_process :Local :Args()
{
	my ($self, $c) = @_;

	if($c->stash->{'login_allow'} eq "true")
	{

		if($c->user_exists() and $c->check_any_user_role(qw/ user admin /))
		{
			my $profile_allele_types = $c->request->params->{allele_type_str};
			$c->flash->{profile_allele_types} = $profile_allele_types;

			$c->response->redirect($c->uri_for($self->action_for('add_profile')));
		}
		else
		{
			$c->stash(template => 'error/access_denied_admin.tt2', page_title=>$ERROR_LOGIN_REQ_PAGE_TITLE);
		}

	}
	else
	{
		$c->stash(template => 'error/error_404.tt2', page_title=>$ERROR_404_PAGE_TITLE);
	}

}

sub add_profile :Local :Args()
{

	my ($self, $c) = @_;

	$c->log->debug('*** INSIDE add_profile_form_process METHOD ***');


	if($c->stash->{'login_allow'} eq "true")
	{

		if($c->user_exists() and $c->check_any_user_role(qw/ user admin /))
		{

			my $obj = $c->model('GetAlleleInfo');
			my $loci_name_list = $obj->_get_all_loci_names();

			$obj = $c->model('GetSequenceTypeInfo');
			my $last_ngstar_type = $obj->_get_last_ngstar_type();
			my $curr_ngstar_type;

			if($last_ngstar_type)
			{
				$curr_ngstar_type = $last_ngstar_type + 1 ;
			}
			else
			{
				$curr_ngstar_type = 1;
			}

			$obj = $c->model('GetMetadata');
			my $classification_list = $obj->_get_all_isolate_classifications();
			my $antimicrobial_name_list = $obj->_get_mic_antimicrobial_names();

			my $curr_lang = $c->session->{lang};
			my $lh = NGSTAR::I18N::i_default->new;

			if($c->session->{lang})
			{
				if($c->session->{lang} eq $TRANSLATION_LANG)
				{
					$lh = NGSTAR::I18N::fr->new;
				}
			}

			if(not $loci_name_list)
			{

				$c->stash(error_code => $loci_name_list);

			}
			elsif(not $classification_list)
			{

				$c->stash(error_code => $classification_list);

			}
			elsif(not $antimicrobial_name_list)
			{

				$c->stash(error_code => $antimicrobial_name_list);

			}
			else
			{
				my @classification_codes;

				foreach my $classification_in_list (@$classification_list)
				{
					push @classification_codes ,$classification_in_list->{classification_code};
				}
				my @classifications = map { $_, $_ } @classification_codes;

				my $ge = "&ge;";
				my $le = "&le;";
				my $gt = "&gt;";
				my $lt = "&lt;";

				my $ge_decoded = decode_entities($ge);
				my $le_decoded = decode_entities($le);
				my $gt_decoded = decode_entities($gt);
				my $lt_decoded = decode_entities($lt);

				my $form = NGSTAR::Form::AddProfileForm->new(
					language_handle => $lh,
					field_list => [
						'sequence_type' => {
							do_label => 1,
							type => 'Text',
							label => 'shared.profile.type.text',
							label_class => 'col-sm-2',
							element_wrapper_class => 'col-sm-10',
							required => 1,
							maxlength => 3,
							element_attr => { class => 'input-full', readonly => 'readonly' },
							default => $curr_ngstar_type
						},
						'patient_gender' => {
							do_label => 1,
							type => 'Select',
							label => 'shared.patient.gender.text',
							label_class => 'col-sm-2',
							element_wrapper_class => 'col-sm-10',
							required => 0,
							options => [{value => 'U', label => $c->loc('shared.unknown.text')},
										{value => 'F', label => $c->loc('shared.female.text')},
										{value => 'M', label => $c->loc('shared.male.text') }],
							default => 'U'
						},
						'beta_lactamase' => {
							do_label => 1,
							type => 'Select',
							label => 'shared.beta.lactamase.text',
							label_class => 'col-sm-2',
							element_wrapper_class => 'col-sm-10',
							required => 0,
							options => [{value => 'Unknown', label => $c->loc('shared.unknown.text')},
										{value => 'Positive', label => $c->loc('shared.positive.text')},
										{value => 'Negative', label => $c->loc('shared.negative.text') }],
							default => 'Unknown'
						},
						'isolate_classification' => {
							do_label => 1,
							type => 'Select',
							label => 'shared.isolate.classifications.text',
							tags => { label_after => $self->show_popover($c, $classification_list) },
							label_class => 'col-sm-2',
							element_wrapper_class => 'col-sm-10',
							required => 0,
							options => \@classifications,
							element_name => 'isolate_classification[]',
							multiple => 1,
						},
						$antimicrobial_name_list->[0].'_comparator_option' => {
							do_label => 1,
							type => 'Select',
							label => $antimicrobial_name_list->[0],
							tags => { label_after => " ".$c->loc('shared.mgl.text') },
							label_class => 'col-sm-2',
							element_wrapper_class => 'col-sm-10',
							required => 0,
							options => [{value => '=', label => '='},
										{value => 'lt', label => $lt_decoded},
										{value => 'gt', label => $gt_decoded},
										{value => 'le', label => $le_decoded},
										{value => 'ge', label => $ge_decoded}],
							default => '='
						},
						$antimicrobial_name_list->[1].'_comparator_option' => {
							do_label => 1,
							type => 'Select',
							label => $antimicrobial_name_list->[1],
							tags => { label_after => " ".$c->loc('shared.mgl.text') },
							label_class => 'col-sm-2',
							element_wrapper_class => 'col-sm-10',
							required => 0,
							options => [{value => '=', label => '='},
										{value => 'lt', label => $lt_decoded},
										{value => 'gt', label => $gt_decoded},
										{value => 'le', label => $le_decoded},
										{value => 'ge', label => $ge_decoded}],
							default => '='
						},
						$antimicrobial_name_list->[2].'_comparator_option' => {
							do_label => 1,
							type => 'Select',
							label => $antimicrobial_name_list->[2],
							tags => { label_after => " ".$c->loc('shared.mgl.text') },
							label_class => 'col-sm-2',
							element_wrapper_class => 'col-sm-10',
							required => 0,
							options => [{value => '=', label => '='},
										{value => 'lt', label => $lt_decoded},
										{value => 'gt', label => $gt_decoded},
										{value => 'le', label => $le_decoded},
										{value => 'ge', label => $ge_decoded}],
							default => '='
						},
						$antimicrobial_name_list->[3].'_comparator_option' => {
							do_label => 1,
							type => 'Select',
							label => $antimicrobial_name_list->[3],
							tags => { label_after => " ".$c->loc('shared.mgl.text') },
							label_class => 'col-sm-2',
							element_wrapper_class => 'col-sm-10',
							required => 0,
							options => [{value => '=', label => '='},
										{value => 'lt', label => $lt_decoded},
										{value => 'gt', label => $gt_decoded},
										{value => 'le', label => $le_decoded},
										{value => 'ge', label => $ge_decoded}],
							default => '='
						},
						$antimicrobial_name_list->[4].'_comparator_option' => {
							do_label => 1,
							type => 'Select',
							label => $antimicrobial_name_list->[4],
							tags => { label_after => " ".$c->loc('shared.mgl.text') },
							label_class => 'col-sm-2',
							element_wrapper_class => 'col-sm-10',
							required => 0,
							options => [{value => '=', label => '='},
										{value => 'lt', label => $lt_decoded},
										{value => 'gt', label => $gt_decoded},
										{value => 'le', label => $le_decoded},
										{value => 'ge', label => $ge_decoded}],
							default => '='
						},
						$antimicrobial_name_list->[5].'_comparator_option' => {
							do_label => 1,
							type => 'Select',
							label => $antimicrobial_name_list->[5],
							tags => { label_after => " ".$c->loc('shared.mgl.text') },
							label_class => 'col-sm-2',
							element_wrapper_class => 'col-sm-10',
							required => 0,
							options => [{value => '=', label => '='},
										{value => 'lt', label => $lt_decoded},
										{value => 'gt', label => $gt_decoded},
										{value => 'le', label => $le_decoded},
										{value => 'ge', label => $ge_decoded}],
							default => '='
						},
						$antimicrobial_name_list->[6].'_comparator_option' => {
							do_label => 1,
							type => 'Select',
							label => $antimicrobial_name_list->[6],
							tags => { label_after => " ".$c->loc('shared.mgl.text') },
							label_class => 'col-sm-2',
							element_wrapper_class => 'col-sm-10',
							required => 0,
							options => [{value => '=', label => '='},
										{value => 'lt', label => $lt_decoded},
										{value => 'gt', label => $gt_decoded},
										{value => 'le', label => $le_decoded},
										{value => 'ge', label => $ge_decoded}],
							default => '='
						},
						$antimicrobial_name_list->[7].'_comparator_option' => {
							do_label => 1,
							type => 'Select',
							label => $antimicrobial_name_list->[7],
							tags => { label_after => " ".$c->loc('shared.mgl.text') },
							label_class => 'col-sm-2',
							element_wrapper_class => 'col-sm-10',
							required => 0,
							options => [{value => '=', label => '='},
										{value => 'lt', label => $lt_decoded},
										{value => 'gt', label => $gt_decoded},
										{value => 'le', label => $le_decoded},
										{value => 'ge', label => $ge_decoded}],
							default => '='
						},
						$antimicrobial_name_list->[0] => {
							do_label => 0,
							type => 'Text',
							element_wrapper_class => 'col-sm-offset-2 col-sm-10',
							required => 0,
							minlength => 1,
							maxlength => 6,
							element_attr => { class=>'input-full' },
							validate_method => \&check_mic
						},
						$antimicrobial_name_list->[1] => {
							do_label => 0,
							type => 'Text',
							element_wrapper_class => 'col-sm-offset-2 col-sm-10',
							required => 0,
							minlength => 1,
							maxlength => 6,
							element_attr => { class=>'input-full' },
							validate_method => \&check_mic
						},
						$antimicrobial_name_list->[2] => {
							do_label => 0,
							type => 'Text',
							element_wrapper_class => 'col-sm-offset-2 col-sm-10',
							required => 0,
							minlength => 1,
							maxlength => 6,
							element_attr => { class=>'input-full' },
							validate_method => \&check_mic
						},
						$antimicrobial_name_list->[3] => {
							do_label => 0,
							type => 'Text',
							element_wrapper_class => 'col-sm-offset-2 col-sm-10',
							required => 0,
							minlength => 1,
							maxlength => 6,
							element_attr => { class=>'input-full' },
							validate_method => \&check_mic
						},
						$antimicrobial_name_list->[4] => {
							do_label => 0,
							type => 'Text',
							element_wrapper_class => 'col-sm-offset-2 col-sm-10',
							required => 0,
							minlength => 1,
							maxlength => 6,
							element_attr => { class=>'input-full' },
							validate_method => \&check_mic
						},
						$antimicrobial_name_list->[5] => {
							do_label => 0,
							type => 'Text',
							element_wrapper_class => 'col-sm-offset-2 col-sm-10',
							required => 0,
							minlength => 1,
							maxlength => 6,
							element_attr => {class=>'input-full' },
							validate_method => \&check_mic
						},
						$antimicrobial_name_list->[6] => {
							do_label => 0,
							type => 'Text',
							element_wrapper_class => 'col-sm-offset-2 col-sm-10',
							required => 0,
							minlength => 1,
							maxlength => 6,
							element_attr => { class=>'input-full'},
							validate_method => \&check_mic
						},
						$antimicrobial_name_list->[7] => {
							do_label => 0,
							type => 'Text',
							element_wrapper_class => 'col-sm-offset-2 col-sm-10',
							required => 0,
							minlength => 1,
							maxlength => 6,
							element_attr => { class=>'input-full'},
							validate_method => \&check_mic
						},
					]
				);

				$form->process(update_field_list => {
					collection_date => {element_attr => { placeholder => $c->loc("shared.date.format")}},
					csrf => {default => $c->session->{csrf_token} },
				});

				my @separated_allele_types;
				my $allele_type_str = $c->flash->{profile_allele_types};
				if($allele_type_str)
				{
					@separated_allele_types = split("," , $allele_type_str);

					$form->process(update_field_list => {
						allele_type0 => {default => $separated_allele_types[0]},
						allele_type1 => {default => $separated_allele_types[1]},
						allele_type2 => {default => $separated_allele_types[2]},
						allele_type3 => {default => $separated_allele_types[3]},
						allele_type4 => {default => $separated_allele_types[4]},
						allele_type5 => {default => $separated_allele_types[5]},
						allele_type6 => {default => $separated_allele_types[6]},
					});
				}

				$c->stash(template => 'sequence_type/AddProfileForm.tt2', form => $form, antimicrobial_name_list => $antimicrobial_name_list, classification_list => $classification_list, name_list => $loci_name_list, , page_title=>$ADD_ST_PAGE_TITLE);

				$form->process(params => $c->request->params);
				return unless $form->validated;


				#get meta-data
				#to do: validate request parameters
				my $collection_date = $c->request->params->{collection_date};
				my $country = $c->request->params->{country};
				my $patient_age = $c->request->params->{patient_age};
				my $patient_gender = $c->request->params->{patient_gender};
				my $beta_lactamase = $c->request->params->{beta_lactamase};
				my $classification_code = $c->request->params->{isolate_classification};
				my $epi_data = $c->request->params->{epi_data};
				my $curator_comment = $c->request->params->{curator_comment};
				my $csrf_form_submitted = $c->request->params->{csrf};
				my %mic_map;
				my $error_string="";

				my $metadata;
				my $amr_marker_string="";
				my $formatted_classification_code="";
				my $result_amr_marker_string="";

				if($csrf_form_submitted and $csrf_form_submitted eq $c->session->{csrf_token})
				{

					my $error_code;
					my %profile_map;

					my $sequence_type = $c->request->params->{sequence_type};

					if($sequence_type !~ /^(\d+)$/)
					{

						$error_code = $ERROR_INVALID_SEQUENCE_TYPE;

					}

					my @allele_types_list;

					for( my $i = 0; $i < $NUM_SEQUENCES; $i ++)
					{

						my $key = "allele_type".$i;
						my $allele_type = $c->request->params->{$key};

						if($allele_type !~ /^[0-9]\d*(\.\d{0,3})?$/)
						{

							$error_code = $ERROR_INVALID_ALLELE_TYPE;

						}

						my $loci_name = $loci_name_list->[$i];
						$profile_map{$loci_name} = $allele_type;

						$obj = $c->model('GetMetadata');
						$metadata = $obj->_get_metadata($allele_type, $loci_name);

						if(($metadata) and (%$metadata))
						{
							if($metadata->{amr_markers})
							{
								$amr_marker_string .= $loci_name." ".$metadata->{amr_markers}."; ";
								$result_amr_marker_string .= $loci_name." ".$metadata->{amr_markers}."; ";
							}
							else
							{
								$amr_marker_string .= $loci_name." Not provided; ";
								$result_amr_marker_string .= $loci_name." Not provided; ";
							}
							push @allele_types_list, $allele_type;
						}
					}

					chomp($result_amr_marker_string);

					if($classification_code)
					{

						if(ref($classification_code) eq 'ARRAY')
						{

							foreach my $code (@$classification_code)
							{

								$formatted_classification_code .= $code."/";

							}

						}
						else
						{

							$formatted_classification_code = $classification_code."/";

						}

					}

					foreach my $name (@$antimicrobial_name_list)
					{

						my $comparator_key = $name . "_comparator_option";
						$mic_map{$name}{mic_comparator} = $c->request->params->{$comparator_key};

						if($c->request->params->{$name} and length $c->request->params->{$name} > 0)
						{
							$mic_map{$name}{mic_value} = $c->request->params->{$name};
						}
						else
						{
							$mic_map{$name}{mic_value} = undef;
						}

					}

					my $err_msg;

					if(defined $error_code)
					{

						$err_msg = $c->loc($ERROR_BASE_STRING.$error_code);
						$c->stash(error_id => $error_code, error_code => $err_msg);

					}
					else
					{

						$c->session->{csrf_token} = Session::Token->new(length => 128)->get;

						$obj = $c->model('AddSequenceTypeProfile');
						my $result = $obj->_add_sequence_type_profile($sequence_type, \%profile_map, $country, $patient_age, $collection_date, $patient_gender, $epi_data, $curator_comment, $beta_lactamase, $formatted_classification_code, \%mic_map, $amr_marker_string);

						if($result eq $VALID_CONST)
						{

							$c->flash(add_profile_notification => $NOTIFICATION_ON, amr_marker_string => $result_amr_marker_string, st_added => $sequence_type, allele_types_list => \@allele_types_list);
							$c->response->redirect($c->uri_for($self->action_for('list_profiles')));

						}
						elsif($result eq $ERROR_NONEXISTANT_ALLELE)
						{

							$obj = $c->model('GetAlleleInfo');
							my $nonexistant_alleles = $obj->_get_non_existant_alleles(\%profile_map);
							$obj = $c->model('GetIntegerType');
							my $loci_int_type_set = $obj->_get_loci_with_integer_type();

							if(($nonexistant_alleles) and (@$nonexistant_alleles))
							{

								foreach my $allele(@$nonexistant_alleles)
								{

									if((%$loci_int_type_set) and (exists $loci_int_type_set->{$allele->{loci_name}}))
									{

										$error_string = $error_string.$allele->{loci_name}." ".$allele->{allele_type}."\n";

									}
									else
									{

										$error_string = $error_string.$allele->{loci_name}." ".sprintf ("%.3f", $allele->{allele_type})."\n";

									}

								}

								$c->flash(edit_notification => $NOTIFICATION_OFF);

								$err_msg = $c->loc($ERROR_BASE_STRING.$result);

								$err_msg =  named_sprintf($err_msg, { error_alleles => $error_string });
								$c->stash(error_id => $result, error_code => $err_msg );

							}

						}
						else
						{

							$c->flash(add_notification => $NOTIFICATION_OFF);
							$err_msg = $c->loc($ERROR_BASE_STRING.$result);
							$c->stash(error_id => $result, error_code => $err_msg);

						}

					}

				}
				else
				{

					$c->response->redirect($c->uri_for($self->action_for('add_profile')));

				}

			}

		}
		else
		{

			$c->stash(template => 'error/access_denied_admin.tt2', page_title=>$ERROR_LOGIN_REQ_PAGE_TITLE);

		}

	}
	else
	{

		$c->stash(template => 'error/error_404.tt2', page_title=>$ERROR_404_PAGE_TITLE);


	}

}

sub batch_add_profile :Local
{

	my ($self, $c) = @_;

	$c->log->debug("*** INSIDE batch_add_profile METHOD ***");

	if($c->stash->{'login_allow'} eq "true")
	{

		if($c->user_exists() and $c->check_any_user_role(qw/ user admin /))
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

			my $form = NGSTAR::Form::BatchAddProfileForm->new(language_handle => $lh, ctx => $c);

			$form->process(update_field_list => {
				profiles => {messages => {required => $c->loc('enter.profile.msg')}},
				csrf => {default => $c->session->{csrf_token} },
			});

			$c->stash(template => 'sequence_type/BatchAddProfileForm.tt2', form => $form, , page_title=>$BATCH_ADD_ST_PAGE_TITLE);

			$form->process(params => $c->request->params);
			return unless $form->validated;

			my $has_error = $FALSE;
			my $error_code = $INVALID_CONST;

			my $input = $c->request->params->{profiles};
			my $csrf_form_submitted = $c->request->params->{csrf};

			if($csrf_form_submitted and $csrf_form_submitted eq $c->session->{csrf_token})
			{
				#remove any characters that are not part of the whitelist
				#case 1: info is provided in textbox
				if($input)
				{

					$input =~ s/[^,\d\.\n]//g;

				}

				my $obj;
				my $result;
				my $err_msg;

				#case 2: a file is uploaded
				if(not $has_error and not $input)
				{

					#Catalyst saves the uploaded file to a temp directory (default is at /tmp).
					#You can specify this directory in the Catalyst configuration contained in NGSTAR.pm
					#The uploaded file is automatically saved with a random filename for security.
					#The uploaded file is automatically deleted after it has been processed.
					my $upload = $c->request->upload('my_file');

					if($upload)
					{

						$c->log->debug('**Headers: ' . $upload->headers);
						$c->log->debug('**Content-Type: ' . $upload->type);
						$c->log->debug('**Filename: ' . $upload->filename);
						$c->log->debug('**Temp dir: ' . $upload->tempname);
						$c->log->debug('**Size in bytes: ' . $upload->size);

						my $filename = $upload->filename;
						my $filesize = $upload->size;
						my $content_type = $upload->type;

						#file size should not be any greater than 1 MB
						if($filesize > $MAX_FILE_SIZE)
						{

							$has_error = $TRUE;
							$error_code = $ERROR_FILE_SIZE_TOO_LARGE;

						}

						if($filesize <= $MIN_FILE_SIZE)
						{

							$has_error = $TRUE;
							$error_code = $ERROR_FILE_SIZE_TOO_SMALL;

						}

						#check the content type
						if($content_type ne "text/plain" and $content_type ne "text/csv")
						{

							$has_error = $TRUE;
							$error_code = $ERROR_INVALID_CONTENT_TYPE;

						}

						#check that the filename is the correct format
						if($filename !~ /^[(A-Z)|(\d)|(_)|(\-)]+((\.txt)|(\.csv))$/i)
						{

							$has_error = $TRUE;
							$error_code = $ERROR_INVALID_FILENAME_FORMAT;

						}

						if(not $has_error)
						{

							#slurp reads the file contents and appends then to a string.
							#it returns a string that contains the contents of the file
							$input= $upload->slurp();

							if($input !~ /[(A-Z)|(\d)|(\.)]+/i)
							{

								$has_error = $TRUE;
								$error_code = $ERROR_INVALID_INPUT_FORMAT;

							}

						}

					}
					#case 3: textbox is empty and no file is uploaded
					else
					{

						$has_error = $TRUE;
						$error_code = $ERROR_INVALID_INPUT_FORMAT;

					}

				}
				if(not $has_error)
				{

					$obj = $c->model('ValidateBatchProfiles');
					$result = $obj->_validate_batch_profiles_parse($input);

					if($result eq $VALID_CONST)
					{

						$result = $obj->_validate_input($input);

						if($result and %$result)
						{

							$has_error = $TRUE;
							$c->stash(error_codes => $result);

						}

					}
					else
					{

						$has_error = $TRUE;
						$error_code = $ERROR_INVALID_INPUT_FORMAT;

						$err_msg = $c->loc($ERROR_BASE_STRING.$ERROR_INVALID_INPUT_FORMAT);
						$c->stash(error_id => $ERROR_INVALID_INPUT_FORMAT, error_code => $err_msg);

					}

				}
				else
				{

					$err_msg = $c->loc($ERROR_BASE_STRING.$error_code);
					$c->stash(error_id => $error_code, error_code => $err_msg);

				}

				#if there are no errors after validation, then proceed with batch adding alleles to the database
				if(not $has_error)
				{

					$c->session->{csrf_token} = Session::Token->new(length => 128)->get;

					$obj = $c->model('BatchAddProfile');
					$result = $obj->_batch_add_profile($input);

					if($result ne $VALID_CONST)
					{

						$has_error = $TRUE;
						$error_code = $result;

					}

					if(not $has_error)
					{
						$c->flash(batch_profile_notification => $NOTIFICATION_ON);
						$c->response->redirect($c->uri_for($self->action_for('list_profiles')));

					}

				}

			}
			else
			{

				$c->response->redirect($c->uri_for($self->action_for('batch_add_profile')));

			}

		}
		else
		{

			$c->stash(template => 'error/access_denied_admin.tt2', page_title=>$ERROR_LOGIN_REQ_PAGE_TITLE);

		}

	}
	else
	{

			$c->stash(template => 'error/error_404.tt2',, page_title=>$ERROR_404_PAGE_TITLE);

	}

}

sub batch_add_example :Local
{

	my ($self, $c) = @_;

	$c->log->debug('*** INSIDE SEQUENCETYPE batch_add_example METHOD ***');


	my $obj = $c->model('GetAlleleInfo');
	my $loci_names = $obj->_get_all_loci_names;

	if($c->user_exists() and $c->check_any_user_role(qw/ user admin /))
	{

		$c->stash(template => 'sequence_type/BatchAddProfileExample.tt2', loci_names => $loci_names, num_sequences => $NUM_SEQUENCES, page_title=>$BATCH_ADD_ST_EX_PAGE_TITLE);

	}
	else
	{

		$c->stash(template => 'error/access_denied_admin.tt2', page_title=>$ERROR_LOGIN_REQ_PAGE_TITLE);

	}

}

sub batch_add_profile_metadata :Local
{

	my ($self, $c) = @_;

	$c->log->debug('*** INSIDE batch_add_profile_metadata METHOD ***');

	if($c->stash->{'login_allow'} eq "true")
	{

		if($c->user_exists() and $c->check_any_user_role(qw/ user admin /))
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


			my $form = NGSTAR::Form::BatchAddProfileMetadataForm->new(language_handle => $lh, ctx => $c);

			$form->process(update_field_list => {
				batch_metadata => {messages => {required => $c->loc('shared.enter.metadata.msg')}},
				csrf => {default => $c->session->{csrf_token} },
			});

			$c->stash(template => 'sequence_type/BatchAddProfileMetadataForm.tt2', form => $form, page_title=>$BATCH_ADD_ST_METADATA_PAGE_TITLE);

			$form->process(params => $c->request->params);
			return unless $form->validated;

			my $has_error = $FALSE;
			my $error_code = $INVALID_CONST;
			my $obj;
			my $result;
			my $err_msg;

			my $input = $c->request->params->{batch_metadata};
			my $csrf_form_submitted = $c->request->params->{csrf};

			if($csrf_form_submitted and $csrf_form_submitted eq $c->session->{csrf_token})
			{
				#remove any characters that are not part of this whitelist
				#case 1: info is provided in textbox
				if($input)
				{

					$input =~ s/[^A-Za-z\d\.\s\n\r\-\_\,\;\t\:\/<>=]//g;

				}
				#case 2: a file is uploaded
				elsif(not $has_error and not $input)
				{

					my $upload = $c->request->upload('batch_metadata_file');

					if($upload)
					{

						my $filename = $upload->filename;
						my $filesize = $upload->size;

						if($filesize > $MAX_FILE_SIZE)
						{

							$has_error = $TRUE;
							$error_code = $ERROR_FILE_SIZE_TOO_LARGE;

						}

						if($filesize <= $MIN_FILE_SIZE)
						{

							$has_error = $TRUE;
							$error_code = $ERROR_FILE_SIZE_TOO_SMALL;

						}

						if($filename !~ /^[(A-Z)|(\d)|(_)|(\-)]+(\.txt)$/i)
						{

							$has_error = $TRUE;
							$error_code = $ERROR_INVALID_FILENAME_FORMAT;

						}

						if(not $has_error)
						{

							$input= $upload->slurp();

							if($input !~ /^[(<)|(>)|(=)|(\:)|(+)|(A-Z)|(0-9)|(\.)|(\-)|(_)|(\,)|(\n)|(\r)|(\s)|(\t)|(\;)|(\/)]+$/i)
							{

								$has_error = $TRUE;
								$error_code = $ERROR_INVALID_TAB_INPUT_FORMAT;

							}

						}

					}
					#case 3: textbox is empty and no file is uploaded
					else
					{

						$has_error = $TRUE;
						$error_code = $ERROR_INVALID_INPUT_FORMAT;
					}

				}

				if(not $has_error)
				{

				   $obj = $c->model('ValidateBatchMetadata');

				   #validate whether the input can be properly parsed

					$result = $obj->_validate_batch_metadata_parse($input);

					if($result eq $VALID_CONST)
					{

						#validate metadata in the tab formatted input
						$result = $obj->_validate_batch_profile_metadata_input($input);

						if($result and %$result)
						{

							$has_error = $TRUE;
							$c->stash(error_codes => $result);

						}

					}
					else
					{

						$has_error = $TRUE;
						$error_code = $result;

						$err_msg = $c->loc($ERROR_BASE_STRING.$result);
						$c->stash(error_id => $result, error_code => $err_msg);

					}

				}
				else
				{

					$err_msg = $c->loc($ERROR_BASE_STRING.$error_code);
					$c->stash(error_id => $error_code, error_code => $err_msg);

				}

				#if there are no errors after validation, then proceed with batch adding metadata to the database
				if(not $has_error)
				{

					$c->session->{csrf_token} = Session::Token->new(length => 128)->get;

					$obj = $c->model('BatchAddMetadata');
					$result = $obj->_batch_add_profile_metadata($input);

					if($result ne $VALID_CONST)
					{

						$has_error = $TRUE;
						$error_code = $result;

						$err_msg = $c->loc($ERROR_BASE_STRING.$error_code);
						$c->stash(error_id => $error_code, error_code => $err_msg);

					}

					if(not $has_error)
					{

						$c->flash(batch_metadata_notification => $NOTIFICATION_ON);
						$c->response->redirect($c->uri_for($self->action_for('batch_add_profile_metadata')));

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

				$c->response->redirect($c->uri_for($self->action_for('batch_add_profile_metadata')));

			}

		}
		else
		{

			$c->stash(template => 'error/access_denied_admin.tt2', page_title=>$ERROR_LOGIN_REQ_PAGE_TITLE);

		}

	}
	else
	{

		$c->stash(template => 'error/error_404.tt2', page_title=>$ERROR_404_PAGE_TITLE);

	}

}

sub batch_add_profile_metadata_example :Local
{

	my ($self, $c) = @_;

	$c->log->debug('*** INSIDE batch_add_profile_metadata_example METHOD ***');

	if($c->user_exists() and $c->check_any_user_role(qw/ user admin /))
	{

		$c->stash(template => 'sequence_type/BatchAddProfileMetadataExample.tt2', page_title=>$BATCH_ADD_ST_METADATA_EX_PAGE_TITLE);

	}
	else
	{

		$c->stash(template => 'error/access_denied_admin.tt2', page_title=>$ERROR_LOGIN_REQ_PAGE_TITLE);

	}

}

sub batch_profile_query :Local
{

	my ($self, $c) = @_;

	my $curr_lang = $c->session->{lang};
	my $lh = NGSTAR::I18N::i_default->new;
	my $err_msg;
	my $obj;
	$obj = $c->model('GetAlleleInfo');
	my $name_list = $obj->_get_all_loci_names;

	if($c->session->{lang})
	{
		if($c->session->{lang} eq $TRANSLATION_LANG)
		{
			$lh = NGSTAR::I18N::fr->new;
		}
	}

	#add some additional fields to the form that is not already defined in AddAlleleForm
	my $form = NGSTAR::Form::BatchProfileQueryForm->new(
		language_handle => $lh,
	);

	$form->process(update_field_list => {
		csrf => {default => $c->session->{csrf_token} },
	});

	$c->stash(template => 'sequence_type/BatchProfileQueryForm.tt2', form => $form, page_title => $BATCH_PROFILE_QUERY_PAGE_TITLE);

	$form->process(params => $c->request->params);
	return unless $form->validated;

	my $has_error = $FALSE;
	my $error_code = $INVALID_CONST;
	my $csrf_form_submitted = $c->request->params->{csrf};

	my $input = $c->request->params->{batch_profile_query};

	if($csrf_form_submitted and $csrf_form_submitted eq $c->session->{csrf_token})
	{
		#remove any characters that are not part of this whitelist
		#case 1: info is provided in textbox

		if($input)
		{

			$input =~ s/[^\d\.\s\n\r\t\,]//g;

		}
		#case 2: a file is uploaded
		if(not $has_error and not $input)
		{
			#Catalyst saves the uploaded file to a temp directory (default is at /tmp).
			#You can specify this directory in the Catalyst configuration contained in NGSTAR.pm
			#The uploaded file is automatically saved with a random filename for security.
			#The uploaded file is automatically deleted after it has been processed.

			my $upload = $c->request->upload('batch_profile_query_file');

			if($upload)
			{

				my $filename = $upload->filename;
				my $filesize = $upload->size;

				#file size should not be any greater than 5.34 MB
				#this file size limit should be good enough to support
				#a fasta file with ~2000 alleles
				if($filesize > $MAX_FILE_SIZE)
				{

					$has_error = $TRUE;
					$error_code = $ERROR_FILE_SIZE_TOO_LARGE;

				}

				if($filesize <= $MIN_FILE_SIZE)
				{

					$has_error = $TRUE;
					$error_code = $ERROR_FILE_SIZE_TOO_SMALL;

				}

				#check that the filename is the correct format
				if($filename !~ /^[(A-Z)|(\d)|(\_)|(\-)]+(\.csv)|(\.txt)$/i)
				{

					$has_error = $TRUE;
					$error_code = $ERROR_INVALID_FILENAME;

				}

				if(not $has_error)
				{

					#slurp reads the file contents and appends then to a string.
					#it returns a string that contains the contents of the file
					#$string = $upload->slurp();
					$input= $upload->slurp();

					if($input !~ /^[(0-9)|(\.)|(\,)|(\n)|(\r)|(\s)|(\t)]+$/i)
					{

						$has_error = $TRUE;
						$error_code = $ERROR_INVALID_INPUT_FORMAT;

					}

				}

			}
			#case 3: textbox is empty and no file is uploaded
			else
			{

				$has_error = $TRUE;
				$error_code = $ERROR_INVALID_INPUT_FORMAT;

			}

		}

		if(not $input)
		{
			$err_msg = $c->loc($ERROR_BASE_STRING.$ERROR_CODE_EMPTY_PROFILES);
			$c->stash(error_id => $ERROR_CODE_EMPTY_PROFILES, error_code => $err_msg);
		}
		else
		{
			$obj = $c->model('GetSequenceTypeInfo');
			my $profile_count = $obj->_get_profile_list_length();

			if($profile_count > 0)
			{
				$obj = $c->model('BatchSequenceTypeQuery');
				my $batch_seq_type_results = $obj->_profile_batch_query($input);

				if(($batch_seq_type_results) and (@$batch_seq_type_results))
				{

					$c->stash(template => 'sequence_type/BatchQueryResults.tt2', page_title=>$BATCH_PROFILE_QUERY_RESULTS_PAGE_TITLE, batch_seq_type_results_list => \@$batch_seq_type_results, name_list => $name_list );

				}
				else
				{
					$err_msg = $c->loc($ERROR_BASE_STRING.$ERROR_CODE_BATCH_PROFILE_QUERY_DATA);
					$c->stash(error_id => $ERROR_CODE_BATCH_PROFILE_QUERY_DATA, error_code => $err_msg);
				}
			}
			else
			{
				$err_msg = $c->loc($ERROR_BASE_STRING.$ERROR_NO_PROFILES);
				$c->stash(error_id => $ERROR_NO_PROFILES, error_code => $err_msg);
			}

		}

	}

}

sub batch_profile_query_example :Local
{

	my ($self, $c) = @_;

	$c->log->debug('*** INSIDE SEQUENCETYPE batch_profile_query_example METHOD ***');

	$c->stash(template => 'sequence_type/BatchProfileQueryExample.tt2', page_title=>$BATCH_PROFILE_QUERY_EX_PAGE_TITLE);


}

sub curator_profile_query :Local
{
	my ($self, $c) = @_;

	if($c->stash->{'login_allow'} eq "true")
	{

		if($c->user_exists() and $c->check_any_user_role(qw/ user admin /))
		{

			my $curr_lang = $c->session->{lang};
			my $lh = NGSTAR::I18N::i_default->new;
			my $err_msg;
			my $obj;
			$obj = $c->model('GetAlleleInfo');
			my $name_list = $obj->_get_all_loci_names;

			if($c->session->{lang})
			{
				if($c->session->{lang} eq $TRANSLATION_LANG)
				{
					$lh = NGSTAR::I18N::fr->new;
				}
			}

			#add some additional fields to the form that is not already defined in AddAlleleForm
			my $form = NGSTAR::Form::CuratorProfileQueryForm->new(
				language_handle => $lh,
			);

			$form->process(update_field_list => {
				csrf => {default => $c->session->{csrf_token} },
			});

			$c->stash(template => 'sequence_type/CuratorProfileQueryForm.tt2', form => $form, page_title => $CURATOR_PROFILE_QUERY_PAGE_TITLE);
			$form->process(params => $c->request->params);
			return unless $form->validated;

			my $csrf_form_submitted = $c->request->params->{csrf};
			my $input = $c->request->params->{curator_profiles};
			my $error_code;
			my $is_valid = $TRUE;
			my $parsed_profile_list;

			if($csrf_form_submitted and $csrf_form_submitted eq $c->session->{csrf_token})
			{

				if($input !~ /^[(A-Z)|(0-9)|(\.)(\n)|(\r)|(\s)|(:)]+$/i)
				{

					$is_valid = $FALSE;
					$error_code = $ERROR_INVALID_CURATOR_PROFILE_INPUT_FORMAT;

				}

				if($is_valid)
				{

					#remove all extra newlines at the end of the file
					$input =~ s/[\r\n]*\Z//g;

					$obj = $c->model("ParseProfiles");
					$parsed_profile_list = $obj->_parse_curator_profile($input);

					if($parsed_profile_list)
					{

						my %allele_type_map;
						my $name_key;
						my $count = 0;

						foreach my $allele_type(@$parsed_profile_list)
						{

							$name_key = $name_list->[$count];
							$allele_type =~ s/(\s+)//g;
							$allele_type_map{$name_key} = $allele_type;
							$count++;

						}

						my $match_threshold = 0;
						my $max_results = 10;
						my $is_curator_query = $TRUE;

						$self->get_st_profile($c, \%allele_type_map, $match_threshold, $name_list, $max_results, $is_curator_query);


					}
					else
					{
						$err_msg = $c->loc($ERROR_BASE_STRING.$ERROR_INVALID_CURATOR_PROFILE_INPUT_FORMAT);
						$c->stash(error_id => $ERROR_INVALID_CURATOR_PROFILE_INPUT_FORMAT, error_code => $err_msg);
					}

				}

			}
			else
			{
				$c->response->redirect($c->uri_for($self->action_for('curator_profile_query')));
			}


		}
		else
		{
			$c->stash(template => 'error/access_denied_admin.tt2', page_title=>$ERROR_LOGIN_REQ_PAGE_TITLE);
		}

	}
	else
	{

		$c->stash(template => 'error/error_404.tt2', page_title=>$ERROR_404_PAGE_TITLE);

	}


}


sub delete :Local :Args(1)
{

	my ($self, $c, $sequence_type) = @_;

	if($c->stash->{'login_allow'} eq "true")
	{

		if($c->user_exists() and $c->check_any_user_role(qw/ user admin /))
		{

			$c->response->redirect($c->uri_for($self->action_for('delete_process'), $sequence_type));

		}
		else
		{

			$c->stash(template => 'error/access_denied_admin.tt2', page_title=>$ERROR_LOGIN_REQ_PAGE_TITLE);

		}

	}
	else
	{

		$c->stash(template => 'error/error_404.tt2', page_title=>$ERROR_404_PAGE_TITLE);

	}

}

sub delete_process :Local :Args(1)
{

	my ($self, $c, $sequence_type) = @_;

	$c->log->debug('*** INSIDE delete_process METHOD ***');

	if($c->stash->{'login_allow'} eq "true")
	{

		if($c->user_exists() and $c->check_any_user_role(qw/ user admin /))
		{

			my $obj = $c->model('DeleteSequenceTypeProfile');
			my $result = $obj->_delete_sequence_type_profile($sequence_type);
			my $err_msg;


			if($result eq $VALID_CONST)
			{

				$c->flash(delete_notification => $NOTIFICATION_ON);
				$c->response->redirect($c->uri_for($self->action_for('list_profiles')));

			}
			else
			{

				$c->flash(delete_notification => $NOTIFICATION_OFF);

				$err_msg = $c->loc($ERROR_BASE_STRING.$result);
				$c->stash(error_id => $result, error_code => $err_msg);

			}

		}
		else
		{

			$c->stash(template => 'error/access_denied_admin.tt2', page_title=>$ERROR_LOGIN_REQ_PAGE_TITLE);

		}

	}
	else
	{

		$c->stash(template => 'error/error_404.tt2', page_title=>$ERROR_404_PAGE_TITLE);

	}

}

sub details :Local :Args(1)
{

	my ($self, $c, $sequence_type) = @_;

	$c->log->debug('*** INSIDE details METHOD ***');

	if(not $c->user_exists())
	{
		my $obj = $c->model('GetAlleleInfo');
		my $loci_name_list = $obj->_get_all_loci_names();
		my $err_msg;


		$obj = $c->model('GetSequenceTypeInfo');
		my $profile = $obj->_get_profile($sequence_type);

		$obj = $c->model('GetMetadata');
		my $metadata = $obj->_get_metadata($sequence_type);
		my $mic_list = $obj->_get_metadata_mics($sequence_type);
		my $classifications_list = $obj->_get_metadata_classifications($sequence_type);

		if((not $loci_name_list) or
			(not $profile) or
			(not $metadata) or
			(not $mic_list))
		{

			$err_msg = $c->loc($ERROR_BASE_STRING.$ERROR_CODE_PROFILE_NO_DATA);
			$c->stash(error_id => $ERROR_CODE_PROFILE_NO_DATA, error_code => $err_msg);

		}
		else
		{

			$obj = $c->model('GetIntegerType');
			my $loci_int_type_set = $obj->_get_loci_with_integer_type();

			$c->stash(template => 'sequence_type/ProfileDetails.tt2', loci_name_list => $loci_name_list, sequence_type => $sequence_type, profile => $profile, metadata => $metadata, mic_list => $mic_list, loci_int_type_set => $loci_int_type_set, classifications_list => $classifications_list, page_title=>$ST_DETAILS_PAGE_TITLE);

		}
	}
	else
	{
		$c->response->redirect($c->uri_for($self->action_for('edit'),$sequence_type));

	}
}

sub display_sequence_type :Local
{

	my ($self, $c) = @_;

	$c->log->debug("*** INSIDE display_sequence_type METHOD ***");

	my $obj = $c->model('GetIntegerType');
	my $loci_int_type_set = $obj->_get_loci_with_integer_type();


	$c->stash(template => 'sequence_type/SequenceTypeResult.tt2', loci_int_type_set => $loci_int_type_set, page_title=>$ST_QUERY_RESULT_PAGE_TITLE);

}


sub download_profiles_process :Local :Args()
{

	my ($self, $c, $option) = @_;

	$c->log->debug('*** INSIDE download_profiles_process METHOD ***');


	my @options = ($OPTION_COMMA_SEPARATED_TEXT, $OPTION_TAB_SEPARATED_TEXT);

	my $has_error = $FALSE;
	my $err_msg;
	my $obj;

	if(($option) and ($option !~ /^[(A-Z)|(\s)]+$/i))
	{

		$has_error = $TRUE;

	}

	if(not $has_error)
	{

		$obj = $c->model('GetSequenceTypeInfo');
		my $length = $obj->_get_profile_list_length();

		if($length > 0)
		{

			my $format_option;

			if(lc($option) eq lc($options[0]))
			{

				$format_option = $FORMAT_CODE_COMMA;

			}
			elsif(lc($option) eq lc($options[1]))
			{

				$format_option = $FORMAT_CODE_TAB;

			}
			else
			{

				$err_msg = $c->loc($ERROR_BASE_STRING.$ERROR_CODE_INVALID_DOWNLOAD_FORMAT);
				$c->stash(error_id => $ERROR_CODE_INVALID_DOWNLOAD_FORMAT, error_code => $err_msg);

			}

			my $result = $obj->_get_all_profiles_format($format_option);

			if(not $result)
			{

				$err_msg = $c->loc($ERROR_BASE_STRING.$ERROR_CODE_INVALID_PROFILE_FORMAT);
				$c->stash(error_id => $ERROR_CODE_INVALID_PROFILE_FORMAT, error_code => $err_msg);

			}
			else
			{

				$self->export_profiles($c, $result, $format_option);

			}

		}
		else
		{

		   $c->stash(template => 'sequence_type/ListProfiles.tt2', error => $ERROR_NO_PROFILES, , page_title=>$ST_LIST_PAGE_TITLE);

		}

	}
	else
	{

		$err_msg = $c->loc($ERROR_BASE_STRING.$ERROR_CODE_INVALID_OPTION);
		$c->stash(error_id => $ERROR_CODE_INVALID_OPTION, error_code => $err_msg);


	}

}


sub download_profile_metadata :Local :Args()
{

	my ($self, $c) = @_;

	$c->log->debug('*** INSIDE download_profile_metadata METHOD ***');


	my $obj = $c->model('GetSequenceTypeInfo');
	my $length = $obj->_get_profile_list_length();
	my $err_msg;

	if($length > 0)
	{

		$obj = $c->model('GetMetadata');

		my $localized_header .= $c->loc("shared.profile.type.text")."\t".$c->loc("shared.amr.markers.text")."\t".$c->loc("shared.collection.date.text") . "\t". $c->loc("shared.country.text") ."\t". $c->loc("shared.patient.age.text") ."\t". $c->loc("shared.patient.gender.text")."\t".$c->loc("shared.beta.lactamase.text") ."\t". $c->loc("shared.isolate.classifications.text")."\t".$c->loc("Azithromycin")."\t".$c->loc("Cefixime"). "\t".$c->loc("Ceftriaxone"). "\t".$c->loc("Ciprofloxacin"). "\t".$c->loc("Erythromycin"). "\t".$c->loc("Penicillin"). "\t".$c->loc("Spectinomycin"). "\t".$c->loc("Tetracycline"). "\t".$c->loc("shared.additional.epi.data.text")."\t".$c->loc("shared.curator.comments.text")."\n";

		my $result = $obj->_get_profile_metadata($localized_header);

		if(not $result)
		{

			$err_msg = $c->loc($ERROR_BASE_STRING.$ERROR_CODE_INVALID_PROFILE_METADATA_FORMAT);
			$c->stash(error_id => $ERROR_CODE_INVALID_PROFILE_METADATA_FORMAT, error_code => $err_msg);

		}
		else
		{

			$self->export_profile_metadata($c, $result);

		}

	}
	else
	{

	   $c->stash(template => 'sequence_type/ListProfiles.tt2', error => $ERROR_NO_PROFILES, , page_title=>$ST_LIST_PAGE_TITLE);

	}

}


sub edit :Local :Args(1)
{

	my ($self, $c, $seq_type_prev) = @_;

	$c->log->debug('*** INSIDE edit METHOD ***');

	if($c->stash->{'login_allow'} eq "true")
	{

		if($c->user_exists() and $c->check_any_user_role(qw/ user admin /))
		{

			my $result;

			my $obj = $c->model('GetAlleleInfo');
			my $loci_name_list = $obj->_get_all_loci_names();

			$obj = $c->model('GetSequenceTypeInfo');
			my $profile_map_prev = $obj->_get_profile($seq_type_prev);

			$obj = $c->model('GetMetadata');
			my $antimicrobial_name_list = $obj->_get_mic_antimicrobial_names();
			my $classification_list = $obj->_get_all_isolate_classifications();
			my $metadata = $obj->_get_metadata($seq_type_prev);
			my $mic_list = $obj->_get_metadata_mics($seq_type_prev);
			my $isolate_classifications_list = $obj->_get_metadata_classifications($seq_type_prev);
			my $err_msg;

			my $classification_code_on_error = $c->request->params->{isolate_classification};


			my $curr_lang = $c->session->{lang};
			my $lh = NGSTAR::I18N::i_default->new;

			if($c->session->{lang})
			{
				if($c->session->{lang} eq $TRANSLATION_LANG)
				{
					$lh = NGSTAR::I18N::fr->new;
				}
			}


			if($loci_name_list and $profile_map_prev and $antimicrobial_name_list and $classification_list and $metadata and $mic_list)
			{

				my @classification_codes;

				foreach my $classification_in_list (@$classification_list)
				{
					push @classification_codes ,$classification_in_list->{classification_code};
				}

				my @classifications = map { $_, $_ } @classification_codes;


				my $isolate_classification_codes="";

				if($classification_code_on_error)
				{

					if(ref($classification_code_on_error) eq 'ARRAY')
					{

						foreach my $class_code (@$classification_code_on_error)
						{

							$isolate_classification_codes = $isolate_classification_codes.$class_code." ";
						}

					}
					else
					{

						$isolate_classification_codes = $isolate_classification_codes.$classification_code_on_error." ";

					}

				}
				elsif($c->request->referer eq $c->request->uri and  (defined $classification_code_on_error and $classification_code_on_error eq ""))
				{
					$isolate_classification_codes = "";
				}
				else
				{

					foreach my $isolate_code (@$isolate_classifications_list)
					{

						#passed to template so that we can populate the isolate classifications using jquery
						$isolate_classification_codes = $isolate_classification_codes.$isolate_code->{classification_code}." ";

					}

				}

				my $ge = "&ge;";
				my $le = "&le;";
				my $gt = "&gt;";
				my $lt = "&lt;";

				my $ge_decoded = decode_entities($ge);
				my $le_decoded = decode_entities($le);
				my $gt_decoded = decode_entities($gt);
				my $lt_decoded = decode_entities($lt);

				my $form = NGSTAR::Form::EditProfileForm->new(
					language_handle => $lh,
					field_list => [
						'patient_gender' => {
							do_label => 1,
							type => 'Select',
							label => 'shared.patient.gender.text',
							label_class => 'col-sm-2',
							element_wrapper_class => 'col-sm-10',
							required => 0,
							options => [{value => 'U', label => $c->loc('shared.unknown.text')},
										{value => 'F', label => $c->loc('shared.female.text')},
										{value => 'M', label => $c->loc('shared.male.text') }],
							default => $metadata->{patient_gender}
						},
						'beta_lactamase' => {
							do_label => 1,
							type => 'Select',
							label => 'shared.beta.lactamase.text',
							label_class => 'col-sm-2',
							element_wrapper_class => 'col-sm-10',
							required => 0,
							options => [{value => 'Unknown', label => $c->loc('shared.unknown.text')},
										{value => 'Positive', label => $c->loc('shared.positive.text')},
										{value => 'Negative', label => $c->loc('shared.negative.text') }],
							default => $metadata->{beta_lactamase}
						},
						'isolate_classification' => {
							do_label => 1,
							type => 'Select',
							label => 'shared.isolate.classifications.text',
							tags => { label_after => $self->show_popover($c, $classification_list) },
							label_class => 'col-sm-2',
							element_wrapper_class => 'col-sm-10',
							required => 0,
							options => \@classifications,
							element_name => 'isolate_classification[]',
							multiple => 1,
						},
						$antimicrobial_name_list->[0].'_comparator_option' => {
							do_label => 1,
							type => 'Select',
							label => $antimicrobial_name_list->[0],
							tags => { label_after => " ".$c->loc('shared.mgl.text') },
							label_class => 'col-sm-2',
							element_wrapper_class => 'col-sm-10',
							required => 0,
							options => [{value => '=', label => '='},
										{value => 'lt', label => $lt_decoded},
										{value => 'gt', label => $gt_decoded},
										{value => 'le', label => $le_decoded},
										{value => 'ge', label => $ge_decoded}],
							default => $mic_list->[0]->{mic_comparator}
						},
						$antimicrobial_name_list->[1].'_comparator_option' => {
							do_label => 1,
							type => 'Select',
							label => $antimicrobial_name_list->[1],
							tags => { label_after => " ".$c->loc('shared.mgl.text') },
							label_class => 'col-sm-2',
							element_wrapper_class => 'col-sm-10',
							required => 0,
							options => [{value => '=', label => '='},
										{value => 'lt', label => $lt_decoded},
										{value => 'gt', label => $gt_decoded},
										{value => 'le', label => $le_decoded},
										{value => 'ge', label => $ge_decoded}],
							default => $mic_list->[1]->{mic_comparator}
						},
						$antimicrobial_name_list->[2].'_comparator_option' => {
							do_label => 1,
							type => 'Select',
							label => $antimicrobial_name_list->[2],
							tags => { label_after => " ".$c->loc('shared.mgl.text') },
							label_class => 'col-sm-2',
							element_wrapper_class => 'col-sm-10',
							required => 0,
							options => [{value => '=', label => '='},
										{value => 'lt', label => $lt_decoded},
										{value => 'gt', label => $gt_decoded},
										{value => 'le', label => $le_decoded},
										{value => 'ge', label => $ge_decoded}],
							default => $mic_list->[2]->{mic_comparator}
						},
						$antimicrobial_name_list->[3].'_comparator_option' => {
							do_label => 1,
							type => 'Select',
							label => $antimicrobial_name_list->[3],
							tags => { label_after => " ".$c->loc('shared.mgl.text') },
							label_class => 'col-sm-2',
							element_wrapper_class => 'col-sm-10',
							required => 0,
							options => [{value => '=', label => '='},
										{value => 'lt', label => $lt_decoded},
										{value => 'gt', label => $gt_decoded},
										{value => 'le', label => $le_decoded},
										{value => 'ge', label => $ge_decoded}],
							default => $mic_list->[3]->{mic_comparator}
						},
						$antimicrobial_name_list->[4].'_comparator_option' => {
							do_label => 1,
							type => 'Select',
							label => $antimicrobial_name_list->[4],
							tags => { label_after => " ".$c->loc('shared.mgl.text') },
							label_class => 'col-sm-2',
							element_wrapper_class => 'col-sm-10',
							required => 0,
							options => [{value => '=', label => '='},
										{value => 'lt', label => $lt_decoded},
										{value => 'gt', label => $gt_decoded},
										{value => 'le', label => $le_decoded},
										{value => 'ge', label => $ge_decoded}],
							default => $mic_list->[4]->{mic_comparator}
						},
						$antimicrobial_name_list->[5].'_comparator_option' => {
							do_label => 1,
							type => 'Select',
							label => $antimicrobial_name_list->[5],
							tags => { label_after => " ".$c->loc('shared.mgl.text') },
							label_class => 'col-sm-2',
							element_wrapper_class => 'col-sm-10',
							required => 0,
							options => [{value => '=', label => '='},
										{value => 'lt', label => $lt_decoded},
										{value => 'gt', label => $gt_decoded},
										{value => 'le', label => $le_decoded},
										{value => 'ge', label => $ge_decoded}],
							default => $mic_list->[5]->{mic_comparator}
						},
						$antimicrobial_name_list->[6].'_comparator_option' => {
							do_label => 1,
							type => 'Select',
							label => $antimicrobial_name_list->[6],
							tags => { label_after => " ".$c->loc('shared.mgl.text') },
							label_class => 'col-sm-2',
							element_wrapper_class => 'col-sm-10',
							required => 0,
							options => [{value => '=', label => '='},
										{value => 'lt', label => $lt_decoded},
										{value => 'gt', label => $gt_decoded},
										{value => 'le', label => $le_decoded},
										{value => 'ge', label => $ge_decoded}],
							default => $mic_list->[6]->{mic_comparator}
						},
						$antimicrobial_name_list->[7].'_comparator_option' => {
							do_label => 1,
							type => 'Select',
							label => $antimicrobial_name_list->[7],
							tags => { label_after => " ".$c->loc('shared.mgl.text') },
							label_class => 'col-sm-2',
							element_wrapper_class => 'col-sm-10',
							required => 0,
							options => [{value => '=', label => '='},
										{value => 'lt', label => $lt_decoded},
										{value => 'gt', label => $gt_decoded},
										{value => 'le', label => $le_decoded},
										{value => 'ge', label => $ge_decoded}],
							default => $mic_list->[7]->{mic_comparator}
						},

						$antimicrobial_name_list->[0] => {
							do_label => 0,
							type => 'Text',
							element_wrapper_class => 'col-sm-offset-2 col-sm-10',
							required => 0,
							minlength => 1,
							maxlength => 6,
							element_attr => { class=>'input-full'},
							validate_method => \&check_mic
						},
						$antimicrobial_name_list->[1] => {
							do_label => 0,
							type => 'Text',
							element_wrapper_class => 'col-sm-offset-2 col-sm-10',
							size => 3,
							required => 0,
							minlength => 1,
							maxlength => 6,
							element_attr => {class=>'input-full' },
							validate_method => \&check_mic
						},
						$antimicrobial_name_list->[2] => {
							do_label => 0,
							type => 'Text',
							element_wrapper_class => 'col-sm-offset-2 col-sm-10',
							required => 0,
							minlength => 1,
							maxlength => 6,
							element_attr => {class=>'input-full' },
							validate_method => \&check_mic
						},
						$antimicrobial_name_list->[3] => {
							do_label => 0,
							type => 'Text',
							element_wrapper_class => 'col-sm-offset-2 col-sm-10',
							required => 0,
							minlength => 1,
							maxlength => 6,
							element_attr => {class=>'input-full'},
							validate_method => \&check_mic
						},
						$antimicrobial_name_list->[4] => {
							do_label => 0,
							type => 'Text',
							element_wrapper_class => 'col-sm-offset-2 col-sm-10',
							required => 0,
							minlength => 1,
							maxlength => 6,
							element_attr => { class=>'input-full'},
							validate_method => \&check_mic
						},
						$antimicrobial_name_list->[5] => {
							do_label => 0,
							type => 'Text',
							element_wrapper_class => 'col-sm-offset-2 col-sm-10',
							required => 0,
							minlength => 1,
							maxlength => 6,
							element_attr => { class=>'input-full'},
							validate_method => \&check_mic
						},
						$antimicrobial_name_list->[6] => {
							do_label => 0,
							type => 'Text',
							element_wrapper_class => 'col-sm-offset-2 col-sm-10',
							required => 0,
							minlength => 1,
							maxlength => 6,
							element_attr => { class=>'input-full'},
							validate_method => \&check_mic
						},
						$antimicrobial_name_list->[7] => {
							do_label => 0,
							type => 'Text',
							element_wrapper_class => 'col-sm-offset-2 col-sm-10',
							required => 0,
							minlength => 1,
							maxlength => 6,
							element_attr => { class=>'input-full' },
							validate_method => \&check_mic
						},
					]
				);

				$form->process(update_field_list => {
					collection_date => {element_attr => { placeholder => $c->loc("shared.date.format")}},
					csrf => {default => $c->session->{csrf_token} },
				});


				$c->stash(template => 'sequence_type/EditProfileForm.tt2', form => $form, ics => $isolate_classification_codes, antimicrobial_name_list => $antimicrobial_name_list, classification_list => $classification_list, loci_name_list => $loci_name_list, metadata => $metadata, mic_list => $mic_list, page_title=>$EDIT_ST_PAGE_TITLE);

				my $patient_age;


				if($metadata->{patient_age} == 0 || $metadata->{patient_age} eq "" )
				{

					$patient_age = "";

				}
				else
				{

					$patient_age = $metadata->{patient_age};

				}

				my $mic_value_0;
				my $mic_value_1;
				my $mic_value_2;
				my $mic_value_3;
				my $mic_value_4;
				my $mic_value_5;
				my $mic_value_6;
				my $mic_value_7;

				if($mic_list->[0]->{mic_value})
				{

					$mic_value_0 = $mic_list->[0]->{mic_value};

				}

				if($mic_list->[1]->{mic_value})
				{

					$mic_value_1 = $mic_list->[1]->{mic_value};

				}

				if($mic_list->[2]->{mic_value})
				{
					$mic_value_2 = $mic_list->[2]->{mic_value};
				}

				if($mic_list->[3]->{mic_value})
				{

					$mic_value_3 = $mic_list->[3]->{mic_value};

				}

				if($mic_list->[4]->{mic_value})
				{

					$mic_value_4 = $mic_list->[4]->{mic_value};

				}

				if($mic_list->[5]->{mic_value})
				{

					$mic_value_5 = $mic_list->[5]->{mic_value};

				}

				if($mic_list->[6]->{mic_value})
				{

					$mic_value_6 = $mic_list->[6]->{mic_value};

				}

				if($mic_list->[7]->{mic_value})
				{

					$mic_value_7 = $mic_list->[7]->{mic_value};

				}

				my $collection_date_prev = $metadata->{collection_date};

				if(not $collection_date_prev)
				{

					$collection_date_prev = "";

				}


				$form->process(update_field_list => {
					sequence_type => {default => $seq_type_prev},
					allele_type0 => {default => $profile_map_prev->{$loci_name_list->[0]}},
					allele_type1 => {default => int($profile_map_prev->{$loci_name_list->[1]})},
					allele_type2 => {default => int($profile_map_prev->{$loci_name_list->[2]})},
					allele_type3 => {default => int($profile_map_prev->{$loci_name_list->[3]})},
					allele_type4 => {default => int($profile_map_prev->{$loci_name_list->[4]})},
					allele_type5 => {default => int($profile_map_prev->{$loci_name_list->[5]})},
					allele_type6 => {default => int($profile_map_prev->{$loci_name_list->[6]})},
					amr_markers => {default => $metadata->{amr_markers}},
					collection_date => {default => $collection_date_prev},
					country => {default => $metadata->{country}},
					patient_age => {default => $patient_age},
					$antimicrobial_name_list->[0] => {default => $mic_value_0},
					$antimicrobial_name_list->[1] => {default => $mic_value_1},
					$antimicrobial_name_list->[2] => {default => $mic_value_2},
					$antimicrobial_name_list->[3] => {default => $mic_value_3},
					$antimicrobial_name_list->[4] => {default => $mic_value_4},
					$antimicrobial_name_list->[5] => {default => $mic_value_5},
					$antimicrobial_name_list->[6] => {default => $mic_value_6},
					$antimicrobial_name_list->[7] => {default => $mic_value_7},
					epi_data => {default => $metadata->{epi_data}},
					curator_comment => {default => $metadata->{curator_comment}},
					},
					params => $c->request->params
				);

				return unless $form->validated;

				my $seq_type_new = $c->request->params->{sequence_type};

				my $error_code;
				my %profile_map_new;
				my $counter = 0;

				if($seq_type_new !~ /^[0-9]+$/)
				{

					$error_code = $ERROR_INVALID_SEQUENCE_TYPE;

				}

				foreach my $name (@$loci_name_list)
				{

					my $key = "allele_type" . $counter;
					my $value = $c->request->params->{$key};

					if($value !~ /^[0-9]\d*(\.\d{0,3})?$/)
					{

						$error_code = $ERROR_INVALID_ALLELE_TYPE;

					}

					$profile_map_new{$name} = $value;
					$counter ++;

				}

				#to do: validate request parameters
				my $amr_marker_string = $c->request->params->{amr_markers};
				my $collection_date = $c->request->params->{collection_date};
				my $country = $c->request->params->{country};
				$patient_age = $c->request->params->{patient_age};
				my $patient_gender = $c->request->params->{patient_gender};
				my $beta_lactamase = $c->request->params->{beta_lactamase};
				my $classification_code = $c->request->params->{isolate_classification};
				my $epi_data = $c->request->params->{epi_data};
				my $curator_comment = $c->request->params->{curator_comment};
				my $csrf_form_submitted = $c->request->params->{csrf};
				my %mic_map;


				if($csrf_form_submitted and $csrf_form_submitted eq $c->session->{csrf_token})
				{

					if($patient_age eq "" )
					{

						$patient_age = 0;

					}

					my $formatted_classification_code="";

					if($classification_code)
					{
						if(ref($classification_code) eq 'ARRAY')
						{

							foreach my $code (@$classification_code)
							{

								$formatted_classification_code .= $code."/";

							}

						}
						else
						{

							$formatted_classification_code = $classification_code."/";

						}
					}

					foreach my $name (@$antimicrobial_name_list)
					{

						my $comparator_key = $name . "_comparator_option";
						my $value = $c->request->params->{$name};

						if($value eq "")
						{
							$value = 0;
						}

						$mic_map{$name}{mic_comparator} = $c->request->params->{$comparator_key};

						if($c->request->params->{$name} and length $c->request->params->{$name} > 0)
						{
							$mic_map{$name}{mic_value} = $c->request->params->{$name};
						}
						else
						{
							$mic_map{$name}{mic_value} = undef;
						}


					}

					if(defined $error_code)
					{

						$err_msg = $c->loc($ERROR_BASE_STRING.$error_code);
						$c->stash(error_id => $error_code, error_code => $err_msg);


					}
					else
					{

						$c->session->{csrf_token} = Session::Token->new(length => 128)->get;

						$obj = $c->model('EditSequenceTypeProfile');
						$result = $obj->_edit_profile($seq_type_prev, $seq_type_new, $profile_map_prev, \%profile_map_new, $country, $patient_age, $collection_date, $patient_gender, $epi_data, $curator_comment, $beta_lactamase, $formatted_classification_code, \%mic_map, $amr_marker_string);

						if($result eq $VALID_CONST)
						{

							$c->flash(edit_notification => $NOTIFICATION_ON);
							$c->response->redirect($c->uri_for($self->action_for('list_profiles')));

						}
						elsif($result eq $ERROR_NONEXISTANT_ALLELE)
						{

							$obj = $c->model('GetAlleleInfo');
							my $nonexistant_alleles = $obj->_get_non_existant_alleles(\%profile_map_new);
							my $error_string;

							$obj = $c->model('GetIntegerType');
							my $loci_int_type_set = $obj->_get_loci_with_integer_type();

							if(($nonexistant_alleles) and (@$nonexistant_alleles))
							{

								foreach my $allele(@$nonexistant_alleles)
								{

									if((%$loci_int_type_set) and (exists $loci_int_type_set->{$allele->{loci_name}}))
									{

										$error_string = $error_string.$allele->{loci_name}." ".$allele->{allele_type}."<br>";

									}
									else
									{

										$error_string = $error_string.$allele->{loci_name}." ".sprintf ("%.3f", $allele->{allele_type})."<br>";

									}

								}

								$c->flash(edit_notification => $NOTIFICATION_OFF);

								$err_msg = $c->loc($ERROR_BASE_STRING.$result);
								$err_msg =  named_sprintf($err_msg, { error_alleles => $error_string });
								$c->stash(error_id => $result, error_code => $err_msg );


							}

						}
						else
						{

							$c->flash(edit_notification => $NOTIFICATION_OFF);

							$err_msg = $c->loc($ERROR_BASE_STRING.$result);
							$c->stash(error_id => $result, error_code => $err_msg );


						}

					}

				}
				else
				{

					$c->response->redirect($c->uri_for($self->action_for('edit'), $seq_type_prev));

				}

			}
			else
			{

				$err_msg = $c->loc($ERROR_BASE_STRING.$ERROR_CODE_PROFILE_NO_DATA);
				$c->stash(error_id => $ERROR_CODE_PROFILE_NO_DATA, error_code => $err_msg);

			}

		}
		else
		{

			$c->stash(template => 'error/access_denied_admin.tt2', page_title=>$ERROR_LOGIN_REQ_PAGE_TITLE);

		}

	}
	else
	{

		$c->stash(template => 'error/error_404.tt2', page_title=>$ERROR_404_PAGE_TITLE);

	}

}

sub email_sequence_type_process :Local :Args()
{
	my ($self, $c, $allele_type_str) = @_;

	my $profile_allele_types;

	if(not $allele_type_str)
	{

		$profile_allele_types = $c->request->params->{allele_type_str};
	}
	else
	{
		$profile_allele_types = $allele_type_str;
	}
	$c->flash->{profile_allele_types} = $profile_allele_types;

	$c->response->redirect($c->uri_for($self->action_for('email_sequence_type')));

}

sub email_sequence_type :Local :Args()
{

	my ($self, $c) = @_;

	my $obj = $c->model('GetAlleleInfo');
	my $loci_name_list = $obj->_get_all_loci_names();


	$obj = $c->model('GetMetadata');
	my $classification_list = $obj->_get_all_isolate_classifications();
	my $antimicrobial_name_list = $obj->_get_mic_antimicrobial_names();

	$obj = $c->model('GetError');
	my $err_msg;

	if(not $loci_name_list)
	{

		$err_msg = $c->loc($ERROR_BASE_STRING.$loci_name_list);
		$c->stash(error_id => $loci_name_list, error_code => $err_msg);

	}
	elsif(not $classification_list)
	{

		$err_msg = $c->loc($ERROR_BASE_STRING.$classification_list);
		$c->stash(error_id => $classification_list, error_code => $err_msg);

	}
	elsif(not $antimicrobial_name_list)
	{

		$err_msg = $c->loc($ERROR_BASE_STRING.$antimicrobial_name_list);
		$c->stash(error_id => $antimicrobial_name_list, error_code => $err_msg);

	}
	else
	{
		my $logged_on_username;
		my $logged_on_user;

		if($c->user_exists() and $c->check_any_user_role(qw/ user admin /))
		{
			my $user_id = $c->user->get('id');

			$obj = $c->model('GetUserInfo');
			$logged_on_username = $obj->_get_current_username_by_user_id($user_id);

			$logged_on_user =  $obj->_get_user_details_by_username($logged_on_username);

		}

		my @classification_codes;

		foreach my $classification_in_list (@$classification_list)
		{
			push @classification_codes ,$classification_in_list->{classification_code};
		}
		my @classifications = map { $_, $_ } @classification_codes;

		my @locis = map { $_, $_ } @{$loci_name_list};

		my $ge = "&ge;";
		my $le = "&le;";
		my $gt = "&gt;";
		my $lt = "&lt;";

		my $ge_decoded = decode_entities($ge);
		my $le_decoded = decode_entities($le);
		my $gt_decoded = decode_entities($gt);
		my $lt_decoded = decode_entities($lt);

		my $curr_lang = $c->session->{lang};
		my $lh = NGSTAR::I18N::i_default->new;

		if($c->session->{lang})
		{
			if($c->session->{lang} eq $TRANSLATION_LANG)
			{
				$lh = NGSTAR::I18N::fr->new;
			}
		}


		#add some additional fields to the form that is not already defined in EmailAlleleForm
		my $form = NGSTAR::Form::EmailProfileForm->new(
			language_handle => $lh,
			field_list => [
				'patient_gender' => {
					do_label => 1,
					type => 'Select',
					label => 'shared.patient.gender.text',
					label_class => 'col-sm-2',
					element_wrapper_class => 'col-sm-10',
					required => 0,
					options => [{value => 'U', label => $c->loc('shared.unknown.text')},
								{value => 'F', label => $c->loc('shared.female.text')},
								{value => 'M', label => $c->loc('shared.male.text') }],
					default => 'U'
				},
				'beta_lactamase' => {
					do_label => 1,
					type => 'Select',
					label => 'shared.beta.lactamase.text',
					label_class => 'col-sm-2',
					element_wrapper_class => 'col-sm-10',
					required => 0,
					options => [{value => 'Unknown', label => $c->loc('shared.unknown.text')},
								{value => 'Positive', label => $c->loc('shared.positive.text')},
								{value => 'Negative', label => $c->loc('shared.negative.text') }],
					default => 'Unknown'

				},
				'isolate_classification' => {
					do_label => 1,
					type => 'Select',
					label => 'shared.isolate.classifications.text',
					tags => { label_after => $self->show_popover($c, $classification_list) },
					label_class => 'col-sm-2',
					element_wrapper_class => 'col-sm-10',
					required => 0,
					options => \@classifications,
					element_name => 'isolate_classification[]',
					multiple => 1,
				},
				$antimicrobial_name_list->[0].'_comparator_option' => {
					do_label => 1,
					type => 'Select',
					label => $antimicrobial_name_list->[0],
					tags => { label_after => " ".$c->loc('shared.mgl.text') },
					label_class => 'col-sm-2',
					element_wrapper_class => 'col-sm-10',
					required => 0,
					options => [{value => '=', label => '='},
								{value => 'lt', label => $lt_decoded},
								{value => 'gt', label => $gt_decoded},
								{value => 'le', label => $le_decoded},
								{value => 'ge', label => $ge_decoded}],
					default => '='
				},
				$antimicrobial_name_list->[1].'_comparator_option' => {
					do_label => 1,
					type => 'Select',
					label => $antimicrobial_name_list->[1],
					tags => { label_after => " ".$c->loc('shared.mgl.text') },
					label_class => 'col-sm-2',
					element_wrapper_class => 'col-sm-10',
					required => 0,
					options => [{value => '=', label => '='},
								{value => 'lt', label => $lt_decoded},
								{value => 'gt', label => $gt_decoded},
								{value => 'le', label => $le_decoded},
								{value => 'ge', label => $ge_decoded}],
					default => '='
				},
				$antimicrobial_name_list->[2].'_comparator_option' => {
					do_label => 1,
					type => 'Select',
					label => $antimicrobial_name_list->[2],
					tags => { label_after => " ".$c->loc('shared.mgl.text') },
					label_class => 'col-sm-2',
					element_wrapper_class => 'col-sm-10',
					size => 3,
					required => 0,
					options => [{value => '=', label => '='},
								{value => 'lt', label => $lt_decoded},
								{value => 'gt', label => $gt_decoded},
								{value => 'le', label => $le_decoded},
								{value => 'ge', label => $ge_decoded}],
					default => '='
				},
				$antimicrobial_name_list->[3].'_comparator_option' => {
					do_label => 1,
					type => 'Select',
					label => $antimicrobial_name_list->[3],
					tags => { label_after => " ".$c->loc('shared.mgl.text') },
					label_class => 'col-sm-2',
					element_wrapper_class => 'col-sm-10',
					required => 0,
					options => [{value => '=', label => '='},
								{value => 'lt', label => $lt_decoded},
								{value => 'gt', label => $gt_decoded},
								{value => 'le', label => $le_decoded},
								{value => 'ge', label => $ge_decoded}],
					default => '='
				},
				$antimicrobial_name_list->[4].'_comparator_option' => {
					do_label => 1,
					type => 'Select',
					label => $antimicrobial_name_list->[4],
					tags => { label_after => " ".$c->loc('shared.mgl.text') },
					label_class => 'col-sm-2',
					element_wrapper_class => 'col-sm-10',
					required => 0,
					options => [{value => '=', label => '='},
								{value => 'lt', label => $lt_decoded},
								{value => 'gt', label => $gt_decoded},
								{value => 'le', label => $le_decoded},
								{value => 'ge', label => $ge_decoded}],
					default => '='
				},
				$antimicrobial_name_list->[5].'_comparator_option' => {
					do_label => 1,
					type => 'Select',
					label => $antimicrobial_name_list->[5],
					tags => { label_after => " ".$c->loc('shared.mgl.text') },
					label_class => 'col-sm-2',
					element_wrapper_class => 'col-sm-10',
					required => 0,
					options => [{value => '=', label => '='},
								{value => 'lt', label => $lt_decoded},
								{value => 'gt', label => $gt_decoded},
								{value => 'le', label => $le_decoded},
								{value => 'ge', label => $ge_decoded}],
					default => '='
				},
				$antimicrobial_name_list->[6].'_comparator_option' => {
					do_label => 1,
					type => 'Select',
					label => $antimicrobial_name_list->[6],
					tags => { label_after => " ".$c->loc('shared.mgl.text') },
					label_class => 'col-sm-2',
					element_wrapper_class => 'col-sm-10',
					required => 0,
					options => [{value => '=', label => '='},
								{value => 'lt', label => $lt_decoded},
								{value => 'gt', label => $gt_decoded},
								{value => 'le', label => $le_decoded},
								{value => 'ge', label => $ge_decoded}],
					default => '='
				},
				$antimicrobial_name_list->[7].'_comparator_option' => {
					do_label => 1,
					type => 'Select',
					label => $antimicrobial_name_list->[7],
					tags => { label_after => " ".$c->loc('shared.mgl.text') },
					label_class => 'col-sm-2',
					element_wrapper_class => 'col-sm-10',
					required => 0,
					options => [{value => '=', label => '='},
								{value => 'lt', label => $lt_decoded},
								{value => 'gt', label => $gt_decoded},
								{value => 'le', label => $le_decoded},
								{value => 'ge', label => $ge_decoded}],
					default => '='
				},
				$antimicrobial_name_list->[0] => {
					do_label => 0,
					type => 'Text',
					element_wrapper_class => 'col-sm-offset-2 col-sm-10',
					required => 0,
					minlength => 1,
					maxlength => 6,
					element_attr => {class=>'input-full'},
					validate_method => \&check_mic
				},
				$antimicrobial_name_list->[1] => {
					do_label => 0,
					type => 'Text',
					element_wrapper_class => 'col-sm-offset-2 col-sm-10',
					required => 0,
					minlength => 1,
					maxlength => 6,
					element_attr => { class=>'input-full' },
					validate_method => \&check_mic
				},
				$antimicrobial_name_list->[2] => {
					do_label => 0,
					type => 'Text',
					element_wrapper_class => 'col-sm-offset-2 col-sm-10',
					required => 0,
					minlength => 1,
					maxlength => 6,
					element_attr => {class=>'input-full'},
					validate_method => \&check_mic
				},
				$antimicrobial_name_list->[3] => {
					do_label => 0,
					type => 'Text',
					element_wrapper_class => 'col-sm-offset-2 col-sm-10',
					required => 0,
					minlength => 1,
					maxlength => 6,
					element_attr => {class=>'input-full' },
					validate_method => \&check_mic
				},
				$antimicrobial_name_list->[4] => {
					do_label => 0,
					type => 'Text',
					element_wrapper_class => 'col-sm-offset-2 col-sm-10',
					required => 0,
					minlength => 1,
					maxlength => 6,
					element_attr => {class=>'input-full'},
					validate_method => \&check_mic
				},
				$antimicrobial_name_list->[5] => {
					do_label => 0,
					type => 'Text',
					element_wrapper_class => 'col-sm-offset-2 col-sm-10',
					required => 0,
					minlength => 1,
					maxlength => 6,
					element_attr => {class=>'input-full'},
					validate_method => \&check_mic
				},
				$antimicrobial_name_list->[6] => {
					do_label => 0,
					type => 'Text',
					element_wrapper_class => 'col-sm-offset-2 col-sm-10',
					required => 0,
					minlength => 1,
					maxlength => 6,
					element_attr => {class=>'input-full'},
					validate_method => \&check_mic
				},
				$antimicrobial_name_list->[7] => {
					do_label => 0,
					type => 'Text',
					element_wrapper_class => 'col-sm-offset-2 col-sm-10',
					required => 0,
					minlength => 1,
					maxlength => 6,
					element_attr => {class=>'input-full' },
					validate_method => \&check_mic
				},

			],
		ctx => $c,
		);

		$form->process(update_field_list => {
			first_name => {messages => {required => $c->loc('shared.enter.first.name.msg')}},
			last_name => {messages => {required => $c->loc('shared.enter.last.name.msg')}},
			institution_name => {messages => {required => $c->loc('shared.enter.ins.name.msg')}},
			institution_city => {messages => {required => $c->loc('shared.enter.ins.city.msg')}},
			institution_country => {messages => {required => $c->loc('shared.enter.ins.country.msg')}},
			email_address => {messages => {required => $c->loc('shared.enter.email.address.msg')}},
			allele_type0 => {messages => {required => $c->loc('shared.enter.allele.type.form.error.msg')}},
			allele_type1 => {messages => {required => $c->loc('shared.enter.allele.type.form.error.msg')}},
			allele_type2 => {messages => {required => $c->loc('shared.enter.allele.type.form.error.msg')}},
			allele_type3 => {messages => {required => $c->loc('shared.enter.allele.type.form.error.msg')}},
			allele_type4 => {messages => {required => $c->loc('shared.enter.allele.type.form.error.msg')}},
			allele_type5 => {messages => {required => $c->loc('shared.enter.allele.type.form.error.msg')}},
			allele_type6 => {messages => {required => $c->loc('shared.enter.allele.type.form.error.msg')}},
			collection_date => {element_attr => { placeholder => $c->loc("shared.date.format")}},
			csrf => {default => $c->session->{csrf_token} },
		});

		$c->stash(template => 'sequence_type/EmailProfileForm.tt2', form => $form, antimicrobial_name_list => $antimicrobial_name_list, classification_list => $classification_list, loci_name_list => $loci_name_list, page_title=>$EMAIL_ST_PAGE_TITLE);

		if($c->user_exists() and $c->check_any_user_role(qw/ user admin /))
		{
			my $fname = $logged_on_user->[0]->{first_name};
			my $lname = $logged_on_user->[0]->{last_name};
			my $email = $logged_on_user->[0]->{email_address};
			my $ins_name = $logged_on_user->[0]->{institution_name};
			my $ins_city = $logged_on_user->[0]->{institution_city};
			my $ins_country = $logged_on_user->[0]->{institution_country};

			$form->process(update_field_list => {
				first_name => {default => $fname},
				last_name => {default => $lname},
				email_address => {default => $email},
				institution_name => {default => $ins_name},
				institution_country => {default => $ins_country},
				institution_city => {default => $ins_city},
			});
		}

		my @separated_allele_types;
		my $allele_type_str = $c->flash->{profile_allele_types};

		if($allele_type_str)
		{
			@separated_allele_types = split("," , $allele_type_str);
		}

		$form->process(update_field_list => {
			allele_type0 => {default => $separated_allele_types[0]},
			allele_type1 => {default => $separated_allele_types[1]},
			allele_type2 => {default => $separated_allele_types[2]},
			allele_type3 => {default => $separated_allele_types[3]},
			allele_type4 => {default => $separated_allele_types[4]},
			allele_type5 => {default => $separated_allele_types[5]},
			allele_type6 => {default => $separated_allele_types[6]},
		});

		$form->process(params => $c->request->params);
		return unless $form->validated;


		my $first_name = $c->request->params->{first_name};
		my $last_name = $c->request->params->{last_name};
		my $email_address = $c->request->params->{email_address};
		my $institution_name = $c->request->params->{institution_name};
		my $institution_country = $c->request->params->{institution_country};
		my $institution_city = $c->request->params->{institution_city};
		my $comments = $c->request->params->{comments};

		my $allele_types;

		#get meta-data
		#to do: validate request parameters
		my $collection_date = $c->request->params->{collection_date};
		my $country = $c->request->params->{country};
		my $patient_age = $c->request->params->{patient_age};
		my $patient_gender = $c->request->params->{patient_gender};
		my $beta_lactamase = $c->request->params->{beta_lactamase};
		my $classification_code = $c->request->params->{isolate_classification};
		my $epi_data = $c->request->params->{epi_data};
		my $csrf_form_submitted = $c->request->params->{csrf};

		my $upload = $c->request->upload('trace_file');
		my $err_msg;

		if($csrf_form_submitted and $csrf_form_submitted eq $c->session->{csrf_token})
		{

			my @allele_types;
			my $error_code;
			my $has_error = $FALSE;


			for( my $i = 0; $i < $NUM_SEQUENCES; $i ++)
			{

				my $key = "allele_type".$i;
				my $allele_type = $c->request->params->{$key};

				if($allele_type !~ /^[0-9]\d*(\.\d{0,3})?$/)
				{

					$error_code = $ERROR_INVALID_ALLELE_TYPES;
					$has_error = $TRUE;
				}
				else
				{

					push @allele_types, $allele_type;

				}

			}

			if($upload)
			{
				my $filename = $upload->filename;
				my $filesize = $upload->size;

				#file size should not be any greater than 5.34 MB
				#this file size limit should be good enough to support
				#a fasta file with ~2000 alleles
				if($filesize > $MAX_FILE_SIZE)
				{

					$has_error = $TRUE;
					$error_code = $ERROR_FILE_SIZE_TOO_LARGE;

				}

				if($filesize <= $MIN_FILE_SIZE)
				{

					$has_error = $TRUE;
					$error_code = $ERROR_FILE_SIZE_TOO_SMALL;

				}

				#check that the filename is the correct format
				if($filename !~ /^[\w\-\_]+(\.trace)|(\.txt)$/i)
				{

					$has_error = $TRUE;
					$error_code = $ERROR_INVALID_TRACE_FILENAME;

				}
			}

			if($has_error)
			{
				$err_msg = $c->loc($ERROR_BASE_STRING.$error_code);
				$c->stash(error_id => $error_code, error_code => $err_msg);
			}
			else
			{
				my %mic_map;

				my $formatted_classification_code="";

				if($classification_code)
				{

					if(ref($classification_code) eq 'ARRAY')
					{

						foreach my $code (@$classification_code)
						{

							$formatted_classification_code .= $code."/";

						}

					}
					else
					{

						$formatted_classification_code = $classification_code."/";

					}

				}

				foreach my $name (@$antimicrobial_name_list)
				{

					my $comparator_key = $name . "_comparator_option";
					$mic_map{$name}{mic_comparator} = $c->request->params->{$comparator_key};
					$c->log->debug('\ncomparator: ' . $mic_map{$name}{mic_comparator});
					$mic_map{$name}{mic_value} = $c->request->params->{$name};

				}


				$obj = $c->model('ValidateEmailForm');

				my $validate_result = $obj->_validate_new_profile_email_form($first_name, $last_name, $email_address, $institution_name, $institution_country, $institution_city, $comments, \@allele_types, $country, $patient_age, $patient_gender, $epi_data, $beta_lactamase, $formatted_classification_code, \%mic_map, $collection_date);

				if($validate_result)
				{

					$c->session->{csrf_token} = Session::Token->new(length => 128)->get;

					$self->send_email($c, $first_name, $last_name, $email_address, $institution_name, $institution_country, $institution_city, $comments, \@allele_types, $country, $patient_age, $patient_gender, $epi_data, $beta_lactamase, $formatted_classification_code, \%mic_map, $collection_date, $antimicrobial_name_list, $upload, $loci_name_list);

					$c->flash(sent_profile_email_notification => $NOTIFICATION_ON);
					$c->response->redirect($c->uri_for($self->action_for('email_sequence_type')));

				}
				else
				{

					$err_msg = $c->loc($ERROR_BASE_STRING.$validate_result);
					$c->stash(error_id => $validate_result, error_code => $err_msg);

				}

			}

		}
		else
		{

			$c->response->redirect($c->uri_for($self->action_for('email_sequence_type')));

		}

	}

}

sub export_profiles
{

	my ($self, $c, $contents, $format_option) = @_;

	$c->log->debug('*** INSIDE export_profiles METHOD ***');


	my $filename = "ngstar_profiles.txt";
	my $obj = $c->model('GetAlleleInfo');
	my $loci_names = $obj->_get_all_loci_names;
	my $loci_count = $obj->_get_loci_name_count;


	if($format_option eq $FORMAT_CODE_COMMA)
	{
		$format_option = ",";
	}
	else
	{
		$format_option = "\t";
	}

	my $profile_order = "st".$format_option;
	my $count = 0;

	foreach my $loci_name(@$loci_names)
	{
		if($count < ($loci_count - 1))
		{
			$profile_order = $profile_order.$loci_name.$format_option;
		}
		else
		{
			$profile_order = $profile_order.$loci_name;
		}
		$count ++;
	}

	$profile_order = $profile_order."\n";
	$contents = $profile_order.$contents;

	$c->response->content_type('text/plain');
	$c->response->header('Content-Disposition', qq[attachment; filename="$filename"]);
	$c->response->body($contents);

}

sub export_profile_query_results :Local :Args()
{
	my ($self, $c) = @_;

	my $str = $c->request->params->{csv_str};

	if(not $str)
	{
		$str = $c->request->params->{tsv_str};

	}

	my $filename = "batch_profile_query_results.txt";
	$c->response->content_type('text/plain');
	$c->response->header('Content-Disposition', qq[attachment; filename="$filename"]);
	$c->response->body($str);
}


sub export_profile_metadata
{

	my ($self, $c, $contents) = @_;

	$c->log->debug('*** INSIDE export_profile_metadata METHOD ***');


	my $filename = "ngstar_profile_metadata.txt";

	$c->response->content_type('text/plain');
	$c->response->header('Content-Disposition', qq[attachment; filename="$filename"]);
	$c->response->body($contents);

}

sub form :Local
{

	my ($self, $c) = @_;

	$c->log->debug('*** INSIDE form METHOD ***');

	return $self->form_process($c);

}

sub form_process
{

	my ($self, $c) = @_;

	$c->log->debug('*** INSIDE form_process METHOD ***');


	my $search_option = "Exact or nearest match",
	my $max_results = 10;

	my $obj = $c->model('GetAlleleInfo');
	my $result = $obj->_get_all_loci_names;
	my $err_msg;

	if(not $result)
	{

		$err_msg = $c->loc($ERROR_BASE_STRING.$ERROR_CODE_NO_LOCIS);
		$c->stash(error_id => $ERROR_CODE_NO_LOCIS, error_code => $err_msg);

	}
	else
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


		my $form = NGSTAR::Form::SequenceTypeForm->new(language_handle => $lh, ctx => $c);

		$form->process(update_field_list => {
			allele_type0 => {messages => {required => $c->loc('shared.enter.allele.type.form.error.msg')}},
			allele_type1 => {messages => {required => $c->loc('shared.enter.allele.type.form.error.msg')}},
			allele_type2 => {messages => {required => $c->loc('shared.enter.allele.type.form.error.msg')}},
			allele_type3 => {messages => {required => $c->loc('shared.enter.allele.type.form.error.msg')}},
			allele_type4 => {messages => {required => $c->loc('shared.enter.allele.type.form.error.msg')}},
			allele_type5 => {messages => {required => $c->loc('shared.enter.allele.type.form.error.msg')}},
			allele_type6 => {messages => {required => $c->loc('shared.enter.allele.type.form.error.msg')}},
			csrf => {default => $c->session->{csrf_token} },
		});

		$c->stash(template => 'sequence_type/SequenceTypeForm.tt2', form => $form, name_list => $result, page_title=>$ST_QUERY_PAGE_TITLE);

		$form->process(params => $c->request->params);
		return unless $form->validated;

		my $csrf_form_submitted = $c->request->params->{csrf};


		if($csrf_form_submitted and $csrf_form_submitted eq $c->session->{csrf_token})
		{

			$c->session->{csrf_token} = Session::Token->new(length => 128)->get;

			$obj = $c->model('GetSequenceTypeInfo');
			my $profile_count = $obj->_get_profile_list_length;

			if($profile_count > 0)
			{
				#flash is used to pass on values to redirect
				$c->flash(form_data => $form->value, search_option => $search_option);

				$c->response->redirect($c->uri_for($self->action_for('form_process_option'), $PROFILE_QUERY_MANUAL, $max_results));
			}
			else
			{
				$err_msg = $c->loc($ERROR_BASE_STRING.$ERROR_NO_PROFILES);
				$c->stash(error_id => $ERROR_NO_PROFILES, error_code => $err_msg);
			}

		}
		else
		{

			$c->response->redirect($c->uri_for($self->action_for('form')));

		}

	}

}

#option 0 is for allelic profile query after a multiple locus query, option 1 is for a separate allelic profile query
sub form_process_option :Local :Args(2)
{

	my ($self, $c, $option, $max_results) = @_;

	$c->log->debug('*** INSIDE form_process_option METHOD ***');

	my $obj;
	my $err_msg;

	if($option and ((lc($option) eq lc($PROFILE_QUERY_AUTO)) or (lc($option) eq lc($PROFILE_QUERY_MANUAL))))
	{

		$obj = $c->model('GetAlleleInfo');
		my $name_list = $obj->_get_all_loci_names;



		if(not $name_list)
		{

			$err_msg = $c->loc($ERROR_BASE_STRING.$ERROR_CODE_NO_LOCIS);
			$c->stash(error_id => $ERROR_CODE_NO_LOCIS, error_code => $err_msg);

		}
		else
		{

			my $allele_type;
			my %allele_type_map;
			my $form_data;
			my $num_allele_results = 0;

			my $error_code;



			if(lc($option) eq lc($PROFILE_QUERY_AUTO))
			{

				$num_allele_results = $c->request->params->{size};

				if($num_allele_results !~ /^(\d+)$/)
				{

					$error_code = $ERROR_CODE_INVALID_SIZE;
				}

			}

			if(lc($option) eq lc($PROFILE_QUERY_MANUAL))
			{

				$form_data = $c->flash->{form_data};
				$num_allele_results = scalar @{$name_list};

			}

			for(my $i = 0; $i < $num_allele_results; $i ++)
			{

				my $type_key = "allele_type".$i;

				if(lc($option) eq lc($PROFILE_QUERY_AUTO))
				{

					my $name_key = "allele_name".$i;
					my $name = $c->request->params->{$name_key};
					$allele_type = $c->request->params->{$type_key};

					my $loci_name_exists = $FALSE;

					foreach my $loci_in_list (@$name_list)
					{
						if(lc($loci_in_list) eq lc($name))
						{
							$loci_name_exists = $TRUE;
						}
					}

					if(not $loci_name_exists)
					{

						$error_code = $ERROR_INVALID_LOCI_NAME;

					}
					elsif($allele_type !~ /^[0-9]\d*(\.\d{0,3})?$/)
					{

						$error_code = $ERROR_INVALID_ALLELE_TYPE;

					}

					$allele_type_map{$name} = $allele_type;

				}
				if(lc($option) eq lc($PROFILE_QUERY_MANUAL))
				{

					my $name_key = $name_list->[$i];
					$allele_type = $form_data->{$type_key};

					if($allele_type !~ /^[0-9]\d*(\.\d{0,3})?$/)
					{

						$error_code = $ERROR_INVALID_ALLELE_TYPE;

					}

					$allele_type_map{$name_key} = $allele_type;

				}

			}

			if(lc($option) eq lc($PROFILE_QUERY_AUTO))
			{

				foreach my $name (@$name_list)
				{

					my $key = "allele_option_".$name;
					#get the allele type
					my $allele_option = $c->request->params->{$key};

					if((defined $allele_option) and ($allele_option ne ""))
					{

						if($allele_option !~ /^[0-9]\d*(\.\d{0,3})?$/)
						{

							$error_code = $ERROR_INVALID_ALLELE_TYPE;

						}

						$allele_type_map{$name} = $allele_option;

					}

				}

			}

			my $match_threshold;
			my $search_option;


			if(lc($option) eq lc($PROFILE_QUERY_AUTO))
			{

				$c->log->debug("selection is: Exact or nearest match");
				$search_option = "Exact or nearest match";

			}

			if(lc($option) eq lc($PROFILE_QUERY_MANUAL))
			{

				$c->log->debug("selection is: Exact or nearest match");
				$search_option = $c->flash->{search_option};

			}

			if((not $search_option) or ($search_option !~ /^[(A-Z)|(\d+)|(\s)]+$/i))
			{

				$error_code = $ERROR_CODE_INVALID_QUERY_OPTION;

			}

			if(defined $error_code)
			{

				$err_msg = $c->loc($ERROR_BASE_STRING.$error_code);
				$c->stash(error_id => $error_code, error_code => $err_msg);

			}
			else
			{

				$match_threshold = 0;



				$c->log->debug("match threshold is: ".$match_threshold);
				$self->get_st_profile($c, \%allele_type_map, $match_threshold, $name_list, $max_results);

			}

		}

	}
	else
	{

		$err_msg = $c->loc($ERROR_BASE_STRING.$ERROR_CODE_INVALID_QUERY_OPTION);
		$c->stash(error_id => $ERROR_CODE_INVALID_QUERY_OPTION, error_code => $err_msg);

	}

}

sub get_st_profile
{

	my ($self, $c, $allele_type_map, $match_threshold, $name_list, $max_results, $is_curator_query) = @_;

	$c->log->debug('*** INSIDE get_st_profile METHOD ***');

	my $obj = $c->model('GetSequenceTypeInfo');
	my $length = $obj->_get_profile_list_length();
	my $err_msg;
	my @metadata_list;
	my $metadata;

	if($length > 0)
	{

		$obj = $c->model('GetSequenceType');
		my $result = $obj->_get_profile_query($allele_type_map, $match_threshold, $max_results);

		if(not $result)
		{

			$err_msg = $c->loc($ERROR_BASE_STRING.$ERROR_CODE_NO_PROFILES_RETURNED);
			$c->stash(error_id => $ERROR_CODE_NO_PROFILES_RETURNED, error_code => $err_msg);

		}
		else
		{

			foreach my $profile(@$result)
			{

				$obj = $c->model('GetMetadata');
				$metadata = $obj->_get_metadata($profile->{type});
				push @metadata_list, $metadata;

			}

			$obj = $c->model('GetAlleleInfo');
			my $nonexistant_allele_list = $obj->_get_non_existant_alleles($allele_type_map);

			$c->flash(st_profile_list => $result, metadata_list => \@metadata_list, allele_type_map => $allele_type_map, name_list => $name_list, num_sequences => $NUM_SEQUENCES, nonexistant_allele_list => $nonexistant_allele_list, is_curator_query => $is_curator_query);
			$c->response->redirect($c->uri_for($self->action_for('display_sequence_type')));

		}

	}
	else
	{

		$c->stash(template => 'sequence_type/ListProfiles.tt2', error => $ERROR_NO_PROFILES, page_title=>$ST_LIST_PAGE_TITLE);

	}

}

sub list_profiles :Local
{

	my ($self, $c) = @_;
	$c->log->debug('*** INSIDE list_profiles METHOD ***');

	my $obj = $c->model('GetAlleleInfo');
	my $name_list = $obj->_get_all_loci_names();

	$obj = $c->model('GetSequenceTypeInfo');
	my $length = $obj->_get_profile_list_length();

	my $st_profile_list;
	my @metadata_list;
	my $metadata;
	my $err_msg;

	if($length > 0)
	{

	   $st_profile_list = $obj->_get_profile_list();

		foreach my $profile (@$st_profile_list)
		{

			$obj = $c->model('GetMetadata');
			$metadata = $obj->_get_metadata($profile->{type});
			push @metadata_list, $metadata;

		}

		if(not $st_profile_list)
		{

			$err_msg = $c->loc($ERROR_BASE_STRING.$ERROR_CODE_NO_PROFILES_RETURNED);
			$c->stash(error_id => $ERROR_CODE_NO_PROFILES_RETURNED, error_code => $err_msg);

		}
		elsif(not $name_list)
		{

			$err_msg = $c->loc($ERROR_BASE_STRING.$ERROR_CODE_NO_LOCIS);
			$c->stash(error_id => $ERROR_CODE_NO_LOCIS, error_code => $err_msg);

		}
		else
		{

			$obj = $c->model('GetIntegerType');
			my $loci_int_type_set = $obj->_get_loci_with_integer_type();

			$c->stash(template => 'sequence_type/ListProfiles.tt2', name_list => $name_list, st_profile_list => $st_profile_list, loci_int_type_set => $loci_int_type_set, metadata_list => \@metadata_list, page_title=>$ST_LIST_PAGE_TITLE );

		}

	}
	else
	{

		$c->stash(template => 'sequence_type/ListProfiles.tt2', error => $ERROR_NO_PROFILES, page_title=>$ST_LIST_PAGE_TITLE);

	}

}

sub send_email
{

	my ($self, $c, $first_name, $last_name, $email_address, $institution_name, $institution_country, $institution_city, $comments, $allele_types, $country, $patient_age, $patient_gender, $epi_data, $beta_lactamase, $classification_code, $mic_map, $collection_date, $antimicrobial_name_list, $trace_file, $loci_name_list) = @_;

	my $curator_email_address = $c->config->{curator_email};

	my $mics = "";

	if(scalar keys %$mic_map > 0)
	{

		foreach my $name (@$antimicrobial_name_list)
		{

			my $mic_comparator = $mic_map->{$name}{mic_comparator};
			my $mic_value = $mic_map->{$name}{mic_value};

			if($mic_comparator)
			{
				if ($mic_comparator eq $MIC_COMPARATOR_EQUALS and $mic_value eq "")
				{
					$mics .= "";
				}
				elsif ($mic_comparator eq $MIC_COMPARATOR_EQUALS)
				{

					$mics .= $name.": = ".$mic_value ."\n";

				}
				elsif($mic_comparator eq $MIC_COMPARATOR_LESS_THAN_OR_EQUALS)
				{

					$mics .= $name.": <= ".$mic_value ."\n";

				}
				elsif($mic_comparator eq $MIC_COMPARATOR_GREATER_THAN_OR_EQUALS)
				{

					$mics .= $name.": >= ".$mic_value ."\n";

				}
				elsif($mic_comparator eq $MIC_COMPARATOR_GREATER_THAN)
				{

					$mics .= $name.": > ".$mic_value ."\n";

				}
				elsif($mic_comparator eq $MIC_COMPARATOR_LESS_THAN)
				{

					$mics .= $name.": < ".$mic_value ."\n";

				}
				else
				{

					$mics .= $name."\n";

				}

			}

		}

	}


	my $allele_type_list="";
	my $count = 0;

	foreach my $loci_name(@$loci_name_list)
	{

		$allele_type_list .= $loci_name.": ".@$allele_types[$count]."\n";
		$count++;

	}

	if($trace_file)
	{

		$c->model('CuratorEmail')->send(
			from => $curator_email_address,
			to => $curator_email_address,
			subject => 'New Profile',
			attachment => [$trace_file->tempname, $trace_file->filename], #tempname is a built in field from request upload object and it is what is required for adding the attachment to the email
			plaintext => "First Name: ".$first_name."\n\nLast Name: ".$last_name."\n\nEmail Address: ".$email_address
			."\n\nInstitution Name: ".$institution_name."\n\nInstitution Country: ".$institution_country
			."\n\nInstitution City: ".$institution_city."\n\nComments: ".$comments."\n\nAllele Types:\n".$allele_type_list
			."\nCollection Date: ".$collection_date
			."\n\nCountry: ".$country."\n\nPatient Age: ".$patient_age
			."\n\nPatient_gender: ".$patient_gender."\n\nEpidemiological Data: ".$epi_data."\n\nBeta-Lactamase: ".$beta_lactamase
			."\n\nIsolate Classification(s): ".$classification_code."\n\nMICs:\n".$mics,
		);

	}
	else
	{

		$c->model('CuratorEmail')->send(
			from => $curator_email_address,
			to => $curator_email_address,
			subject => 'New Profile',
			plaintext => "First Name: ".$first_name."\n\nLast Name: ".$last_name."\n\nEmail Address: ".$email_address
			."\n\nInstitution Name: ".$institution_name."\n\nInstitution Country: ".$institution_country
			."\n\nInstitution City: ".$institution_city."\n\nComments: ".$comments."\n\nAllele Types:\n".$allele_type_list
			."\nCollection Date: ".$collection_date
			."\n\nCountry: ".$country."\n\nPatient Age: ".$patient_age
			."\n\nPatient_gender: ".$patient_gender."\n\nEpidemiological Data: ".$epi_data."\n\nBeta-Lactamase: ".$beta_lactamase
			."\n\nIsolate Classification(s): ".$classification_code."\n\nMICs:\n".$mics,
		);

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
