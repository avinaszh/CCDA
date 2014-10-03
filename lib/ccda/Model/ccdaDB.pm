package ccda::Model::ccdaDB;

use strict;
use base 'Catalyst::Model::DBIC::Schema';

__PACKAGE__->config(
    schema_class => 'ccda::Schema',
    connect_info => [
        'dbi:mysql:database',
        'username',
        'password',
        { AutoCommit => 1 },
        
    ],
);

=head1 NAME

ccda::Model::ccdaDB - Catalyst DBIC Schema Model
=head1 SYNOPSIS

See L<ccda>

=head1 DESCRIPTION

L<Catalyst::Model::DBIC::Schema> Model using schema L<ccda::Schema>

=head1 AUTHOR

root

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
