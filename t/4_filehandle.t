use Test::More;
use File::Spec;

BEGIN { plan tests => 2 };

use Inline Lua => 'DATA';

ok(1);

my $file = File::Spec->catfile("t", "test.out");
open FILE, ">", $file or die $!;
write_file(\*FILE, "foo", "bar", "baz");
close FILE;

my $fh = get_fh($file);
is_deeply([<$fh>], ["foo\n", "bar\n", "baz\n"]);

__END__
__Lua__
function write_file (fh, ...)
    for i = 1, table.getn(arg), 1 do
	fh:write(arg[i], "\n")
    end
end

function get_fh (file)
    return io.open(file, "r")
end
