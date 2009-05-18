package ccda::Controller::Reports;

use strict;
use warnings;
use parent 'Catalyst::Controller';

=head1 NAME

ccda::Controller::Reports - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index

=cut

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;

    $c->response->body('Matched ccda::Controller::Reports in Reports.');
}

=head2 base

Can place common logic to start  chained dispatch here

=cut

sub base :Chained('/') :PathPart('reports') :CaptureArgs(0) {
    my ( $self, $c ) = @_;

    # Store the ResultSet in stash so it's available for other methods
    $c->stash->{resultset} = $c->model('ccdaDB::Deals');

    # Print a message to the debug log
    $c->log->debug('*** INSIDE BASE METHOD ***');
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

    # Find the callcenter object and store it in the stash
    $c->stash->{callcenter} = $c->stash->{rsCallcenters}->find($id);

    # Store id in stash
    $c->stash->{id} = $id;

    $c->stash->{template} = '';
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

List reports

=cut

sub list :Chained('base') :PathPart('list') :Args(0) {
    my ($self, $c) = @_;

    # Get all my deals
    $c->stash->{deals} = [$c->model('ccdaDB::Deals')->all];

    # Set the TT template to use
    $c->stash->{template} = 'reports/list.tt2';
}

=head2 deals_all

Display all reports

=cut

sub deals_all :Chained('base') :PathPart('deals_all') :Args(0) {
    my ($self, $c) = @_;
    my %search;

    # Permission to view data:
    # Managers can only see what their callcenters records
    # Agents can only see their own records
    foreach my $role ($c->user->roles) {
        if ($role eq "manager") {
            $search{callcenter_id} = $c->user->callcenter_id;
        } elsif ($role eq "agent") {
            $search{agent_id} = $c->user->id;
        } 
    }

    # Get all my deals
    $c->stash->{deals} = [
    $c->model('ccdaDB::Deals')->search(
        { %search },
        {
            join => 'user',
            join => 'status'
        }


    )
    
    ];

    #$c->stash->{deals} = [$c->model('ccdaDB::Deals')->all];

    # Set the TT template to use
    $c->stash->{template} = 'reports/deals_all.tt2';
}

=head2 negotiations

Display negotiations reports

=cut

sub negotiations :Chained('base') :PathPart('negotiations') :Args(0) {
    my ($self, $c) = @_;

    # Define resultsources
    # my $rsRoles = $c->model('ccdaDB::Roles');

    my $manager = $c->model('ccdaDB::Roles')->search({ role => 'manager' });
    $c->stash->{managers} = [$c->model('ccdaDB::Users')->search(
        { active => '1', role_id => $manager->id },
        { join  => 'map_user_role' }
    )];

    my $agent = $c->model('ccdaDB::Roles')->search({ role => 'agent' });
    $c->stash->{agents} = [$c->model('ccdaDB::Users')->search(
        { active => '1', role_id => $agent->id },
        { join  => 'map_user_role' }
    )];

    $c->stash->{states} = [$c->model('ccdaDB::States')->all()];

    $c->stash->{status} = [$c->model('ccdaDB::Status')->all()];

    $c->stash->{shipping_status} = [$c->model('ccdaDB::Status')->all()];

    # Set the TT template to use
    $c->stash->{template} = 'reports/negotiations.tt2';
}

=head2 negotiations_do

Display negotiations reports

=cut

sub negotiations_do :Chained('base') :PathPart('negotiations_do') :Args(0) {
    my ($self, $c) = @_;
    
    my $manager             = $c->request->params->{manager}; 
    my $agent               = $c->request->params->{agent}; 
    my $first_name          = $c->request->params->{first_name}; 
    my $last_name           = $c->request->params->{last_name}; 
    my $purchase_date_from  = $c->request->params->{purchase_date_from}; 
    my $purchase_date_to    = $c->request->params->{purchase_date_to}; 
    my $state               = $c->request->params->{state}; 
    my $city                = $c->request->params->{city}; 
    my $zip_code            = $c->request->params->{zip_code}; 
    my $status              = $c->request->params->{status}; 
    my $shipping_status     = $c->request->params->{shipping_status}; 

    my %hash;
    $hash{agent_name}           = $agent if ($agent ne "NULL");    
    $hash{first_name}           = $state if ($first_name);
    $hash{last_name}            = $state if ($last_name);
    $hash{purchase_date_from}   = $purchase_date_from if ($purchase_date_from);
    $hash{purchase_date_to}     = $purchase_date_to if ($purchase_date_to);
    $hash{state}                = $state if ($state ne "NULL");
    $hash{city}                 = $city if ($city);
    $hash{zip_code}             = $zip_code if ($zip_code);
    $hash{status}               = $status if ($status ne "NULL");
    $hash{shipping_status}      = $shipping_status if ($shipping_status ne "NULL");


    # Get records based on my search
    $c->stash->{deals} = [$c->model('ccdaDB::Deals')->search(
    { 
        %hash
    }
    )];    

    # Get my total amount charged
    my $rs3 = $c->model('ccdaDB::Deals')->search(
    {
        %hash
    },
    {
        select  => [ { sum => 'charged_amount'  }  ],
        as      => [ 'total_charged_amount' ],
    }
    );
    my $tca = $rs3->first->get_column('total_charged_amount');
    $c->stash->{total_charged_amount} = $tca;
    
    # Set the TT template to use
    $c->stash->{template} = 'reports/negotiations_do.tt2';
}

=head2 daily_report

Display daily_report reports

=cut

sub daily_report :Chained('base') :PathPart('daily_report') :Args(0) {
    my ($self, $c) = @_;


    # Set the TT template to use
    $c->stash->{template} = 'reports/daily_report.tt2';
}

=head2 daily_report_do

Display daily_report reports

=cut

sub daily_report_do :Chained('base') :PathPart('daily_report_do') :Args(0) {
    my ($self, $c) = @_;

    my $purchase_date_from      = $c->request->params->{purchase_date_from};
    my $purchase_date_to        = $c->request->params->{purchase_date_to};

    my %hash;
    $hash{purchase_date_from}   = $purchase_date_from if ($purchase_date_from);
    $hash{purchase_date_to}     = $purchase_date_to if ($purchase_date_to);


    # Get records based on my search
    $c->stash->{deals} = [$c->model('ccdaDB::Deals')->search(
    {
        %hash
    }
    )];

    # Get my total amount charged
    my $rs3 = $c->model('ccdaDB::Deals')->search(
    {
        %hash
    },
    {
        select  => [ { sum => 'charged_amount'  }  ],
        as      => [ 'total_charged_amount' ],
    }
    );
    my $tca = $rs3->first->get_column('total_charged_amount');
    $c->stash->{total_charged_amount} = $tca;

    # Set the TT template to use
    $c->stash->{template} = 'reports/daily_report_do.tt2';
}

=head2 transactions

Display transactions reports

=cut

sub transactions :Chained('base') :PathPart('transactions') :Args(0) {
    my ($self, $c) = @_;

    if ($c->check_user_roles('admin')) {

        # Get my callcenters
        $c->stash->{callcenters} = [$c->model('ccdaDB::Callcenters')->search(
            { active => '1'}
        )];
        
        $c->log->debug("$c->user->roles");

        # Set the TT template to use
        $c->stash->{template} = 'reports/transactions_callcenters.tt2';

    } elsif ($c->check_user_roles('manager')) {
    
        # Get my callcenters
        $c->stash->{callcenters} = [$c->model('ccdaDB::Callcenters')->search(
            { active => '1', id => $c->user->callcenter_id }
        )];

        # Set the TT template to use
        $c->stash->{template} = 'reports/transactions_callcenters.tt2';

    } else {

    }
}

=head2 transactions_do

Display transactions reports

=cut

sub transactions_do :Chained('callcenters_callcenter') :PathPart('transactions_do') :Args(0) {
    my ($self, $c) = @_;

    my $id = $c->stash->{id};

    my %hash;
    $hash{callcenter_id} = $id;

    # Setup for all Deals
    # Get records based on my search
    $c->stash->{transactions} = [$c->model('ccdaDB::Deals')->search(
        { %hash }
    )];

    # Get my total amount charged
    my $rs3 = $c->model('ccdaDB::Deals')->search(
        { %hash },
        {   
            select  => [ { sum => 'charged_amount'  }  ],
            as      => [ 'total_charged_amount' ],
        }
    );

    my $tca = $rs3->first->get_column('total_charged_amount');
    $c->stash->{total_charged_amount} = $tca;

    $hash{status} = '2';
    # Get my total amount charged
    my $rs4 = $c->model('ccdaDB::Deals')->search(
        { %hash },
        {
            select  => [ { sum => 'charged_amount'  }  ],
            as      => [ 'total_charged_amount' ],
        }
    );

    my $tcca = $rs4->first->get_column('total_charged_amount');
    $c->stash->{total_credit_charged_amount} = $tcca;


    # Setup fields for Credited Deals
    # Add hash status '2' = CREDIT to my search 
    $hash{status} = '2';

    # Get records based on my search
    $c->stash->{transactions_cancelled} = [$c->model('ccdaDB::Deals')->search(
        { %hash }
    )];

    # Get my total amount charged
    my $rs4 = $c->model('ccdaDB::Deals')->search(
        { %hash },
        {
            select  => [ { sum => 'charged_amount'  }  ],
            as      => [ 'total_charged_amount' ],
        }
    );

    my $tcca = $rs4->first->get_column('total_charged_amount');
    $c->stash->{total_credit_charged_amount} = $tcca;


    # Get my percentage
    my $callcenter = $c->model('ccdaDB::Callcenters')->find($id);
    
    # Get my percentage
    my $percentage = $callcenter->percentage;

    # Set the TT template to use
    $c->stash->{template} = 'reports/transactions.tt2';
}


=head1 AUTHOR

root

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
