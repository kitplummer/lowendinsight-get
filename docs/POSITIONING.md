# LowEndInsight: Leading Intelligence for Supply Chain Risk

> **Know before you `go get`**

## The Problem with Traditional Security Scanning

Traditional supply chain security tools tell you what's already broken. CVE databases, NVD lookups, and SBOM vulnerability scanners are *forensic* - they examine the corpse after the damage is done.

| Traditional Signal | What It Tells You | The Problem |
|-------------------|-------------------|-------------|
| CVE disclosed | "This component has a known vulnerability" | Already exploited in the wild |
| NVD severity | "Here's how bad it is" | Reactive - you've already shipped it |
| SBOM scan | "You have 47 vulnerable dependencies" | Remediation is expensive |

This model worked when humans reviewed every dependency addition. But in the age of **vibe-coding** and **agentic engineering**, where AI agents make dependency decisions at speed, waiting for CVEs is waiting too long.

## Leading Indicators: Vital Signs, Not Autopsies

LowEndInsight provides **leading intelligence** - predictive signals about open source project health that indicate *future* risk, not just *known* vulnerabilities.

| LEI Signal | What It Tells You | Why It Matters |
|------------|-------------------|----------------|
| **Bus Factor** | "2 people maintain this entire project" | Predicts abandonment, slow patches |
| **Commit Currency** | "Last commit was 18 months ago" | Predicts unpatched vulns, security debt |
| **Functional Contributors** | "1 person does 90% of the work" | Predicts burnout, handoff risk |
| **Contributor Trajectory** | "Active contributors down 60% YoY" | Predicts project sunset |

### The Core Difference

```
CVE/NVD:  "You adopted something that IS broken"
LEI:      "You're about to adopt something that WILL break"
```

Traditional security is **forensic** - examining what went wrong.
LowEndInsight is **diagnostic** - checking vital signs before you operate.

## Where LEI Fits in the Dependency Lifecycle

LEI doesn't replace CVE scanning - it complements it by shifting risk detection *left*, to the moment of consideration rather than the moment of crisis.

```
┌─────────────────────────────────────────────────────────────────┐
│                     Dependency Lifecycle                         │
├────────────────┬────────────────┬────────────────┬──────────────┤
│    CONSIDER    │     ADOPT      │      RUN       │    RETIRE    │
├────────────────┼────────────────┼────────────────┼──────────────┤
│   LEI check    │   SBOM gen     │   CVE scan     │  EOL notice  │
│   (leading)    │   (baseline)   │   (lagging)    │  (lagging)   │
└────────────────┴────────────────┴────────────────┴──────────────┤
         ▲                                  ▲                      │
         │                                  │                      │
    PREVENTION                         DETECTION                   │
    (cheap, fast)                      (expensive, slow)           │
└──────────────────────────────────────────────────────────────────┘
```

**Prevention is cheaper than remediation.** A dependency you never adopt can't become a CVE you have to patch at 2am.

## Agentic Engineering and Vibe-Coding

In modern development workflows, AI agents are making more decisions:

- **Vibe-coding**: Developers describe intent; agents write implementation
- **Agentic CI/CD**: Agents select dependencies, resolve conflicts, update packages
- **Autonomous refactoring**: Agents modernize codebases, swap libraries

These agents operate at speed. They don't have time to wait for a CVE disclosure cycle. They need *instant* signal about whether a dependency is healthy.

### The Agentic Workflow with LEI

**With leading intelligence:**
```
Agent considers adding dependency
  → LEI pre-flight check (milliseconds)
  → "Bus factor: 1, No commits in 2 years, Risk: HIGH"
  → Agent finds alternative OR flags for human review
  → Risky dependency never enters codebase
```

**Without leading intelligence:**
```
Agent adds dependency (looks fine, no CVEs!)
  → Shipped to production
  → 6 months later: CVE disclosed
  → Emergency patching cycle
  → Incident response
  → Post-mortem reveals: project was abandoned, vuln sat unpatched for a year
```

## Air-Gapped and Disconnected Deployments

For environments using [Zarf](https://github.com/zarf-dev/zarf), UDS, or similar air-gapped deployment tools, leading intelligence is even more critical:

- **Updates are expensive**: You can't just `npm update` in a SCIF
- **Approval cycles are long**: New packages require security review
- **Prevention beats remediation**: Bad dependencies are *very* hard to remove

LEI's cache export/import enables **pre-deployment risk assessment**:

1. Analyze your SBOM in a connected environment
2. Export the LEI cache
3. Import to your air-gapped LEI instance
4. All future checks are instant, no network required

## Integration Patterns

### Pre-Commit / Pre-Merge Gate

```bash
# In CI pipeline - fail fast on high-risk new dependencies
lei-check --sbom sbom.json --fail-on-risk high
```

### Agentic Guardrail

```python
# Agent considering a new dependency
result = lei.analyze("https://github.com/some/dependency")
if result.risk in ["high", "critical"]:
    return find_alternative(result.reasons)
```

### Continuous Monitoring

```bash
# Weekly health check on existing dependencies
lei-check --sbom production-sbom.json --report weekly-risk-report.json
```

## Key Metrics Explained

### Bus Factor
The minimum number of contributors who would need to disappear for the project to stall. A bus factor of 1 means a single person leaving could kill the project.

- **Low risk**: 5+ functional contributors
- **Medium risk**: 3-4 functional contributors
- **High risk**: 2 functional contributors
- **Critical risk**: 1 functional contributor

### Commit Currency
How recently the project has been actively developed. Stale projects accumulate security debt.

- **Low risk**: Commits within last month
- **Medium risk**: 1-6 months since last commit
- **High risk**: 6-12 months since last commit
- **Critical risk**: 12+ months since last commit

### Contributor Trajectory
Is the project growing, stable, or declining? Declining contributor counts often precede abandonment.

### Large Recent Commit Risk
Has a large portion of the codebase been recently rewritten? Large changes introduce risk, especially from new contributors.

## The Bottom Line

Every dependency is a bet on the future. CVE databases tell you which bets already lost. LowEndInsight helps you place better bets.

> **Leading indicators for lagging-free deployments.**

---

## Learn More

- [API Reference](API.md) - Integrate LEI into your workflow
- [Operations Guide](OPERATIONS.md) - Deploy LEI in your environment
- [LowEndInsight Core](https://github.com/kitplummer/lowendinsight) - The analysis engine

## Quick Start

```bash
# Analyze a repository
curl -X POST 'http://localhost:4000/v1/analyze' \
  -H 'Content-Type: application/json' \
  -d '{"urls":["https://github.com/your/dependency"], "cache_mode": "blocking"}'

# Analyze your entire SBOM
curl -X POST 'http://localhost:4000/v1/analyze/sbom' \
  -H 'Content-Type: application/json' \
  -d '{"sbom": <your-cyclonedx-or-spdx>, "cache_mode": "blocking"}'
```
