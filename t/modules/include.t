use strict;
use warnings FATAL => 'all';

use Apache::Test;
use Apache::TestRequest;

## mod_include tests
my ($doc, $actual, $expected);
my $dir = "/modules/include/";

## 1: <!--#echo var="DOCUMENT_NAME" -->
## 2: <!--#set var="message" value="set works"-->
## 3: <!--#include file="inc-two.shtml"-->
## 4: <!--#include virtual="/modules/include/inc-two.shtml"-->
## 5: <!--#include file="inc-one.shtml"--> (which in turn includes inc-two)
## 6: <!--#include virtual="/modules/include/inc-one.shtml"-->
## 7: <!--#include file="inc-three.shtml"--> (which in turn includes two more)
## 8: <!--#include virtual="/modules/include/inc-one.shtml"-->
## 9: <!--#foo virtual="/inc-two.shtml"-->
## 10: <!--#include file="/inc-two.shtml"-->
## 11: <!--#include virtual="/inc-two.shtml"-->
## 12-15: various tests for <!--#config errmsg="errmsg"-->
## 16-20: various if, if else, if elif, etc
## 21: big fat test

my %test = (
"echo.shtml"       =>    "echo.shtml",
"set.shtml"        =>    "set works",
"include1.shtml"   =>    "inc-two.shtml body  include.shtml body",
"include2.shtml"   =>    "inc-two.shtml body  include.shtml body",
"include3.shtml"   =>    "inc-two.shtml body  inc-one.shtml body  include.shtml body",
"include4.shtml"   =>    "inc-two.shtml body  inc-one.shtml body  include.shtml body",
"include5.shtml"   =>    "inc-two.shtml body  inc-one.shtml body  inc-three.shtml body  include.shtml body",
"include6.shtml"   =>    "inc-two.shtml body  inc-one.shtml body  inc-three.shtml body  include.shtml body",
"foo.shtml"        =>    "[an error occurred while processing this directive] foo.shtml body",
"foo1.shtml"       =>    "[an error occurred while processing this directive] foo.shtml body",
"foo2.shtml"       =>    "[an error occurred while processing this directive] foo.shtml body",
"encode.shtml"     =>    "\# \%\^ \%23\%20\%25\%5e",
"errmsg1.shtml"    =>    "errmsg",
"errmsg2.shtml"    =>    "errmsg",
"errmsg3.shtml"    =>    "errmsg",
"if1.shtml"        =>    "pass",
"if2.shtml"        =>    "pass   pass",
"if3.shtml"        =>    "pass   pass   pass",
"if4.shtml"        =>    "pass   pass",
"if5.shtml"        =>    "pass  pass  pass",
"big.shtml"        =>    "hello   pass  pass   pass     hello"
);

my $tests = keys %test;
plan tests => $tests + 1, test_module 'include';

my $bung = 0;
foreach (keys %test) {
    $doc = $_;
    $expected = $test{$_};
    $actual = GET_BODY "$dir$doc";

    ## super chomp - all leading and trailing \n
    $actual =~ s/^\n*//;
    $actual =~ s/\n*$//;
    ## and all the rest change to spaces
    $actual =~ s/\n/ /g;

    unless ($actual eq $expected) {
        $bung++;
        open (FOO, ">failed-include$bung");
        print FOO "$_\n";
        print FOO "expected:\n->$expected<-\n";
        print FOO "actual:\n->$actual<-\n";
        close(FOO);
    }
    ok ($actual eq $expected);
}

$doc = "printenv.shtml";
ok GET_OK "$dir$doc";
