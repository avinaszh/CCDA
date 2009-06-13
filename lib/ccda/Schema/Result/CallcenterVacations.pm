package ccda::Schema::Result::CallcenterVacations;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("InflateColumn::DateTime", "TimeStamp", "Core");
__PACKAGE__->table("callcenter_vacations");
__PACKAGE__->add_columns(
  "callcenter_id",
  { data_type => "INT", default_value => 0, is_nullable => 0, size => 11 },
  "vacation_id",
  { data_type => "INT", default_value => 0, is_nullable => 0, size => 11 },
);
__PACKAGE__->set_primary_key("callcenter_id", "vacation_id");


# Created by DBIx::Class::Schema::Loader v0.04005 @ 2009-06-13 13:40:07
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:4Jx7pqR0fGZHYSICuFK5vQ

__PACKAGE__->belongs_to(callcenter => 'ccda::Schema::Result::Callcenters', 'callcenter_id');
__PACKAGE__->belongs_to(vacation => 'ccda::Schema::Result::Vacations', 'vacation_id');


# You can replace this text with custom content, and it will be preserved on regeneration
1;
