package ccda::Schema::Result::Callcenters;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("InflateColumn::DateTime", "TimeStamp", "Core");
__PACKAGE__->table("callcenters");
__PACKAGE__->add_columns(
  "id",
  { data_type => "INT", default_value => undef, is_nullable => 0, size => 11 },
  "broker_id",
  { data_type => "INT", default_value => undef, is_nullable => 0, size => 11 },
  "name",
  {
    data_type => "VARCHAR",
    default_value => undef,
    is_nullable => 1,
    size => 128,
  },
  "alias",
  {
    data_type => "VARCHAR",
    default_value => undef,
    is_nullable => 1,
    size => 128,
  },
  "percentage",
  { data_type => "DECIMAL", default_value => undef, is_nullable => 1, size => 5 },
  "processing_fee",
  { data_type => "DECIMAL", default_value => undef, is_nullable => 1, size => 5 },
  "chargeback_fee",
  { data_type => "DECIMAL", default_value => undef, is_nullable => 1, size => 5 },
  "active",
  { data_type => "INT", default_value => 1, is_nullable => 0, size => 11 },
  "notes",
  {
    data_type => "TEXT",
    default_value => undef,
    is_nullable => 1,
    size => 65535,
  },
);
__PACKAGE__->set_primary_key("id");


# Created by DBIx::Class::Schema::Loader v0.04005 @ 2009-05-16 21:28:37
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:8gZjans58uvJS6eHewQcrQ

__PACKAGE__->has_many(map_callcenter_merchant => 'ccda::Schema::Result::CallcenterMerchants', 'callcenter_id');

# You can replace this text with custom content, and it will be preserved on regeneration
1;
