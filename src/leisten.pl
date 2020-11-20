#!/usr/bin/perl

use strict;
use warnings;

use feature 'say';

use Data::Printer;
use List::Util qw/sum/;
use Math;

my $i_roh_laenge = 2500;
my $i_fuge = 3;

my $hr_parts = {
    1760 => 3,
    1720 => 2,
    1080 => 4,
    1190 => 2,
    1050 => 1,
    800 => 2,
    766 => 9,
    712 => 1,
    640 => 4,
    346 => 1,
    256 => 4,
    300 => 3,
};

sub prepare_parts {
    my $hr_parts = shift;
    foreach my $k (keys %{$hr_parts}) {
        $hr_parts->{$k} = {
            free => $hr_parts->{$k},
            test => 0,
            used => 0,
        }
    }
    return;
}

sub move_part {
    my $hr_parts = shift || die "no move parts given";
    my $i_laenge = (shift) + 0 || die "no move part laenge given";
    my $s_type_from = shift || die "no move part type from given";
    my $s_type_to = shift || die "no move part type to given";

    die "unknown part length" if ! $hr_parts->{$i_laenge};
    die "unknown from type" if not defined $hr_parts->{$i_laenge}->{$s_type_from};
    die "unknown to type" if not defined $hr_parts->{$i_laenge}->{$s_type_to};

    return if $hr_parts->{$i_laenge}->{$s_type_from} < 1;

    $hr_parts->{$i_laenge}->{$s_type_from}--;
    $hr_parts->{$i_laenge}->{$s_type_to}++;

    return 1;
}


sub gesamtlaenge {
    my $hr_parts = shift || die "no parts given";
    my $s_type = shift || die "no type given";

    my $l = 0;
    $l += $_ * ($hr_parts->{$_}->{$s_type} // 0) foreach keys %{$hr_parts};

    return $l;
}

sub i_get_rest {
    return $i_roh_laenge if ! scalar @{$_[0]};

    return $i_roh_laenge - (sum(@{$_[0]})//0) - $i_fuge * (scalar @{$_[0]}-1);
}

sub a_get_candidates {
    my $hr_parts = shift || die "no parts given";
    my $i_rest = shift;

    return
        reverse sort { $a <=> $b }
        grep {
            $_ <= $i_rest-$i_fuge
            && $hr_parts->{$_}->{free} > 0
        }
        keys %{$hr_parts};
}

sub a_get_set {
    my $hr_parts = shift || die "no parts given";
    my $i_depth = shift || 0;
    my @a_set = @_;

    my $i_rest = i_get_rest(\@a_set);
    return @a_set if !$i_rest;

    my @a_candidates = a_get_candidates($hr_parts, $i_rest);
    return @a_set if ! scalar @a_candidates;

    my @a_best_set = @a_set;
    foreach my $i_candidate (@a_candidates) {

        move_part($hr_parts, $i_candidate, "free", "test");
        my @a_cur_set = a_get_set($hr_parts,$i_depth+1, @a_set, $i_candidate);
        move_part($hr_parts, $i_candidate, "test", "free");

        if (i_get_rest(\@a_cur_set) < i_get_rest(\@a_best_set)) {
            @a_best_set = @a_cur_set;
            return @a_best_set if !i_get_rest(\@a_cur_set);
        }
    }

    return @a_best_set;
}


prepare_parts($hr_parts);

my $i_laenge_used = gesamtlaenge($hr_parts, "used");
my $i_laenge_test = gesamtlaenge($hr_parts, "test");
my $i_laenge_free = gesamtlaenge($hr_parts, "free");

my $i_gesamt_laenge = $i_laenge_used + $i_laenge_test + $i_laenge_free;

say "Länge verteilt: ".$i_laenge_used. " mm";
say "Länge im test: ".$i_laenge_test. " mm";
say "Länge unverteilt: ".$i_laenge_free. " mm";
say "Gesamtlänge: ".$i_gesamt_laenge. " mm";
say "Rohleistenlänge: ".$i_roh_laenge. " mm";
say "Mindestpartsanzahl: ".Math::ceil($i_gesamt_laenge / $i_roh_laenge);
say '';

my $ar_results = [];
my @a = ();
my $i = 0;
my $i_summe_rest = 0;
my $i_rest = 0;

# @a = a_get_set($hr_parts);
# if (scalar @a) {
#     $i_rest = i_get_rest([ @a ] );
#     $i_summe_rest+=$i_rest;
#     say sprintf('%2d. Leiste: Verschnitt: %4d mm, Fugen: %d x %d mm', ++$i, $i_rest, scalar @a-1, $i_fuge).": [ ".join(', ', map { sprintf("%4d", $_).' mm' } @a). " ]";
#     move_part($hr_parts, $_, "free", "used") for @a;
#     push @$ar_results, [ @a ];
# }
# else {
#     say 'keine Verarbeitung möglich';
# }

while (gesamtlaenge($hr_parts, "free")) {
    @a = a_get_set($hr_parts);
    if (! scalar @a) {
        say 'keine Verarbeitung möglich';
        last;
    };
    $i_rest = i_get_rest([ @a ] );
    $i_summe_rest+=$i_rest;
    say sprintf('%2d. Leiste: Verschnitt: %4d mm, Fugen: %d x %d mm', ++$i, $i_rest, scalar @a-1, $i_fuge).": [ ".join(', ', map { sprintf("%4d", $_).' mm' } @a). " ]";
    move_part($hr_parts, $_, "free", "used") for @a;
    push @$ar_results, [ @a ];
}

say '';
$i_laenge_used = gesamtlaenge($hr_parts, "used");
$i_laenge_test = gesamtlaenge($hr_parts, "test");
$i_laenge_free = gesamtlaenge($hr_parts, "free");
$i_gesamt_laenge = $i_laenge_used + $i_laenge_test + $i_laenge_free;
say "Länge verteilt: ".$i_laenge_used. " mm";
say "Länge im test: ".$i_laenge_test. " mm";
say "Länge unverteilt: ".$i_laenge_free. " mm";
say "Länge Verschnitt: ".$i_summe_rest. " mm";
say "Gesamtlänge: ".$i_gesamt_laenge. " mm";

#p $ar_results;