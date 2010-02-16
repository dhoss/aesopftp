#!/usr/bin/perl
# ftp.pl
use strict;
use Net::FTP;

unless (@ARGV) {
    print "\nUsage: ftp.pl SERVER USERNAME PASSWORD\n";
    exit;
}
my ( $server, $user, $pass ) = @ARGV;
my $ftp = Net::FTP->new( $server, Timeout => 10 )
  or die "Couldnt connect";
$ftp->login( $user, $pass )
  or die "Couldnt connect";
print "\nConnected successfully\n\n";
$ftp->binary;
print "For a list of commands type 'commands'\n\n";

while (1) {
    my $input = <STDIN>;
    chomp $input;
    my $arg = $input;
    $arg =~ s/^\w*\s*//;
    my @array = split( /\s/, $input );
    my $command = shift @array;

    if ( $command eq "commands" ) {
        print
"\nCommands are: \nls\npwd\ncd \(cd REMOTEPATH\)\nget \(get REMOTEFILE\)\nput \(put LOCALFILE)\nquit\n\n";
        next;
    }
    elsif ( $command eq "put" ) {
        $ftp->put($arg) or print "\nFile $arg not found\n\n" and next;
        print "\nFile transfer complete\n";
        print "\nSent file $arg\n\n";
    }
    elsif ( $command eq "get" ) {
        $ftp->get($arg) or print "\nFile $arg not found\n\n" and next;
        print "\nFile transfer complete\n";
        print "\n$arg received\n\n";
        next;
    }
    elsif ( $command eq "cd" ) {
        $ftp->cwd($arg) or print "\n$arg is not a valid directory\n\n" and next;
        print "\nDirectory changed to: ", $ftp->pwd(), "\n\n";
        next;
    }
    elsif ( $command eq "quit" ) {
        if ($ftp) {
            print "\nClosing session\n";
            $ftp->close;
        }
        last;
    }
    elsif ( $command eq "pwd" ) {
        print "\nCurrent working directory: ", $ftp->pwd(), "\n\n";
        next;
    }
    elsif ( $command eq "ls" ) {
        my @list = $ftp->ls();
        print "\nContents of ", $ftp->pwd(), ":\n";
        foreach (@list) {
            print $_, "\n";
        }
        print "\n";
    }
    else {
        print "\nI didnt understand that\n\n";
        next;
    }
    next;
}
