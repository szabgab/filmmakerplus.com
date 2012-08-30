package PerlTV;
use Dancer ':syntax';

our $VERSION = '0.1';

use YAML qw(LoadFile);
use Data::Dumper qw(Dumper);

#get '/' => sub {
#	my $channels = LoadFile config->{appdir} . '/data/channels.yml';
#    template 'index', $channels;
#};


hook before => sub {
	my $host = $ENV{PERLTV} || request->host;
	# TODO: check if any of these values are missing!
	my $conf = config->{PerlTV}{$host};
	my $channel = $conf->{channel};

	var channel  => $channel;
	var myconfig => $conf;
	var channels => LoadFile config->{appdir} . "/data/$channel.yml";

	return;
};

hook before_template => sub {
	my $tokens = shift;
	$tokens->{channel} = vars->{channel};
	$tokens->{page_title} ||= vars->{channel};
	$tokens->{brand} = vars->{channels}{profile}{title} || vars->{channel};
	$tokens->{adwords} = vars->{myconfig}{adwords};
	$tokens->{clicky}  = vars->{myconfig}{clicky};
	$tokens->{show_thumbnails} = 1 unless request->uri =~ m{/videos};
	$tokens->{host} = $ENV{PERLTV} || request->host;
	#for my $f (@{ $tokens->{films} }) {
	#	next if not defined $f->{description};
	#	#$f->{description} =~ s{(http://\S+)}{<a href="$1">$1</a>}g;
	#}
	$tokens->{current}{description} =~ s{(http://\S+)}{<a href="$1">$1</a>}g;
};


get '/' => sub {
	my $channels = vars->{channels};
	$channels->{current} = $channels->{latest};
	$channels->{page_title} = vars->{channels}{profile}{title} || vars->{channel};
    template 'one/index', $channels, { layout => 'one' };
};

get '/v/:id' => sub {
	my $channels = vars->{channels};
	($channels->{current}) =  grep { $_->{video_id} eq param('id') } @{ $channels->{films} };
	$channels->{page_title} = $channels->{current}{title};
    template 'one/v', $channels, { layout => 'one' };
};

get '/playlists' => sub {
	my $channels = vars->{channels};
	$channels->{page_title} = "Playlists of " . vars->{channel};
    template 'one/playlists', $channels, { layout => 'one' };
};
get '/about' => sub {
	my $channels = vars->{channels};
	$channels->{page_title} = "About " . vars->{channel};
    template 'one/about', $channels, { layout => 'one' };
};

get '/videos' => sub {
	my $c = vars->{channels};
	$c->{page_title} = "All the films of " . vars->{channel};
    template 'one/all', $c, { layout => 'one' };
};

true;

