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
is(exception { $result = $transport->send($message, \%envelope) },
    undef, 'Mail sent ok');

is(@requests, 1, 'HTTP request performed');
isa_ok($result, 'Email::Sender::Success', 'Return value');

my $req = shift @requests;
is($req->{method}, 'POST', 'POST method');
is($req->{uri}, "$proto://api:$api_key\@$host/$domain/messages.mime", 'URI ok');
like($req->{data}->{headers}->{'content-type'}, qr{^multipart/form-data},
        'Used multipart/form-data');

my $form = $req->{form};
is($form->{message}->{body}, $message, "Message in message.body");
ok($form->{message}->{header}->{filename}, "Message sent as file");
is($form->{to}->{body}, $envelope{to}, "Recipient in to:");
is($form->{'o:campaign'}->{body}, 'testing', "Got o:campaign");
is($form->{'o:tracking-clicks'}->{body}, 'yes', "Got o:tracking-clicks");


done_testing;


sub mock_request {
    my ($self, $method, $uri, $data) = @_;

    push(@requests, {
        method => $method,
        uri    => $uri,
        data   => $data,
        form   => parse_form($data->{content}),
    });

    return { success => 1 };
}

sub parse_form {
    my ($form) = @_;

    my ($boundary, $data) = split(/\r\n/, $form, 2);

    my %form;
    for my $chunk (split("\r\n$boundary", $data)) {
        next if ($chunk eq "--\r\n");
        my ($header, $body) = split(/\r\n\r\n/, $chunk, 2);

        my $section = { body => $body };

        while ($header =~ /\s(\S+)="(.*?)"/g) {
            $section->{header}->{$1} = $2;
        }

        $form{ $section->{header}->{name} } = $section;
    }

    return \%form;
}
