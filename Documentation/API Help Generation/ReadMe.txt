=== Generate API CHM Help ===
1. To generate API docs you need to generate the source help files from the JScript code, and a SandCastle help project based on a template
2. Build the help file (TestComplete1.chm) and discard the final result
3. Run updates on working files required to make TestComplete <F1> functionality work
4. Regenerate TestComplete1.chm by running HTML Help Builder form the command line
5. Copy TestComplete1.chm to the testComplete /Help folder in program files 