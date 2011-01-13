#
# SplashBox::DBus::Trigger Trigger.pm
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

package SplashBox::DBus::Trigger;

use strict;
use warnings;
use SplashBox::Job::Trigger;

use Net::DBus::Exporter qw(org.opensplash.bot.job);

use base qw(Net::DBus::Object);

sub new {
	my $class = shift;
	my $service = shift;

	my $self = $class->SUPER::new($service, "/org/opensplash/bot/job/Trigger");
	bless $self, $class;

	return $self;
}


dbus_method("check_job", [], []);

sub check_job {
	my $self = shift;
	my $name = shift;
	SplashBox::Job::Trigger::check_job();
}
1;
