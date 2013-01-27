package Dist::Zilla::Plugin::Daemonize;
use Moose;
use Daemon::Control;

with 'Dist::Zilla::Role::AfterBuild';

has daemon_control => (isa => 'Daemon::Control', is => 'ro', lazy_build => 1);
has _daemonize_args => ( isa => 'HashRef', is => 'ro', required => 1 );

sub _build_daemon_control {
  return Daemon::Control->new( shift->_daemonize_args );
}

around BUILDARGS => sub {
  my $orig        = shift;
  my $class       = shift;
  my ($args)      = @_;
  my $zilla       = delete $args->{zilla};
  my $plugin_name = delete $args->{plugin_name};
  return $class->$orig(
    { zilla           => $zilla,
      plugin_name     => $plugin_name,
      _daemonize_args => $args
    }
  );
};

sub after_build {
  my ( $self, $build_root ) = @_;
  return unless $ENV{AUTOMATED_TESTING};
  my $dc = $self->daemon_control;
  $dc->do_restart;
  do {
    sleep(1);
  } until $dc->pid_running;
}

1;
