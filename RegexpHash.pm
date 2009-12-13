package Tie::RegexpHash;

require 5.005_62;
use strict;

use warnings::register qw(Tie::RegexpHash);

require Exporter;

our @ISA = qw( Exporter );

our %EXPORT_TAGS = ( 'all' => [ qw( ) ] );
our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );
our @EXPORT = qw();

our $VERSION = '0.10';

use Carp;

sub new

# Creates a new 'Tie::RegexpHash' object. We use an underlying array rather
# than a hash because we want to search through the hash keys in the order
# that they were added.
#
# See the _find() and add() routines for more details.

  {
    my ($class) = @_;

    my $self = {
      KEYS   => [ ], # array of Regexp keys
      VALUES => [ ], # array of corresponding values
      COUNT  => 0,   # the number of hash/key pairs (is this necessay?)
    };

    bless $self, $class;
  }


sub _find

# Sequentially goes through the hash keys for Regexps which match the given
# key and returns the index. If the hash is empty, or a matching key was not
# found, returns undef.

  {
    my ($self, $key) = @_;

    unless ($self->{COUNT})
      {
	return;
      }

    if (ref($key) eq "Regexp")
      {
	my $i = 0;
	while  ( ($key ne $self->{KEYS}->[ $i ]) and
		 ($i < $self->{COUNT}) ) {
	    $i++;
	  }

	if ($i == $self->{COUNT})
	  {
	    return;
	  }
	else
	  {
	    return $i;
	  }

      }
    else
      {
	my $i = 0;
	while  ( ($key !~ m/$self->{KEYS}->[ $i ]/) and
		 ($i < $self->{COUNT}) ) {
	    $i++;
	  }

	if ($i == $self->{COUNT})
	  {
	    return;
	  }
	else
	  {
	    return $i;
	  }
      }
  }

sub add

# If a key exists the value will be replaced. (If the Regexps are not the same
# but match, a warning is displayed.) If the key is new, then a new key/value
# pair is added.

  {
    my ($self, $key, $value) = @_;

    my $index = _find $self, $key;
    if (defined($index))
      {
	if ($key ne $self->{KEYS}->[ $index ])
	  {
	    if (warnings::enabled)
	      {
		warnings::warn "'`$key\' is not the same as '`" .
		  $self->{KEYS}->[$index] . "\'";
	      }
	  }
	$self->{VALUES}->[ $index ] = $value;
      }
    else
      {
	$index = $self->{COUNT}++;

	my $Regexp;
	if (ref($key) eq "Regexp")
	  {
	    $Regexp = $key;
	  }
	else
	  {
	    $Regexp = qr/$key/;
	  }

	$self->{KEYS}->[ $index ]   = $key;
	$self->{VALUES}->[ $index ] = $value;
      }

  }


sub match_exists

# Does a key exist or does it match any Regexp keys?

  {
    my ($self, $key) = @_;
    return defined( _find $self, $key );
  }

sub match

# Returns the value of a key or any matches to Regexp keys.

  {
    my ($self, $key) = @_;

    my $index = _find $self, $key;

    if (defined($index))
      {
	return $self->{VALUES}->[ $index ];
      }
    else
      {
	return;
      }
  }

sub remove

# Removes a key or Regexp key and associated value from the hash. If the key
# is not the same as the Regexp, a warning is displayed.

  {
    my ($self, $key) = @_;

    my $index = _find $self, $key;

    if (defined($index))
      {

	if ($key ne $self->{KEYS}->[ $index ])
	  {
	    if (warnings::enabled)
	      {
		warnings::warn "'`$key\' is not the same as '`" .
		  $self->{KEYS}->[$index] . "\'";
	      }
	  }

	my $value = $self->{VALUES}->[ $index ];
	splice @{ $self->{KEYS} },   $index, 1;
	splice @{ $self->{VALUES} }, $index, 1;
	$self->{COUNT}--;
	return $value;
      }
    else
      {
	if (warnings::enabled)
	  {
	    warnings::warn "Cannot delete a nonexistent key: \`$key\'";
	  }
	return;
      }

  }

sub clear

# Clears the hash.

  {
    my ($self) = @_;

    $self->{KEYS}   = [ ];
    $self->{VALUES} = [ ];
    $self->{COUNT}  = 0;

  }

BEGIN
  {
    # make aliases...
    no strict;
    *TIEHASH = \ &new;
    *STORE   = \ &add;
    *EXISTS  = \ &match_exists;
    *FETCH   = \ &match;
    *DELETE  = \ &remove;
    *CLEAR   = \ &clear;
  }

sub FIRSTKEY

# Returns the first key

  {
    my ($self) = @_;

    unless ($self->{COUNT})
      {
	return;
      }

    return $self->{KEYS}->[0];

  }

sub NEXTKEY

# Returns the next key

  {
    my ($self, $lastkey) = @_;

    unless ($self->{COUNT})
      {
	return;
      }

    my $index = _find $self, $lastkey;

    unless (defined($index))
      {
	confess "Invalid \$lastkey";
      }

    $index++;

    if ($index == $self->{COUNT})
      {
	return;
      }
    else
      {
	return $self->{KEYS}->[ $index ];
      }

  }


1;
__END__

=head1 NAME

Tie::RegexpHash - Use regular expressions as hash keys

=head1 REQUIREMENTS

C<Tie::RegexpHash> is written for and tested on Perl 5.6.0. A future
version might be tweaked to run on 5.005.

It uses only standard modules.

=head2 Installation

Installation is pretty standard:

  perl Makefile.PL
  make
  make install

No test suite is available in this version.

=head1 SYNOPSIS

  use Tie::RegexpHash;

  my %hash;

  tie %hash, 'Tie::RegexpHash';

  $hash{ qr/^5(\s+|-)?gal(\.|lons?)?/i } = '5-GAL';

  $hash{'5 gal'};     # returns "5-GAL"
  $hash{'5GAL'};      # returns "5-GAL"
  $hash{'5  gallon'}; # also returns "5-GAL"

  my $rehash = Tie::RegexpHash->new();

  $rehash->add( qr/\d+(\.\d+)?/, "contains a number" );
  $rehash->add( qr/s$/,          "ends with an \`s\'" );

  $rehash->match( "foo 123" );  # returns "contains a number"
  $rehash->match( "examples" ); # returns "ends with an `s'"

=head1 DESCRIPTION

This module allows one to use regular expressions for hash keys, so that
values can be associated with anything that matches the key.

Hashes can be operated on using the standard tied hash interface in Perl,
or using an object-orineted interface described below.

=head1 METHODS

=head2 new

  my $obj = Tie::RegexpHash->new()

Creates a new "RegexpHash" (Regular Expression Hash) object.

=head2 add

  $obj->add( $key, $value );

Adds a new key/value pair to the hash. C<$key> can be a Regexp or a string
(which is compiled into a Regexp).

If C<$key> is already defined, the value will be changed. If C<$key> matches
an existing key (but is not the same), a warning will be shown if warnings
are enabled.

=head2 match

  $value = $obj->match( $quasikey );

Returns the value associated with C<$quasikey>. (C<$quasikey> can be a string
which matches an existing Regexp or an actual Regexp.)  Returns 'undef' if
there is no match.

Regexps are matched in the order they are defined.

=head2 match_exists

  if ($obj->match_exists( $quasikey )) ...

Returns a true value if there exists a matching key.

=head2 remove

  $value = $obj->remove( $quasikey );

Deletes the key associated with C<$quasikey>.  If C<$quasikey> matches
an existing key (but is not the same), a warning will be shown if warnings
are enabled.

Returns the value associated with the key.

=head2 clear

  $obj->clear();

Removes all key/value pairs.

=head1 AUTHOR

Robert Rothenberg <rrwo@cpan.org>

=head1 LICENSE

Copyright (c) 2001 Robert Rothenberg. All rights reserved.
This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=cut
