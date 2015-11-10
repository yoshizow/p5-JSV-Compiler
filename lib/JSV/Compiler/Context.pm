package JSV::Compiler::Context;
use strict;
use warnings;

use JSON;
use JSV::Compiler::Keyword qw(:constants);

use Class::Accessor::Lite (
    new => 0,
    ro  => [qw/
        keywords
        json
        loose_type
    /],
);

sub new {
    my ($class, %args) = @_;

    bless +{
        json => JSON->new->allow_nonref->canonical,
        %args,
    }, $class;
}

# TODO: $schema を解釈し、それぞれの keyword に対する code を emit する。
# priority は最初は考えなくてよい。
# INSTANCE_TYPE に関しては、codegen の方法を考えると JSV と同じような順序で生成すると
# いいかも。
sub generate_code {
    my ($self, $schema) = @_;

    my @codes = ();

    for my $keyword (@{ $self->keywords->{INSTANCE_TYPE_ANY()} }) {
        next unless exists $schema->{$keyword->keyword};
        push @codes, $keyword->generate_code($self, $schema);
    }
    push @codes, q[ if (ref($instance) eq 'HASH') { ];
    for my $keyword (@{ $self->keywords->{INSTANCE_TYPE_OBJECT()} }) {
        next unless exists $schema->{$keyword->keyword};
        push @codes, $keyword->generate_code($self, $schema);
    }
    push @codes, q[ } ];

    return join "\n", @codes;
}

1;
