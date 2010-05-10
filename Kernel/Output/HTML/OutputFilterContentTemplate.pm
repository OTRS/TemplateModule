# --
# Kernel/Output/HTML/OutputFilterContentTemplate.pm
# Copyright (C) 2001-2010 OTRS AG, http://otrs.org/
# --
# $Id: OutputFilterContentTemplate.pm,v 1.2 2010-05-10 16:11:02 sb Exp $
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::Output::HTML::OutputFilterContentTemplate;

use strict;
use warnings;

use vars qw($VERSION);
$VERSION = qw($Revision: 1.2 $) [1];

sub new {
    my ( $Type, %Param ) = @_;

    # allocate new hash for object
    my $Self = {};
    bless( $Self, $Type );

    # check needed objects
    for my $Needed (
        qw(
        LayoutObject ConfigObject LogObject MainObject ParamObject
        )
        )
    {
        $Self->{$Needed} = $Param{$Needed} || die "Got no $Needed!";
    }
    for my $Needed (qw(Debug)) {
        if ( !defined $Param{$Needed} ) {
            die "Got no $Needed!";
        }
        $Self->{$Needed} = $Param{$Needed};
    }

    return $Self;
}

sub Run {
    my ( $Self, %Param ) = @_;

    # modify all <td> elements
    my $Search  = '(<td[^>]+colspan)';
    my $Replace = ' style="background-color:#FF0000" ';
    ${ $Param{Data} } =~ s{$Search}{$1$Replace}msg;

    return 1;
}

1;
