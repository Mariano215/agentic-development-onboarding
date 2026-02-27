# Agentic Development Onboarding System - Design Document

**Date:** 2026-02-27
**Author:** Claude Code + Mariano A. Mattei
**Status:** Approved Design

## Executive Summary

This document outlines the design for a foolproof Claude Code onboarding system that transforms developers from traditional to agentic development mindset. The system embodies the VibeOps philosophy through a modular tutorial that teaches **verification-first development** when code is abundant and judgment is scarce.

## Problem Statement

Current Issue: New users get overwhelmed by the comprehensive Claude Code setup and don't know where to start, despite having sophisticated scripts and agents available.

Target Solution: A guided tutorial system that teaches the **why** behind agentic development through hands-on experience with a full-stack application, following the VibeOps manifesto principles.

## Design Principles

Based on the Agentic Development Manifesto:

1. **Intent over Requirements**: Teach executable acceptance criteria
2. **Proof over Progress**: Nothing advances without verification gates
3. **Verification-first**: Security and testing are first-class citizens
4. **Human Judgment**: AI generates, humans decide tradeoffs
5. **Observability**: All decisions and outputs are auditable
6. **Progressive Complexity**: Frame → Model → Generate → Verify/Observe

## Architecture

### Repository Structure

```
claude-code-agentic-onboarding/
├── README.md                           # Entry point with manifesto overview
├── AGENTIC_DEVELOPMENT_MANIFESTO.md    # Core philosophy document
├── onboard.sh                          # Master orchestrator script
├── setup-current-project.sh            # Integrates with existing projects
├── tutorial-phases/
│   ├── phase0-philosophy/              # Manifesto deep dive (mandatory)
│   │   ├── understand-paradigm.sh     # Interactive walkthrough
│   │   ├── old-vs-new.md             # Traditional vs Agentic comparison
│   │   └── assessment.sh             # Readiness evaluation
│   ├── phase1-frame/                  # Intent → Constraints
│   │   ├── define-intent.sh          # Acceptance test workshop
│   │   ├── constraints-template.md   # Non-negotiables template
│   │   └── demo-intent/              # Example transformations
│   ├── phase2-model/                  # Threats → Boundaries
│   │   ├── threat-modeling.sh        # Guided threat analysis
│   │   ├── security-boundaries.sh    # Least privilege setup
│   │   └── demo-threats/             # Todo app threat model
│   ├── phase3-generate/               # Scaffold → Code
│   │   ├── agentic-scaffold.sh       # Agent-driven generation
│   │   ├── prompt-versioning.sh      # Prompt management
│   │   └── demo-generation/          # Generated todo app
│   └── phase4-verify-observe/         # Tests + Gates + Signals
│       ├── security-gates.sh         # SAST, secrets, policy
│       ├── test-gates.sh            # Unit/integration/e2e
│       ├── deploy-observe.sh        # Monitoring & rollback
│       └── demo-deployment/         # Live observable app
├── verification-gates/                 # Reusable verification system
│   ├── security-pipeline.sh          # OWASP checks, scanning
│   ├── quality-pipeline.sh           # Coverage, complexity
│   └── deployment-pipeline.sh        # Canary, health, rollback
├── manifesto-integration/             # Philosophy embedding tools
│   ├── add-to-project.sh            # Adds manifesto to projects
│   ├── daily-checklist.md           # VibeOps practices
│   └── decision-framework.md        # Agentic decision making
├── shared/                           # Reusable components
│   ├── verification.sh              # Common validation functions
│   ├── project-templates/           # Base templates
│   └── agent-configs/               # Reusable configurations
├── examples/                         # Reference implementations
│   ├── completed-tutorial/          # Expected final result
│   └── troubleshooting/             # Common issues
└── tests/                           # Meta-testing system
    ├── manifesto-alignment/         # Philosophy adherence
    ├── learning-effectiveness/      # Educational outcomes
    └── tutorial-robustness/         # System reliability
```

### Integration with Current Setup

The onboarding system integrates with the existing `/home/mmattei/Projects` structure:

1. **Manifesto Integration**: Adds `AGENTIC_DEVELOPMENT_MANIFESTO.md` to current directory
2. **Script Enhancement**: Updates existing scripts to reference manifesto principles
3. **Template Updates**: Enhances project templates with VibeOps integration
4. **Agent Team Support**: Includes beta features like agent teams in advanced phases

## User Journey & Data Flow

### Complete Learning Flow

```
Clone Repo → Phase 0 (Philosophy) → Assessment Gate →
Phase 1 (Frame) → Acceptance Tests Gate →
Phase 2 (Model) → Security Gate →
Phase 3 (Generate) → Code Verification Gate →
Phase 4 (Verify/Observe) → Production Readiness Gate →
Graduation: Agentic Developer
```

### State Management

**Progress Tracking:**
```
~/.claude-onboarding/
├── progress.json              # Completion status, scores
├── manifesto-assessment/      # Philosophy understanding
├── demo-project/             # Evolving tutorial project
└── verification-history/     # All gate results, timestamped
```

**Gate Dependencies:**
- Phase 1: Requires manifesto assessment > 80%
- Phase 2: Requires all acceptance tests passing
- Phase 3: Requires security threat model approved
- Phase 4: Requires all generated code passing gates
- Graduation: Requires production deployment with observability

### Knowledge Transfer Mechanism

Each phase demonstrates a fundamental shift:

- **Phase 0 → 1**: Requirements docs → Executable acceptance criteria
- **Phase 1 → 2**: Security afterthought → Threat modeling first
- **Phase 2 → 3**: Manual coding → Human judgment + agent generation
- **Phase 3 → 4**: Deploy and pray → Verify then observe

## Component Details

### Master Orchestrator (`onboard.sh`)

VibeOps-driven menu system:
1. **Start VibeOps Tutorial** → Full 4-phase journey
2. **Jump to Phase X** → Resume from checkpoint
3. **Verify Current State** → Run all gates on existing work
4. **Reset & Clean** → Fresh environment

**Key Feature**: Verification gates before each phase. No progression without green gates.

### Tutorial Phases

**Phase 0 - Philosophy (Mandatory)**
- Interactive manifesto walkthrough
- Traditional vs agentic mindset comparison
- Assessment to ensure readiness
- **Gate**: 80% philosophy assessment score

**Phase 1 - Frame (Intent → Constraints)**
- Workshop for writing acceptance tests first
- Template for capturing non-negotiables
- Example: "Todo app" → "Todo app with offline sync, XSS prevention, <30s rollback"
- **Gate**: All requirements are testable

**Phase 2 - Model (Threats → Boundaries)**
- Guided threat analysis using OWASP LLM Top 10
- Least privilege setup and data classification
- Security-first architecture decisions
- **Gate**: Complete threat model approved

**Phase 3 - Generate (Scaffold → Code)**
- Agent-driven code generation to meet Phase 1 tests
- Prompt versioning and management
- Human judgment decision points
- **Gate**: All acceptance tests pass + code quality standards

**Phase 4 - Verify/Observe (Tests + Gates + Signals)**
- SAST, secrets scanning, policy checks
- Full test suite (unit/integration/e2e)
- Observable deployment with monitoring and rollback
- **Gate**: Production-ready deployment running

### Verification System

**Security Pipeline:**
- OWASP vulnerability scanning
- Secret detection and removal
- Policy compliance validation
- Dependency vulnerability checks

**Quality Pipeline:**
- Code complexity analysis
- Test coverage requirements
- Maintainability metrics
- Performance benchmarks

**Deployment Pipeline:**
- Canary deployment validation
- Health check implementation
- Rollback plan testing
- Observability setup

## Error Handling & Recovery

### Failure Categories

**Philosophy Resistance (Phase 0)**
- Personalized remediation based on gaps
- Side-by-side traditional vs agentic examples
- Retry with targeted materials

**Intent Definition Failures (Phase 1)**
- Interactive intent refinement workshop
- Template-guided acceptance test writing
- "Can this be verified?" validation loop

**Security Modeling Gaps (Phase 2)**
- OWASP-guided threat walkthrough
- Progressive disclosure starting with obvious threats
- Security gate simulation showing real vulnerabilities

**Generation/Verification Failures (Phase 3-4)**
- Iterative refinement process demonstration
- Human judgment decision points clearly marked
- Learn from failure: update prompts and constraints

### Recovery Mechanisms

**Graceful Degradation:**
- No Claude Code? → Conceptual walkthrough mode
- Agent generation fails? → Manual coding with verification gates
- Security tools missing? → Checklist-based security review
- Deployment issues? → Local development with mock observability

**Safety Nets:**
- Sandboxed tutorial environment
- Git checkpoints at every gate passage
- "Nuclear reset" option for any phase
- Backup verification methods when tools fail

## Testing & Validation

### Self-Verification (Eating Our Own Dog Food)

**Meta-Level Testing:**
- **Manifesto Alignment**: Does tutorial match principles?
- **Learning Effectiveness**: Does it actually teach agentic thinking?
- **Tutorial Robustness**: Handles real-world chaos gracefully?

**Continuous Validation:**
- Automated complete journey testing
- Integration testing with existing Projects setup
- Real-world validation with actual developers

### Success Metrics (VibeOps Style)

**Speed AND Quality:**
- Time to complete tutorial (lead time)
- Percentage passing each gate on first try (quality)
- Number of "aha moments" reported (learning effectiveness)
- Skill transfer to real projects (practical application)

**Observability for Learning:**
- Confusion points → Improve materials
- Stuck points → Better error handling
- Excitement generators → Emphasize these aspects
- Graduate performance → Validate approach

## Implementation Priorities

### Phase 1: Core Infrastructure
1. Repository structure and manifesto integration
2. Master orchestrator script
3. Basic verification gate framework
4. Integration with current Projects setup

### Phase 2: Tutorial Content
1. Phase 0 (Philosophy) with assessment
2. Phase 1 (Frame) with acceptance testing
3. Demo project foundation
4. Basic error handling

### Phase 3: Advanced Features
1. Phases 2-4 (Model, Generate, Verify/Observe)
2. Full verification pipeline
3. Agent team integration
4. Complete error recovery system

### Phase 4: Polish & Scale
1. Comprehensive testing suite
2. Documentation and troubleshooting
3. Performance optimization
4. Community feedback integration

## Success Criteria

**Immediate (Post-Implementation):**
- New users can complete tutorial without getting stuck
- 80%+ pass rate on first attempt for each phase
- Clear understanding of VibeOps principles demonstrated

**Medium-term (3 months):**
- Tutorial graduates successfully apply agentic principles to real projects
- Reduced support requests about "where to start" with Claude Code
- Positive feedback on learning experience

**Long-term (6+ months):**
- Community adoption and contribution to tutorial improvements
- Demonstrable improvement in code quality and delivery speed for graduates
- Tutorial becomes the standard onboarding for agentic development practices

## Conclusion

This design creates a comprehensive onboarding system that transforms developers' mindset from traditional to agentic through hands-on experience. By embedding the manifesto principles throughout and requiring verification gates at each step, users learn not just the tools but the fundamental philosophy of verification-first development.

The modular design allows for progressive complexity while the comprehensive error handling ensures no one gets left behind. Most importantly, it embodies the VibeOps principle that "proof beats progress" - every step must be verified before advancement.

---

**Next Steps:** Create detailed implementation plan using writing-plans skill.