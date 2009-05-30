package ccda::Controller::Admin;

use strict;
use warnings;
use parent 'Catalyst::Controller';
use Digest::SHA1  qw(sha1 sha1_hex);

=head1 NAME

ccda::Controller::Admin - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index

=cut

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;

    $c->response->body('Matched ccda::Controller::Admin in Admin.');
}

=head2 base

Can place common logic to start  chained dispatch here

=cut

sub base :Chained('/') :PathPart('admin') :CaptureArgs(0) {
    my ( $self, $c ) = @_;

    # Store the ResultSet in stash so it's available for other methods
    $c->stash->{resultset} = $c->model('ccdaDB::Deals');
    $c->stash->{admin_action} = 1;

    # Print a message to the debug log
    $c->log->debug('*** INSIDE BASE METHOD ***');
}

=head2 object

Fetch the specified deal objet based on the book ID and store it in the stash

=cut

sub object :Chained('base') :PathPart('id') :CaptureArgs(1) {
    # $id = primary key of deal
    my ( $self, $c, $id ) = @_;

    # Find the dsal object and store it in the stash
    #$c->stash(object => $c->stash->{resultset}->find($id));

    $c->stash->{id} = $id;

    # Make sure the lookup was successful.
    die "Deal $id not found!" if !$c->stash->{object};
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


=head2 list

List admin

=cut

sub list :Chained('base') :PathPart('list') :Args(0) {
    my ($self, $c) = @_;

    # Set the TT template to use
    $c->stash->{template} = 'admin/list.tt2';
}

=head2 brokers

Base for all my brokers methods

=cut

sub brokers :Chained('base') :PathPart('brokers') :CaptureArgs(0) {
    my ($self, $c) = @_;

    $c->stash->{rsBrokers} = $c->model('ccdaDB::Brokers');
}

=head2 brokers_broker

Base for record specific methods
/admin/brokers/*/action

=cut

sub brokers_broker :Chained('brokers') :PathPart('') :CaptureArgs(1) {
    my ($self, $c, $id) = @_;

    # Store id in stash
    $c->stash->{broker_id} = $id;
    
    # Store record in the stash
    $c->stash->{broker} = $c->stash->{rsBrokers}->find($id);

    $c->stash->{template} = '';
}

=head2 broker_create

Create brokers

=cut

sub broker_create :Chained('brokers') :PathPart('create') :Args(0) {
    my ($self, $c) = @_;

    # Set the TT template to use
    $c->stash->{template} = 'admin/broker_create.tt2';
}

=head2 broker_create_do

Add the submited broker to the database

=cut

sub broker_create_do :Chained('brokers') :PathPart('create_do') :Args(0) {
    my ($self, $c) = @_;

    # Retrieve the values from the form
    my $name                    = $c->request->params->{name};
    my $percentage              = $c->request->params->{percentage};
    my $active                  = $c->request->params->{active};
    my $notes                   = $c->request->params->{notes};

    # Create broker
    my $broker = $c->stash->{rsBrokers}->create({
        name            => $name,
        percentage      => $percentage,
        active          => $active,
        notes           => $notes,
    });

    # Status message
    $c->flash->{status_msg} = "broker $name created.";

    # Set redirect to brokers list
    $c->response->redirect($c->uri_for($self->action_for('brokers_list')));
}

=head2 brokers_list

Display all the brokers

=cut

sub brokers_list :Chained('brokers') :PathPart('list') :Args(0) {
    my ($self, $c) = @_;

    # Get all my brokersss
    $c->stash->{brokers} = [$c->stash->{rsBrokers}->all];

    # Set the TT template to use
    $c->stash->{template} = 'admin/brokers_list.tt2';
}

=head2 broker_view

Display information for specific broker

=cut

sub broker_view :Chained('brokers_broker') :PathPart('view') :Args(0) {
    my ($self, $c) = @_;

    my $id = $c->stash->{broker_id};

    $c->stash->{callcenters} = [$c->model('ccdaDB::Callcenters')->search (
        { broker_id => $id }
    )];
    
    # Set the TT template to use
    $c->stash->{template} = 'admin/broker_view.tt2';
}


=head2 broker_update_do

Update the brokers details

=cut

sub broker_update_do :Chained('brokers_broker') :PathPart('broker_update_do') :Args(0) {
    my ($self, $c) = @_;

    my $id = $c->stash->{broker_id};

    # Update the template
    # Retrieve the values from the form
    my $name                    = $c->request->params->{name};
    my $percentage              = $c->request->params->{percentage};
    my $active                  = $c->request->params->{active};
    my $notes                   = $c->request->params->{notes};

    # Update broker
    my $broker = $c->stash->{broker}->update({
        name            => $name,
        percentage      => $percentage,
        active          => $active,
        notes           => $notes,
    });

    # Status message
    $c->flash->{status_msg} = "broker $id updated.";

    # Set redirect to brokers list
    $c->response->redirect($c->uri_for($self->action_for('brokers_list')));
}

=head2 broker_delete_do

Delete specific broker

=cut

sub broker_delete_do :Chained('brokers_broker') :PathPart('delete') :Args(0) {
    my ($self, $c) = @_;

    my $id = $c->stash->{broker_id};

    $c->stash->{broker}->delete];

    # Status message
    $c->flash->{status_msg} = "broker $id deleted.";

    # Set redirect to brokers list
    $c->response->redirect($c->uri_for($self->action_for('brokers_list')));
}

=head2 callcenters

Base for all my callcenters methods

=cut

sub callcenters :Chained('base') :PathPart('callcenters') :CaptureArgs(0) {
    my ($self, $c) = @_;

    # Store the ResultSet in stash so it's available for other methods
    $c->stash->{rsCallcenters} = $c->model('ccdaDB::Callcenters');
    
}

=head2 callcenters_callcenter

Base for record specific methods
/admin/callcenters/*/action

=cut

sub callcenters_callcenter :Chained('callcenters') :PathPart('') :CaptureArgs(1) {
    my ($self, $c, $id) = @_;

    # Find the deal object and store it in the stash
    $c->stash->{callcenter} = $c->stash->{rsCallcenters}->find($id);
    
    # Store id in stash
    $c->stash->{id} = $id;

    $c->stash->{template} = '';
}

=head2 callcenter_create

Create callcenters

=cut

sub callcenter_create :Chained('callcenters') :PathPart('create') :Args(0) {
    my ($self, $c) = @_;
    
    # Get my brokers
    $c->stash->{brokers} = [$c->model('ccdaDB::Brokers')->search(
        { active => '1' }
    )];

    # Get my merchants
    $c->stash->{merchants} = [$c->model('ccdaDB::Merchants')->search(
        { active => '1' }
    )];

    # Get my vacations
    $c->stash->{vacations} = [$c->model('ccdaDB::Vacations')->search(
        { active => '1' }
    )];

    # Get my gifts
    $c->stash->{gifts} = [$c->model('ccdaDB::Gifts')->search(
        { active => '1' }
    )];

    # Set the TT template to use
    $c->stash->{template} = 'admin/callcenter_create.tt2';
}

=head2 callcenter_create_do

Add the submited callcenter to the database

=cut


sub callcenter_create_do :Chained('callcenters') :PathPart('create_do') :Args(0) {
    my ($self, $c) = @_;

    # Retrieve the values from the form
    my $broker_id               = $c->request->params->{broker_id};    
    my $name                    = $c->request->params->{name};
    my $alias                   = $c->request->params->{alias};    
    my $contact                 = $c->request->params->{contact};    
    my $work_phone              = $c->request->params->{work_phone};    
    my $cell_phone              = $c->request->params->{cell_phone};    
    my $email_address           = $c->request->params->{email_address};    
    my $address_1               = $c->request->params->{address_1};    
    my $address_2               = $c->request->params->{address_2};    
    my $city                    = $c->request->params->{city};    
    my $state                   = $c->request->params->{state};    
    my $zip_code                = $c->request->params->{zip_code};    
    my $country                 = $c->request->params->{country};    
    my $percentage              = $c->request->params->{percentage};    
    my $processing_fee          = $c->request->params->{processing_fee};    
    my $chargeback_fee          = $c->request->params->{chargeback_fee};
    my $vacations               = $c->request->params->{vacations};
    my $gifts                   = $c->request->params->{gifts};
    my $merchants               = $c->request->params->{merchants};
    my $active                  = $c->request->params->{active};
    my $notes                   = $c->request->params->{notes};

    # Create callcenter
    my $callcenter = $c->stash->{rsCallcenters}->create({
        broker_id       => $broker_id,   
        name            => $name,
        alias           => $alias,
        contact         => $contact,
        work_phone      => $work_phone,
        cell_phone      => $cell_phone,
        email_address   => $email_address,
        address_1       => $address_1,
        address_2       => $address_2,
        city            => $city,
        state           => $state,
        zip_code        => $zip_code,
        country         => $country,
        percentage      => $percentage,
        processing_fee  => $processing_fee,    
        chargeback_fee  => $chargeback_fee,
        active          => $active,
        notes           => $notes,
    });
    
    # Add vacations pacakges to our call center
    if ($vacations) {
        # is $vacation an array or a single string.
        # cause we are pulling from a checkbox if the return is a single element
        # its return as a scalar var, if it has multiple elements its retrurned
        # as an array reference
        if (ref($vacations) eq 'ARRAY') {
            # create a record for each vacation the callcenter has
            foreach my $vacation ( @{ $vacations } ) {
                $callcenter->create_related(
                    'map_callcenter_vacation', { vacation_id => $vacation }
                );
            }
        } else {
            # create record for each role the user has
            $callcenter->create_related(
                'map_callcenter_vacation', { vacation_id => $vacations }
            );
        }

    }

    # Add gifts pacakges to our call center
    if ($gifts) {
        # is $gift an array or a single string.
        # cause we are pulling from a checkbox if the return is a single element
        # its return as a scalar var, if it has multiple elements its retrurned
        # as an array reference
        if (ref($gifts) eq 'ARRAY') {
            # create a record for each gift the callcenter has
            foreach my $gift ( @{ $gifts } ) {
                $callcenter->create_related(
                    'map_callcenter_gift', { gift_id => $gift }
                );
            }
        } else {
            # create record for each role the user has
            $callcenter->create_related(
                'map_callcenter_gift', { gift_id => $gifts }
            );
        }

    }


    if ($merchants) {
        # is $merchant an array or a single string.
        # because we are pulling from a checkbox if the return is a single element
        # its return as a scalar var, if it has multiple elements its retrurned
        # as an array reference
        if (ref($merchants) eq 'ARRAY') {
            # create a record for each merchant the callcenter has
            foreach my $merchant ( @{ $merchants } ) {
                $callcenter->create_related('map_callcenter_merchant', { merchant_id => $merchant });
            }
        } else {
            # create record for each role the user has
            $callcenter->create_related('map_callcenter_merchant', { merchant_id => $merchants });
        }   

    }

    # Status message
    $c->flash->{status_msg} = "callcenter $name created.";

    # Set redirect to callcenters list
    $c->response->redirect($c->uri_for($self->action_for('callcenters_list')));
}

=head2 callcenters_list

Display all the callcenters

=cut

sub callcenters_list :Chained('callcenters') :PathPart('list') :Args(0) {
    my ($self, $c) = @_;

    # Get all my callcentersss
    #$c->stash->{callcenters} = [$c->model('ccdaDB::Callcenters')->all];
    $c->stash->{callcenters} = [$c->stash->{rsCallcenters}->all];

    # Set the TT template to use
    $c->stash->{template} = 'admin/callcenters_list.tt2';
}

=head2 callcenter_view

Display information for specific callcenter

=cut

sub callcenter_view :Chained('callcenters_callcenter') :PathPart('view') :Args(0) {
    my ($self, $c) = @_;

    my $id = $c->stash->{id};

    # Get my brokers
    $c->stash->{brokers} = [$c->model('ccdaDB::Brokers')->all];

    # Get my vacations
    $c->stash->{vacations} = [$c->model('ccdaDB::Vacations')->all];
    $c->stash->{callcentervacations} = [
        $c->model('ccdaDB::CallcenterVacations')->search(
            { callcenter_id => $id  }
        )
    ];

    # Get my gifts
    $c->stash->{gifts} = [$c->model('ccdaDB::Gifts')->all];
    $c->stash->{callcentergifts} = [
        $c->model('ccdaDB::CallcenterGifts')->search(
            { callcenter_id => $id  }
        )
    ];

    # Get my merchants
    $c->stash->{merchants} = [$c->model('ccdaDB::Merchants')->all];
    $c->stash->{callcentermerchants} = [
        $c->model('ccdaDB::CallcenterMerchants')->search( 
            { callcenter_id => $id  } 
        )
    ];

    # Set the TT template to use
    $c->stash->{template} = 'admin/callcenter_view.tt2';
}


=head2 callcenter_update_do

Update the callcenters details

=cut

sub callcenter_update_do :Chained('callcenters_callcenter') :PathPart('callcenter_update_do') :Args(0) {
    my ($self, $c) = @_;

    my $id = $c->stash->{id};

    # Update the template
    # Retrieve the values from the form
    my $broker_id               = $c->request->params->{broker_id};
    my $name                    = $c->request->params->{name};
    my $alias                   = $c->request->params->{alias};
    my $contact                 = $c->request->params->{contact};
    my $work_phone              = $c->request->params->{work_phone};
    my $cell_phone              = $c->request->params->{cell_phone};
    my $email_address           = $c->request->params->{email_address};
    my $address_1               = $c->request->params->{address_1};
    my $address_2               = $c->request->params->{address_2};
    my $city                    = $c->request->params->{city};
    my $state                   = $c->request->params->{state};
    my $zip_code                = $c->request->params->{zip_code};
    my $country                 = $c->request->params->{country};
    my $percentage              = $c->request->params->{percentage};
    my $processing_fee          = $c->request->params->{processing_fee};
    my $chargeback_fee          = $c->request->params->{chargeback_fee};
    my $active                  = $c->request->params->{active};
    my $vacations               = $c->request->params->{vacations};
    my $gifts                   = $c->request->params->{gifts};
    my $merchants               = $c->request->params->{merchants};
    my $notes                   = $c->request->params->{notes};


    # Update callcenter
    my $callcenter = $c->stash->{callcenter}->update({
        broker_id       => $broker_id,   
        name            => $name,
        alias           => $alias,
        contact         => $contact,
        work_phone      => $work_phone,
        cell_phone      => $cell_phone,
        email_address   => $email_address,
        address_1       => $address_1,
        address_2       => $address_2,
        city            => $city,
        state           => $state,
        zip_code        => $zip_code,
        country         => $country,
        percentage      => $percentage,
        processing_fee  => $processing_fee,    
        chargeback_fee  => $chargeback_fee,
        active          => $active,
        notes           => $notes,
    });

    # Delete callcenter vacations
    $c->model('ccdaDB::CallcenterVacations')->search(
        { callcenter_id => $id }
    )->delete;

    # Check if we have vacations
    if ($vacations) {
        # is $vacation an array or a single string.
        # because we are pulling from a checkbox if the return is a single
        # element its return as a scalar var, if it has multiple elements its
        # retrurned as an array reference
        if (ref($vacations) eq 'ARRAY') {
            # create a record for each vacation the callcenter has
            foreach my $vacation ( @{ $vacations } ) {
                $callcenter->create_related(
                    'map_callcenter_vacation', { vacation_id => $vacation }
                );
            }
        } else {
            # create record for each role the user has
            $callcenter->create_related(
                'map_callcenter_vacation', { vacation_id => $vacations }
            );
        }
    }

    # Delete callcenter gifts
    $c->model('ccdaDB::CallcenterGifts')->search(
        { callcenter_id => $id }
    )->delete;

    # Check if we have gifts
    if ($gifts) {
        # is $gift an array or a single string.
        # because we are pulling from a checkbox if the return is a single
        # element its return as a scalar var, if it has multiple elements its
        # retrurned as an array reference
        if (ref($gifts) eq 'ARRAY') {
            # create a record for each gift the callcenter has
            foreach my $gift ( @{ $gifts } ) {
                $callcenter->create_related(
                    'map_callcenter_gift', { gift_id => $gift }
                );
            }
        } else {
            # create record for each role the user has
            $callcenter->create_related(
                'map_callcenter_gift', { gift_id => $gifts }
            );
        }
    }


    # Delete callcenter merchants 
    $c->model('ccdaDB::CallcenterMerchants')->search(
        { callcenter_id => $id }
    )->delete; 

    # Check if we have merchants
    if ($merchants) {
        # is $merchant an array or a single string.
        # because we are pulling from a checkbox if the return is a single 
        # element its return as a scalar var, if it has multiple elements its 
        # retrurned as an array reference
        if (ref($merchants) eq 'ARRAY') {
            # create a record for each merchant the callcenter has
            foreach my $merchant ( @{ $merchants } ) {
                $callcenter->create_related(
                    'map_callcenter_merchant', { merchant_id => $merchant }
                );
            }
        } else {
            # create record for each role the user has
            $callcenter->create_related(
                'map_callcenter_merchant', { merchant_id => $merchants }
            );
        }
    }

    # Status message
    $c->flash->{status_msg} = "callcenter $id updated.";

    # Set redirect to callcenters list
    $c->response->redirect($c->uri_for($self->action_for('callcenters_list')));
}

=head2 callcenter_delete_do

Delete specific callcenter

=cut

sub callcenter_delete_do :Chained('callcenters_callcenter') :PathPart('delete') :Args(0) {
    my ($self, $c) = @_;

    my $id = $c->stash->{id};

    # Delete the callcenter (because of has_many it will cascade)
    $c->stash->{callcenter}->delete;

    # Status message
    $c->flash->{status_msg} = "callcenter $id deleted.";

    # Set redirect to callcenters list
    $c->response->redirect($c->uri_for($self->action_for('callcenters_list')));
}




=head2 users

Base for all my users methods

=cut

sub users :Chained('base') :PathPart('users') :CaptureArgs(0) {
    my ($self, $c) = @_;

    # Store the ResultSet in stash so it's available for other methods
    $c->stash->{rsUsers} = $c->model('ccdaDB::Users');
    
    # Set callcenter id in the stash
    $c->stash->{callcenter_id} = $c->user->callcenter_id;
}

=head2 users_user

Base for record specific methods
/admin/users/*/action

=cut

sub users_user :Chained('users') :PathPart('') :CaptureArgs(1) {
    my ($self, $c, $id) = @_;

    # Store id in stash
    $c->stash->{user_id} = $id;

    # Find the deal deal and store it in the stash
    $c->stash->{user} = $c->stash->{rsUsers}->find($id);

    # Make sure the lookup was successful.
    die "User $id not found!" if !$c->stash->{user};
}

=head2 user_create

Create users

=cut

sub user_create :Chained('users') :PathPart('create') :Args(0) {
    my ($self, $c) = @_;
    
    # Get all my callcenters
    $c->stash->{callcenters} = [$c->model('ccdaDB::Callcenters')->all];

    # Get all my roles to be display in our form
    $c->stash->{roles} = [$c->model('ccdaDB::Roles')->all];
    
    # Set the TT template to use
    $c->stash->{template} = 'admin/user_create.tt2';
}

=head2 user_create_do

Add the submited user to the database

=cut

sub user_create_do :Chained('users') :PathPart('create_do') :Args(0) {
    my ($self, $c) = @_;

    # Retrieve the values from the form
    my $callcenter_id           = $c->request->params->{callcenter_id};
    my $first_name              = $c->request->params->{first_name};
    my $last_name               = $c->request->params->{last_name};
    my $username                = $c->request->params->{username};
    my $password                = sha1_hex($c->request->params->{password});
    my $email_address           = $c->request->params->{email_address};
    my $active                  = $c->request->params->{active};
    my $notes                   = $c->request->params->{notes};
    my $roles                   = $c->request->params->{role};

    # Create user
    my $user = $c->stash->{rsUsers}->create({
        callcenter_id   => $callcenter_id,
        first_name      => $first_name,
        last_name       => $last_name,
        username        => $username,
        password        => $password,
        email_address   => $email_address,
        active          => $active,
        notes           => $notes,
    });

    # is $roles an array or a single string.
    # because we are pulling from a checkbox if the return is a single element
    # its return as a scalar var, if it has multiple elements its retrurned
    # as an array reference
    if (ref($roles) eq 'ARRAY') {
        # create a record for each role the user has
        foreach my $role ( @{ $roles } ) {
            $user->create_related('map_user_role', { role_id => $role });
        }
    } else {
        # create record for each role the user has
        $user->create_related('map_user_role', { role_id => $roles }); 
    }

    # Data::Dumer issue
    $Data::Dumper::Useperl = 1;

    # Status message
    $c->flash->{status_msg} = "User $username created.";

    # Set redirect to users list
    $c->response->redirect($c->uri_for($self->action_for('users_list')));

}

=head2 users_list

Display all the users

=cut 

sub users_list :Chained('users') :PathPart('list') :Args(0) {
    my ($self, $c) = @_;
    my $callcenter_id = $c->user->callcenter_id;
    my %search;
    
    if (!($c->check_user_roles('admin'))) {
        $search{callcenter_id} = $callcenter_id;
    }
    
    # Get all my usersss
    $c->stash->{users} = [$c->stash->{rsUsers}->search(
        { %search },
        { order_by => 'id' }
    )];

    # Set the TT template to use
    $c->stash->{template} = 'admin/users_list.tt2';
}

=head2 user_view

Display information for specific user

=cut

sub user_view :Chained('users_user') :PathPart('view') :Args(0) {
    my ($self, $c) = @_;

    my $id = $c->stash->{user_id};

    # Get all my roles to be display in our form
    $c->stash->{roles} = [$c->model('ccdaDB::Roles')->all];
    $c->stash->{userroles} = [$c->model('ccdaDB::UserRoles')->search(
        {user_id => $id }
    )];
   
    # Get my callcenters
    $c->stash->{callcenters} = [$c->model('ccdaDB::Callcenters')->all];
    
    # Set the TT template to use
    $c->stash->{template} = 'admin/user_view.tt2';
}

=head2 user_update_do

Update the users details

=cut

sub user_update_do :Chained('users_user') :PathPart('user_update_do') :Args(0) {
    my ($self, $c) = @_;

    my $id = $c->stash->{user_id};

    my $current_password = $c->stash->{user}->password;

    # Update the template
    # Retrieve the values from the form
    my $callcenter_id           = $c->request->params->{callcenter_id};
    my $first_name              = $c->request->params->{first_name};
    my $last_name               = $c->request->params->{last_name};
    my $username                = $c->request->params->{username};
    my $password                ;
    my $email_address           = $c->request->params->{email_address};
    my $active                  = $c->request->params->{active};
    my $notes                   = $c->request->params->{notes};
    my $roles                   = $c->request->params->{role};

    # Check if password has changed, before it updates the database
    #if ($c->request->params->{password} ne $current_password->password) {
    if ($c->request->params->{password} ne $current_password) {
        $password = sha1_hex($c->request->params->{password});   
    } else {
        $password = $current_password;
    }

    # Update user
    my $user = $c->stash->{user}->update({
        callcenter_id   => $callcenter_id,
        first_name      => $first_name,
        last_name       => $last_name,
        username        => $username,
        password        => $password,
        email_address   => $email_address,
        notes           => $notes,
        active          => $active,
    });

    # Update roles    
    # First delete previous roles
    my $del_roles = $c->model('ccdaDB::UserRoles')->search(
        {user_id => $id }
    )->delete;

    # If we have any roles then create them
    if ($roles) {
        # is $roles an array or a single string.
        # because we are pulling from a checkbox if the return is a single 
        # element its return as a scalar var, if it has multiple elements its 
        # retrurned as an array reference
        if (ref($roles) eq 'ARRAY') {
            # create a record for each role the user has
            foreach my $role ( @{ $roles } ) {
                $user->create_related('map_user_role', { role_id => $role });
            }
        } else {
            # create record for each role the user has
            $user->create_related('map_user_role', { role_id => $roles });
        }
    }

    # Status message
    $c->flash->{status_msg} = "User $id updated.";

    # Set redirect to users list
    $c->response->redirect($c->uri_for($self->action_for('users_list')));
}

=head2 user_delete_do

Delete specific user

=cut

sub user_delete_do :Chained('users_user') :PathPart('delete') :Args(0) {
    my ($self, $c) = @_;

    my $id = $c->stash->{user_id};

    # Find the user and delete it
    #$c->stash->{user} = $c->stash->{user}->delete;
    $c->stash->{user}->delete;

    # Status message
    $c->flash->{status_msg} = "User $id deleted.";

    # Set redirect to users list
    $c->response->redirect($c->uri_for($self->action_for('users_list')));
}

=head2 vacations

Base for all my vacations methods

=cut

sub vacations :Chained('base') :PathPart('vacations') :CaptureArgs(0) {
    my ($self, $c) = @_;

}

=head2 vacations_vacation

Base for record specific methods
/admin/vacations/*/action

=cut

sub vacations_vacation :Chained('vacations') :PathPart('') :CaptureArgs(1) {
    my ($self, $c, $id) = @_;

    # Store id in stash
    $c->stash->{id} = $id;

    $c->stash->{template} = '';
}

=head2 vacation_create

Create vacations

=cut

sub vacation_create :Chained('base') :PathPart('vacations/create') :Args(0) {
    my ($self, $c) = @_;

    # Set the TT template to use
    $c->stash->{template} = 'admin/vacation_create.tt2';
}

=head2 vacation_create_do

Add the submited vacation to the database

=cut

sub vacation_create_do :Chained('base') :PathPart('vacations/create_do') :Args(0) {
    my ($self, $c) = @_;

    # Retrieve the values from the form
    my $name                    = $c->request->params->{name};
    my $active                  = $c->request->params->{active};
    my $notes                   = $c->request->params->{notes};

    # Create vacation
    my $vacation = $c->model('ccdaDB::vacations')->create({
        name            => $name,
        active          => $active,
        notes           => $notes,
    });

    # Status message
    $c->flash->{status_msg} = "vacation $name created.";

    # Set redirect to vacations list
    $c->response->redirect($c->uri_for($self->action_for('vacations_list')));

}

=head2 vacations_list

Display all the vacations

=cut

sub vacations_list :Chained('vacations') :PathPart('list') :Args(0) {
    my ($self, $c) = @_;

    # Get all my vacationsss
    $c->stash->{vacations} = [$c->model('ccdaDB::vacations')->all];

    # Set the TT template to use
    $c->stash->{template} = 'admin/vacations_list.tt2';
}

=head2 vacation_view

Display information for specific vacation

=cut

sub vacation_view :Chained('vacations_vacation') :PathPart('view') :Args(0) {
    my ($self, $c) = @_;

    my $id = $c->stash->{id};

    # Get my record
    $c->stash->{vacation} = $c->model('ccdaDB::vacations')->find($id);

    # Set the TT template to use
    $c->stash->{template} = 'admin/vacation_view.tt2';
}

=head2 vacation_update_do

Update the vacations details

=cut

sub vacation_update_do :Chained('vacations_vacation') :PathPart('vacation_update_do') :Args(0) {
    my ($self, $c) = @_;

    my $id = $c->stash->{id};

    # Update the template
    # Retrieve the values from the form
    my $name                    = $c->request->params->{name};
    my $active                  = $c->request->params->{active};
    my $notes                   = $c->request->params->{notes};

    # Update vacation
    my $vacation = $c->model('ccdaDB::vacations')->find($id)->update({
        name            => $name,
        active          => $active,
        notes           => $notes,
    });

    # Status message
    $c->flash->{status_msg} = "vacation $id updated.";

    # Set redirect to vacations list
    $c->response->redirect($c->uri_for($self->action_for('vacations_list')));
}

=head2 vacation_delete_do

Delete specific vacation

=cut

sub vacation_delete_do :Chained('vacations_vacation') :PathPart('delete') :Args(0) {
    my ($self, $c) = @_;

    my $id = $c->stash->{id};

    $c->stash->{vacation} = [$c->model('ccdaDB::vacations')->find($id)->delete];

    # Status message
    $c->flash->{status_msg} = "vacation $id deleted.";

    # Set redirect to vacations list
    $c->response->redirect($c->uri_for($self->action_for('vacations_list')));
}

=head2 merchants

Base for all my merchants methods

=cut

sub merchants :Chained('base') :PathPart('merchants') :CaptureArgs(0) {
    my ($self, $c) = @_;

}

=head2 merchants_merchant

Base for record specific methods
/admin/merchants/*/action

=cut

sub merchants_merchant :Chained('merchants') :PathPart('') :CaptureArgs(1) {
    my ($self, $c, $id) = @_;

    # Store id in stash
    $c->stash->{id} = $id;

    $c->stash->{template} = '';
}

=head2 merchant_create

Create merchants

=cut

sub merchant_create :Chained('base') :PathPart('merchants/create') :Args(0) {
    my ($self, $c) = @_;

    # Set the TT template to use
    $c->stash->{template} = 'admin/merchant_create.tt2';
}

=head2 merchant_create_do

Add the submited merchant to the database

=cut

sub merchant_create_do :Chained('base') :PathPart('merchants/create_do') :Args(0) {
    my ($self, $c) = @_;

    # Retrieve the values from the form
    my $name                    = $c->request->params->{name};
    my $active                  = $c->request->params->{active};
    my $notes                   = $c->request->params->{notes};

    # Create merchant
    my $merchant = $c->model('ccdaDB::Merchants')->create({
        name            => $name,
        active          => $active,
        notes           => $notes,
    });

    # Status message
    $c->flash->{status_msg} = "merchant $name created.";

    # Set redirect to merchants list
    $c->response->redirect($c->uri_for($self->action_for('merchants_list')));

}

=head2 merchants_list

Display all the merchants

=cut

sub merchants_list :Chained('merchants') :PathPart('list') :Args(0) {
    my ($self, $c) = @_;

    # Get all my merchantsss
    $c->stash->{merchants} = [$c->model('ccdaDB::Merchants')->all];

    # Set the TT template to use
    $c->stash->{template} = 'admin/merchants_list.tt2';
}

=head2 merchant_view

Display information for specific merchant

=cut

sub merchant_view :Chained('merchants_merchant') :PathPart('view') :Args(0) {
    my ($self, $c) = @_;

    my $id = $c->stash->{id};

    # Get my record
    $c->stash->{merchant} = $c->model('ccdaDB::Merchants')->find($id);

    # Set the TT template to use
    $c->stash->{template} = 'admin/merchant_view.tt2';
}

=head2 merchant_update_do

Update the merchants details

=cut

sub merchant_update_do :Chained('merchants_merchant') :PathPart('merchant_update_do') :Args(0) {
    my ($self, $c) = @_;

    my $id = $c->stash->{id};

    # Update the template
    # Retrieve the values from the form
    my $name                    = $c->request->params->{name};
    my $active                  = $c->request->params->{active};
    my $notes                   = $c->request->params->{notes};

    # Update merchant
    my $merchant = $c->model('ccdaDB::Merchants')->find($id)->update({
        name            => $name,
        active          => $active,
        notes           => $notes,
    });

    # Status message
    $c->flash->{status_msg} = "merchant $id updated.";

    # Set redirect to merchants list
    $c->response->redirect($c->uri_for($self->action_for('merchants_list')));
}

=head2 merchant_delete_do

Delete specific merchant

=cut

sub merchant_delete_do :Chained('merchants_merchant') :PathPart('delete') :Args(0) {
    my ($self, $c) = @_;

    my $id = $c->stash->{id};

    $c->stash->{merchant} = [$c->model('ccdaDB::Merchants')->find($id)->delete];

    # Status message
    $c->flash->{status_msg} = "merchant $id deleted.";

    # Set redirect to merchants list
    $c->response->redirect($c->uri_for($self->action_for('merchants_list')));
}

=head2 gifts

Base for all my gifts methods

=cut

sub gifts :Chained('base') :PathPart('gifts') :CaptureArgs(0) {
    my ($self, $c) = @_;

}

=head2 gifts_gift

Base for record specific methods
/admin/gifts/*/action

=cut

sub gifts_gift :Chained('gifts') :PathPart('') :CaptureArgs(1) {
    my ($self, $c, $id) = @_;

    # Store id in stash
    $c->stash->{id} = $id;

    $c->stash->{template} = '';
}

=head2 gift_create

Create gifts

=cut

sub gift_create :Chained('base') :PathPart('gifts/create') :Args(0) {
    my ($self, $c) = @_;

    # Set the TT template to use
    $c->stash->{template} = 'admin/gift_create.tt2';
}

=head2 gift_create_do

Add the submited gift to the database

=cut

sub gift_create_do :Chained('base') :PathPart('gifts/create_do') :Args(0) {
    my ($self, $c) = @_;

    # Retrieve the values from the form
    my $name                    = $c->request->params->{name};
    my $active                  = $c->request->params->{active};
    my $notes                   = $c->request->params->{notes};

    # Create gift
    my $gift = $c->model('ccdaDB::Gifts')->create({
        name            => $name,
        active          => $active,
        notes           => $notes,
    });

    # Status message
    $c->flash->{status_msg} = "gift $name created.";

    # Set redirect to gifts list
    $c->response->redirect($c->uri_for($self->action_for('gifts_list')));

}

=head2 gifts_list

Display all the gifts

=cut

sub gifts_list :Chained('gifts') :PathPart('list') :Args(0) {
    my ($self, $c) = @_;

    # Get all my giftsss
    $c->stash->{gifts} = [$c->model('ccdaDB::Gifts')->all];

    # Set the TT template to use
    $c->stash->{template} = 'admin/gifts_list.tt2';
}

=head2 gift_view

Display information for specific gift

=cut

sub gift_view :Chained('gifts_gift') :PathPart('view') :Args(0) {
    my ($self, $c) = @_;

    my $id = $c->stash->{id};

    # Get my record
    $c->stash->{gift} = $c->model('ccdaDB::Gifts')->find($id);

    # Set the TT template to use
    $c->stash->{template} = 'admin/gift_view.tt2';
}

=head2 gift_update_do

Update the gifts details

=cut

sub gift_update_do :Chained('gifts_gift') :PathPart('gift_update_do') :Args(0) {
    my ($self, $c) = @_;

    my $id = $c->stash->{id};

    # Update the template
    # Retrieve the values from the form
    my $name                    = $c->request->params->{name};
    my $active                  = $c->request->params->{active};
    my $notes                   = $c->request->params->{notes};

    # Update gift
    my $gift = $c->model('ccdaDB::Gifts')->find($id)->update({
        name            => $name,
        active          => $active,
        notes           => $notes,
    });

    # Status message
    $c->flash->{status_msg} = "gift $id updated.";

    # Set redirect to gifts list
    $c->response->redirect($c->uri_for($self->action_for('gifts_list')));
}

=head2 gift_delete_do

Delete specific gift

=cut

sub gift_delete_do :Chained('gifts_gift') :PathPart('delete') :Args(0) {
    my ($self, $c) = @_;

    my $id = $c->stash->{id};

    $c->stash->{gift} = [$c->model('ccdaDB::Gifts')->find($id)->delete];

    # Status message
    $c->flash->{status_msg} = "gift $id deleted.";

    # Set redirect to gifts list
    $c->response->redirect($c->uri_for($self->action_for('gifts_list')));
}


=head1 AUTHOR

root

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
