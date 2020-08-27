#perl -i~ -CD -p encode.pl ungarn-chars.ttl
#http://stackoverflow.com/questions/27487038/get-codepoint-for-a-matched-character
my %substitutes;
while (/(<[^>]*>)/g) {
    my $orig = $1;
    my $replace = $1;
    $replace =~ s/([\x{c0}-\x{2af}\x{2018}-\x{2020}\x{fffd}])/sprintf "\\u%04X", ord $1/ge;
    $substitutes{$orig} = $replace;
}

while(($orig, $replace) = each(%substitutes)) {
    my $pos = index($_, $orig);
    substr($_, $pos, length($orig), $replace);
}
