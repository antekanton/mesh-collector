#!/usr/bin/perl
use strict;
use warnings;
use utf8;
use constant MQTT => 1;
my $prt = 3303;
my $interface = 'eth0';
my $recvr = '192.168.188.114';
my $key16 = '1PG7OiApB1nwvP+rz05pAQ==';
#my $key32 = 'Nmh7EooP2Tsc+7pvPwXLcEDDuYhk+fBo2GLnbA1Y1sg=';
my $protobufPath = 'protobufs';
################################################


use IO::Socket::INET;
use IO::Socket::Multicast;
use Crypt::OpenSSL::AES;
use MIME::Base64;
use Google::ProtocolBuffers::Dynamic;
use DBI;

our %portnums;
binmode STDOUT, ':encoding(UTF-8)';
#require './constants.pl';
my $bcast = 0xffffffff;
use constant DESTINATION => '224.0.0.69:4403';

my $dbh = DBI->connect("dbi:mysql:dbname=meshrouter:192.168.188.16", "meshrouter","meshtastic",{ RaiseError => 1})
  or die $DBI::errstr;

my $dynamic = Google::ProtocolBuffers::Dynamic->new($protobufPath);
$dynamic->load_file('mesh.proto');
$dynamic->map({ package => 'meshtastic', prefix => 'Meshtastic' });

# Create a new UDP socket
my $s = IO::Socket::INET->new(LocalPort=>$prt, Proto => 'udp', LocalAddr => '0.0.0.0') or die "ERROR creating socket : $!\n";
#my $m = IO::Socket::Multicast->new(LocalPort=>$port) or die "ERROR creating socket : $!\n";
my $m = IO::Socket::Multicast->new(Proto=>'udp',PeerAddr=>DESTINATION) or die "ERROR creating socket : $!\n";
#$m->mcast_add($address,$interface);
#$m->mcast_ttl(1);
#$m->mcast_loopback(0);

my @recent;
my ($datagram,$flags);
while (1) {
  $s->recv($datagram,512,$flags);
#print "Received datagram from ", $s->peerhost, ", flags ", $flags || "none", ":" . "\n";
  next unless ($s->peerhost eq $recvr);

#print unpack("H*", $datagram);
#print "\n";
  my $packet;
  eval{$packet = Meshtastic::MeshPacket->decode($datagram);};
  my $src = $packet->get_from;
  my $dst = $packet->get_to;
  my $chHash = $packet->get_channel;
  my $encrypted = $packet->get_encrypted;
  my $id = $packet->get_id;
#  my $rx_time = $packet->get_rx_time;
  my $snr = $packet->get_rx_snr;
  my $hopLimit = $packet->get_hop_limit;
  # $want_ack
#  my $priority = $packet->get_priority;
  my $rssi = $packet->get_rx_rssi;
  my $isMQTT = $packet->get_via_mqtt || 0;
  my $hopStart = $packet->get_hop_start;
  # $public_key
#  my $pki_encrypted = $packet->get_pki_encrypted;
  my $nextHop  = $packet->get_next_hop;
  my $relayNode = $packet->get_relay_node;
#  my $transport = $packet->get_transport_mechanism;

  my $old;
  foreach my $e (@recent){
    if ($e == $id){
     $old = 1;
     last;
    }
  }
  if (not $old){
    push (@recent, $id);
    my $sz = @recent;
    if ($sz > 100){
      shift @recent;
    }
  }

  my $isTX = 0;
  if ($rssi > -50 and $relayNode == 0x10){ $isTX = 1 };
  my $ttl = 0;
  if ((defined $hopStart)and(defined $hopLimit)){
    $ttl = $hopStart - $hopLimit;
  }

   my $nonce = pack("Q<",$id) . pack("Q<",$src);
   my $cipher = Crypt::OpenSSL::AES->new(decode_base64($key16),{cipher  => 'AES-128-CTR', iv => $nonce});
   my $decrypted = $cipher->decrypt($encrypted);

   my $portNum = 0;
   my $payload;
   eval{ my $data = Meshtastic::Data->decode($decrypted);
     $portNum = $data->get_portnum;
     $payload = $data->get_payload;
   };
#   if (defined $portnum){print " $portnums{$portnum}";};
   my $pSize = length $datagram;
   my $ts = time;
   $dbh->do("insert into meshrouter.packets (dbtime, id, src, dst, chHash, hopLimit, hopStart, nextHop, relayNode,
	rssi, snr, portNum, isTX, pSize, isMQTT) values (from_unixtime($ts), $id, $src, $dst, $chHash, $hopLimit, $hopStart,
	$nextHop, $relayNode, $rssi, $snr, $portNum, $isTX, $pSize, $isMQTT);");
   if (not $isMQTT){
   if (not $old){
     if (defined $chHash and $chHash == 0 and $dst != 4294967295){
	 # encrypted LOCAL_ONLY i.e. direct messages
	 $m->send($datagram);
       }elsif ($portNum == 1){
	 textMsg($src, $payload, $datagram, $id, $dst);
       }elsif ($portNum == 3){
	 position($src, $payload);
       }elsif ($portNum == 4){
  	 nodeInfo($src, $payload);
       }elsif ($portNum == 5){
	 $m->send($datagram); #routing app
       }
     }
     if ($portNum == 70){TraceRoute($src, $dst, $payload, $rssi, $snr, $id)};
   }
   if ($ttl==0){
     $dbh->do("insert into meshrouter.neighbours (dbtime,src,rssi,snr) values (from_unixtime($ts),$src,$rssi,$snr);");
     $dbh->do("UPDATE meshrouter.info SET lastHeard = from_unixtime($ts) WHERE id = $src;");
   }
}
$s->close();
$dbh->disconnect;

sub textMsg{
    my $src = shift;
    my $p = shift;
    my $pkt = shift;
    my $id = shift;
    my $dst = shift;
    $m->send($pkt);
  my $ts = time;
  my $sth = $dbh->prepare("insert into meshrouter.chat (dbtime, id, src, dst, message) values (from_unixtime(?),?,?,?,?);");
  $sth->execute($ts,$id,$src,$dst,$p);
}

sub TraceRoute{
    my $src = shift;
    my $dst = shift;
    my $p = shift;
    my $rssi = shift;
    my $snr = shift;
    my $id = shift;
    my $route;
    eval{$route = Meshtastic::RouteDiscovery->decode($p);};
    my $Fsz = $route->route_size;
    my $Bsz = $route->route_back_size;
    my $Fsnr = $route->snr_towards_size;
    my $ts = time;
    if ($Fsz){
       # update neighbour rssi/snr
       my $LastHost;
       if ($Bsz){
         $LastHost = $route->get_route_back($Bsz-1);
       }else{
         $LastHost = $route->get_route($Fsz-1);
       }
       unless ($LastHost == 4294967295) { # !ffffffff broadcast
         $dbh->do("insert into meshrouter.neighbours (dbtime,src,rssi,snr) values (from_unixtime($ts),$LastHost,$rssi,$snr);");
	 $dbh->do("UPDATE meshrouter.info SET lastHeard = from_unixtime($ts) WHERE id = $LastHost;");
       }
    }
    my $last;
    if ($Bsz){ #if reverse route
        $last = $dst;
    }else{
	$last = $src;
    }
    if ($Fsz){
      for my $i (0..$Fsnr-1){
        my $next;
        if ($i<$Fsz){
          $next = $route->get_route($i);
        }else{# last forward hop
          if ($Bsz){ #if reverse route
            $next = $src;
          }else{
            $next = $dst;
          }
        };
        my $snr = $route->get_snr_towards($i)/4;
	my ($r) = $dbh->selectrow_array("SELECT dbtime FROM meshrouter.traces WHERE id = $id AND src = $last AND dst = $next;");
	unless (defined $r){
          $dbh->do("insert into meshrouter.traces (id, dbtime, src, dst, snr)
	  values ($id, from_unixtime($ts),$last, $next, $snr);");
        }
        $last = $next;
      }
    }
    if ($Bsz){
      for my $i (0..$Bsz-1){
        my $next = $route->get_route_back($i);
        my $snr = $route->get_snr_back($i)/4;
	unless ($last == $next){
	  my ($r) = $dbh->selectrow_array("SELECT dbtime FROM meshrouter.traces WHERE id = $id AND src = $last AND dst = $next;");
	  unless (defined $r){
            $dbh->do("insert into meshrouter.traces (id, dbtime, src, dst, snr, is_reverse)
	       values ($id, from_unixtime($ts),$last, $next, $snr, 1);");
    	  }
        }
        $last = $next;
      }
    }
}

sub position{
  my $src = shift;
  my $p = shift;
  my ($lat, $lon, $alt);
  my $data;
  eval{$data = Meshtastic::Position->decode($p);};
  $lat = $data->get_latitude_i;
  $lon = $data->get_longitude_i;
  $alt = $data->get_altitude;
#copy received coordinates to display coordinates
  my $d_lon = $lon;
  my $d_lat = $lat;

#limit coordinates to bbox
  if ($d_lat < 545000000){$d_lat = 545000000};
  if ($d_lat > 554000000){$d_lat = 554000000};
  if ($d_lon < 820000000){$d_lon = 820000000};
  if ($d_lon > 839000000){$d_lon = 839000000};

#add jitter to spread same coordinate nodes
  $d_lon += int(rand(2000)) - 1000;
  $d_lat += int(rand(1000)) - 500;

  my $ts = time;
  unless ($lat == 0 or $lon == 0){
    my $sth = $dbh->prepare("INSERT INTO meshrouter.info (id, longitude, latitude, altitude, lastHeard) VALUES (?, ?, ?, ?, from_unixtime(?))
     ON DUPLICATE KEY UPDATE longitude = ?, latitude = ?, altitude = ?, lastHeard = from_unixtime(?);");
    $sth->execute($src, $lon, $lat, $alt, $ts, $lon, $lat, $alt, $ts);

    my ($f) = $dbh->selectrow_array("SELECT isFixedPos FROM meshrouter.info WHERE id = $src;");
    unless ($f){
      $dbh->do("UPDATE meshrouter.info SET disp_lat = $d_lat, disp_lon = $d_lon WHERE id = $src ;");
    }
  }
}

sub nodeInfo{
  my $src = shift;
  my $p = shift;
  my ($lname, $sname, $role);
  my $data;
  eval{$data = Meshtastic::User->decode($p);};
  $lname = $data->get_long_name;
  $sname = $data->get_short_name;
  $role = $data->get_role;
  my $ts = time;
  my $sth = $dbh->prepare("INSERT INTO info (id, lname, sname, lastHeard, role) VALUES (?, ?, ?, from_unixtime(?), ?)
     ON DUPLICATE KEY UPDATE lname = ?, sname = ?, lastHeard = from_unixtime(?), role = ?;");
  $sth->execute($src, $lname, $sname, $ts, $role, $lname, $sname, $ts, $role);
}

sub chHash {
  my ($string) = @_;
  my $v = 2;
  $v ^= $_ for unpack 'C*', $string;
  return $v;
}
