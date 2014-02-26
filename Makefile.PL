use 5.006;
use ExtUtils::MakeMaker;
use Config;

use constant LUA_LIBS => 1;
use constant LUA_INC  => 2;

sub which {
    my ( $program ) = @_;

    my $path = qx(which $program 2>/dev/null);
    if($?) {
        return undef;
    }
    chomp $path;
    return $path;
}

sub has_program {
    my ( $program ) = @_;

    my $path = which($program);

    return defined($path);
}

{
    my $config_program;

    sub get_config_program {
        unless(defined $config_program) {
            if(has_program('lua-config')) {
                $config_program = 'lua-config';
            } elsif(has_program('pkg-config')) {
                system 'pkg-config lua >/dev/null 2>/dev/null'; # XXX *nix-specific
                if($?) {
                    system 'pkg-config lua5.1 >/dev/null 2>/dev/null'; # XXX *nix-specific

                    if($?) {
                        # XXX uh-oh
                    } else {
                        $config_program = 'pkg-config lua5.1';
                    }
                } else {
                    $config_program = 'pkg-config lua';
                }
            } else {
                # XXX uh-oh...
            }
        }

        return $config_program;
    }
}

sub lua_conf {
    my $config_program = get_config_program();

    my $meth = shift;
    # lua-config is Debian specific
    if ($meth == LUA_LIBS) {
        chomp (my $val = `$config_program --libs` || "-llua -llualib");
        return $val;
    }
    if ($meth == LUA_INC) {
        chomp (my $val = `$config_program --cflags` || "");
        return $val;
    }
}

sub have_lua {
    my $CC = $Config{cc};
    my %args = map { split /\s*=\s*/ } @ARGV;
    $LIBS = $args{ LIBS } || lua_conf(LUA_LIBS);
    $INC = $args{ INC } || lua_conf(LUA_INC);
    return 1 if system("$CC check.c $INC $LIBS 2>/dev/null") == 0;
    return 0;
}

##{ $share_dir_code{preamble} || '' ##}

if (! have_lua()) {
    die <<EOD;
*******************************************
Couldn't find a working Lua installation
on this matchine. This is required for
this module.

To obtain it, go to
    http://www.lua.org/download.html
*******************************************
EOD
}

WriteMakefile(
    NAME              => 'Inline::Lua',
##{ $plugin->get_default(qw(ABSTRACT AUTHOR LICENSE VERSION)) ##}
##{ $plugin->get_prereqs(1) ##}
    LIBS              => [ $LIBS ],
    DEFINE            => '',
    INC               => "-I. " . $INC,
    clean             => { FILES => "_Inline a.out" },
);
if  (eval {require ExtUtils::Constant; 1}) {
  # If you edit these definitions to change the constants used by this module,
  # you will need to use the generated const-c.inc and const-xs.inc
  # files to replace their "fallback" counterparts before distributing your
  # changes.
  my @names = (qw());
  ExtUtils::Constant::WriteConstants(
                                     NAME         => 'Inline::Lua',
                                     NAMES        => \@names,
                                     DEFAULT_TYPE => 'IV',
                                     C_FILE       => 'const-c.inc',
                                     XS_FILE      => 'const-xs.inc',
                                  );

}
else {
  use File::Copy;
  use File::Spec;
  foreach my $file ('const-c.inc', 'const-xs.inc') {
    my $fallback = File::Spec->catfile('fallback', $file);
    copy ($fallback, $file) or die "Can't copy $fallback to $file: $!";
  }
}

##{ $share_dir_code{postamble} || '' ##}
