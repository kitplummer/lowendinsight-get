# LowEndInsight Roadmap: Dynamic Intelligence Signals

This document captures potential signals LEI could derive from repositories and external sources, with a prioritized roadmap for implementation.

## Vision

Expand LEI from static snapshot analysis to **dynamic trend intelligence** - not just "what is the bus factor today" but "is the bus factor improving or declining?"

---

## Signal Catalog

### Tier 1: Git History Analysis (No External API Required)

These signals can be computed purely from `git log` and repository contents.

| Signal | Description | Computation | Predictive Value |
|--------|-------------|-------------|------------------|
| **Commit velocity trend** | Is commit rate accelerating or decelerating? | Compare commits/month over trailing quarters | High - early warning of slowdown |
| **Contributor churn** | Net change in active contributors | (new contributors - departed) / period | High - sustainability signal |
| **Code churn rate** | % of codebase rewritten vs added | Lines modified / total lines over period | Medium - stability indicator |
| **File hotspots** | Files with highest change frequency | Rank files by commit count | Medium - risk concentration |
| **Commit message entropy** | Quality of commit messages | NLP analysis, length distribution | Low-Medium - discipline signal |
| **Bot commit ratio** | % commits from bots (dependabot, renovate) | Pattern match on author/email | Medium - maintenance mode indicator |
| **Release cadence** | Time between tagged releases | Analyze tag timestamps | Medium - predictability |
| **Contributor onboarding rate** | New contributors per period | First-commit analysis | Medium - community growth |
| **Weekend/off-hours commits** | Work pattern sustainability | Timestamp analysis | Low - burnout indicator |
| **Merge vs rebase patterns** | Development workflow hygiene | Commit graph analysis | Low - process maturity |

### Tier 2: Code Analysis (Static Analysis of Repo Contents)

| Signal | Description | Computation | Predictive Value |
|--------|-------------|-------------|------------------|
| **Dependency depth** | Total transitive dependencies | Parse lockfiles, build dep graph | High - supply chain complexity |
| **Dependency freshness** | How outdated are dependencies? | Compare locked versions to latest | High - security debt indicator |
| **Test file ratio** | Test code to production code | File pattern matching, LOC ratio | Medium - quality investment |
| **Documentation coverage** | README, docs/, inline comments | File presence, comment ratio | Medium - maintainability |
| **License compatibility** | Conflicts in dependency licenses | Parse LICENSE files, SPDX | Medium - legal risk |
| **Build system complexity** | Number of build configs, scripts | File enumeration | Low - onboarding friction |

### Tier 3: External API Signals (GitHub/GitLab API Required)

| Signal | Description | API Source | Predictive Value |
|--------|-------------|------------|------------------|
| **Issue backlog trend** | Is open issue count growing? | Issues API | High - maintainer bandwidth |
| **PR time-to-merge** | How fast are PRs merged? | Pull Requests API | High - responsiveness |
| **Star/fork trajectory** | Interest trend over time | Repo stats API | Medium - community momentum |
| **Fork activity vs upstream** | Are forks more active? | Compare fork commit rates | High - abandonment signal |
| **Downstream dependents** | Projects depending on this | Dependency graph API | Medium - blast radius |
| **Sponsor/funding status** | Financial backing present? | Sponsors API | Medium - viability |
| **Security advisory history** | Past CVE count and frequency | Security advisories API | High - security culture |
| **Discussion activity** | Community engagement | Discussions API | Low - community health |

### Tier 4: Behavioral/Social Signals (Qualitative)

| Signal | Description | Detection Method | Predictive Value |
|--------|-------------|------------------|------------------|
| **Governance model** | BDFL vs committee vs foundation | README/GOVERNANCE.md parsing | Medium - resilience |
| **Corporate backing** | Company sponsor identified | Author email domains, README | Medium - stability |
| **Code of conduct** | Community standards present | File presence | Low - community health |
| **Contributing guide** | Onboarding documentation | File presence, quality | Low - accessibility |
| **Breaking change frequency** | Semver major bump rate | Tag/release analysis | Medium - integration risk |

---

## Implementation Roadmap

### Phase 1: Core Trend Signals (Q1 2026)

Focus on highest-value signals computable from git history alone.

#### 1.1 Commit Velocity Trend
- Compare commits/month across trailing 3, 6, 12 month windows
- Output: `accelerating`, `stable`, `decelerating`, `stalled`
- Risk mapping: decelerating → medium, stalled → high

#### 1.2 Contributor Churn Analysis
- Track first-commit and last-commit dates per contributor
- Compute: new contributors, departed contributors, net change
- Output: `growing`, `stable`, `shrinking`, `exodus`
- Risk mapping: shrinking → medium, exodus → critical

#### 1.3 Dependency Freshness Score
- Parse lockfiles (package-lock.json, go.sum, mix.lock, etc.)
- Compare to latest versions (requires network for lookup)
- Output: % deps outdated, avg staleness in months
- Risk mapping: >50% outdated or >12mo avg → high

### Phase 2: External Intelligence (Q2 2026)

Add GitHub/GitLab API integration for richer signals.

#### 2.1 Issue Backlog Trend
- Fetch open issue count over time
- Compute: growth rate, avg time open
- Risk mapping: growing backlog + long avg time → high

#### 2.2 Fork Divergence Detection
- Compare upstream commit rate to top forks
- Detect when forks are more active than upstream
- Risk mapping: fork > upstream activity → warning

### Phase 3: Advanced Analysis (Q3 2026)

- Code churn analysis
- File hotspot detection
- Dependency depth graphing
- Security advisory correlation

---

## API Response Evolution

Current response:
```json
{
  "risk": "low",
  "contributor_count": 25,
  "functional_contributors": 8,
  "commit_currency_weeks": 2
}
```

Proposed enhanced response:
```json
{
  "risk": "low",
  "contributor_count": 25,
  "functional_contributors": 8,
  "commit_currency_weeks": 2,
  "trends": {
    "velocity": "stable",
    "velocity_delta": -0.12,
    "contributor_churn": "growing",
    "contributor_net_change": 3,
    "dependency_freshness": 0.73,
    "deps_outdated_count": 12,
    "issue_backlog_trend": "stable"
  },
  "alerts": [
    {"signal": "dependency_freshness", "severity": "medium", "message": "27% of dependencies are >6 months outdated"}
  ]
}
```

---

## Implementation Notes

### Caching Strategy
- Trend computations are expensive - cache aggressively
- Separate TTL for snapshot metrics (shorter) vs trend metrics (longer)
- Allow force-refresh for trend recomputation

### Performance Considerations
- Git history analysis scales with repo size
- Consider sampling for very large repos (>100k commits)
- Async computation for trend metrics

### Configuration
- Make trend windows configurable (default: 3/6/12 months)
- Allow disabling expensive computations
- API rate limit configuration for external APIs

---

## Success Metrics

| Metric | Target |
|--------|--------|
| Trend signal computation time | <5s for 95th percentile |
| False positive rate (risk prediction) | <10% |
| Adoption of trend signals in API responses | 80% of queries request trends |
| Correlation with future CVEs | Measurable correlation within 6 months |

---

## References

- [Bus Factor research](https://arxiv.org/abs/1604.06766)
- [Technical Debt quantification](https://www.sciencedirect.com/science/article/pii/S0164121218301456)
- [OSS sustainability signals](https://dl.acm.org/doi/10.1145/3196398.3196454)
