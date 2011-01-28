#
# SplashBox SplashBox.pm
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
package SplashBox;

use strict;
use warnings;

our $VERSION = '0.0.2';

use Cwd 'abs_path';
use base qw(Exporter);
our @EXPORT = qw($ABS_PATH $JOB_PATH $BOT_PATH $DATA_PATH $ACTION_PATH $TEMPLATE_PATH $progname $SPLASHBOX_LIB);

our ($progname) = $0 =~ m#(?:.*/)?([^/]*)#;

# Change $IS_DEV to 1 for local development.
our $IS_DEV = 0;

our $SPLASHBOX_LIB = '/var/lib/splashbox';
our ($ABS_PATH) = abs_path($0) =~ m#(.*/).*#;
if ($IS_DEV == 1)
{
	$SPLASHBOX_LIB = "$ABS_PATH..";
}

our $JOB_PATH = '/tmp/splashbox';
our $BOT_PATH = $SPLASHBOX_LIB . '/action/';
our $DATA_PATH = $SPLASHBOX_LIB . '/data/';
our $ACTION_PATH = $DATA_PATH . 'action';
our $TEMPLATE_PATH = $DATA_PATH . 'templates';

sub show_log
{
	printf (STDERR "- %20s - %s\n", "[$progname]",  @_);
}

sub show_pathinfo
{
	printf (STDERR " JOB_PATH=$JOB_PATH\n" );
	printf (STDERR " BOT_PATH=$BOT_PATH\n" );
	printf (STDERR " DATA_PATH=$DATA_PATH\n" );
	printf (STDERR " ACTION_PATH=$ACTION_PATH\n" );
	printf (STDERR " TEMPLATE_PATH=$TEMPLATE_PATH\n" );
}

1;

