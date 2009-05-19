package ccda::Controller::Deals;

use strict;
use warnings;
use parent 'Catalyst::Controller';

=head1 NAME

ccda::Controller::Deals - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index

=cut

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;

    $c->response->body('Matched ccda::Controller::Deals in Deals.');
}

=head2 base

Can place common logic to start  chained dispatch here

=cut

sub base :Chained('/') :PathPart('deals') :CaptureArgs(0) {
    my ( $self, $c ) = @_;

    # Store the ResultSet in stash so it's available for other methods
    $c->stash->{resultset} = $c->model('ccdaDB::Deals');

    # Whats our user callcenter_id
    $c->stash->{callcenter_id} = $c->user->get('callcenter_id');

}

=head2 deal

Fetch the specified deal objet based on the book ID and store it in the stash

=cut

sub deal :Chained('base') :PathPart('id') :CaptureArgs(1) {
    # $id = primary key of deal
    my ( $self, $c, $id ) = @_;

    # Find the deal deal and store it in the stash
    $c->stash->{deal} = $c->stash->{resultset}->find($id);

    $c->stash->{deal_id} = $id;

    # Make sure the lookup was successful.
    die "Deal $id not found!" if !$c->stash->{deal};
}

=head2 access_denied

Handle Catalyst::Plugin::Auhtorization::ACL access denied exepctions

=cut

sub access_denied : Private {
    my ($self, $c) = @_;

    # Set the error message
    $c->stash->{error_msg} = 'Unathorized!';

    # Display the list
    $c->forward('list');
}

=head2 create

Form to create a new deal

=cut

sub create :Chained('base') :PathPart('create') :Args(0) {
    my ($self, $c) = @_;
    
        $c->stash->{states} = [$c->model('ccdaDB::States')->all];
        $c->stash->{countries} = [$c->model('ccdaDB::Countries')->all];
        $c->stash->{status} = [$c->model('ccdaDB::Status')->all];
        $c->stash->{payments} = [$c->model('ccdaDB::Payments')->all];

    if ($c->check_user_roles('admin')) {

        $c->stash->{gifts} = [$c->model('ccdaDB::Gifts')->search({ 
            active => '1' 
        })];
        $c->stash->{merchants} = [$c->model('ccdaDB::Merchants')->search({ 
            active => '1' 
        })];
        $c->stash->{vacations} = [$c->model('ccdaDB::Vacations')->search({ 
            active => '1' 
        })];
        $c->stash->{agents} = [$c->model('ccdaDB::Users')->search(
            { active => '1', role_id => '3' },
            { join  => 'map_user_role' }
        )];

    } else {

        $c->stash->{vacations} = [$c->model('ccdaDB::Vacations')->search(
            { active => '1', callcenter_id => $c->stash->{callcenter_id} },
            { join => 'map_callcenter_vacation' }
        )];
        $c->stash->{gifts} = [$c->model('ccdaDB::Gifts')->search(
            { active => '1', callcenter_id => $c->stash->{callcenter_id} },
            { join => 'map_callcenter_gift' }
        )];
        $c->stash->{merchants} = [$c->model('ccdaDB::Merchants')->search(
            { active => '1', callcenter_id => $c->stash->{callcenter_id} },
            { join => 'map_callcenter_merchant' }
        )];
        $c->stash->{agents} = [$c->model('ccdaDB::Users')->search(
            { 
              active => '1', 
              role_id => '3',
              callcenter_id => $c->stash->{callcenter_id}
            } ,
            { join  => 'map_user_role' }
        )];

    }

    # Set the template
    $c->stash->{template} = 'deals/create.tt2';
}

=head2 create_do

Take information from form and add to the database

=cut

sub create_do :Chained('base') :PathPart('create_do') :Args(0) {
    my ($self, $c) = @_;

    # Retrieve the values from the form
    my $callcenter_id           = $c->request->params->{callcenter_id};
    my $first_name              = $c->request->params->{first_name};
    my $last_name               = $c->request->params->{last_name};
    my $home_phone              = $c->request->params->{home_phone};
    my $cell_phone              = $c->request->params->{cell_phone};
    my $work_phone              = $c->request->params->{work_phone};
    my $email_address           = $c->request->params->{email_address};
    my $address                 = $c->request->params->{address};
    my $zip_code                = $c->request->params->{zip_code};
    my $city                    = $c->request->params->{city};
    my $state                   = $c->request->params->{state};
    my $country                 = $c->request->params->{country};
    my $estimated_travel_date   = $c->request->params->{estimated_travel_date};
    my $payment_method          = $c->request->params->{payment_method};
    my $name_on_card            = $c->request->params->{name_on_card};
    my $card_number             = $c->request->params->{card_number};
    my $card_exp_month          = $c->request->params->{card_exp_month};
    my $card_exp_year           = $c->request->params->{card_exp_year};
    my $card_cvv                = $c->request->params->{card_cvv};
    my $deal_purchased          = $c->request->params->{deal_purchased};
    my $card_auth               = $c->request->params->{card_auth};
    my $purchase_date           = $c->request->params->{purchase_date};
    my $merchant_id             = $c->request->params->{merchant_id};
    my $genie_number_1          = $c->request->params->{genie_number_1};
    my $genie_number_2          = $c->request->params->{genie_number_2};
    my $agent_id                = $c->request->params->{agent_id};
    my $gifts_given             = $c->request->params->{gifts_given};
    my $charged_amount          = $c->request->params->{charged_amount};
    my $notes                   = $c->request->params->{notes};

    # Convert dates submited by the form to SQL dates
    $purchase_date          = date_format('mdY_to_Ymd',$purchase_date);
    $estimated_travel_date  = date_format('mdY_to_Ymd',$estimated_travel_date);

    # Create deal
    my $deal = $c->model('ccdaDB::Deals')->create({
        callcenter_id           => $callcenter_id,
        first_name              => $first_name,
        last_name               => $last_name,
        home_phone              => $home_phone,
        cell_phone              => $cell_phone,
        work_phone              => $work_phone,
        email_address           => $email_address,
        address                 => $address,
        zip_code                => $zip_code,
        city                    => $city,
        state                   => $state,
        country                 => $country,
        estimated_travel_date   => $estimated_travel_date,
        payment_method          => $payment_method,
        name_on_card            => $name_on_card,
        card_number             => $card_number,
        card_exp_month          => $card_exp_month,
        card_exp_year           => $card_exp_year,
        card_cvv                => $card_cvv,
        card_auth               => $card_auth,
        purchase_date           => $purchase_date,
        merchant_id             => $merchant_id,
        genie_number_1          => $genie_number_1,
        genie_number_2          => $genie_number_2,
        agent_id                => $agent_id,
        charged_amount          => $charged_amount,
        notes                   => $notes,
    });

    # Add deal_purchased
    if ($deal_purchased) {
        if (ref($deal_purchased) eq 'ARRAY') {
            # create a record for each role the user has
            foreach my $dp ( @{ $deal_purchased } ) {
                $deal->create_related('deal_vacation', { vacation_id => $dp });
            }
        } else {
            # create record for each role the user has
            $deal->create_related('deal_vacation', { vacation_id => $deal_purchased });
        }
    }

    
    # Add gifts_given
    if ($gifts_given) {
        if (ref($gifts_given) eq 'ARRAY') {
            # create a record for each gift the deal has
            foreach my $gg ( @{ $gifts_given } ) {
                $deal->create_related('deal_gift', { gift_id => $gg });
            }
        } else {
            # create record for each gift the deal has
            $deal->create_related('deal_gift', { gift_id => $gifts_given });
        }   
    }

    # Status message
    $c->flash->{status_msg} = "deal $first_name $last_name created.";

    # Set redirect to gifts list
    $c->response->redirect($c->uri_for($c->controller('Reports')->action_for('deals_all')));

}

=head2 view

Display details of a particular deal

=cut

sub view :Chained('deal') :PathPart('view') :Args(0) {
    my ($self, $c) = @_;

    # Set the deal id
    my $id = $c->stash->{deal_id};

    # Get my misc resultsets
    $c->stash->{deal_gifts} = [$c->model('ccdaDB::DealGifts')->search({
        deal_id => $id 
    })];
    $c->stash->{deal_vacations} = [$c->model('ccdaDB::DealVacations')->search({
        deal_id => $id 
    })];
    $c->stash->{states} = [$c->model('ccdaDB::States')->all];
    $c->stash->{countries} = [$c->model('ccdaDB::Countries')->all];
    $c->stash->{status} = [$c->model('ccdaDB::Status')->all];
    $c->stash->{transaction_status} =
        [$c->model('ccdaDB::TransactionStatus')->all];
    $c->stash->{payments} = [$c->model('ccdaDB::Payments')->all];

    if ($c->check_user_roles('admin')) {

        $c->stash->{vacations} = [$c->model('ccdaDB::Vacations')->search({
            active => '1'
        })];
        $c->stash->{gifts} = [$c->model('ccdaDB::Gifts')->search({
            active => '1'
        })];
        $c->stash->{merchants} = [$c->model('ccdaDB::Merchants')->search({
            active => '1'
        })];
        $c->stash->{agents} = [$c->model('ccdaDB::Users')->search(
            { active => '1', role_id => '3' },
            { join  => 'map_user_role' }
        )];
        $c->stash->{callcenters} = [$c->model('ccdaDB::Callcenters')->search({
            active => '1'
        })];

    } else {
        $c->stash->{vacations} = [$c->model('ccdaDB::Vacations')->search(
            { active => '1', callcenter_id => $c->stash->{callcenter_id} },
            { join => 'map_callcenter_vacation' }
        )];
        $c->stash->{gifts} = [$c->model('ccdaDB::Gifts')->search(
            { active => '1', callcenter_id => $c->stash->{callcenter_id} },
            { join => 'map_callcenter_gift' }
        )];
        $c->stash->{merchants} = [$c->model('ccdaDB::Merchants')->search(
            { active => '1', callcenter_id => $c->stash->{callcenter_id} },
            { join => 'map_callcenter_merchant' }
        )];
        $c->stash->{agents} = [$c->model('ccdaDB::Users')->search(
            {
              active => '1',
              role_id => '3',
              callcenter_id => $c->stash->{callcenter_id}
            } ,
            { join  => 'map_user_role' }
        )];

    }


    # Fix the purchase_date
    my $purchase_date = $c->stash->{deal}->purchase_date->date;
    $c->stash->{purchase_date} = date_format('Ymd_to_mdY',$purchase_date);

    # Fix the estimated_travel_date
    my $estimated_travel_date = $c->stash->{deal}->estimated_travel_date->date;
    $c->stash->{estimated_travel_date} = date_format(
        'Ymd_to_mdY',
        $estimated_travel_date
    );

    # Set the TT template to use
    $c->stash->{template} = 'deals/view.tt2'; 
}

=head2 update_do

Take information from form and update the database

=cut

sub update_do :Chained('deal') :PathPart('update_do') :Args(0) {
    my ($self, $c) = @_;

    my $id = $c->stash->{deal_id};

    # Retrieve the values from the form
    my $callcenter_id           = $c->request->params->{callcenter_id};
    my $first_name              = $c->request->params->{first_name};
    my $last_name               = $c->request->params->{last_name};
    my $home_phone              = $c->request->params->{home_phone};
    my $cell_phone              = $c->request->params->{cell_phone};
    my $work_phone              = $c->request->params->{work_phone};
    my $email_address           = $c->request->params->{email_address};
    my $address                 = $c->request->params->{address};
    my $zip_code                = $c->request->params->{zip_code};
    my $city                    = $c->request->params->{city};
    my $state                   = $c->request->params->{state};
    my $country                 = $c->request->params->{country};
    my $estimated_travel_date   = $c->request->params->{estimated_travel_date};
    my $payment_method          = $c->request->params->{payment_method};
    my $name_on_card            = $c->request->params->{name_on_card};
    my $card_number             = $c->request->params->{card_number};
    my $card_exp_month          = $c->request->params->{card_exp_month};
    my $card_exp_year           = $c->request->params->{card_exp_year};
    my $card_cvv                = $c->request->params->{card_cvv};
    my $deal_purchased          = $c->request->params->{deal_purchased};
    my $card_auth               = $c->request->params->{card_auth};
    my $purchase_date           = $c->request->params->{purchase_date};
    my $merchant_id             = $c->request->params->{merchant_id};
    my $genie_number_1          = $c->request->params->{genie_number_1};
    my $genie_number_2          = $c->request->params->{genie_number_2};
    my $agent_id                = $c->request->params->{agent_id};
    my $gifts_given             = $c->request->params->{gifts_given};
    my $charged_amount          = $c->request->params->{charged_amount};
    my $notes                   = $c->request->params->{notes};
    my $status                  = $c->request->params->{status};

    # Format my dates for SQL 
    $purchase_date = date_format('mdY_to_Ymd', $purchase_date);
    $estimated_travel_date = date_format('mdY_to_Ymd', $estimated_travel_date);

    if ($status eq '2' && $charged_amount > 0) {
        $charged_amount = $charged_amount * -1;
    } else {
        if ($charged_amount < 0) {
            $charged_amount = $charged_amount * -1;
        }
    } 

    # Create deal
    my $deal = $c->model('ccdaDB::Deals')->find($id)->update({
        callcenter_id           => $callcenter_id,
        first_name              => $first_name,
        last_name               => $last_name,
        home_phone              => $home_phone,
        cell_phone              => $cell_phone,
        work_phone              => $work_phone,
        email_address           => $email_address,
        address                 => $address,
        zip_code                => $zip_code,
        city                    => $city,
        state                   => $state,
        country                 => $country,
        estimated_travel_date   => $estimated_travel_date,
        payment_method          => $payment_method,
        name_on_card            => $name_on_card,
        card_number             => $card_number,
        card_exp_month          => $card_exp_month,
        card_exp_year           => $card_exp_year,
        card_cvv                => $card_cvv,
        card_auth               => $card_auth,
        purchase_date           => $purchase_date,
        merchant_id             => $merchant_id,
        genie_number_1          => $genie_number_1,
        genie_number_2          => $genie_number_2,
        agent_id                => $agent_id,
        charged_amount          => $charged_amount,
        notes                   => $notes,
        status                  => $status,
    });

    # Update vacations
    my $del_vacations = $c->model('ccdaDB::DealVacations')->search(
        {deal_id => $id }
    )->delete;

    if ($deal_purchased) {
        my $vacations = $deal_purchased;

        if (ref($vacations) eq 'ARRAY') {
            # create a record for each vacation the deal has
            foreach my $vacation ( @{ $vacations } ) {
                $deal->create_related('deal_vacation', { vacation_id => $vacation });
            }
        } else {
            # create record for each vacation the deal has
            $deal->create_related('deal_vacation', { vacation_id => $vacations });
        }
    }

    # Update gifts
    my $del_gifts = $c->model('ccdaDB::DealGifts')->search(
        {deal_id => $id }
    )->delete;

    if ($gifts_given) {
        my $gifts = $gifts_given;

        if (ref($gifts) eq 'ARRAY') {
            # create a record for each gift the deal has
            foreach my $gift ( @{ $gifts } ) {
                $deal->create_related('deal_gift', { gift_id => $gift });
            }
        } else {
            # create record for each gift the deal has
            $deal->create_related('deal_gift', { gift_id => $gifts });
        }
    }


    # Status message
    $c->flash->{status_msg} = "deal $first_name $last_name updated.";

    # Set redirect to gifts list
    $c->response->redirect($c->uri_for($c->controller('Reports')->action_for('deals_all')));

}

=head2 delete_do

Delete a deal

=cut

sub delete_do :Chained('deal') :PathPart('delete_do') :Args(0) {
    my ($self, $c) = @_;

    my $id = $c->stash->{deal_id};

    # Check permissions
    $c->detach('/error_noperms')
        unless $c->stash->{deal}->delete_allowed_by($c->user->get_deal);

    # Use the deal deal saved by 'deal' and delete it along
    $c->stash->{deal}->delete;

    my $del_vacations = $c->model('ccdaDB::DealVacations')->search(
        {deal_id => $id }
    )->delete;

    my $del_gifts = $c->model('ccdaDB::DealGifts')->search(
        {deal_id => $id }
    )->delete;


    # Use 'flash' to save information across requests until it's read
    $c->flash->{status_msg} = "Deal deleted";

    # Redirect the user back to the list page
    $c->response->redirect($c->uri_for($c->controller('Reports')->action_for('deals_all')));

}  

=head2 fixCheckbox

Create a string from the results out of a checkbox group 
that we can store in a database table

=cut

sub fixCheckbox {
    my $array = shift;
    my $return;

    if (ref($array) eq 'ARRAY') {
        foreach my $a ( @{ $array } ) {
            $return .= "$a,";
        }  
        $return =~ s/,$//;
    } else {
        $return = $array;
    }
   
return $return;
}

sub date_format  {
    # TODO: accept multiple formats
    my $format = shift;
    my $var = shift;
    my @split_date;
    my $date;
    my $ret;

    if ($format eq "mdY_to_Ymd") {
        # From month-day-year date create the SQL date format
        @split_date = split(/-/, $var);
        $date = "$split_date[2]-$split_date[0]-$split_date[1]";
    }
    
    if ($format eq "Ymd_to_mdY") {
        # From SQL date create the month-day-year date format       
        @split_date = split(/-/, $var);
        $date = "$split_date[1]-$split_date[2]-$split_date[0]";
    }
    
    $ret = $date;
    
return $ret;
}

=head1 AUTHOR

root

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
