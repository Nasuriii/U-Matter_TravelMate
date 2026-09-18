# TravelMate Recovery

Backup exports and Storage downloads have been collected.
Full restore testing is still pending.

04_Restore_TravelMate_Auth_Storage.sql restores the custom Auth
trigger and Storage policies after the application schema and
data have been restored to a separate Supabase recovery project.

Do not run it on the existing source project.
Database backups and credentials are stored separately.
Sankyu sankyu please
