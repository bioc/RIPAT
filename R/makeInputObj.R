#' @title Make the retroviral vector integration site object.
#' 
#' @description
#' Make an input object for annotation functions.
#'              
#' @usage 
#' makeInputObj(inFile, mapTool = 'blast', 
#'              vectorPos = 'front', outPath = getwd(), 
#'              outFileName = paste0('RIPAT', round(unclass(Sys.time()))))
#' 
#' @param inFile a string vector. The path of a local alignment result file.
#'               File do not include any header and comment.
#' @param mapTool a character vector. Function serves two types of file
#'                such as outputs from BLAST and BLAT. Default is 'blast'.
#'                If you want to use BLAT result, use 'blat'.
#' @param vectorPos a character vector. Sets the position of vector on sequences.
#'                  Default value is 'front'. If the vector is located at the behind of sequence,
#'                  you can change it to 'behind'. 
#' @param outPath a string vector. Directory path of tab-deliminated hit files
#'                generated by this function.
#' @param outFileName a character vector. Attached character to the result file name.
#' 
#' @return Return two types of outputs. Text file and R object.
#'         Available hit data from input is written in text file and
#'         generated as a list of GenomicRange(GR) format object.
#'         
#' @examples 
#' blast_obj = makeInputObj(inFile = paste0(.libPaths()[1], '/RIPAT/scripts/A5_15856M_BLASTn.txt'))
#' 
#' @export
makeInputObj = function(inFile, mapTool = 'blast', vectorPos = 'front', outPath = getwd(), outFileName = paste0('RIPAT', round(unclass(Sys.time())))){
  message('----- Create R objects for integration site annotation. (Time : ', date(), ')')
  message('- Validate an input file.')
  if(length(which(c('blast', 'blat') %in% mapTool)) == 0){stop("[ERROR] Please confirm the alignment tool name.\n----- This process is halted. (Time : ", date(), ")\n")}
  hitTable = utils::read.delim(inFile, header = FALSE, stringsAsFactors = FALSE)
  if(mapTool == 'blast'){
    if(ncol(hitTable) != 12){
      stop("[ERROR] Please check column of your input file!\n----- This process is halted. (Time :" , date(), ')\n')
    }
    } else if(mapTool == 'blat'){
      if(ncol(hitTable) != 21){
        stop("[ERROR] Please check column of your input file!\n----- This process is halted. (Time :" , date(), ')\n')
      }
    }
  message('- OK!')
  if(stringr::str_ends(outPath, pattern = '/')){
    outPath = stringr::word(outPath, start = 1, end = nchar(outPath), sep = '')
  } else {NULL}
  message('- Edit an input file.')
  if(mapTool == 'blast'){
    hitTable = subset(hitTable, stringr::str_detect(hitTable[,2], '_') == FALSE)[,-c(5,6,11,12)]
    strand = hitTable$V9 - hitTable$V10;
    key1 = which(strand > 0); key2 = which(strand <= 0)
    new_start = hitTable$V9; new_end = hitTable$V10
    new_start[key1] = hitTable$V10[key1]; new_end[key1] = hitTable$V9[key1]
    strand[key1] = '-'; strand[key2] = '+'
    hitTable$V2[which(!stringr::str_detect(as.character(hitTable$V2), 'chr'))] = paste0('chr', hitTable$V2[which(!stringr::str_detect(as.character(hitTable$V2), 'chr'))])
    hitTable = data.frame(cbind(hitTable[,c(1:6)], new_start, new_end, strand), stringsAsFactors = FALSE)
    colnames(hitTable) = c('qname', 'sname', 'identity', 'align_length', 'qstart', 'qend', 'sstart', 'send', 'strand')
  } else if(mapTool == 'blat'){
    hitTable = subset(hitTable, stringr::str_detect(hitTable[,14], '_') == FALSE)
    iden = hitTable$V1 / hitTable$V11 * 100
    hitTable = data.frame(cbind(hitTable[,c(10,14)], iden, hitTable[,c(1,12,13,16,17,9)]), stringsAsFactors = FALSE)
    colnames(hitTable) = c('qname', 'sname', 'identity', 'align_length', 'qstart', 'qend', 'sstart', 'send', 'strand')
  }
  pos = vector("integer", length = nrow(hitTable))
  if(vectorPos == 'front'){
    pos[which(hitTable$strand == '+')] = as.numeric(hitTable$sstart)[which(hitTable$strand == '+')] - 1      
    pos[which(hitTable$strand == '-')] = as.numeric(hitTable$send)[which(hitTable$strand == '-')] + 1
  } else if(vectorPos == 'back'){
    pos[which(hitTable$strand == '-')] = as.numeric(hitTable$sstart)[which(hitTable$strand == '-')] - 1
    pos[which(hitTable$strand == '+')] = as.numeric(hitTable$send)[which(hitTable$strand == '+')] + 1
  } else {
    stop("[ERROR] Please check position of vector!\n----- This process is halted. (Time :" , date(), ')\n')}
  hitTable = data.frame(cbind(hitTable, 'integration' = pos), stringsAsFactors = FALSE)
  message('- OK!')
  query_list = sort(unique(hitTable$qname), decreasing = FALSE)
  max_iden_list = lapply(query_list, function(x){tmp = hitTable[which(hitTable$qname == x),];
  iden_max = max(tmp$identity); return(tmp[which(tmp$identity == iden_max),])})
  max_len_list = lapply(max_iden_list, function(x){tmp = max(x$align_length); return(x[which(x$align_length == tmp),])})
  len_list = unlist(lapply(max_len_list, nrow))
  if(length(which(len_list >= 2)) != 0){
    only_hits = data.frame(do.call("rbind", max_len_list[-which(len_list >= 2)]), stringsAsFactors = FALSE)
  } else {
    only_hits = data.frame(do.call("rbind", max_len_list), stringsAsFactors = FALSE)
  }
  dup_hits = data.frame(do.call("rbind", max_len_list[which(len_list >= 2)]), stringsAsFactors = FALSE)
  message('- Make GR object.')
  only_hits_tab = data.frame(only_hits[,c(2,10,10,9,1,3,4)], stringsAsFactors = FALSE)
  colnames(only_hits_tab) = c('seqname', 'start', 'end', 'strand', 'query', 'identity', 'align_length')
  gr_only = GenomicRanges::makeGRangesFromDataFrame(only_hits_tab, keep.extra.columns = TRUE)
  if(nrow(dup_hits) != 0){
    dup_hits_tab = data.frame(dup_hits[,c(2,10,10,9,1,3,4)], stringsAsFactors = FALSE)
    colnames(dup_hits_tab) =  c('seqname', 'start', 'end', 'strand', 'query', 'identity', 'align_length')
    gr_dup = GenomicRanges::makeGRangesFromDataFrame(dup_hits_tab, keep.extra.columns = TRUE)
  } else {gr_dup = NULL}
  output_list = list('Decided' = gr_only, 'Undecided' = gr_dup)
  message('- OK!')
  message('- Write hit table to file.')
  hitTable_used = data.frame(rbind(only_hits, dup_hits), stringsAsFactors = FALSE)
  utils::write.table(hitTable_used, file = paste0(outPath, '/', outFileName, '_Used_hits_from_', mapTool, '.txt'), append = FALSE, quote = FALSE, sep = '\t', na = '', row.names = FALSE, col.names = TRUE)
  message('----- Finish. (Time : ', date(), ')')
  return(output_list)
}
