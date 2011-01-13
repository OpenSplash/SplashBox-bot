#
# SplashBox::DBus::Parser Parser.pm
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

package SplashBox::DBus::Parser;

use strict;
use warnings;
use SplashBox;
use SplashBox::Language::Parser;

use Net::DBus;
use Net::DBus::Exporter qw(org.opensplash.bot.language);

use base qw(Net::DBus::Object);

sub new {
	my $class = shift;
	my $service = shift;
	my $parser = SplashBox::Language::Parser->new();


	my $self = $class->SUPER::new($service, "/org/opensplash/bot/language/Parser");
	$self->{"parser"} = $parser;
	bless $self, $class;

	return $self;
}


dbus_method("say", ["string"], ["string"]);

sub say {
	my ($self, $args) = @_;
	my $is_chat_message = $self->{"parser"}->parser($args);
	my $return_msg = "";
	if ($is_chat_message)
	{
		my $chat = Net::DBus->session
			->get_service('org.opensplash.chatbot')
			->get_object('/org/opensplash/chatbot/Chat')
			;
		$return_msg = $chat->hello($args);

	}
	return $return_msg;
}
1;
