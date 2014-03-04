# --
# Kernel/System/HTMLUtilsRedefined.pm - HTML utils custom changes
# Copyright (C) 2001-2014 OTRS AG, http://otrs.com/
# --
# $origin: https://github.com/OTRS/otrs/blob/77149f6f5210094eff910cfea2f6009f603221ce/Kernel/System/HTMLUtils.pm
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::System::HTMLUtilsRedefined;

use strict;
use warnings;

use Kernel::System::VariableCheck qw(:all);

# disable redefine warnings in this scope
{
no warnings 'redefine';

    sub Kernel::System::HTMLUtils::Safety {
        my ( $Self, %Param ) = @_;

# ---
# Customer
# ---
# bli bla blub
# ---
        # check needed stuff
        for (qw(String)) {
            if ( !defined $Param{$_} ) {
                $Self->{LogObject}->Log( Priority => 'error', Message => "Need $_!" );
                return;
            }
        }

        my $String = $Param{String} || '';

        # check ref
        my $StringScalar;
        if ( !ref $String ) {
            $StringScalar = $String;
            $String       = \$StringScalar;
        }

        my %Safety;

        my $Replaced;

        # In UTF-7, < and > can be encoded to mask them from security filters like this one.
        my $TagStart = '(?:<|[+]ADw-)';
        my $TagEnd   = '(?:>|[+]AD4-)';

        # This can also be entity-encoded to hide it from the parser.
        #   Browsers seem to tolerate an omitted ";".
        my $JavaScriptPrefixRegex = '
            (?: j | &\#106[;]? | &\#x6a[;]? )
            (?: a | &\#97[;]?  | &\#x61[;]? )
            (?: v | &\#118[;]? | &\#x76[;]? )
            (?: a | &\#97[;]?  | &\#x61[;]? )
            (?: s | &\#115[;]? | &\#x73[;]? )
            (?: c | &\#99[;]?  | &\#x63[;]? )
            (?: r | &\#114[;]? | &\#x72[;]? )
            (?: i | &\#105[;]? | &\#x69[;]? )
            (?: p | &\#112[;]? | &\#x70[;]? )
            (?: t | &\#116[;]? | &\#x74[;]? )
        ';

        my $ExpressionPrefixRegex = '
            (?: e | &\#101[;]? | &\#x65[;]? )
            (?: x | &\#120[;]? | &\#x78[;]? )
            (?: p | &\#112[;]? | &\#x70[;]? )
            (?: r | &\#114[;]? | &\#x72[;]? )
            (?: e | &\#101[;]? | &\#x65[;]? )
            (?: s | &\#115[;]? | &\#x73[;]? )
            (?: s | &\#115[;]? | &\#x73[;]? )
            (?: i | &\#105[;]? | &\#x69[;]? )
            (?: o | &\#111[;]? | &\#x6f[;]? )
            (?: n | &\#110[;]? | &\#x6e[;]? )
        ';

        # Replace as many times as it is needed to avoid nesting tag attacks.
        do {
            $Replaced = undef;

            # remove script tags
            if ( $Param{NoJavaScript} ) {
                $Replaced += ${$String} =~ s{
                    $TagStart script.*? $TagEnd .*?  $TagStart /script \s* $TagEnd
                }
                {}sgxim;
                $Replaced += ${$String} =~ s{
                    $TagStart script.*? $TagEnd .+? ($TagStart|$TagEnd)
                }
                {}sgxim;

                # remove style/javascript parts
                $Replaced += ${$String} =~ s{
                    $TagStart style[^>]+? $JavaScriptPrefixRegex (.+?|) $TagEnd (.*?) $TagStart /style \s* $TagEnd
                }
                {}sgxim;

                # remove MS CSS expressions (JavaScript embedded in CSS)
                ${$String} =~ s{
                    ($TagStart style[^>]+? $TagEnd .*? $TagStart /style \s* $TagEnd)
                }
                {
                    if ( index($1, 'expression(' ) > -1 ) {
                        $Replaced = 1;
                        '';
                    }
                    else {
                        $1;
                    }
                }egsxim;
            }

            # remove HTTP refirects
            $Replaced += ${$String} =~ s{
                $TagStart meta [^>]+? http-equiv=('|"|)refresh [^>]+? $TagEnd
            }
            {}sgxim;

            # remove <applet> tags
            if ( $Param{NoApplet} ) {
                $Replaced += ${$String} =~ s{
                    $TagStart applet.*? $TagEnd (.*?) $TagStart /applet \s* $TagEnd
                }
                {}sgxim;
            }

            # remove <Object> tags
            if ( $Param{NoObject} ) {
                $Replaced += ${$String} =~ s{
                    $TagStart object.*? $TagEnd (.*?) $TagStart /object \s* $TagEnd
                }
                {}sgxim;
            }

            # remove <svg> tags
            if ( $Param{NoSVG} ) {
                $Replaced += ${$String} =~ s{
                    $TagStart svg.*? $TagEnd (.*?) $TagStart /svg \s* $TagEnd
                }
                {}sgxim;
            }

            # remove <embed> tags
            if ( $Param{NoEmbed} ) {
                $Replaced += ${$String} =~ s{
                    $TagStart embed.*? $TagEnd
                }
                {}sgxim;
            }

            # check each html tag
            ${$String} =~ s{
                ($TagStart.+?$TagEnd)
            }
            {
                my $Tag = $1;
                if ($Param{NoJavaScript}) {

                    # remove on action attributes
                    $Replaced += $Tag =~ s{
                        (?:\s|/) on.+?=(".+?"|'.+?'|.+?)($TagEnd|\s)
                    }
                    {$2}sgxim;

                    # remove entities in tag
                    $Replaced += $Tag =~ s{
                        (&\{.+?\})
                    }
                    {}sgxim;

                    # remove javascript in a href links or src links
                    $Replaced += $Tag =~ s{
                        ((?:\s|;|/)(?:background|url|src|href)=)
                        ('|"|)                                  # delimiter, can be empty
                        (?:\s* $JavaScriptPrefixRegex .*?)      # javascript, followed by anything but the delimiter
                        \2                                      # delimiter again
                        (\s|$TagEnd)
                    }
                    {
                        "$1\"\"$3";
                    }sgxime;

                    # remove link javascript tags
                    $Replaced += $Tag =~ s{
                        ($TagStart link .+? $JavaScriptPrefixRegex (.+?|) $TagEnd)
                    }
                    {}sgxim;

                    # remove MS CSS expressions (JavaScript embedded in CSS)
                    $Replaced += $Tag =~ s{
                        \sstyle=("|')[^\1]*? $ExpressionPrefixRegex [(].*?\1($TagEnd|\s)
                    }
                    {
                        $2;
                    }egsxim;
                }

                # remove load tags
                if ($Param{NoIntSrcLoad} || $Param{NoExtSrcLoad}) {
                    $Tag =~ s{
                        ($TagStart (.+?) (?: \s | /) src=(.+?) (\s.+?|) $TagEnd)
                    }
                    {
                        my $URL = $3;
                        if ($Param{NoIntSrcLoad} || ($Param{NoExtSrcLoad} && $URL =~ /(http|ftp|https):\//i)) {
                            $Replaced = 1;
                            '';
                        }
                        else {
                            $1;
                        }
                    }segxim;
                }

                # replace original tag with clean tag
                $Tag;
            }segxim;

            $Safety{Replace} += $Replaced;

        } while ($Replaced);    ## no critic

        # check ref && return result like called
        if ($StringScalar) {
            $Safety{String} = ${$String};
        }
        else {
            $Safety{String} = $String;
        }
        return %Safety;
    }

}

1;
