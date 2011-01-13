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

sub check_job {
	open  LH, ">/tmp/opensplash-check-job.pid" or die "Can't open /tmp/opensplash-check-job.pid";
	flock LH, LOCK_EX|LOCK_NB or return;

	my @jobs = <$JOB_PATH/now/*.xml>;
	my $xml = new XML::Simple;
	foreach my $thisjob (@jobs) {
		my $data = $xml->XMLin("$thisjob");
#	       print Dumper($data);
		my $user = $data->{'data'}->{'user'};
		my $robot = $data->{'meta'}->{'robot'};
		my $raw = $data->{'data'}->{'raw'};

		# Call robot.
		printf STDERR ("%s runs '%s %s'\n", $user, $BOT_PATH . $robot, $raw);
		if ( -x "$BOT_PATH$robot" ) {
			system("$BOT_PATH$robot '$raw'");
			unlink $thisjob;
		}
		else
		{
			print STDERR "No robot $BOT_PATH$robot found.\n";
		}
	}
}

1;
