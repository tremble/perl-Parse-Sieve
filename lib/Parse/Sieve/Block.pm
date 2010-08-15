package Parse::Sieve::Block;

# $URL$
# $Rev$
# $Date$
# $Id$
#
# Copyright 2010 Mark Chappell - <tremble@tremble.org.uk>
#
# This program is free software; you can redistribute
# it and/or modify it under the same terms as Perl itself.
# 
# The full text of the license can be found in the
# LICENSE file included with this module.
#

use strict;
use warnings;

BEGIN {
	use Exporter ();
	use vars qw($VERSION);
	$VERSION = '1.00';
}

use base qw(Class::Accessor::Fast);

__PACKAGE__->mk_accessors(qw(name));

my $indentation = "\t";

sub getIndentation {
	return $indentation;
}
sub setIndentation {
	$indentation = $_;
	return;
}

sub new
{
	my $class =shift;
	my $self = bless ({}, ref $class || $class);

	if (scalar @_) {
		$self->commands(@_);
	}
	return $self;
}

sub clone
{
	my $self = shift;
	return $self->Parse::Sieve::Block::new($self->commands(), @_);
}

=head2 toString

Purpose : return a block of sieve code in text format

Return  : Returns all commands ordered by priority in text format

=cut

sub toString {
	my $self = shift;
	my $indent = shift;
	my $in = q{} ;
	foreach (1..$indent-1) {$in .= $indentation;};
	my $line = $self->_toString($indent,@_);
	$line = "\n${in}{\n" . $line . "\n${in}}\n" if ($line);
	return $line;
}

sub _toString {
	my $self = shift;
	my $indent = shift;
	my $in = q{} ;
	foreach (1..$indent) {$in .= $indentation;};
	my @commands = $self->commands();
	foreach my $command (@commands) {
		next unless ($command);
		my $line = $command->toString($indent+1) ;
		$command = $line;
	}
	my $line = $in . join ("\n${in}", @commands);
	return $line;
}


# XXX WriteMe
sub equals {
	my $self = shift;
	my $object = shift;
	return 0;
}

=head2 findCommand

Return L<Parse::Sieve::Command> find by priority

Return undef on error, 0 on not found

=cut

# XXX Do we want to search recursively, do we want to permit
# searching by id ?
sub findCommand
{
	my $self = shift;
	my $priority = shift;
	return if not defined $self->commands;

	foreach my $command (@{$self->commands}) {
		return $command if ($command->priority == $priority );
	}

	return 0;
}

=head2 swapCommands

Swap priorities, 

Return 1 on success, 0 on error

=cut

# XXX We need to do something sensible if you try to swap if controls

sub swapCommands
{
	my $self = shift;
	my $a = shift;
	my $b = shift;

	return 0 if $a == $b;

	my $commanda = $self->find_command($a);
	my $commandb = $self->find_command($b);
	
	return 0 unless $commanda->isa('Parse::Sieve::Command');
	return 0 unless $commandb->isa('Parse::Sieve::Command');

	my $priority = $commandb->priority();
	$commandb->priority($commanda->priority());
	$commanda->priority($priority);

	return 1;
}

=head2 reorderCommands

Reorder rules with a list of number, start with 1, and with blank separator. Usefull for ajax sort functions.

Thank you jeanne for your help in brain storming.

Return 1 on success, 0 on error

=cut

# XXX Ergh, what is it with these space sepearated lists
sub reorderCommands
{
	my $self = shift;
	my $list = shift;

	return 0 if ( ! $list );

	my @swap = split q{ } , $list;

	return 0 if ( ! scalar @swap );

	my @new_ordered_commands;
	foreach my $swap ( @swap ) {
	  if ($swap =~ /\d+/mx) {
	   my $command = $self->find_command($swap);
	   push @new_ordered_commands, $command;
	  }
	}

	my $i=1;
	foreach my $rule (@new_ordered_commands) {
	  $rule->priority($i);
	  $i++;
	};

	return 1;
}

=head2 deleteCommand

Delete a command, dealing with elsif and else statements

 if deleted command is 'if' then ...
	delete next command if next command is 'else'
	change next command to 'if' next is 'elsif'

Return : the Parse::Sieve::Command deleted

=cut

sub deleteCommand
{
	my $self = shift;
	my $priority = shift;
	if (ref($priority) && $priority->can('priority')) {
		$priority = $priority->priority;
	}
	my $deleted = 0;
	my @commands =  $self->commands();
	my @newcommands = ();
	my $order = 0;
	my $lastindex = $#commands; 
	for my $i ( 0..$lastindex ) {
		my $command = $commands[$i];
		my $next=$i+1;
		if ($command->priority == $priority) {
			$deleted = $command;
			if ( defined $commands[$next] && $command->identifier eq 'if') {
				$commands[$next]->identifier('if')
					if ($commands[$next]->identifier eq 'elsif' );

				# XXX We should probably do something more intellegent here
				if ($commands[$next]->identifier eq 'else' ) {
					$i++;
				}
			}
		}
		else {
			++$order;
			$command->priority($order);
			push @newcommands, $command;
		}
	}

	@newcommands = grep { $_ } @newcommands;
	$self->{'commands'} = \@newcommands;
	
	return $deleted;
}

# Deleting of tests is done at the block level so that we can nuke 
# blank if statements
sub deleteTest
{
	my $self = shift;
	my $id = shift;
	if (ref($id) && $id->can('id')) {
		$id = $id->id;
	}
	my @commands =  $self->commands;
	my $order = 0;
	my $deleted = undef;
	
	foreach my $command (@commands) {
		my $d = $command->deleteTest($id);
		next unless ($d);
		$deleted = $d;
		my @tests = $command->tests;
		next if (scalar @tests) ;
		$deleted = $self->deleteCommand($command);
	}

	return $deleted;
}

=head2 appendCommand

Purpose  : append a command to the end of block

Return   : priority on success, 0 on error

Argument : Parse::Sieve::Command object

=cut

sub appendCommand
{
	my $self = shift;
	my $command = shift;

	return 0 unless $command;
	return 0 unless ($command->isa('Parse::Sieve::Command'));

	my @commands = $self->commands();
	my $priority = 0;
	if (scalar @commands) {
		my $lastCommand = $commands[-1];
		$priority = $lastCommand->priority + 10;
	}

	$command->priority($priority);
	push @commands, $command;
	$self->commands(@commands);

	return $priority;
}


=head2 insertCommandBefore

Purpose  : add a command into the block immediately before another 

Return   : priority on success, 0 on error

Argument : Parse::Sieve::Command object

=cut

sub insertCommandBefore
{
	my $self = shift;
	my $newcommand = shift;
	my $oldcommand = shift;
	my $oldpriority = undef;

	return 0 unless ($newcommand);
	return 0 unless ($newcommand->isa('Parse::Sieve::Command'));
	return 0 unless ($oldcommand);
	if ($oldcommand =~ /^\d*$/mx) {
		$oldpriority = $oldcommand;
	} else {
		return unless (ref($oldcommand));
		return unless ($oldcommand->can('priority'));
		$oldpriority = $oldcommand->priority;
	}

	my $previous = $oldpriority - 1;
	my $previouspriority = undef;
	foreach my $command ($self->commands()){
		next unless (ref($command));
		next unless ($command->can('priority'));
		$previouspriority = $previous if ($command->priority == $oldpriority);
		$previous = $command->priority;
	}
	return unless (defined $previouspriority);
	my $newpriority = (($previouspriority + $oldpriority) / 2);
	$newcommand->priority($newpriority);
	my @commands =  $self->commands();
	push @commands, $newcommand;
	$self->commands(@commands);
	return $newcommand->priority;
}


=head2 insertCommandAfter

Purpose  : add a command into the block immediately after another 

Return   : priority on success, 0 on error

Argument : Parse::Sieve::Command object

=cut

sub insertCommandAfter
{
	my $self = shift;
	my $newcommand = shift;
	my $oldcommand = shift;
	my $oldpriority = undef;

	return 0 unless ($newcommand);
	return 0 unless ($newcommand->isa('Parse::Sieve::Command'));
	return 0 unless ($oldcommand);
	if ($oldcommand =~ /^\d*$/mx) {
		$oldpriority = $oldcommand;
	} else {
		return unless (ref($oldcommand));
		return unless ($oldcommand->can('priority'));
		$oldpriority = $oldcommand->priority;
	}

	my $current = 0;
	my $nextpriority = undef;
	foreach my $command ($self->commands()){
		next unless (ref($command));
		next unless ($command->can('priority'));
		if ($current) {
			$nextpriority = $command->priority;
			$current = 0;
		}
		$current = 1 if ($command->priority == $oldpriority);
	}
	$nextpriority = $oldpriority + 1 if ($current);
	return unless (defined $nextpriority);
	my $newpriority = (($nextpriority + $oldpriority) / 2);
	$newcommand->priority($newpriority);
	my @commands = $self->commands();
	push @commands, $newcommand;
	$self->commands(@commands);
	return $newcommand->priority;
}


=head2 insertCommand

Purpose  : add a command into the block using the priority of that
command to tell us where.

Return   : priority on success, 0 on error

Argument : Parse::Sieve::Command object

=cut

sub insertCommand
{
	my $self = shift;
	my $command = shift;

	return 0 unless ($command);
	return 0 unless $command->isa('Parse::Sieve::Command');

	my @commands =  $self->commands() || ();
	push @commands, $command;
	$self->commands(@commands);
	return $command->priority;
}

=head2 commands

Purpose  : Return a sorted list of command objects

Return   : Returns a list of Parse::Sieve::Commands ordered by priority.

=cut

sub commands
{
	my $self = shift;
	unless (@_) {
		my $ret = $self->{'commands'};
		return () unless (ref($ret) eq 'ARRAY');
		return @{$ret};
	}
	my @commands = sort {  $a->{'priority'} <=> $b->{'priority'}
							||
						$a->{'id'} <=> $b->{'id'}  } @_;

	@commands = grep {$_} @commands;

	$self->{'commands'} = \@commands;
	return @commands;
}

=head2 sieverequire

Purpose  : Returns a list of all require strings required by the commands

Return   : Returns a list of all require strings required by the commands

=cut

sub sieverequire {
	my $self = shift;
	my @commands = $self->commands();
	my @req = ();
	foreach my $command (@commands) {
		next unless $command->can('sieverequire');
		push @req, $command->sieverequire();
	}
	my %rq = ();
	foreach my $require (@req) {
		$rq{$require} = 1;
	}
	return keys %rq;
}

=head1 BUGS

=head1 SUPPORT


=head1 AUTHOR

Mark Chappell <tremble@tremble.org.uk>

=head1 COPYRIGHT

Copyright 2009 Mark Chappell - <tremble@tremble.org.uk>

This program is free software; you can redistribute
it and/or modify it under the same terms as Perl itself.

The full text of the license can be found in the
LICENSE file included with this module.


=head1 SEE ALSO

L<Parse::Sieve>

=cut

1;
