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

package DAL::DaoStub;

use 5.014002;
use strict;
use warnings;

require Exporter;

our @ISA = qw(Exporter);

# Items to export into callers namespace by default. Note: do not export
# names by default without a very good reason. Use EXPORT_OK instead.
# Do not simply export all your public functions/methods/constants.

# This allows declaration	use DAL::DaoStub ':all';
# If you do not need this, moving things directly into @EXPORT or @EXPORT_OK
# will save memory.
our %EXPORT_TAGS = ( 'all' => [ qw(

) ] );

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

our @EXPORT = qw(
	get_all_allele_length
	get_all_alleles_by_loci
	get_all_loci_names
	get_allele_length
);

our $VERSION = '0.01';

# Preloaded methods go here.

sub new
{

	my ($class) = @_;
	my $self = {};
	bless $self, $class;
	return $self;

}

#start BusinessLogic::GetAlleleType

sub get_all_allele_length
{

	my ($self, $sequence_map, $info_map) = @_;

	foreach my $name (keys %$info_map)
	{

		$info_map->{$name} = length($sequence_map->{$name});

	}

	return 1;

}

sub get_all_alleles_by_loci
{

	my ($self) = @_;
	my @allele_list = ("this is a stub");

	return \@allele_list;

}

sub get_all_loci_names
{

	my ($self, $size) = @_;

	my @name_list;
	for(my $i = 0; $i < $size; $i ++)
	{

		push @name_list, $i;

	}

	return \@name_list;

}

sub get_allele_length
{

	my ($self) = @_;
	return 390;

}

#end BusinessLogic::GetAlleleType

1;
__END__
# Below is stub documentation for your module. You'd better edit it!

=head1 NAME

DAL::DaoStub - Perl extension for blah blah blah

=head1 SYNOPSIS

  use DAL::DaoStub;
  blah blah blah

=head1 DESCRIPTION

Stub documentation for DAL::DaoStub, created by h2xs. It looks like the
author of the extension was negligent enough to leave the stub
unedited.

Blah blah blah.

=head2 EXPORT

None by default.



=head1 SEE ALSO

Mention other useful documentation such as the documentation of
related modules or operating system documentation (such as man pages
in UNIX), or any relevant external documentation such as RFCs or
standards.

If you have a mailing list set up for your module, mention it here.

If you have a web site set up for your module, mention it here.

=head1 AUTHOR

Irish Medina, E<lt>irish_m@E<gt>
Copyright (C) 2014 by Irish Medina

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.14.2 or,
at your option, any later version of Perl 5 you may have available.


=cut
