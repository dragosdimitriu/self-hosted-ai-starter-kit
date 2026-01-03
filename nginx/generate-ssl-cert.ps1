# PowerShell script to generate self-signed SSL certificate for n8n
# This is for development/testing. For production, use Let's Encrypt.

param(
    [string]$DomainOrIP = "77.81.243.123"
)

$SSL_DIR = ".\nginx\ssl"

Write-Host "Generating self-signed SSL certificate for $DomainOrIP..." -ForegroundColor Yellow
Write-Host "Note: This creates a self-signed certificate. Browsers will show a security warning." -ForegroundColor Yellow
Write-Host "For production use, consider using Let's Encrypt with a domain name." -ForegroundColor Yellow
Write-Host ""

# Create SSL directory if it doesn't exist
if (-not (Test-Path $SSL_DIR)) {
    New-Item -ItemType Directory -Path $SSL_DIR | Out-Null
}

# Generate self-signed certificate using PowerShell
$cert = New-SelfSignedCertificate `
    -DnsName $DomainOrIP `
    -CertStoreLocation "Cert:\CurrentUser\My" `
    -KeyAlgorithm RSA `
    -KeyLength 2048 `
    -NotAfter (Get-Date).AddDays(365) `
    -FriendlyName "n8n Self-Signed Certificate"

# Export certificate to PEM format
$certPath = "Cert:\CurrentUser\My\$($cert.Thumbprint)"
$certBytes = $cert.Export([System.Security.Cryptography.X509Certificates.X509ContentType]::Cert)
[System.IO.File]::WriteAllBytes("$SSL_DIR\cert.pem", $certBytes)

# Export private key (requires additional steps)
$keyBytes = $cert.PrivateKey.Export([System.Security.Cryptography.CngKeyBlobFormat]::Pkcs8PrivateBlob)
[System.IO.File]::WriteAllBytes("$SSL_DIR\key.pem", $keyBytes)

# Note: PowerShell's New-SelfSignedCertificate doesn't easily export to PEM format
# For Windows, you may need to use OpenSSL or convert the certificate
Write-Host ""
Write-Host "Certificate created in Windows certificate store." -ForegroundColor Green
Write-Host "Thumbprint: $($cert.Thumbprint)" -ForegroundColor Green
Write-Host ""
Write-Host "For PEM format certificates on Windows, consider:" -ForegroundColor Yellow
Write-Host "1. Install OpenSSL for Windows" -ForegroundColor Yellow
Write-Host "2. Use the generate-ssl-cert.sh script with Git Bash or WSL" -ForegroundColor Yellow
Write-Host "3. Or use certbot/Let's Encrypt for production certificates" -ForegroundColor Yellow

