# Gerencia o certificado raiz usado pelo Claude Code no Git Bash.
# O arquivo armazenado é $XDG_CONFIG_HOME/certs/ca_root.pem.

cert_dir="$XDG_CONFIG_HOME/certs"
cert_file="$cert_dir/ca_root.pem"
cert_tmp="$cert_dir/ca_root.pem.new"

mkdir -p "$cert_dir"

# Baixa o certificado raiz de google.com:443
printf "Q" \
| openssl s_client -showcerts -connect google.com:443 2>/dev/null \
| awk '/BEGIN CERTIFICATE/{cert=""; inside=1} inside{cert=cert $0 "\n"} /END CERTIFICATE/{last_cert=cert; inside=0} END{printf "%s", last_cert}' \
> "$cert_tmp"

# Calcula fingerprint SHA256 do novo certificado
new_fp=$(openssl x509 -in "$cert_tmp" -noout -fingerprint -sha256 2>/dev/null | sed 's/.*=//; s/://g')

# Calcula fingerprint do certificado existente (se houver)
if [ -f "$cert_file" ]; then
  old_fp=$(openssl x509 -in "$cert_file" -noout -fingerprint -sha256 2>/dev/null | sed 's/.*=//; s/://g')
fi

# Atualiza o arquivo apenas se não existir ou se o fingerprint mudou
if [ ! -f "$cert_file" ] || [ "$new_fp" != "$old_fp" ]; then
  mv "$cert_tmp" "$cert_file"
  displaySuccess "Certificado raiz" "Atualizado em $cert_file"
else
  rm -f "$cert_tmp"
fi

# Avisa se o certificado está prestes a expirar (< 7 dias)
if ! openssl x509 -in "$cert_file" -checkend 604800 >/dev/null 2>&1; then
  exp_date=$(openssl x509 -in "$cert_file" -noout -enddate 2>/dev/null | sed 's/notAfter=//')
  displayWarning "Certificado raiz" "Irá expirar nos próximos 7 dias (data: $exp_date, será atualizado automaticamente por mim)"
fi

export SSL_CERT_FILE="$cert_file"
export NODE_EXTRA_CA_CERTS="$cert_file"
