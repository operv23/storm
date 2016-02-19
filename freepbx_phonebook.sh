#!/bin/bash
echo "hello"
touch /tftpboot/freepbx_phonebook.xml
chown -R asterisk /tftpboot/freepbx_phonebook.xml
echo "
<?php
require_once('/etc/freepbx.conf');
//error_reporting(E_ALL);
//ini_set(\"display_errors\", ON);

// Database settings
\$DBhost = \$amp_conf['AMPDBHOST']; //** Insert your host here
\$DBuser = \$amp_conf['AMPDBUSER']; //** Insert your DB user here
\$DBpass = \$amp_conf['AMPDBPASS']; //** Insert your password here
\$DBdatabase = \$amp_conf['AMPDBNAME']; //** change only when installed Free PBX in a non-common way!

// Connect to the Database and get all devices
\$DBlink = mysql_connect(\$DBhost, \$DBuser, \$DBpass) or die(\"Could not connect to host.\");
mysql_select_db(\$DBdatabase, \$DBlink) or die(\"Could not find database.\");
\$DBquery = \"SELECT user, description FROM devices ORDER BY description ASC\";
\$QUERYresult = mysql_query(\$DBquery, \$DBlink) or die(\"Data not found.\");

//Setup XMLWriter
\$writer = new XMLWriter();
\$writer->openURI('/tftpboot/freepbx_phonebook.xml'); //** If your TFTP server is using another root directory as /tfptboot, chang the path here!
\$writer->setIndent(4);

//Beginn output
\$writer->startDocument('1.0');
\$writer->startElement('AddressBook');

//Add extensions / contacts from devices to the xml phonebook
while (\$contact=mysql_fetch_array(\$QUERYresult)){
    \$writer->startElement('Contact');
    \$writer->writeElement('LastName',\$contact['description']);
    \$writer->writeElement('FirstName','');
    \$writer->startElement('Phone');
    \$writer->writeElement('phonenumber',\$contact['user']);
    \$writer->writeElement('accountindex',\"0\");
    \$writer->endElement();
    \$writer->endElement();
}

\$writer->endElement();
\$writer->endDocument();
\$writer->flush();
?>
" >> /var/www/html/freepbx_phonebook.php

