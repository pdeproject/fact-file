#!/usr/bin/perl -w
 

# It is highly recommended that you use version 6 upwards of 
# the UserAgent module since it provides for tighter server 
# certificate validation 
###
 
#
 
# PayPal PDT (Payment Data Transfer) CGI
 
#
 
###
 
 
use strict;

use CGI qw(:all unescape);
 
use CGI::Carp qw(fatalsToBrowser);
 
 
# These modules are required to make the secure HTTP request to PayPal.
 
use LWP::UserAgent 6;
 
 
 
###
 
# CUSTOMIZE THIS: This is the seller's Payment Data Transfer authorization token.
 
# Replace this with the PDT token in "Website Payment Preferences" under your account.
 
###
 
 
my $auth_token = "VUDGCF2EA5huqlEqbSLPbg0JY3F-Pokyf-99r2sZWPR4x7GkWZEa-zIG49O";
 
 
sub done_text {
 
    return (p('Your transaction has been completed, and a receipt for your purchase has been
emailed to you. You may log into your account at <a
href="https://www.paypal.com/">www.paypal.com</a> to view details of this transaction.'),
end_html());
 
}
 
 
print header(), start_html("Thank you for your purchase!");
 
 
# Set up the secure request to the PayPal server to fetch the transaction info
 
my $paypal_server = "www.paypal.com";
 
 
my $transaction = param("tx");
 
 
if (not $transaction) {
 
    print (h2("The transaction ID was not found."), done_text());
 
 
    exit();
 
}
 
 
my $paypal_url = "https://$paypal_server/cgi-bin/webscr";
 
my $query = join("&", "cmd=_notify-synch", "tx=$transaction", "at=$auth_token");
 

 
my $user_agent = new LWP::UserAgent;
 
my $request = new HTTP::Request("POST", $paypal_url);
 
 
$request->content_type("application/x-www-form-urlencoded");
$request->header(Host => $paypal_server); 
$request->content($query);
 
# Make the request
 
 
my $result = $user_agent->request($request);
 
 
if ($result->is_error) {
 
    print(h1("An error was encountered"), br(), p("An error was encountered contacting the PayPal
server:"),
 
        $result->error_as_HTML, done_text());
 
    exit();
 
}
 
 
# Decode the response into individual lines and unescape any HTML escapes
 
my @response = split("\n", unescape($result->content));
 
 
# The status is always the first line of the response.
 
my $status = shift @response;
 
 
if ($status eq "SUCCESS") {
 
    # success
 
    my %transaction;
 
 
    foreach my $response_line (@response) {
 
      my ($key, $value) = split "=", $response_line;
 
      $transaction{$key} = $value;
 
    }
 
    # These are only some of the transaction details available; there are others.
 
    # You should print all the transaction details appropriate.
 
    print(h2("Here are the details of your purchase:"),
 
      ul(li("Customer Name: " . $transaction{'first_name'} . " " . $transaction{'last_name'}),
 
          li("Item: " . $transaction{'item_name'}),
 
          li("Amount: " . $transaction{'payment_gross'})));
 
 
} elsif ($status eq "FAIL") {
 
    print(h2("Unable to retrieve transaction details."));
 
    # failure
 
} else {
 
    # unknown error
 
    print(h2("Error retrieving transaction details."));
 
}
 
 
print done_text();
