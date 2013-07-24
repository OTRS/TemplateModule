# --
# Kernel/Output/HTML/OutputFilterPreTemplate.pm
# Copyright (C) 2001-2012 OTRS AG, http://otrs.org/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::Output::HTML::OutputFilterPreTemplate;

use strict;
use warnings;

use Kernel::System::Encode;
use Kernel::System::DB;
use Kernel::System::Time;

sub new {
    my ( $Type, %Param ) = @_;

    # allocate new hash for object
    my $Self = {};
    bless( $Self, $Type );

    # check needed objects
    for my $Object (
        qw(
        LayoutObject ConfigObject LogObject MainObject ParamObject
        )
        )
    {
        $Self->{$Object} = $Param{$Object} || die "Got no $Object!";
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
    my $ValidTemplates = $Self->{ConfigObject}->Get('Frontend::Output::FilterElementPre')
        ->{'OutputFilterPreTemplate'}->{Modules};

    # apply only if template is valid in config
    return 1 if !$ValidTemplates->{$TemplateName};

    my $ItemDisplay .= <<'END';
                <tr valign="top">
                    <td><b>Pre $Text{"Title"}:</b></td>
                    <td>$QData{"Title"}</td>
                </tr>
END

    # display item
    my $Search = '([ \t]+</table>(?:(?!</table>).)+?<!-- dtl:block:CustomerTable -->)';
    ${ $Param{Data} } =~ s{$Search}{$ItemDisplay$1}ms;

    return 1;
}

1;
