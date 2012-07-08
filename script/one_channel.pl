#!/usr/bin/env perl
use strict;
use warnings;
use v5.12;

use YAML qw(LoadFile DumpFile);
use Data::Dumper qw(Dumper);

use WebService::GData::YouTube;
my $yt = WebService::GData::YouTube->new();

my ($config_file) = @ARGV;
die "Usage $0 channels.yml\n" if not $config_file;


my $config = LoadFile($config_file);
#print Dumper $config;
#say $config->{channel};

my $time = time;

#my $videos = $yt->get_user_video_by_id($config->{channel});
#

my $profile = $yt->get_user_profile($config->{channel});
#say $profile;

#    etag
#    category
#    id
#    link
#    author
#    feed_links
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
    statistics
);

my %profile;
foreach my $p (@profile_fields) {
	$profile{$p} = $profile->$p;
}
$config->{profile} = \%profile;

my $videos = $yt->get_user_videos($config->{channel});
#print scalar @$videos;


my @video_fields = qw(
	title
	video_id
	description
	keywords
	etag
	view_count
	favorite_count
	thumbnails
	recorded
	duration
	uploaded
);

my @films;
$config->{number_of_videos} = scalar @$videos;
foreach my $v (@$videos) {
	#say "   $v";
	my %f;
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

