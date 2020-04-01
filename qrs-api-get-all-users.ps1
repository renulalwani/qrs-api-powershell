# This script is provided "AS IS", without any warranty, under the MIT License
# See the https://github.com/tonikautto/qrs-api-powershell/blob/master/LICENSE for details
# Copyright (c) 2020 Toni Kautto

# References 
# QRS API - GET /user/full: https://help.qlik.com/en-US/sense-developer/February2020/APIs/RepositoryServiceAPI/index.html?page=1079
# XrfKey; https://help.qlik.com/en-US/sense-developer/Subsystems/RepositoryServiceAPI/Content/Sense_RepositoryServiceAPI/RepositoryServiceAPI-Connect-API-Using-Xrfkey-Headers.htm

# Paramters for REST API call
# Qlik Sense node to make API call to
# User ID to use for authorization
param (
    [Parameter(Mandatory=$true)]
    [string] $FQDN       = "qlikserver.domain.local",   
    [Parameter(Mandatory=$true)]
    [string] $UserName   = "administrator",             
    [Parameter(Mandatory=$true)]
    [string] $UserDomain = "domain"
)

# Qlik Sense client certificate to be used for connection authentication
# Note, certificate lookup must return only one certificate. 
$ClientCert = Get-ChildItem -Path "Cert:\CurrentUser\My" | Where-Object {$_.Subject -like '*QlikClient*'}

# Only continue if one unique client cert was found 
if (($ClientCert | measure-object).count -ne 1) { 
    Write-Host "Failed. Could not find one unique certificate." -ForegroundColor Red
    Exit 
}

# 16 character Xrefkey to use for QRS API call
$XrfKey = "hfFOab87fD98f7sf"

# HTTP headers to be used in REST API call
$HttpHeaders = @{}
$HttpHeaders.Add("X-Qlik-Xrfkey","$XrfKey")
$HttpHeaders.Add("X-Qlik-User", "UserDirectory=$UserDomain;UserId=$UserName")
$HttpHeaders.Add("Content-Type", "application/json")

# HTTP body for REST API call
$HttpBody = @{}

# Invoke REST API call
# Get condensed list of all users in Qlik Sense Repository 
Invoke-RestMethod -Uri "https://$($FQDN):4242/qrs/user/full?xrfkey=$($xrfkey)" `
                  -Method GET `
                  -Headers $HttpHeaders  `
                  -Body $HttpBody `
                  -ContentType 'application/json' `
                  -Certificate $ClientCert