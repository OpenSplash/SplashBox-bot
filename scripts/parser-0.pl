#! /usr/bin/perl
#
# parser-0.pl
#
# Copyright (c) 2010 - The OpenSplash Team
# http://www.opensplash-project.org/
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

use strict;
use warnings;
use UUID;

my $DATA_PATH = '../data';
my $ACTION_PATH = '/tmp/splashbox/';
my $BOT_PATH = '../action';

my @list_action = <$DATA_PATH/action/*.xml>;
my $action;

my @list_time = <$DATA_PATH/time/*.xml>;
my $time;

sub show_log {
	printf (STDERR "- %20s - %s\n", "[$0]",  @_);
}

sub fill_xml {
	my $raw_xml = "$_[0]";
	my %subsitution_array = split(/[;=]/, $_[1]);

	foreach my $key (keys %subsitution_array){
		$subsitution_array{$key} =~ s/["']//g;
		#print "$key = ";
		#print "$subsitution_array{$key}\n";

		$raw_xml =~ s/{$key}/$subsitution_array{$key}/g;
	}
	return $raw_xml;

}

sub dispatcher {
	my $action = "$_[0]";
	my $args = "$_[1]";
	open (FH, "$DATA_PATH/action/$action.xml");
	undef $/;
	my $raw_xml = <FH>;
	my $raw = '';
	my ($uuid, $uuid_string);
	UUID::generate($uuid);
	UUID::unparse($uuid, $uuid_string);
	my $epoch_seconds = time();

	foreach my $data (@ARGV) {
		$raw = "$raw$data ";
	}
	$raw_xml = &fill_xml ($raw_xml, "user='$ENV{USER}';raw='$raw';uuid='$uuid_string';create_date='$epoch_seconds'");


	open (FH_WRITE, ">$ACTION_PATH/now/$uuid_string.xml");
	print FH_WRITE $raw_xml;
	show_log "File: $ACTION_PATH/now/$uuid_string.xml is created!";
	close (FH_WRITE);
	close (FH);
}

sub init {
	if ( ! -e "$ACTION_PATH" ) {
		system "mkdir -p $ACTION_PATH";
	}
	system "mkdir -p $ACTION_PATH/now";
	system "mkdir -p $ACTION_PATH/later";
	system "mkdir -p $ACTION_PATH/routine";
}


&init;

my $is_chat_message = 1;
foreach $action (@list_action) {
	$action =~ s#.*/##;
	$action =~ s#\.xml##;

	if ("@ARGV" =~ /\b$action\b/i )
	{
		show_log "Got action='$action'";
		$is_chat_message = 0;
		&dispatcher ($action, "@ARGV");
		last;
	}
}

foreach $time (@list_time) {
	$time =~ s#.*/##;
	$time =~ s#\.xml##;
	$time =~ s#_# #;

	if ("@ARGV" =~ /\b$time\b/i )
	{
		show_log "Got time='$time'";
		last;
	}
}

# Pass unknown messages to the chat bot.
if ( $is_chat_message eq 1 )
{
	system("$BOT_PATH/chat \"@ARGV\"");
}

