# Copyright 2020 SUSE LLC
# SPDX-License-Identifier: GPL-2.0-or-later
#
# Summary: Test "# semodule" command with options "-l / -d / -e" can work
# Maintainer: QE Security <none@suse.de>
# Tags: poo#63490, tc#1741286

use base 'opensusebasetest';
use strict;
use warnings;
use testapi;
use serial_terminal 'select_serial_terminal';
use utils;
use version_utils qw(is_sle_micro);

sub run {
    select_serial_terminal;

    my $tarball = "logs.tar.xz";
    assert_script_run("tar cJf $tarball /var/log/");
    upload_logs($tarball, timeout => 60);

}

1;
