
<!-- README.md is generated from README.Rmd. Please edit that file -->

# graphql.parse

<!-- badges: start -->
<!-- badges: end -->

The goal of graphql.parse is to parse GraphQL schemas in an R-style way

## Installation

You can install the development version of graphql.parse like so:

``` r
remotes::install_github("HIBio/graphql.parse")
```

## Example

`query_builder()` walks up and down the schema, enabling users to
dynamically select the fields they wish to be returned

``` r
library(graphql.parse)
query_string <- query_builder()
```

<img src="man/figures/demo.gif" />

    Options in Query; Select next level, or 0 to finish 

     1: meta                     2: target                   3: targets               
     4: disease                  5: diseases                 6: drug                  
     7: drugs                    8: search                   9: associationDatasources
    10: interactionResources    11: geneOntologyTerms       12: up 1 level            


    Selection: 6
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

    Template for variables:

    variables = list(
       chemblId = character(1)
    )

This `query_string` can then be passed along with the necessary
variables to the API

``` r
run_query(query_string, variables = list(chemblId = "CHEMBL1201828"))
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

The schema can also be fetched once then re-used in additional queries

``` r
schema <- get_schema()
cat(substring(schema, 1, 50))
#> type APIVersion {
#>   x: String!
#>   y: String!
#>   z: S
```

This can then be used in the `query_builder()` without hitting the
endpoint just to retrieve the schema

``` r
query_builder(schema = schema)
```

Alternatively, the Genetics API can be used. When an `api_url` is
specified in `query_builder()`, it is stored in the query string and
accessible to `run_query`

``` r
qs <- query_builder(api_url = OT_GENETICS_API)
```

    Options in Query; Select next level, or 0 to finish 

     1: meta                                   2: search                              
     3: genes                                  4: geneInfo                            
     5: studyInfo                              6: variantInfo                         
     7: studiesForGene                         8: studyLocus2GeneTable                
     9: manhattan                             10: topOverlappedStudies                
    11: overlapInfoForStudy                   12: tagVariantsAndStudiesForIndexVariant
    13: indexVariantsAndStudiesForTagVariant  14: pheWAS                              
    15: gecko                                 16: regionPlot                          
    17: genesForVariantSchema                 18: genesForVariant                     
    19: gwasRegional                          20: qtlRegional                         
    21: studyAndLeadVariantInfo               22: gwasCredibleSet                     
    23: qtlCredibleSet                        24: colocalisationsForGene              
    25: gwasColocalisationForRegion           26: gwasColocalisation                  
    27: qtlColocalisation                     28: studiesAndLeadVariantsForGene       
    29: studiesAndLeadVariantsForGeneByL2G    30: up 1 level                          


    Selection: 4
    Options in Gene; Select next level, or 0 to finish 

     1: id            2: symbol        3: bioType       4: description   5: chromosome    6: tss        
     7: start         8: end           9: fwdStrand    10: exons        11: up 1 level   

    Selection: 1
    Options in Gene; Select next level, or 0 to finish 

     1: id            2: symbol        3: bioType       4: description   5: chromosome    6: tss        
     7: start         8: end           9: fwdStrand    10: exons        11: up 1 level   

    Selection: 2
    Options in Gene; Select next level, or 0 to finish 

     1: id            2: symbol        3: bioType       4: description   5: chromosome    6: tss        
     7: start         8: end           9: fwdStrand    10: exons        11: up 1 level   

    Selection: 4
    Options in Gene; Select next level, or 0 to finish 

     1: id            2: symbol        3: bioType       4: description   5: chromosome    6: tss        
     7: start         8: end           9: fwdStrand    10: exons        11: up 1 level   

    Selection: 0
    query gql( 
      $geneId: String! 
    ) { 
       geneInfo(geneId: $geneId) { 
          id 
          symbol 
          description 
       } 
    }

    Template for variables:

    variables = list(
       geneId = character(1)
    )

``` r
run_query(qs, variables = list(geneId = "ENSG00000197405"))
#> $geneInfo
#> $geneInfo$id
#> [1] "ENSG00000197405"
#> 
#> $geneInfo$symbol
#> [1] "C5AR1"
#> 
#> $geneInfo$description
#> [1] "complement C5a receptor 1 [Source:HGNC Symbol;Acc:HGNC:1338]"
```

# Canned Queries

Some canned queries are available. To fetch the `dataVersion`

``` r
dataVersion(OT_API)
#> Warning in api_url.default(query_string): No api_url detected on this object
#> $name
#> [1] "Open Targets GraphQL & REST API Beta"
#> 
#> $dataVersion
#>      year     month iteration 
#>      "23"      "09"       "0"

dataVersion(OT_GENETICS_API)
#> Warning in api_url.default(query_string): No api_url detected on this object
#> $name
#> [1] "Open Targets Genetics Portal"
#> 
#> $dataVersion
#> major minor patch 
#>    22    10     0
```

# Documentation

[This video](https://www.youtube.com/watch?v=_sZR0VxpwqE) provides a
great overview of the OpenTargets GraphQL API.

[![](https://img.youtube.com/vi/_sZR0VxpwqE/0.jpg)](https://www.youtube.com/watch?v=_sZR0VxpwqE)

# Limitations

This package is designed to work with any GraphQL schema, but is
currently limited to those endpoints which support a plaintext schema
hosted at `<GRAPHQL_API>/schema`. An improvement to this package would
involve fetching the schema itself via the API.

The OpenTargets (and OpenTargets Genetics) GraphQL APIs are currently
supported and the APIs are stored as exported variables in this package,
`OT_API` and `OT_GENETICS_API`.
