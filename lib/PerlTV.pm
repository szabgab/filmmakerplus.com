package PerlTV;
use Dancer ':syntax';

our $VERSION = '0.1';

use YAML qw(LoadFile);

get '/' => sub {
	my $channels = LoadFile config->{appdir} . '/data/channels.yml';
    template 'index', $channels;
};

true;
