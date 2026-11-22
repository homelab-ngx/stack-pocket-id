# stack-pocket-id

[Pocket ID](https://pocket-id.org), a sign-in server (OIDC) that uses
passkeys, as a stack for [homelab-ngx](https://github.com/homelab-ngx/homelab-ngx). It is built from nixpkgs.

## Getting started

1. Add the stack: `homelab stacks add github:homelab-ngx/stack-pocket-id`,
   or Add stack on the dashboard's Stacks page.
2. On the stack's page, set `APP_URL` to the address people sign in at,
   `https://auth.<your domain>`. Passkeys are bound to it.
3. Set `ENCRYPTION_KEY` to the output of `openssl rand -base64 32`.
4. Approve the grants and start the stack.
5. Open `https://auth.<your domain>/setup` and make the admin account.

Clients, users and mail settings are made in Pocket ID's admin pages.

Uploaded images stay on the stack's disk. To keep them in S3 instead, set
`FILE_BACKEND` to `s3` and fill in the `S3_*` variables.

To move an existing install, copy its `data/` folder into
`/var/lib/pocket-id` in the stack before the first start.

Mail goes through a relay on the host: in the admin pages, set the SMTP host
to the stack's gateway address, port 25, no TLS. homelab-ngx has no mail
relay on the host yet, so Pocket ID sends no mail on it today.

<!-- manifest:start -->
<!-- Made from homelab-stack.json. Change the manifest, not these lines. -->

## Grants

You approve each of these before the stack starts.

- Route: `auth.<your domain>` to port 1411 in the stack.
- Network: out to the host on port 25/tcp.

## Variables

| Name | Kind | Required | Default | Description |
| --- | --- | --- | --- | --- |
| `APP_URL` | env | yes |  | The address people sign in at, such as https://auth.example.com. Passkeys are bound to it: changing it later invalidates them. |
| `ENCRYPTION_KEY` | secret | yes |  | Encrypts stored keys and secrets. Make one with: openssl rand -base64 32 |
| `FILE_BACKEND` | env: `s3` | no |  | Where uploaded images are kept: s3, or unset for the stack's own disk. |
| `S3_ENDPOINT` | env | no |  | S3 endpoint URL, for FILE_BACKEND s3. |
| `S3_BUCKET` | env | no |  | S3 bucket, for FILE_BACKEND s3. |
| `S3_REGION` | env | no |  | S3 region, for FILE_BACKEND s3. |
| `S3_ACCESS_KEY_ID` | secret | no |  | S3 access key ID, for FILE_BACKEND s3. |
| `S3_SECRET_ACCESS_KEY` | secret | no |  | S3 secret access key, for FILE_BACKEND s3. |

## Backup

The stack recommends these folders. None is backed up until you add it to a backup.

- Pocket ID database: `/var/lib/pocket-id` in the stack.

## Health

An update is kept when all of this holds, and rolled back when it does not.

- `pocket-id.service` is active.
- Port 1411 answers at `/healthz`.

Manifest version 8, built with nixpkgs `nixos-unstable`. Runs on [homelab-ngx](https://github.com/homelab-ngx/homelab-ngx).

<!-- manifest:end -->

## License

MIT, see [LICENSE](LICENSE).
