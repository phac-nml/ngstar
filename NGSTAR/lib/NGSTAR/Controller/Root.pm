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

package NGSTAR::Controller::Root;
use Moose;
use namespace::autoclean;

use Readonly;

BEGIN { extends 'Catalyst::Controller' }

use Session::Token;

#
# Sets the actions in this controller to be registered with no prefix
# so they function identically to actions created in MyApp.pm
#
__PACKAGE__->config(namespace => '');

=encoding utf-8

=head1 NAME

NGSTAR::Controller::Root - Root Controller for NGSTAR

=head1 DESCRIPTION

[enter your description here]

=head1 METHODS

=head2 index

The root page (/)

=cut

Readonly my $FALSE => 0;
Readonly my $TRUE => 1;

Readonly my $ERROR_404_PAGE_TITLE => "shared.404.page.not.found.text";
Readonly my $DEFAULT_LANG => "en";

sub begin :Path
{

	my ( $self, $c ) = @_;


	if(not $c->req->cookie('ngstar_lang_pref'))
	{
		$c->res->redirect($c->uri_for($c->controller('Welcome')->action_for('language_selection')));
	}
	else
	{
		$c->res->redirect($c->uri_for($c->controller('Welcome')->action_for('home')));
		#$c->stash(template=>"home/homepage.tt2", page_title=>"NG-STAR Home", no_wrapper=>1);
		#$self->action_for('home');
	}

}

sub index :Path :Args(1)
{

	my ( $self, $c , $lang ) = @_;

	$lang ||= $c->req->param("lang");

	my $locale = $lang;
	my @path_tokens;
	my $token_count = 0;


	if($c->request->referer)
	{
		@path_tokens = split("/",$c->request->referer);
	}

	my $no_referer = $FALSE;

	$c->languages( $locale ? [ $locale ] : undef );

	$c->res->cookies->{ngstar_lang_pref} = { value => $lang, expires => '+1y' };


	if($c->req->cookie('ngstar_lang_pref'))
	{
		#required for language link in header
		if(length $c->req->cookie('ngstar_lang_pref')->value == 2)
		{
			$c->session->{lang} = $c->req->cookie('ngstar_lang_pref')->value;
		}
		else
		{
			$c->session->{lang} = $DEFAULT_LANG;
		}
	}

	foreach my $token (@path_tokens)
	{
		if($token eq "language_selection")
		{
			$token_count += 1;
		}
	}

	if($token_count > 0)
	{
		$no_referer = $TRUE;
	}

	if(not $c->session->{csrf_token})
	{
		$c->session->{csrf_token} = Session::Token->new(length => 128)->get;
	}

	if($no_referer)
	{
	   #$c->stash(template=>"home/homepage.tt2", page_title=>"NG-STAR Home", no_wrapper=>1);
		$c->res->redirect($c->uri_for($c->controller('Welcome')->action_for('home')));
	}
	else
	{
		$c->res->redirect($c->request->referer);
	}

}


=head2 default

Standard 404 error page

=cut

sub default :Path
{

	my ( $self, $c ) = @_;

	#$c->response->body( 'Page not found' );
	#$c->response->status(404);

	$c->stash(template => 'error/error_404.tt2', page_title => $ERROR_404_PAGE_TITLE);

}

=head2 end

Attempt to render a view, if needed.

=cut

sub end : ActionClass('RenderView') {}

=head1 AUTHOR

Irish Medina

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
