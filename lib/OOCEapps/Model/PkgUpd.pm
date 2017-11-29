package OOCEapps::Model::PkgUpd;
use Mojo::Base 'OOCEapps::Model::base';

use OOCEapps::Controller::PkgUpd;
use OOCEapps::Utils;

# constants
my $MODULES = join '::', grep { !/^Model$/ } split /::/, __PACKAGE__;

# attributes
has schema  => sub {
    my $sv = OOCEapps::Utils->new;

    return {
    members => {
        pkglist_url => {
            description => 'url to package list',
            example     => 'https://raw.githubusercontent.com/omniosorg/omnios-build/master/doc/packages.md',
            validator   => $sv->regexp(qr/^.*$/, 'expected a string'),
        },
    },
    }
};

sub refreshParser {
    my $self = shift;

    my $packages = OOCEapps::Controller::PkgUpd::getPkgList($self, $self->config->{pkglist_url});
    my $modules  = OOCEapps::Utils::loadModules($MODULES);

    PKG: for my $pkg (keys %$packages) {
        for my $mod (@$modules) {
            $mod->canParse($pkg, $packages->{$pkg}->{url}) && do {
                $self->config->{parser}->{$pkg} = $mod;
                next PKG;
            };
        }
    }
    # default parser
    $self->config->{parser}->{DEFAULT} = OOCEapps::PkgUpd::base->new;
}

sub register {
    my $self = shift;
    my $app  = shift;

    $self->SUPER::register($app);

    $self->refreshParser;
}

1;

__END__

=head1 COPYRIGHT

Copyright 2017 OmniOS Community Edition (OmniOSce) Association.

=head1 LICENSE

This program is free software: you can redistribute it and/or modify it
under the terms of the GNU General Public License as published by the Free
Software Foundation, either version 3 of the License, or (at your option)
any later version.
This program is distributed in the hope that it will be useful, but WITHOUT
ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for
more details.
You should have received a copy of the GNU General Public License along with
this program. If not, see L<http://www.gnu.org/licenses/>.

=head1 AUTHOR

S<Dominik Hassler E<lt>hadfl@omniosce.orgE<gt>>

=head1 HISTORY

2017-09-06 had Initial Version

=cut

