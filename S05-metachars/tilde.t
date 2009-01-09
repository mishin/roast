use v6;
use Test;

plan 7;

# L<S05/New metacharacters/"The ~ operator is a helper for matching
# nested subrules with a specific terminator">

regex t1 {
    '(' ~ ')' 'ab'
}

ok 'c(ab)d' ~~ m/<t1>/, 'Can work with ~ and constant atoms (match)';
ok 'ab)d'  !~~ m/<t1>/, '~ and constant atoms (missing opening bracket)';
ok '(a)d'  !~~ m/<t1>/, '~ and constant atoms (wrong content)';
# this shouldn't throw an exception. See here:
# http://irclog.perlgeek.de/perl6/2009-01-08#i_816425
#?rakudo skip 'should not throw exceptions'
ok 'x(ab'  !~~ m/<t1>/,  '~ and constant atoms (missing closing bracket)';

#?rakudo skip 'parse errors'
{
    regex recursive {
        '(' ~ ')' [ 'a'* <recursive>* ]
    };

    ok '()'     ~~ m/<recursive>/, 'Can match "()" with tilde generator';
    ok '(a)'    ~~ m/<recursive>/, 'Can match "(a)" with tilde generator';
    ok '(aa)'   ~~ m/<recursive>/, 'Can match "(aa)" with tilde generator';
}
