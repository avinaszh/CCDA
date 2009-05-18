use strict;
use warnings;
use Test::More tests => 3;

BEGIN { use_ok 'Catalyst::Test', 'ccda' }
BEGIN { use_ok 'ccda::Controller::Manage' }

ok( request('/manage')->is_success, 'Request should succeed' );


