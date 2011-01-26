#
# SplashBox::Job::Trigger Trigger.pm 
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

package SplashBox::Job::Trigger;

use strict;
use warnings;

use UUID;
use XML::Simple;
use Fcntl qw(:flock);

use SplashBox;


sub new {
	my ($this, %opts) = @_;
	my $class = ref($this) || $this;

	my $self = {};
	bless $self, $class;

	return $self;
}


sub _run {
	my ($this_job, $user, $robot, $raw) = @_;
	my $return_str = "";
	printf STDERR ("%s runs '%s %s'\n", $user, $BOT_PATH . $robot, $raw);
	if ( -x "$BOT_PATH$robot" ) {
		open COMMAND, "$BOT_PATH$robot '$raw' |";
		unlink $this_job;
	}
	else
	{
		print STDERR "No robot $BOT_PATH$robot found.\n";
	}

	while (<COMMAND>)
	{
		$return_str = $_;
	}
	close COMMAND;
	return $return_str;
}

sub check_job {
	my ($job_type) = @_;
	open  LH, ">/tmp/opensplash-check-job.pid" or die "Can't open /tmp/opensplash-check-job.pid";
	flock LH, LOCK_EX|LOCK_NB or return;

	my $return_str = '';
	my @jobs;
	if ($job_type eq "now")
	{
		@jobs = <$JOB_PATH/now/*.xml>;
	}
	if ($job_type eq "later")
	{
		@jobs = <$JOB_PATH/later/*.xml>;
	}
	if ($job_type eq "routine")
	{
		@jobs = <$JOB_PATH/routine/*.xml>;
	}

	my $xml = new XML::Simple;
	my $now_date = time();
	foreach my $this_job (@jobs) {
		my $data = $xml->XMLin("$this_job");
		my $user = $data->{'data'}->{'user'};
		my $robot = $data->{'meta'}->{'robot'};
		my $raw = $data->{'data'}->{'raw'};
		my $next_run_date = $data->{'data'}->{'next_run_date'};

		if ($job_type eq "now")
		{
			$return_str = _run($this_job, $user, $robot, $raw);
		}
		if ($job_type eq "later" && $now_date >= $next_run_date )
		{
			$return_str = _run($this_job, $user, $robot, $raw);
		}
		if ($job_type eq "routine" && $now_date >= $next_run_date)
		{
			$return_str = _run($this_job, $user, $robot, $raw);
			# send $raw to parser again.
		}
	}
	close LH;
	return $return_str;
}

1;
