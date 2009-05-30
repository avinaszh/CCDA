package ccda::Schema::Result::DealVacations;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("InflateColumn::DateTime", "TimeStamp", "Core");
__PACKAGE__->table("deal_vacations");
__PACKAGE__->add_columns(
  "deal_id",
  { data_type => "INT", default_value => 0, is_nullable => 0, size => 11 },
  "vacation_id",
  { data_type => "INT", default_value => 0, is_nullable => 0, size => 11 },
);
__PACKAGE__->set_primary_key("deal_id", "vacation_id");


# Created by DBIx::Class::Schema::Loader v0.04005 @ 2009-05-30 16:05:03
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:QtvYKebhA7svHSmjFnjRuw

__PACKAGE__->belongs_to(deal => 'ccda::Schema::Result::Deals', 'deal_id');
__PACKAGE__->belongs_to(vacation => 'ccda::Schema::Result::Vacations', 'vacation_id');

# You can replace this text with custom content, and it will be preserved on regeneration
1;
