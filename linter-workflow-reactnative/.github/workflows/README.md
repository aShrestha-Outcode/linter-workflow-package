# GitHub Actions Workflows

This directory contains CI/CD workflows for the Outcode React Native App using a **PR-based workflow** where quality checks run on PRs and deployment happens after merge.

## Active Workflows

### 1. `quality.yml` - Code Quality Checks
**Purpose**: Enforces code quality standards on every push and PR.

**Triggers**:
- ✅ **PR opened/updated** (primary - runs on all PRs to protected branches)
- ✅ **Push to feature branches** (early feedback before PR)
- ✅ Manual trigger via `workflow_dispatch`

**What it does**:
- Format check (Prettier)
- Linting (ESLint)
- Tests (Jest)

**Status**: ✅ **This MUST pass before deployment**

---

### 2. `deploy-uat.yml` - UAT Deployment
**Purpose**: Deploy to UAT after PR is merged.

**Triggers**:
- ✅ PR merged to `uat` branch (from `develop`)
- ✅ Manual trigger

**What it does**:
- Verifies PR was merged (not just closed)
- Builds app for UAT (Android & iOS)
- Deploys to UAT environment (mocked)

**Status**: ✅ **ACTIVE** - Used for UAT deployments

---

### 3. `deploy-prod.yml` - Production Deployment
**Purpose**: Deploy to production after PR is merged.

**Triggers**:
- ✅ PR merged to `prod` branch (from `uat`)
- ✅ Manual trigger

**What it does**:
- Verifies PR was merged (not just closed)
- Creates version tag
- Builds app for production (Android & iOS)
- Deploys to production (mocked)

**Status**: ✅ **ACTIVE** - Used for production deployments

---

### 4. `merge-prod-to-main.yml` - Store Approval Merge
**Purpose**: Merge prod → main after store approval.

**Triggers**:
- ✅ Manual trigger (after Apple/Google approval)

**What it does**:
- Merges prod → main
- Creates store-approved tag
- Ensures main reflects live store code

**Status**: ✅ **ACTIVE** - Used after store approval

---

## Complete Workflow Flow

### How Quality Checks and Deployment Work Together

```
Developer creates PR: develop → uat
  ↓
quality.yml runs automatically (on PR)
  ↓
Quality checks: format ✅, lint ✅, tests ✅
  ↓
If FAILS → PR is blocked (can't merge)
If PASSES → PR can be merged
  ↓
Reviewer approves and merges PR
  ↓
deploy-uat.yml triggers automatically
  ↓
Deploys to UAT environment
  ↓
PR: uat → prod (same flow)
  ↓
deploy-prod.yml runs → Deploys to Production
  ↓
Wait for Apple/Google store approval
  ↓
merge-prod-to-main.yml (manual) → Merges prod → main
```

**Key Points**:
- ✅ Quality checks run on PR (blocks merge if fails)
- ✅ Deployment runs only after PR is merged (not on direct push)
- ✅ Branch protection enforces quality gate

---

## Store Approval Workflow

### Important: `prod → main` Merge After Store Approval

This project uses a **store-aligned workflow**:
1. Deploy from `prod` to App Store/Play Store
2. Wait for Apple/Google approval
3. **Only after approval**: Merge `prod → main`

**Why this is smart**:
- ✅ `main` reflects what's actually live in stores
- ✅ No discrepancies between codebase and store versions
- ✅ Clear audit trail of approved deployments
- ✅ Safe rollback (main = live code)

**How to merge after approval**:
1. Go to: **Actions → Merge Prod to Main (After Store Approval)**
2. Click: **Run workflow**
3. Fill in:
   - Version (e.g., v1.1.0)
   - Store approval date
   - Your name/email
4. Approve the workflow (requires manual approval)
5. Workflow merges `prod → main`

---

## Branch Protection Setup

### Prevent Direct Pushes to Protected Branches

To prevent direct pushes to `develop`, `uat`, `prod`, and `main`:

1. Go to: **Settings → Branches → Branch protection rules**
2. Add rule for each protected branch (`develop`, `uat`, `prod`, `main`):
   - ✅ **Require a pull request before merging**
     - ✅ Require approvals: **1** (or **2** for `prod`/`main`)
     - ✅ Dismiss stale pull request approvals when new commits are pushed
   - ✅ **Require status checks to pass before merging** ← **CRITICAL!**
     - ✅ Require branches to be up to date before merging
     - ✅ **Select: "Code Quality / quality (pull_request)"**
       - This is the exact status check name
       - Format: `{workflow_name} / {job_name} ({event})`
       - **Note**: The workflow must run at least once for this to appear in the list
   - ✅ **Restrict who can push to matching branches**
     - ✅ Do not allow bypasses (prevents direct pushes)
   - ✅ **Include administrators** (optional - uncheck to enforce even for admins)

**Important**: After setting up branch protection, create a test PR to verify:
- ✅ Merge button is disabled until quality checks pass
- ✅ Quality check must show ✅ (green) before merge is allowed

**Result**: Developers **cannot** push directly to protected branches. They must:
1. Create a feature branch
2. Push the feature branch
3. Create a PR
4. Get approval
5. Merge via PR

### Local Safeguard (Optional)

A pre-push hook (`.husky/pre-push-branch-protection`) is included as a **local reminder**.
- ⚠️ Can be bypassed with `git push --no-verify`
- ✅ GitHub branch protection is the **real enforcement** (cannot be bypassed)

This ensures:
- ✅ No direct pushes to protected branches
- ✅ PRs can't be merged if quality checks fail
- ✅ Quality checks must pass before merge
- ✅ Deployment only happens after approved merge

---

## Mock Deployments (For Testing)

⚠️ **Current Status**: Deployment workflows use **MOCK steps** to demonstrate the end-to-end flow without requiring actual deployment secrets.

**What's mocked**:
- Build outputs (simulated)
- Store uploads (simulated)
- Notifications (simulated)

**To test the flow**:
1. Create PR: `develop → uat` → Quality runs → Merge → UAT deployment (mocked)
2. Create PR: `uat → prod` → Quality runs → Merge → Production deployment (mocked)
3. After "store approval" → Run "Merge Prod to Main" workflow

**When ready for real deployments**:
- Replace mock steps with actual commands
- Add required secrets in GitHub Settings
- Remove `[MOCK]` labels and `sleep` commands
- Configure iOS certificates and Android keystores
- Set up Fastlane for iOS/Android deployments

---

## Manual Deployment

If you need to deploy manually:

```bash
# Option 1: Trigger via GitHub UI
# Actions → Deploy workflow → Run workflow

# Option 2: Trigger via GitHub CLI
gh workflow run deploy-uat.yml
gh workflow run deploy-prod.yml
```

**Note**: Manual deployment still requires quality checks to have passed (or you can re-run them first).

---

## Example Scenario

### Deploy to UAT

1. **Developer creates PR**:
   ```bash
   # Create feature branch
   git checkout -b feature/new-feature develop
   git commit -m "feat: add new feature"
   git push origin feature/new-feature
   
   # Create PR: feature/new-feature → develop
   # After merge, create PR: develop → uat
   ```

2. **Quality checks run automatically**:
   - `quality.yml` runs on PR
   - Checks format, lint, tests
   - Status: ✅ Pass or ❌ Fail

3. **If quality fails**:
   - PR shows ❌ status
   - PR cannot be merged (blocked by branch protection)
   - Developer fixes issues and pushes
   - Quality checks run again

4. **If quality passes**:
   - PR shows ✅ status
   - Reviewer approves PR
   - PR is merged

5. **Deployment triggers automatically**:
   - `deploy-uat.yml` runs after merge
   - Deploys to UAT environment
   - Team is notified

---

## Troubleshooting

**Issue**: Deployment doesn't trigger after PR merge
- **Check**: PR was actually merged (not just closed)
- **Check**: PR target branch matches workflow trigger (uat/prod)
- **Check**: Workflow file syntax is correct

**Issue**: Quality checks don't block PR
- **Solution**: Set up branch protection rules
- **Solution**: Require "Code Quality" status check

**Issue**: Deployment runs even when quality fails
- **Solution**: Check that branch protection is configured
- **Solution**: Verify quality workflow is required

**Issue**: Want to deploy without PR
- **Solution**: Use manual trigger (`workflow_dispatch`)
- **Note**: Still requires quality checks (unless explicitly skipped)

---

## Workflow Status

| Workflow | Type | Status | When It Runs |
|----------|------|--------|--------------|
| `quality.yml` | Quality | ✅ Active | PR created/updated, push |
| `deploy-uat.yml` | Deployment | ✅ Active | PR merged to uat |
| `deploy-prod.yml` | Deployment | ✅ Active | PR merged to prod |
| `merge-prod-to-main.yml` | Merge | ✅ Active | Manual (after store approval) |

---

## Additional Documentation

- `BRANCH_STRATEGY.md` - Detailed branch strategy explanation
- See main project `README.md` for code quality standards

