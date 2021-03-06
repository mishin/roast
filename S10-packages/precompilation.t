use Test;
use lib 't/spec/packages';
use Test::Util;

plan 17;

my @precomp-paths;

for <C A B> {
    my $path = "t/spec/packages/Example/{$_}.pm";
    my $precomp-path = $path ~ '.' ~ $*VM.precomp-ext;
    unlink $precomp-path if $precomp-path.IO.e;
    ok CompUnit.new($path).precomp, "precomp Example::$_";
    ok $precomp-path.IO.e, "created $precomp-path";
    @precomp-paths.push: $precomp-path;
}

my @keys = Test::Util::run( q:to"--END--").lines;
    use lib 't/spec/packages';
    use Example::A;
    use Example::B;

    .say for Example::.keys.sort;
    --END--

#?rakudo.jvm todo 'RT #122773'
is_deeply @keys, [<A B C>], 'Diamond relationship';

#?rakudo.jvm todo 'RT #122896'
#?rakudo.moar todo 'RT #122896'
is_run 'use lib "t/spec/packages"; use Example::C; f();', { err => '', out => '', status => 0 }, 'precompile exported cached sub';

unlink $_ for @precomp-paths;

# RT #76456
{
    my $cur  = CompUnitRepo::Local::File.new("t/spec/packages");

    my ($cu) = $cur.candidates('RT76456');
    ok $cu.precomp(:force), 'precompiled a parameterized role';
    unlink $cu.precomp-path if $cu.precomp-path.IO.e;
}

#RT #122447
{
    # also a test of precompilation from the command line
    my $module-name = 'RT122447';
    my $output-path = "t/spec/packages/" ~ $module-name ~ '.pm.' ~ $*VM.precomp-ext;
    unlink $output-path if $output-path.IO.e;
    is_run 'sub foo($bar) { Proxy.new( FETCH => sub (|) { }, STORE => sub (|) { } ) }', { err => '', out => '', status => 0 }, :compiler-args['--target', $*VM.precomp-target, '--output', $output-path ], 'precompile sub with params returning a proxy';

    is_run '0', { err => '', out => '', status => 0 }, :compiler-args['-I', 't/spec/packages', '-M', $module-name], 'precompile load - from the command line';
    unlink $output-path if $output-path.IO.e;
}

#RT #115240
{
    my $module-name = 'RT115240';
    my $output-path = "t/spec/packages/" ~ $module-name ~ '.pm.' ~ $*VM.precomp-ext;
    unlink $output-path if $output-path.IO.e;
    is_run 'role Foo [ ] { }; role Bar does Foo[] { }', { err => '', out => '', status => 0 }, :compiler-args['--target', $*VM.precomp-target, '--output', $output-path ], "precomp curried role compose";

    is_run "use $module-name; class C does Bar { };", { err => '', out => '', status => 0 }, :compiler-args['-I', 't/spec/packages', '-M', $module-name], 'precompile load - from the command line';
    unlink $output-path if $output-path.IO.e;
}

#RT #123276
{
    my $name = 'RT123276';

    for "{$name}", "{$name}::B::C1", "{$name}::B::C2" -> $module-name {
        my $module-dir = join '/', split('::', $module-name);
        my $path = "t/spec/packages/{$module-dir}.pm";
        my $precomp-path = $path ~ '.' ~ $*VM.precomp-ext;
        unlink $precomp-path if $precomp-path.IO.e;
        ok CompUnit.new($path).precomp(), "precomp Example::$_";
        @precomp-paths.push: $precomp-path;
    }

    my @keys = Test::Util::run( q:to"--END--").lines;
        use lib 't/spec/packages';
        use RT123276::B::C1;
        use RT123276::B::C2;
        say RT123276::B::C1.^methods
    --END--

    #?rakudo.jvm todo 'RT #123276'
    #?rakudo.moar todo 'RT #123276'
    #?rakudo.parrot todo 'RT #123276'
    is_deeply @keys, [<foo>], 'RT123276';

    unlink $_ for @precomp-paths;
}

