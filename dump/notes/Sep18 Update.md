Good evening po ulit, Ma'am. This is just a quick update po regarding what we were able to work on today for U-Matter TravelMate, especially dun po sa database side since medyo marami din po kaming changes na ginawa today and may mga nasira din along the way pero thankfully naayos naman din po namin.

First po, we have finally finalized yung current schema setup ng TravelMate database. Before po kasi, most of the tables that we made were under the `travelmate` schema, since nung una po we thought na mas okay siya para separated yung tables ng system. Pero as per your suggestion po ma'am, we decided to migrate yung actual application tables into the `public` schema instead, especially since mas magiging compatible and straightforward siya with Supabase, authentication, RLS policies, and yung API po.

So today po, we have successfully migrated yung tables from the `travelmate` schema into `public`. Medyo may mga kailangan lang din po kaming i-check after the migration since some of the SQL queries, relationships, policies and other references were still expecting the old schema, pero after going through them po, yung current setup is now mainly using the `public` schema.

Another major change po that we did today is dun sa users.

Originally po, we had a `users` table and some other user-related tables because before po, yung idea namin was that we will manage the accounts ourselves inside the database. Pero as per your suggestion po ma'am, we changed this setup and instead decided to use the authentication system that Supabase already provides.

So yung previous `users` table was basically changed into more of a `profiles` table instead po.

The way it works now is that Supabase Auth handles the actual account of the user, while yung `profiles` table is only for the information that is needed by TravelMate itself.

So yung flow po ngayon is basically:

Google OAuth
→ Supabase Authentication
→ `auth.users`
→ `profiles`

We also integrated Google OAuth po for the sign in, which is also based po dun sa suggestion and example that you showed us before. Because of this, we no longer need to manually handle passwords or create our own authentication system inside the application database. Yung Supabase Auth na po yung responsible dun, while yung profile and other TravelMate-related user information is stored separately sa `profiles`.

I think this also made the structure cleaner po because yung authentication and yung actual application data of the user are not mixed together anymore.

For Mission 3 naman po, we also worked a lot today dun sa backup and recovery part.

Previously po, we already had some SQL exports and we were also able to download some of the image files from Supabase Storage, pero yung main problem was we still did not have proper proof na kapag may nawala sa database, kaya talaga namin siyang i-restore.

We originally tried using some of the Supabase local tools po, pero yung Docker and WSL requirements were too heavy for the laptop that I am currently using, so instead po we installed PostgreSQL 17 directly on Windows and used that as our local recovery environment.

We were able to successfully restore yung TravelMate database into a separate local PostgreSQL database called:

`travelmate_recovery_test`

We purposely used a separate database po so that we will not have to experiment directly on the actual hosted Supabase database.

After po nun, we created another backup using PostgreSQL `pg_dump` using the custom archive format.

We checked po if the backup succeeded using:

`echo %ERRORLEVEL%`

and it returned `0`.

We also checked if readable talaga yung backup by using `pg_restore --list`, and that also returned `0`, so at least we were able to confirm na hindi lang siya basta file na na-create, readable talaga siya by PostgreSQL.

After that po, we tried simulating actual data loss.

We created a small table called `recovery_demo` and inserted three test records. Then gumawa po kami ng backup while those records were still there.

After making the backup, we intentionally deleted the `recovery_demo` table, basically simulating po na may accidentally na-delete na table inside the system.

Dito po kami nagkaroon ng problem.

When we first tried restoring the table, the command itself looked like it worked, pero when we checked the database again using:

`SELECT * FROM public.recovery_demo;`

we got the error:

`relation "public.recovery_demo" does not exist`

So apparently po, the restore command ran but it did not actually restore the table that we were expecting.

We eventually found out po na yung problem was with how we selected the table using `pg_restore`.

Originally po we used:

`-t public.recovery_demo`

pero hindi po siya gumana properly in our PostgreSQL 17 setup.

What fixed it was separating yung schema and yung actual table:

`-n public -t recovery_demo`

After changing it to that, we ran the restore again and this time po the table came back successfully.

We checked the records and yung same three records that existed before deleting the table were restored properly.

So at least now po we were able to actually test this entire flow:

Working database
→ Backup
→ Verify backup
→ Simulate data loss
→ Restore
→ Verify recovered data

Before po kasi we only had the backup files, pero now at least we already have proof na kaya din talaga siyang gamitin for recovery.

We also clarified today po yung difference between the local recovery database and the actual Supabase backup.

Yung local PostgreSQL database po that we restored is mainly for testing yung recovery process. It is not automatically the latest backup of the actual hosted Supabase database every time may bagong data.

So yung setup po that we are looking at now is more like:

Supabase = actual hosted database
Local PostgreSQL = recovery and testing environment
GitHub = scripts, SQL files, documentation, and recovery instructions

Then yung actual database backup file itself should still be stored separately and not directly uploaded sa GitHub, especially since it may contain actual application data.

We also started checking po yung database roles today.

We found out na the two job roles that we need already actually exist, which are:

`tm_catalog_reviewer`

and

`tm_reporting_analyst`

So thankfully po, we do not need to create the roles again from scratch.

The `tm_catalog_reviewer` is supposed to be responsible for reviewing the TravelMate listings. Currently po it already has access to read some of the catalog information, and yung intended final setup is that it can read the listings and destinations, and only update the `status` of a listing, without being able to create or delete records.

The other role, `tm_reporting_analyst`, is supposed to be a read-only role po. Meaning it should be able to view the needed listing and destination information for reporting, but it should not be able to change anything.

When we checked the actual permissions today po, we found out that these two roles are only partially configured. The catalog reviewer can already read some of the needed tables, pero it still does not have the final permission for updating the listing status. Then yung reporting analyst naman po exists already, pero it still does not have the correct read permissions for the needed tables.

We also checked po yung role membership and we confirmed that the `postgres` account can use `SET ROLE` for both roles, which should help us later during the demo since we can directly demonstrate the restrictions through PostgreSQL itself.

For example po, yung planned demonstration will be something like:

`tm_reporting_analyst`

* SELECT works
* UPDATE does not work
* DELETE does not work

Then:

`tm_catalog_reviewer`

* SELECT works
* updating the listing status works
* DELETE does not work

We did not finish applying the final permissions tonight po since medyo late na din, so this will probably be one of the first things that we will continue tomorrow.

So overall po, today was mostly more on cleaning, fixing and finalizing the database rather than adding new features.

We finalized the current schema and migrated it into `public` based po on your suggestion, changed the old user setup into a `profiles` setup and integrated Supabase Auth with Google OAuth based din po on your suggestion, successfully restored our database locally using PostgreSQL 17, created and verified a backup, simulated data loss, encountered a restore problem and fixed it, successfully recovered the deleted data, and then we also started auditing the two required database roles.

There are still some things left po, especially yung final permissions of the two roles, organizing the recovery documentation and screenshots, and practicing the database defense itself, pero compared po dun sa state namin before, mas stable and organized na po yung database ngayon.

That's all for today po, Ma'am, and sorry again po for the late update. Thank you po!
