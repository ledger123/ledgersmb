#=====================================================================
# LedgerSMB
# Small Medium Business Accounting software
# http://www.ledgersmb.org/
#
# Copyright (C) 2006
# This work contains copyrighted information from a number of sources all used
# with permission.
#
# This file contains source code included with or based on SQL-Ledger which
# is Copyright Dieter Simader and DWS Systems Inc. 2000-2005 and licensed
# under the GNU General Public License version 2 or, at your option, any later
# version.  For a full list including contact information of contributors,
# maintainers, and copyright holders, see the CONTRIBUTORS file.
#
# Original Copyright Notice from SQL-Ledger 2.6.17 (before the fork):
# Copyright (C) 2002
#
#  Author: DWS Systems Inc.
#     Web: http://www.sql-ledger.org
#
#  Contributors:
#
# Original Author and copyright holder:
# Dieter Simader dsmimader@sql-ledger.com
#======================================================================
#
# This file has undergone whitespace cleanup.
#
#======================================================================
#
# mailer package
#
#======================================================================

package Mailer;

use Encode;
use MIME::Lite;
use MIME::Base64;
use LedgerSMB::Sysconfig;

sub new {
    my ($type) = @_;
    my $self = {};

    bless $self, $type;
}

sub send {
    my ($self) = @_;

    my $domain = $self->{from};
    my $boundary = time;
    $boundary = "LSMB-$boundary";
    $domain =~ s/(.*?\@|>)//g;
    my $msg_id = "<$boundary\@$domain>";

    $self->{contenttype} = "text/plain" unless $self->{contenttype};

    for (qw(from to cc bcc)) {
        $self->{$_} =~ s/\&lt;/</g;
        $self->{$_} =~ s/\&gt;/>/g;
        $self->{$_} =~ s/(\/|\\|\$)//g;
    }

    my $msg = MIME::Lite->new(
        'From'    => $self->{from},
        'To'      => $self->{to},
        'Cc'      => $self->{cc},
        'Bcc'     => $self->{bcc},
        'Subject' => Encode::encode('MIME-Header', $self->{subject}),
        'Type'    => 'TEXT',
	'Data'    => Encode::encode_utf8($self->{message}),
	'Encoding' => '8bit',
        'Message-ID' => $msg_id,
    );
    $msg->attr("Content-Type" => $self->{contenttype});
    $msg->attr("Content-Type.charset" => 'UTF-8') if
        $self->{contenttype} =~ m#^text/#;
    $msg->add( 'Disposition-Notification-To' => $self->{from} )
      if $self->{notify};
    $msg->replace( 'X-Mailer' => "LedgerSMB $self->{version}" );
    $msg->binmode(':utf8');

    if ( @{ $self->{attachments} } ) {
        foreach my $attachment ( @{ $self->{attachments} } ) {

            my $application =
              ( $attachment =~ /(^\w+$)|\.(html|text|txt|sql)$/ )
              ? "text"
              : "application";

            my $filename = $attachment;
            my $type = "$application/$self->{format}";
            $type .= '; charset="UTF-8"' if $application eq 'text';

            # strip path
            $filename =~ s/(.*\/|$self->{fileid})//g;
            $msg->attach(
                'Type'        => $type,
                'Path'        => $attachment,
                'Filename'    => $filename,
                'Disposition' => 'attachment',
            );
        }

    }

    if ( ${LedgerSMB::Sysconfig::smtphost} ) {
        $msg->send(
            'smtp',
            ${LedgerSMB::Sysconfig::smtphost},
            Timeout => ${LedgerSMB::Sysconfig::smtptimeout}
        ) || return $!;
    }
    else {
        $msg->send( 'sendmail', ${LedgerSMB::Sysconfig::sendmail} )
          || return $!;
    }

    return "";

}

1;

