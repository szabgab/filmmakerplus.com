package PerlTV;
use Dancer ':syntax';

our $VERSION = '0.1';

use YAML qw(LoadFile);

get '/' => sub {
	my $channels = LoadFile '/home/gabor/channels.yml';
    template 'index', $channels;
};

true;
