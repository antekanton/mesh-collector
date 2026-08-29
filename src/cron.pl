#!/usr/bin/perl
use strict;
use warnings;
use DBI;

# Загрузка переменных окружения
use Env qw(
    DB_HOST DB_PORT DB_NAME DB_USER DB_PASSWORD
    MIN_DATAPOINT
);

# Установка значений по умолчанию
my $db_host = $ENV{DB_HOST} // 'mysql';
my $db_port = $ENV{DB_PORT} // 3306;
my $db_name = $ENV{DB_NAME} // 'meshcollector';
my $db_user = $ENV{DB_USER} // 'meshcollector';
my $db_password = $ENV{DB_PASSWORD} // 'meshtastic';
my $minDP = $ENV{MIN_DATAPOINT} // 64; # минимальное число датапоинтов для создания графика

my $dbh = DBI->connect(
    "dbi:MariaDB:dbname=$db_name;host=$db_host;port=$db_port",
    $db_user,
    $db_password,
    { RaiseError => 1 }
) or die $DBI::errstr;

my $sth = $dbh->prepare("SELECT distinct src FROM meshcollector.neighbours;");
$sth->execute;
while ( my ($id) = $sth->fetchrow_array()){
## delete old records
  my ($dp1) = $dbh->selectrow_array("SELECT COUNT(*) cnt FROM meshcollector.neighbours
    WHERE src = $id AND dbtime > (sysdate() - INTERVAL '7' DAY) ");
  if ($dp1 < $minDP){
    my ($dp2) = $dbh->selectrow_array("SELECT COUNT(*) cnt FROM meshcollector.neighbours
      WHERE src = $id AND dbtime > (sysdate() - INTERVAL '1' DAY) ");
    my ($lname, $sname) = $dbh->selectrow_array("SELECT lname, sname FROM meshcollector.names WHERE id = $id;");
    unless ($dp2 > 0 and $dp2 == $dp1){ #если новая нода и все датапоинты свежие
      if (defined $lname){
        print "removed: $id $lname $sname $dp1 $dp2\n";
      }else{
        print "removed: $id $dp1 $dp2\n";
      }
      $dbh->do("DELETE from meshcollector.names WHERE id = $id;");
      $dbh->do("DELETE from meshcollector.neighbours WHERE src = $id;");
    }
  }
## add new names
# смотрим сколько датапоинтов у нас есть:
  my ($dp) = $dbh->selectrow_array("SELECT COUNT(*) cnt FROM meshcollector.neighbours WHERE src = $id");
  next unless ($dp > $minDP);
    my ($lname, $sname) = $dbh->selectrow_array("SELECT lname, sname FROM info WHERE id = $id;");
    if (defined $lname){
      my ($test) =  $dbh->selectrow_array("SELECT lName FROM meshcollector.names WHERE id = $id;");
      unless (defined $test){
        $dbh->do("insert into meshcollector.names (id,lname,sname) values ($id, '$lname', '$sname');");
        print "added: $id $lname $sname\n";
      }
    }
}

$dbh->disconnect;
