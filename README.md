# FS Rebuild

## Project Goal

This repository contains the rebuild workspace for the offline FS system.

Current scope:

1. Build a maintainable new project skeleton.
2. Land the platform layer, core data model, and minimal business backbone first.
3. Extend from login and dictionary services to menu, org tree, and object list step by step.

Out of scope for the first stage:

- Full legacy UI parity
- Full map compatibility
- Full report/export and upgrade behavior parity

## Repository Structure

- `backend`: Spring Boot + MyBatis backend
- `frontend`: Vue 3 + Vite frontend
- `docs`: lightweight engineering notes inside the project
- `sql`: schema, seed, and migration draft files

## Tech Stack

- Backend: Spring Boot 3.5 + MyBatis + MySQL
- Frontend: Vue 3 + Vite + TypeScript
- Database: MySQL, rebuilt by business domain
- Map capability: isolated for a later integration stage

## Delivery Order

### Step 1: Platform Layer

- Login and auth
- Base dictionary
- Org tree and navigation menu
- Shared list/detail page skeleton

### Step 2: Core Data Model

- Object master data
- Reference records
- Receive batches
- Check tasks

### Step 3: Core Workflow

- Data initialization
- Receive mobile data
- Object detail editing
- Quality check

### Step 4: Extended Capability

- Map workspace
- Attachment and export
- Upstream reporting

## Local Notes

The analysis bundle referenced by this workspace is stored locally in a separate document folder.

Recommended reading order:

1. Project document index
2. Architecture and rebuild analysis
3. Implementation plan and phase schedule

## Current Status

- Project skeleton created
- Minimal auth and dictionary API landed
- Org/menu/object-list skeleton is being added
- Next step is to wire backend runtime against the new schema
