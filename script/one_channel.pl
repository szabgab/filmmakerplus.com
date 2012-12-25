#!/usr/bin/env perl
use strict;
use warnings;
use v5.12;

use YAML         qw(LoadFile DumpFile);
use Data::Dumper qw(Dumper);
use MIME::Lite   ();
use WebService::GData::YouTube ();

my $yt = WebService::GData::YouTube->new();

my $conf = LoadFile 'config.yml';
usage() if not @ARGV;
process_sites(@ARGV);
exit;
#############################

sub process_sites {
	my @sites = @_;

	foreach my $site (@sites) {
		process($site);
	}
}


sub process {
	my ($site) = @_;


	if (not $conf->{PerlTV}{$site}) {
		warn "Site '$site' is not available\n";
	}

	my $channel = $conf->{PerlTV}{$site}{channel};
	my $data_file = "data/$channel.yml";

	my $old_data;
	if (-e $data_file) {
		$old_data = LoadFile $data_file;
	}

	my $new_data;

	my $time = time;

	my $profile = $yt->get_user_profile($channel);

	my %profile = map { $_ => $profile->$_ } profile_fields();
	my $stat = $profile->statistics;
	my @stat_fields = qw(last_web_access view_count subscriber_count video_watch_count total_upload_views);
	$profile{statistics} = { map { $_ => $stat->$_ } @stat_fields };
	$new_data->{profile} = \%profile;

	my @videos = reverse sort {$a->view_count <=> $b->view_count} @{ $yt->get_user_videos($channel) };

	my @films;
	$new_data->{calculated}{number_of_videos} = scalar @videos;
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

		foreach my $field (video_fields()) {
			$f{$field} = $v->$field;
		}
		push @films, \%f;
		if (not defined $new_data->{latest} or $new_data->{latest}{uploaded} lt $f{uploaded}) {
			$new_data->{latest} = {%f};
		}
		# TODO most popular? selected list?
	}
	$new_data->{films} = \@films;

	my $playlists = $yt->get_user_playlists($channel);
	foreach my $pl (@$playlists) {
		my %d = (
			title       => $pl->title,
			playlist_id => $pl->playlist_id,
			keywords    => $pl->keywords,
			is_private  => $pl->is_private,
		);
		push @{ $new_data->{playlists} }, \%d;
		#say $pl->summary; # how to get the value?
	}

	DumpFile($data_file, $new_data);


	my $text = '';
	foreach my $f (qw(total_upload_views view_count)) {
		$old_data->{profile}{statistics}{$f} ||= 0;
		$new_data->{profile}{statistics}{$f} ||= 0;
		if ($old_data->{profile}{statistics}{$f} != $new_data->{profile}{statistics}{$f}) {
			$text .= "$f changed from $old_data->{profile}{statistics}{$f} to $new_data->{profile}{statistics}{$f}\n";
		}
	}
	if ($text) {
		$text = "Report for $site\n\n$text";
		my $mail = MIME::Lite->new(
			To      => 'Gabor Szabo <szabgab@gmail.com>',
			From    => 'Perl TV <perltv@szabgab.com>',
			Subject => "PerlTV for $site",
			Data    => $text,
		);
		$mail->send('smtp', 'localhost') or warn "Could not send mail for '$site' $!\n";
	}

	return;
}

sub usage {
	print "Usage: $0 site(s)\n";
	print "Available sites:\n\n";
	foreach my $k (keys %{ $conf->{PerlTV} }) {
		say "  $k";
	}
	exit;
}

sub profile_fields {
	return qw(
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
}

sub video_fields {
	return qw(
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
}



