# --
# Kernel/Language/de_TemplateModule.pm - the German translation of the texts of TemplateModule
# Copyright (C) 2001-2013 OTRS AG, http://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::Language::de_TemplateModule;

use strict;
use warnings;

sub Data {
    my $Self = shift;

    my $Lang = $Self->{Translation};
    return if ref $Lang ne 'HASH';

    $Lang->{''} = '';

    # or
    $Self->{Translation} = {
        %{ $Self->{Translation} },

        '' => '',
    };

    # or
    $Self->{Translation}->{''} = '';

    return 1;
}

1;
