1. Grab latest ***EU/US*** Sanction Lists for review
- https://data.europa.eu/data/datasets/consolidated-list-of-persons-groups-and-entities-subject-to-eu-financial-sanctions?locale=en
- https://ofac.treasury.gov/specially-designated-nationals-and-blocked-persons-list-sdn-human-readable-lists

2. Build automation to
   - Grab sanctioned ```TLD```.
   - Determine ```A```, ```NS```, ```MX``` Records.
   - Understand ***ownership*** of found ```IP Ranges```.
   - Cross-reference ```IP``` and ```Entity``` ***ownership*** to ```Country of Origin```.
  
3. Filter out ***non-EU/US*** ```Country of Origin``` and build report.
   - Should contain ```relevant country(ies)```,```entity(ies)```,```details of suspected violation```.
   - Deterimne if ***ownership*** has offices/relations under ***EU/US*** jurisdiction that can be leveraged.
   
5. For ***EU/US*** ```Country of Origin```
   - Build Report usig relevant template(s).
   - Inform relavant ***ownership/entities*** under ***EU/US*** jurisdiction of the suspected violation. Follow company proccesses [if applicable](https://www.dowjones.com/professional/risk/glossary/sanctions/compliance/).
   - Submit report(s).
   - Build follow-up reminder automation.
