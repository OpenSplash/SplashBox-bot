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
	my ($self, $raw_xml, %substitution_hash) = @_;

	foreach my $key (keys %substitution_hash){
		$substitution_hash{$key} =~ s/["']//g;

		$raw_xml =~ s/{$key}/$substitution_hash{$key}/g;
	}
	return $raw_xml;
}

sub dispatcher {
	my ($self, $action, $raw, $next_run_date, $is_cycle, $time_period) = @_;
	open (FH, "< $DATA_PATH/action/$action.xml") or die $!;
	undef $/;
	my $raw_xml = <FH>;
	my ($uuid, $uuid_string);
	UUID::generate($uuid);
	UUID::unparse($uuid, $uuid_string);
	my $create_date = time();
	my $time_type = '';

	my %substitution_hash = (
		'user' => "$ENV{USER}",
		'raw' => "$raw",
		'uuid' => "$uuid_string",
		'create_date' => "$create_date",
		'next_run_date' => "$next_run_date",
		'time_period' => "$time_period",
		'cycle' => "$is_cycle"
	);

	$raw_xml = $self->fill_xml ($raw_xml, %substitution_hash);


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
	my $next_run_date = 0;
	my $time_is_cycle = 0;
	my $time_period = 0;
	my $base_period = 0;
	my $time_string;

	my $xml = new XML::Simple;

	foreach $each_time_file (@list_time) {
		$time_string = $each_time_file;
		$time_string =~ s#.*/##;
		$time_string =~ s#\.xml##;
		$time_string =~ s#_# #g;

		if ("$msg" =~ /\b$time_string\b/i )
		{
			SplashBox::show_log ("Got time='$time_string'");
			my $xml_data = $xml->XMLin("$each_time_file");
			my $time_code = $xml_data->{"meta"}->{"time_code"};
			$time_is_cycle = $xml_data->{"meta"}->{"cycle"};
			$time_period = $xml_data->{"meta"}->{"time_period"};

			my ($time_num, $time_type) = $time_period =~ m#([0-9]+)([a-zA-Z]+)#;
			if ($time_type eq 'd') # day
			{
				$base_period = 60 * 60 * 24;
			}
			if ($time_type eq 'm') # munite
			{
				$base_period = 60;
			}
			if ($time_type eq 'w') # week
			{
				$base_period = 60 * 60 * 24 * 7;
			}

			$time_period = $base_period * $time_num; #FIXME
			$next_run_date = time() + $time_period;

			last;
		}
	}
	my $ret = [$next_run_date, $time_is_cycle, $time_period];
	return $ret;
}

sub parser {
	my ($self, $msg) = @_;
	my $is_chat_message = 1;
	my @list_action = <$DATA_PATH/action/*.xml>;
	my $action;
	my $next_run_date = 0;
	my $is_cycle = 0;
	my $time_period = 0;
	my $ret;


	foreach $action (@list_action) {
		$action =~ s#.*/##;
		$action =~ s#\.xml##;

		if ("$msg" =~ /\b$action\b/i )
		{
			SplashBox::show_log ("Got action='$action'");
			$ret = _time_parser("$msg");
			($next_run_date, $is_cycle, $time_period) = @$ret;

			$is_chat_message = 0;
			$self->dispatcher ($action, "$msg", $next_run_date, $is_cycle, $time_period);
			last;
		}
	}

	
	return $is_chat_message;
}


1;
