#!/usr/bin/perl -w
use strict;
use warnings;
use Data::Dump qw/pp/;

my $colorize = 1;
my %extension = %{extensions()};
my $colmax;
eval{
   my $terminal = q|/dev/pts/1|;
   $colmax = `stty -a <"$terminal" | grep -Po '(?<=columns )\\d+'`;
};
$colmax ||= 100;

my $target = '.';
my $lists;

foreach (@ARGV){
  if ($_ eq '--demo'){ 
    my @files = sort keys %extension;
    push @files, "[default]";
    $lists = { dirs => [qw/dir1 dir2 dir2/], files => [@files[2..scalar @files]]};
  } elsif ($_ =~ m/(--nocolor|-bw)/i) {
    $colorize = 0;
  } elsif ($_ =~ m/(--width|-w)=(\d+)/i){
    $colmax = $2;
  } elsif ($_ =~ m/(--help|-h|\?)/i){
    print "usage:\n  dev-icons.plx [target] [options]\n"
        . " default [target] is current directory\n\nOptions:\n"
        . " --help, -h, ? : display this info\n"
        . " --demo : print a list of all current extensions\n"
        . " -w=[number], --width=[number] : set screen width (default 100)\n"
        . " -bw, --nocolor : turn off colorization (default is on)\n";
  } elsif ($_ !~ /-/){
    $target = $_;
  }
}

$lists ||= build_lists($target || '.');

my @dlist = @{ $lists->{dirs}  };
my @flist = @{ $lists->{files} };

my $maxlen = 10;
map {$maxlen = length $_ if length $_ > $maxlen} (@dlist,@flist);

# hard limit at half colmax, else add 5
$maxlen = ($maxlen > $colmax/2) ? $colmax/2 : $maxlen + 5;
my @result;
my $line = '';
my $col = 0;
my $d = scalar @dlist + 1;
@dlist = (@dlist,@flist);
foreach (@dlist){
  $d-- if $d; # is directory?
  my $cell = devicons_format($_,$d);

  $line .= $cell;
  $col++;
  if ($col >= int($colmax/$maxlen)){
    $col = 0;
    $line =~ s/\s+$//;  # trim
    push @result, $line; 
    $line = '';
    next;
  }
}
push @result, '';
printf join "\n", @result;

sub build_lists     {
  my $target = shift;

  opendir(DIR, $target) || die "Unable to access $target: $!";
  my @d_ls = grep {(!/^\.\.?$/) and -d "$target/$_"} readdir(DIR);
  rewinddir  DIR;
  my @f_ls = grep {(!/^\.\.?$/) and -f "$target/$_"} readdir(DIR);
  closedir DIR;

  return {dirs => \@d_ls, files => \@f_ls};


 }
sub devicons_format {
  my ($name, $dir) = @_;
  return '' unless $name;
  $name =~ m/([^\.]*)$/;
  my $ext = $extension{$1} 
         || $extension{uc $1} 
         || $extension{'.default'};
  $ext = $extension{'.dir'} if $dir;

  $name = substr($name, 0, $maxlen-8) . "..." if length $name > $maxlen - 1;
  $name = "$ext->{symbol} $name";
  my $pad = " " x ($maxlen - length $name);
  $name = "$ext->{color}$name\x1b[0m" if $colorize;
  
  return "$name$pad";


 }
sub extensions      {
  my %color = (
    '.default' => 248,
    archive    => 2,
    audio      => 136,
    config     => 9,
    data       => 13,
    diff       => 8,
    disk       => 1,
    err        => 196,
    font       => 108,
    game       => 177,
    image      => 5,
    image_v    => 10,
    install    => 255,
    key        => 15,
    lock       => 248,
    markup     => 11,
    props      => 6,
    script     => 130,
    sheet      => 148,
    src        => 4,
    src_py     => 36,
    src_perl   => 1,
    sql        => 223,
    style      => 161,
    txt        => 7,
    txt_doc    => 12,
    txt_note   => 3,
    txt_slide  => 166,
    video      => 10,
    x          => 240,
  );

  my %category = (
    archive   => { symbol => '', set => [qw/7z a arj bz bz2 gz lrz lz lzm lzo rar s7z tar xz zip zipx zoo zpaq zz/]},
    archive_p => { symbol => '', set => [qw/apk bsp cab deb jar jad pak pk3 rpm vdf vpk/]},
    audio     => { symbol => '', set => [qw/aac aiff alac ape cda dat fcm flac m4a mid midi mod mp3 sid mp4a wav wma wv wvc/]},
    config    => { symbol => '', set => [qw/cfg conf ini Makefile MANIFEST pcf rc viminfo/]},
    data      => { symbol => '', set => [qw/accdb accde accdr accdt dump db fmp12 fp7 localstorage mdb mde nc sqlite/]},
    diff      => { symbol => '', set => [qw/diff patch/]},
    disk      => { symbol => '', set => [qw/bin dmg iso nrg qcow sparseimage toast vcd vmdk/]},
    err       => { symbol => '', set => [qw/deny err error stderr/]},
    font      => { symbol => '', set => [qw/afm fon fnt otf PFA pfb pfm ttf/]},
    game      => { symbol => '', set => [qw/32x a00 a52 a64 a78 adf atr fm2 cdi gb gba gbc gel gg ggl j64 nds nes rom sav sms st/]},
    image     => { symbol => '', set => [qw/bmp gif ico jpg jpeg nth png psb psd tif tiff ts/]},
    image_v   => { symbol => '', set => [qw/ai eps epsf/]},
    key       => { symbol => '', set => [qw/asc bfe enc gpg pem p12 sig signature/]},
    lock      => { symbol => '', set => [qw/lock lockfile pid state/]},
    markup    => { symbol => '', set => [qw/eml hbs htm html jhtm mustache mht slim twig tt tt2 ejs/]},
    props     => { symbol => '', set => [qw/cue description directory json properties rdata rss srt theme torrent urlview xml yml/]},
    script    => { symbol => '', set => [qw/awk bash bat fish sed sh vim zsh/]},
    sheet     => { symbol => '', set => [qw/csv ods xla xls xlsm xlsx xltm xltx/]},
    src       => { symbol => '', set => [qw/d dart go java jl php rb rs scala/]},
    src_c     => { symbol => '', set => [qw/c c++ cpp cxx H h++ hpp hxx M tcc/]},
    src_cljr  => { symbol => '', set => [qw/clj cljc cljs edn/]},
    src_erl   => { symbol => '', set => [qw/erl hrl/]},
    src_f     => { symbol => '', set => [qw/fs fsi fsscript fsx/]},
    src_hkl   => { symbol => '', set => [qw/hs lhs/]},
    src_js    => { symbol => '', set => [qw/coffee js jsm jsp jsx/]},
    src_ms    => { symbol => '', set => [qw/cc cp cs sln suo/]},
    src_lisp  => { symbol => 'λ', set => [qw/cl lisp ml mli/]},
    src_py    => { symbol => '', set => [qw/py pyc pyd pyo/]},
    src_perl  => { symbol => '', set => [qw/PL pl plx pm/]},
    sql       => { symbol => '', set => [qw/msql mysql pgsql rlib sql/]},
    style     => { symbol => '', set => [qw/css less sass scss styl/]},
    txt       => { symbol => '', set => [qw/etx info markdown md mkd nfo t txt/]},
    txt_doc   => { symbol => '', set => [qw/doc docm docx odb odt pdf rtf/]},
    txt_note  => { symbol => '', set => [qw/AUTHORS CHANGES CONTRIBUTORS COPYRIGHT HISTORY INSTALL LICENCE log note NOTICE PATENTS README VERSION/]},
    txt_slide => { symbol => '', set => [qw/pps ppt ppts pptsm pptx pptxm/]},
    video     => { symbol => '', set => [qw/asf asm avi divx flv m2v m4v mkv mov mp4/]},
    x_backup  => { symbol => '', set => [qw/bak BUP old orig un~/]},
    x_docker  => { symbol => '', set => [qw/Dockerfile dockerignore/]},
    x_apple   => { symbol => '', set => [qw/CFUserTextEncoding DS_store localized/]},
    x_git     => { symbol => '', set => [qw/git gitattributes gitmodules gitignore/]},
  );

  my %extension = (
    '.default'    => { symbol => '', color => "\x1b[38;5;$color{'.default'}m",},
    '.dir'        => { symbol => '', color => "\x1b[38;5;14m", },
    ai            => { symbol => '' },
    cljs          => { symbol => '' },
    d             => { symbol => '' },
    Dockerfile    => { color  => 190 },
    edn           => { symbol => '' },
    git           => { color  => 125 },
    go            => { symbol => '' },
    hbs           => { symbol => '' },
    java          => { symbol => '' },
    jl            => { symbol => '' },
    jsx           => { symbol => '' },  
    mustache      => { symbol => '' },
    Makefile      => { color  => 190 },
    pgsql         => { symbol => '' },
    php           => { symbol => '' },
    psb           => { symbol => '' },
    psd           => { symbol => '' },
    rb            => { symbol => '' },
    rlib          => { symbol => '' },
    rs            => { symbol => '' },
    rss           => { symbol => '' },
    sass          => { symbol => '' },
    scala         => { symbol => '' },
    scss          => { symbol => '' },
    styl          => { symbol => '' },
    ts            => { symbol => '' },
    twig          => { symbol => '' },
    vim           => { symbol => '' },
  );

  foreach my $cat (keys %category){
    my $color = $color{$cat} 
             || $color{(split '_', $cat)[0]}
             || $color{'.default'};

    foreach ( @{$category{$cat}{set}} ){
      $extension{$_}{symbol} ||= $category{$cat}{symbol};
      $extension{$_}{color}  ||= $color;

      next if $extension{$_}{color} =~ /[^\d]/;

      # condition for 8 / black = background 200 / magenta
      $extension{$_}{color}  = ($extension{$_}{color} != 8) 
        ? "\x1b[38;5;$extension{$_}{color}m"
        : "\x1b[48;5;200m";
    }
  }

  return \%extension;
 }
1;
