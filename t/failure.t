use strict;
use Test::More;
use Test::Fatal;

use Email::Sender::Transport::Mailgun;

{
    no warnings 'redefine';
    *HTTP::Tiny::request = \&mock_request;
}

my @requests;

my $proto   = 'http';
my $host    = 'mailgun.example.com';
my $api_key = 'abcdef';
my $domain  = 'test.example.com';

my %envelope = (
    from => 'sender@test.example.com',
    to   => 'recipient@test.example.com',
);

my $message = <<END_MESSAGE;
From: $envelope{from}
To: $envelope{to}
Subject: this message is going nowhere fast

Dear Recipient,

  You will never receive this.

--
sender
END_MESSAGE

my $transport = Email::Sender::Transport::Mailgun->new(
    api_key  => $api_key,
    domain   => $domain,
    base_uri => "$proto://$host",
    campaign => 'testing',
    tracking_clicks => 'yes',
);

my $result;
isa_ok(exception { $result = $transport->send($message, \%envelope) },
    'Email::Sender::Failure', 'Mail sent ok');

done_testing;

sub mock_request {
    my ($self, $method, $uri, $data) = @_;
    return { success => 0, content => 'You failed' };
}
