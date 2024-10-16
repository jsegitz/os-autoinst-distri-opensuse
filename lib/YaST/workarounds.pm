# Copyright 2015-2022 SUSE LLC
# SPDX-License-Identifier: GPL-2.0-or-later

package YaST::workarounds;


use strict;
use warnings;
use Exporter 'import';
use testapi;
use utils;
use version_utils;
use Config::Tiny;

our @EXPORT = qw(
  apply_workaround_poo124652
  apply_workaround_bsc1206132
  workaround_poo124652_for_send_key_until
);

=head1 Workarounds for known issues

=head2 apply_workaround_poo124652 ($mustmatch, [,[$timeout] | timeout => $timeout] ):

Workaround for the screen refresh issue.

First checks if we need to apply the workaround, if the needle matches 
already no workaround is required.

If the workaround is needed we record a soft failure and apply a 'shift-f3' 
and 'esc' sequence that should fix the problem

If the problem still persists (we saw one occasion in the VRs) then we retry
with maximazing and shrinking the screen twice by sending 'alt-f10' two times. 

=cut

sub apply_workaround_poo124652 {
    my ($mustmatch) = shift;
    my $timeout;
    $timeout = shift if (@_ % 2);
    my %args = (timeout => $timeout // 0, @_);
    if (!check_screen($mustmatch, %args)) {
        record_info('poo#124652', 'poo#124652 - gtk glitch not showing dialog window decoration on openQA');
        send_key('shift-f3', wait_screen_change => 1);
        check_screen('style-sheet-selection-popup', 10);
        send_key('esc', wait_screen_change => 1);
        # in some verification tests this didn't work, so let's check
        if (!check_screen($mustmatch)) {
            record_info('Retry', "shift-f3 workaround did not solve the problem");
            send_key('alt-f10', wait_screen_change => 1);
            send_key('alt-f10', wait_screen_change => 1);
        }
    }
}

=head2 apply_workaround_bsc1206132 ():

Workaround for the iscsi return code issue.

Records a soft failure with a reference to bsc#1206132

Changes the iscsid service file to require and start after the iscsid socket.
Then reloads systemd, in order to scan for the changed unit.

=cut

sub apply_workaround_bsc1206132 {
    record_soft_failure('bsc#1206132 - iscsid Socket start failed after yast iscsi-client configuration, lead yast iscsi-client finish with error code');
    my $service_unit = '/usr/lib/systemd/system/iscsid.service';
    my $Config = Config::Tiny->new;
    $Config = Config::Tiny->read_string(script_output("cat $service_unit"));
    # change the two values in [Unit] section of the service file, as specified in bsc#1206132
    $Config->{Unit}->{Requires} = 'iscsid.socket';
    $Config->{Unit}->{After} = 'iscsid.socket';
    my $str = $Config->write_string();
    assert_script_run("echo \"$str\" > $service_unit");
    systemctl('daemon-reload');
}

=head2 workaround_poo124652_for_send_key_until ():

Workaround screen refresh issue for the send_key_until_needle_match

Records a soft failure with a reference to bsc#1206132

This is the wrapper for send_key_until_needle_match for applying
apply_workaround_bsc1206132.

=cut

sub workaround_poo124652_for_send_key_until {
    my ($tag, $key, $counter, $timeout) = @_;

    $counter //= 20;
    $timeout //= 1;

    my $real_timeout = 0;
    while (!check_screen($tag, $real_timeout)) {
        wait_screen_change {
            send_key $key;
        };
        if (--$counter <= 0) {
            apply_workaround_bsc1206132 $tag;
        }
        $real_timeout = $timeout;
    }
}

1;
