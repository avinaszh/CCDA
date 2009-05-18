use strict;
use warnings;
use Test::More tests => 3;

BEGIN { use_ok 'Catalyst::Test', 'ccda' }
BEGIN { use_ok 'ccda::Controller::Callcenters' }

ok( request('/callcenters')->is_success, 'Request should succeed' );


