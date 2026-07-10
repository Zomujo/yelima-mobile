import re

with open('lib/features/medications/data/repositories/medication_repository_impl.dart', 'r') as f:
    content = f.read()

# I will use regex to find multi-line comments and replace them with single line comments.
# Or I can just write a script to replace the specific long comments since they're mostly known.

replacements = [
    (
        '''  // Appended to day-scoped cache keys so a cached value never survives past
  // the day it was written, instead of silently showing yesterday's data.''',
        '''  // Daily scoped cache key.'''
    ),
    (
        '''        // Cache the rate (similar to HomeMetrics)''',
        '''        // Cache adherence rate.'''
    ),
    (
        '''        // Cache the full JSON for the days list''',
        '''        // Cache adherence days list.'''
    ),
    (
        '''      // Try to parse the full JSON cache first''',
        '''      // Parse JSON cache.'''
    ),
    (
        '''          // Fall through to basic cache if JSON parsing fails''',
        '''          // Fallback to basic cache.'''
    ),
    (
        '''      // Fallback to basic rate cache''',
        '''      // Fallback basic cache.'''
    ),
    (
        '''        // HomeMetrics caches the rate as a fraction (e.g. 1.0 for 100%), while Medications API uses whole numbers''',
        '''        // Parse fractional rate to percentage.'''
    ),
    (
        '''        // Cache the counts''',
        '''        // Cache medication counts.'''
    ),
    (
        '''      // Fallback to counting from DB''',
        '''      // Fallback to DB count.'''
    ),
    (
        '''        // Cache atomically in a transaction''',
        '''        // Cache data atomically.'''
    ),
    (
        '''          // Cache these medications locally into the Medications table for 'All Medicines'\n''',
        '''          // Cache all medicines locally.\n'''
    ),
    (
        '''          // Specifically cache the exact list for this section to avoid timezone/filtering mismatches offline\n''',
        '''          // Cache sectional medicines directly.\n'''
    ),
    (
        '''      // Fallback to manual DB filtering if JSON cache is missing''',
        '''      // Fallback to DB query filtering.'''
    ),
    (
        '''      // Optimistic Offline Queue''',
        '''      // Queue optimistic offline mutation.'''
    ),
    (
        '''        // Persist the confirm locally too - otherwise it only lives in the
        // controller's in-memory state and reverts to "unconfirmed" if the
        // app restarts before the queued mutation syncs.''',
        '''        // Persist confirmation locally.'''
    ),
    (
        '''        return right(null); // Fake success for UI''',
        '''        return right(null); // Optimistic success.'''
    ),
    (
        '''      // Cache entry missing/corrupt - the Medications table update above
      // still keeps the "All medicines" view and DB-filtered fallback correct.''',
        '''      // Cache mismatch fallback.'''
    ),
    (
        '''  // Keyed by "page-pageSize" - a single shared timestamp would let a fresh
  // page-1 fetch mask the fact that page 2+ was never actually fetched.''',
        '''  // Pagination cache keys.'''
    ),
    (
        '''      // Stale-While-Revalidate check''',
        '''      // Verify cache freshness.'''
    ),
    (
        '''        // Upsert by id instead of clearing first, so medications from other
        // pages already cached aren't wiped out by this page's fetch.''',
        '''        // Upsert medications to avoid wiping other pages.'''
    ),
    (
        '''        // Cache the history locally''',
        '''        // Cache history locally.'''
    ),
    (
        '''        // We do not store full historical logs locally yet, so we return a placeholder.''',
        '''        // Return placeholder for missing logs.'''
    ),
    (
        '''      // Optimistic Offline Queue for creation''',
        '''      // Queue offline creation.'''
    ),
    (
        '''      // Save local optimistic view''',
        '''      // Save optimistic view.'''
    ),
    (
        '''      // Queue mutation''',
        '''      // Queue background mutation.'''
    ),
    (
        '''      // We don't cache per-section dosing schedules or real timestamps
      // locally yet, so this is a best-effort reconstruction from the
      // list row rather than the full remote detail payload.''',
        '''      // Best-effort detail reconstruction from local cache.'''
    ),
    (
        '''      // Fetch local if exists''',
        '''      // Fetch local cache.'''
    ),
    (
        '''        // Update local optimistic view. The Medications table only models a
        // flattened dosage/purpose/single toBeTakenAt per row, so `notes`
        // maps onto `purpose`, but the morning/afternoon/evening dosing
        // schedule edits (time/quantity per section) have no local column to
        // land in - they're still queued below and will apply correctly
        // once the mutation syncs, they just won't be reflected in the
        // optimistic view until then.''',
        '''        // Optimistic local update (schedule edits await sync).'''
    ),
]

for old, new in replacements:
    content = content.replace(old, new)

with open('lib/features/medications/data/repositories/medication_repository_impl.dart', 'w') as f:
    f.write(content)
