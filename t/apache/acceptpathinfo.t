use strict;
use warnings FATAL => 'all';

use Apache::Test;
use Apache::TestRequest;
use Apache::TestUtil;

my $havecgi = have_cgi();

my $pathinfo = "/foo/bar";

##
##             mode       path,  filerc, filebody,     cgirc, cgibody
##
my %tests = (
             default => [ "",    "404","Not Found",    "200","_${pathinfo}_" ],
             on      => [ "/on", "200","_${pathinfo}_","200","_${pathinfo}_" ],
             off     => [ "/off","404","Not Found",    "404","Not Found"     ]
            );


my @files = ("", "/index.shtml");
push @files, "/test.sh" if ($havecgi);

my $numtests = ((scalar keys %tests) * (scalar @files) * 4);
plan tests => $numtests, sub { have_apache(2) && have_module('include') };

my $loc = "/apache/acceptpathinfo";

foreach my $mode (keys %tests) {
    foreach my $file (@files) {

        foreach my $pinf ("","$pathinfo") {

            my ($expectedrc, $expectedbody);
        
            if ($pinf eq "") {
                $expectedrc = "200";
                $expectedbody = "_\\(none\\)_";
            }
            else {
                if ($file eq "") {
                    $expectedrc = "404";
                    $expectedbody = "Not Found";
                }
                elsif ($file eq "/index.shtml") {
                    $expectedrc = $tests{$mode}[1];
                    $expectedbody = $tests{$mode}[2];
                }
                else {
                    $expectedrc = $tests{$mode}[3];
                    $expectedbody = $tests{$mode}[4];
                }
            }


            my $req = $loc.$tests{$mode}[0].$file.$pinf;

            my $actual = GET_RC "$req";
            ok t_cmp($expectedrc,
                     $actual,
                     "AcceptPathInfo $mode return code for $req"
                    );

            $actual = super_chomp(GET_BODY "$req");
            ok t_cmp(qr/$expectedbody/,
                     $actual,
                     "AcceptPathInfo $mode body for $req"
                    );
        }
    }
}

sub super_chomp {
    my ($body) = shift;

    ## super chomp - all leading and trailing \n (and \r for win32)
    $body =~ s/^[\n\r]*//;
    $body =~ s/[\n\r]*$//;
    ## and all the rest change to spaces
    $body =~ s/\n/ /g;
    $body =~ s/\r//g; #rip out all remaining \r's

    $body;
}
