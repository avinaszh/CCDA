package ccda::Schema::Result::CallcenterMerchants;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("InflateColumn::DateTime", "TimeStamp", "Core");
__PACKAGE__->table("callcenter_merchants");
__PACKAGE__->add_columns(
  "callcenter_id",
  { data_type => "INT", default_value => 0, is_nullable => 0, size => 11 },
  "merchant_id",
  { data_type => "INT", default_value => 0, is_nullable => 0, size => 11 },
);
__PACKAGE__->set_primary_key("callcenter_id", "merchant_id");


# Created by DBIx::Class::Schema::Loader v0.04005 @ 2009-05-30 12:41:50
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:T5sQcHa6kCgW5iCxYC/aMg

__PACKAGE__->belongs_to(callcenter => 'ccda::Schema::Result::Callcenters', 'callcenter_id');
__PACKAGE__->belongs_to(merchant => 'ccda::Schema::Result::Merchants', 'merchant_id');

# You can replace this text with custom content, and it will be preserved on regeneration
1;
