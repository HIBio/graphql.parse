
<!-- README.md is generated from README.Rmd. Please edit that file -->

# graphql.parse

<!-- badges: start -->
<!-- badges: end -->

The goal of graphql.parse is to parse GraphQL schemas in an R-style way

## Installation

You can install the development version of graphql.parse like so:

``` r
remotes::install_github("HIBio/graphql.parse)
```

## Example

`query_builder()` walks up and down the schema, enabling users to
dynamically select the fields they wish to be returned

``` r
library(graphql.parse)
api_url <- "https://api.platform.opentargets.org/api/v4/graphql"
query_string <- query_builder(api_url)
```

``` bash
Options in Query; Select next level, or 0 to finish 

 1: object_class             2: meta                     3: target                   4: targets               
 5: disease                  6: diseases                 7: drug                     8: drugs                 
 9: search                  10: associationDatasources  11: interactionResources    12: geneOntologyTerms     
13: up 1 level              

Selection: 7
Options in Drug; Select next level, or 0 to finish 

 1: id                          2: name                        3: synonyms                 
 4: tradeNames                  5: yearOfFirstApproval         6: drugType                 
 7: isApproved                  8: crossReferences             9: maximumClinicalTrialPhase
10: hasBeenWithdrawn           11: blackBoxWarning            12: description              
13: parentMolecule             14: childMolecules             15: approvedIndications      
16: drugWarnings               17: similarEntities            18: literatureOcurrences     
19: mechanismsOfAction         20: indications                21: knownDrugs               
22: adverseEvents              23: linkedDiseases             24: linkedTargets            
25: up 1 level                 

Selection: 1
Options in Drug; Select next level, or 0 to finish 

 1: id                          2: name                        3: synonyms                 
 4: tradeNames                  5: yearOfFirstApproval         6: drugType                 
 7: isApproved                  8: crossReferences             9: maximumClinicalTrialPhase
10: hasBeenWithdrawn           11: blackBoxWarning            12: description              
13: parentMolecule             14: childMolecules             15: approvedIndications      
16: drugWarnings               17: similarEntities            18: literatureOcurrences     
19: mechanismsOfAction         20: indications                21: knownDrugs               
22: adverseEvents              23: linkedDiseases             24: linkedTargets            
25: up 1 level                 

Selection: 19
Options in MechanismsOfAction; Select next level, or 0 to finish 

1: rows
2: uniqueActionTypes
3: uniqueTargetTypes
4: up 1 level

Selection: 1
Options in MechanismOfActionRow; Select next level, or 0 to finish 

1: mechanismOfAction
2: actionType
3: targetName
4: references
5: targets
6: up 1 level

Selection: 1
Options in MechanismOfActionRow; Select next level, or 0 to finish 

1: mechanismOfAction
2: actionType
3: targetName
4: references
5: targets
6: up 1 level

Selection: 3
Options in MechanismOfActionRow; Select next level, or 0 to finish 

1: mechanismOfAction
2: actionType
3: targetName
4: references
5: targets
6: up 1 level

Selection: 5
Options in Target; Select next level, or 0 to finish 

 1: id                     2: alternativeGenes       3: approvedSymbol         4: approvedName        
 5: biotype                6: chemicalProbes         7: dbXrefs                8: functionDescriptions
 9: geneticConstraint     10: genomicLocation       11: geneOntology          12: hallmarks           
13: homologues            14: pathways              15: proteinIds            16: safetyLiabilities   
17: subcellularLocations  18: synonyms              19: symbolSynonyms        20: nameSynonyms        
21: obsoleteSymbols       22: obsoleteNames         23: targetClass           24: tep                 
25: tractability          26: transcriptIds         27: similarEntities       28: literatureOcurrences
29: evidences             30: interactions          31: mousePhenotypes       32: expressions         
33: knownDrugs            34: associatedDiseases    35: up 1 level            

Selection: 1
Options in Target; Select next level, or 0 to finish 

 1: id                     2: alternativeGenes       3: approvedSymbol         4: approvedName        
 5: biotype                6: chemicalProbes         7: dbXrefs                8: functionDescriptions
 9: geneticConstraint     10: genomicLocation       11: geneOntology          12: hallmarks           
13: homologues            14: pathways              15: proteinIds            16: safetyLiabilities   
17: subcellularLocations  18: synonyms              19: symbolSynonyms        20: nameSynonyms        
21: obsoleteSymbols       22: obsoleteNames         23: targetClass           24: tep                 
25: tractability          26: transcriptIds         27: similarEntities       28: literatureOcurrences
29: evidences             30: interactions          31: mousePhenotypes       32: expressions         
33: knownDrugs            34: associatedDiseases    35: up 1 level            

Selection: 3
Options in Target; Select next level, or 0 to finish 

 1: id                     2: alternativeGenes       3: approvedSymbol         4: approvedName        
 5: biotype                6: chemicalProbes         7: dbXrefs                8: functionDescriptions
 9: geneticConstraint     10: genomicLocation       11: geneOntology          12: hallmarks           
13: homologues            14: pathways              15: proteinIds            16: safetyLiabilities   
17: subcellularLocations  18: synonyms              19: symbolSynonyms        20: nameSynonyms        
21: obsoleteSymbols       22: obsoleteNames         23: targetClass           24: tep                 
25: tractability          26: transcriptIds         27: similarEntities       28: literatureOcurrences
29: evidences             30: interactions          31: mousePhenotypes       32: expressions         
33: knownDrugs            34: associatedDiseases    35: up 1 level            

Selection: 35
Options in Target; Select next level, or 0 to finish 

1: mechanismOfAction
2: actionType
3: targetName
4: references
5: targets
6: up 1 level

Selection: 4
Options in Reference; Select next level, or 0 to finish 

1: ids
2: source
3: urls
4: up 1 level

Selection: 2
Options in Reference; Select next level, or 0 to finish 

1: ids
2: source
3: urls
4: up 1 level

Selection: 3
Options in Reference; Select next level, or 0 to finish 

1: ids
2: source
3: urls
4: up 1 level

Selection: 0
query gql( 
   $chemblId: String! 
) { 
   drug(chemblId: $chemblId) { 
      id 
      mechanismsOfAction { 
         rows { 
            mechanismOfAction 
            targetName 
            targets { 
               id 
               approvedSymbol 
            } 
            references { 
               source 
               urls 
            } 
         } 
      } 
   } 
}
```

This `query_string` can then be passed along with the necessary
variables to the API

``` r
run_query(api_url, query_string, variables = list(chemblId = "CHEMBL1201828"))
#> $drug
#> $drug$id
#> [1] "CHEMBL1201828"
#> 
#> $drug$mechanismsOfAction
#> $drug$mechanismsOfAction$rows
#> $drug$mechanismsOfAction$rows[[1]]
#> $drug$mechanismsOfAction$rows[[1]]$mechanismOfAction
#> [1] "Complement C5 inhibitor"
#> 
#> $drug$mechanismsOfAction$rows[[1]]$targetName
#> [1] "Complement C5"
#> 
#> $drug$mechanismsOfAction$rows[[1]]$targets
#> $drug$mechanismsOfAction$rows[[1]]$targets[[1]]
#> $drug$mechanismsOfAction$rows[[1]]$targets[[1]]$id
#> [1] "ENSG00000106804"
#> 
#> $drug$mechanismsOfAction$rows[[1]]$targets[[1]]$approvedSymbol
#> [1] "C5"
#> 
#> 
#> 
#> $drug$mechanismsOfAction$rows[[1]]$references
#> $drug$mechanismsOfAction$rows[[1]]$references[[1]]
#> $drug$mechanismsOfAction$rows[[1]]$references[[1]]$source
#> [1] "DailyMed"
#> 
#> $drug$mechanismsOfAction$rows[[1]]$references[[1]]$urls
#> $drug$mechanismsOfAction$rows[[1]]$references[[1]]$urls[[1]]
#> [1] "http://dailymed.nlm.nih.gov/dailymed/lookup.cfm?setid=ebcd67fa-b4d1-4a22-b33d-ee8bf6b9c722"
```
