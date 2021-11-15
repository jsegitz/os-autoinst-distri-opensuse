# SUSE's openQA tests
#
# Copyright 2021 SUSE LLC
# SPDX-License-Identifier: FSFAP

# Summary: The class introduces all accessing methods for Boot code options tab in bootloader module
# Maintainer: QE YaST <qa-sle-yast@suse.de>

package YaST::Bootloader::BootCodeOptionsPage;
use parent 'Installation::Navigation::NavigationBase';
use strict;
use warnings;

sub init {
    my ($self) = @_;
    $self->SUPER::init();
    $self->{cmb_bootloader} = $self->{app}->combobox({id => "\"Bootloader::LoaderTypeWidget\""});
    $self->{cb_write_to_partition} = $self->{app}->checkbox({id => 'boot'});
    $self->{cb_bootdev} = $self->{app}->checkbox({id => 'mbr'});
    $self->{cb_custom_boot} = $self->{app}->checkbox({id => 'custom'});
    $self->{cmb_mbr_flag} = $self->{app}->combobox({id => '"Bootloader::PMBRWidget"'});
    $self->{cb_trusted_boot} = $self->{app}->checkbox({id => '"Bootloader::TrustedBootWidget"'});
    $self->{cb_generic_to_mbr} = $self->{app}->checkbox({id => '"Bootloader::GenericMBRWidget"'});
    $self->{cb_set_active_flag} = $self->{app}->checkbox({id => '"Bootloader::ActivateWidget"'});
    $self->{tb_boot_loader_settings} = $self->{app}->tab({id => '"CWM::DumbTabPager"'});
    $self->{btn_ok} = $self->{app}->button({id => 'next'});
    $self->{btn_cancel} = $self->{app}->button({id => 'abort'});
    return $self;
}

sub is_shown {
    my ($self) = @_;
    return $self->{cmb_bootloader}->exist();
}

sub get_bootloader_type {
    my ($self) = @_;
    return $self->{cmb_bootloader}->value();
}

sub get_write_to_mbr {
    my ($self) = @_;
    return $self->{cb_bootdev}->is_checked();
}

sub get_write_to_custom {
    my ($self) = @_;
    return $self->{cb_custom_boot}->is_checked();
}

sub get_trusted_boot_support {
    my ($self) = @_;
    return $self->{cb_custom_boot}->is_checked();
}

sub get_write_to_partition {
    my ($self) = @_;
    return $self->{cb_write_to_partition}->is_checked();
}

sub get_protective_mbr_flag {
    my ($self) = @_;
    return $self->{cmb_mbr_flag}->value();
}

sub get_set_active_flag {
    my ($self) = @_;
    return $self->{cb_set_active_flag}->is_checked();
}

sub get_write_generic_to_mbr {
    my ($self) = @_;
    return $self->{cb_generic_to_mbr}->is_checked();
}

sub check_write_to_partition {
    my ($self) = @_;
    $self->{cb_write_to_partition}->check();
}

sub check_write_generic_to_mbr {
    my ($self) = @_;
    $self->{cb_generic_to_mbr}->check();
}

sub uncheck_write_to_mbr {
    my ($self) = @_;
    $self->{cb_bootdev}->uncheck();
}

sub switch_tab_bootloader_options {
    my ($self) = @_;
    $self->{tb_boot_loader_settings}->select("Boot&loader Options");
}

1;
