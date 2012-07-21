#!/usr/bin/perl
use strict;
use warnings;

use File::Basename;
use File::Spec;
use MIME::Base64;
use JSON::Syck;

my $BINDIR  = File::Spec->rel2abs( dirname __FILE__ );
my $ROOTDIR = sprintf '%s/..', $BINDIR;
my $IMGDIR = {
  bl => sprintf( '%s/img/bl', $ROOTDIR ),
  bg => sprintf( '%s/img/bg', $ROOTDIR ),
  it => sprintf( '%s/img/it', $ROOTDIR ),
  lf => sprintf( '%s/img/lf', $ROOTDIR ),
};

my $data = {};
my $jsonfile = sprintf '%s/imgs.json', $BINDIR;

# 各画像をBase64エンコードする
for my $d ( keys %$IMGDIR ) {
  opendir my $dir, $IMGDIR->{$d};
  my @imgs = sort grep $_ !~ m{^\.}, readdir $dir;
  closedir $dir;

  for my $f ( @imgs ) {
    my ( $type, $name ) = ( $f =~ m{^ ([^\.]+) \. (.*) \.png $}x );
    my $base64ed;

    my $imgfile = sprintf '%s/%s', $IMGDIR->{$d}, $f;
    open( my $fh, '<', $imgfile ) ||  die $!;
    {
      local $/;
      ( $base64ed = encode_base64( <$fh> ) ) =~ s{\x0d\x0a?|\x0a}{}g;
    }
    close $fh;

    my $keyname = sprintf '%s-%s-%s', $d, $type, $name;
    $data->{$keyname} = sprintf 'data:image/png;base64,%s', $base64ed;
  }
}

# $data ハッシュを json 化してファイルに書き出す
open my $fh, '>', $jsonfile;
print $fh JSON::Syck::Dump( $data ), "\n";
close $fh;

__END__
