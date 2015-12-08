#!/usr/bin/perl

use DBI;
#use strict;
use DBIx::Dump;
use DBD::mysql;
#use Spreadsheet::WriteExcel;
#use MIME::Lite;

#my $dsn = "dbi:mysql:bugs:localhost";
my $dsn = "dbi:mysql:bugs:10.250.208.51";
my $DBHOST = "10.250.208.51";
my $DBNAME = "bugs";
my $DBUSER = "bugs";
my $DBPASS = "bugs_pass";
my @stash = ();
my @data = ();
my @data2 = ();
my @data3 =();
my @new_stash = ();
my $total_open = ();
my $report_name = "mustfix.csv"; 
my $email_file = "Spartan_tmp_email.html";


#Query for severity one DEFERRED bugs
my $sqlcountone = 'select count(*) from bugs_activity
		where bug_when > "2012-07-23" and bugs_activity.bug_id in ( select bug_id from bugs 
								  where product_id in (2) and bug_status IN ("RESOLVED","VERIFIED")
								  and cf_target_release in ( "1.1.0" ) and resolution IN ("FIXED") and bug_severity="S1 - DU/DL")
								
		and fieldid in ( 12 )';
							
							
#Query for severity two DEFEERRED bugs	
my $sqlcounttwo = 'select count(*) from bugs_activity
		where bug_when > "2012-07-23" and bugs_activity.bug_id in ( select bug_id from bugs 
								  where product_id in (2) and bug_status IN ("RESOLVED","VERIFIED")
								  and cf_target_release in ( "1.1.0" ) and resolution IN ("FIXED") and bug_severity="S2 - Major (Crash/Broken Feature)")
								
		and fieldid in ( 12 )';
#Query for severity three DEFERRED bugs	
my $sqlcountthree = 'select count(*) from bugs_activity
		where bug_when > "2012-07-23" and bugs_activity.bug_id in ( select bug_id from bugs 
								  where product_id in (2) and bug_status IN ("RESOLVED","VERIFIED")
								  and cf_target_release in ( "1.1.0" ) and resolution IN ("FIXED") and bug_severity="S3 - Minor (Cosmetic)")
								
		and fieldid in ( 12 )';	
#Query for severity four DEFERRED bugs		
my $sqlcountfour = 'select count(*) from bugs_activity
		where bug_when > "2012-07-23" and bugs_activity.bug_id in ( select bug_id from bugs 
								  where product_id in (2) and bug_status IN ("RESOLVED","VERIFIED")
								  and cf_target_release in ( "1.1.0" ) and resolution IN ("FIXED") and bug_severity="S4 - Enhancement Request")
								
		and fieldid in ( 12 )';	
#Query for severity five DEFERRED bugs		
my $sqlcountfive = 'select count(*) from bugs_activity
		where bug_when > "2012-07-23" and bugs_activity.bug_id in ( select bug_id from bugs 
								  where product_id in (2) and bug_status IN ("RESOLVED","VERIFIED")
								  and cf_target_release in ( "1.1.0" ) and resolution IN ("FIXED") and bug_severity="S5 - Task Tracking")
								
		and fieldid in ( 12) ';		
		
		
		
my $sqltotal = 'select count(*) from bugs_activity
		where bug_when > "2012-07-23" and bugs_activity.bug_id in ( select bug_id from bugs 
								  where product_id in (2) and bug_status IN ("RESOLVED","VERIFIED")
								  and cf_target_release in ( "1.1.0" ) and resolution IN ("FIXED"))
								
		and fieldid in ( 12) ';		
#create a hash
my %cmpt;
#connect to the database
my $DB = DBI->connect($dsn, $DBUSER, $DBPASS, \%attr) || die "Data base connection not made: $DBI::errstr";

#get severity one numbers


$sth = $DB->prepare($sqlcountone);
$sth->execute();
$count = $sth->fetchrow();
$cmpt{'S1 - DU/DL'}= $count;


$sth->finish;

#get severity two numbers

$sth = $DB->prepare($sqlcounttwo);
$sth->execute();
$count = $sth->fetchrow();
$cmpt{'S2 - Major (Crash/Broken Feature)'}= $count;

$sth->finish;

#get severity three numbers


$sth = $DB->prepare($sqlcountthree);
$sth->execute();
$count = $sth->fetchrow();
$cmpt{'S3 - Minor (Cosmetic)'}= $count;


$sth->finish;

#get severity four numbers


$sth = $DB->prepare($sqlcountfour);
$sth->execute();
$count = $sth->fetchrow();
$cmpt{'S4 - Enhancement Request'}= $count;


$sth->finish;

#get severity five numbers


$sth = $DB->prepare($sqlcountfive);
$sth->execute();
$count = $sth->fetchrow();
$cmpt{'S5 - Task Tracking'}= $count;


$sth->finish;

$sth = $DB->prepare($sqltotal);
$sth->execute();
$count = $sth->fetchrow();
$cmpt{'Total'}= $count;


$sth->finish;

my %months = (
	"Jan" => 1,
	"Feb" => 2,
	"Mar" => 3,
	"Apr" => 4,
	"May" => 5,
	"Jun" => 6,
	"Jul" => 7,
	"Aug" => 8,
	"Sep" => 9,
	"Oct" => 10,
	"Nov" => 11,
	"Dec" => 12,
);
$dte = localtime();
$dte =~ /(.*?)\s+(.*?)\s+(\d+)\s+\d+\:\d+\:\d+\s+(\d+)/;
$year = $4 - 2000;
$dte = "$months{$2}/$3/".($4-2000);


my $content ='';
$content .= "$dte";
#$content .= localtime();
for $sev('S1 - DU/DL','S2 - Major (Crash/Broken Feature)','S3 - Minor (Cosmetic)','S4 - Enhancement Request','S5 - Task Tracking')
{
	$content .= ",".$cmpt{$sev};
}

$content .= ",".$cmpt{'Total'};	





write2file( 'fixedtrend.csv', $content);


exit;

#my $workbook  = Spreadsheet::WriteExcel->new("$report_name");
#die "Problems creating new Excel file: $!" unless defined $workbook;

sub write2file {
	open( FILE, ">> $_[0]" ) or die "Could not open $_[0]";
	print "\n";
	print FILE $_[1];
	print "\n";
	close FILE;
}

sub main {
   #create_completed_items("3.5");
   #create_completed_items("4.0");
  # $workbook->close();
   send_mail();
   exit();
}

sub create_todo_report {
   my $version = shift;
   gen_dev_items($version, "Dev $version");
   gen_test_items($version, "Test $version");
   #gen_1_0_items();
}

sub create_completed_items {
   my $version = shift;
   gen_completed_items($version, "Completed $version");
}

sub gen_dev_items {
   my $version = shift;
   my $worksheet_name= shift;
   
   my $sql = gen_query("Sidewinder", "1.0", "'UNCONFIRMED','NEW','ASSIGNED','REOPENED'", "bugs.priority","bugs.reporter");
   my @data = get_data($sql); 
   write_worksheet($worksheet_name, \@data, "DEV");
}

sub gen_test_items {   
   my $version = shift;
   my $worksheet_name= shift;
   my $sql = gen_query("Spartan", $version, "'RESOLVED'","profiles.login_name","bugs.qa_contact");
   my @data = get_data($sql); 
   write_worksheet($worksheet_name, \@data, "TEST");  
}

sub gen_completed_items {
   my $version = shift;
   my $worksheet_name= shift;
   my $sql = gen_query("Spartan", $version, "'VERIFIED','CLOSED'", "bugs.priority","bugs.reporter");
   my @data = get_data($sql); 
   write_worksheet($worksheet_name, \@data, "COMPLETED");  
}


sub get_data {
  my $sql = shift;
  my @data = ();
  my $DB = DBI->connect($dsn, $DBUSER, $DBPASS, \%attr) || die "Data base connection not made: $DBI::errstr";
  my $sth = $DB->prepare($sql);
  $total_open = $sth->execute();
  while ($sth->fetchrow()){
  push (@data); 
  }
  $sth->finish;
  $DB->disconnect;
  return @data;
}



sub get_data2 {
  my $sql = shift;
  #my @data = ();
  my $DB = DBI->connect($dsn, $DBUSER, $DBPASS, \%attr) || die "Data base connection not made: $DBI::errstr";
  my $sth = $DB->prepare($sql);
  print "$sql\n";
  #exit;
  $total_open = $sth->execute();
  #print "DEBUG TOTAL OPEN: $total_open\n";
  while (($l2) = $sth->fetchrow()){
  push (@data2,"$l2,"); 
  }
  $sth->finish;
  $DB->disconnect;
  return @data2;
}





sub write_worksheet {
  my $worksheet_name = ($_[0]);
  my @data = @{$_[1]};
  my $calling_app = ($_[2]);
  my $line_count = 1;
  my $bugzilla_url = "http://bugz.ocarina.local/show_bug.cgi?id="; 

  my $filename = $email_file . "_" . $calling_app; 
  open (HTML_FILE, ">$filename");  

  my $custom = $workbook->set_custom_color(40, 255, 100, 12);
  my $header = $workbook->add_format(
                                        bg_color => $custom,
                                        pattern  => 1,
                                        border   => 1
                                      );
  $header->set_bold();
  $header->set_color('black');

  my $worksheet = $workbook->add_worksheet("$worksheet_name");
  $worksheet->set_column('E:E', 70);
  $worksheet->set_column('A:D', 12);
  $worksheet->write(0, 0,  "Bug_ID", $header);
  $worksheet->write(0, 1,  "Priority", $header);
  $worksheet->write(0, 2,  "Dev Owner", $header);
  $worksheet->write(0, 3,  "Test Owner", $header);
  $worksheet->write(0, 4,  "Description", $header);


  print HTML_FILE "<html><body>Defect report for Spartan-1.0.<br><br>";
  
  print HTML_FILE "<table><tr><td>Bug_ID</td><td>Priority</td><td>Dev Owner</td><td>Test Owner</td><td>Description</td></tr>";

  foreach $line (@data){ 
    my @vars = split(/,/,$line);
    my $ID = $vars[0];
    my $P  = $vars[1];
    my $DEV = $vars[7];
    my $TEST = $vars[6];
    my $DESC = $vars[9];	

    my $bug_link = "$bugzilla_url" . "$ID";	
    
    $worksheet->write_url($line_count, 0, $bug_link, $ID);
    $worksheet->write($line_count, 1, $P);
    $worksheet->write($line_count, 2, $DEV);
    $worksheet->write($line_count, 3, $TEST);
    $worksheet->write($line_count, 4, $DESC);

    if (($P =~ /P0/) or ($P =~ /P1/)) {
	
	     print HTML_FILE "<tr><td><a href=$bug_link>$ID</a></td><td>$P</td><td>$DEV</td><td>$TEST</td><td>$DESC</td></tr> ";
    #print "after $P\n";
	}

   
    $line_count++;
  } 
  

     print HTML_FILE "</table></body></html>";
     close(HTML_FILE);
}















sub send_mail {    
#   my $message_body = "Attached is the Daily Bugzilla Report for 1.0 and 2.0.\n This report is generated automatically based on the latest data in bugzilla.\n Please keep bugz updatad so the report is accurate.\n \n Thanks, \n Bugz";
 
my $filename = $email_file . "_DEV";
open (HTML_FILE, "<$filename"); 
my $message_body = <HTML_FILE>; 
   
### Create a new multipart message:
    #$msg = MIME::Lite->new(
       # From    =>'praveen_kandala@dell.com',
        #To      =>'praveen_kandala@dell.com',
        #Cc      =>'Renato_Maranon@dell.com,adam_capell@dell.com',
        #Subject =>'Spartan-1.0 defect Report',
        #Type    =>'multipart/mixed',
    #);

   #$msg->attach (
     #Type => 'HTML',
     #Data => $message_body
   #) or die "Error adding the text message part: $!\n";

    #$msg->attach(
        #Type     => 'application/excel',
        #Path     => "$report_name", 
        #Filename => "$report_name",
        #Disposition => 'attachment'
        #) or die "Error adding $report_name: $!\n";
    

    ### use Net:SMTP to do the sending
    #$msg->send('smtp', 'smtp.ins.dell.com', Debug=>1 );

unlink($filename);

}

main();