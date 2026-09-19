# Restoring backups

Three things have to happen, in this order.

## 1. Grant `session_replication_role` first

Mealie disables foreign key enforcement during a restore with `SET session_replication_role = 'replica'`.
Setting that parameter requires superuser.
The `mealie` role owns its database but is not a superuser, so the restore fails with `InsufficientPrivilege`.
Mealie truncates every table before it hits that error, so a failed restore leaves the database empty.

```sh
kubectl exec \
  -n household \
  "$(kubectl get cluster db -n household -o jsonpath='{.status.currentPrimary}')" \
  -c postgres \
  -- \
  psql -c "GRANT SET ON PARAMETER session_replication_role TO mealie;"
```

The grant covers `SET` but not `ALTER SYSTEM`.
It applies to the whole cluster, because `pg_parameter_acl` is a shared catalog.
Neither Terraform nor CNPG manages the grant, so it does not survive rebuilding the `db` cluster.

## 2. Restart if `users` is empty

A failed restore leaves no user to log in as.
Restarting recreates the default group, household and user through `init_db`.

```sh
kubectl rollout restart deploy/mealie -n household
```

Log in as `changeme@example.com` / `MyPassword`.
Mealie uses those defaults because we do not set `DEFAULT_EMAIL` or `DEFAULT_PASSWORD`.

## 3. Restart after the restore

The restore replaces the data directory, including `/app/data/.secret`, the JWT signing key.
The process keeps the key it read at startup, so it signs tokens with one key and rejects them with the other.
`POST /api/auth/token` returns 200, then `GET /api/users/self` returns 401.

```sh
kubectl rollout restart deploy/mealie -n household
```

## Notes

- Restore into the version the backup came from.
  The version is in the backup filename.
  Image automation moves the Deployment off that version, so check before restoring.
- The backup `.zip` lives at `/app/data/backups/` on the data PVC.
  It survives restarts, so you only need to upload it once.

## Revoking the grant

Only a restore needs this grant.

```sh
kubectl exec \
  -n household \
  "$(kubectl get cluster db -n household -o jsonpath='{.status.currentPrimary}')" \
  -c postgres \
  -- \
  psql -c "REVOKE SET ON PARAMETER session_replication_role FROM mealie;"
```
