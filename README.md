
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

This is a basic example which shows you how to solve a common problem:

``` r
library(graphql.parse)
schema <- httr::content(httr::GET("https://api.platform.opentargets.org/api/v4/graphql/schema"))
schema_els <- strsplit(schema, "(?<=})", perl = TRUE)[[1]]
# drop blank lines
schema_els <- gsub("\n\n", "\n", schema_els)
classes <- sapply(schema_els, detect_class)
splits <- split(schema_els, classes)
types <- splits$type
types2 <- setNames(types, sapply(sapply(types, parse_elements), \(x) x$object_class))
```

Note the complicating subquery classes (denoted by entry
`subquery_class`)!

``` r
qry <- types2[names(types2) == "Disease"]
cat(qry)
#> 
#> "Disease or phenotype entity"
#> type Disease {
#>   "Open Targets disease id"
#>   id: String!
#>   "Disease name"
#>   name: String!
#>   "Disease description"
#>   description: String
#>   "List of external cross reference IDs"
#>   dbXRefs: [String!]
#>   "List of direct location Disease terms"
#>   directLocationIds: [String!]
#>   "List of indirect location Disease terms"
#>   indirectLocationIds: [String!]
#>   "List of obsolete diseases"
#>   obsoleteTerms: [String!]
#>   "Disease synonyms"
#>   synonyms: [DiseaseSynonyms!]
#>   ancestors: [String!]!
#>   descendants: [String!]!
#>   "Ancestor therapeutic area disease entities in ontology"
#>   therapeuticAreas: [Disease!]!
#>   "Disease parents entities in ontology"
#>   parents: [Disease!]!
#>   "Disease children entities in ontology"
#>   children: [Disease!]!
#>   "Direct Location disease terms"
#>   directLocations: [Disease!]!
#>   "Indirect Location disease terms"
#>   indirectLocations: [Disease!]!
#>   "Return similar labels using a model Word2CVec trained with PubMed"
#>   similarEntities(
#>     "List of IDs either EFO ENSEMBL CHEMBL"
#>     additionalIds: [String!],
#>     "List of entity names to search for (target, disease, drug,...)"
#>     entityNames: [String!],
#>     "Threshold similarity between 0 and 1"
#>     threshold: Float, size: Int): [Similarity!]!
#>   "Return the list of publications that mention the main entity, alone or in combination with other entities"
#>   literatureOcurrences(
#>     "List of IDs either EFO ENSEMBL CHEMBL"
#>     additionalIds: [String!], cursor: String): Publications!
#>   "Is disease a therapeutic area itself"
#>   isTherapeuticArea: Boolean!
#>   "Phenotype from HPO index"
#>   phenotypes(page: Pagination): DiseaseHPOs
#>   "The complete list of all possible datasources"
#>   evidences(
#>     "List of Ensembl IDs"
#>     ensemblIds: [String!]!,
#>     "Use disease ontology to capture evidences from all descendants to build associations"
#>     enableIndirect: Boolean,
#>     "List of datasource ids"
#>     datasourceIds: [String!], size: Int, cursor: String): Evidences!
#>   "RNA and Protein baseline expression"
#>   otarProjects: [OtarProject!]!
#>   "Clinical precedence for investigational or approved drugs indicated for disease and curated mechanism of action"
#>   knownDrugs(
#>     "Query string"
#>     freeTextQuery: String, size: Int, cursor: String): KnownDrugs
#>   "associations on the fly"
#>   associatedTargets(Bs: [String!],
#>     "Use disease ontology to capture evidences from all descendants to build associations"
#>     enableIndirect: Boolean, datasources: [DatasourceSettingsInput!], aggregationFilters: [AggregationFilter!], BFilter: String, orderByScore: String, page: Pagination): AssociatedTargets!
#> }
x <- parse_elements(qry)
purrr::map(x, ~if (utils::hasName(.x, "subquery_class")) {
  purrr::map(.x, tibble::as_tibble) 
} else {
  tibble::as_tibble(.x)
})
#> $object_class
#> # A tibble: 1 × 1
#>   value  
#>   <chr>  
#> 1 Disease
#> 
#> $id
#> # A tibble: 1 × 3
#>   class   description             nullable
#>   <chr>   <chr>                   <lgl>   
#> 1 String! Open Targets disease id TRUE    
#> 
#> $name
#> # A tibble: 1 × 3
#>   class   description  nullable
#>   <chr>   <chr>        <lgl>   
#> 1 String! Disease name TRUE    
#> 
#> $description
#> # A tibble: 1 × 3
#>   class  description         nullable
#>   <chr>  <chr>               <lgl>   
#> 1 String Disease description FALSE   
#> 
#> $dbXRefs
#> # A tibble: 1 × 3
#>   class     description                          nullable
#>   <chr>     <chr>                                <lgl>   
#> 1 [String!] List of external cross reference IDs FALSE   
#> 
#> $directLocationIds
#> # A tibble: 1 × 3
#>   class     description                           nullable
#>   <chr>     <chr>                                 <lgl>   
#> 1 [String!] List of direct location Disease terms FALSE   
#> 
#> $indirectLocationIds
#> # A tibble: 1 × 3
#>   class     description                             nullable
#>   <chr>     <chr>                                   <lgl>   
#> 1 [String!] List of indirect location Disease terms FALSE   
#> 
#> $obsoleteTerms
#> # A tibble: 1 × 3
#>   class     description               nullable
#>   <chr>     <chr>                     <lgl>   
#> 1 [String!] List of obsolete diseases FALSE   
#> 
#> $synonyms
#> # A tibble: 1 × 3
#>   class              description      nullable
#>   <chr>              <chr>            <lgl>   
#> 1 [DiseaseSynonyms!] Disease synonyms FALSE   
#> 
#> $ancestors
#> # A tibble: 1 × 3
#>   class      description nullable
#>   <chr>      <chr>       <lgl>   
#> 1 [String!]! ""          TRUE    
#> 
#> $descendants
#> # A tibble: 1 × 3
#>   class      description nullable
#>   <chr>      <chr>       <lgl>   
#> 1 [String!]! ""          TRUE    
#> 
#> $therapeuticAreas
#> # A tibble: 1 × 3
#>   class       description                                            nullable
#>   <chr>       <chr>                                                  <lgl>   
#> 1 [Disease!]! Ancestor therapeutic area disease entities in ontology TRUE    
#> 
#> $parents
#> # A tibble: 1 × 3
#>   class       description                          nullable
#>   <chr>       <chr>                                <lgl>   
#> 1 [Disease!]! Disease parents entities in ontology TRUE    
#> 
#> $children
#> # A tibble: 1 × 3
#>   class       description                           nullable
#>   <chr>       <chr>                                 <lgl>   
#> 1 [Disease!]! Disease children entities in ontology TRUE    
#> 
#> $directLocations
#> # A tibble: 1 × 3
#>   class       description                   nullable
#>   <chr>       <chr>                         <lgl>   
#> 1 [Disease!]! Direct Location disease terms TRUE    
#> 
#> $indirectLocations
#> # A tibble: 1 × 3
#>   class       description                     nullable
#>   <chr>       <chr>                           <lgl>   
#> 1 [Disease!]! Indirect Location disease terms TRUE    
#> 
#> $similarEntities
#> $similarEntities$subquery_class
#> # A tibble: 1 × 1
#>   value         
#>   <chr>         
#> 1 [Similarity!]!
#> 
#> $similarEntities$additionalIds
#> # A tibble: 1 × 3
#>   class     description                           nullable
#>   <chr>     <chr>                                 <lgl>   
#> 1 [String!] List of IDs either EFO ENSEMBL CHEMBL FALSE   
#> 
#> $similarEntities$entityNames
#> # A tibble: 1 × 3
#>   class     description                                                  nulla…¹
#>   <chr>     <chr>                                                        <lgl>  
#> 1 [String!] List of entity names to search for (target, disease, drug,.… FALSE  
#> # … with abbreviated variable name ¹​nullable
#> 
#> $similarEntities$threshold
#> # A tibble: 1 × 3
#>   class description                          nullable
#>   <chr> <chr>                                <lgl>   
#> 1 Float Threshold similarity between 0 and 1 FALSE   
#> 
#> $similarEntities$size
#> # A tibble: 1 × 3
#>   class description nullable
#>   <chr> <chr>       <lgl>   
#> 1 Int   ""          FALSE   
#> 
#> 
#> $literatureOcurrences
#> $literatureOcurrences$subquery_class
#> # A tibble: 1 × 1
#>   value        
#>   <chr>        
#> 1 Publications!
#> 
#> $literatureOcurrences$additionalIds
#> # A tibble: 1 × 3
#>   class     description                           nullable
#>   <chr>     <chr>                                 <lgl>   
#> 1 [String!] List of IDs either EFO ENSEMBL CHEMBL FALSE   
#> 
#> $literatureOcurrences$cursor
#> # A tibble: 1 × 3
#>   class  description nullable
#>   <chr>  <chr>       <lgl>   
#> 1 String ""          FALSE   
#> 
#> 
#> $isTherapeuticArea
#> # A tibble: 1 × 3
#>   class    description                          nullable
#>   <chr>    <chr>                                <lgl>   
#> 1 Boolean! Is disease a therapeutic area itself TRUE    
#> 
#> $phenotypes
#> $phenotypes$subquery_class
#> # A tibble: 1 × 1
#>   value      
#>   <chr>      
#> 1 DiseaseHPOs
#> 
#> 
#> $evidences
#> $evidences$subquery_class
#> # A tibble: 1 × 1
#>   value     
#>   <chr>     
#> 1 Evidences!
#> 
#> $evidences$ensemblIds
#> # A tibble: 1 × 3
#>   class      description         nullable
#>   <chr>      <chr>               <lgl>   
#> 1 [String!]! List of Ensembl IDs TRUE    
#> 
#> $evidences$enableIndirect
#> # A tibble: 1 × 3
#>   class   description                                                    nulla…¹
#>   <chr>   <chr>                                                          <lgl>  
#> 1 Boolean Use disease ontology to capture evidences from all descendant… FALSE  
#> # … with abbreviated variable name ¹​nullable
#> 
#> $evidences$datasourceIds
#> # A tibble: 1 × 3
#>   class     description            nullable
#>   <chr>     <chr>                  <lgl>   
#> 1 [String!] List of datasource ids FALSE   
#> 
#> $evidences$size
#> # A tibble: 1 × 3
#>   class description nullable
#>   <chr> <chr>       <lgl>   
#> 1 Int   ""          FALSE   
#> 
#> $evidences$cursor
#> # A tibble: 1 × 3
#>   class  description nullable
#>   <chr>  <chr>       <lgl>   
#> 1 String ""          FALSE   
#> 
#> 
#> $otarProjects
#> # A tibble: 1 × 3
#>   class           description                         nullable
#>   <chr>           <chr>                               <lgl>   
#> 1 [OtarProject!]! RNA and Protein baseline expression TRUE    
#> 
#> $knownDrugs
#> $knownDrugs$subquery_class
#> # A tibble: 1 × 1
#>   value     
#>   <chr>     
#> 1 KnownDrugs
#> 
#> $knownDrugs$freeTextQuery
#> # A tibble: 1 × 3
#>   class  description  nullable
#>   <chr>  <chr>        <lgl>   
#> 1 String Query string FALSE   
#> 
#> $knownDrugs$size
#> # A tibble: 1 × 3
#>   class description nullable
#>   <chr> <chr>       <lgl>   
#> 1 Int   ""          FALSE   
#> 
#> $knownDrugs$cursor
#> # A tibble: 1 × 3
#>   class  description nullable
#>   <chr>  <chr>       <lgl>   
#> 1 String ""          FALSE   
#> 
#> 
#> $associatedTargets
#> $associatedTargets$subquery_class
#> # A tibble: 1 × 1
#>   value             
#>   <chr>             
#> 1 AssociatedTargets!
#> 
#> $associatedTargets$enableIndirect
#> # A tibble: 1 × 3
#>   class   description                                                    nulla…¹
#>   <chr>   <chr>                                                          <lgl>  
#> 1 Boolean Use disease ontology to capture evidences from all descendant… FALSE  
#> # … with abbreviated variable name ¹​nullable
#> 
#> $associatedTargets$datasources
#> # A tibble: 1 × 3
#>   class                      description nullable
#>   <chr>                      <chr>       <lgl>   
#> 1 [DatasourceSettingsInput!] ""          FALSE   
#> 
#> $associatedTargets$aggregationFilters
#> # A tibble: 1 × 3
#>   class                description nullable
#>   <chr>                <chr>       <lgl>   
#> 1 [AggregationFilter!] ""          FALSE   
#> 
#> $associatedTargets$BFilter
#> # A tibble: 1 × 3
#>   class  description nullable
#>   <chr>  <chr>       <lgl>   
#> 1 String ""          FALSE   
#> 
#> $associatedTargets$orderByScore
#> # A tibble: 1 × 3
#>   class  description nullable
#>   <chr>  <chr>       <lgl>   
#> 1 String ""          FALSE   
#> 
#> $associatedTargets$page
#> # A tibble: 1 × 3
#>   class      description nullable
#>   <chr>      <chr>       <lgl>   
#> 1 Pagination ""          FALSE

jsonview::json_tree_view(x)
```

<div id="htmlwidget-6d7eece78ef23a7df87a" style="width:100%;height:480px;" class="jsontreeview html-widget"></div>
<script type="application/json" data-for="htmlwidget-6d7eece78ef23a7df87a">{"x":{"jsonDoc":"eyJvYmplY3RfY2xhc3MiOiJEaXNlYXNlIiwiaWQiOnsiY2xhc3MiOiJTdHJpbmchIiwiZGVzY3JpcHRpb24iOiJPcGVuIFRhcmdldHMgZGlzZWFzZSBpZCIsIm51bGxhYmxlIjp0cnVlfSwibmFtZSI6eyJjbGFzcyI6IlN0cmluZyEiLCJkZXNjcmlwdGlvbiI6IkRpc2Vhc2UgbmFtZSIsIm51bGxhYmxlIjp0cnVlfSwiZGVzY3JpcHRpb24iOnsiY2xhc3MiOiJTdHJpbmciLCJkZXNjcmlwdGlvbiI6IkRpc2Vhc2UgZGVzY3JpcHRpb24iLCJudWxsYWJsZSI6ZmFsc2V9LCJkYlhSZWZzIjp7ImNsYXNzIjoiW1N0cmluZyFdIiwiZGVzY3JpcHRpb24iOiJMaXN0IG9mIGV4dGVybmFsIGNyb3NzIHJlZmVyZW5jZSBJRHMiLCJudWxsYWJsZSI6ZmFsc2V9LCJkaXJlY3RMb2NhdGlvbklkcyI6eyJjbGFzcyI6IltTdHJpbmchXSIsImRlc2NyaXB0aW9uIjoiTGlzdCBvZiBkaXJlY3QgbG9jYXRpb24gRGlzZWFzZSB0ZXJtcyIsIm51bGxhYmxlIjpmYWxzZX0sImluZGlyZWN0TG9jYXRpb25JZHMiOnsiY2xhc3MiOiJbU3RyaW5nIV0iLCJkZXNjcmlwdGlvbiI6Ikxpc3Qgb2YgaW5kaXJlY3QgbG9jYXRpb24gRGlzZWFzZSB0ZXJtcyIsIm51bGxhYmxlIjpmYWxzZX0sIm9ic29sZXRlVGVybXMiOnsiY2xhc3MiOiJbU3RyaW5nIV0iLCJkZXNjcmlwdGlvbiI6Ikxpc3Qgb2Ygb2Jzb2xldGUgZGlzZWFzZXMiLCJudWxsYWJsZSI6ZmFsc2V9LCJzeW5vbnltcyI6eyJjbGFzcyI6IltEaXNlYXNlU3lub255bXMhXSIsImRlc2NyaXB0aW9uIjoiRGlzZWFzZSBzeW5vbnltcyIsIm51bGxhYmxlIjpmYWxzZX0sImFuY2VzdG9ycyI6eyJjbGFzcyI6IltTdHJpbmchXSEiLCJkZXNjcmlwdGlvbiI6IiIsIm51bGxhYmxlIjp0cnVlfSwiZGVzY2VuZGFudHMiOnsiY2xhc3MiOiJbU3RyaW5nIV0hIiwiZGVzY3JpcHRpb24iOiIiLCJudWxsYWJsZSI6dHJ1ZX0sInRoZXJhcGV1dGljQXJlYXMiOnsiY2xhc3MiOiJbRGlzZWFzZSFdISIsImRlc2NyaXB0aW9uIjoiQW5jZXN0b3IgdGhlcmFwZXV0aWMgYXJlYSBkaXNlYXNlIGVudGl0aWVzIGluIG9udG9sb2d5IiwibnVsbGFibGUiOnRydWV9LCJwYXJlbnRzIjp7ImNsYXNzIjoiW0Rpc2Vhc2UhXSEiLCJkZXNjcmlwdGlvbiI6IkRpc2Vhc2UgcGFyZW50cyBlbnRpdGllcyBpbiBvbnRvbG9neSIsIm51bGxhYmxlIjp0cnVlfSwiY2hpbGRyZW4iOnsiY2xhc3MiOiJbRGlzZWFzZSFdISIsImRlc2NyaXB0aW9uIjoiRGlzZWFzZSBjaGlsZHJlbiBlbnRpdGllcyBpbiBvbnRvbG9neSIsIm51bGxhYmxlIjp0cnVlfSwiZGlyZWN0TG9jYXRpb25zIjp7ImNsYXNzIjoiW0Rpc2Vhc2UhXSEiLCJkZXNjcmlwdGlvbiI6IkRpcmVjdCBMb2NhdGlvbiBkaXNlYXNlIHRlcm1zIiwibnVsbGFibGUiOnRydWV9LCJpbmRpcmVjdExvY2F0aW9ucyI6eyJjbGFzcyI6IltEaXNlYXNlIV0hIiwiZGVzY3JpcHRpb24iOiJJbmRpcmVjdCBMb2NhdGlvbiBkaXNlYXNlIHRlcm1zIiwibnVsbGFibGUiOnRydWV9LCJzaW1pbGFyRW50aXRpZXMiOnsic3VicXVlcnlfY2xhc3MiOiJbU2ltaWxhcml0eSFdISIsImFkZGl0aW9uYWxJZHMiOnsiY2xhc3MiOiJbU3RyaW5nIV0iLCJkZXNjcmlwdGlvbiI6Ikxpc3Qgb2YgSURzIGVpdGhlciBFRk8gRU5TRU1CTCBDSEVNQkwiLCJudWxsYWJsZSI6ZmFsc2V9LCJlbnRpdHlOYW1lcyI6eyJjbGFzcyI6IltTdHJpbmchXSIsImRlc2NyaXB0aW9uIjoiTGlzdCBvZiBlbnRpdHkgbmFtZXMgdG8gc2VhcmNoIGZvciAodGFyZ2V0LCBkaXNlYXNlLCBkcnVnLC4uLikiLCJudWxsYWJsZSI6ZmFsc2V9LCJ0aHJlc2hvbGQiOnsiY2xhc3MiOiJGbG9hdCIsImRlc2NyaXB0aW9uIjoiVGhyZXNob2xkIHNpbWlsYXJpdHkgYmV0d2VlbiAwIGFuZCAxIiwibnVsbGFibGUiOmZhbHNlfSwic2l6ZSI6eyJjbGFzcyI6IkludCIsImRlc2NyaXB0aW9uIjoiIiwibnVsbGFibGUiOmZhbHNlfX0sImxpdGVyYXR1cmVPY3VycmVuY2VzIjp7InN1YnF1ZXJ5X2NsYXNzIjoiUHVibGljYXRpb25zISIsImFkZGl0aW9uYWxJZHMiOnsiY2xhc3MiOiJbU3RyaW5nIV0iLCJkZXNjcmlwdGlvbiI6Ikxpc3Qgb2YgSURzIGVpdGhlciBFRk8gRU5TRU1CTCBDSEVNQkwiLCJudWxsYWJsZSI6ZmFsc2V9LCJjdXJzb3IiOnsiY2xhc3MiOiJTdHJpbmciLCJkZXNjcmlwdGlvbiI6IiIsIm51bGxhYmxlIjpmYWxzZX19LCJpc1RoZXJhcGV1dGljQXJlYSI6eyJjbGFzcyI6IkJvb2xlYW4hIiwiZGVzY3JpcHRpb24iOiJJcyBkaXNlYXNlIGEgdGhlcmFwZXV0aWMgYXJlYSBpdHNlbGYiLCJudWxsYWJsZSI6dHJ1ZX0sInBoZW5vdHlwZXMiOnsic3VicXVlcnlfY2xhc3MiOiJEaXNlYXNlSFBPcyJ9LCJldmlkZW5jZXMiOnsic3VicXVlcnlfY2xhc3MiOiJFdmlkZW5jZXMhIiwiZW5zZW1ibElkcyI6eyJjbGFzcyI6IltTdHJpbmchXSEiLCJkZXNjcmlwdGlvbiI6Ikxpc3Qgb2YgRW5zZW1ibCBJRHMiLCJudWxsYWJsZSI6dHJ1ZX0sImVuYWJsZUluZGlyZWN0Ijp7ImNsYXNzIjoiQm9vbGVhbiIsImRlc2NyaXB0aW9uIjoiVXNlIGRpc2Vhc2Ugb250b2xvZ3kgdG8gY2FwdHVyZSBldmlkZW5jZXMgZnJvbSBhbGwgZGVzY2VuZGFudHMgdG8gYnVpbGQgYXNzb2NpYXRpb25zIiwibnVsbGFibGUiOmZhbHNlfSwiZGF0YXNvdXJjZUlkcyI6eyJjbGFzcyI6IltTdHJpbmchXSIsImRlc2NyaXB0aW9uIjoiTGlzdCBvZiBkYXRhc291cmNlIGlkcyIsIm51bGxhYmxlIjpmYWxzZX0sInNpemUiOnsiY2xhc3MiOiJJbnQiLCJkZXNjcmlwdGlvbiI6IiIsIm51bGxhYmxlIjpmYWxzZX0sImN1cnNvciI6eyJjbGFzcyI6IlN0cmluZyIsImRlc2NyaXB0aW9uIjoiIiwibnVsbGFibGUiOmZhbHNlfX0sIm90YXJQcm9qZWN0cyI6eyJjbGFzcyI6IltPdGFyUHJvamVjdCFdISIsImRlc2NyaXB0aW9uIjoiUk5BIGFuZCBQcm90ZWluIGJhc2VsaW5lIGV4cHJlc3Npb24iLCJudWxsYWJsZSI6dHJ1ZX0sImtub3duRHJ1Z3MiOnsic3VicXVlcnlfY2xhc3MiOiJLbm93bkRydWdzIiwiZnJlZVRleHRRdWVyeSI6eyJjbGFzcyI6IlN0cmluZyIsImRlc2NyaXB0aW9uIjoiUXVlcnkgc3RyaW5nIiwibnVsbGFibGUiOmZhbHNlfSwic2l6ZSI6eyJjbGFzcyI6IkludCIsImRlc2NyaXB0aW9uIjoiIiwibnVsbGFibGUiOmZhbHNlfSwiY3Vyc29yIjp7ImNsYXNzIjoiU3RyaW5nIiwiZGVzY3JpcHRpb24iOiIiLCJudWxsYWJsZSI6ZmFsc2V9fSwiYXNzb2NpYXRlZFRhcmdldHMiOnsic3VicXVlcnlfY2xhc3MiOiJBc3NvY2lhdGVkVGFyZ2V0cyEiLCJlbmFibGVJbmRpcmVjdCI6eyJjbGFzcyI6IkJvb2xlYW4iLCJkZXNjcmlwdGlvbiI6IlVzZSBkaXNlYXNlIG9udG9sb2d5IHRvIGNhcHR1cmUgZXZpZGVuY2VzIGZyb20gYWxsIGRlc2NlbmRhbnRzIHRvIGJ1aWxkIGFzc29jaWF0aW9ucyIsIm51bGxhYmxlIjpmYWxzZX0sImRhdGFzb3VyY2VzIjp7ImNsYXNzIjoiW0RhdGFzb3VyY2VTZXR0aW5nc0lucHV0IV0iLCJkZXNjcmlwdGlvbiI6IiIsIm51bGxhYmxlIjpmYWxzZX0sImFnZ3JlZ2F0aW9uRmlsdGVycyI6eyJjbGFzcyI6IltBZ2dyZWdhdGlvbkZpbHRlciFdIiwiZGVzY3JpcHRpb24iOiIiLCJudWxsYWJsZSI6ZmFsc2V9LCJCRmlsdGVyIjp7ImNsYXNzIjoiU3RyaW5nIiwiZGVzY3JpcHRpb24iOiIiLCJudWxsYWJsZSI6ZmFsc2V9LCJvcmRlckJ5U2NvcmUiOnsiY2xhc3MiOiJTdHJpbmciLCJkZXNjcmlwdGlvbiI6IiIsIm51bGxhYmxlIjpmYWxzZX0sInBhZ2UiOnsiY2xhc3MiOiJQYWdpbmF0aW9uIiwiZGVzY3JpcHRpb24iOiIiLCJudWxsYWJsZSI6ZmFsc2V9fX0=","scroll":false,"jsonDocName":"x"},"evals":[],"jsHooks":[]}</script>
