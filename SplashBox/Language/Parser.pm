#
# SplashBox::Language::Parser Parser.pm 
#
# Copyright (c) 2010-2011  The OpenSplash Team
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

package SplashBox::Language::Parser;

use strict;
use warnings;

use UUID;
use XML::Simple;
use SplashBox;
use SplashBox::Job::Trigger;

sub new {
	my ($this, %opts) = @_;
	my $class = ref($this) || $this;

	my $self = {};
	bless $self, $class;

	return $self;
}

sub fill_xml {
	my ($self, $raw_xml, $args) = @_;
	my %subsitution_array = split(/[;=]/, $args);

	foreach my $key (keys %subsitution_array){
		$subsitution_array{$key} =~ s/["']//g;
		#print "$key = ";
		#print "$subsitution_array{$key}\n";

		$raw_xml =~ s/{$key}/$subsitution_array{$key}/g;
	}
	return $raw_xml;
}

sub dispatcher {
	my ($self, $action, $raw, $next_run_date) = @_;
	open (FH, "< $DATA_PATH/action/$action.xml") or die $!;
	undef $/;
	my $raw_xml = <FH>;
	my ($uuid, $uuid_string);
	UUID::generate($uuid);
	UUID::unparse($uuid, $uuid_string);
	my $epoch_seconds = time();
	my $time_type = '';

	$raw_xml = $self->fill_xml ($raw_xml, "user='$ENV{USER}';raw='$raw';uuid='$uuid_string';create_date='$epoch_seconds';next_run_date='$next_run_date'");


	if ($next_run_date == 0)
	{
		$time_type = 'now';
	}
	else
	{
		$time_type = 'later';
	}
	open (FH_WRITE, "> $JOB_PATH/$time_type/$uuid_string.xml") or die $!;
	print FH_WRITE $raw_xml;

	SplashBox::show_log ("File: $JOB_PATH/$time_type/$uuid_string.xml is created!");
	close (FH_WRITE);
	close (FH);
}

sub _time_parser {
	my ($msg) = @_;
	my @list_time = <$DATA_PATH/time/*.xml>;
	my $each_time_file;
	my %time_tag;
	my $next_run_date = 0;
	my $base_period = 0;
	my $time_string;

	my $xml = new XML::Simple;

	foreach $each_time_file (@list_time) {
		$time_string = $each_time_file;
		$time_string =~ s#.*/##;
		$time_string =~ s#\.xml##;
		$time_string =~ s#_# #;

		if ("$msg" =~ /\b$time_string\b/i )
		{
			SplashBox::show_log ("Got time='$time_string'");
			my $xml_data = $xml->XMLin("$each_time_file");
			my $time_code = $xml_data->{"meta"}->{"time_code"};
			my $time_circle = $xml_data->{"meta"}->{"circle"};
			my $time_period = $xml_data->{"meta"}->{"time_period"};

			my ($time_num, $time_type) = $time_period =~ m#([0-9]+)([a-zA-Z]+)#;
			if ($time_type eq 'd')
			{
				$base_period = 60 * 60 * 24;
			}

			$next_run_date = time() + ($time_num * $base_period);
			$time_tag{'time_code'} = $time_code;
			$time_tag{'time_circle'} = $time_circle;
			$time_tag{'time_period'} = $time_period;

			# TODO parse time file here.
			last;
		}
	}

	return $next_run_date;
}

sub parser {
	my ($self, $msg) = @_;
	my $is_chat_message = 1;
	my @list_action = <$DATA_PATH/action/*.xml>;
	my $action;
	my $next_run_date = 0;


	foreach $action (@list_action) {
		$action =~ s#.*/##;
		$action =~ s#\.xml##;

		if ("$msg" =~ /\b$action\b/i )
		{
			SplashBox::show_log ("Got action='$action'");
			$next_run_date = _time_parser("$msg");

			$is_chat_message = 0;
			$self->dispatcher ($action, "$msg", $next_run_date);
			last;
		}
	}

	
	return $is_chat_message;
}


1;
