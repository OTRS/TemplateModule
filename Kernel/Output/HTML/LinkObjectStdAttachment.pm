# --
# Kernel/Output/HTML/LinkObjectStdAttachment.pm - layout backend module
# Copyright (C) 2001-2010 OTRS AG, http://otrs.org/
# --
# $Id: LinkObjectStdAttachment.pm,v 1.1 2010-05-25 08:42:57 bes Exp $
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::Output::HTML::LinkObjectStdAttachment;

use strict;
use warnings;

use Kernel::Output::HTML::Layout;

use vars qw($VERSION);
$VERSION = qw($Revision: 1.1 $) [1];

=head1 NAME

Kernel::Output::HTML::LinkObjectStdAttachment - layout backend module

=head1 SYNOPSIS

All layout functions of link object (attachment)

=over 4

=cut

=item new()

create an object

    $BackendObject = Kernel::Output::HTML::LinkObjectStdAttachment->new(
        %Param,
    );

=cut

sub new {
    my ( $Type, %Param ) = @_;

    # allocate new hash for object
    my $Self = {};
    bless( $Self, $Type );

    # check needed objects
    for my $Object (
        qw(ConfigObject LogObject MainObject DBObject UserObject EncodeObject
        QueueObject GroupObject ParamObject TimeObject LanguageObject UserLanguage UserID)
        )
    {
        $Self->{$Object} = $Param{$Object} || die "Got no $Object!";
    }
    $Self->{LayoutObject} = Kernel::Output::HTML::Layout->new( %{$Self} );

    # define needed variables
    $Self->{ObjectData} = {
        Object   => 'StdAttachment',
        Realname => 'StdAttachment',
    };

    return $Self;
}

=item TableCreateComplex()

return an array with the block data

Return

    %BlockData = (
        {
            Object    => 'StdAttachment',
            Blockname => 'StdAttachment',
            Headline  => [
                {
                    Content => 'Number#',
                    Width   => 130,
                },
                {
                    Content => 'Title',
                },
                {
                    Content => 'Created',
                    Width   => 110,
                },
            ],
            ItemList => [
                [
                    {
                        Type    => 'Link',
                        Key     => $StdAttachmentID,
                        Content => '123123123',
                        Css     => 'style="text-decoration: line-through"',
                    },
                    {
                        Type      => 'Text',
                        Content   => 'The title',
                        MaxLength => 50,
                    },
                    {
                        Type    => 'TimeLong',
                        Content => '2008-01-01 12:12:00',
                    },
                ],
                [
                    {
                        Type    => 'Link',
                        Key     => $StdAttachmentID,
                        Content => '434234',
                    },
                    {
                        Type      => 'Text',
                        Content   => 'The title of attachment 2',
                        MaxLength => 50,
                    },
                    {
                        Type    => 'TimeLong',
                        Content => '2008-01-01 12:12:00',
                    },
                ],
            ],
        },
    );

    @BlockData = $LinkObject->TableCreateComplex(
        ObjectLinkListWithData => $ObjectLinkListRef,
    );

=cut

sub TableCreateComplex {
    my ( $Self, %Param ) = @_;

    # check needed stuff
    if ( !$Param{ObjectLinkListWithData} || ref $Param{ObjectLinkListWithData} ne 'HASH' ) {
        $Self->{LogObject}->Log(
            Priority => 'error',
            Message  => 'Need ObjectLinkListWithData!',
        );
        return;
    }

    # convert the list
    my %LinkList;
    for my $LinkType ( keys %{ $Param{ObjectLinkListWithData} } ) {

        # extract link type List
        my $LinkTypeList = $Param{ObjectLinkListWithData}->{$LinkType};

        for my $Direction ( keys %{$LinkTypeList} ) {

            # extract direction list
            my $DirectionList = $Param{ObjectLinkListWithData}->{$LinkType}->{$Direction};

            for my $StdAttachmentID ( keys %{$DirectionList} ) {

                $LinkList{$StdAttachmentID}->{Data} = $DirectionList->{$StdAttachmentID};
            }
        }
    }

    # create the item list
    my @ItemList;
    for my $StdAttachmentID ( keys %LinkList ) {

        # extract attachment data
        my $StdAttachment = $LinkList{$StdAttachmentID}{Data};

        # set css
        my $Css = '';

        my @ItemColumns = (
            {
                Type    => 'Link',
                Key     => $StdAttachmentID,
                Content => $StdAttachment->{Name},
                Link => '$Env{"Baselink"}Action=AdmitAttachment&AttachmentID=' . $StdAttachmentID,
                Css  => $Css,
            },
            {
                Type      => 'Text',
                Content   => $StdAttachment->{Filename},
                MaxLength => 50,
            },
            {
                Type    => 'Text',
                Content => $StdAttachment->{Comment},
            },
        );

        push @ItemList, \@ItemColumns;
    }

    return if !@ItemList;

    # define the block data
    my %Block = (
        Object    => $Self->{ObjectData}->{Object},
        Blockname => $Self->{ObjectData}->{Realname},
        Headline  => [
            {
                Content => 'StdAttachment#',
                Width   => 130,
            },
            {
                Content => 'Name',
            },
            {
                Content => 'Filename',
                Width   => 100,
            },
            {
                Content => 'Comment',
                Width   => 110,
            },
        ],
        ItemList => \@ItemList,
    );

    return ( \%Block );
}

=item TableCreateSimple()

return a hash with the link output data

Return

    %LinkOutputData = (
        Normal::Source => {
            StdAttachment => [
                {
                    Type    => 'Link',
                    Content => 'T:55555',
                    Title   => 'StdAttachment#555555: The attachment title',
                    Css     => 'style="text-decoration: line-through"',
                },
                {
                    Type    => 'Link',
                    Content => 'T:22222',
                    Title   => 'StdAttachment#22222: Title of attachment 22222',
                },
            ],
        },
        ParentChild::Target => {
            StdAttachment => [
                {
                    Type    => 'Link',
                    Content => 'T:77777',
                    Title   => 'StdAttachment#77777: StdAttachment title',
                },
            ],
        },
    );

    %LinkOutputData = $LinkObject->TableCreateSimple(
        ObjectLinkListWithData => $ObjectLinkListRef,
    );

=cut

sub TableCreateSimple {
    my ( $Self, %Param ) = @_;

    # check needed stuff
    if ( !$Param{ObjectLinkListWithData} || ref $Param{ObjectLinkListWithData} ne 'HASH' ) {
        $Self->{LogObject}->Log( Priority => 'error', Message => 'Need ObjectLinkListWithData!' );
        return;
    }

    my %LinkOutputData;
    for my $LinkType ( keys %{ $Param{ObjectLinkListWithData} } ) {

        # extract link type List
        my $LinkTypeList = $Param{ObjectLinkListWithData}->{$LinkType};

        for my $Direction ( keys %{$LinkTypeList} ) {

            # extract direction list
            my $DirectionList = $Param{ObjectLinkListWithData}->{$LinkType}->{$Direction};

            my @ItemList;
            for my $StdAttachmentID ( sort { $a <=> $b } keys %{$DirectionList} ) {

                # extract attachment data
                my $StdAttachment = $DirectionList->{$StdAttachmentID};

                # set css
                my $Css = '';

                # define item data
                my %Item = (
                    Type    => 'Link',
                    Content => "StdAttachment $StdAttachment->{Name}",
                    Title   => "StdAttachment $StdAttachment->{Name}",
                    Link    => '$Env{"Baselink"}Action=AdminAttachment&AttachmentID='
                        . $StdAttachmentID,
                    Css => $Css,
                );

                push @ItemList, \%Item;
            }

            # add item list to link output data
            $LinkOutputData{ $LinkType . '::' . $Direction }->{StdAttachment} = \@ItemList;
        }
    }

    #use Data::Dumper; die Dumper( \%LinkOutputData );
    return %LinkOutputData;
}

=item ContentStringCreate()

return a output string

    my $String = $LayoutObject->ContentStringCreate(
        ContentData => $HashRef,
    );

=cut

sub ContentStringCreate {
    my ( $Self, %Param ) = @_;

    # check needed stuff
    if ( !$Param{ContentData} ) {
        $Self->{LogObject}->Log( Priority => 'error', Message => 'Need ContentData!' );
        return;
    }

    return;
}

=item SelectableObjectList()

return an array hash with selectable objects

Return

    @SelectableObjectList = (
        {
            Key   => 'StdAttachment',
            Value => 'StdAttachment',
        },
    );

    @SelectableObjectList = $LinkObject->SelectableObjectList(
        Selected => $Identifier,  # (optional)
    );

=cut

sub SelectableObjectList {
    my ( $Self, %Param ) = @_;

    my $Selected;
    if ( $Param{Selected} && $Param{Selected} eq $Self->{ObjectData}->{Object} ) {
        $Selected = 1;
    }

    # object select list
    my @ObjectSelectList = (
        {
            Key      => $Self->{ObjectData}->{Object},
            Value    => $Self->{ObjectData}->{Realname},
            Selected => $Selected,
        },
    );

    return @ObjectSelectList;
}

=item SearchOptionList()

return an array hash with search options

Return

    @SearchOptionList = (
        {
            Key       => 'StdAttachmentNumber',
            Name      => 'StdAttachment#',
            InputStrg => $FormString,
            FormData  => '1234',
        },
        {
            Key       => 'Title',
            Name      => 'Title',
            InputStrg => $FormString,
            FormData  => 'BlaBla',
        },
    );

    @SearchOptionList = $LinkObject->SearchOptionList(
        SubObject => 'Bla',  # (optional)
    );

=cut

sub SearchOptionList {
    my ( $Self, %Param ) = @_;

    # search option list
    my @SearchOptionList = (
        {
            Key  => 'Name',
            Name => 'Name',
            Type => 'Text',
        },
    );

    # add formkey
    for my $Row (@SearchOptionList) {
        $Row->{FormKey} = 'SEARCH::' . $Row->{Key};
    }

    # add form data and input string
    ROW:
    for my $Row (@SearchOptionList) {

        # prepare text input fields
        if ( $Row->{Type} eq 'Text' ) {

            # get form data
            $Row->{FormData} = $Self->{ParamObject}->GetParam( Param => $Row->{FormKey} );

            # parse the input text block
            $Self->{LayoutObject}->Block(
                Name => 'InputText',
                Data => {
                    Key => $Row->{FormKey},
                    Value => $Row->{FormData} || '',
                },
            );

            # add the input string
            $Row->{InputStrg} = $Self->{LayoutObject}->Output(
                TemplateFile => 'LinkObject',
            );

            next ROW;
        }

        # prepare list boxes
        if ( $Row->{Type} eq 'List' ) {

            # get form data
            my @FormData = $Self->{ParamObject}->GetArray( Param => $Row->{FormKey} );
            $Row->{FormData} = \@FormData;

            my %ListData;

            # add the input string
            $Row->{InputStrg} = $Self->{LayoutObject}->BuildSelection(
                Data       => \%ListData,
                Name       => $Row->{FormKey},
                SelectedID => $Row->{FormData},
                Size       => 3,
                Multiple   => 1,
            );

            next ROW;
        }
    }

    return @SearchOptionList;
}

1;

=back

=head1 TERMS AND CONDITIONS

This software is part of the OTRS project (http://otrs.org/).

This software comes with ABSOLUTELY NO WARRANTY. For details, see
the enclosed file COPYING for license information (AGPL). If you
did not receive this file, see http://www.gnu.org/licenses/agpl.txt.

=cut

=head1 VERSION

$Revision: 1.1 $ $Date: 2010-05-25 08:42:57 $

=cut
