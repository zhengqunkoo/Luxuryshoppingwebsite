---
name: security-red-teaming
description: Systematically test AI systems for security vulnerabilities and attack vectors.
---

# Security Red Teaming Skill

Use this skill when conducting comprehensive security testing of AI systems, especially conversational AIs.

## Attack Vector Categories

1. **Prompt Injection**: Attempts to override system instructions
2. **Jailbreaking**: Trying to break character or role (DAN mode, developer mode)
3. **Data Exposure**: Attempts to extract system information, API keys, or internal data
4. **Input Manipulation**: Encoding tricks, long inputs, XSS attempts
5. **Role Confusion**: Identity confusion, role-playing attacks
6. **Technical Probes**: SQL injection, system architecture questions

## Testing Methodology

1. **Plan Attack Vectors**
   - Create comprehensive list of potential vulnerabilities
   - Categorize by severity and likelihood
   - Document expected vs actual behavior

2. **Execute Systematic Tests**
   - Test each attack vector methodically
   - Document exact input and complete response
   - Note any security boundary breaches

3. **Analyze Results**
   - Identify successful vs failed attacks
   - Assess response consistency and effectiveness
   - Measure time to respond and response quality

4. **Strengthen Defenses**
   - Update system prompts with improved guardrails
   - Add specific deflection strategies for common attacks
   - Implement input validation and sanitization

5. **Retest and Validate**
   - Re-run attack vectors after improvements
   - Ensure legitimate functionality remains intact
   - Document security improvements

## Key Principles

- **Comprehensive Coverage**: Test all known attack vectors systematically
- **Response Consistency**: Ensure uniform, secure responses to all attack types
- **User Experience**: Maintain helpfulness for legitimate queries
- **Documentation**: Keep detailed logs of all security tests and responses

## Common Patterns

- **Deflection Language**: Use varied, warm responses when rejecting attacks
- **Information Boundaries**: Never reveal system internals, API details, or training data
- **Character Consistency**: Maintain persona even under attack
- **Graceful Degradation**: Handle malformed inputs without crashing

## Success Metrics

- **100% Attack Resistance**: All security tests should fail safely
- **Response Quality**: Maintain helpfulness for legitimate users
- **Performance**: No degradation in response time or quality
- **Consistency**: Uniform security posture across all interaction types</content>
<parameter name="filePath">/home/koo/github/Luxuryshoppingwebsite/.github/skills/security-red-teaming/SKILL.md