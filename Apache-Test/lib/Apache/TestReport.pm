package Apache::TestReport;

use strict;
use warnings FATAL => 'all';

use Apache::Test ();

use File::Spec::Functions qw(catfile);

# generate t/REPORT script (or a different filename) which will drive
# Apache::TestReport
sub generate_script {
    my ($class, $file) = @_;

    $file ||= catfile 't', 'REPORT';

    local $/;
    my $content = <DATA>;
    Apache::Test::config()->write_perlscript($file, $content);

}

1;
__DATA__

use strict;
use FindBin qw($Bin);
use lib "$Bin/../Apache-Test/lib";

use Apache::TestConfig ();

my $env = Apache::TestConfig::as_string();
{
    local $/ = undef;
    my $template = <DATA>;
    $template =~ s/\[CONFIG\]/$env/;
    print $template;
}

__DATA__


-------------8<----------Start Bug Report ------------8<----------
1. Problem Description:

  [DESCRIBE THE PROBLEM HERE]

2. Used Components and their Configuration:

[CONFIG]

3. This is the core dump trace: (if you get a core dump):

  [CORE TRACE COMES HERE]

-------------8<----------End Bug Report --------------8<----------

Note: Complete the rest of the details and post this bug report to
test-dev <at> httpd.apache.org. To subscribe to the list send an empty
email to test-dev-subscribe@httpd.apache.org.
