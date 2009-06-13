package ccda::Schema::Result::UserRoles;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("InflateColumn::DateTime", "TimeStamp", "Core");
__PACKAGE__->table("user_roles");
__PACKAGE__->add_columns(
  "user_id",
  { data_type => "INT", default_value => 0, is_nullable => 0, size => 11 },
  "role_id",
  { data_type => "INT", default_value => 0, is_nullable => 0, size => 11 },
);
__PACKAGE__->set_primary_key("user_id", "role_id");


# Created by DBIx::Class::Schema::Loader v0.04005 @ 2009-06-13 13:40:07
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:nhsKFaV+jqtfs40L9bAVHg

__PACKAGE__->belongs_to(user => 'ccda::Schema::Result::Users', 'user_id');
__PACKAGE__->belongs_to(role => 'ccda::Schema::Result::Roles', 'role_id');


# You can replace this text with custom content, and it will be preserved on regeneration
1;
