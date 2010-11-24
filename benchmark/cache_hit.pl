use strict;
use warnings;

use Benchmark qw(:all);
use Cache::LRU;
use Cache::Ref::LRU;
use Cache::Ref::Util::LRU::Array;
use Cache::Ref::Util::LRU::List;
use Tie::Cache::LRU;

my $size = 1024;
my $loop = 1000;

sub cache_iface {
    my $cache = shift;
    $cache->set(a => 1);
    my $c = 0;
    $c += $cache->get('a')
        for 1..$loop;
    $c;
}

cmpthese(-1, {
    'Cache::LRU' => sub {
        cache_iface(
            Cache::LRU->new(
                size => $size,
            ),
        );
    },
    'Cache::Ref::LRU (Array)' => sub {
        cache_iface(
            Cache::Ref::LRU->new(
                size      => $size,
                lru_class => qw(Cache::Ref::Util::LRU::Array),
            ),
        );
    },
    'Cache::Ref::LRU (List)'  => sub {
        cache_iface(
            Cache::Ref::LRU->new(
                size      => $size,
                lru_class => qw(Cache::Ref::Util::LRU::List),
            ),
        );
    },
    'Tie::Cache::LRU' => sub {
        tie my %cache, 'Tie::Cache::LRU', $size;
        $cache{a} = 1;
        my $c = 0;
        $c += $cache{a}
            for 1..$loop;
        $c;
    },
});
