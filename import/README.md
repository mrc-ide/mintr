## Importing data

This will evolve as the upstream data changes and as our needs change. These scripts will create rds files that can be used to initialise the app. We'll store these either on mrcdata.dide.ic.ac.uk or as github release artefacts and pull them in fairly automatically during deployment.  They will expand into the actual mint database, which is much larger than the rds but faster to read.

The process (best carried out on Imperial's network).

1. Acquire new data from the science team; this will come in an "index" and "values" file and place them in this directory.
2. Update the names in `scripts/import.R`; likely the dates will have changed
3. Run the script `scripts/import.R` which processes the data and ensures that it's possible to build the database
4. Copy the resulting files (`import/index.rds` and `import/prevalence.rds`) to a network directory (e.g., `~/net/home/mint`)
5. Connect to mrcdata via RDP and move these files into the path `C:\xampp\htdocs\mrcdata\mint` on the server

The files are now available as https://mrcdata.dide.ic.ac.uk/mint/index.rds and https://mrcdata.dide.ic.ac.uk/mint/prevalence.rds
