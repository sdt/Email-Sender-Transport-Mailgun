requires 'perl', '5.008001';

requires 'Email::Sender';
requires 'Furl';
requires 'HTTP::Request::Common';
requires 'IO::Socket::SSL';

on 'test' => sub {
    requires 'Test::More', '0.98';
};

