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

package NGSTAR;
use Moose;
use namespace::autoclean;

use Catalyst::Runtime 5.80;

# Set flags and add plugins for the application.
#
# Note that ORDERING IS IMPORTANT here as plugins are initialized in order,
# therefore you almost certainly want to keep ConfigLoader at the head of the
# list if you're using it.
#
#         -Debug: activates the debug mode for very useful log messages
#   ConfigLoader: will load the configuration from a Config::General file in the
#                 application's home directory
# Static::Simple: will serve static files from the application's root
#                 directory

# The three session plugins are needed to be able to use "flash"
use Catalyst qw/
	ConfigLoader
	Static::Simple

	StackTrace

	Authentication
	Authorization::Roles

	Session
	Session::Store::File
	Session::State::Cookie

	I18N
/;

extends 'Catalyst';

our $VERSION = '0.01';

# Configure the application.
#
# Note that settings in ngstar.conf (or other external
# configuration file that you set up manually) take precedence
# over this when using ConfigLoader. Thus configuration
# details given here can function as a default configuration,
# with an external configuration file acting as an override for
# local deployment.

__PACKAGE__->config(
	name => 'NGSTAR',
	# Disable deprecated behavior needed by old applications
	disable_component_resolution_regex_fallback => 1,
	#enable_catalyst_header => 1, # Send X-Catalyst header
	# Automatically copies the content of flash to stash
	session => {flash_to_stash => 1},
);

__PACKAGE__->config(
	# Configure the view
	'View::HTML' => {
		# Set the location of the TT files
		INCLUDE_PATH => [
			__PACKAGE__->path_to('root', 'src'),
		],
	},
);

__PACKAGE__->config( { ENCODING => "UTF-8" } );


__PACKAGE__->config(
	'Plugin::Authentication' => {

		default_realm => 'login',
		login => {
			credential => {
				class => 'Password',
				password_type => 'self_check',
			},
			store => {
				class => 'DBIx::Class',
				user_model => 'DB::User',
				role_relation => 'roles',
				role_field => 'role',
				use_userdata_from_session => 1,
			}
		},
		tokens => {
				credential => {
				class => 'Password',
				password_field => 'token',
				password_type => 'self_check',
			},
			store => {
				class => 'DBIx::Class',
				user_model => 'DB::PasswordResetRequest',
				use_userdata_from_session => 1,
			}
		},
		used_passwords => {
				credential => {
				class => 'Password',
				password_field => 'used_password',
				password_type => 'self_check',
			},
			store => {
				class => 'DBIx::Class',
				user_model => 'DB::PasswordHistory',
				use_userdata_from_session => 1,
			}
		},
	},
);

__PACKAGE__->config(
	'View::Email::Template' => {
		#specify where to look in the stash for email information
		stash_key => 'email',
		#define defaults for the mail
		default => {
			content_type => 'text/plain',
			charset => 'utf-8',
			view => 'TT::NoWrap',
		},
		#setup how to send email
		sender => {
			mailer => 'SMTP',
			mailer_args => {
				host => NGSTAR->config->{curator_email_host},
				sasl_username => NGSTAR->config->{curator_email},
				sasl_password => NGSTAR->config->{curator_email_password},
				port => 465,
				ssl => 1,
			}
		}
	}
);


#By default, temporary files (from file uploads) are stored in the system temp dir
#You can change the location of where temporary files are stored by including this
#configuration setting and specifying the path to the directory where you intend to store
#temporary files
#__PACKAGE__->config(
#    uploadtmp => '/path/to/tmpdir'
#);

# Start the application
__PACKAGE__->setup();

#Disable debug logging unless run with -d flag
__PACKAGE__->log->levels( qw/info warn error fatal/) unless __PACKAGE__->debug;
=encoding utf8

=head1 NAME

NGSTAR - Catalyst based application

=head1 SYNOPSIS

	script/ngstar_server.pl

=head1 DESCRIPTION

[enter your description here]

=head1 SEE ALSO

L<NGSTAR::Controller::Root>, L<Catalyst>

=head1 AUTHOR

Irish Medina

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
