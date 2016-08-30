package Email::Sender::Transport::Mailgun;
use Moo;
with 'Email::Sender::Transport';

use Furl qw( );
use HTTP::Request::Common;

our $VERSION = "0.01";

with 'Email::Sender::Transport';

has [qw( api_key domain )] => (
    is => 'ro',
    required => 1,
);

has uri => (
    is => 'lazy',
);

has ua => (
    is => 'lazy',
    builder => sub { Furl->new },
);

# https://documentation.mailgun.com/api-sending.html#sending
sub send_email {
    my ($self, $email, $env) = @_;

    my $to = ref $env->{to} ? join(',', @{ $env->{to} }) : $env->{to};

    # message parameter needs to be a multipart/form-data file
    my $message = [ undef, 'message.mime', Content => $email->as_string ];

    my $request = POST $self->uri . '/messages.mime',
        Content_Type => 'form-data',
        Content => { to => $to, message => $message };

    my $response = $self->ua->request($request);

    return $self->success if $response->is_success;
    Email::Sender::Failure->throw($response->message);
}

sub _build_uri {
    my $self = shift;

    return 'https://api:' . $self->api_key
         . '@api.mailgun.net/v3/' . $self->domain;
}

no Moo;
1;
__END__

=encoding utf-8

=head1 NAME

Email::Sender::Transport::Mailgun - Email::Sender using Mailgun

=head1 SYNOPSIS

    use Email::Sender::Simple qw( sendmail );
    use Email::Sender::Transport::Mailgun qw( );

    my $transport = Email::Sender::Transport::Mailgun->new(
        api_key => '...',
        domain  => '...',
    );

    my $message = ...;

    sendmail($message, { transport => $transport });

=head1 DESCRIPTION

This transport delivers mail via Mailgun's messages.mime API.

The headers described in L<https://documentation.mailgun.com/user_manual.html#sending-via-smtp> can be specified in the message headers.

=head1 ATTRIBUTES

=head2 api_key

Mailgun API key. See L<https://documentation.mailgun.com/api-intro.html#authentication>

=head2 domain

Mailgun domain. See L<https://documentation.mailgun.com/api-intro.html#base-url>

=head1 LICENSE

Copyright (C) Stephen Thirlwall.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

Stephen Thirlwall E<lt>sdt@cpan.orgE<gt>

=cut
