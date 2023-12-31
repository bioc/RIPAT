#################### Test script ####################
library(RIPAT)

input_dir = "[Input_directory]"
input_file = '[Input_file_name]'
output_dir = "[Output_directory]"
output_file_name = '[Used_in_processes_except_for_annotation]'
random_output_file_name = "[Result_with_random_analysis]"
norandom_output_file_name = "[Result_without_random_analysis]"

### 00. Make data files - Do it once at the first time of RIPAT.
#makeData(organism = 'GRCh37')

### 01. Make R object
# Single file
blat_obj = makeInputObj(inFile = paste0(input_dir, '/', input_file),
                        vectorPos = 'front',
                        mapTool = 'blat', 
                        outPath = output_dir,
                        outFileName = paste0(output_file_name, '_single'))
# Several files
blat_obj2 = makeInputObj2(inDir = input_dir,
                          id = 'A5',
                          mapTool = 'blat',
                          vectorPos = 'front',
                          outPath = output_dir,
                          outFileName = paste0(output_file_name, '_multiple'))

### 02. Gene
blat_gene_random = annoByGene(hits = blat_obj2, 
                              organism = 'GRCh37', 
                              interval = 5000,
                              range = c(-20000, 20000), 
                              doRandom = TRUE, 
                              randomSize = 5000, # default = 10000
                              includeUndecided = FALSE,
                              outPath = output_dir,
                              outFileName = random_output_file_name)

blat_gene_norandom = annoByGene(hits = blat_obj,
                                 organism = 'GRCh37',
                                 interval = 5000,
                                 range = c(-20000, 20000), 
                                 doRandom = FALSE,
                                 includeUndecided = FALSE,
                                 outPath = output_dir,
                                 outFileName = norandom_output_file_name)

### 03. CpG
blat_cpg_random = annoByCpG(hits = blat_obj,
                            organism = 'GRCh37',
                            interval = 5000,
                            range = c(-20000, 20000),
                            doRandom = TRUE,
                            randomSize = 5000, #default = 10000
                            includeUndecided = FALSE,
                            outPath = output_dir,
                            outFileName = random_output_file_name)

blat_cpg_norandom = annoByCpG(hits = blat_obj,
                              organism = 'GRCh37',
                              interval = 5000,
                              range = c(-20000, 20000),
                              doRandom = FALSE,
                              includeUndecided = FALSE,
                              outPath = output_dir,
                              outFileName = norandom_output_file_name)

### 04. Pathogenic variant
blat_var_random = annoByVar(hits = blat_obj,
                            organism = 'GRCh37',
                            interval = 5000,
                            range = c(-20000, 20000),
                            doRandom = TRUE,
                            randomSize = 5000, # default = 10000
                            includeUndecided = FALSE,
                            outPath = output_dir,
                            outFileName = random_output_file_name)

blat_var_norandom = annoByVar(hits = blat_obj,
                              organism = 'GRCh37',
                              interval = 5000,
                              range = c(-20000, 20000),
                              doRandom = FALSE,
                              includeUndecided = FALSE,
                              outPath = output_dir,
                              outFileName = norandom_output_file_name)

### 05. Repeat
blat_repeat_random = annoByRepeat(hits = blat_obj,
                                  organism = 'GRCh37',
                                  interval = 5000,
                                  range = c(-20000, 20000),
                                  doRandom = TRUE,
                                  randomSize = 1000, # default = 10000
                                  includeUndecided = FALSE,
                                  outPath = output_dir,
                                  outFileName = random_output_file_name)

blat_repeat_norandom = annoByRepeat(hits = blat_obj,
                                    organism = 'GRCh37',
                                    interval = 5000,
                                    range = c(-20000, 20000),
                                    doRandom = FALSE,
                                    includeUndecided = FALSE,
                                    outPath = output_dir,
                                    outFileName = norandom_output_file_name)

### 06. Karyogram
# Single file
karyo_gene = drawingKaryo(hits = blat_obj,
                          organism = "GRCh37",
                          feature = blat_gene_norandom$Gene_data,  
                          includeUndecided = FALSE,
                          outPath = output_dir,
                          outFileName = paste0(output_file_name, '_single'))

# Several files
karyo_gene2 = drawingKaryo(hits = blat_obj,
                          organism = "GRCh37",
                          feature = blat_gene_norandom$Gene_data,  
                          includeUndecided = FALSE,
                          outPath = output_dir,
                          outFileName = paste0(output_file_name, '_multiple'))

### 07. Make result files
results = makeDocument(res = blat_gene_random,
                       resType = 'gene',
                       interval = 5000,
                       range = c(-20000, 20000),
                       includeUndecided = FALSE,
                       outPath = output_dir,
                       outFileName = paste0(output_file_name, '_multiple'))

