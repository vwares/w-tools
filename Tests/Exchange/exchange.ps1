﻿Function Test-Send-ExchangeMail()
{

    $mailto = "john@domain.net"
    $subject = "Test mail"
    $mailbody= "This is a test mail"
    $filelist = "C:\temp\file1.txt;C:\temp\file2.txt"
   
    $username = "joe@domain.com"

    # Method 1 : direct input
    $SecurePassword = Read-Host -AsSecureString

    # Method 2 : plain text (not recommended)
    #$Password = "mypassword"
    #$SecurePassword = ($Password | ConvertTo-SecureString -asPlainText -Force)

    # Method 3 : encrypted key (preferred)
    #$key = Get-Content $config.'Send-ExchangeMail'.Encrypted-Keyfile
    #$encpassword = $config.'Send-ExchangeMail'.Encrypted-Password
    #$SecurePassword = $encpassword | ConvertTo-SecureString -Key $key

    # Send Exchange mail without attachments
    $Return = Send-ExchangeMail -ExchangeUserName $username -ExchangePassword $SecurePassword -ExchangeMailTo $mailto -ExchangeMailTitle $subject -ExchangeMailBody $mailbody

    # Send Exchange mail with attachments
    $Return = Send-ExchangeMail -ExchangeAttachments $filelist -ExchangeUserName $username -ExchangePassword $SecurePassword -ExchangeMailTo $mailto -ExchangeMailTitle $subject -ExchangeMailBody $mailbody

}

Function Test-New-ExchangeMeeting()
{

    $username = "creator@domain.com"
    $password = Read-Host "Enter password of $username" -AsSecureString
    $ewsurl = "https://outlook.office365.com/EWS/Exchange.asmx"
    $attendees = "john@domain.com;joe@domain.com"
    $title = "Test Meeting" 
    $body = "Body of test Meeting"
    $start = '2020-12-03T16:05:00' # yyyy-MM-ddTHH:mm:ss
    $end = '2020-12-03T16:35:00' # yyyy-MM-ddTHH:mm:ss
	$location = "Paris - Eiffel Tower"
    $filelist ="C:\temp\file1.txt;C:\temp\file2.txt"

    # Create simple Office 365 meeting, no Teams, no location and no attachement
    $MeetingId = New-ExchangeMeeting -ExchangeUserName $username -ExchangePassword $password -ExchangeRequiredAttendees $attendees -ExchangeMeetingTitle $title -ExchangeMeetingBody $body -ExchangeMeetingStartDate $start -ExchangeMeetingEndDate $end

    # Create meeting for custom Exchange server, no Teams and no attachement

    # Create Teams Office 365 meeting

    # Create Office 365 meeting with attached files and specified location
    $MeetingId = New-ExchangeMeeting -ExchangeUserName $username -ExchangePassword $password -ExchangeRequiredAttendees $attendees -ExchangeMeetingTitle $title -ExchangeMeetingBody $body -ExchangeMeetingStartDate $start -ExchangeMeetingEndDate $end -ExchangeAttachments $filelist -ExchangeMeetingLocation $location

}

Function Test-Edit-ExchangeMeeting()
{

    $username = "creator@domain.com"
    $password = Read-Host "Enter password of $username" -AsSecureString
    $ewsurl = "https://outlook.office365.com/EWS/Exchange.asmx"
    $title = "Modified Test Meeting" 
    $body = "Body of modified test Meeting"
    $start = '2020-12-04T17:15:00' # yyyy-MM-ddHH:mm:ss
    $end = '2020-12-04T17:45:00' # yyyy-MM-ddHH:mm:ss
	$newlocation = "Marseille - Vieux-Port"
    $filelist ="C:\temp\file1.txt;C:\temp\file3.txt"

    # Create simple Office 365 meeting, no Teams and no attachement
    $MeetingId = Edit-ExchangeMeeting -ExchangeMeetingId $MeetingId -ExchangeUserName $username -ExchangePassword $password -ExchangeMeetingTitle $title -ExchangeMeetingBody $body -ExchangeMeetingStartDate $start -ExchangeMeetingEndDate $end

    # Create meeting for custom Exchange server, no Teams and no attachement

    # Create Teams Office 365 meeting

    # Create Office 365 meeting with attached files and new Location
    $MeetingId = Edit-ExchangeMeeting -ExchangeMeetingId $MeetingId -ExchangeUserName $username -ExchangePassword $password -ExchangeMeetingTitle $title -ExchangeMeetingBody $body -ExchangeMeetingStartDate $start -ExchangeMeetingEndDate $end -ExchangeMeetingLocation $newlocation -ExchangeAttachments $filelist

}

Function Test-Remove-ExchangeMeeting()
{

    $username = "creator@domain.com"
    $password = Read-Host "Enter password of $username" -AsSecureString
    $ewsurl = "https://outlook.office365.com/EWS/Exchange.asmx"
    $meetingid = "BAAAAIIA4AB0xbcQGoLgCAAAAAAp1gKGUsnWAQAAAAAAAAAAEAAAAHlrfMPoxtBGv8a7N7md0Zk="
	
    # Cancel Exchange meeting by Id
    $MeetingState = Stop-ExchangeMeeting -ExchangeUserName $username -ExchangePassword $password -ExchangeMeetingId $meetingid

    # Delete Exchange meeting by Id
    $MeetingState = Stop-ExchangeMeeting -Delete -ExchangeUserName $username -ExchangePassword $password -ExchangeMeetingId $meetingid

}