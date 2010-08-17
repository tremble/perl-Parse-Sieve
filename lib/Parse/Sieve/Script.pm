package Parse::Sieve::Script;

# $URL$
# $Rev$
# $Date$
# $Id$
#
# Copyright 2009-2010 Mark Chappell - <tremble@tremble.org.uk>
#
# This program is free software; you can redistribute
# it and/or modify it under the same terms as Perl itself.
# 
# The full text of the license can be found in the
# LICENSE file included with this module.
#

use strict;
use warnings;
use Parse::Sieve::Block;

BEGIN {
    use vars qw($VERSION);
    $VERSION     = '1.00';
}

use base qw(Parse::Sieve::Block);

use overload q("") => \&toString;

sub new {
	my $type = shift;

	my $self = Parse::Sieve::Block->new(@_);
	return unless (defined $self);

	bless $self,$type;

	return $self;
}

=head2 toString

Purpose : toString the full script: including any require rules and all
commands

Return  : Returns require control and all commands ordered by priority in text format

=cut

sub toString {
	my $self = shift;
	my $script = q{};
	my @reqs = $self->sieverequire();
	if (scalar (@reqs)) {
		$script = 'require [ "'
			. join ('", "', @reqs)
			. '" ];' . "\n";
	}

	$script .= $self->Parse::Sieve::Block::_toString(0);
	return $script;
}


=head2 toString

Purpose : Compare this script to another script and return true if they're the same...

Return  : Returns true if the two scripts are the same.

=cut

sub equals {
    my $self = shift;
    my $object = shift;
	return 1 if (\$self == \$object) ;
	# XXX Horrible hacky way to do it
	# Also wouldn't work sensibly if we start preserving comments, additionally it 
	# doesn't permit us to fiddle with things to suggest we don't care about certain
	# parts being different...
	return ($self->toString eq $object->toString);
}

=head1 BUGS

=head1 SUPPORT

=head1 AUTHOR

Mark Chappell - <tremble@tremble.org.uk>

=head1 COPYRIGHT

Copyright 2009-2010 Mark Chappell - <tremble@tremble.org.uk>

This program is free software; you can redistribute
it and/or modify it under the same terms as Perl itself.

The full text of the license can be found in the
LICENSE file included with this module.

=head1 SEE ALSO

L<Parse::Sieve>

=cut

1;
