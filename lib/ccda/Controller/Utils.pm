package ccda::Controller::Utils;

use strict;
use warnings;
use parent 'Catalyst::Controller';
use Digest::MD5 qw(md5_hex);

=head1 NAME

ccda::Controller::Utils - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index

=cut

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;

    $c->response->body('Matched ccda::Controller::Utils in Utils.');
}

sub test : Local {
    my ($self, $c) = @_;
    my $what;
    my $by;

    $what = ['id','name'];
    $by->{alias} = 'CGonzalez';

    my $id = $self->get_callcenter_info($c,$what,\{ 'alias' => 'CGonzales' });
    
    print $id->name;
}

sub create_md5 {
    my ($self, $c, $md5_hash) = @_;
    my $md5;
    my $md5_data;
    my $ctx;

    $ctx         = Digest::MD5->new;
    $md5_data    = $md5_hash->{purchase_date};
    $md5_data   .= $md5_hash->{last_name}. ", ";
    $md5_data   .= $md5_hash->{first_name};
    $md5_data   .= $md5_hash->{charged_amount};

    $ctx->add($md5_data);

    $md5        = $ctx->hexdigest;

return $md5;
}

sub full_name {
    my ($self, $c, $format, $str) = @_;
    my @name;
    my %name;

    if ($format eq "last_first") {
        my @name = split(/,/, $str);

        # Removing leading spaces
        $name[0] = leading_spaces($name[0]);
        $name[1] = leading_spaces($name[1]);

        # Remove trailing spaces
        $name[0] = trailing_spaces($name[0]);
        $name[1] = trailing_spaces($name[1]);

        $name{first_name} = $name[1];
        $name{last_name}  = $name[0];
    }

return \%name;
}

sub leading_spaces{
    my $string = shift;

    $string =~ s/^\s+//;

return $string;
}

sub trailing_spaces {
    my $string = shift;

    $string =~ s/\s+$//;

return $string;
}

sub date_format  {
    # TODO: accept multiple formats
    my ($self, $c, $format, $var) = @_; 
    my @split_date;
    my $date;
    my $year;
    my $month;
    my $day;
    my $ret;

    # Replace / with -
    $var =~ s/\//-/g;

    if ($format eq "mdY_to_Ymd") {
        # From month-day-year date create the SQL date format
        @split_date = split(/-/, $var);
        $year = $split_date[2];

        if (length($split_date[0]) < 2) {
            $month = "0".$split_date[0]
        } else {
            $month = $split_date[0]
        }

        if (length($split_date[1]) < 2) {
            $day = "0".$split_date[1]
        } else {
            $day = $split_date[1]
        }

        $date = "$year-$month-$day";
        #print "FIX: $date\n";

    } elsif ($format eq "Ymd_to_mdY") {

        # From SQL date create the month-day-year date format
        @split_date = split(/-/, $var);
        $date = "$split_date[1]-$split_date[2]-$split_date[0]";
        
    }

    $ret = $date;

return $ret;
}

=head2 get_payment_info

This helper will retrieve any information regarding a payment based on the "by" arguement provided

usage: get_callcenter_info($c,\@what, \%by)

=cut

sub get_payment_info {
    my ($self, $c, $what, $by) = @_;
    my $rs;
    my $ret;

    $rs = $c->model('ccdaDB::Payments')->search(
        { %$by },
        { columns => [ @$what ] }
    )->first;

    $ret = $rs;

return $ret;
}


=head2 get_callcenter_info

This helper will retrieve any information regarding a callcenter based on the "by" arguement provided

usage: get_callcenter_info($c,\@what, \%by)

=cut

sub get_callcenter_info {
    my ($self, $c, $what, $by) = @_;
    my $ret;
    
    $ret = $c->model('ccdaDB::Callcenters')->search(
        { %$by },
        { columns => [ @$what ] }
    )->first;
    
return $ret;
}

=head2 get_status_info

This helper will retrieve any information regarding a status based on the "by" arguement provided

usage: get_status_info($c,\@what, \%by)

=cut

sub get_status_info {
    my ($self, $c, $what, $by) = @_;
    my $rs;
    my $ret;

    $rs = $c->model('ccdaDB::Status')->search(
        { %$by },
        { columns => [ @$what ] }
    )->first;

    $ret = $rs;

return $ret;
}

=head2 get_transaction_status_info

This helper will retrieve any information regarding a status based on the "by" arguement provided

usage: get_transaction_status_info($c,\@what, \%by)

=cut

sub get_transaction_status_info {
    my ($self, $c, $what, $by) = @_;
    my $rs;
    my $ret;

    $rs = $c->model('ccdaDB::TransactionStatus')->search(
        { %$by },
        { columns => [ @$what ] }
    )->first;

    $ret = $rs;

return $ret;
}


=head1 AUTHOR

,,,

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
