package ccda::Schema::Result::ShippingStatus;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("InflateColumn::DateTime", "TimeStamp", "Core");
__PACKAGE__->table("shipping_status");
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
);
__PACKAGE__->set_primary_key("id");


# Created by DBIx::Class::Schema::Loader v0.04005 @ 2009-06-12 02:03:43
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:XkLgHTi80cPD9IXDDjBqFQ


# You can replace this text with custom content, and it will be preserved on regeneration
1;
