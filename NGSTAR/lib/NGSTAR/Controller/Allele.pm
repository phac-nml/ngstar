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

package NGSTAR::Controller::Allele;
use Moose;
use namespace::autoclean;
use NGSTAR::Form::AlleleForm;
use NGSTAR::Form::AddAlleleForm;
use NGSTAR::Form::BatchAddAlleleForm;
use NGSTAR::Form::BatchAddMetadataForm;
use NGSTAR::Form::EditAlleleForm;
use NGSTAR::Form::EmailAlleleForm;
use NGSTAR::Form::BatchAlleleQueryForm;
use HTML::FormHandler;

use Readonly;
use Data::Dumper;

use HTML::Entities;
use Text::Sprintf::Named qw(named_sprintf);
use Catalyst qw( ConfigLoader );

use Session::Token;

BEGIN { extends 'Catalyst::Controller'; 'NGSTAR::Controller::Allele';}

=head1 NAME

NGSTAR::Controller::Allele - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index

=cut
#set this to the number of textboxes you have to input alleles into
Readonly my $NUM_SEQUENCES => 7;

Readonly my $TRANSLATION_LANG => "fr";
Readonly my $DEFAULT_LANG => "en";

#file sizes are in bytes
Readonly my $MAX_FILE_SIZE => 5600000;  #5.34 MB
Readonly my $MIN_FILE_SIZE => 0;

Readonly my $NOTIFICATION_OFF => 0;
Readonly my $NOTIFICATION_ON => 1;

Readonly my $FALSE => 0;
Readonly my $TRUE => 1;

Readonly my $INVALID_CONST => "IS_INVALID";
Readonly my $VALID_CONST => "IS_VALID";

Readonly my $INVALID_TYPE => -1;

Readonly my $PATIENT_GENDER_FEMALE => 'F';
Readonly my $PATIENT_GENDER_MALE => 'M';
Readonly my $PATIENT_GENDER_UNKNOWN => 'U';


Readonly my $ERROR_INVALID_LOCI_NAME => 1005;
Readonly my $ERROR_INVALID_ALLELE_TYPE => 1014;
Readonly my $ERROR_NO_ALLELES => 1015;
Readonly my $ERROR_CODE_EMPTY_ALLELES => 1016;
Readonly my $ERROR_INVALID_ALLELE_SEQUENCE => 1017;
Readonly my $ERROR_CODE_NO_LOCIS => 1018;
Readonly my $ERROR_INVALID_ALLELE_INFO => 1019;
Readonly my $ERROR_CODE_NO_DATA => 1020;
Readonly my $ERROR_INVALID_LOCI => 1021;
Readonly my $ERROR_NO_LOCI_ALLELES => 1022;

Readonly my $ERROR_INVALID_PROFILE_ALLELE_TYPES => 2004;
Readonly my $ERROR_NO_INPUT_PROVIDED => 2012;
Readonly my $ERROR_CODE_NO_ST_MATCH => 2016;

Readonly my $ERROR_INVALID_FASTA_INPUT_FORMAT => 5000;
Readonly my $ERROR_INVALID_TAB_INPUT_FORMAT => 5001;
Readonly my $ERROR_INVALID_FILENAME_FORMAT => 5002;
Readonly my $ERROR_INVALID_FILENAME => 5003;
Readonly my $ERROR_CODE_INVALID_OPTION => 5004;
Readonly my $ERROR_FILE_SIZE_TOO_LARGE => 5006;
Readonly my $ERROR_FILE_SIZE_TOO_SMALL => 5007;
Readonly my $ERROR_INVALID_INPUT_FORMAT => 5008;
Readonly my $ERROR_INVALID_TRACE_FILENAME => 5009;
Readonly my $ERROR_INVALID_FASTA_INPUT_CHARACTERS => 5010;

Readonly my $ERROR_INVALID_SAMPLE_NUMBER => 6000;
Readonly my $ERROR_INVALID_FASTA_SEQUENCE => 6001;
Readonly my $ERROR_INVALID_FASTA_LOCI_NAME => 6002;
Readonly my $ERROR_INVALID_FASTA_HEADER => 6003;

Readonly my $OPTION_ADD => "add";
Readonly my $OPTION_DELETE => "delete";
Readonly my $OPTION_DETAILS => "details";
Readonly my $OPTION_DOWNLOAD => "download";
Readonly my $OPTION_DOWNLOAD_ALLELE_METADATA => "downloadAlleleMetadata";
Readonly my $OPTION_EDIT => "edit";
Readonly my $OPTION_VIEW => "view";
Readonly my $OPTION_NONE => "";
Readonly my $OPTION_ETEST => "E-Test";
Readonly my $OPTION_AGAR_DILUTION => "Agar Dilution";
Readonly my $OPTION_DISC_DIFFUSION => "Disc Diffusion";

Readonly my $MIC_COMPARATOR_EQUALS => "=";
Readonly my $MIC_COMPARATOR_LESS_THAN_OR_EQUALS => "le";
Readonly my $MIC_COMPARATOR_GREATER_THAN_OR_EQUALS => "ge";
Readonly my $MIC_COMPARATOR_LESS_THAN => "lt";
Readonly my $MIC_COMPARATOR_GREATER_THAN => "gt";

Readonly my $SUCCESS => "SUCCESS";
Readonly my $ERROR_BASE_STRING => "modal.confirm.error.";


Readonly my $ADD_ALLELE_PAGE_TITLE => "shared.add.new.allele.text";
Readonly my $EDIT_ALLELE_PAGE_TITLE => "shared.edit.allele.text";
Readonly my $EMAIL_ALLELE_PAGE_TITLE => "shared.email.allele.text";

Readonly my $BATCH_ADD_ALLELE_PAGE_TITLE => "shared.batch.add.alleles.text";
Readonly my $BATCH_ADD_ALLELE_EX_PAGE_TITLE => "shared.batch.add.alleles.example.text";

Readonly my $BATCH_ADD_ALLELE_METADATA_PAGE_TITLE => "shared.batch.add.allele.metadata.text";
Readonly my $BATCH_ADD_ALLELE_METADATA_EX_PAGE_TITLE => "batch.add.allele.metadata.example.text";
Readonly my $BATCH_ALLELE_QUERY_RESULTS_PAGE_TITLE => "shared.batch.allele.query.results.text";

Readonly my $ALLELE_DETAILS_PAGE_TITLE => "shared.allele.details.text";
Readonly my $ALLELE_QUERY_PAGE_TITLE => "shared.allele.query.text";
Readonly my $ALLELE_QUERY_RESULT_PAGE_TITLE => "browser.title.allele.query.results";

Readonly my $ALLELE_LIST_PAGE_TITLE => "shared.allele.list.text";
Readonly my $SELECT_LOCI_PAGE_TITLE => "shared.select.loci.to.view.alleles.text";

Readonly my $ERROR_404_PAGE_TITLE => "shared.404.page.not.found.text";
Readonly my $ERROR_LOGIN_REQ_PAGE_TITLE => "shared.access.denied.text";

Readonly my $UNDER_DEV_PAGE_TITLE => "page.under.development.text";

Readonly my $NOT_FOUND => "not.found.text";
Readonly my $ALLELE_TYPE_NOT_FOUND => "Not found";
Readonly my $BATCH_ALLELE_QUERY_PAGE_TITLE => "shared.batch.allele.query.text";
Readonly my $BATCH_ALLELE_QUERY_EXAMPLE_PAGE_TITLE => "shared.batch.allele.query.example.text";

Readonly my $MULTIPLE_ALLELES_SAME_LOCI => 0;
Readonly my $MULTIPLE_ALLELES_MULTIPLE_LOCI => 1;
Readonly my $SINGLE_ALLELES_MULTIPLE_LOCI => 2;
Readonly my $SINGLE_ALLELE_SINGLE_LOCI => 3;


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

#a validator for AddAlleleForm
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


sub add_allele :Local
{

	my ($self, $c, $default_loci, $default_mics_determination) = @_;

	$c->log->debug('*** INSIDE add_allele METHOD ***');

	if($c->stash->{'login_allow'} eq "true")
	{

		if($c->user_exists() and $c->check_any_user_role(qw/ user admin /))
		{

			my $obj = $c->model('GetAlleleInfo');
			my $loci_name_list = $obj->_get_all_loci_names();
			$default_loci ||= $loci_name_list->[0];
			$default_mics_determination ||= '';
			$obj = $c->model('GetMetadata');
			my $classification_list = $obj->_get_all_isolate_classifications();
			my $antimicrobial_name_list = $obj->_get_mic_antimicrobial_names();


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

				my @locis = map { $_, $_ } @{$loci_name_list};

				my @classifications = map { $_, $_ } @classification_codes;


				my $ge = "&ge;";
				my $le = "&le;";

				my $lessthan = "&lt;";
				my $greaterthan = "&gt;";

				my $gt_decoded = decode_entities($greaterthan);
				my $lt_decoded = decode_entities($lessthan);

				my $ge_decoded = decode_entities($ge);
				my $le_decoded = decode_entities($le);


				#add some additional fields to the form that is not already defined in AddAlleleForm
				my $curr_lang = $c->session->{lang};
				my $lh = NGSTAR::I18N::i_default->new;

				if($c->session->{lang})
				{
					if($c->session->{lang} eq $TRANSLATION_LANG)
					{
						$lh = NGSTAR::I18N::fr->new;
					}
				}

				   my $form = NGSTAR::Form::AddAlleleForm->new(
					language_handle => $lh,
					field_list => [
						'loci_name_option' => {
							do_label => 1,
							type => 'Select',
							label => 'shared.loci.name.text',
							label_class => 'col-sm-2',
							element_wrapper_class => 'col-sm-10',
							required => 1,
							options => \@locis,
							default => $default_loci
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
							size => scalar(@$classification_list),
							required => 0,
							options => \@classifications,
							element_name => 'isolate_classification[]',
							multiple => 1,
						},
						'mics_determined_by_option'=>{
									do_label => 1,
									type => 'Select',
									label => 'shared.mics.determination.text',
									label_class => 'col-sm-2',
									element_wrapper_class => 'col-sm-10',
									widget => 'radio_group',
									multiple => 0,
									options => [{value=> '' , label => $c->loc('shared.none.text') },
													{value=> 'E-Test' , label => $c->loc('shared.etest.text') },
												  {value=> 'Agar Dilution' , label => $c->loc('shared.agar.dilution.text') },
												  {value=> 'Disc Diffusion', label => $c->loc('shared.disc.diffusion.text') }],
									  default => $default_mics_determination
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
							element_attr => { class => 'input-full' },
							validate_method => \&check_mic
						},
						$antimicrobial_name_list->[1] => {
							do_label => 0,
							type => 'Text',
							element_wrapper_class => 'col-sm-offset-2 col-sm-10',
							required => 0,
							minlength => 1,
							maxlength => 6,
							element_attr => { class => 'input-full' },
							validate_method => \&check_mic

						},
						$antimicrobial_name_list->[2] => {
							do_label => 0,
							type => 'Text',
							element_wrapper_class => 'col-sm-offset-2 col-sm-10',
							required => 0,
							minlength => 1,
							maxlength => 6,
							element_attr => { class => 'input-full' },
							validate_method => \&check_mic
						},
						$antimicrobial_name_list->[3] => {
							do_label => 0,
							type => 'Text',
							element_wrapper_class => 'col-sm-offset-2 col-sm-10',
							required => 0,
							minlength => 1,
							maxlength => 6,
							element_attr => { class => 'input-full' },
							validate_method => \&check_mic
						},
						$antimicrobial_name_list->[4] => {
							do_label => 0,
							type => 'Text',
							element_wrapper_class => 'col-sm-offset-2 col-sm-10',
							required => 0,
							minlength => 1,
							maxlength => 6,
							element_attr => { class => 'input-full' },
							validate_method => \&check_mic
						},
						$antimicrobial_name_list->[5] => {
							do_label => 0,
							type => 'Text',
							element_wrapper_class => 'col-sm-offset-2 col-sm-10',
							required => 0,
							minlength => 1,
							maxlength => 6,
							element_attr => { class => 'input-full' },
							validate_method => \&check_mic
						},
						$antimicrobial_name_list->[6] => {
							do_label => 0,
							type => 'Text',
							element_wrapper_class => 'col-sm-offset-2 col-sm-10',
							required => 0,
							minlength => 1,
							maxlength => 6,
							element_attr => { class => 'input-full' },
							validate_method => \&check_mic
						},
						$antimicrobial_name_list->[7] => {
							do_label => 0,
							type => 'Text',
							element_wrapper_class => 'col-sm-offset-2 col-sm-10',
							required => 0,
							minlength => 1,
							maxlength => 6,
							element_attr => { class => 'input-full' },
							validate_method => \&check_mic
						},
						$antimicrobial_name_list->[0].'_interpretation_option' => {
							do_label => 1,
							type => 'Select',
							label => $antimicrobial_name_list->[0],
							tags => { label_after => " ".$c->loc('shared.interpretation.text') },
							label_class => 'col-sm-2',
							element_wrapper_class => 'col-sm-10',
							required => 0,
							options => [{value => 'Unknown', label => $c->loc('shared.unknown.text')},
										{value => 'Intermediate', label => $c->loc('shared.intermediate.text')},
										{value => 'Resistant', label => $c->loc('shared.resistant.text')},
										{value => 'Susceptible', label => $c->loc('shared.susceptible.text')}],
							default => 'Unknown'
						},
						$antimicrobial_name_list->[1].'_interpretation_option' => {
							do_label => 1,
							type => 'Select',
							label => $antimicrobial_name_list->[1],
							tags => { label_after => " ".$c->loc('shared.interpretation.text') },
							label_class => 'col-sm-2',
							element_wrapper_class => 'col-sm-10',
							required => 0,
							options => [{value => 'Unknown', label => $c->loc('shared.unknown.text')},
										{value => 'Intermediate', label => $c->loc('shared.intermediate.text')},
										{value => 'Resistant', label => $c->loc('shared.resistant.text')},
										{value => 'Susceptible', label => $c->loc('shared.susceptible.text')}],
							default => 'Unknown'
						},
						$antimicrobial_name_list->[2].'_interpretation_option' => {
							do_label => 1,
							type => 'Select',
							label => $antimicrobial_name_list->[2],
							tags => { label_after => " ".$c->loc('shared.interpretation.text') },
							label_class => 'col-sm-2',
							element_wrapper_class => 'col-sm-10',
							required => 0,
							options => [{value => 'Unknown', label => $c->loc('shared.unknown.text')},
										{value => 'Intermediate', label => $c->loc('shared.intermediate.text')},
										{value => 'Resistant', label => $c->loc('shared.resistant.text')},
										{value => 'Susceptible', label => $c->loc('shared.susceptible.text')}],
							default => 'Unknown'
						},
						$antimicrobial_name_list->[3].'_interpretation_option' => {
							do_label => 1,
							type => 'Select',
							label => $antimicrobial_name_list->[3],
							tags => { label_after => " ".$c->loc('shared.interpretation.text') },
							label_class => 'col-sm-2',
							element_wrapper_class => 'col-sm-10',
							required => 0,
							options => [{value => 'Unknown', label => $c->loc('shared.unknown.text')},
										{value => 'Intermediate', label => $c->loc('shared.intermediate.text')},
										{value => 'Resistant', label => $c->loc('shared.resistant.text')},
										{value => 'Susceptible', label => $c->loc('shared.susceptible.text')}],
							default => 'Unknown'
						},
						$antimicrobial_name_list->[4].'_interpretation_option' => {
							do_label => 1,
							type => 'Select',
							label => $antimicrobial_name_list->[4],
							tags => { label_after => " ".$c->loc('shared.interpretation.text') },
							label_class => 'col-sm-2',
							element_wrapper_class => 'col-sm-10',
							required => 0,
							options => [{value => 'Unknown', label => $c->loc('shared.unknown.text')},
										{value => 'Intermediate', label => $c->loc('shared.intermediate.text')},
										{value => 'Resistant', label => $c->loc('shared.resistant.text')},
										{value => 'Susceptible', label => $c->loc('shared.susceptible.text')}],
							default => 'Unknown'
						},
						$antimicrobial_name_list->[5].'_interpretation_option' => {
							do_label => 1,
							type => 'Select',
							label => $antimicrobial_name_list->[5],
							tags => { label_after => " ".$c->loc('shared.interpretation.text') },
							label_class => 'col-sm-2',
							element_wrapper_class => 'col-sm-10',
							required => 0,
							options => [{value => 'Unknown', label => $c->loc('shared.unknown.text')},
										{value => 'Intermediate', label => $c->loc('shared.intermediate.text')},
										{value => 'Resistant', label => $c->loc('shared.resistant.text')},
										{value => 'Susceptible', label => $c->loc('shared.susceptible.text')}],
							default => 'Unknown'
						},
						$antimicrobial_name_list->[6].'_interpretation_option' => {
							do_label => 1,
							type => 'Select',
							label => $antimicrobial_name_list->[6],
							tags => { label_after => " ".$c->loc('shared.interpretation.text') },
							label_class => 'col-sm-2',
							element_wrapper_class => 'col-sm-10',
							required => 0,
							options => [{value => 'Unknown', label => $c->loc('shared.unknown.text')},
										{value => 'Intermediate', label => $c->loc('shared.intermediate.text')},
										{value => 'Resistant', label => $c->loc('shared.resistant.text')},
										{value => 'Susceptible', label => $c->loc('shared.susceptible.text')}],
							default => 'Unknown'
						},
						$antimicrobial_name_list->[7].'_interpretation_option' => {
							do_label => 1,
							type => 'Select',
							label => $antimicrobial_name_list->[7],
							tags => { label_after => " ".$c->loc('shared.interpretation.text') },
							label_class => 'col-sm-2',
							element_wrapper_class => 'col-sm-10',
							required => 0,
							options => [{value => 'Unknown', label => $c->loc('shared.unknown.text')},
										{value => 'Intermediate', label => $c->loc('shared.intermediate.text')},
										{value => 'Resistant', label => $c->loc('shared.resistant.text')},
										{value => 'Susceptible', label => $c->loc('shared.susceptible.text')}],
							default => 'Unknown'
						},
					],
					ctx => $c,
				);

				$c->stash(template => 'allele/AddAlleleForm.tt2', form => $form, antimicrobial_name_list => $antimicrobial_name_list, classification_list => $classification_list, loci_name_list => $loci_name_list, page_title=>$ADD_ALLELE_PAGE_TITLE, prev_loci_name => $default_loci);

				$form->process(update_field_list => {
					allele_type => {messages => {required => $c->loc('shared.enter.allele.type.form.error.msg')}},
					allele_sequence => {messages => {required => $c->loc('shared.enter.sequence.msg')}},
					collection_date => {element_attr => { placeholder => $c->loc("shared.date.format")}},
					csrf => {default => $c->session->{csrf_token} },
				});

				$form->process(params => $c->request->params);
				return unless $form->validated;

				my $loci_name = $c->request->params->{loci_name_option};
				my $allele_type = $c->request->params->{allele_type};
				my $allele_sequence = $c->request->params->{allele_sequence};

				my @options = ($OPTION_NONE,$OPTION_ETEST,$OPTION_AGAR_DILUTION,$OPTION_DISC_DIFFUSION);

				#get meta-data
				#to do: validate request parameters
				my $amr_marker_string = $c->request->params->{amr_markers};
				my $country = $c->request->params->{country};
				my $patient_age = $c->request->params->{patient_age};
				my $patient_gender = $c->request->params->{patient_gender};
				my $collection_date = $c->request->params->{collection_date};
				my $beta_lactamase = $c->request->params->{beta_lactamase};
				my $classification_code = $c->request->params->{isolate_classification};
				my $epi_data = $c->request->params->{epi_data};
				my $curator_comment = $c->request->params->{curator_comment};
				my $mics_determined_by = $c->request->params->{mics_determined_by_option};
				my $csrf_form_submitted = $c->request->params->{csrf};

				my %mic_map;
				my %interpretation_map;

				my $formatted_classification_code="";

				if($csrf_form_submitted and $csrf_form_submitted eq $c->session->{csrf_token})
				{
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

					if($mics_determined_by eq $options[0])
					{

						undef %mic_map;
						undef %interpretation_map;

					}
					elsif(lc($mics_determined_by) ne lc($options[3]) &&  $mics_determined_by ne lc($options[0]))
					{

						foreach my $name (@$antimicrobial_name_list)
						{

							my $comparator_key = $name . "_comparator_option";
							$mic_map{$name}{mic_comparator} = $c->request->params->{$comparator_key};
							$c->log->debug('\ncomparator: ' . $mic_map{$name}{mic_comparator});

							if($c->request->params->{$name} and length $c->request->params->{$name} > 0)
							{
								$mic_map{$name}{mic_value} = $c->request->params->{$name};
							}
							else
							{
								$mic_map{$name}{mic_value} = undef;
							}

						}

					}
					else
					{

						foreach my $name (@$antimicrobial_name_list)
						{

							my $comparator_key = $name . "_interpretation_option";
							$interpretation_map{$name}{interpretation_value} = $c->request->params->{$comparator_key};
							$c->log->debug('\nInterpretation: ' . $interpretation_map{$name}{interpretation_value});

						}

					}

					my $error_code;

					$allele_sequence =~ s/(\s+)//g;     #remove any whitespaces

					my $loci_name_exists = $FALSE;

					foreach my $loci_in_list (@$loci_name_list)
					{
						if(lc($loci_in_list) eq lc($loci_name))
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
					elsif($allele_sequence !~ /^[ATCG]+$/i)
					{

						$error_code = $ERROR_INVALID_ALLELE_SEQUENCE;

					}


					if(defined $error_code)
					{

						my $err_msg = $c->loc($ERROR_BASE_STRING.$error_code);

						$c->stash(error_id => $error_code, error_code => $err_msg);

					}
					else
					{


						$obj = $c->model('AddAllele');
						my $result = $obj->_add_allele($loci_name, $allele_type, $allele_sequence, $country, $patient_age, $patient_gender, $epi_data, $curator_comment,$beta_lactamase, $formatted_classification_code, \%mic_map, $mics_determined_by, $collection_date, \%interpretation_map, $amr_marker_string);

						if($result eq $VALID_CONST)
						{
							$c->session->{csrf_token} = Session::Token->new(length => 128)->get;


							$obj = $c->model('ConvertSequences');

							my $is_onishi_type = $FALSE;
							my $onishi_type_set = $obj->_get_loci_with_onishi_type();
							my $aa_profile_exists = $FALSE;
							my $aa_profile;

							if((%$onishi_type_set) and (exists $onishi_type_set->{$loci_name}))
							{
								$is_onishi_type = $TRUE;

								#check if onishi aminio acid profile exists for the allele sequence provided
								($aa_profile_exists, $aa_profile) = $obj->_check_amino_acid_profile($allele_sequence);

							}

							#if amino acid profile exists or loci is not an onishi type it will redirect to list alleles page otherwise user is redirected to the add amino acid profile page
							if($aa_profile_exists == $TRUE or $is_onishi_type == $FALSE)
							{
								$c->flash(add_notification => $NOTIFICATION_ON);
								$c->response->redirect($c->uri_for($self->action_for('list_loci_alleles'), $loci_name));
							}
							else
							{
								$c->flash(add_notification => $NOTIFICATION_ON, loci_name => $loci_name ,allele_type => $allele_type);
								$c->response->redirect($c->uri_for($c->controller('Curator')->action_for('add_amino_acid_profile'), $aa_profile));
							}

						}
						else
						{

							$obj = $c->model('GetAlleleInfo');
							my ($type_with_seq_exists, $type_found) = $obj->_get_type_by_sequence($loci_name, $allele_sequence);

							$obj = $c->model('GetIntegerType');
							my $loci_int_type_set = $obj->_get_loci_with_integer_type();

							if((%$loci_int_type_set) and (exists $loci_int_type_set->{$loci_name}))
							{

								$type_with_seq_exists = int($type_with_seq_exists);

							}

							my $err_msg;


							if(defined $type_found && $type_found == $INVALID_TYPE)
							{

								$err_msg = $c->loc($ERROR_BASE_STRING.$result);

								if((%$loci_int_type_set) and (exists $loci_int_type_set->{$loci_name}))
								{

									$allele_type = int($allele_type);

								}
								else
								{
									$allele_type = sprintf ("%.3f", $allele_type);
								}

								$err_msg =  named_sprintf($err_msg, { allele_type => $allele_type, loci_name => $loci_name });

								$c->stash(error_id => $result, error_code => $err_msg);

							}
							else
							{

								$err_msg = $c->loc($ERROR_BASE_STRING.$result);

								$err_msg =  named_sprintf($err_msg, { loci_name => $loci_name, allele_type => $type_with_seq_exists });

								$c->stash(error_id => $result, error_code => $err_msg);

							}

						}

					}

				}
				else
				{

					$c->response->redirect($c->uri_for($self->action_for('add_allele'),$loci_name));

				}

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

sub analyze_sequence_process :Local
{
	my ($self, $c, $sequence, $loci_name, $allele_type) = @_;

	$c->flash->{analysis_sequence} = $sequence;
	$c->flash->{analysis_loci_name} = $loci_name;
	$c->flash->{analysis_allele_type} = $allele_type;
	$c->response->redirect($c->uri_for($self->action_for('analyze_sequence')));
}

sub analyze_sequence :Local
{

	my ($self, $c) = @_;

	my $obj = $c->model('GetAlleleInfo');
	my $result;
	my $is_onishi_type= $FALSE;
	my $err_msg;

	my $sequence = $c->flash->{analysis_sequence};
	my $loci_name = $c->flash->{analysis_loci_name};
	my $allele_type = $c->flash->{analysis_allele_type};

	if($sequence && $loci_name && $allele_type)
	{
		$result = $obj->_get_wild_type_allele_by_loci_id($loci_name);
	}

	#get onishi/protein/dna seqs for sequence and for wild Type as well as differences
	# wt -> Wild Type
	# us -> User Sequence
	# diffs -> Differences between wt and us

	if($result)
	{
		$obj = $c->model('ConvertSequences');

		my $onishi_type_set = $obj->_get_loci_with_onishi_type();

		if((%$onishi_type_set) and (exists $onishi_type_set->{$loci_name}))
		{
			$is_onishi_type = $TRUE;
		}

		my ($dna_seq_wt, $dna_seq_us, $dna_diffs)  = $obj->_get_dna_sequences($sequence, $result);
		my ($protein_seq_wt, $protein_seq_us, $protein_diffs)  = $obj->_get_protein_sequences($sequence, $result);

		my ($onishi_seq_wt, $onishi_seq_us, $onishi_diffs, $is_mosaic, $is_valid, $probable_type);
		$is_valid = $TRUE;

		#Only penA gene an onishi
		if($is_onishi_type == $TRUE)
		{
			($onishi_seq_wt, $onishi_seq_us, $onishi_diffs, $is_mosaic, $allele_type, $is_valid, $probable_type)  = $obj->_get_onishi_sequences($sequence, $loci_name, $allele_type);
		}

		if($allele_type eq $ALLELE_TYPE_NOT_FOUND)
		{
			$allele_type = -1;
		}

		$obj = $c->model('GetIntegerType');
		my $loci_int_type_set = $obj->_get_loci_with_integer_type();

		if((%$loci_int_type_set) and (exists $loci_int_type_set->{$loci_name}) and $allele_type > -1)
		{
			$allele_type = int($allele_type);
		}

		#The following code block is used in AnalyzeSequences tt2 file to show position marks above tables for sequences

		#begin
		my $wild_type_seq_length;
		my $char_count;
		my $onishi_pos_marks;

		if($is_onishi_type == $TRUE)
		{

			$wild_type_seq_length = length $onishi_seq_wt;
			$char_count = 0;
			$onishi_pos_marks="";

			while($char_count < $wild_type_seq_length)
			{
				$onishi_pos_marks .= "|";
				$char_count++;
			}

		}
		$wild_type_seq_length = length $protein_seq_wt;
		$char_count = 0;
		my $protein_pos_marks="";

		while($char_count < $wild_type_seq_length)
		{
			$protein_pos_marks .= "|";
			$char_count++;
		}

		$wild_type_seq_length = length $dna_seq_wt;
		$char_count = 0;
		my $dna_pos_marks="";

		while($char_count < $wild_type_seq_length)
		{
			$dna_pos_marks .= "|";
			$char_count++;
		}
		#end

		$obj = $c->model('ConvertSequences');
		my $onishi_positions_list = $obj->_get_amino_acids("penA");
		my $onishi_positions ="";

		foreach my $amino_acid(@$onishi_positions_list)
		{
			$onishi_positions .= $amino_acid->{aa_pos}.",";
		}

		if($is_onishi_type == $TRUE)
		{
			$c->stash(template => 'allele/AnalyzeSequences.tt2', page_title => "Sequence Analysis", user_sequence => uc($sequence), allele_type => $allele_type, wild_type_seq => uc($result),
						 dna_wt => $dna_seq_wt, dna_us=> $dna_seq_us, dna_diff=> $dna_diffs,
						onishi_wt => $onishi_seq_wt, onishi_us=> $onishi_seq_us, onishi_diff=> $onishi_diffs,
						protein_wt => $protein_seq_wt, protein_us=> $protein_seq_us, protein_diff=> $protein_diffs,
						non_onishi_seq => "false", is_mosaic => $is_mosaic, is_valid => $is_valid, probable_penA_type => $probable_type, loci_name => $loci_name, onishi_pos_marks => $onishi_pos_marks, protein_pos_marks => $protein_pos_marks, dna_pos_marks => $dna_pos_marks, onishi_positions => $onishi_positions );
		}
		else
		{
			$c->stash(template => 'allele/AnalyzeSequences.tt2', page_title => "Sequence Analysis", user_sequence => uc($sequence), allele_type => $allele_type, wild_type_seq => uc($result),
						dna_wt => $dna_seq_wt, dna_us=> $dna_seq_us, dna_diff=> $dna_diffs,
						protein_wt => $protein_seq_wt, protein_us=> $protein_seq_us, protein_diff=> $protein_diffs,
						non_onishi_seq => "true", loci_name => $loci_name,  protein_pos_marks => $protein_pos_marks, dna_pos_marks => $dna_pos_marks);
		}

	}
	else
	{

		$err_msg = $c->loc($ERROR_BASE_STRING.$ERROR_NO_LOCI_ALLELES);
		$err_msg =  named_sprintf($err_msg, { loci_name => $loci_name });

		#NO ALLELE SELECTED ERROR - No allele was selected. Please select an allele and try running the analysis again.
		$c->stash(template => 'allele/AnalyzeSequences.tt2', error_id => $ERROR_NO_LOCI_ALLELES, error_code => $err_msg);
	}

}

sub batch_add_allele :Local
{

	my ($self, $c, $default_loci) = @_;

	if($c->stash->{'login_allow'} eq "true")
	{

		if($c->user_exists() and $c->check_any_user_role(qw/ user admin /))
		{

			my $obj = $c->model('GetAlleleInfo');
			my $result = $obj->_get_all_loci_names();
			$default_loci ||= $result->[0];

			my @locis = map { $_, $_ } @{$result};

			my $curr_lang = $c->session->{lang};
			my $lh = NGSTAR::I18N::i_default->new;

			if($c->session->{lang})
			{
				if($c->session->{lang} eq $TRANSLATION_LANG)
				{
					$lh = NGSTAR::I18N::fr->new;
				}
			}

			#add some additional fields to the form that is not already defined in AddAlleleForm
			my $form = NGSTAR::Form::BatchAddAlleleForm->new(
			language_handle => $lh,
				field_list => [
					'loci_name_option' => {
						do_label => 1,
						type => 'Select',
						label => 'shared.loci.name.text',
						label_class => 'col-sm-2',
						element_wrapper_class => 'col-sm-10',
						required => 1,
						options => \@locis,
						element_attr => {class=> 'input-full' },
						default => $default_loci
					},
				]
			);

			$form->process(update_field_list => {
				csrf => {default => $c->session->{csrf_token} },
			});

			$c->stash(template => 'allele/BatchAddAlleleForm.tt2', form => $form ,loci_name_list => $result, page_title => $BATCH_ADD_ALLELE_PAGE_TITLE, prev_loci_name => $default_loci);

			$form->process(params => $c->request->params);
			return unless $form->validated;

			my $has_error = $FALSE;
			my $error_code = $INVALID_CONST;

			#target will contain the path to the file
			#passed from batch_add_allele method above

			my $loci_name = $c->request->params->{loci_name_option};
			my $input = $c->request->params->{fasta_sequences};
			my $csrf_form_submitted = $c->request->params->{csrf};

			if($csrf_form_submitted and $csrf_form_submitted eq $c->session->{csrf_token})
			{
				#remove any characters that are not part of this whitelist
				#case 1: info is provided in textbox

				if($input)
				{

					$input =~ s/[^>A-Za-z\d\.\s\n]//g;

				}

				my $loci_name_exists = $FALSE;

				foreach my $loci_in_list (@$result)
				{
					if(lc($loci_in_list) eq lc($loci_name))
					{
						$loci_name_exists = $TRUE;
					}
				}

				if(not $loci_name_exists)
				{

					$has_error = $TRUE;
					$error_code = $ERROR_INVALID_LOCI;

				}

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
						if($filename !~ /^[(A-Z)|(\d)|(_)|(\-)]+(\.fasta)$/i)
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

							if($input !~ /[(>)|(A-Z)|(\d)|(\.)]+/i)
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

					$obj = $c->model('ValidateBatchAlleles');

					#validate whether the input can be properly parsed
					$result = $obj->_validate_batch_alleles_parse($input, $loci_name);


					if($result eq $VALID_CONST)
					{

						#validate each allele in the fasta formatted input
						$result = $obj->_validate_batch_alleles_input($input, $loci_name);

						if($result and %$result)
						{

							#this line must be added or else it will call subsequent responses
							$has_error = $TRUE;

							#need to add error_codes hash to stash here because you can't pass a
							#reference to a hash as an argument to another method in the controller
							$c->stash(error_codes => $result, loci_name => $loci_name);

						}

					}
					else
					{

						$has_error = $TRUE;
						$error_code = $result;

						my $err_msg = $c->loc($ERROR_BASE_STRING.$error_code);
						$c->stash(error_id => $error_code, error_code => $err_msg);

					}

				}
				else
				{

					my $err_msg = $c->loc($ERROR_BASE_STRING.$error_code);
					$c->stash(error_id => $error_code, error_code => $err_msg);

				}

				#if there are no errors after validation, then proceed with batch adding alleles to the database
				if(not $has_error)
				{

					$obj = $c->model('BatchAddAllele');
					$result = $obj->_batch_add_allele($input, $loci_name);

					#required for list_loci_alleles to determine which view will be shown [Options for curators and no options for non curators]
					if($result ne $VALID_CONST)
					{

						$has_error = $TRUE;
						$error_code = $result;

					}

					if(not $has_error)
					{

						$c->session->{csrf_token} = Session::Token->new(length => 128)->get;

						$c->flash(batch_add_notification => $NOTIFICATION_ON);
						$c->response->redirect($c->uri_for($self->action_for('list_loci_alleles'), $loci_name));

					}

				}

			}
			else
			{
				$c->response->redirect($c->uri_for($self->action_for('batch_add_allele'), $loci_name));
			}

		}
		else
		{

			$c->stash(template => 'error/access_denied_admin.tt2', page_title => $ERROR_LOGIN_REQ_PAGE_TITLE);

		}

	}
	else
	{

		$c->stash(template => 'error/error_404.tt2', $ERROR_404_PAGE_TITLE);

	}

}
sub batch_add_example :Local
{

	my ($self, $c, $prev_loci_name) = @_;

	$c->log->debug('*** INSIDE batch_add_example METHOD ***');

	if($c->user_exists() and $c->check_any_user_role(qw/ user admin /))
	{

		$c->stash(template => 'allele/BatchAddAlleleExample.tt2', page_title => $BATCH_ADD_ALLELE_EX_PAGE_TITLE, prev_loci_name =>$prev_loci_name);

	}
	else
	{

		$c->stash(template => 'error/access_denied_admin.tt2', page_title => $ERROR_LOGIN_REQ_PAGE_TITLE);


	}

}

sub batch_add_metadata :Local
{

	my ($self, $c, $default_loci) = @_;

	$c->log->debug('*** INSIDE batch_add_metadata METHOD ***');

	if($c->stash->{'login_allow'} eq "true")
	{

		if($c->user_exists() and $c->check_any_user_role(qw/ user admin /))
		{

			my $obj = $c->model('GetAlleleInfo');
			my $result = $obj->_get_all_loci_names();
			$default_loci ||= $result->[0];

			my @locis = map { $_, $_ } @{$result};

			my $curr_lang = $c->session->{lang};
			my $lh = NGSTAR::I18N::i_default->new;

			if($c->session->{lang})
			{
				if($c->session->{lang} eq $TRANSLATION_LANG)
				{
					$lh = NGSTAR::I18N::fr->new;
				}
			}


			#add some additional fields to the form that is not already defined in AddAlleleForm
			my $form = NGSTAR::Form::BatchAddMetadataForm->new(
				language_handle => $lh,
				field_list => [
						'loci_name_option' => {
							do_label => 1,
							type => 'Select',
							label => 'shared.loci.name.text',
							label_class => 'col-sm-2',
							element_wrapper_class => 'col-sm-10',
							required => 1,
							options => \@locis,
							element_attr => { class=>'input-full'},
							default => $default_loci
						},
					],
				ctx => $c,
			);

			$c->stash(template => 'allele/BatchAddMetadataForm.tt2', form => $form, loci_name_list => $result, page_title => $BATCH_ADD_ALLELE_METADATA_PAGE_TITLE);

			$form->process(update_field_list => {
				csv_metadata => {messages => {required => $c->loc('shared.enter.metadata.msg')}},
				csrf => {default => $c->session->{csrf_token} },
			});

			$form->process(params => $c->request->params);
			return unless $form->validated;

			my $has_error = $FALSE;
			my $error_code = $INVALID_CONST;

			my $loci_name = $c->request->params->{loci_name_option};
			my $input = $c->request->params->{csv_metadata};
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

					my $upload = $c->request->upload('my_csv');

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

				my $err_msg;

				if(not $has_error)
				{

				   $obj = $c->model('ValidateBatchMetadata');

				   #validate whether the input can be properly parsed
				   $result = $obj->_validate_batch_metadata_parse($input);

				   if($result eq $VALID_CONST)
				   {

						#validate metadata in the tab formatted input

						$result = $obj->_validate_batch_metadata_input($input, $loci_name);

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

						my $err_msg = $c->loc($ERROR_BASE_STRING.$error_code);
						$c->stash(error_id => $error_code, error_code => $err_msg);

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
					$result = $obj->_batch_add_metadata($input,$loci_name);

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
						$c->response->redirect($c->uri_for($self->action_for('batch_add_metadata')));

					}

				}
				else
				{

					$c->stash(error_codes => $result);

				}

			}
			else
			{

				$c->response->redirect($c->uri_for($self->action_for('batch_add_metadata'), $loci_name));

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

sub batch_add_metadata_example :Local
{

	my ($self, $c) = @_;

	$c->log->debug('*** INSIDE batch_add_metadata_example METHOD ***');

	if($c->user_exists() and $c->check_any_user_role(qw/ user admin /))
	{

		$c->stash(template => 'allele/BatchAddMetadataExample.tt2', page_title => $BATCH_ADD_ALLELE_METADATA_EX_PAGE_TITLE);

	}
	else
	{

		$c->stash(template => 'error/access_denied_admin.tt2', page_title => $ERROR_LOGIN_REQ_PAGE_TITLE);

	}

}

sub batch_allele_query :Local :Args()
{
	my ($self,$c) = @_;

	my $curr_lang = $c->session->{lang};
	my $lh = NGSTAR::I18N::i_default->new;
	my $num_allele_results = 7;
	my $err_msg;


	if($c->session->{lang})
	{
		if($c->session->{lang} eq $TRANSLATION_LANG)
		{
			$lh = NGSTAR::I18N::fr->new;
		}
	}

	#add some additional fields to the form that is not already defined in AddAlleleForm
	my $form = NGSTAR::Form::BatchAlleleQueryForm->new(
		language_handle => $lh,
	);

	$form->process(update_field_list => {
		csrf => {default => $c->session->{csrf_token} },
	});

	$c->stash(template => 'allele/BatchAlleleQueryForm.tt2', form => $form, page_title => $BATCH_ALLELE_QUERY_PAGE_TITLE);

	$form->process(params => $c->request->params);
	return unless $form->validated;

	my $has_error = $FALSE;
	my $error_code = $INVALID_CONST;
	my $csrf_form_submitted = $c->request->params->{csrf};

	my $input = $c->request->params->{batch_fasta_sequences};

	if($csrf_form_submitted and $csrf_form_submitted eq $c->session->{csrf_token})
	{
		#remove any characters that are not part of this whitelist
		#case 1: info is provided in textbox

		if($input)
		{

			$input =~ s/[^>A-Za-z\_\d\.\s\n]//g;

		}
		#case 2: a file is uploaded
		if(not $has_error and not $input)
		{
			#Catalyst saves the uploaded file to a temp directory (default is at /tmp).
			#You can specify this directory in the Catalyst configuration contained in NGSTAR.pm
			#The uploaded file is automatically saved with a random filename for security.
			#The uploaded file is automatically deleted after it has been processed.

			my $upload = $c->request->upload('batch_fasta_query');

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
				if($filename !~ /^[(A-Z)|(\d)|(\_)|(\-)]+(\.fasta)|(\.txt)$/i)
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

					if($input !~ /[(>)|(A-Z)|(\_)|(\d)|(\.)]+/i)
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

			$err_msg = $c->loc($ERROR_BASE_STRING.$ERROR_CODE_EMPTY_ALLELES);
			$c->stash(error_id => $ERROR_CODE_EMPTY_ALLELES, error_code => $err_msg);

		}
		else
		{

			my $obj = $c->model('GetAlleleInfo');
			my $allele_sequence_count = $obj->_get_all_allele_count();
			my $is_multi_query = $TRUE;


			if($allele_sequence_count > 0)
			{

				$obj = $c->model('ParseFasta');

				my ($is_valid, $sequence_map, $query_state, $invalid_sample_number, $invalid_header, $invalid_loci_name, $invalid_sequence) = $obj->_parse_fasta_batch_query_alleles($input);


				if($invalid_sequence)
				{
					$err_msg = $c->loc($ERROR_BASE_STRING.$ERROR_INVALID_FASTA_SEQUENCE);
					$c->stash(error_id => $ERROR_INVALID_FASTA_SEQUENCE, error_code => $err_msg);
				}
				elsif($invalid_loci_name)
				{
					$obj = $c->model('GetAlleleInfo');
					my $allele_sequence_count = $obj->_get_all_allele_count();

					my $loci_name_list = $obj->_get_all_loci_names();
					my $loci_names = join( ',', @$loci_name_list );

					$err_msg = $c->loc($ERROR_BASE_STRING.$ERROR_INVALID_FASTA_LOCI_NAME);
					$err_msg =  named_sprintf($err_msg, { loci_names => $loci_names });
					$c->stash(error_id => $ERROR_INVALID_FASTA_LOCI_NAME, error_code => $err_msg);
				}
				elsif($invalid_header)
				{
					$err_msg = $c->loc($ERROR_BASE_STRING.$ERROR_INVALID_FASTA_HEADER);
					$c->stash(error_id => $ERROR_INVALID_FASTA_HEADER, error_code => $err_msg);
				}
				elsif($invalid_sample_number)
				{
					$err_msg = $c->loc($ERROR_BASE_STRING.$ERROR_INVALID_SAMPLE_NUMBER);
					$c->stash(error_id => $ERROR_INVALID_SAMPLE_NUMBER, error_code => $err_msg);
				}
				elsif($is_valid and ($sequence_map and %$sequence_map) and (($query_state == $SINGLE_ALLELES_MULTIPLE_LOCI) or ($query_state == $SINGLE_ALLELE_SINGLE_LOCI) ))
				{

					$is_multi_query = $FALSE;
					$self->get_allele_type($c, $sequence_map, $num_allele_results, $is_multi_query);

				}
				elsif($is_valid and ($sequence_map and %$sequence_map) and ($query_state == $MULTIPLE_ALLELES_SAME_LOCI or $query_state == $MULTIPLE_ALLELES_MULTIPLE_LOCI ))
				{

					$self->get_allele_type($c, $sequence_map, $num_allele_results, $is_multi_query);

				}
				else
				{

					$err_msg = $c->loc($ERROR_BASE_STRING.$ERROR_INVALID_FASTA_INPUT_CHARACTERS);
					$c->stash(error_id => $ERROR_INVALID_FASTA_INPUT_CHARACTERS, error_code => $err_msg);

				}


			}
			else
			{

				$err_msg = $c->loc($ERROR_BASE_STRING.$ERROR_NO_ALLELES);
				$c->stash(error_id => $ERROR_NO_ALLELES, error_code => $err_msg);

			}

		}

	}

}

sub batch_allele_query_example :Local
{

	my ($self, $c) = @_;

	$c->log->debug('*** INSIDE batch_add_example METHOD ***');

	$c->stash(template => 'allele/BatchAlleleQueryExample.tt2', page_title => $BATCH_ALLELE_QUERY_EXAMPLE_PAGE_TITLE);

}

sub details :Local :Args(2)
{

	my ($self, $c, $loci_name, $allele_type) = @_;

	if(not $c->user_exists())
	{

		my $obj;
		$obj = $c->model('GetIntegerType');
		my $loci_int_type_set = $obj->_get_loci_with_integer_type();

		if((%$loci_int_type_set) and (exists $loci_int_type_set->{$loci_name}))
		{
			   $allele_type = int($allele_type);
		}

		$obj = $c->model('GetAlleleInfo');
		my $allele = $obj->_get_allele_details($loci_name, $allele_type);

		$obj = $c->model('GetMetadata');
		my $metadata = $obj->_get_metadata($allele_type, $loci_name);
		my $mic_list = $obj->_get_metadata_mics($allele_type, $loci_name);
		my $interpretation_list = $obj->_get_metadata_interpretations($allele_type, $loci_name);
		my $classifications_list = $obj->_get_metadata_classifications($allele_type, $loci_name);
		my $err_msg;

		if((not $allele) or
			(not $metadata) or
			(not $mic_list) or
			(not $interpretation_list))
		{

			$err_msg = $c->loc($ERROR_BASE_STRING.$ERROR_CODE_NO_DATA);
			$c->stash(error_id => $ERROR_CODE_NO_DATA, error_code => $err_msg);

		}
		else
		{
			$c->stash(template => 'allele/AlleleDetails.tt2', allele_info => $allele, loci_name => $loci_name, metadata => $metadata, mic_list => $mic_list, interpretation_list => $interpretation_list, loci_int_type_set => $loci_int_type_set, classifications_list => $classifications_list, page_title => $ALLELE_DETAILS_PAGE_TITLE);
		}

	}
	else
	{
		$c->response->redirect($c->uri_for($self->action_for('edit'),$loci_name, $allele_type));
	}
}


sub delete :Local :Args(2)
{

	my ($self, $c, $loci_name, $allele_type) = @_;

	if($c->stash->{'login_allow'} eq "true")
	{

		if($c->user_exists() and $c->check_any_user_role(qw/ user admin /))
		{

			my $obj;
			$obj = $c->model('GetIntegerType');
			my $loci_int_type_set = $obj->_get_loci_with_integer_type();

			if((%$loci_int_type_set) and (exists $loci_int_type_set->{$loci_name}))
			{

				$allele_type = int($allele_type);

			}

			$obj = $c->model('DeleteAllele');
			my $result = $obj->_delete_allele($loci_name, $allele_type);

			if($result eq $VALID_CONST)
			{

				$c->flash(delete_notification => $NOTIFICATION_ON);
				$c->response->redirect($c->uri_for($self->action_for('list_loci_alleles'), $loci_name));

			}
			else
			{

				$c->flash(delete_notification => $NOTIFICATION_OFF);
				$c->response->redirect($c->uri_for($self->action_for('list_loci_alleles'), $loci_name, $allele_type, $result));

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

sub display_types :Local
{

	my ($self, $c) = @_;

	$c->log->debug('*** INSIDE display_types METHOD ***');

	my $obj = $c->model('GetIntegerType');
	my $loci_int_type_set = $obj->_get_loci_with_integer_type();

	$obj = $c->model('GetAlleleInfo');
	my $loci_count = $obj->_get_loci_name_count();

	$obj = $c->model('GetUserInfo');

	my $user_id;
	my $curr_loggedin_username;
	my $curr_loggedin_user_details;
	my $institution_name="";
	my $user_name ="";
	my $email_address="";

	if($c->user_exists() and $c->check_any_user_role(qw/ user admin /))
	{
		$user_id = $c->user->get('id');
		$curr_loggedin_username = $obj->_get_current_username_by_user_id($user_id);
		$curr_loggedin_user_details = $obj->_get_user_details_by_username($curr_loggedin_username);

		$institution_name = $curr_loggedin_user_details->[0]->{institution_name};
		$user_name = $curr_loggedin_user_details->[0]->{first_name}." ".$curr_loggedin_user_details->[0]->{last_name};
		$email_address = $curr_loggedin_user_details->[0]->{email_address};

	}

	my @selection_list = (
		"Exact or nearest match",
		"Exact match only",
		"6 or more matches",
		"5 or more matches",
		"4 or more matches",
		"3 or more matches",
		"2 or more matches",
		"1 or more matches"
	);

	$c->stash(template => 'allele/AlleleTypeResult.tt2', selection_list => \@selection_list, loci_int_type_set => $loci_int_type_set, loci_count => $loci_count, ins_name => $institution_name, loggedin_user_name => $user_name, email_address => $email_address, page_title => $ALLELE_QUERY_RESULT_PAGE_TITLE );

}

sub display_multi_types :Local
{

	my ($self, $c) = @_;

	$c->log->debug('*** INSIDE display_multi_types METHOD ***');

	my $obj = $c->model('GetIntegerType');
	my $loci_int_type_set = $obj->_get_loci_with_integer_type();

	$obj = $c->model('GetAlleleInfo');
	my $loci_count = $obj->_get_loci_name_count();

	$obj = $c->model('GetUserInfo');

	my $user_id;
	my $curr_loggedin_username;
	my $curr_loggedin_user_details;
	my $institution_name="";
	my $user_name ="";
	my $email_address="";

	if($c->user_exists() and $c->check_any_user_role(qw/ user admin /))
	{
		$user_id = $c->user->get('id');
		$curr_loggedin_username = $obj->_get_current_username_by_user_id($user_id);
		$curr_loggedin_user_details = $obj->_get_user_details_by_username($curr_loggedin_username);

		$institution_name = $curr_loggedin_user_details->[0]->{institution_name};
		$user_name = $curr_loggedin_user_details->[0]->{first_name}." ".$curr_loggedin_user_details->[0]->{last_name};
		$email_address = $curr_loggedin_user_details->[0]->{email_address};

	}


	$c->stash(template => 'allele/AlleleMultiTypeResult.tt2', loci_int_type_set => $loci_int_type_set, loci_count => $loci_count, ins_name => $institution_name, loggedin_user_name => $user_name, email_address => $email_address, page_title => $BATCH_ALLELE_QUERY_RESULTS_PAGE_TITLE );

}

sub download_loci_process :Local :Args(1)
{

	my ($self, $c, $loci_name) = @_;

	$c->log->debug('*** INSIDE download_loci_process METHOD ***');
	$c->log->debug('*** loci_name: ' . $loci_name);

	my $result = 0;
	my $option = "download";
	my @options = ($OPTION_DOWNLOAD);


	my $has_error = $FALSE;

	if($option !~ /^[A-Z]+$/i)
	{

		$has_error = $TRUE;

	}

	my $obj;

	if(not $has_error)
	{

		if(lc($option) eq lc($options[0]))
		{

			$obj = $c->model('GetAlleleInfo');
			$result = $obj->_get_loci_alleles_format($loci_name);

			if(not $result)
			{

				my $err_msg = $c->loc($ERROR_BASE_STRING.$result);
				$c->stash(error_id => $result, error_code => $err_msg);

			}
			else
			{

				$self->export_alleles($c, $loci_name, $result);

			}

		}
		else
		{

			my $err_msg = $c->loc($ERROR_BASE_STRING.$ERROR_CODE_INVALID_OPTION);
			$c->stash(error_id => $ERROR_CODE_INVALID_OPTION, error_code => $err_msg);


		}

	}
	else
	{

		my $err_msg = $c->loc($ERROR_BASE_STRING.$ERROR_CODE_INVALID_OPTION);
		$c->stash(error_id => $ERROR_CODE_INVALID_OPTION, error_code => $err_msg);

	}

}

sub download_metadata_process :Local :Args(1)
{

	my ($self, $c, $loci_name) = @_;

	$c->log->debug('*** INSIDE download_metadata_process METHOD ***');
	$c->log->debug('*** loci_name: ' . $loci_name);

	my $result = 0;
	my $option = "download";
	my @options = ($OPTION_DOWNLOAD);
	my $has_error = $FALSE;

	if($option !~ /^[A-Z]+$/i)
	{

		$has_error = $TRUE;

	}

	my $obj;

	if(not $has_error)
	{

		if(lc($option) eq lc($options[0]))
		{

			$obj = $c->model('GetMetadata');

			my $localized_header .= $c->loc("shared.allele.type.text")."\t".$c->loc("shared.collection.date.text") . "\t". $c->loc("shared.country.text") ."\t". $c->loc("shared.patient.age.text") ."\t". $c->loc("shared.patient.gender.text")."\t".$c->loc("shared.beta.lactamase.text") ."\t". $c->loc("shared.isolate.classifications.text")."\t".$c->loc("shared.mics.determination.text"). "\t".$c->loc("Azithromycin")."\t".$c->loc("Cefixime"). "\t".$c->loc("Ceftriaxone"). "\t".$c->loc("Ciprofloxacin"). "\t".$c->loc("Erythromycin"). "\t".$c->loc("Penicillin"). "\t".$c->loc("Spectinomycin"). "\t".$c->loc("Tetracycline"). "\t".$c->loc("shared.additional.epi.data.text")."\t".$c->loc("shared.curator.comments.text")."\n";



			$result = $obj->_get_allele_metadata($loci_name, $localized_header);

			if(not $result)
			{

				my $err_msg = $c->loc($ERROR_BASE_STRING.$result);
				$c->stash(error_id => $result, error_code => $err_msg);

			}
			else
			{

				$self->export_metadata($c, $loci_name, $result);

			}

		}
		else
		{

			my $err_msg = $c->loc($ERROR_BASE_STRING.$ERROR_CODE_INVALID_OPTION);
			$c->stash(error_id => $ERROR_CODE_INVALID_OPTION, error_code => $err_msg);

		}

	}
	else
	{

		my $err_msg = $c->loc($ERROR_BASE_STRING.$ERROR_CODE_INVALID_OPTION);
		$c->stash(error_id => $ERROR_CODE_INVALID_OPTION, error_code => $err_msg);

	}

}

sub edit :Local :Args(2)
{

	my ($self, $c, $loci_name_prev, $allele_type_prev) = @_;

	if($c->stash->{'login_allow'} eq "true")
	{

		if($c->user_exists() and $c->check_any_user_role(qw/ user admin /))
		{

			my $obj;
			$obj = $c->model('GetIntegerType');
			my $loci_int_type_set = $obj->_get_loci_with_integer_type();

			if((%$loci_int_type_set) and (exists $loci_int_type_set->{$loci_name_prev}))
			{

				$allele_type_prev = int($allele_type_prev);

			}

			my $result;
			my @options = ($OPTION_NONE,$OPTION_ETEST,$OPTION_AGAR_DILUTION,$OPTION_DISC_DIFFUSION);

			$obj = $c->model('GetAlleleInfo');
			my $loci_name_list = $obj->_get_all_loci_names();
			my $allele_details = $obj->_get_allele_details($loci_name_prev, $allele_type_prev);

			$obj = $c->model('GetMetadata');
			my $antimicrobial_name_list = $obj->_get_mic_antimicrobial_names();
			my $classification_list = $obj->_get_all_isolate_classifications();
			my $metadata = $obj->_get_metadata($allele_type_prev, $loci_name_prev);
			my $mic_list = $obj->_get_metadata_mics($allele_type_prev, $loci_name_prev);
			my $interpretation_list = $obj->_get_metadata_interpretations($allele_type_prev, $loci_name_prev);
			my $isolate_classifications_list = $obj->_get_metadata_classifications($allele_type_prev, $loci_name_prev);
			my $err_msg;

			my $classification_code_on_error = $c->request->params->{isolate_classification};


			if($loci_name_list and $allele_details and $antimicrobial_name_list and $classification_list and $metadata and $mic_list and $isolate_classifications_list)
			{

				my @locis = map { $_, $_ } @{$loci_name_list};

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
				elsif(($c->request->referer eq $c->request->uri) and (not $classification_code_on_error))
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

				my $curr_lang = $c->session->{lang};
				my $lh = NGSTAR::I18N::i_default->new;

				if($c->session->{lang})
				 {
					if($c->session->{lang} eq $TRANSLATION_LANG)
					{
						$lh = NGSTAR::I18N::fr->new;
					}
				   }

				my $form = NGSTAR::Form::EditAlleleForm->new(
					language_handle => $lh,
					field_list => [
						'loci_name_option' => {
							do_label => 1,
							type => 'Select',
							label => 'shared.loci.name.text',
							label_class => 'col-sm-2',
							element_wrapper_class => 'col-sm-10',
							required => 1,
							options => \@locis,
							default => $loci_name_prev
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
						'mics_determined_by_option'=>{
									do_label => 1,
									type => 'Select',
									label => 'shared.mics.determination.text',
									label_class => 'col-sm-2',
									element_wrapper_class => 'col-sm-10',
									widget => 'radio_group',
									multiple => 0,
									options => [{value=> '' , label => $c->loc('shared.none.text') },
												{value=> 'E-Test' , label => $c->loc('shared.etest.text') },
											  {value=> 'Agar Dilution' , label => $c->loc('shared.agar.dilution.text') },
											  {value=> 'Disc Diffusion', label => $c->loc('shared.disc.diffusion.text') }],
									  default => $metadata->{mics_determined_by}
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
							element_attr => { class => 'input-full' },
							required => 0,
							minlength => 1,
							maxlength => 6,
							validate_method => \&check_mic
						},
						$antimicrobial_name_list->[1] => {
							do_label => 0,
							type => 'Text',
							element_wrapper_class => 'col-sm-offset-2 col-sm-10',
							element_attr => { class => 'input-full' },
							required => 0,
							minlength => 1,
							maxlength => 6,
							validate_method => \&check_mic
						},
						$antimicrobial_name_list->[2] => {
							do_label => 0,
							type => 'Text',
							element_wrapper_class => 'col-sm-offset-2 col-sm-10',
							element_attr => { class => 'input-full' },
							required => 0,
							minlength => 1,
							maxlength => 6,
							validate_method => \&check_mic
						},
						$antimicrobial_name_list->[3] => {
							do_label => 0,
							type => 'Text',
							element_wrapper_class => 'col-sm-offset-2 col-sm-10',
							element_attr => { class => 'input-full' },
							required => 0,
							minlength => 1,
							maxlength => 6,
							validate_method => \&check_mic
						},
						$antimicrobial_name_list->[4] => {
							do_label => 0,
							type => 'Text',
							element_wrapper_class => 'col-sm-offset-2 col-sm-10',
							element_attr => { class => 'input-full' },
							required => 0,
							minlength => 1,
							maxlength => 6,
							validate_method => \&check_mic
						},
						$antimicrobial_name_list->[5] => {
							do_label => 0,
							type => 'Text',
							element_wrapper_class => 'col-sm-offset-2 col-sm-10',
							element_attr => { class => 'input-full' },
							required => 0,
							minlength => 1,
							maxlength => 6,
							validate_method => \&check_mic
						},
						$antimicrobial_name_list->[6] => {
							do_label => 0,
							type => 'Text',
							element_wrapper_class => 'col-sm-offset-2 col-sm-10',
							element_attr => { class => 'input-full' },
							required => 0,
							minlength => 1,
							maxlength => 6,
							validate_method => \&check_mic
						},
						$antimicrobial_name_list->[7] => {
							do_label => 0,
							type => 'Text',
							element_wrapper_class => 'col-sm-offset-2 col-sm-10',
							element_attr => { class => 'input-full' },
							required => 0,
							minlength => 1,
							maxlength => 6,
							validate_method => \&check_mic
						},
						$antimicrobial_name_list->[0].'_interpretation_option' => {
							do_label => 1,
							type => 'Select',
							label => $antimicrobial_name_list->[0],
							tags => { label_after => " ".$c->loc('shared.interpretation.text') },
							label_class => 'col-sm-2',
							element_wrapper_class => 'col-sm-10',
							element_attr => { class => 'input-full' },
							required => 0,
							options => [{value => 'Unknown', label => $c->loc('shared.unknown.text')},
										{value => 'Intermediate', label => $c->loc('shared.intermediate.text')},
										{value => 'Resistant', label => $c->loc('shared.resistant.text')},
										{value => 'Susceptible', label => $c->loc('shared.susceptible.text')}],
							default => $interpretation_list->[0]->{interpretation_value}
						},
						$antimicrobial_name_list->[1].'_interpretation_option' => {
							do_label => 1,
							type => 'Select',
							label => $antimicrobial_name_list->[1],
							tags => { label_after => " ".$c->loc('shared.interpretation.text') },
							label_class => 'col-sm-2',
							element_wrapper_class => 'col-sm-10',
							element_attr => { class => 'input-full' },
							required => 0,
							options => [{value => 'Unknown', label => $c->loc('shared.unknown.text')},
										{value => 'Intermediate', label => $c->loc('shared.intermediate.text')},
										{value => 'Resistant', label => $c->loc('shared.resistant.text')},
										{value => 'Susceptible', label => $c->loc('shared.susceptible.text')}],
							default => $interpretation_list->[1]->{interpretation_value}
						},
						$antimicrobial_name_list->[2].'_interpretation_option' => {
							do_label => 1,
							type => 'Select',
							label => $antimicrobial_name_list->[2],
							tags => { label_after => " ".$c->loc('shared.interpretation.text') },
							label_class => 'col-sm-2',
							element_wrapper_class => 'col-sm-10',
							element_attr => { class => 'input-full' },
							required => 0,
							options => [{value => 'Unknown', label => $c->loc('shared.unknown.text')},
										{value => 'Intermediate', label => $c->loc('shared.intermediate.text')},
										{value => 'Resistant', label => $c->loc('shared.resistant.text')},
										{value => 'Susceptible', label => $c->loc('shared.susceptible.text')}],
							default => $interpretation_list->[2]->{interpretation_value}
						},
						$antimicrobial_name_list->[3].'_interpretation_option' => {
							do_label => 1,
							type => 'Select',
							label => $antimicrobial_name_list->[3],
							tags => { label_after => " ".$c->loc('shared.interpretation.text') },
							label_class => 'col-sm-2',
							element_wrapper_class => 'col-sm-10',
							element_attr => { class => 'input-full' },
							required => 0,
							options => [{value => 'Unknown', label => $c->loc('shared.unknown.text')},
										{value => 'Intermediate', label => $c->loc('shared.intermediate.text')},
										{value => 'Resistant', label => $c->loc('shared.resistant.text')},
										{value => 'Susceptible', label => $c->loc('shared.susceptible.text')}],
							default => $interpretation_list->[3]->{interpretation_value}
						},
						$antimicrobial_name_list->[4].'_interpretation_option' => {
							do_label => 1,
							type => 'Select',
							label => $antimicrobial_name_list->[4],
							tags => { label_after => " ".$c->loc('shared.interpretation.text') },
							label_class => 'col-sm-2',
							element_wrapper_class => 'col-sm-10',
							element_attr => { class => 'input-full' },
							required => 0,
							options => [{value => 'Unknown', label => $c->loc('shared.unknown.text')},
										{value => 'Intermediate', label => $c->loc('shared.intermediate.text')},
										{value => 'Resistant', label => $c->loc('shared.resistant.text')},
										{value => 'Susceptible', label => $c->loc('shared.susceptible.text')}],
							default => $interpretation_list->[4]->{interpretation_value}
						},
						$antimicrobial_name_list->[5].'_interpretation_option' => {
							do_label => 1,
							type => 'Select',
							label => $antimicrobial_name_list->[5],
							tags => { label_after => " ".$c->loc('shared.interpretation.text') },
							label_class => 'col-sm-2',
							element_wrapper_class => 'col-sm-10',
							element_attr => { class => 'input-full' },
							required => 0,
							options => [{value => 'Unknown', label => $c->loc('shared.unknown.text')},
										{value => 'Intermediate', label => $c->loc('shared.intermediate.text')},
										{value => 'Resistant', label => $c->loc('shared.resistant.text')},
										{value => 'Susceptible', label => $c->loc('shared.susceptible.text')}],
							default => $interpretation_list->[5]->{interpretation_value}
						},
						$antimicrobial_name_list->[6].'_interpretation_option' => {
							do_label => 1,
							type => 'Select',
							label => $antimicrobial_name_list->[6],
							tags => { label_after => " ".$c->loc('shared.interpretation.text') },
							label_class => 'col-sm-2',
							element_wrapper_class => 'col-sm-10',
							element_attr => { class => 'input-full' },
							required => 0,
							options => [{value => 'Unknown', label => $c->loc('shared.unknown.text')},
										{value => 'Intermediate', label => $c->loc('shared.intermediate.text')},
										{value => 'Resistant', label => $c->loc('shared.resistant.text')},
										{value => 'Susceptible', label => $c->loc('shared.susceptible.text')}],
							default => $interpretation_list->[6]->{interpretation_value}
						},
						$antimicrobial_name_list->[7].'_interpretation_option' => {
							do_label => 1,
							type => 'Select',
							label => $antimicrobial_name_list->[7],
							tags => { label_after => " ".$c->loc('shared.interpretation.text') },
							label_class => 'col-sm-2',
							element_wrapper_class => 'col-sm-10',
							element_attr => { class => 'input-full' },
							required => 0,
							options => [{value => 'Unknown', label => $c->loc('shared.unknown.text')},
										{value => 'Intermediate', label => $c->loc('shared.intermediate.text')},
										{value => 'Resistant', label => $c->loc('shared.resistant.text')},
										{value => 'Susceptible', label => $c->loc('shared.susceptible.text')}],
							default => $interpretation_list->[7]->{interpretation_value}
						},
					],
					ctx => $c,
				);

				$form->process(update_field_list => {
					allele_type => {messages => {required => $c->loc('shared.enter.allele.type.form.error.msg')}},
					allele_sequence => {messages => {required => $c->loc('shared.enter.sequence.msg')}},
					collection_date => {element_attr => { placeholder => $c->loc("shared.date.format")}},
					csrf => {default => $c->session->{csrf_token} },
				});

				$c->stash(template => 'allele/EditAlleleForm.tt2', form => $form, ics => $isolate_classification_codes, antimicrobial_name_list => $antimicrobial_name_list, classification_list => $classification_list, loci_name => $loci_name_prev, loci_name_list => $loci_name_list, metadata => $metadata, mic_list => $mic_list, interpretation_list => $interpretation_list, page_title => $EDIT_ALLELE_PAGE_TITLE, prev_loci_name => $loci_name_prev);
				my $patient_age;

				if($metadata->{patient_age})
				{

					if($metadata->{patient_age} == 0 || $metadata->{patient_age} eq "" )
					{

						$patient_age = "";

					}
					else
					{

						$patient_age = $metadata->{patient_age};

					}

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

				#Datepicker will display an empty field on edit allele page when no date was entered when allele was added.
				#Without this it displays 0000-00-00
				my $collection_date_prev = $metadata->{collection_date};

				if(not $collection_date_prev)
				{

					$collection_date_prev = "";

				}

				my $allele_type_to_edit = $allele_details->allele_type;

				if((%$loci_int_type_set) and (exists $loci_int_type_set->{$loci_name_prev}))
				{

					$allele_type_to_edit = int($allele_type_to_edit);

				}

				$form->process(update_field_list => {
					allele_type => {default => $allele_type_to_edit},
					allele_sequence => {default => $allele_details->allele_sequence},
					amr_markers => {default => $metadata->{amr_markers}},
					country => {default => $metadata->{country}},
					patient_age => {default => $patient_age},
					collection_date => {default => $collection_date_prev},
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
				params => $c->request->params);
				return unless $form->validated;

				my $loci_name_new = $c->request->params->{loci_name_option};
				my $allele_type_new = $c->request->params->{allele_type};
				my $sequence = $c->request->params->{allele_sequence};


				#get meta-data
				#to do: validate request parameters
				my $amr_marker_string = $c->request->params->{amr_markers};
				my $country = $c->request->params->{country};
				$patient_age = $c->request->params->{patient_age};
				my $patient_gender = $c->request->params->{patient_gender};
				my $collection_date = $c->request->params->{collection_date};
				my $classification_code = $c->request->params->{isolate_classification};
				my $beta_lactamase = $c->request->params->{beta_lactamase};
				my $epi_data = $c->request->params->{epi_data};
				my $curator_comment = $c->request->params->{curator_comment};
				my $mics_determined_by = $c->request->params->{mics_determined_by_option};
				my $csrf_form_submitted = $c->request->params->{csrf};


				if($csrf_form_submitted and $csrf_form_submitted eq $c->session->{csrf_token})
				{

					if($patient_age eq "")
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

					my %mic_map;
					my %interpretation_map;

					if($mics_determined_by eq $options[0])
					{

						undef %mic_map;
						undef %interpretation_map;

					}
					elsif(lc($mics_determined_by) ne lc($options[3]) && lc($mics_determined_by) ne lc($options[0]))
					{

						foreach my $name (@$antimicrobial_name_list)
						{

							my $comparator_key = $name . "_comparator_option";
							$mic_map{$name}{mic_comparator} = $c->request->params->{$comparator_key};
							$c->log->debug('\ncomparator: ' . $mic_map{$name}{mic_comparator});

							if($c->request->params->{$name} and length $c->request->params->{$name} > 0)
							{
								$mic_map{$name}{mic_value} = $c->request->params->{$name};
							}
							else
							{
								$mic_map{$name}{mic_value} = undef;
							}

							undef %interpretation_map;

						}

					}
					else
					{

						foreach my $name (@$antimicrobial_name_list)
						{

							my $mic_name = $name . "_interpretation_option";
							$interpretation_map{$name}{interpretation_value} = $c->request->params->{$mic_name};
							$c->log->debug('\nInterpretation: ' . $interpretation_map{$name}{interpretation_value});
							undef %mic_map;

						 }

					}


					my $error_code;

					$sequence =~ s/(\s+)//g;

					my $loci_name_exists = $FALSE;

					foreach my $loci_in_list (@$loci_name_list)
					{
						if(lc($loci_in_list) eq lc($loci_name_new))
						{
							$loci_name_exists = $TRUE;
						}

					}

					if(not $loci_name_exists)
					{

						$error_code = $ERROR_INVALID_LOCI_NAME;

					}
					elsif($allele_type_new !~ /^[0-9]\d*(\.\d{0,3})?$/)
					{

						$error_code = $ERROR_INVALID_ALLELE_TYPE;

					}
					elsif($sequence !~ /^[ATCG]+$/i)
					{

						$error_code = $ERROR_INVALID_ALLELE_SEQUENCE;

					}

					if(defined $error_code)
					{

						$err_msg = $c->loc($ERROR_BASE_STRING.$error_code);
						$c->stash(error_id => $error_code, error_code => $err_msg);

					}
					else
					{


						$obj = $c->model('EditAllele');
						$result = $obj->_edit_allele($loci_name_new, $allele_type_new, $sequence, $loci_name_prev, $allele_type_prev, $country, $patient_age, $patient_gender, $epi_data, $curator_comment, $beta_lactamase, $formatted_classification_code, \%mic_map, $mics_determined_by, $collection_date, \%interpretation_map, $amr_marker_string);

						if($result eq $VALID_CONST)
						{

							$obj = $c->model('ConvertSequences');

							my $is_onishi_type = $FALSE;
							my $onishi_type_set = $obj->_get_loci_with_onishi_type();
							my $aa_profile_exists = $FALSE;
							my $aa_profile;

							if((%$onishi_type_set) and (exists $onishi_type_set->{$loci_name_new}))
							{
								$is_onishi_type = $TRUE;

								#check if onishi aminio acid profile exists for the allele sequence provided
								($aa_profile_exists, $aa_profile) = $obj->_check_amino_acid_profile($sequence);

							}

							$c->session->{csrf_token} = Session::Token->new(length => 128)->get;

							#if amino acid profile exists or loci is not an onishi type it will redirect to list alleles page otherwise user is redirected to the add amino acid profile page
							if($aa_profile_exists == $TRUE or $is_onishi_type == $FALSE)
							{
								$c->flash(edit_notification => $NOTIFICATION_ON);
								$c->response->redirect($c->uri_for($self->action_for('list_loci_alleles'), $loci_name_new,$allele_type_new));
							}
							else
							{
								$c->flash(edit_notification => $NOTIFICATION_ON);
								$c->response->redirect($c->uri_for($c->controller('Curator')->action_for('edit_amino_acid_profile'), $aa_profile));
							}


						}
						else
						{

							$obj = $c->model('GetAlleleInfo');
							my ($type_with_seq_exists, $type_found) = $obj->_get_type_by_sequence($loci_name_new, $sequence);


							if((%$loci_int_type_set) and (exists $loci_int_type_set->{$loci_name_new}))
							{

								$type_with_seq_exists = int($type_with_seq_exists);

							}

							my $formatted_type;


							if(defined $type_found && $type_found != $INVALID_TYPE)
							{

								if((%$loci_int_type_set) and (exists $loci_int_type_set->{$loci_name_new}))
								{

									$formatted_type = int($allele_type_new);

								}
								else
								{
									$formatted_type = sprintf ("%.3f", $allele_type_new);
								}

								$err_msg = $c->loc($ERROR_BASE_STRING.$result);

								$err_msg =  named_sprintf($err_msg, { allele_type => $formatted_type, loci_name => $loci_name_new });

								$c->stash(error_id => $result, error_code => $err_msg);


							}
							else
							{

								$err_msg = $c->loc($ERROR_BASE_STRING.$result);

								$err_msg =  named_sprintf($err_msg, {allele_type => $type_with_seq_exists, loci_name => $loci_name_new });

								$c->stash(error_id => $result, error_code => $err_msg);

							}


						}

					}

				}
				else
				{

					$c->response->redirect($c->uri_for($self->action_for('edit'), $loci_name_prev, $allele_type_prev));

				}

			}
			else
			{

				my $err_msg = $c->loc($ERROR_BASE_STRING.$ERROR_CODE_NO_DATA);
				$c->stash(error_id => $ERROR_CODE_NO_DATA, error_code => $err_msg);

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

sub email_allele :Local
{

	my ($self, $c, $default_loci) = @_;

	my $obj = $c->model('GetAlleleInfo');
	my $loci_name_list = $obj->_get_all_loci_names();

	$default_loci ||= $loci_name_list->[0];

	$obj = $c->model('GetMetadata');
	my $classification_list = $obj->_get_all_isolate_classifications();
	my $antimicrobial_name_list = $obj->_get_mic_antimicrobial_names();

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
		my $form = NGSTAR::Form::EmailAlleleForm->new(
			language_handle => $lh,
				field_list => [
				'loci_name_option' => {
					do_label => 1,
					type => 'Select',
					label => 'shared.loci.name.text',
					label_class => 'col-sm-2',
					element_wrapper_class => 'col-sm-10',
					required => 1,
					options => \@locis,
					default => $default_loci
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
				'mics_determined_by_option'=>{
							  do_label => 1,
							  type => 'Select',
							  label => 'shared.mics.determination.text',
							  label_class => 'col-sm-2',
							  element_wrapper_class => 'col-sm-10',
							  widget => 'radio_group',
							  multiple => 0,
							  options => [{value=> '' , label => $c->loc('shared.none.text') },
										  {value=> 'E-Test' , label => $c->loc('shared.etest.text') },
										  {value=> 'Agar Dilution' , label => $c->loc('shared.agar.dilution.text') },
										  {value=> 'Disc Diffusion', label => $c->loc('shared.disc.diffusion.text') }],
							  default => ''
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
					element_attr => { class => 'input-full' },
					required => 0,
					minlength => 1,
					maxlength => 6,
					validate_method => \&check_mic
				},
				$antimicrobial_name_list->[1] => {
					do_label => 0,
					type => 'Text',
					element_wrapper_class => 'col-sm-offset-2 col-sm-10',
					element_attr => { class => 'input-full' },
					required => 0,
					minlength => 1,
					maxlength => 6,
					validate_method => \&check_mic
				},

				$antimicrobial_name_list->[2] => {
					do_label => 0,
					type => 'Text',
					element_wrapper_class => 'col-sm-offset-2 col-sm-10',
					element_attr => { class => 'input-full' },
					required => 0,
					minlength => 1,
					maxlength => 6,
					validate_method => \&check_mic
				},
				$antimicrobial_name_list->[3] => {
					do_label => 0,
					type => 'Text',
					element_wrapper_class => 'col-sm-offset-2 col-sm-10',
					element_attr => { class => 'input-full' },
					required => 0,
					minlength => 1,
					maxlength => 6,
					validate_method => \&check_mic
				},
				$antimicrobial_name_list->[4] => {
					do_label => 0,
					type => 'Text',
					element_wrapper_class => 'col-sm-offset-2 col-sm-10',
					element_attr => { class => 'input-full' },
					required => 0,
					minlength => 1,
					maxlength => 6,
					validate_method => \&check_mic
				},
				$antimicrobial_name_list->[5] => {
					do_label => 0,
					type => 'Text',
					element_wrapper_class => 'col-sm-offset-2 col-sm-10',
					element_attr => { class => 'input-full' },
					required => 0,
					minlength => 1,
					maxlength => 6,
					validate_method => \&check_mic
				},
				$antimicrobial_name_list->[6] => {
					do_label => 0,
					type => 'Text',
					element_wrapper_class => 'col-sm-offset-2 col-sm-10',
					element_attr => { class => 'input-full' },
					required => 0,
					minlength => 1,
					maxlength => 6,
					validate_method => \&check_mic
				},
				$antimicrobial_name_list->[7] => {
					do_label => 0,
					type => 'Text',
					element_wrapper_class => 'col-sm-offset-2 col-sm-10',
					element_attr => { class => 'input-full' },
					required => 0,
					minlength => 1,
					maxlength => 6,
					validate_method => \&check_mic
				},
				$antimicrobial_name_list->[0].'_interpretation_option' => {
					do_label => 1,
					type => 'Select',
					label => $antimicrobial_name_list->[0],
					tags => { label_after => " ".$c->loc('shared.interpretation.text') },
					label_class => 'col-sm-2',
					element_wrapper_class => 'col-sm-10',
					element_attr => { class => 'input-full' },
					required => 0,
					options => [{value => 'Unknown', label => $c->loc('shared.unknown.text')},
								{value => 'Intermediate', label => $c->loc('shared.intermediate.text')},
								{value => 'Resistant', label => $c->loc('shared.resistant.text')},
								{value => 'Susceptible', label => $c->loc('shared.susceptible.text')}],
					default => 'Unknown'
				},
				$antimicrobial_name_list->[1].'_interpretation_option' => {
					do_label => 1,
					type => 'Select',
					label => $antimicrobial_name_list->[1],
					tags => { label_after => " ".$c->loc('shared.interpretation.text') },
					label_class => 'col-sm-2',
					element_wrapper_class => 'col-sm-10',
					element_attr => { class => 'input-full' },
					required => 0,
					options => [{value => 'Unknown', label => $c->loc('shared.unknown.text')},
								{value => 'Intermediate', label => $c->loc('shared.intermediate.text')},
								{value => 'Resistant', label => $c->loc('shared.resistant.text')},
								{value => 'Susceptible', label => $c->loc('shared.susceptible.text')}],
					default => 'Unknown'
				},
				$antimicrobial_name_list->[2].'_interpretation_option' => {
					do_label => 1,
					type => 'Select',
					label => $antimicrobial_name_list->[2],
					tags => { label_after => " ".$c->loc('shared.interpretation.text') },
					label_class => 'col-sm-2',
					element_wrapper_class => 'col-sm-10',
					element_attr => { class => 'input-full' },
					required => 0,
					options => [{value => 'Unknown', label => $c->loc('shared.unknown.text')},
								{value => 'Intermediate', label => $c->loc('shared.intermediate.text')},
								{value => 'Resistant', label => $c->loc('shared.resistant.text')},
								{value => 'Susceptible', label => $c->loc('shared.susceptible.text')}],
					default => 'Unknown'
				},
				$antimicrobial_name_list->[3].'_interpretation_option' => {
					do_label => 1,
					type => 'Select',
					label => $antimicrobial_name_list->[3],
					tags => { label_after => " ".$c->loc('shared.interpretation.text') },
					label_class => 'col-sm-2',
					element_wrapper_class => 'col-sm-10',
					element_attr => { class => 'input-full' },
					required => 0,
					options => [{value => 'Unknown', label => $c->loc('shared.unknown.text')},
								{value => 'Intermediate', label => $c->loc('shared.intermediate.text')},
								{value => 'Resistant', label => $c->loc('shared.resistant.text')},
								{value => 'Susceptible', label => $c->loc('shared.susceptible.text')}],
					default => 'Unknown'
				},
				$antimicrobial_name_list->[4].'_interpretation_option' => {
					do_label => 1,
					type => 'Select',
					label => $antimicrobial_name_list->[4],
					tags => { label_after => " ".$c->loc('shared.interpretation.text') },
					label_class => 'col-sm-2',
					element_wrapper_class => 'col-sm-10',
					element_attr => { class => 'input-full' },
					required => 0,
					options => [{value => 'Unknown', label => $c->loc('shared.unknown.text')},
								{value => 'Intermediate', label => $c->loc('shared.intermediate.text')},
								{value => 'Resistant', label => $c->loc('shared.resistant.text')},
								{value => 'Susceptible', label => $c->loc('shared.susceptible.text')}],
					default => 'Unknown'
				},
				$antimicrobial_name_list->[5].'_interpretation_option' => {
					do_label => 1,
					type => 'Select',
					label => $antimicrobial_name_list->[5],
					tags => { label_after => " ".$c->loc('shared.interpretation.text') },
					label_class => 'col-sm-2',
					element_wrapper_class => 'col-sm-10',
					element_attr => { class => 'input-full' },
					required => 0,
					options => [{value => 'Unknown', label => $c->loc('shared.unknown.text')},
								{value => 'Intermediate', label => $c->loc('shared.intermediate.text')},
								{value => 'Resistant', label => $c->loc('shared.resistant.text')},
								{value => 'Susceptible', label => $c->loc('shared.susceptible.text')}],
					default =>'Unknown'
				},
				$antimicrobial_name_list->[6].'_interpretation_option' => {
					do_label => 1,
					type => 'Select',
					label => $antimicrobial_name_list->[6],
					tags => { label_after => " ".$c->loc('shared.interpretation.text') },
					label_class => 'col-sm-2',
					element_wrapper_class => 'col-sm-10',
					element_attr => { class => 'input-full' },
					required => 0,
					options => [{value => 'Unknown', label => $c->loc('shared.unknown.text')},
								{value => 'Intermediate', label => $c->loc('shared.intermediate.text')},
								{value => 'Resistant', label => $c->loc('shared.resistant.text')},
								{value => 'Susceptible', label => $c->loc('shared.susceptible.text')}],
					default => 'Unknown'
				},
				$antimicrobial_name_list->[7].'_interpretation_option' => {
					do_label => 1,
					type => 'Select',
					label => $antimicrobial_name_list->[7],
					tags => { label_after => " ".$c->loc('shared.interpretation.text') },
					label_class => 'col-sm-2',
					element_wrapper_class => 'col-sm-10',
					element_attr => { class => 'input-full' },
					required => 0,
					options => [{value => 'Unknown', label => $c->loc('shared.unknown.text')},
								{value => 'Intermediate', label => $c->loc('shared.intermediate.text')},
								{value => 'Resistant', label => $c->loc('shared.resistant.text')},
								{value => 'Susceptible', label => $c->loc('shared.susceptible.text')}],
					default => 'Unknown'
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
			allele_sequence => {messages => {required => $c->loc('shared.enter.sequence.msg')}},
			collection_date => {element_attr => { placeholder => $c->loc("shared.date.format")}},
			csrf => {default => $c->session->{csrf_token} },
		});

		$c->stash(template => 'allele/EmailAlleleForm.tt2', form => $form, antimicrobial_name_list => $antimicrobial_name_list, classification_list => $classification_list, loci_name_list => $loci_name_list, page_title => $EMAIL_ALLELE_PAGE_TITLE);

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
		$form->process(params => $c->request->params);
		return unless $form->validated;

		my @options = ($OPTION_NONE,$OPTION_ETEST,$OPTION_AGAR_DILUTION,$OPTION_DISC_DIFFUSION);

		my $first_name = $c->request->params->{first_name};
		my $last_name = $c->request->params->{last_name};
		my $email_address = $c->request->params->{email_address};
		my $institution_name = $c->request->params->{institution_name};
		my $institution_country = $c->request->params->{institution_country};
		my $institution_city = $c->request->params->{institution_city};
		my $comments = $c->request->params->{comments};
		my $loci_name = $c->request->params->{loci_name_option};
		my $allele_sequence = $c->request->params->{allele_sequence};

		#get meta-data
		#to do: validate request parameters
		my $collection_date = $c->request->params->{collection_date};
		my $country = $c->request->params->{country};
		my $patient_age = $c->request->params->{patient_age};
		my $patient_gender = $c->request->params->{patient_gender};
		my $beta_lactamase = $c->request->params->{beta_lactamase};
		my $classification_code = $c->request->params->{isolate_classification};
		my $epi_data = $c->request->params->{epi_data};
		my $mics_determined_by = $c->request->params->{mics_determined_by_option};
		my $csrf_form_submitted = $c->request->params->{csrf};

		my $upload = $c->request->upload('trace_file');
		my $has_error = $FALSE;
		my $err_msg;
		my $error_code;

		if($csrf_form_submitted and $csrf_form_submitted eq $c->session->{csrf_token})
		{
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
				my %interpretation_map;

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


				if($mics_determined_by eq $options[0])
				{

					undef %mic_map;
					undef %interpretation_map;

				}
				elsif(lc($mics_determined_by) ne lc($options[3]) &&  $mics_determined_by ne lc($options[0]))
				{

					foreach my $name (@$antimicrobial_name_list)
					{

						my $comparator_key = $name . "_comparator_option";
						$mic_map{$name}{mic_comparator} = $c->request->params->{$comparator_key};
						$c->log->debug('\ncomparator: ' . $mic_map{$name}{mic_comparator});
						$mic_map{$name}{mic_value} = $c->request->params->{$name};

					}

				}
				else
				{

					foreach my $name (@$antimicrobial_name_list)
					{

						my $comparator_key = $name . "_interpretation_option";
						$interpretation_map{$name}{interpretation_value} = $c->request->params->{$comparator_key};
						$c->log->debug('\nInterpretation: ' . $interpretation_map{$name}{interpretation_value});

					}

				}

				$allele_sequence =~ s/(\s+)//g;     #remove any whitespace

				my $loci_name_exists = $FALSE;

				foreach my $loci_in_list (@$loci_name_list)
				{
					if(lc($loci_in_list) eq lc($loci_name))
					{
						$loci_name_exists = $TRUE;
					}
				}

				if(not $loci_name_exists)
				{

					$error_code = $ERROR_INVALID_LOCI_NAME;

				}
				elsif($allele_sequence !~ /^[ATCG]+$/i)
				{

					$error_code = $ERROR_INVALID_ALLELE_SEQUENCE;

				}



				if(defined $error_code)
				{

					$err_msg = $c->loc($ERROR_BASE_STRING.$error_code);
					$c->stash(error_id => $error_code, error_code => $err_msg);

				}


				else
				{

					$obj = $c->model('ValidateEmailForm');

					my $validate_result = $obj->_validate_email_form($first_name, $last_name, $email_address, $institution_name, $institution_country, $institution_city, $comments, $loci_name, $allele_sequence, $country, $patient_age, $patient_gender, $epi_data, $beta_lactamase, $formatted_classification_code, \%mic_map, $mics_determined_by, $collection_date, \%interpretation_map);

					if($validate_result)
					{

						$c->session->{csrf_token} = Session::Token->new(length => 128)->get;

						$self->send_email($c, $first_name, $last_name, $email_address, $institution_name, $institution_country, $institution_city, $comments, $loci_name, $allele_sequence, $collection_date, $country, $patient_age, $patient_gender, $epi_data, $beta_lactamase, $formatted_classification_code, $mics_determined_by, \%mic_map, \%interpretation_map, $antimicrobial_name_list, $upload);

						$c->flash(sent_email_notification => $NOTIFICATION_ON);
						$c->response->redirect($c->uri_for($self->action_for('email_allele')));

					}
					else
					{

						$err_msg = $c->loc($ERROR_BASE_STRING.$validate_result);
						$c->stash(error_id => $validate_result, error_code => $err_msg);

					}

				}

			}

		}
		else
		{

			$c->response->redirect($c->uri_for($self->action_for('email_allele')));

		}

	}

}

sub export_alleles
{

	my ($self, $c, $loci_name, $contents) = @_;

	my $filename = $loci_name . '.fasta';

	$c->response->content_type('text/plain');
	$c->response->header('Content-Disposition', qq[attachment; filename="$filename"]);
	$c->response->body($contents);

}

sub export_metadata
{

	my ($self, $c, $loci_name, $contents) = @_;

	my $filename = $loci_name . '_metadata.txt';

	$c->response->content_type('text/plain');
	$c->response->header('Content-Disposition', qq[attachment; filename="$filename"]);
	$c->response->body($contents);

}

sub export_batch_allele_query_results :Local :Args()
{
	my ($self, $c) = @_;

	my $str = $c->request->params->{csv_str};

	if(not $str)
	{
		$str = $c->request->params->{tsv_str};

	}

	my $filename = "batch_allele_query_results.txt";
	$c->response->content_type('text/plain');
	$c->response->header('Content-Disposition', qq[attachment; filename="$filename"]);
	$c->response->body($str);
}

sub form :Local
{

	my ($self, $c, $msg) = @_;

	$c->log->debug('*** INSIDE form METHOD ***');

	return $self->form_process($c, $msg);


}

sub form_process
{

	my ($self, $c, $msg) = @_;

	$c->log->debug('*** INSIDE form_process METHOD ***');

	my $obj = $c->model('GetAlleleInfo');
	my $result= $obj->_get_all_loci_names();
	my $form_submitted;
	my $err_msg;

	if(not $result)
	{

		$err_msg = $c->loc($ERROR_BASE_STRING.$result);
		$c->stash(error_id => $result, error_code => $err_msg);

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


		my $form_allele = NGSTAR::Form::AlleleForm->new(language_handle => $lh, ctx => $c);

		$form_allele->process(update_field_list => {
			csrf => {default => $c->session->{csrf_token} },
		});

		$c->stash(template => 'allele/AlleleForm.tt2', form => $form_allele, loci_name_list => $result, msg => $msg, page_title => $ALLELE_QUERY_PAGE_TITLE);

		$form_allele->process(params => $c->request->params);
		return unless $form_allele->validated;

		$form_submitted = $c->request->params->{submit_name};
		my $csrf_form_submitted = $c->request->params->{csrf};

		if($csrf_form_submitted and $csrf_form_submitted eq $c->session->{csrf_token})
		{
			$obj = $c->model('GetAlleleInfo');
			my $count = $obj->_get_all_allele_count();

			if($count > 0)
			{

				my %sequence_map;
				my $has_error = $FALSE;

				my $empty_alleles_count = 0;
				my $num_allele_results = 7;

				#get the values from the Allele Query form
				for(my $i = 0; $i < $NUM_SEQUENCES; $i ++)
				{
					my $key = "seq".$i;

					my $sequence = $c->request->params->{$key};
					$sequence =~ s/(\s+)//g;

					if($sequence ne "")
					{

						if($sequence !~ /^[(ATCG)|(\n|\r)]+$/i)
						{
							   $has_error = $TRUE;
						}

					}
					else
					{
						#each allele sequence input box that is empty
						$empty_alleles_count++;
					}

					$sequence_map{$result->[$i]} = $sequence;

				}

				#no error in sequences entered and atleast 1 sequence is entered
				if(not $has_error and $empty_alleles_count < $NUM_SEQUENCES)
				{

					$c->session->{csrf_token} = Session::Token->new(length => 128)->get;


					$self->get_allele_type($c, \%sequence_map,$num_allele_results);

				}
				elsif($empty_alleles_count == $NUM_SEQUENCES)
				{

					$err_msg = $c->loc($ERROR_BASE_STRING.$ERROR_CODE_EMPTY_ALLELES);
					$c->stash(error_id => $ERROR_CODE_EMPTY_ALLELES, error_code => $err_msg);

				}
				else
				{

					$err_msg = $c->loc($ERROR_BASE_STRING.$ERROR_INVALID_ALLELE_SEQUENCE);
					$c->stash(error_id => $ERROR_INVALID_ALLELE_SEQUENCE, error_code => $err_msg);

				}

			}
			else
			{

				$err_msg = $c->loc($ERROR_BASE_STRING.$ERROR_NO_ALLELES);
				$c->stash(error_id => $ERROR_NO_ALLELES, error_code => $err_msg);

			}
		}
		else
		{
			$c->response->redirect($c->uri_for($self->action_for('form')));
		}

	}

}

sub get_allele_type
{

	my ($self, $c, $sequence_map, $size, $is_multi_query) = @_;

	$c->log->debug('*** INSIDE get_allele_type METHOD ***');

	my $obj = $c->model('GetAlleleType');
	$obj->_setup_data("BusinessLogic/data");
	my $result = $obj->_get_allele_types($sequence_map, $is_multi_query);
	$obj->_cleanup_data("BusinessLogic/data");

	#if server side validation catches an error
	if(not $result)
	{

		my $err_msg = $c->loc($ERROR_BASE_STRING.$result);
		$c->stash(error_id => $result, error_code => $err_msg);

	}
	else
	{
		#determine the alleles with multiple 100% matches
		my %allele_counter;
		$allele_counter{is_error} = 0;

		my @metadata_set;
		my $metadata;

		for my $allele (@$result)
		{

			my $loci_name = $allele->{name};
			my $allele_type = $allele->{type};

			$obj = $c->model("GetMetadata");
			$metadata = $obj->_get_metadata($allele_type,$loci_name);

			if($metadata)
			{

				push @metadata_set, $metadata;

			}

			if($allele->{error_msg} eq "OK"){

				if(exists $allele_counter{$loci_name})
				{

					$allele_counter{$loci_name} = $allele_counter{$loci_name} + 1;

				}
				else
				{

					$allele_counter{$loci_name} = 1;

				}

			}
			else
			{

				$allele_counter{$loci_name} = 0;

			}

		}

		$obj = $c->model('GetIntegerType');
		my $loci_int_type_set = $obj->_get_loci_with_integer_type();

		$obj = $c->model('GetAlleleInfo');
		my $all_loci_names= $obj->_get_all_loci_names();


		$c->flash(allele_info_list => $result, metadata_set=>\@metadata_set,  allele_counter => \%allele_counter, loci_int_type_set => $loci_int_type_set, all_loci_names => $all_loci_names);


		if(not $is_multi_query)
		{
			$self->form_process_option($c,$size,$result, $sequence_map);
		}
		else
		{
			$c->response->redirect($c->uri_for($self->action_for('display_multi_types')));
		}
	}

}

sub form_process_option
{

	my ($self, $c, $size,$result, $sequence_map) = @_;


	$c->log->debug('*** INSIDE form_process_option METHOD ***');

	my $obj = $c->model('GetAlleleInfo');
	my $name_list = $obj->_get_all_loci_names;

	if(not $name_list)
	{

		my $err_msg = $c->loc($ERROR_BASE_STRING.$ERROR_CODE_NO_LOCIS);
		$c->stash(error_id => $ERROR_CODE_NO_LOCIS, error_code => $err_msg);

	}
	else
	{

		my $allele_type;
		my %allele_type_map;
		my $form_data;
		my $num_allele_results = 0;
		my $has_error = $FALSE;

		$num_allele_results = $size;

		if($num_allele_results !~ /^(\d+)$/)
		{

			$has_error = $TRUE;

		}

		foreach my $allele (@$result)
		{

			$allele_type_map{$allele->{name}} = $allele->{type};

		}

		foreach my $name (@$name_list)
		{

			my $key = "allele_option_".$name;

			#get the allele type
			my $allele_option = $c->request->params->{$key};

			if((defined $allele_option) and ($allele_option ne ""))
			{

				if($allele_option !~ /^[0-9]\d*(\.\d{0,3})?$/)
				{

					$has_error = $TRUE;

				}

				$allele_type_map{$name} = $allele_option;

			}

		}

		my $match_threshold = 7;
		$self->get_st_profile($c, \%allele_type_map, $match_threshold, $name_list, $sequence_map);


	}

}

sub get_st_profile
{

	my ($self, $c, $allele_type_map, $match_threshold, $name_list, $sequence_map) = @_;

	$c->log->debug('*** INSIDE get_st_profile METHOD ***');

	my $obj = $c->model('GetSequenceTypeInfo');
	my $length = $obj->_get_profile_list_length();
	my @metadata_list;
	my $metadata;
	my $result;
	my $NOT_FOUND = 0;
	my $max_results = 1;

	if($length > 0)
	{

		$obj = $c->model('GetSequenceType');
		$result = $obj->_get_profile_query($allele_type_map, $match_threshold, $max_results);

		if(not $result)
		{

			my $err_msg = $c->loc($ERROR_BASE_STRING.$ERROR_CODE_NO_ST_MATCH);
			$c->stash(error_id => $ERROR_CODE_NO_ST_MATCH, error_code => $err_msg);

			$NOT_FOUND = 1;

		}
		else
		{

			foreach my $profile(@$result)
			{

				$obj = $c->model('GetMetadata');
				$metadata = $obj->_get_metadata($profile->{type});
				push @metadata_list, $metadata;

			}

		}

	}
	else
	{

		$NOT_FOUND = 1;

	}


	$c->flash(st_profile_list => $result, metadata_list => \@metadata_list, allele_type_map => $allele_type_map, name_list => $name_list, st_not_found => $NOT_FOUND, seq_map => $sequence_map);
	$c->response->redirect($c->uri_for($self->action_for('display_types')));

}

sub list_loci_alleles :Local :Args()
{

	my ($self, $c, $loci_name, $allele_type, $error_code) = @_;

	my $obj = $c->model('GetAlleleInfo');
	my $length = $obj->_get_loci_allele_list_length($loci_name);
	my $loci_name_list = $obj->_get_all_loci_names();
	my @metadata_list;
	my $metadata;
	my $err_msg;

	my $loci_name_exists = $FALSE;

	foreach my $loci_in_list (@$loci_name_list)
	{
		if(lc($loci_in_list) eq lc($loci_name))
		{
			$loci_name_exists = $TRUE;
		}
	}
	if(not $loci_name_exists)
	{

		$c->stash(template => 'allele/ListAlleles.tt2', loci_name_list => $loci_name_list , loci_name => $loci_name, is_invalid => $TRUE ,error => $ERROR_INVALID_LOCI_NAME, page_title => $ALLELE_LIST_PAGE_TITLE);

	}
	else
	{

		if($length > 0)
		{

			my $result = $obj->_get_loci_alleles($loci_name);

			if(not $result)
			{

				$err_msg = $c->loc($ERROR_BASE_STRING.$result);
				$c->stash(error_id => $result, error_code => $err_msg);

			}
			else
			{

				$obj = $c->model('GetIntegerType');
				my $loci_int_type_set = $obj->_get_loci_with_integer_type();

				foreach my $allele(@$result)
				{

					if ( exists $loci_int_type_set->{$loci_name})
					{

						$allele->{'allele_type'} = int($allele->{'allele_type'});

					}

					$obj = $c->model('GetMetadata');
					$metadata = $obj->_get_metadata($allele->{allele_type}, $loci_name);
					push @metadata_list, $metadata;

				}

				if(defined $error_code)
				{

					$err_msg = $c->loc($ERROR_BASE_STRING.$error_code);
					$err_msg =  named_sprintf($err_msg, { allele_to_delete_loci_name => $loci_name, allele_type => $allele_type});

				}
				else
				{

					undef $error_code;
					undef $err_msg;
				}

				$c->stash(template => 'allele/ListAlleles.tt2', loci_name_list => $loci_name_list , allele_list => $result, loci_int_type_set => $loci_int_type_set, allele_to_delete_loci_name => $loci_name, loci_name => $loci_name ,allele_type => $allele_type, metadata_list => \@metadata_list, error_id => $error_code, error_code => $err_msg, page_title => $ALLELE_LIST_PAGE_TITLE );

			}

		}
		else
		{

			$c->stash(template => 'allele/ListAlleles.tt2', loci_name_list => $loci_name_list , loci_name => $loci_name , is_invalid => $FALSE, error => $ERROR_NO_ALLELES, page_title => $ALLELE_LIST_PAGE_TITLE);

		}
	}

}

sub send_email
{

	my ($self, $c, $first_name, $last_name, $email_address, $institution_name, $institution_country, $institution_city, $comments,$loci_name, $allele_sequence, $collection_date, $country, $patient_age, $patient_gender, $epi_data, $beta_lactamase, $classification_code, $mics_determined_by,$mic_map, $interpretation_map, $antimicrobial_name_list, $trace_file) = @_;


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
				if ($mic_comparator eq $MIC_COMPARATOR_EQUALS)
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
	elsif(scalar keys %$interpretation_map > 0)
	{

		foreach my $name (@$antimicrobial_name_list)
		{

			my $interpretation_value = $interpretation_map->{$name}{interpretation_value};

			$mics .= $name.": ".$interpretation_value."\n";


		}


	}
	if($trace_file)
	{

		$c->model('CuratorEmail')->send(
			from => $curator_email_address,
			to => $curator_email_address,
			subject => 'New Allele',
			attachment => [$trace_file->tempname, $trace_file->filename], #tempname is a built in field from request upload object and it is what is required for adding the attachment to the email
			plaintext => "First Name: ".$first_name."\n\nLast Name: ".$last_name."\n\nEmail Address: ".$email_address
			."\n\nInstitution Name: ".$institution_name."\n\nInstitution Country: ".$institution_country
			."\n\nInstitution City: ".$institution_city."\n\nComments: ".$comments."\n\nLoci Name: ".$loci_name
			."\n\nAllele Sequence:\n".$allele_sequence."\n\nCollection Date: ".$collection_date
			."\n\nCountry: ".$country."\n\nPatient Age: ".$patient_age
			."\n\nPatient_gender: ".$patient_gender."\n\nEpidemiological Data: ".$epi_data."\n\nBeta-Lactamase: ".$beta_lactamase
			."\n\nIsolate Classification(s): ".$classification_code."\n\nMICs Determined By: ".$mics_determined_by."\n\nMICs:\n".$mics,
		);

	}
	else
	{

		$c->model('CuratorEmail')->send(
			from => $curator_email_address,
			to => $curator_email_address,
			subject => 'New Allele',
			plaintext => "First Name: ".$first_name."\n\nLast Name: ".$last_name."\n\nEmail Address: ".$email_address
			."\n\nInstitution Name: ".$institution_name."\n\nInstitution Country: ".$institution_country
			."\n\nInstitution City: ".$institution_city."\n\nComments: ".$comments."\n\nLoci Name: ".$loci_name
			."\n\nAllele Sequence:\n".$allele_sequence."\n\nCollection Date: ".$collection_date
			."\n\nCountry: ".$country."\n\nPatient Age: ".$patient_age
			."\n\nPatient_gender: ".$patient_gender."\n\nEpidemiological Data: ".$epi_data."\n\nBeta-Lactamase: ".$beta_lactamase
			."\n\nIsolate Classification(s): ".$classification_code."\n\nMICs Determined By: ".$mics_determined_by."\n\nMICs:\n".$mics,
		);

	}

}

sub view_loci_alleles :Local
{

	my ($self, $c) = @_;

	my $obj = $c->model('GetAlleleInfo');
	my $result = $obj->_get_all_loci_names();

	if(not $result)
	{

		my $err_msg = $c->loc($ERROR_BASE_STRING.$result);
		$c->stash(error_id => $result, error_code => $err_msg);

	}
	else
	{
		my @locis = map { $_, $_ } @{$result};

		# a dynamic form (no form class has been defined)
		my $form = HTML::FormHandler->new(
			field_list         => [
				'loci_to_view_option' => {
					do_label => 0,
					type => 'Select',
					size => scalar(@$result),
					required => 1,
					options => \@locis,
					default => $result->[0]
				},
			],
		);

		$c->stash(template => 'allele/ViewLociAlleles.tt2', form => $form, page_title => $SELECT_LOCI_PAGE_TITLE);

	}

}

sub view_loci_alleles_process :Local
{

	my ($self, $c) = @_;

	my $loci_name = $c->request->params->{loci_to_view_option};
	my $option = $c->request->params->{option};
	my $has_error = $FALSE;

	my $obj = $c->model('GetAlleleInfo');
	my $loci_name_list = $obj->_get_all_loci_names();
	my $loci_name_exists = $FALSE;

	foreach my $loci_in_list (@$loci_name_list)
	{
		if(lc($loci_in_list) eq lc($loci_name))
		{
			$loci_name_exists = $TRUE;
		}
	}

	my $err_msg;

	if(not $loci_name_exists)
	{

		$err_msg = $c->loc($ERROR_BASE_STRING.$ERROR_INVALID_LOCI_NAME);
		$c->stash(error_id => $ERROR_INVALID_LOCI_NAME, error_code => $err_msg);

	}
	elsif($option !~ /^[A-Z]+$/i)
	{

		$err_msg = $c->loc($ERROR_BASE_STRING.$ERROR_CODE_INVALID_OPTION);
		$c->stash(error_id => $ERROR_CODE_INVALID_OPTION, error_code => $err_msg);

	}
	else
	{

		$c->response->redirect($c->uri_for($self->action_for('list_loci_alleles'), $loci_name));

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
