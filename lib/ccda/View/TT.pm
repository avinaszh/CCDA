package ccda::View::TT;

use strict;
use base 'Catalyst::View::TT';

__PACKAGE__->config(
    # Change default TT extension
    TEMPLATE_EXTENSION => '.tt2',
    # Set the location for TT files
    INCLUDE_PATH => [
            ccda->path_to( 'root', 'src' ),
        ],
    # Set to 1 for detailed timer stats in your HTML as comments
    TIMER          => 1,
    # This is my template wrapper
    WRAPPER => 'wrapper.tt2',
);

=head1 NAME

ccda::View::TT - TT View for ccda

=head1 DESCRIPTION

TT View for ccda. 

=head1 SEE ALSO

L<ccda>

=head1 AUTHOR

root

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
