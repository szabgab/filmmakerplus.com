package PerlTV;
use Dancer ':syntax';

our $VERSION = '0.1';

use YAML qw(LoadFile);

#get '/' => sub {
#	my $channels = LoadFile config->{appdir} . '/data/channels.yml';
#    template 'index', $channels;
#};


get '/' => sub {
	my $channels = LoadFile config->{appdir} . '/data/one_channel.yml';
    template 'one/index', $channels, { layout => 'one' };
};

get '/about' => sub {
	my $channels = {};
    template 'one/about', $channels, { layout => 'one' };
};


true;
