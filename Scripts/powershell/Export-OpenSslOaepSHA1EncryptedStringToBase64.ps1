# Variables
$ProjectPath = "C:\Users\john\Documents\Projects\Encrypt"
$InFile = "$ProjectPath\Configuration Files\plaintext.txt"
$InKey = "$ProjectPath\Configuration Files\publickey.txt"
$TempBatchPath = "$ProjectPath\Scripts\test.bat" # Generated by script

try {

    # Temporary batch file content
    $TempBatchContent = "@$ProjectPath\Libraries\openssl\OpenSSL-Win32\openssl.exe pkeyutl -in ""$InFile"" -encrypt -pubin -inkey ""$InKey"" -pkeyopt rsa_padding_mode:oaep -pkeyopt rsa_oaep_md:sha1 -pkeyopt rsa_mgf1_md:sha1 | $ProjectPath\Libraries\openssl\OpenSSL-Win32\openssl.exe base64"
    Set-Content -Path $TempBatchPath -Value $TempBatchContent

    # Execution
    $opensslresponse = Invoke-Expression $TempBatchPath -ErrorAction SilentlyContinue -WarningAction SilentlyContinue  | Out-String

    # Output
    Write-Output $opensslresponse

}
catch {
    Throw $_.Exception
}
finally {
    If (Test-Path -Path $TempBatchPath) {
        Remove-Item -Path $TempBatchPath # delete temporary batch file
    }
}
