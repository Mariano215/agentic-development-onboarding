# VibeOps Daily Practices Checklist

This checklist embodies the VibeOps principles in daily development work. Use it to maintain the mindset and practices that lead to high-quality, maintainable code.

## Before starting any feature

### Frame first
- [ ] Clearly define the problem this feature solves
- [ ] Identify the user story and acceptance criteria
- [ ] Define success metrics and observable outcomes
- [ ] Document assumptions and constraints
- [ ] Create a rough architectural sketch

### Model threats
- [ ] Identify potential failure modes
- [ ] Consider security implications
- [ ] Think about performance bottlenecks
- [ ] Plan for error handling and edge cases
- [ ] Consider backward compatibility requirements
- [ ] Plan rollback strategy

## During development

### Human judgment
- [ ] Code review your own work before submitting
- [ ] Ask "Does this make sense to a future maintainer?"
- [ ] Choose clarity over cleverness
- [ ] Write meaningful commit messages
- [ ] Document complex decisions and trade-offs
- [ ] Test edge cases and error conditions

### Verification gates
- [ ] Run unit tests before each commit
- [ ] Verify integration tests pass
- [ ] Check code coverage meets standards
- [ ] Run static analysis and linting
- [ ] Test in realistic environments
- [ ] Verify monitoring and logging work

## Before deployment

### All gates green
- [ ] All automated tests pass
- [ ] Code review approved
- [ ] Security scanning complete
- [ ] Performance benchmarks met
- [ ] Documentation updated
- [ ] Rollback plan tested

### Observable
- [ ] Monitoring and alerting configured
- [ ] Log levels and messages verified
- [ ] Metrics collection working
- [ ] Error tracking enabled
- [ ] Health checks implemented
- [ ] Debugging information available

## End of day reflection

### Proof over progress
- [ ] What did I actually verify works today?
- [ ] What assumptions did I validate?
- [ ] What evidence do I have of quality?
- [ ] What corners did I cut and why?
- [ ] What technical debt did I create/address?

### Learning
- [ ] What new thing did I learn today?
- [ ] What would I do differently next time?
- [ ] What patterns or anti-patterns did I encounter?
- [ ] What questions came up that need research?
- [ ] What knowledge should I share with the team?

## Weekly review

### Patterns
- [ ] What bugs/issues repeated this week?
- [ ] What design patterns worked well?
- [ ] What architectural decisions proved good/bad?
- [ ] What testing strategies were effective?
- [ ] What communication patterns helped/hindered?

### Improvements
- [ ] What processes can be streamlined?
- [ ] What tools could improve productivity?
- [ ] What knowledge gaps need addressing?
- [ ] What documentation needs updating?
- [ ] What team practices should change?

### Skills
- [ ] What technical skills do I want to develop?
- [ ] What domain knowledge would help?
- [ ] What architectural understanding is missing?
- [ ] What tools should I learn better?
- [ ] What soft skills need attention?

---

## Usage Tips

- Keep this checklist visible during development
- Check items as you complete them
- Don't skip items even when rushing
- Use failed items as learning opportunities
- Customize sections based on your project needs
- Share patterns and learnings with your team

Remember: **Quality is not negotiable. Speed comes from skill, not shortcuts.**