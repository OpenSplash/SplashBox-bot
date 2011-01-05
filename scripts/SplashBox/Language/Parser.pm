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
use SplashBox;

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
	my ($self, $action, $args) = @_;
        open (FH, "< $DATA_PATH/action/$action.xml") or die $!;
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
        $raw_xml = $self->fill_xml ($raw_xml, "user='$ENV{USER}';raw='$raw';uuid='$uuid_string';create_date='$epoch_seconds'");


        open (FH_WRITE, "> $JOB_PATH/now/$uuid_string.xml") or die $!;
        print FH_WRITE $raw_xml;
        SplashBox::show_log ("File: $JOB_PATH/now/$uuid_string.xml is created!");
        close (FH_WRITE);
        close (FH);
}

1;
