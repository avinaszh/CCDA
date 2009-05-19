package ccda::Schema::Result::DealGifts;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("InflateColumn::DateTime", "TimeStamp", "Core");
__PACKAGE__->table("deal_gifts");
__PACKAGE__->add_columns(
  "gift_id",
  { data_type => "INT", default_value => 0, is_nullable => 0, size => 11 },
  "deal_id",
  { data_type => "INT", default_value => 0, is_nullable => 0, size => 11 },
);
__PACKAGE__->set_primary_key("gift_id", "deal_id");


# Created by DBIx::Class::Schema::Loader v0.04005 @ 2009-05-19 12:29:38
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:i/Fgsq73eYQpOasDCu+OzQ

__PACKAGE__->belongs_to(deal => 'ccda::Schema::Result::Deals', 'deal_id');
__PACKAGE__->belongs_to(gift => 'ccda::Schema::Result::Gifts', 'gift_id');

# You can replace this text with custom content, and it will be preserved on regeneration
1;
