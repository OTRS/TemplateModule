# --
# Kernel/Output/HTML/OutputFilterPostTemplate.pm
# Copyright (C) 2001-2013 OTRS AG, http://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::Output::HTML::OutputFilterPostTemplate;

use strict;
use warnings;

use Kernel::System::Encode;
use Kernel::System::DB;
use Kernel::System::Time;
use Kernel::System::Ticket;

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

    # get template name
    my $TemplateName = $Param{TemplateFile} || '';
    return 1 if !$TemplateName;

    # get valid modules
    my $ValidTemplates = $Self->{ConfigObject}->Get('Frontend::Output::FilterElementPost')
        ->{'OutputFilterPostTemplate'}->{Modules};

    # apply only if template is valid in config
    return 1 if !$ValidTemplates->{$TemplateName};

    # create needed objects
    $Self->{EncodeObject} = Kernel::System::Encode->new( %{$Self} );
    if ( $Self->{LayoutObject}->{DBObject} ) {
        $Self->{DBObject} = $Self->{LayoutObject}->{DBObject};
    }
    else {
        $Self->{DBObject} = Kernel::System::DB->new( %{$Self} );
    }
    $Self->{TimeObject}   = Kernel::System::Time->new( %{$Self} );
    $Self->{TicketObject} = Kernel::System::Ticket->new( %{$Self} );

    my $TicketID = $Self->{ParamObject}->GetParam( Param => 'TicketID' );
    return 1 if !$TicketID;

    my %Ticket = $Self->{TicketObject}->TicketGet(
        TicketID => $TicketID,
        UserID   => $Self->{LayoutObject}->{UserID},
    );
    return 1 if !%Ticket;

    my $ItemDisplay .= <<"END";
                <tr valign="top">
                    <td><b>Post Title:</b></td>
                    <td>$Ticket{Title}</td>
                </tr>
END

    # display item
    my $Search = '([ \t]+</table>\s+<!--start CustomerTable-->)';
    ${ $Param{Data} } =~ s{$Search}{$ItemDisplay$1}ms;

    return 1;
}

1;
