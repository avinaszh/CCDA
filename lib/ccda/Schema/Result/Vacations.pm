package ccda::Schema::Result::Vacations;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("InflateColumn::DateTime", "TimeStamp", "Core");
__PACKAGE__->table("vacations");
__PACKAGE__->add_columns(
  "id",
  { data_type => "INT", default_value => undef, is_nullable => 0, size => 11 },
  "name",
  {
    data_type => "VARCHAR",
    default_value => undef,
    is_nullable => 0,
    size => 128,
  },
  "active",
  { data_type => "INT", default_value => undef, is_nullable => 0, size => 1 },
  "notes",
  {
    data_type => "TEXT",
    default_value => undef,
    is_nullable => 0,
    size => 65535,
  },
);
__PACKAGE__->set_primary_key("id");


# Created by DBIx::Class::Schema::Loader v0.04005 @ 2009-05-14 10:48:20
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:AXb+QyiUENX2yfQsJ+PVvw

__PACKAGE__->has_many(deal_vacation => 'ccda::Schema::Result::DealVacations', 'vacation_id');

# You can replace this text with custom content, and it will be preserved on regeneration
1;
