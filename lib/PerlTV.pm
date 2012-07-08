package PerlTV;
use Dancer ':syntax';

our $VERSION = '0.1';

use YAML qw(LoadFile);

#get '/' => sub {
#	my $channels = LoadFile config->{appdir} . '/data/channels.yml';
#    template 'index', $channels;
#};


hook before => sub {
	var channels => LoadFile config->{appdir} . '/data/one_channel.yml';
};


get '/' => sub {
	my $channels = vars->{channels};
    template 'one/index', $channels, { layout => 'one' };
};

get '/about' => sub {
	my $channels = vars->{channels};
    template 'one/about', $channels, { layout => 'one' };
};

get '/all' => sub {
    template 'one/all', vars->{channels}, { layout => 'one' };
};

true;
