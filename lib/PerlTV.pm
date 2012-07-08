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
	$channels->{current} = $channels->{latest};
	$channels->{page_title} = $channels->{profile}{title} || $channels->{channel};
    template 'one/index', $channels, { layout => 'one' };
};

get '/v/:id' => sub {
	my $channels = vars->{channels};
	($channels->{current}) =  grep { $_->{video_id} eq param('id') } @{ $channels->{films} };
	$channels->{page_title} = $channels->{current}{title};
    template 'one/index', $channels, { layout => 'one' };
};

get '/about' => sub {
	my $channels = vars->{channels};
	$channels->{page_title} = "About $channels->{channel}";
    template 'one/about', $channels, { layout => 'one' };
};

get '/all' => sub {
	my $c = vars->{channels};
	$c->{page_title} = "All the films of $c->{channel}";
    template 'one/all', $c, { layout => 'one' };
};

true;
