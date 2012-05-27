#!/usr/bin/env perl
use strict;
use warnings;
use v5.12;

use YAML qw(LoadFile DumpFile);
use Data::Dumper qw(Dumper);

use WebService::GData::YouTube;
my $yt = WebService::GData::YouTube->new();

my ($config_file, $data_file) = @ARGV;
die "Usage $0 channels.yml data.yml\n" if not $data_file;


my $config = LoadFile($config_file);
#print Dumper $config;

my $time = time;

foreach my $ch (sort keys %{$config->{channels}}) {
	say "$ch: $config->{channels}{$ch}{title}";
	foreach my $film (@{ $config->{channels}{$ch}{films} }) {
		say "   $film";
		my ($id) = $film->{url} =~ m{([^=]+$)};
		say "   $id";
		my $video = $yt->get_video_by_id($id);
		$film->{$time}{view_count} = $video->view_count;
	}
}

DumpFile($config_file, $config);

