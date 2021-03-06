#!/usr/bin/perl

use strict;
use warnings;
use inc::Module::Install 0.65;

name 'LedgerSMB';
version '1.2.15';
license 'GPL';

perl_version '5.8.1';

requires 'Data::Dumper';
requires 'Locale::Maketext';
requires 'Locale::Maketext::Lexicon' => '0.56';
requires 'DBI' => '1.00';
requires 'MIME::Base64';
requires 'Digest::MD5';
requires 'HTML::Entities';
requires 'DBD::Pg';
requires 'Math::BigFloat';
requires 'IO::File';
requires 'Encode';
requires 'Locale::Country';
requires 'Locale::Language';
requires 'Time::Local';
requires 'Cwd';
requires 'Config::Std';
requires 'MIME::Lite';

build_requires 'Test::More';

feature 'POS module credit card processing support',
    -default => 0,
    'Net::TCLink' => 0;

feature 'Experimental scripting engine',
    -default => 0,
    'Parse::RecDescent' => 0;

feature 'Developer tool dependencies',
    -default => 0,
    'Getopt::Long' => 0,
    'FileHandle' => 0;

auto_install;
WriteAll;
