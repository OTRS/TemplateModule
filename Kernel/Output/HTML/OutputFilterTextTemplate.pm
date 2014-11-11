# --
# Kernel/Output/HTML/OutputFilterTextTemplate.pm - text filter
# Copyright (C) 2001-2014 OTRS AG, http://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::Output::HTML::OutputFilterTextTemplate;

use strict;
use warnings;

use vars qw(@ISA $VERSION);

sub new {
    my ( $Type, %Param ) = @_;

    # allocate new hash for object
    my $Self = {};
    bless( $Self, $Type );

    # check needed objects
    for my $Needed (qw(DBObject ConfigObject LogObject TimeObject MainObject LayoutObject)) {
        $Self->{$Needed} = $Param{$Needed} || die "Got no $Needed!";
    }

    return $Self;
}

sub Pre {
    my ( $Self, %Param ) = @_;

    # check needed stuff
    if ( !defined $Param{Data} ) {
        $Self->{LogObject}->Log(
            Priority => 'error',
            Message  => 'Need Data!'
        );
        $Self->{LayoutObject}->FatalDie();
    }

    ${ $Param{Data} } =~ s{\. ([a-z])}{". " . uc($1)}emsg;

    return $Param{Data};
}

sub Post {
    my ( $Self, %Param ) = @_;

    # check needed stuff
    if ( !defined $Param{Data} ) {
        $Self->{LogObject}->Log(
            Priority => 'error',
            Message  => 'Need Data!'
        );
        $Self->{LayoutObject}->FatalDie();
    }

    ${ $Param{Data} } =~ s{(invalid)}{<b>$1</b>}msig;

    return $Param{Data};
}

1;
