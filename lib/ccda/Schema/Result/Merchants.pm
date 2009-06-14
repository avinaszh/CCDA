package ccda::Schema::Result::Merchants;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("InflateColumn::DateTime", "TimeStamp", "Core");
__PACKAGE__->table("merchants");
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


# Created by DBIx::Class::Schema::Loader v0.04005 @ 2009-06-14 15:13:16
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:IHMFpSyMVJgE7M+v4md5Tw

__PACKAGE__->has_many(map_callcenter_merchant => 'ccda::Schema::Result::CallcenterMerchants', 'merchant_id');


# You can replace this text with custom content, and it will be preserved on regeneration
1;
