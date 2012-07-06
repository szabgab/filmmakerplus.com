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
#my $videos = $yt->get_user_videos($config->{channel});
#print scalar @$videos;

#    etag
#    category
#    id
#    link
#    author
my @profile = qw(
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
    feed_links
    statistics
);

my %profile;
foreach my $p (@profile) {
	$profile{$p} = $profile->$p;
}
$config->{profile} = \%profile;


#foreach my $ch (sort keys %{$config->{channels}}) {
#	say "$ch: $config->{channels}{$ch}{title}";
#	foreach my $film (@{ $config->{channels}{$ch}{films} }) {
#		say "   $film";
#		my ($id) = $film->{url} =~ m{([^=]+$)};
#		say "   $id";
#		my $video = $yt->get_video_by_id($id);
#		$film->{$time}{view_count} = $video->view_count;
#		$film->{title} = $video->title;
#	}
#}

DumpFile($config_file, $config);

