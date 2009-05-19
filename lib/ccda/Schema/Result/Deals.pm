package ccda::Schema::Result::Deals;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("InflateColumn::DateTime", "TimeStamp", "Core");
__PACKAGE__->table("deals");
__PACKAGE__->add_columns(
  "id",
  { data_type => "INT", default_value => undef, is_nullable => 0, size => 11 },
  "callcenter_id",
  { data_type => "INT", default_value => undef, is_nullable => 0, size => 11 },
  "first_name",
  {
    data_type => "VARCHAR",
    default_value => undef,
    is_nullable => 1,
    size => 128,
  },
  "last_name",
  {
    data_type => "VARCHAR",
    default_value => undef,
    is_nullable => 1,
    size => 128,
  },
  "home_phone",
  {
    data_type => "VARCHAR",
    default_value => undef,
    is_nullable => 1,
    size => 128,
  },
  "cell_phone",
  {
    data_type => "VARCHAR",
    default_value => undef,
    is_nullable => 1,
    size => 128,
  },
  "work_phone",
  {
    data_type => "VARCHAR",
    default_value => undef,
    is_nullable => 1,
    size => 128,
  },
  "email_address",
  {
    data_type => "VARCHAR",
    default_value => undef,
    is_nullable => 1,
    size => 128,
  },
  "address",
  {
    data_type => "VARCHAR",
    default_value => undef,
    is_nullable => 1,
    size => 128,
  },
  "city",
  {
    data_type => "VARCHAR",
    default_value => undef,
    is_nullable => 1,
    size => 128,
  },
  "state",
  {
    data_type => "VARCHAR",
    default_value => undef,
    is_nullable => 1,
    size => 128,
  },
  "country",
  {
    data_type => "VARCHAR",
    default_value => undef,
    is_nullable => 1,
    size => 128,
  },
  "zip_code",
  {
    data_type => "VARCHAR",
    default_value => undef,
    is_nullable => 1,
    size => 128,
  },
  "estimated_travel_date",
  { data_type => "DATE", default_value => undef, is_nullable => 1, size => 10 },
  "payment_method",
  { data_type => "INT", default_value => undef, is_nullable => 1, size => 11 },
  "card_number",
  {
    data_type => "VARCHAR",
    default_value => undef,
    is_nullable => 1,
    size => 128,
  },
  "card_exp_month",
  {
    data_type => "VARCHAR",
    default_value => undef,
    is_nullable => 1,
    size => 128,
  },
  "card_exp_year",
  {
    data_type => "VARCHAR",
    default_value => undef,
    is_nullable => 1,
    size => 128,
  },
  "card_cvv",
  {
    data_type => "VARCHAR",
    default_value => undef,
    is_nullable => 1,
    size => 128,
  },
  "name_on_card",
  {
    data_type => "VARCHAR",
    default_value => undef,
    is_nullable => 1,
    size => 128,
  },
  "card_auth",
  {
    data_type => "VARCHAR",
    default_value => undef,
    is_nullable => 1,
    size => 128,
  },
  "purchase_date",
  { data_type => "DATE", default_value => undef, is_nullable => 1, size => 10 },
  "merchant_id",
  { data_type => "INT", default_value => undef, is_nullable => 1, size => 11 },
  "genie_number_1",
  {
    data_type => "VARCHAR",
    default_value => undef,
    is_nullable => 1,
    size => 128,
  },
  "genie_number_2",
  {
    data_type => "VARCHAR",
    default_value => undef,
    is_nullable => 1,
    size => 128,
  },
  "agent_id",
  { data_type => "INT", default_value => undef, is_nullable => 1, size => 11 },
  "supervisor_id",
  { data_type => "INT", default_value => undef, is_nullable => 1, size => 11 },
  "charged_amount",
  { data_type => "DECIMAL", default_value => undef, is_nullable => 1, size => 5 },
  "notes",
  {
    data_type => "TEXT",
    default_value => undef,
    is_nullable => 1,
    size => 65535,
  },
  "status",
  { data_type => "INT", default_value => 1, is_nullable => 1, size => 11 },
  "shipping_status",
  { data_type => "INT", default_value => 1, is_nullable => 1, size => 11 },
  "transaction_status",
  { data_type => "INT", default_value => 1, is_nullable => 1, size => 11 },
  "created",
  {
    data_type => "TIMESTAMP",
    default_value => "CURRENT_TIMESTAMP",
    is_nullable => 0,
    size => 14,
  },
  "updated",
  {
    data_type => "TIMESTAMP",
    default_value => "0000-00-00 00:00:00",
    is_nullable => 0,
    size => 14,
  },
);
__PACKAGE__->set_primary_key("id");


# Created by DBIx::Class::Schema::Loader v0.04005 @ 2009-05-19 12:29:38
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:aVZnDKXdu/cv/DnKpLuQRA

=head2 delete_allowed_by

Can the specified user delete the current book?

=cut

sub delete_allowed_by {
    my ($self, $user) = @_;

    # Only allow delete if user has 'admin' role
    return $user->has_role('admin');
}

__PACKAGE__->has_many(user => 'ccda::Schema::Result::Users', {  'foreign.id' => 'self.agent_id' }, { cascade_delete => 0 });
__PACKAGE__->has_many(status => 'ccda::Schema::Result::Status', {  'foreign.id' => 'self.status' }, { cascade_delete => 0 } );
__PACKAGE__->has_many(transaction_status => 'ccda::Schema::Result::TransactionStatus', 
    {  'foreign.id' => 'self.transaction_status' }, { cascade_delete => 0 } 
);

__PACKAGE__->has_many(deal_vacation => 'ccda::Schema::Result::DealVacations', 'deal_id');
__PACKAGE__->many_to_many(vacations => 'deal_vacation', 'vacation');

__PACKAGE__->has_many(deal_gift => 'ccda::Schema::Result::DealGifts', 'deal_id');
__PACKAGE__->many_to_many(gifts => 'deal_gift', 'gift');


# You can replace this text with custom content, and it will be preserved on regeneration
1;
