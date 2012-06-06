# --
# Kernel/Output/HTML/OutputFilterTemplateModule.pm
# Copyright (C) 2001-2012 OTRS AG, http://otrs.org/
# --
# $Id: OutputFilterTemplateModule.pm,v 1.3 2012-06-06 11:10:02 mb Exp $
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see L<http://www.gnu.org/licenses/agpl.txt>.
# --

package Kernel::Output::HTML::OutputFilterTemplateModule;

use strict;
use warnings;

use vars qw($VERSION);
$VERSION = qw($Revision: 1.3 $) [1];

sub new {
    my ( $Type, %Param ) = @_;

    # allocate new hash for object
    my $Self = {};
    bless( $Self, $Type );

    # get needed objects
    for my $Object (
        qw(ConfigObject Debug EncodeObject LayoutObject LogObject MainObject ParamObject TimeObject )
        )
    {
        $Self->{$Object} = $Param{$Object} || die "Got no $Object!";
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
