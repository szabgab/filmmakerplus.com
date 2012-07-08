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
);

my %profile;
foreach my $p (@profile_fields) {
	$profile{$p} = $profile->$p;
}
my $stat = $profile->statistics;
my @stat_fields = qw(last_web_access view_count subscriber_count video_watch_count total_upload_views);
$profile{statistics} = { map { $_ => $stat->$_ } @stat_fields };
$config->{profile} = \%profile;

my $videos = $yt->get_user_videos($config->{channel});


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
);

my @films;
$config->{number_of_videos} = scalar @$videos;
foreach my $v (@$videos) {
#say $v;
	my %f;
	foreach my $field (@video_fields) {
		my $recorded = $v->recorded;
		my $thumbnails = $v->thumbnails;
		$f{$field} = $v->$field;
		#say "$field : $f{$field}";
	}
	#if ($f{thumbnails}) {
		#for my $i (0 .. @{ $f{thumbnails} } - 1) {
			#say "$i : $f{thumbnails}[$i]";
			#delete $f{thumbnails}[$i];
			#$f{thumbnails}[$i] = 23;
			#{
			#	url    => $f{thumbnails}[$i]->url,
			#	height => $f{thumbnails}[$i]->height,
			#	width  => $f{thumbnails}[$i]->width,
			#	time   => $f{thumbnails}[$i]->time,
			#};
	#		say "a: $f{thumbnails}[$i]";
	#	}
	#}
	push @films, \%f;
	if (not defined $config->{latest} or $config->{latest}{uploaded} lt $f{uploaded}) {
		$config->{latest} = {%f};
	}
	# TODO most popular? selected list?
}
$config->{films} = \@films;

DumpFile($config_file, $config);

