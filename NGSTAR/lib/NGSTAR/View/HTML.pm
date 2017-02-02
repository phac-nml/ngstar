package NGSTAR::View::HTML;
use Moose;
use namespace::autoclean;

extends 'Catalyst::View::TT';

__PACKAGE__->config(
    # Change default TT extension
    # This has been commented out for a reason
    #TEMPLATE_EXTENSION => '.tt2',
    render_die => 1,
    # Set the location for TT files
    INCLUDE_PATH => [
        NGSTAR->path_to('root', 'src'),
    ],
    TIMER => 0,
    WRAPPER => 'bootstrap3_wrapper.tt2',
);

=head1 NAME

NGSTAR::View::HTML - TT View for NGSTAR

=head1 DESCRIPTION

TT View for NGSTAR.

=head1 SEE ALSO

L<NGSTAR>

=head1 AUTHOR

Irish Medina

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
