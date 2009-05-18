use strict;
use warnings;
use Test::More tests => 3;

BEGIN { use_ok 'Catalyst::Test', 'ccda' }
BEGIN { use_ok 'ccda::Controller::Logout' }

ok( request('/logout')->is_success, 'Request should succeed' );


