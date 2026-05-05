# MARIS — Disaster Recovery Runbook

## Quick Reference
- Railway dashboard: railway.app
- Supabase dashboard: pgcircqhctfgxnddwcgg.supabase.co
- Git repo: github.com/perealeonel0-hash/aida
- Stable tag: v1.0-stable
- DOI: 10.5281/zenodo.19225985

## Scenario 1: Railway is down
**Impact:** Total outage. No chat, no API.
**Recovery:**
1. Check Railway status: status.railway.app
2. If Railway outage: wait. Nothing to do.
3. If our service crashed: check logs in Railway dashboard
4. If code bug: `git revert HEAD && git push origin main`
5. If need rollback: Railway dashboard → Deployments → select previous deploy → Redeploy

## Scenario 2: Anthropic API is down
**Impact:** Chat returns error. Crisis detection still works (EIP is local).
**Recovery:**
1. Check Anthropic status: status.anthropic.com
2. MARIS returns "Error de conexión" to user — this is handled.
3. DeepSeek is NOT used as fallback (security: personal data).
4. Wait for Anthropic recovery. No action needed.

## Scenario 3: Supabase is down
**Impact:** New user registration fails. Memory read/write fails. Chat still works with local data.
**Recovery:**
1. Check Supabase status
2. startup.py has local backup of safety files — server starts without Supabase
3. Chat works with client-provided data (privacy-first design)
4. New registrations fail silently — user gets error
5. When Supabase returns, everything resumes automatically

## Scenario 4: EIP safety files corrupted/deleted
**Impact:** No crisis detection. CRITICAL.
**Recovery:**
1. Check data/safety_backup/ for local copies
2. If backup exists: copy to modules/safety/ and data/
3. If no backup: re-upload from development machine:
   ```bash
   curl -X PUT -H "apikey: $KEY" -H "Authorization: Bearer $KEY" \
     -H "Content-Type: text/x-python" -H "x-upsert: true" \
     --data-binary @modules/safety/eip.py \
     "$SUPABASE_URL/storage/v1/object/aida-safety/eip.py"
   ```
4. Trigger redeploy: `git commit --allow-empty -m "trigger: restore eip" && git push`

## Scenario 5: Brain state corrupted (NaN in tensors)
**Impact:** All responses have wrong friction. Silent corruption.
**Recovery:**
1. Brain.py now guards against NaN (zeroes invalid friction)
2. If corruption persists: delete soul_state.pt locally and in Supabase Storage
3. Brain will reinitialize with random weights and re-learn

## Scenario 6: Need to rollback to known good state
```bash
git checkout v1.0-stable
git push origin main --force  # CAREFUL: this overwrites current main
```
Or use Railway dashboard → Deployments → pick a previous deploy.

## Scenario 7: Session tokens all invalidated
**Cause:** SESSION_SECRET env var missing or changed.
**Fix:** Ensure SESSION_SECRET is set in Railway Variables. All users will need to re-register on next use (graceful — app handles expired tokens).

## Health Check Endpoints
- `GET /brain_map_visual` — returns 200 if server is up
- Non-streaming, fast response
- Monitor this URL for uptime

## Contacts
- Developer: Leonel Perea Pimentel
- Backend: Railway (FastAPI + PyTorch)
- Database: Supabase
- LLM: Anthropic Claude API
