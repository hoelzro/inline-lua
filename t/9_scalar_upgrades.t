#!/usr/bin/env perl

use strict;
use warnings;
use Test::More tests => 2;

use Inline 'Lua';

{
    my $s = 43.5;
    scalar("$s");
    is(take_num($s), 44.5);
}

{
    my $s = 43.5;
    scalar("$s");
    is(is_large($s), 'small');
}

__END__
__Lua__
function take_num (a)
    return a+1
end

function is_large (a)
    if a > 100.5 then
        return 'large'
    else
        return 'small'
    end
end
