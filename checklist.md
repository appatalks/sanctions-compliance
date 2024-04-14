[x] 1. Grab latest ***EU/US*** Sanction Lists for review
- https://data.europa.eu/data/datasets/consolidated-list-of-persons-groups-and-entities-subject-to-eu-financial-sanctions?locale=en
- https://ofac.treasury.gov/specially-designated-nationals-and-blocked-persons-list-sdn-human-readable-lists

2. Build automation to
[x]   - Grab sanctioned ```TLD```.
[ ]   - Determine ```A```, ```NS```, ```MX``` Records.
        - [x] ```A```
        - [ ] ```NS```
        - [ ] ```MX```
[x]   - Understand ***ownership*** of found ```IP Ranges```.
[x]   - Cross-reference ```IP``` and ```Entity``` ***ownership*** to ```Country of Origin```.
  
3. Filter out ***non-EU/US*** ```Country of Origin``` and build report.
[x]   - Should contain ```relevant country(ies)```,```entity(ies)```,```details of suspected violation```.
[x]   - Deterimne if ***ownership*** has offices/relations under ***EU/US*** jurisdiction that can be leveraged.
   
5. For ***EU/US*** ```Country of Origin```
[x]   - Build Report using relevant template(s).
[x]   - Inform relevant ***ownership/entities*** under ***EU/US*** jurisdiction of the suspected violation. Follow company processes [if applicable](https://www.dowjones.com/professional/risk/glossary/sanctions/compliance/).
[x]   - Submit report(s).
[ ]   - Build follow-up reminder automation.
