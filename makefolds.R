# These functions generate the nfolds.RData that contains the nfolds object (list) with the foldassignments

## Outer 5-fold CV loops  
makefolds <- function(y, cv.fold = 5){   
  n <- length(y)
  nlvl <- table(y)
  idx <- numeric(n)
  folds <- list()
  for (i in 1:length(nlvl)) {
    idx[which(y == levels(y)[i])] <- sample(rep(1:cv.fold, length = nlvl[i]))
  }
  for (i in 1:cv.fold){
    folds[[i]] <- list(train = which(idx != i),
                       test =  which(idx == i)) 
  }  
  return(folds)
}

## Inner/Nested 5-fold CV loops ==> combine nested test/calibration sets ==> Train Calibration model ==> PREDICT
makenestedfolds <- function(y, cv.fold = 5){
  nfolds <- list()
  folds <- makefolds(y, cv.fold)
  names(folds) <- paste0("outer", 1:length(folds))
  for(k in 1:length(folds)){
    inner = makefolds(y[folds[[k]]$train], cv.fold)
    names(inner) <- paste0("inner", 1:length(folds))
    for(i in 1:length(inner)){
      inner[[i]]$train <- folds[[k]]$train[inner[[i]]$train]
      inner[[i]]$test <- folds[[k]]$train[inner[[i]]$test]
    }
    nfolds[[k]] <- list(folds[k], inner) 
  }
  names(nfolds) <- paste0("outer", 1:length(nfolds))
  return(nfolds)
}

