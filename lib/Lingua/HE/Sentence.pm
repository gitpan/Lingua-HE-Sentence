package Lingua::HE::Sentence;

#==============================================================================
#
# Start of POD
#
#==============================================================================

=head1 NAME

Lingua::HE::Sentence - Module for splitting Hebrew text into sentences.

=head1 SYNOPSIS

	use Lingua::HE::Sentence qw( get_sentences );

	my $sentences=get_sentences($text);	## Get the sentences.
	foreach my $sentence (@$sentences) {
		## do something with $sentence
	}


=head1 DESCRIPTION

The C<Lingua::HE::Sentence> module contains the function get_sentences, which splits Hebrew text into its constituent sentences, based on regular expressions.

The module assumes text encoded in Logical Hebrew, according to CP1255. Supporting other input formats is possible, but I need people to ask for it.

=head1 HEBREW DETAILS

Language:               Hebrew
Language ID:            he
MS Locale ID:           1037
ISO 639-1:              he
ISO 639-2 (MARC):       heb
ISO 8859 (charset):     8859-8
ANSI codepage:          1255
Unicode:                0590-05FF

=head1 FUNCTIONS

All functions used should be requested in the 'use' clause. None is exported by default.

=item get_sentences( $text )

The get sentences function takes a scalar containing ascii text as an argument and returns a reference to an array of sentences that the text has been split into.
Returned sentences will be trimmed (beginning and end of sentence) of white-spaces.
Strings with no alpha-numeric characters in them, won't be returned as sentences.

=item get_EOS(	)

This function returns the value of the string used to mark the end of sentence. You might want to see what it is, and to make sure your text doesn't contain it. You can use set_EOS() to alter the end-of-sentence string to whatever you desire.

=item set_EOS( $new_EOS_string )

This function alters the end-of-sentence string used to mark the end of sentences. 

=head1 FUTURE WORK

=item [1] Object Oriented like usage.

=item [2] Supporting more encodings, or at least UNICODE (e.g. utf-8).

=item [3] Code cleanup and optimization.

=head1 SEE ALSO

	Lingua::EN::Sentence

=head1 AUTHOR

Shlomo Yona shlomo@cs.haifa.ac.il

=head1 COPYRIGHT

Copyright (c) 2001, 2002 Shlomo Yona. All rights reserved.

This library is free software. 
You can redistribute it and/or modify it under the same terms as Perl itself.  

=cut

#==============================================================================
#
# End of POD
#
#==============================================================================


#==============================================================================
#
# Pragmas
#
#==============================================================================
require 5.005_03;
use strict;
use POSIX qw(locale_h);
#==============================================================================
#
# Modules
#
#==============================================================================
require Exporter;

#==============================================================================
#
# Public globals
#
#==============================================================================
use vars qw/$VERSION @ISA @EXPORT_OK $EOS $LOC $AP $P $PAP/;
use Carp qw/cluck/;

$VERSION = '0.01';

# LC_CTYPE now in locale "French, Canada, codeset ISO 8859-1"
$LOC=setlocale(LC_CTYPE, "CP1255"); 
use locale;

@ISA = qw( Exporter );
@EXPORT_OK = qw( get_sentences 
		get_EOS set_EOS);

$EOS="\001";
$P = q/[\.!?]/;			## PUNCTUATION
$AP = q/(?:'|"|\)|\]|\})?/;	## AFTER PUNCTUATION
$PAP = $P.$AP;

#==============================================================================
#
# Public methods
#
#==============================================================================

#------------------------------------------------------------------------------
# get_sentences - takes text input and splits it into sentences.
# A regular expression cuts viciously the text into sentences, 
# and then a list of rules (some of them consist of a list of abbreviations)
# is applied on the marked text in order to fix end-of-sentence markings on 
# places which are not indeed end-of-sentence.
#------------------------------------------------------------------------------
sub get_sentences {
	my ($text)=@_;
	return [] unless defined $text;

	my $marked_text = first_sentence_breaking($text);
	my @sentences = split(/$EOS/,$marked_text);
	my $cleaned_sentences = clean_sentences(\@sentences);
	return $cleaned_sentences;
}

#------------------------------------------------------------------------------
# get_EOS - get the value of the $EOS (end-of-sentence mark).
#------------------------------------------------------------------------------
sub get_EOS {
	return $EOS;
}

#------------------------------------------------------------------------------
# set_EOS - set the value of the $EOS (end-of-sentence mark).
#------------------------------------------------------------------------------
sub set_EOS {
	my ($new_EOS) = @_;
	if (not defined $new_EOS) {
		cluck "Won't set \$EOS to undefined value!\n";
		return $EOS;
	}
	return $EOS = $new_EOS;
}

#==============================================================================
#
# Private methods
#
#==============================================================================

sub clean_sentences {
	my ($sentences) = @_;
		my $cleaned_sentences;
		foreach my $s (@$sentences) {
			next if not defined $s;
			next if $s!~m/\w+/;
			$s=~s/^\s*//;
			$s=~s/\s*$//;
##			$s=~s/\s+/ /g;
			push @$cleaned_sentences,$s;
		}
	return $cleaned_sentences;
}

sub first_sentence_breaking {
	my ($text) = @_;
	$text=~s/\n\s*\n/$EOS/gs;	## double new-line means a different sentence.
	$text=~s/($PAP\s)/$1$EOS/gs;
	$text=~s/(\s\w$P)/$1$EOS/gs; # breake also when single letter comes before punc.
	return $text;
}

#==============================================================================
#
# Return TRUE
#
#==============================================================================

1;
