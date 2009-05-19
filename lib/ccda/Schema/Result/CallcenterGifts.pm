package ccda::Schema::Result::CallcenterGifts;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("InflateColumn::DateTime", "TimeStamp", "Core");
__PACKAGE__->table("callcenter_gifts");
__PACKAGE__->add_columns(
  "callcenter_id",
  { data_type => "INT", default_value => 0, is_nullable => 0, size => 11 },
  "gift_id",
  { data_type => "INT", default_value => 0, is_nullable => 0, size => 11 },
);
__PACKAGE__->set_primary_key("callcenter_id", "gift_id");


# Created by DBIx::Class::Schema::Loader v0.04005 @ 2009-05-19 12:29:38
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:dRdjDmdAWztR9mr7HMJseg

__PACKAGE__->belongs_to(callcenter => 'ccda::Schema::Result::Callcenters', 'callcenter_id');
__PACKAGE__->belongs_to(gifts => 'ccda::Schema::Result::Gifts', 'gift_id');


# You can replace this text with custom content, and it will be preserved on regeneration
1;
