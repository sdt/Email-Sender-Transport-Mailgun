package Email::Sender::Transport::Mailgun;
our $VERSION = "0.01";

use Moo;
with 'Email::Sender::Transport';

use HTTP::Tiny              qw( );
use HTTP::Tiny::Multipart   qw( );
use JSON::MaybeXS           qw( );

{
  package
    Email::Sender::Success::MailgunSuccess;
  use Moo;
  extends 'Email::Sender::Success';
  has id => (
    is  => 'ro',
    required => 1,
  );
  no Moo;
}

has [qw( api_key domain )] => (
    is => 'ro',
    required => 1,
);

my @options = qw(
    campaign deliverytime dkim tag testmode
    tracking tracking_clicks tracking_opens
);

has [@options] => (
    is => 'ro',
    predicate => 1,
);

has base_uri => (
    is => 'lazy',
    builder => sub { 'https://api.mailgun.net/v3' },
);

has uri => (
    is => 'lazy',
);

has ua => (
    is => 'lazy',
    builder => sub { HTTP::Tiny->new(verify_SSL => 1) },
);

has json => (
    is => 'lazy',
    builder => sub { JSON::MaybeXS->new },
);

# https://documentation.mailgun.com/api-sending.html#sending
sub send_email {
    my ($self, $email, $env) = @_;

    my $content = {
        to => ref $env->{to} ? join(',', @{ $env->{to} }) : $env->{to},
        message => {
            filename => 'message.mime',
            content => $email->as_string,
        },
    };

    for my $option (@options) {
        my $has_option = "has_$option";
        if ($self->$has_option) {
            my $key = "o:$option";
            $key =~ tr/_/-/;
            $content->{$key} = $self->$option;
        }
    }

    my $uri = $self->uri . '/messages.mime';
    my $response = $self->ua->post_multipart($uri, $content);

    Email::Sender::Failure->throw($response->{content})
        unless $response->{success};

    return $self->success($response);
}

sub success {
    my ($self, $response) = @_;

    my $content = $self->json->decode($response->{content});
    return Email::Sender::Success::MailgunSuccess->new(id => $content->{id});
}

sub _build_uri {
    my $self = shift;

    my ($proto, $rest) = split('://', $self->base_uri);
    my $api_key = $self->api_key;
    my $domain = $self->domain;

    return "$proto://api:$api_key\@$rest/$domain";
}

no Moo;
1;
__END__

=encoding utf-8

=for stopwords deliverytime dkim testmode

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

=head2  campaign deliverytime dkim tag testmode tracking tracking_clicks tracking_opens

These correspond to the C<o:> options in the C<messages.mime> section of L<https://documentation.mailgun.com/api-sending.html#sending>

=head1 LICENSE

Copyright (C) Stephen Thirlwall.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

Stephen Thirlwall E<lt>sdt@cpan.orgE<gt>

=cut
