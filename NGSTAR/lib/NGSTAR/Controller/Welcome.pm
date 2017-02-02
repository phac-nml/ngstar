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

package NGSTAR::Controller::Welcome;
use Moose;
use namespace::autoclean;

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


Readonly my $TRANSLATION_LANG => "fr";
Readonly my $DEFAULT_LANG => "en";

Readonly my $FALSE => 0;
Readonly my $TRUE => 1;

Readonly my $WELCOME_PAGE_TITLE => "browser.title.welcome";
Readonly my $TERMS_PAGE_TITLE => "shared.terms.text";

Readonly my $ERROR_404_PAGE_TITLE => "shared.404.page.not.found.text";


sub begin : Private
{

	my ( $self, $c ) = @_;

	my $cookie;

	if(not $c->req->cookie('ngstar_lang_pref'))
	{
		$self->language_selection($c);
		$c->detach();
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

sub default :Path
{

	my ( $self, $c ) = @_;

	$c->stash(template => 'error/error_404.tt2', page_title => $ERROR_404_PAGE_TITLE);

}

sub language_selection :Local :Args()
{

	my ( $self, $c ) = @_;

	$c->stash(no_wrapper => 1, template => 'welcome/welcome.tt2', page_title => $WELCOME_PAGE_TITLE);

}

sub eula :Local :Args()
{

	my ( $self, $c ) = @_;

	my $eula_cookie = "";

	if($c->req->cookie('ngstar_eula_acceptance'))
	{
		$eula_cookie = $c->req->cookie('ngstar_eula_acceptance')->value;
	}

	if(not $eula_cookie eq NGSTAR->config->{eula_version})
	{

		if($c->request->params->{lang})
		{
			if($c->request->params->{lang} eq $TRANSLATION_LANG)
			{
				$c->session->{lang} = $TRANSLATION_LANG;
				$c->res->cookies->{ngstar_lang_pref} = { value => $TRANSLATION_LANG, expires => '+1y' };
				$c->stash(no_wrapper => 1, template => 'welcome/avis.tt2', eula_version_number => NGSTAR->config->{eula_version}, page_title => $TERMS_PAGE_TITLE);
			}
			else
			{
				$c->session->{lang} = "en";
				$c->res->cookies->{ngstar_lang_pref} = { value => 'en', expires => '+1y' };
				$c->stash(no_wrapper => 1, template => 'welcome/terms.tt2', eula_version_number => NGSTAR->config->{eula_version}, page_title => $TERMS_PAGE_TITLE);
			}
		}
		else
		{

			if($c->req->cookies->{ngstar_lang_pref} and $c->req->cookies->{ngstar_lang_pref}->value eq $TRANSLATION_LANG)
			{

				$c->session->{lang} = $TRANSLATION_LANG;
				$c->stash(no_wrapper => 1, template => 'welcome/avis.tt2', eula_version_number => NGSTAR->config->{eula_version}, page_title => $TERMS_PAGE_TITLE);
			}
			else
			{
				$c->session->{lang} = "en";
				$c->stash(no_wrapper => 1, template => 'welcome/terms.tt2', eula_version_number => NGSTAR->config->{eula_version}, page_title => $TERMS_PAGE_TITLE);

			}

		}

	}
	else
	{

		if($c->request->params->{lang} or $c->req->cookie('ngstar_lang_pref'))
		{

			if($c->request->params->{lang} and $c->request->params->{lang} eq $TRANSLATION_LANG  or $c->req->cookie('ngstar_lang_pref') and $c->req->cookie('ngstar_lang_pref')->value eq $TRANSLATION_LANG)
			{

				$c->session->{lang} = $TRANSLATION_LANG;
				$c->res->cookies->{ngstar_lang_pref} = { value => $TRANSLATION_LANG, expires => '+1y' };

				$c->stash(no_wrapper => 0, template => 'welcome/avis.tt2', eula_version_number => NGSTAR->config->{eula_version}, eula_already_accepted => "true", page_title => $TERMS_PAGE_TITLE);

			}
			else
			{

				$c->session->{lang} = "en";
				$c->res->cookies->{ngstar_lang_pref} = { value => 'en', expires => '+1y' };

				$c->stash(no_wrapper => 0, template => 'welcome/terms.tt2', eula_version_number => NGSTAR->config->{eula_version}, eula_already_accepted => "true", page_title => $TERMS_PAGE_TITLE);

			}

		}
		else
		{

			$c->res->redirect($c->uri_for($c->controller('Allele')->action_for('form')));
			$c->detach();

		}

	}

}

sub eula_accepted :Local :Args()
{

	my ( $self, $c, $accepted ) = @_;

	if( $accepted == $TRUE )
	{

		$c->res->cookies->{ngstar_eula_acceptance} = { value => NGSTAR->config->{eula_version}, expires => '+1y' };

		$c->res->redirect($c->uri_for($c->controller('Allele')->action_for('form')));
		$c->detach();

	}
	else
	{

		$c->res->redirect($c->uri_for($c->controller('Root')->action_for('index')));

	}

}

sub home :Local
{

	my ($self, $c) = @_;

	if($c->req->cookies->{ngstar_lang_pref} and $c->req->cookies->{ngstar_lang_pref}->value eq $TRANSLATION_LANG)
	{
		$c->stash(template=>"home/homepage-fr.tt2", page_title=>"NG-STAR Home", no_wrapper=>1);
	}
	else
	{
		$c->stash(template=>"home/homepage.tt2", page_title=>"NG-STAR Home", no_wrapper=>1);

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
