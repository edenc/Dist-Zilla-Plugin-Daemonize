use strict;
use warnings;
use FindBin;
use Test::More;
use Test::DZil;
use Daemon::Control;

my $dist         = qq{$FindBin::Bin/../corpus/DZT};
my $stderr_fname = "$dist/stderr";
unlink $stderr_fname;
my $dc_args = {
  name        => 'dzt test',
  program     => 'script/dzt.pl',
  directory   => $dist,
  pid_file    => "$dist/pid",
  stderr_file => $stderr_fname
};
my $tzil = Builder->from_config(
  { dist_root => 'corpus/DZT' },
  { add_files => {
      'source/dist.ini' =>
        simple_ini( {}, 'TestRelease', [ Daemonize => $dc_args, ], ),
    },
  },
);

{
  local $ENV{AUTOMATED_TESTING} = 1;
  $tzil->build;
}

my $stderr = do { local ( @ARGV, $/ ) = $stderr_fname; <> };
like( $stderr, qr/dzt STDERR OK/, "STDERR OK" );

Daemon::Control->new($dc_args)->do_stop;

done_testing;
