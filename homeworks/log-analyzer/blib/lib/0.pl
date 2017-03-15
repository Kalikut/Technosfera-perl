use 5.010;
use strict;
use warnings;
use DDP;
use Data::Dumper;
use Encode;



my $filepath = "access.log.bz2";#$ARGV[0];
die "USAGE:\n$0 <log-file.bz2>\n"  unless $filepath;
die "File '$filepath' not found\n" unless -f $filepath;

(my $parsed_data, my $types) = parse_file($filepath);
report($parsed_data, $types);
exit;

sub parse_file {
    my $file = shift;

    # you can put your code here

    my $info = { 'total' => { 'time' => {} } };
    my $result = {};
    my $data_types = {};

    open my $fd, "-|", "bunzip2 < $file" or die "Can't open '$file': $!";
    while (my $log_line = <$fd>) {

        # you can put your code here
        # $log_line contains line from log file

        if (not $log_line =~ m/^(\S+)\s+\[(\d+\/\w+\/\d+:\d+:\d+)\S*\s+\S+\s+"[^"]*"\s+(\d*)\s+(\d*)\N*"([^"]*)"$/) { next; }

        if (not exists $data_types->{$3}) { $data_types->{$3} = undef; }
        if (not exists $info->{'total'}->{'time'}->{$2}) { $info->{'total'}->{'time'}->{$2} = undef; }

        if (not exists $info->{$1}) { $info->{$1} = {}; }
        my $ip_info = $info->{$1};
        if (not exists $ip_info->{'time'}) { $ip_info->{'time'} = {}; }
        my $ip_time = $ip_info->{'time'};
        if (not exists $ip_time->{$2}) { $ip_time->{$2} = undef; }
        if (not exists $ip_info->{'code'}) { $ip_info->{'code'} = {}; }
        my $msg_code = $ip_info->{'code'};
        if (not exists $msg_code->{$3}) { $msg_code->{$3} = []; }
        push @{$msg_code->{$3}}, $4, $5 eq '-'?1:$5;

    }
    close $fd;

    # you can put your code here

    #77.60.102.125
    
    for my $ip (keys %{$info}) {
        $result->{$ip} = {};
        my $ip_info = $info->{$ip};
        my $res_info = $result->{$ip};
        $res_info->{'time'} = scalar (keys %{$ip_info->{'time'}});
        $res_info->{'data'} = 0;
        my $info_code = $ip_info->{'code'};
        if (exists $info_code->{'200'}) {
            my $info_code_200 = $info_code->{'200'};
            for my $iter (0..@{$info_code_200}/2 - 1) { $res_info->{'data'} += $info_code_200->[2*$iter] * $info_code_200->[2*$iter+1]; }
        }
        $res_info->{'data'} /= 1024;
        $res_info->{'count'} = 0;
        $res_info->{'data_types'} = {};
        my $res_types = $res_info->{'data_types'};
        for my $code (keys %{$info_code}) {
            $res_types->{$code} = 0;
            my $info_res_code = $info_code->{$code};
            for my $iter (0..@{$info_res_code}/2 - 1) { $res_types->{$code} += $info_res_code->[2*$iter]; ++$res_info->{'count'};}
            $res_types->{$code} /= 1024;
        }
    }

    for my $type (keys %{$data_types}) { $result->{'total'}->{'data_types'}->{$type} = 0; }
    for my $ip (keys %{$result}) {
        if ($ip eq 'total') { next; }
        $result->{'total'}->{'data'} += $result->{$ip}->{'data'};
        $result->{'total'}->{'count'} += $result->{$ip}->{'count'};
        for my $type (keys %{$result->{$ip}->{'data_types'}}) { $result->{'total'}->{'data_types'}->{$type} += $result->{$ip}->{'data_types'}->{$type}; }
    }

    #p $info->{'total'};    
    #p $result->{'total'};

    return ($result, $data_types);
}

sub report {
    my $result = shift;
    my $data_types = shift;

    # you can put your code here

    print "IP\tcount\tavg\tdata";
    for my $type (sort keys %{$data_types}) { print "\tdata_$type"; }
    print "\n";
    my @arr;
    for my $ip (keys %{$result}) {
        push @arr, [($ip, $result->{$ip}->{'count'})];
        if (not defined $result->{$ip}->{'count'}) { p $result->{$ip}; }
    }
    my @sorted_arr = sort { $b->[1] <=> $a->[1] } @arr;
    for my $iter (0..10) {
        my $ip = $sorted_arr[$iter]->[0];
        my $ip_info = $result->{$ip};
        my $avg = $ip_info->{'count'}/$ip_info->{'time'};
        print sprintf "%s\t%d\t%.2f\t%d", $ip,  $ip_info->{'count'},   $avg,  $ip_info->{'data'};
        for my $type (sort keys %{$data_types}) {
            my $ret;
            if (exists $ip_info->{'data_types'}->{$type}) {
                $ret = sprintf "%d", $ip_info->{'data_types'}->{$type};
            } else {
                $ret = "0";
            }
            print "\t$ret"; }
        print "\n";
    }

}
