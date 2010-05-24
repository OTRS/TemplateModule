# --
# Kernel/Output/HTML/OutputFilterTemplateModule.pm
# Copyright (C) 2001-2010 OTRS AG, http://otrs.org/
# --
# $Id: OutputFilterTemplateModule.pm,v 1.2 2010-05-24 09:54:03 bes Exp $
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see L<http://www.gnu.org/licenses/agpl.txt>.
# --

package Kernel::Output::HTML::OutputFilterTemplateModule;

use strict;
use warnings;

use vars qw($VERSION);
$VERSION = qw($Revision: 1.2 $) [1];

sub new {
    my ( $Type, %Param ) = @_;

    # allocate new hash for object
    my $Self = {};
    bless( $Self, $Type );

    # get needed objects
    for my $Needed (
        qw(ConfigObject Debug EncodeObject LayoutObject LogObject MainObject ParamObject TimeObject )
        )
    {
        $Self->{$Needed} = $Param{$Needed} || die "Got no $Object!" );
    }

    return $Self;
}

sub Run {
        my ( $Self, %Param ) = @_;

        #$Param{Data}
        #$Param{TemplateFile}

        return;
}

1;
