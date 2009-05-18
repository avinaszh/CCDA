package ccda::Schema::Result::Roles;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("InflateColumn::DateTime", "TimeStamp", "Core");
__PACKAGE__->table("roles");
__PACKAGE__->add_columns(
  "id",
  { data_type => "INT", default_value => undef, is_nullable => 0, size => 11 },
  "role",
  {
    data_type => "TEXT",
    default_value => undef,
    is_nullable => 1,
    size => 65535,
  },
);
__PACKAGE__->set_primary_key("id");


# Created by DBIx::Class::Schema::Loader v0.04005 @ 2009-05-16 21:28:37
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:B4iZn+n9uJnvW7pj6DN0bA

__PACKAGE__->has_many(map_user_role => 'ccda::Schema::Result::UserRoles', 'role_id');

# You can replace this text with custom content, and it will be preserved on regeneration
1;
