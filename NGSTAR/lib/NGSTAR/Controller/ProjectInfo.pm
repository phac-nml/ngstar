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

package NGSTAR::Controller::ProjectInfo;
use Moose;
use namespace::autoclean;
use Readonly;

use Catalyst qw( ConfigLoader );


BEGIN { extends 'Catalyst::Controller'; }

=head1 NAME

NGSTAR::Controller::ProjectInfo - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index

=cut

Readonly my $BACKGROUND_PAGE_TITLE => "about.ngstar.text";
Readonly my $ERROR_404_PAGE_TITLE => "shared.404.page.not.found.text";

Readonly my $TRANSLATION_LANG => "fr";
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

sub background :Local :Args(0)
{

	my ( $self, $c ) = @_;

	$c->log->debug('*** INSIDE background METHOD ***');

	my $curator_email_address = $c->config->{curator_email};

	if($c->session->{lang} eq $TRANSLATION_LANG)
	{
		$c->stash(template => 'project_info/Background-fr.tt2', page_title => $BACKGROUND_PAGE_TITLE, curator_email => $curator_email_address);
	}
	else
	{
		$c->stash(template => 'project_info/Background.tt2', page_title => $BACKGROUND_PAGE_TITLE, curator_email => $curator_email_address);
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
