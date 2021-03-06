use v6;

use Test;

plan 7;

# L<S04/"Conditional statements"/Conditional statement modifiers work as in Perl 5>

# test the ``given'' statement modifier
{
    my $a = 0;
    $a = $_ given 2 * 3;
    is($a, 6, "post given");
}

# test the ``given'' statement modifier
{
    my $a;
    $a = $_ given 2 * 3;
    is($a, 6, "post given");
}

{
    my $a = '';
    $a = $_ given 'a';
    is($a, 'a', "post given");
}

# RT #121049
{
    my $a = '';
    for ^2 { my $b = $_ given 'a'; $a ~= $b; }
    is($a, 'aa', 'post given in a loop');
}

# L<S04/The C<for> statement/for and given privately temporize>
{
    my $i = 0;
    $_ = 10;
    $i += $_ given $_+3;
    is $_, 10, 'outer $_ did not get updated in lhs of given';
    is $i, 13, 'postfix given worked';
}

# RT #100746
#?rakudo.moar todo "RT #100746"
#?rakudo.jvm todo "RT #100746"
{
    $_ = 'bogus';
    my @r = gather { take "{$_}" given 'cool' }
    is @r[0], 'cool', 'given modifies the $_ that is visible to the {} interpolator';
}

# vim: ft=perl6
