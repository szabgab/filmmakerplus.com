#!/usr/bin/env perl
use strict;
use warnings;
use v5.12;

use YAML qw(LoadFile DumpFile);
use Data::Dumper qw(Dumper);

use WebService::GData::YouTube;
my $yt = WebService::GData::YouTube->new();

my $conf = LoadFile 'config.yml';

my ($site) = @ARGV;
if (not $site) {
	print "Usage: $0 site\n";
	print "Available sites:\n\n";
	foreach my $k (keys %{ $conf->{PerlTV} }) {
		say "  $k";
	}
	exit;
}
if (not $conf->{PerlTV}{$site}) {
	die "Site '$site' is not available\n";
}

my $channel = $conf->{PerlTV}{$site}{channel};
my $config_file = "data/$channel.yml";
#die if not -e $config_file;


my $config;

my $time = time;

my $profile = $yt->get_user_profile($channel);

my @profile_fields = qw(
    updated
    published
    title

    about_me
    first_name
    last_name
    age
    username

    books
    gender
    company
    hobbies
    hometown
    location
    movies
    music
    relationship
    occupation
    school
    thumbnail
);

my %profile = map { $_ => $profile->$_ } @profile_fields;
my $stat = $profile->statistics;
my @stat_fields = qw(last_web_access view_count subscriber_count video_watch_count total_upload_views);
$profile{statistics} = { map { $_ => $stat->$_ } @stat_fields };
$config->{profile} = \%profile;

my @videos = reverse sort {$a->view_count <=> $b->view_count} @{ $yt->get_user_videos($channel) };

my @video_fields = qw(
	title
	video_id
	description
	keywords
	etag
	view_count
	favorite_count
	duration
	uploaded
	media_player
	aspect_ratio
	comments
	appcontrol_state
	denied_countries
	restriction
	uploaded
	genre
	location
);

my @films;
$config->{calculated}{number_of_videos} = scalar @videos;
foreach my $v (@videos) {
	my %f;
	#my $recorded = $v->recorded; # TODO  this is a WebService::GData::YouTube::YT::Recorded object

	my @thumbnail_fields = qw(url height width time);
	my $thumbnails = $v->thumbnails;
	foreach my $tn (@$thumbnails) {
		my %data = map { $_ => $tn->$_ } @thumbnail_fields;
		push @{ $f{thumbnails} }, \%data;
	}

    my @rating_fields = qw(num_likes num_dislikes);
	my $rating = $v->rating; # WebService::GData::YouTube::YT::Rating
	$f{rating} = { map { $_ => $rating->$_ } @rating_fields };

	# category TODO array of WebService::GData::Node::Media::Category

	#my $content = $v->content;
	#die Dumper $content;
	# TODO array of WebService::GData::YouTube::YT::Media::Content

	foreach my $field (@video_fields) {
		$f{$field} = $v->$field;
	}
	push @films, \%f;
	if (not defined $config->{latest} or $config->{latest}{uploaded} lt $f{uploaded}) {
		$config->{latest} = {%f};
	}
	# TODO most popular? selected list?
}
$config->{films} = \@films;

DumpFile($config_file, $config);

