# Outcode Git Branching Strategy

## Purpose

This document defines **Outcode's standard Git branching strategy** for . This strategy ensures:
- ✅ Clear code flow from development to production
- ✅ Store-aligned releases (main reflects what's live in stores)
- ✅ Version-based feature development
- ✅ Protected branches with quality gates (PRs required, no direct pushes)
- ✅ Consistent workflow across all projects

### Important: Protected Branches

**Protected branches** (`main`, `develop`, `uat`, `prod`) **cannot** be pushed to directly. You **must** use Pull Requests (PRs) to create or update these branches. This is enforced by:
- ✅ GitHub branch protection rules (server-side, cannot be bypassed)
- ✅ Local Husky hooks (reminder, can be bypassed with `--no-verify`)

**GitHub Actions workflows only trigger on PR merges**, not on direct pushes to protected branches.

---

## Branch Hierarchy

### Core Branches

```
main
  └── develop
       └── uat
            └── prod
```

### Version Branches

```
develop
  └── v1.1.0 (version branch)
       └── feature/abc (feature branch)
```

---

## Branch Creation Flow

### 1. Initial Setup: `main → develop`

**When**: Initial repository setup or when creating a new project

**How** (PR required after initial setup):
1. **Initial creation** (one-time only, before branch protection is enabled):
   ```bash
   # Start from main
   git checkout main
   git pull origin main
   
   # Create develop branch from main
   git checkout -b develop
   git push origin develop
   ```
2. **After branch protection is enabled**: Use PRs only
   - Create PR: `main → develop` (or from feature branch)
   - Get approval and merge

**Important**: Once branch protection is enabled, you **cannot** push directly to `develop`. You must use PRs.

**Purpose**: `develop` is the integration branch for all development work.

---

### 2. Development to UAT: `develop → uat`

**When**: Code is ready for UAT testing

**How** (PR required - `uat` is a protected branch):
1. **Create PR**: `develop → uat` on GitHub
   - If `uat` branch doesn't exist yet, GitHub will create it when you create the PR
   - Source: `develop`
   - Target: `uat` (create new branch if it doesn't exist)
2. **Quality checks run automatically** (via GitHub Actions)
3. **Get approval**: At least 1 reviewer approval required
4. **Merge PR**: Merge into `uat` branch

**Important**: 
- ❌ **Cannot push directly** to `uat` (branch protection blocks it)
- ✅ **Must use PR** to create/update `uat` branch
- ✅ GitHub Actions only triggers on PR merge (not on direct push)

**Purpose**: `uat` is the User Acceptance Testing environment.

---

### 3. UAT to Production: `uat → prod`

**When**: Code passes UAT and is ready for production

**How** (PR required - `prod` is a protected branch):
1. **Create PR**: `uat → prod` on GitHub
   - If `prod` branch doesn't exist yet, GitHub will create it when you create the PR
   - Source: `uat`
   - Target: `prod` (create new branch if it doesn't exist)
2. **Quality checks run automatically** (via GitHub Actions)
3. **Get approval**: At least 1-2 reviewer approvals required (configurable)
4. **Merge PR**: Merge into `prod` branch
5. **Deployment runs automatically** after merge (via GitHub Actions)

**Important**: 
- ❌ **Cannot push directly** to `prod` (branch protection blocks it)
- ✅ **Must use PR** to create/update `prod` branch
- ✅ GitHub Actions only triggers on PR merge (not on direct push)

**Purpose**: `prod` is the production branch that gets deployed to App Store/Play Store.

---

### 4. Version Branch: `develop → v1.1.0`

**When**: Starting work on a specific version release

**How**:
```bash
# Ensure develop is up to date
git checkout develop
git pull origin develop

# Create version branch from develop
git checkout -b v1.1.0
git push origin v1.1.0
```

**Purpose**: Version branches isolate work for a specific release version.

**Naming Convention**: `v{MAJOR}.{MINOR}.{PATCH}` (e.g., `v1.1.0`, `v2.0.0`)

---

### 5. Feature Branch: `v1.1.0 → feature/abc`

**When**: Starting work on a new feature

**How**:
```bash
# Ensure version branch is up to date
git checkout v1.1.0
git pull origin v1.1.0

# Create feature branch from version branch
git checkout -b feature/abc
git push origin feature/abc
```

**Purpose**: Feature branches isolate individual features for development and review.

**Naming Convention**: `feature/{description}` (e.g., `feature/user-auth`, `feature/dark-mode`)

---

## Branch Merge Process

### Standard Flow

```
feature/abc → v1.1.0 → develop → uat → prod → main
```

### Step-by-Step Merge Process

#### Step 1: Feature → Version Branch

**When**: Feature is complete and ready for review

**Process**:
1. **Create PR**: `feature/abc → v1.1.0`
2. **Quality checks run automatically** (via GitHub Actions)
3. **Code review**: Get approval from team member
4. **Merge PR**: Merge into `v1.1.0`

**Commands**:
```bash
# On feature branch
git checkout feature/abc
git pull origin feature/abc

# Create PR on GitHub: feature/abc → v1.1.0
# Or merge locally (if allowed):
git checkout v1.1.0
git merge feature/abc
git push origin v1.1.0
```

**Requirements**:
- ✅ Quality checks must pass
- ✅ At least 1 approval
- ✅ No merge conflicts

---

#### Step 2: Version Branch → Develop

**When**: Version is ready for integration into develop

**Process**:
1. **Create PR**: `v1.1.0 → develop`
2. **Quality checks run automatically**
3. **Code review**: Get approval
4. **Merge PR**: Merge into `develop`

**Important Notes**:
- ❌ **Cannot merge locally** - `develop` is protected, must use GitHub PR
- ❌ **Cannot push directly** - Branch protection blocks direct pushes
- ✅ **PR is the only way** to update `develop` branch

**Requirements**:
- ✅ Quality checks must pass (blocks merge if fails)
- ✅ At least 1 approval (enforced by branch protection)
- ✅ No merge conflicts
- ✅ Branch must be up to date

---

#### Step 3: Develop → UAT

**When**: Code is ready for UAT testing

**Process**:
1. **Create PR**: `develop → uat` on GitHub
2. **Quality checks run automatically** (via GitHub Actions)
3. **Code review**: Get approval (at least 1 required)
4. **Merge PR**: Merge into `uat` (only possible after checks pass and approval)
5. **Deployment**: `deploy-uat.yml` runs automatically after merge

**Important Notes**:
- ❌ **Cannot merge locally** - `uat` is protected, must use GitHub PR
- ❌ **Cannot push directly** - Branch protection blocks direct pushes
- ✅ **PR is the only way** to update `uat` branch

**Requirements**:
- ✅ Quality checks must pass (blocks merge if fails)
- ✅ At least 1 approval (enforced by branch protection)
- ✅ No merge conflicts
- ✅ Branch must be up to date

**After merge**: UAT deployment runs automatically (via GitHub Actions `deploy-uat.yml`)

---

#### Step 4: UAT → Prod

**When**: Code passes UAT and is ready for production

**Process**:
1. **Create PR**: `uat → prod` on GitHub
2. **Quality checks run automatically** (via GitHub Actions)
3. **Code review**: Get approval (requires 2 approvals for `prod`)
4. **Merge PR**: Merge into `prod` (only possible after checks pass and approvals)
5. **Deployment**: `deploy-prod.yml` runs automatically after merge
6. **Version tag**: Created automatically by workflow

**Important Notes**:
- ❌ **Cannot merge locally** - `prod` is protected, must use GitHub PR
- ❌ **Cannot push directly** - Branch protection blocks direct pushes
- ✅ **PR is the only way** to update `prod` branch

**Requirements**:
- ✅ Quality checks must pass (blocks merge if fails)
- ✅ At least 2 approvals (enforced by branch protection)
- ✅ No merge conflicts
- ✅ Branch must be up to date

**After merge**: Production deployment runs automatically (via GitHub Actions `deploy-prod.yml`)

---

#### Step 5: Prod → Main (After Store Approval)

**When**: App is approved by Apple/Google stores

**Process**:
1. **Wait for store approval**: App Store/Play Store approval
2. **Manual trigger**: Run `merge-prod-to-main.yml` workflow
3. **Provide details**:
   - Version (e.g., v1.1.0)
   - Store approval date
   - Approved by (name/email)
4. **Manual approval**: Approve the workflow
5. **Merge**: `prod → main` happens automatically

**Why after store approval**:
- ✅ `main` reflects what's actually live in stores
- ✅ No discrepancies between codebase and store versions
- ✅ Clear audit trail of approved deployments
- ✅ Safe rollback (main = live code)

**Commands** (via GitHub Actions workflow):
```bash
# This is done via GitHub Actions UI:
# Actions → Merge Prod to Main (After Store Approval) → Run workflow
```

**Requirements**:
- ✅ Store approval received
- ✅ Manual workflow trigger
- ✅ Manual approval in GitHub

---

## Complete Workflow Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                    Feature Development                       │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
                    ┌─────────────────┐
                    │  feature/abc    │
                    └────────┬────────┘
                             │ PR + Review
                             ▼
                    ┌─────────────────┐
                    │    v1.1.0       │
                    └────────┬────────┘
                             │ PR + Review
                             ▼
┌─────────────────────────────────────────────────────────────┐
│                    Integration & Testing                     │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
                    ┌─────────────────┐
                    │    develop      │
                    └────────┬────────┘
                             │ PR + Review
                             ▼
                    ┌─────────────────┐
                    │      uat         │
                    │  (Auto Deploy)   │
                    └────────┬────────┘
                             │ PR + Review
                             ▼
┌─────────────────────────────────────────────────────────────┐
│                    Production & Release                      │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
                    ┌─────────────────┐
                    │      prod        │
                    │  (Auto Deploy)   │
                    │  (Create Tag)   │
                    └────────┬────────┘
                             │
                             │ Wait for Store Approval
                             │
                             ▼
                    ┌─────────────────┐
                    │      main       │
                    │ (Store Aligned) │
                    └─────────────────┘
```

---

## Branch Protection Rules

### Protected Branches

The following branches are **protected** and require PRs:
- ✅ `main`
- ✅ `develop`
- ✅ `uat`
- ✅ `prod`

### GitHub Branch Protection Setup

#### For `develop` Branch

**Settings**:
1. Go to: **Settings → Branches → Branch protection rules**
2. Click: **Add rule**
3. Branch name pattern: `develop`

**Configure**:
- ✅ **Require a pull request before merging**
  - ✅ Require approvals: **1**
  - ✅ Dismiss stale pull request approvals when new commits are pushed
  - ✅ Require review from Code Owners (if CODEOWNERS file exists)

- ✅ **Require status checks to pass before merging** ← **CRITICAL!**
  - ✅ Require branches to be up to date before merging
  - ✅ **Select: "Code Quality / quality (pull_request)"**
    - This is the exact status check name
    - Format: `{workflow_name} / {job_name} ({event})`
    - **Note**: The workflow must run at least once for this to appear

- ✅ **Restrict who can push to matching branches**
  - ✅ Do not allow bypasses (prevents direct pushes)
  - ✅ Include administrators (optional - uncheck to enforce even for admins)

- ✅ **Require conversation resolution before merging**
  - ✅ Require all conversations on the pull request to be resolved

- ✅ **Require linear history** (optional but recommended)
  - ✅ Prevent merge commits (enforces squash or rebase)

**Save**: Click **Create** or **Save changes**

---

#### For `uat` Branch

**Settings**: Same as `develop`, but consider:
- ✅ Require approvals: **1** (same as develop)
- ✅ Same status checks requirement

---

#### For `prod` Branch

**Settings**: Stricter than `develop` and `uat`:
- ✅ **Require a pull request before merging**
  - ✅ Require approvals: **2** (more strict)
  - ✅ Dismiss stale pull request approvals when new commits are pushed
  - ✅ Require review from Code Owners

- ✅ **Require status checks to pass before merging**
  - ✅ Require branches to be up to date before merging
  - ✅ **Select: "Code Quality / quality (pull_request)"**

- ✅ **Restrict who can push to matching branches**
  - ✅ Do not allow bypasses
  - ✅ Include administrators: **Unchecked** (enforce even for admins)

- ✅ **Require conversation resolution before merging**
  - ✅ Require all conversations to be resolved

- ✅ **Require linear history**
  - ✅ Prevent merge commits

**Save**: Click **Create** or **Save changes**

---

#### For `main` Branch

**Settings**: Same as `prod` (most strict):
- ✅ Require approvals: **2**
- ✅ All status checks required
- ✅ No bypasses (even for admins)
- ✅ Linear history required

---

#### For Version Branches (`v*.*.*`)

**Settings**: Similar to `develop`:
- ✅ Require approvals: **1**
- ✅ Status checks required
- ✅ No direct pushes

**Branch name pattern**: `v*.*.*` (wildcard pattern)

---

### Summary of Protection Rules

| Branch | Approvals Required | Status Checks | Direct Push | Admin Bypass |
|--------|-------------------|--------------|-------------|--------------|
| `main` | 2 | ✅ Required | ❌ Blocked | ❌ No |
| `prod` | 2 | ✅ Required | ❌ Blocked | ❌ No |
| `uat` | 1 | ✅ Required | ❌ Blocked | ⚠️ Optional |
| `develop` | 1 | ✅ Required | ❌ Blocked | ⚠️ Optional |
| `v*.*.*` | 1 | ✅ Required | ✅ Allowed | ✅ Yes |
| `feature/*` | 0 | ⚠️ Optional | ✅ Allowed | ✅ Yes |

---

## Branch Naming Conventions

### Core Branches

- `main` - Production-ready code (aligned with stores)
- `develop` - Integration branch for development
- `uat` - User Acceptance Testing environment
- `prod` - Production deployment branch

### Version Branches

- Format: `v{MAJOR}.{MINOR}.{PATCH}`
- Examples: `v1.0.0`, `v1.1.0`, `v2.0.0`
- Created from: `develop`
- Purpose: Isolate work for a specific version release

### Feature Branches

- Format: `feature/{description}`
- Examples: `feature/user-auth`, `feature/dark-mode`, `feature/payment-integration`
- Created from: Version branch (e.g., `v1.1.0`)
- Purpose: Isolate individual features for development

### Other Branch Types (Optional)

- `hotfix/{description}` - Critical production fixes
- `release/{version}` - Release candidate branches
- `bugfix/{description}` - Bug fixes

---

## Workflow Examples

### Example 1: New Feature Development

**Scenario**: Adding user authentication feature for v1.2.0

**Steps**:
```bash
# 1. Create version branch from develop
git checkout develop
git pull origin develop
git checkout -b v1.2.0
git push origin v1.2.0

# 2. Create feature branch from version branch
git checkout v1.2.0
git checkout -b feature/user-auth
git push origin feature/user-auth

# 3. Develop feature
git add .
git commit -m "feat(auth): add user authentication"
git push origin feature/user-auth

# 4. Create PR: feature/user-auth → v1.2.0
# 5. Get approval and merge

# 6. Create PR: v1.2.0 → develop
# 7. Get approval and merge

# 8. Create PR: develop → uat
# 9. Get approval and merge (UAT deployment runs)

# 10. Create PR: uat → prod
# 11. Get approval and merge (Production deployment runs)

# 12. After store approval: Run "Merge Prod to Main" workflow
```

---

### Example 2: Hotfix

**Scenario**: Critical bug in production

**Steps**:
```bash
# 1. Create hotfix branch from prod
git checkout prod
git pull origin prod
git checkout -b hotfix/critical-bug
git push origin hotfix/critical-bug

# 2. Fix bug
git add .
git commit -m "fix: resolve critical production bug"
git push origin hotfix/critical-bug

# 3. Create PR: hotfix/critical-bug → prod
# 4. Fast-track approval and merge

# 5. After store approval: Run "Merge Prod to Main" workflow

# 6. Merge hotfix back to develop (via PR)
# Create PR: hotfix/critical-bug → develop
# Get approval and merge
```

---

### Example 3: Version Release

**Scenario**: Releasing v1.1.0

**Steps**:
```bash
# 1. All features merged to v1.1.0
# 2. Create PR: v1.1.0 → develop
# 3. Merge to develop

# 4. Create PR: develop → uat
# 5. Merge to uat (UAT testing)

# 6. Create PR: uat → prod
# 7. Merge to prod (Production deployment)

# 8. Wait for store approval
# 9. Run "Merge Prod to Main" workflow
```

---

## Best Practices

### ✅ Do This

1. **Always create feature branches from version branches**
   - ✅ `feature/abc` from `v1.1.0`
   - ❌ Not from `develop` directly

2. **Use PRs for all merges to protected branches**
   - ✅ Create PR on GitHub
   - ❌ Don't merge locally (unless absolutely necessary)

3. **Wait for quality checks to pass before merging**
   - ✅ All status checks must be green
   - ❌ Don't merge with failing checks

4. **Merge prod → main only after store approval**
   - ✅ Wait for Apple/Google approval
   - ❌ Don't merge before approval

5. **Keep branches up to date**
   - ✅ Pull latest changes before creating branches
   - ✅ Rebase feature branches if needed

6. **Use descriptive branch names**
   - ✅ `feature/user-authentication`
   - ❌ `feature/abc` or `feature/new`

7. **Delete merged branches**
   - ✅ Delete feature branches after merge
   - ✅ Keep version branches until release is complete

---

### ❌ Don't Do This

1. **Don't commit directly to protected branches**
   - ❌ `git commit` on `develop`, `uat`, `prod`, `main`
   - ✅ Always use feature branches

2. **Don't push directly to protected branches**
   - ❌ `git push origin develop`
   - ✅ Always use PRs

3. **Don't merge without approval**
   - ❌ Merge your own PRs
   - ✅ Get at least 1 approval (2 for prod/main)

4. **Don't merge with failing checks**
   - ❌ Merge PRs with ❌ status checks
   - ✅ Wait for all checks to pass

5. **Don't merge prod → main before store approval**
   - ❌ Merge immediately after prod deployment
   - ✅ Wait for store approval first

6. **Don't create branches from wrong source**
   - ❌ `feature/abc` from `develop` (should be from version branch)
   - ✅ `feature/abc` from `v1.1.0`

---

## Troubleshooting

### Issue: Can't Push to Protected Branch

**Error**: "You cannot push directly to this branch"

**Solution**:
1. Create a feature branch instead
2. Push the feature branch
3. Create a PR to the protected branch

---

### Issue: PR Can't Be Merged (Status Checks Pending)

**Error**: "Merging is blocked: Required status check 'Code Quality' is pending"

**Solution**:
1. Wait for quality checks to complete
2. If checks fail, fix issues and push again
3. Once checks pass, merge will be enabled

---

### Issue: Merge Conflicts

**Error**: "This branch has conflicts that must be resolved"

**Solution**:
1. Update your branch with latest changes:
   ```bash
   git checkout feature/abc
   git pull origin develop  # or target branch
   ```
2. Resolve conflicts
3. Commit and push
4. PR will update automatically

---

### Issue: Need to Bypass Branch Protection

**When**: Emergency hotfix or initial setup

**Solution**:
1. **For initial setup**: Use `ALLOW_PROTECTED_BRANCHES=true` (local hooks only)
2. **For emergency**: Temporarily disable branch protection (not recommended)
3. **Better**: Use hotfix branch and fast-track PR approval

---

## Version Branch Lifecycle Management

### When to Create Version Branches

**Timing**: Create version branches when:
- ✅ Starting work on a new release version (e.g., v1.2.0)
- ✅ Planning features for a specific release
- ✅ Need to isolate work for a version release
- ✅ Multiple features will be developed for the same version

**Best Practice**: Create version branches early in the release cycle, before feature development begins.

**Example Timeline**:
```
Week 1: Create v1.2.0 branch from develop
Week 2-4: Develop features in feature branches (from v1.2.0)
Week 5: Merge all features to v1.2.0
Week 6: Merge v1.2.0 → develop → uat → prod
```

---

### How to Handle Multiple Features in the Same Version Branch

**Scenario**: Multiple developers working on different features for the same version (e.g., v1.2.0)

**Process**:
1. **All developers create feature branches from the same version branch**:
   ```bash
   # Developer 1
   git checkout v1.2.0
   git checkout -b feature/user-auth
   
   # Developer 2
   git checkout v1.2.0
   git checkout -b feature/dark-mode
   
   # Developer 3
   git checkout v1.2.0
   git checkout -b feature/payment
   ```

2. **Develop features independently**:
   - Each developer works on their feature branch
   - No conflicts (isolated work)
   - Can develop in parallel

3. **Merge features to version branch via PRs**:
   - Create PR: `feature/user-auth → v1.2.0`
   - Create PR: `feature/dark-mode → v1.2.0`
   - Create PR: `feature/payment → v1.2.0`
   - Merge each PR after approval

4. **Coordinate merges**:
   - Merge features one at a time (easier conflict resolution)
   - Or merge in parallel if no conflicts expected
   - Test version branch after each merge

**Best Practices**:
- ✅ Keep version branch up to date
- ✅ Merge features incrementally (not all at once)
- ✅ Test version branch after each feature merge
- ✅ Communicate with team about merge order

---

### What to Do When a Version Branch is Complete

**When**: All features for the version are merged and tested

**Process**:
1. **Final testing**:
   - Run full test suite on version branch
   - Verify all features work together
   - Check for integration issues

2. **Create PR to develop**:
   - PR: `v1.2.0 → develop`
   - Get approval
   - Merge to develop

3. **Continue release flow**:
   - PR: `develop → uat`
   - PR: `uat → prod`
   - Deploy to production

4. **Keep version branch** (don't delete yet):
   - Keep until release is complete
   - Keep until store approval
   - Keep until merged to main

---

### How to Close/Archive Version Branches After Release

**When**: Version is released, approved by stores, and merged to main

**Process**:
1. **Verify release is complete**:
   - ✅ Version deployed to production
   - ✅ Store approval received
   - ✅ Merged to main (`prod → main`)

2. **Tag the version branch** (if not already tagged):
   ```bash
   git checkout v1.2.0
   git tag -a v1.2.0 -m "Release v1.2.0"
   git push origin v1.2.0 --tags
   ```

3. **Archive or delete**:
   - **Option 1: Keep for reference** (recommended):
     - Leave branch as-is
     - Add note in PR/commit: "Version complete, keeping for reference"
     - Branch serves as historical record
   
   - **Option 2: Delete** (if you want to clean up):
     ```bash
     # Delete locally
     git branch -d v1.2.0
     
     # Delete remotely
     git push origin --delete v1.2.0
     ```

**Best Practice**: Keep version branches for at least 3-6 months for reference, then archive or delete.

---

## Conflict Resolution

### Step-by-Step Process for Resolving Merge Conflicts in PRs

**When**: PR shows "This branch has conflicts that must be resolved"

**Process**:

#### Option 1: Resolve via GitHub UI (Recommended for Simple Conflicts)

1. **Go to PR page** on GitHub
2. **Click "Resolve conflicts"** button
3. **GitHub shows conflict markers**:
   ```
   <<<<<<< feature/abc
   Your changes
   =======
   Changes from target branch
   >>>>>>> develop
   ```
4. **Edit the file** to resolve conflicts:
   - Keep your changes
   - Keep their changes
   - Combine both
   - Write new code
5. **Mark as resolved** for each file
6. **Click "Mark as resolved"** for all conflicts
7. **Click "Commit merge"**
8. **PR updates automatically** with resolved conflicts

#### Option 2: Resolve Locally (For Complex Conflicts)

1. **Update your branch**:
   ```bash
   git checkout feature/abc
   git pull origin develop  # or target branch
   ```

2. **Git shows conflicts**:
   ```
   Auto-merging lib/main.dart
   CONFLICT (content): Merge conflict in lib/main.dart
   ```

3. **Open conflicted files** and resolve:
   ```dart
   // Before (conflict markers)
   <<<<<<< HEAD
   void myFunction() {
     // Your code
   }
   =======
   void myFunction() {
     // Their code
   }
   >>>>>>> develop
   
   // After (resolved)
   void myFunction() {
     // Combined code
   }
   ```

4. **Stage resolved files**:
   ```bash
   git add lib/main.dart
   ```

5. **Complete the merge**:
   ```bash
   git commit -m "fix: resolve merge conflicts with develop"
   ```

6. **Push to update PR**:
   ```bash
   git push origin feature/abc
   ```

7. **PR updates automatically** with resolved conflicts

---

### How to Rebase Feature Branches

**When**: You want a linear history or need to update your branch with latest changes

**Process**:
1. **Update your branch**:
   ```bash
   git checkout feature/abc
   git fetch origin
   git rebase origin/develop  # or target branch
   ```

2. **If conflicts occur**:
   ```bash
   # Git pauses at each conflict
   # Resolve conflicts in files
   git add lib/main.dart  # Stage resolved file
   git rebase --continue  # Continue rebase
   ```

3. **Repeat** until rebase is complete

4. **Force push** (required after rebase):
   ```bash
   git push --force-with-lease origin feature/abc
   ```

**⚠️ Warning**: Only force push to feature branches, never to protected branches!

**When to use rebase**:
- ✅ Want linear history
- ✅ Feature branch is not shared with others
- ✅ Before creating PR (clean history)

**When NOT to use rebase**:
- ❌ Branch is shared with other developers
- ❌ PR is already open and reviewed
- ❌ Working on protected branches

---

### When to Use Merge vs Rebase

**Use Merge** (default, recommended):
- ✅ PRs to protected branches (always use merge)
- ✅ Shared branches
- ✅ When you want to preserve history
- ✅ When PR is already open

**Use Rebase** (optional, for clean history):
- ✅ Personal feature branches (before PR)
- ✅ Want linear history
- ✅ Branch is not shared

**Best Practice**: Use merge for PRs, rebase only for personal branches before creating PR.

---

### How to Handle Conflicts When Merging Version → Develop

**Scenario**: Merging `v1.2.0 → develop` has conflicts

**Process**:
1. **Identify conflict source**:
   - Check what changed in `develop` since `v1.2.0` was created
   - Usually: other features merged to develop

2. **Resolve conflicts**:
   - Use GitHub UI or local merge
   - Prefer changes from version branch (your release)
   - But incorporate important fixes from develop

3. **Test thoroughly**:
   - Run full test suite
   - Verify all features still work
   - Check integration

4. **Merge PR**:
   - Get approval
   - Merge to develop

**Prevention**:
- ✅ Keep version branch updated with develop periodically
- ✅ Merge develop → version branch before final merge
- ✅ Communicate with team about changes

---

## CI/CD Failure Handling

### How to Re-run Failed Quality Checks

**When**: Quality checks fail in PR

**Options**:

#### Option 1: Re-run via GitHub UI (Easiest)

1. **Go to PR page** on GitHub
2. **Scroll to "Checks" section**
3. **Click on failed check** (e.g., "Code Quality / quality")
4. **Click "Re-run jobs"** or "Re-run failed jobs"
5. **Wait for checks to complete**

#### Option 2: Push New Commit (Triggers Re-run)

1. **Fix the issue** locally
2. **Commit and push**:
   ```bash
   git add .
   git commit -m "fix: resolve quality check failures"
   git push origin feature/abc
   ```
3. **Checks run automatically** on new commit

#### Option 3: Re-run via GitHub Actions

1. **Go to**: Actions tab → Workflow runs
2. **Find failed run**
3. **Click "Re-run all jobs"**

---

### What to Do When CI Fails After Local Hooks Pass

**Scenario**: Pre-push hooks pass locally, but CI fails

**Possible Causes**:
1. **Environment differences** (Flutter/Node versions)
2. **Cached dependencies** (local vs CI)
3. **Timing issues** (race conditions)
4. **Missing files** (not committed)

**Process**:
1. **Check CI logs**:
   - Go to PR → Checks → Failed check
   - Read error messages
   - Identify root cause

2. **Common fixes**:
   ```bash
   # Ensure versions match
   flutter --version  # Should match .fvmrc
   node --version     # Should match .nvmrc
   
   # Clear caches
   flutter clean
   rm -rf node_modules
   npm install
   
   # Run checks locally again
   npm run quality:ci
   ```

3. **Fix and push**:
   - Fix the issue
   - Commit and push
   - CI runs again

4. **If still failing**:
   - Check CI logs for specific error
   - Ask team for help
   - Create ticket if it's a CI issue

---

### How to Debug CI Failures

**Process**:
1. **Read CI logs**:
   - Go to: PR → Checks → Failed check → Logs
   - Scroll to error message
   - Look for stack traces

2. **Common issues**:
   - **Version mismatch**: Check `.fvmrc` and `.nvmrc`
   - **Missing dependencies**: Check `pubspec.yaml` and `package.json`
   - **Test failures**: Check test output
   - **Formatting issues**: Run `dart format .`
   - **Analysis errors**: Run `flutter analyze`

3. **Reproduce locally**:
   ```bash
   # Match CI environment
   fvm use  # Use FVM version
   nvm use  # Use Node version
   
   # Run same commands as CI
   npm ci
   flutter pub get
   npm run quality:ci
   ```

4. **Fix and verify**:
   - Fix the issue
   - Run checks locally
   - Push to trigger CI

---

### Process for Handling Flaky Tests

**When**: Tests pass sometimes, fail other times (non-deterministic)

**Process**:
1. **Identify flaky test**:
   - Check CI logs for test name
   - Note when it fails (randomly)

2. **Reproduce locally**:
   ```bash
   # Run test multiple times
   flutter test test/your_test.dart
   # Run 10 times to see if it fails
   for i in {1..10}; do flutter test test/your_test.dart; done
   ```

3. **Fix the test**:
   - Add proper setup/teardown
   - Fix timing issues
   - Mock external dependencies
   - Remove race conditions

4. **If can't fix immediately**:
   - **Temporary**: Skip the test with `@Skip` annotation
   - **Create ticket**: Document the flaky test
   - **Fix later**: Prioritize fixing in next sprint

5. **Re-run CI**:
   - Push fix
   - Verify test passes consistently

**Best Practice**: Fix flaky tests immediately - they reduce confidence in CI.

---

## Emergency/Hotfix Procedures

### Detailed Hotfix Workflow (from prod → hotfix → back to develop)

**Scenario**: Critical bug in production that needs immediate fix

**Process**:

#### Step 1: Create Hotfix Branch from Prod

```bash
# Ensure prod is up to date
git checkout prod
git pull origin prod

# Create hotfix branch
git checkout -b hotfix/critical-bug
git push origin hotfix/critical-bug
```

#### Step 2: Fix the Bug

```bash
# Make the fix
git add .
git commit -m "fix: resolve critical production bug"
git push origin hotfix/critical-bug
```

#### Step 3: Fast-Track PR to Prod

1. **Create PR**: `hotfix/critical-bug → prod`
2. **Request fast-track approval**:
   - Tag tech lead/principal engineer
   - Explain urgency in PR description
   - Request expedited review
3. **Get approval** (may require 2 approvals, but can be fast-tracked)
4. **Merge PR** (quality checks must still pass)

#### Step 4: Deploy to Production

- `deploy-prod.yml` runs automatically after merge
- Deploy to App Store/Play Store
- Monitor for issues

#### Step 5: After Store Approval - Merge to Main

- Wait for store approval
- Run "Merge Prod to Main" workflow
- Merge `prod → main`

#### Step 6: Merge Hotfix Back to Develop

```bash
# Create PR: hotfix/critical-bug → develop
# Get approval and merge
# This ensures develop has the fix too
```

**Complete Flow**:
```
prod → hotfix/critical-bug → prod → main
                              ↓
                           develop
```

---

### How to Fast-Track Hotfix PRs

**Process**:
1. **Create PR with clear urgency**:
   - Title: `[HOTFIX] fix: critical production bug`
   - Description: Explain impact and urgency
   - Tag: `hotfix` or `urgent`

2. **Notify team immediately**:
   - Tag tech lead in PR
   - Post in team Slack/chat
   - Explain why it's urgent

3. **Request expedited review**:
   - Ask for immediate review
   - Explain business impact
   - Provide context

4. **Get approval**:
   - May still require approvals (for prod) depends on if there is a approvcal process/ principle engineer in the team
   - But reviewers can prioritize
   - Tech lead can approve quickly

5. **Merge immediately** after approval

**Note**: Quality checks must still pass - don't skip them even for hotfixes!

---

### Who Can Approve Emergency Merges

**Approvers** (in order of preference):
1. **Tech Lead** - Can approve any PR (lead of the project)
2. **Principal Engineer** - Can approve any PR
3. **Engineering Manager** - Can approve any PR

**Process**:
1. **Tag approver** in PR
2. **Explain urgency** and impact
3. **Get approval** (can be verbal/Slack, then approve in GitHub)
4. **Merge PR**

**Documentation**: Always document why emergency approval was needed in PR description.

---

### How to Handle Critical Production Issues

**Severity Levels**:

**P0 - Critical** (Service down, data loss):
- ✅ Immediate hotfix
- ✅ Fast-track approval
- ✅ Deploy immediately
- ✅ Post-mortem required

**P1 - High** (Major feature broken):
- ✅ Hotfix within 4 hours
- ✅ Fast-track approval
- ✅ Deploy same day
- ✅ Post-mortem recommended

**P2 - Medium** (Minor feature broken):
- ✅ Fix in next release
- ✅ Normal PR process
- ✅ No fast-track needed

**Process for P0/P1**:
1. **Assess impact** (how many users affected?)
2. **Create hotfix branch** from prod
3. **Fix the issue**
4. **Fast-track PR** (tag approvers)
5. **Deploy immediately** after merge
6. **Monitor** for issues
7. **Merge to main** after store approval
8. **Merge back to develop**
9. **Post-mortem** (for P0 issues)

---

## Documentation Updates

### When to Update Documentation in the Workflow

**Update documentation when**:
- ✅ Adding new features (update feature docs)
- ✅ Changing processes (update workflow docs)
- ✅ Fixing bugs (update troubleshooting)
- ✅ Adding new tools (update setup docs)
- ✅ Changing team structure (update contact info)

**Best Practice**: Update docs as part of the feature PR, not separately.

---

### How to Handle Documentation-Only PRs

**Process**:
1. **Create feature branch** (even for docs):
   ```bash
   git checkout develop
   git checkout -b docs/update-readme
   ```

2. **Make documentation changes**:
   - Update relevant docs
   - Follow documentation style guide
   - Add examples if needed

3. **Create PR**:
   - PR: `docs/update-readme → develop`
   - Title: `docs: update README with new setup instructions`
   - Description: Explain what changed and why

4. **Review process**:
   - ✅ Quality checks still run (formatting, etc.)
   - ✅ Get approval (can be lighter review)
   - ✅ Merge to develop

**Note**: Documentation PRs still go through normal PR process, but review can be faster.

---

### Documentation Review Process

**Reviewers**:
- **Tech Lead** - For process/architecture docs
- **Any team member** - For feature docs
- **Documentation owner** - For major doc changes

**Review Checklist**:
- ✅ Accuracy (information is correct)
- ✅ Clarity (easy to understand)
- ✅ Completeness (covers all cases)
- ✅ Examples (has working examples)
- ✅ Formatting (follows style guide)

**Process**:
1. **Create PR** with documentation changes
2. **Request review** from appropriate reviewer
3. **Address feedback** in PR
4. **Get approval**
5. **Merge PR**

---

## Branch Lifecycle Management

### When to Delete Feature Branches (After Merge)

**When**: Feature branch is merged and no longer needed

**Process**:
1. **After PR is merged**:
   - GitHub shows "Delete branch" button
   - Click to delete remotely

2. **Delete locally**:
   ```bash
   git checkout develop
   git branch -d feature/abc  # Delete local branch
   ```

3. **Clean up remote tracking**:
   ```bash
   git remote prune origin  # Remove stale remote branches
   ```

**Best Practice**: Delete feature branches immediately after merge (keeps repo clean).

---

### When to Delete Version Branches (After Release)

**When**: Version is complete, released, and merged to main

**Timeline**:
- ✅ Keep until release is complete (merged to prod)
- ✅ Keep until store approval received
- ✅ Keep until merged to main
- ✅ Keep for 3-6 months for reference
- ✅ Then archive or delete

**Process**:
1. **Verify release is complete**:
   - ✅ Deployed to production
   - ✅ Store approval received
   - ✅ Merged to main

2. **Tag the version** (if not already tagged):
   ```bash
   git tag -a v1.2.0 -m "Release v1.2.0"
   git push origin v1.2.0 --tags
   ```

3. **Archive or delete**:
   - **Archive**: Add note, keep for reference
   - **Delete**: Remove if no longer needed

---

### How to Archive Old Branches

**Process**:
1. **Tag the branch** (for reference):
   ```bash
   git checkout v1.0.0
   git tag -a archive/v1.0.0 -m "Archived version branch v1.0.0"
   git push origin archive/v1.0.0 --tags
   ```

2. **Add note in branch** (via PR or commit):
   - Commit message: "chore: archive version branch v1.0.0"
   - PR description: "Archiving old version branch"

3. **Keep or delete**:
   - **Keep**: Leave branch as-is (serves as historical record)
   - **Delete**: Remove if confident it's not needed

**Best Practice**: Keep archived branches for at least 6 months, then delete.

---

### Branch Cleanup Process

**Regular cleanup** (monthly or quarterly):

1. **List all branches**:
   ```bash
   git branch -a  # Local and remote
   ```

2. **Identify branches to clean**:
   - ✅ Merged feature branches (delete)
   - ✅ Old version branches (archive or delete)
   - ✅ Abandoned feature branches (check with team, then delete)

3. **Delete merged branches**:
   ```bash
   # Delete local branches that are merged
   git branch --merged develop | grep -v "\*\|develop\|main\|uat\|prod" | xargs -n 1 git branch -d
   
   # Delete remote branches that are merged
   git branch -r --merged develop | grep -v "develop\|main\|uat\|prod" | sed 's/origin\///' | xargs -n 1 git push origin --delete
   ```

4. **Archive old version branches**:
   - Tag them
   - Add notes
   - Keep or delete based on age

**Automation**: Consider GitHub Actions workflow for automatic branch cleanup.

---

## Multi-Developer Workflow

### How Multiple Developers Work on the Same Version Branch

**Scenario**: Team working on v1.2.0 with multiple features

**Process**:
1. **All developers create feature branches from same version branch**:
   ```bash
   # Developer A
   git checkout v1.2.0
   git checkout -b feature/user-auth
   
   # Developer B
   git checkout v1.2.0
   git checkout -b feature/dark-mode
   
   # Developer C
   git checkout v1.2.0
   git checkout -b feature/payment
   ```

2. **Develop independently**:
   - Each developer works on their feature
   - No conflicts (isolated work)
   - Can work in parallel

3. **Merge features incrementally**:
   - Developer A merges first: `feature/user-auth → v1.2.0`
   - Developer B updates: `git pull origin v1.2.0` (if needed)
   - Developer B merges: `feature/dark-mode → v1.2.0`
   - Continue until all features merged

4. **Coordinate merges**:
   - Use team chat to coordinate
   - Merge one at a time (easier conflict resolution)
   - Test after each merge

**Best Practices**:
- ✅ Keep version branch updated: `git pull origin v1.2.0`
- ✅ Merge features incrementally (not all at once)
- ✅ Test version branch after each merge
- ✅ Communicate merge order with team

---

### How to Handle Parallel Feature Development

**Scenario**: Multiple features being developed simultaneously

**Process**:
1. **Create separate feature branches**:
   - Each feature gets its own branch
   - Branches are independent
   - No conflicts during development

2. **Coordinate via team chat**:
   - Share what you're working on
   - Discuss dependencies
   - Plan merge order

3. **Merge in logical order**:
   - Merge foundational features first
   - Merge dependent features after
   - Test after each merge

4. **Handle conflicts early**:
   - If conflicts expected, merge early
   - Resolve conflicts incrementally
   - Don't wait until all features done

**Best Practices**:
- ✅ Communicate with team regularly
- ✅ Merge incrementally (not all at once)
- ✅ Test integration after each merge
- ✅ Use feature flags if needed

---

### Coordination for Version Releases

**Process**:
1. **Release planning meeting**:
   - Decide version number (e.g., v1.2.0)
   - Assign features to developers
   - Set timeline and milestones

2. **Create version branch**:
   - Tech lead creates: `v1.2.0` from `develop`
   - Announce to team
   - All developers use this branch

3. **Feature development**:
   - Developers create feature branches
   - Develop features
   - Create PRs to version branch

4. **Feature integration**:
   - Merge features incrementally
   - Test after each merge
   - Fix issues as they arise

5. **Release preparation**:
   - Final testing on version branch
   - Update version numbers
   - Prepare release notes

6. **Release**:
   - Merge `v1.2.0 → develop`
   - Continue flow: `develop → uat → prod`
   - Deploy to production

**Communication Tools**:
- ✅ Team chat (Slack/Teams) for coordination
- ✅ Project board (Jira/GitHub Projects) for tracking
- ✅ Weekly standups for status updates

---

## Release Notes/Changelog

### How to Generate Release Notes

**Process**:
1. **Collect commit messages** from version branch:
   ```bash
   # Get commits since last release
   git log v1.1.0..v1.2.0 --pretty=format:"- %s" > CHANGELOG.md
   ```

2. **Categorize by type**:
   - Features (feat:)
   - Bug fixes (fix:)
   - Documentation (docs:)
   - Performance (perf:)
   - Breaking changes (BREAKING CHANGE:)

3. **Format release notes**:
   ```markdown
   # Release v1.2.0
   
   ## Features
   - Added user authentication
   - Added dark mode support
   - Added payment integration
   
   ## Bug Fixes
   - Fixed memory leak in image loader
   - Fixed crash on login
   
   ## Performance
   - Optimized image loading
   - Reduced app size by 20%
   ```

4. **Add to PR description** or create separate PR

**Automation**: Consider GitHub Actions workflow to auto-generate release notes from commits.

---

### Changelog Maintenance Process

**Location**: `CHANGELOG.md` in repository root

**Format** (Keep a Changelog format):
```markdown
# Changelog

## [1.2.0] - 2024-01-15

### Added
- User authentication feature
- Dark mode support

### Changed
- Updated UI design

### Fixed
- Memory leak in image loader
- Crash on login

## [1.1.0] - 2023-12-01
...
```

**Process**:
1. **Update CHANGELOG.md** as part of version release PR
2. **Add entry** for new version
3. **Categorize changes** (Added, Changed, Fixed, Removed)
4. **Get review** in PR
5. **Merge with version release**

**Best Practice**: Update changelog in the same PR as version release.

---

### What Information to Include in Release Notes

**Required**:
- ✅ Version number (e.g., v1.2.0)
- ✅ Release date
- ✅ Features added (list of new features)
- ✅ Bug fixes (list of fixes)
- ✅ Breaking changes (if any)

**Optional but Recommended**:
- ⚠️ Performance improvements
- ⚠️ Known issues
- ⚠️ Migration guide (for breaking changes)
- ⚠️ Contributors (who worked on release)

**Format Example**:
```markdown
# Release v1.2.0 - January 15, 2024

## 🎉 New Features
- **User Authentication**: Added OAuth login support
- **Dark Mode**: Complete dark theme implementation
- **Payment Integration**: Added Stripe payment processing

## 🐛 Bug Fixes
- Fixed memory leak in image loader
- Resolved crash on login screen
- Fixed navigation issue on iOS

## ⚡ Performance
- Optimized image loading (50% faster)
- Reduced app size by 20%

## ⚠️ Breaking Changes
- Removed deprecated API endpoints (see migration guide)

## 📝 Migration Guide
If you're upgrading from v1.1.0, please see [MIGRATION.md](docs/MIGRATION.md)
```

**Best Practice**: Keep release notes user-friendly and clear, avoid technical jargon.

---

## Summary

**Outcode Git Branching Strategy** ensures:
- ✅ Clear code flow: `feature → version → develop → uat → prod → main`
- ✅ Store-aligned releases: `main` reflects what's live in stores
- ✅ Protected branches: No direct pushes, PRs required
- ✅ Quality gates: All merges require passing checks
- ✅ Version isolation: Features developed in version branches

**Key Principles**:
1. Always use feature branches (never commit directly to protected branches)
2. Use PRs for all merges (with approvals and status checks)
3. Merge prod → main only after store approval
4. Keep branches up to date
5. Follow naming conventions

**Result**: Consistent, high-quality code flow from development to production, aligned with store releases.

