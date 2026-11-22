{ pkgs, ... }:

# Pocket ID: an OIDC provider that signs people in with passkeys.
#
# Its settings are environment variables. The host's values (APP_URL, the S3
# ones) arrive in /run/secrets/env, which the homelab base module makes the
# last EnvironmentFile of the service, so they override what is set here.
# Clients, users and mail settings are made in its own admin pages and live
# in the database under /var/lib/pocket-id.
#
# Mail goes through the host's relay: in the admin pages set the SMTP host to
# the stack's gateway (the host part of HOMELAB_API_URL, 10.99.N.1), port 25,
# no TLS.

let
  dataDir = "/var/lib/pocket-id";
  s3Env = "/run/pocket-id-s3/env";

  # The S3 keys are optional secrets, so they cannot be LoadCredential=
  # entries (a missing file fails the unit).
  writeS3Env = pkgs.writeShellScript "pocket-id-s3-env" ''
    set -eu
    umask 077
    : > ${s3Env}
    for name in S3_ACCESS_KEY_ID S3_SECRET_ACCESS_KEY; do
      if [ -s "/run/secrets/$name" ]; then
        printf '%s=%s\n' "$name" "$(cat "/run/secrets/$name")" >> ${s3Env}
      fi
    done
  '';
in
{
  services.pocket-id = {
    enable = true;
    inherit dataDir;
    settings = {
      TRUST_PROXY = true;
      # Caddy and the health probe reach it on the stack's address.
      HOST = "0.0.0.0";
      PORT = "1411";
    };
    credentials.ENCRYPTION_KEY = "/run/secrets/ENCRYPTION_KEY";
  };

  systemd.services.pocket-id.serviceConfig = {
    RuntimeDirectory = "pocket-id-s3";
    RuntimeDirectoryMode = "0700";
    ExecStartPre = [
      "+${writeS3Env}"
      # Data moved in from another install keeps that install's owner.
      "+${pkgs.coreutils}/bin/chown -R pocket-id:pocket-id ${dataDir}"
    ];
    EnvironmentFile = [ "-${s3Env}" ];
  };
}
