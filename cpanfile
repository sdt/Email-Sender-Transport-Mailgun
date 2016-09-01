requires 'perl', '5.008001';

requires 'Email::Sender';
requires 'HTTP::Tiny';
requires 'HTTP::Tiny::Multipart';
requires 'IO::Socket::SSL';

on 'test' => sub {
    requires 'Test::Fatal';
    requires 'Test::More', '0.98';
};

