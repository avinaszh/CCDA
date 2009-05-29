package ccda::Schema::Result::Users;

use strict;
use warnings;

use Perl6::Junction qw/any/;
use base 'DBIx::Class';

__PACKAGE__->load_components("InflateColumn::DateTime", "TimeStamp", "Core");
__PACKAGE__->table("users");
__PACKAGE__->add_columns(
  "id",
  { data_type => "INT", default_value => undef, is_nullable => 0, size => 11 },
  "callcenter_id",
  { data_type => "INT", default_value => undef, is_nullable => 0, size => 11 },
  "username",
  {
    data_type => "TEXT",
    default_value => undef,
    is_nullable => 1,
    size => 65535,
  },
  "password",
  {
    data_type => "TEXT",
    default_value => undef,
    is_nullable => 1,
    size => 65535,
  },
  "email_address",
  {
    data_type => "TEXT",
    default_value => undef,
    is_nullable => 1,
    size => 65535,
  },
  "first_name",
  {
    data_type => "TEXT",
    default_value => undef,
    is_nullable => 1,
    size => 65535,
  },
  "last_name",
  {
    data_type => "TEXT",
    default_value => undef,
    is_nullable => 1,
    size => 65535,
  },
  "active",
  { data_type => "INT", default_value => undef, is_nullable => 1, size => 11 },
  "notes",
  {
    data_type => "TEXT",
    default_value => undef,
    is_nullable => 1,
    size => 65535,
  },
);
__PACKAGE__->set_primary_key("id");


# Created by DBIx::Class::Schema::Loader v0.04005 @ 2009-05-14 10:48:20
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:xlfkoSuLxDNYa4Rfz2y0Fw

=head 2 has_role

Check if a user has the specified role

=cut

sub has_role {
    my ($self, $role) = @_;

    # Does this user posses the required role?
    return any(map { $_->role } $self->roles) eq $role;
}

__PACKAGE__->has_many(map_user_role => 'ccda::Schema::Result::UserRoles', 'user_id');
__PACKAGE__->many_to_many(roles => 'map_user_role', 'role');
__PACKAGE__->has_many(callcenter => 'ccda::Schema::Result::Callcenters', {  'foreign.id' => 'self.callcenter_id' }, { cascade_delete => 0 });


# You can replace this text with custom content, and it will be preserved on regeneration
1;
