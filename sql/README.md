# SQL Notes

This directory contains database artifacts for the FS rebuild project:

- schema scripts
- seed scripts
- migration drafts

## Structure

- `schema/`: create tables and structural scripts
- `seed/`: initial data
- `migration/`: legacy-to-new migration drafts

## Current Script Order

1. `schema/001_core_platform.sql`
2. `schema/002_core_business.sql`
3. `schema/003_navigation.sql`
4. `seed/001_initial_auth_and_dict.sql`
5. `seed/002_menu_and_sample_data.sql`

## Current Coverage

### Platform Domain

- orgs
- roles
- users
- role bindings
- regions
- dictionaries
- attachments
- navigation menu

### Business Domain

- reference records
- receive batches
- receive records
- object master data
- object points
- check tasks

## Next Step

Next additions:

1. object extension tables
2. photo/constitution/sample/line-graph tables
3. legacy mapping drafts
