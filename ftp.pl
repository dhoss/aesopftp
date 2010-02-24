#!/usr/bin/perl
# ftp.pl
# simple interface to Net::FTP
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
"\nCommands are: \nls\npwd\ncd \(cd REMOTEPATH\)\nget \(get REMOTEFILE\)\nput \(put LOCALFILE\)\nquit\ndelete \(delete REMOTEFILE\)\nmkdir \(mkdir DIRNAME\)\nrmdir \(rmdir DIRNAME\)\n\n";
        next;
    }
    elsif ( $command eq "delete" ) {
        $ftp->delete($arg) or print "\nFile $arg not found\n\n" and next;
        print "\nFile $arg deleted\n\n";
        next;
    }
    elsif ( $command eq "mkdir" ) {
        $ftp->mkdir($arg)
          or print "\nDirectory $arg could not be made\n\n" and next;
        print "\nDirectory $arg created\n\n";
        next;
    }
    elsif ( $command eq "rmdir" ) {
        print
"\nRemoving directory $arg will delete all files and directories contained within, continue? \(y/n\)\n\n";
        my $ans =;
        chomp $ans;
        if ( $ans eq "y" ) {
            $ftp->rmdir( $arg, 1 )
              or print "\nDirectory $arg could not be removed\n\n" and next;
        }
        else {
            print "\nDirectory removal canceled\n\n" and next;
        }
        print "\nDirectory $arg removed\n\n";
        next;
    }
    elsif ( $command eq "put" ) {
        $ftp->put($arg) or print "\nFile $arg not found\n\n" and next;
        print "\nFile transfer complete\n";
        print "\nSent file $arg\n\n";
        next;
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
        print "\nClosing session\n";
        $ftp->close;
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
        next;
    }
    else {
        print "\nI didnt understand that\n\n";
        next;
    }
}
