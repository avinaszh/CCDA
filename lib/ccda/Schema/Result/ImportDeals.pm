package ccda::Schema::Result::ImportDeals;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("InflateColumn::DateTime", "TimeStamp", "Core");
__PACKAGE__->table("import_deals");
__PACKAGE__->add_columns(
  "id",
  { data_type => "INT", default_value => undef, is_nullable => 0, size => 11 },
  "md5",
  {
    data_type => "VARCHAR",
    default_value => undef,
    is_nullable => 0,
    size => 128,
  },
  "purchase_date",
  { data_type => "DATE", default_value => undef, is_nullable => 1, size => 10 },
  "transaction_status",
  {
    data_type => "VARCHAR",
    default_value => undef,
    is_nullable => 1,
    size => 128,
  },
  "callcenter_alias",
  {
    data_type => "VARCHAR",
    default_value => undef,
    is_nullable => 1,
    size => 128,
  },
  "status",
  {
    data_type => "VARCHAR",
    default_value => undef,
    is_nullable => 1,
    size => 128,
  },
  "reference",
  {
    data_type => "VARCHAR",
    default_value => undef,
    is_nullable => 1,
    size => 128,
  },
  "lead_source",
  {
    data_type => "VARCHAR",
    default_value => undef,
    is_nullable => 1,
    size => 128,
  },
  "customer_name",
  {
    data_type => "VARCHAR",
    default_value => undef,
    is_nullable => 1,
    size => 128,
  },
  "charged_amount",
  { data_type => "DECIMAL", default_value => undef, is_nullable => 1, size => 5 },
  "card_type",
  {
    data_type => "VARCHAR",
    default_value => undef,
    is_nullable => 1,
    size => 128,
  },
  "recording",
  {
    data_type => "VARCHAR",
    default_value => undef,
    is_nullable => 1,
    size => 128,
  },
);
__PACKAGE__->set_primary_key("id");
__PACKAGE__->add_unique_constraint("md5", ["md5"]);


# Created by DBIx::Class::Schema::Loader v0.04005 @ 2009-06-14 15:13:16
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:o7lU/Imd1HX8j8GVONlOZw

__PACKAGE__->might_have(deal => 'ccda::Schema::Result::Deals', 
    { 'foreign.md5' => 'self.md5' });

# You can replace this text with custom content, and it will be preserved on regeneration
1;
