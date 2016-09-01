[![Build Status](https://travis-ci.org/sdt/Email-Sender-Transport-Mailgun.svg?branch=master)](https://travis-ci.org/sdt/Email-Sender-Transport-Mailgun)
# NAME

Email::Sender::Transport::Mailgun - Email::Sender using Mailgun

# SYNOPSIS

    use Email::Sender::Simple qw( sendmail );
    use Email::Sender::Transport::Mailgun qw( );

    my $transport = Email::Sender::Transport::Mailgun->new(
        api_key => '...',
        domain  => '...',
    );

    my $message = ...;

    sendmail($message, { transport => $transport });

# DESCRIPTION

This transport delivers mail via Mailgun's messages.mime API.

The headers described in [https://documentation.mailgun.com/user\_manual.html#sending-via-smtp](https://documentation.mailgun.com/user_manual.html#sending-via-smtp) can be specified in the message headers.

# ATTRIBUTES

## api\_key

Mailgun API key. See [https://documentation.mailgun.com/api-intro.html#authentication](https://documentation.mailgun.com/api-intro.html#authentication)

## domain

Mailgun domain. See [https://documentation.mailgun.com/api-intro.html#base-url](https://documentation.mailgun.com/api-intro.html#base-url)

## campaign deliverytime dkim tag testmode tracking tracking\_clicks tracking\_opens

These correspond to the `o:` options in the `messages.mime` section of [https://documentation.mailgun.com/api-sending.html#sending](https://documentation.mailgun.com/api-sending.html#sending)

# LICENSE

Copyright (C) Stephen Thirlwall.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

# AUTHOR

Stephen Thirlwall <sdt@cpan.org>
